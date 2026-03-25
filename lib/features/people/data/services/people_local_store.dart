import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:two_space_app/features/chat/data/local/aegis_chat_database.dart';
import 'package:two_space_app/features/people/data/models/call_history_entry.dart';
import 'package:two_space_app/features/people/data/models/person_entry.dart';

class PeopleLocalStore {
  PeopleLocalStore._({AegisChatDatabase? database})
      : _database = database ?? AegisChatDatabase();

  static final PeopleLocalStore instance = PeopleLocalStore._();

  static const _favoritesKey = 'favorites';
  static const _cachedPeopleKey = 'cached_people';
  static const _recentPeopleKey = 'recent_people';
  static const _callHistoryKey = 'call_history';
  static const _migrationMetadataKey = 'people_legacy_json_import_completed';
  static const _cachedBucket = 'cached';
  static const _recentBucket = 'recent';

  final AegisChatDatabase _database;
  bool _initialized = false;
  late File _legacyStoreFile;

  Future<List<String>> readFavorites() async {
    await _ensureInitialized();
    final rows = await (_database.select(_database.aegisPeopleFavorites)
          ..orderBy([(table) => OrderingTerm.asc(table.personId)]))
        .get();
    return rows.map((row) => row.personId).toList(growable: false);
  }

  Future<void> writeFavorites(List<String> ids) async {
    await _ensureInitialized();
    final uniqueIds = ids.toSet().toList(growable: false);
    await _database.transaction(() async {
      await _database.delete(_database.aegisPeopleFavorites).go();
      if (uniqueIds.isEmpty) {
        return;
      }
      await _database.batch((batch) {
        batch.insertAll(
          _database.aegisPeopleFavorites,
          uniqueIds
              .map(
                (id) => AegisPeopleFavoritesCompanion.insert(personId: id),
              )
              .toList(growable: false),
        );
      });
    });
  }

  Future<List<PersonEntry>> readCachedPeople() async {
    await _ensureInitialized();
    return _readPeopleBucket(_cachedBucket);
  }

  Future<void> upsertCachedPeople(List<PersonEntry> people) async {
    final merged = <String, PersonEntry>{
      for (final person in await readCachedPeople()) person.id: person,
    };

    for (final person in people) {
      merged[person.id] = person.copyWith(clearPhotoBytes: true);
    }

    final ordered = merged.values.toList()
      ..sort((a, b) {
        final aTime = a.lastInteractionAt ?? a.lastSeenAt ?? DateTime(1970);
        final bTime = b.lastInteractionAt ?? b.lastSeenAt ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

    await _replacePeopleBucket(_cachedBucket, ordered.take(120).toList());
  }

  Future<List<PersonEntry>> readRecentPeople() async {
    await _ensureInitialized();
    return _readPeopleBucket(_recentBucket);
  }

  Future<void> putRecentPerson(PersonEntry person) async {
    final current = <String, PersonEntry>{
      for (final item in await readRecentPeople()) item.id: item,
    };
    current[person.id] = person.copyWith(
      lastInteractionAt: DateTime.now(),
      clearPhotoBytes: true,
    );

    final ordered = current.values.toList()
      ..sort((a, b) {
        final aTime = a.lastInteractionAt ?? DateTime(1970);
        final bTime = b.lastInteractionAt ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

    await _replacePeopleBucket(_recentBucket, ordered.take(40).toList());
  }

  Future<List<CallHistoryEntry>> readCallHistory() async {
    await _ensureInitialized();
    final rows = await (_database.select(_database.aegisPeopleCallHistory)
          ..orderBy([(table) => OrderingTerm.desc(table.startedAtEpochMs)]))
        .get();
    return rows
        .map(
          (row) => CallHistoryEntry.fromJson(
            Map<String, dynamic>.from(jsonDecode(row.payloadJson) as Map),
          ),
        )
        .toList(growable: false);
  }

  Future<void> appendCallHistory(CallHistoryEntry entry) async {
    await _ensureInitialized();
    final normalized = entry.copyWith(
      person: entry.person.copyWith(clearPhotoBytes: true),
    );
    await _database.into(_database.aegisPeopleCallHistory).insertOnConflictUpdate(
          _callHistoryCompanionFromEntry(normalized),
        );
    await _trimCallHistory(limit: 200);
  }

  Future<void> deleteCallHistory(String id) async {
    await _ensureInitialized();
    await (_database.delete(_database.aegisPeopleCallHistory)
          ..where((table) => table.id.equals(id)))
        .go();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }

    await _prepareLegacyPath();
    await _migrateLegacyStoreIfNeeded();
    _initialized = true;
  }

  Future<void> _prepareLegacyPath() async {
    final directory = await getApplicationSupportDirectory();
    _legacyStoreFile = File('${directory.path}/people_store.json');
  }

  Future<void> _migrateLegacyStoreIfNeeded() async {
    final migrationFlag = await _readMetadata(_migrationMetadataKey);
    if (migrationFlag == 'true') {
      return;
    }

    if (await _hasAnyRows()) {
      await _writeMetadata(_migrationMetadataKey, 'true');
      return;
    }

    final legacyData = await _loadLegacyData();
    if (legacyData == null) {
      await _writeMetadata(_migrationMetadataKey, 'true');
      return;
    }

    await _database.transaction(() async {
      final favorites = (legacyData[_favoritesKey] as List<dynamic>? ?? const <dynamic>[])
          .map((value) => value.toString())
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList(growable: false);
      final cachedPeople = _decodePeopleList(legacyData[_cachedPeopleKey]);
      final recentPeople = _decodePeopleList(legacyData[_recentPeopleKey]);
      final callHistory = _decodeCallHistoryList(legacyData[_callHistoryKey]);

      if (favorites.isNotEmpty) {
        await _database.batch((batch) {
          batch.insertAll(
            _database.aegisPeopleFavorites,
            favorites
                .map(
                  (id) => AegisPeopleFavoritesCompanion.insert(personId: id),
                )
                .toList(growable: false),
          );
        });
      }

      await _replacePeopleBucket(
        _cachedBucket,
        cachedPeople.take(120).toList(growable: false),
      );
      await _replacePeopleBucket(
        _recentBucket,
        recentPeople.take(40).toList(growable: false),
      );

      if (callHistory.isNotEmpty) {
        await _database.batch((batch) {
          batch.insertAllOnConflictUpdate(
            _database.aegisPeopleCallHistory,
            callHistory
                .take(200)
                .map(
                  (entry) => _callHistoryCompanionFromEntry(
                    entry.copyWith(
                      person: entry.person.copyWith(clearPhotoBytes: true),
                    ),
                  ),
                )
                .toList(growable: false),
          );
        });
      }

      await _writeMetadata(_migrationMetadataKey, 'true');
    });
  }

  Future<List<PersonEntry>> _readPeopleBucket(String bucket) async {
    final rows = await (_database.select(_database.aegisPeopleEntries)
          ..where((table) => table.bucket.equals(bucket))
          ..orderBy([(table) => OrderingTerm.desc(table.sortEpochMs)]))
        .get();
    return rows
        .map(
          (row) => PersonEntry.fromJson(
            Map<String, dynamic>.from(jsonDecode(row.payloadJson) as Map),
          ),
        )
        .toList(growable: false);
  }

  Future<void> _replacePeopleBucket(String bucket, List<PersonEntry> people) async {
    await (_database.delete(_database.aegisPeopleEntries)
          ..where((table) => table.bucket.equals(bucket)))
        .go();
    if (people.isEmpty) {
      return;
    }
    await _database.batch((batch) {
      batch.insertAll(
        _database.aegisPeopleEntries,
        people
            .map(
              (person) => _peopleEntryCompanionFromPerson(bucket, person),
            )
            .toList(growable: false),
      );
    });
  }

  Future<void> _trimCallHistory({required int limit}) async {
    final rows = await (_database.select(_database.aegisPeopleCallHistory)
          ..orderBy([(table) => OrderingTerm.desc(table.startedAtEpochMs)]))
        .get();
    if (rows.length <= limit) {
      return;
    }

    final idsToDelete = rows.skip(limit).map((row) => row.id).toList(growable: false);
    await (_database.delete(_database.aegisPeopleCallHistory)
          ..where((table) => table.id.isIn(idsToDelete)))
        .go();
  }

  Future<bool> _hasAnyRows() async {
    final favorite = await (_database.select(_database.aegisPeopleFavorites)
          ..limit(1))
        .getSingleOrNull();
    if (favorite != null) {
      return true;
    }

    final person = await (_database.select(_database.aegisPeopleEntries)
          ..limit(1))
        .getSingleOrNull();
    if (person != null) {
      return true;
    }

    final history = await (_database.select(_database.aegisPeopleCallHistory)
          ..limit(1))
        .getSingleOrNull();
    return history != null;
  }

  Future<String?> _readMetadata(String key) async {
    final row = await (_database.select(_database.aegisMetadata)
          ..where((table) => table.key.equals(key))
          ..limit(1))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> _writeMetadata(String key, String value) {
    return _database.into(_database.aegisMetadata).insertOnConflictUpdate(
          AegisMetadataCompanion.insert(
            key: key,
            value: value,
          ),
        );
  }

  Future<Map<String, dynamic>?> _loadLegacyData() async {
    if (!await _legacyStoreFile.exists()) {
      return null;
    }

    try {
      final content = await _legacyStoreFile.readAsString();
      final decoded = jsonDecode(content);
      if (decoded is! Map) {
        return null;
      }
      return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
  }

  AegisPeopleEntriesCompanion _peopleEntryCompanionFromPerson(
    String bucket,
    PersonEntry person,
  ) {
    final normalized = person.copyWith(clearPhotoBytes: true);
    final sortEpochMs =
        (normalized.lastInteractionAt ?? normalized.lastSeenAt)?.millisecondsSinceEpoch ?? 0;

    return AegisPeopleEntriesCompanion.insert(
      bucket: bucket,
      personId: normalized.id,
      payloadJson: jsonEncode(normalized.toJson()),
      displayName: normalized.displayName,
      username: Value(normalized.username),
      remoteUserId: Value(normalized.remoteUserId),
      isTwoSpaceUser: Value(normalized.isTwoSpaceUser),
      isDeviceContact: Value(normalized.isDeviceContact),
      isFavorite: Value(normalized.isFavorite),
      isOnline: Value(normalized.isOnline),
      presenceStatus: Value(normalized.presenceStatus),
      lastSeenAtEpochMs: Value(normalized.lastSeenAt?.millisecondsSinceEpoch),
      lastInteractionAtEpochMs: Value(
        normalized.lastInteractionAt?.millisecondsSinceEpoch,
      ),
      sortEpochMs: Value(sortEpochMs),
    );
  }

  AegisPeopleCallHistoryCompanion _callHistoryCompanionFromEntry(
    CallHistoryEntry entry,
  ) {
    final normalized = entry.copyWith(person: entry.person.copyWith(clearPhotoBytes: true));
    final payload = normalized.toJson();
    return AegisPeopleCallHistoryCompanion.insert(
      id: normalized.id,
      personId: normalized.person.id,
      payloadJson: jsonEncode(payload),
      startedAtEpochMs: normalized.startedAt.millisecondsSinceEpoch,
      durationMs: Value(normalized.duration.inMilliseconds),
      isVideo: Value(normalized.isVideo),
      direction: payload['direction']!.toString(),
      outcome: payload['outcome']!.toString(),
    );
  }

  List<CallHistoryEntry> _decodeCallHistoryList(dynamic value) {
    final values = value as List<dynamic>? ?? const <dynamic>[];
    return values
        .map((item) => CallHistoryEntry.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ))
        .toList();
  }

  List<PersonEntry> _decodePeopleList(dynamic value) {
    final items = value as List<dynamic>? ?? const <dynamic>[];
    return items
        .map((item) => PersonEntry.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ))
        .toList();
  }
}
