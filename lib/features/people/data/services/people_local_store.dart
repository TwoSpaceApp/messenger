import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:two_space_app/features/people/data/models/call_history_entry.dart';
import 'package:two_space_app/features/people/data/models/person_entry.dart';

class PeopleLocalStore {
  PeopleLocalStore._();

  static final PeopleLocalStore instance = PeopleLocalStore._();

  static const _favoritesKey = 'favorites';
  static const _cachedPeopleKey = 'cached_people';
  static const _recentPeopleKey = 'recent_people';
  static const _callHistoryKey = 'call_history';
  static const _schemaVersionKey = 'schema_version';

  Future<List<String>> readFavorites() async {
    final data = await _readData();
    return (data[_favoritesKey] as List<dynamic>? ?? const <dynamic>[])
        .map((value) => value.toString())
        .toList();
  }

  Future<void> writeFavorites(List<String> ids) async {
    final data = await _readData();
    data[_favoritesKey] = ids.toSet().toList();
    await _writeData(data);
  }

  Future<List<PersonEntry>> readCachedPeople() async {
    final data = await _readData();
    return _decodePeopleList(data[_cachedPeopleKey]);
  }

  Future<void> upsertCachedPeople(List<PersonEntry> people) async {
    final data = await _readData();
    final merged = <String, PersonEntry>{
      for (final person in _decodePeopleList(data[_cachedPeopleKey]))
        person.id: person,
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

    data[_cachedPeopleKey] =
        ordered.take(120).map((person) => person.toJson()).toList();
    await _writeData(data);
  }

  Future<List<PersonEntry>> readRecentPeople() async {
    final data = await _readData();
    return _decodePeopleList(data[_recentPeopleKey]);
  }

  Future<void> putRecentPerson(PersonEntry person) async {
    final data = await _readData();
    final current = <String, PersonEntry>{
      for (final item in _decodePeopleList(data[_recentPeopleKey])) item.id: item,
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

    data[_recentPeopleKey] =
        ordered.take(40).map((entry) => entry.toJson()).toList();
    await _writeData(data);
  }

  Future<List<CallHistoryEntry>> readCallHistory() async {
    final data = await _readData();
    final values = data[_callHistoryKey] as List<dynamic>? ?? const <dynamic>[];
    return values
        .map((item) => CallHistoryEntry.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ))
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  Future<void> appendCallHistory(CallHistoryEntry entry) async {
    final data = await _readData();
    final items = await readCallHistory();
    items.insert(0, entry.copyWith(person: entry.person.copyWith(clearPhotoBytes: true)));
    data[_callHistoryKey] =
        items.take(200).map((item) => item.toJson()).toList();
    await _writeData(data);
  }

  Future<void> deleteCallHistory(String id) async {
    final data = await _readData();
    final items = await readCallHistory();
    data[_callHistoryKey] =
        items.where((item) => item.id != id).map((item) => item.toJson()).toList();
    await _writeData(data);
  }

  Future<File> _resolveFile() async {
    final directory = await getApplicationSupportDirectory();
    final file = File('${directory.path}/people_store.json');
    if (!await file.exists()) {
      await file.writeAsString(
        jsonEncode(<String, dynamic>{
          _schemaVersionKey: 1,
          _favoritesKey: <String>[],
          _cachedPeopleKey: <Map<String, dynamic>>[],
          _recentPeopleKey: <Map<String, dynamic>>[],
          _callHistoryKey: <Map<String, dynamic>>[],
        }),
      );
    }
    return file;
  }

  Future<Map<String, dynamic>> _readData() async {
    try {
      final file = await _resolveFile();
      final content = await file.readAsString();
      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<void> _writeData(Map<String, dynamic> data) async {
    final file = await _resolveFile();
    final normalized = <String, dynamic>{
      _schemaVersionKey: 1,
      _favoritesKey: data[_favoritesKey] ?? <String>[],
      _cachedPeopleKey: data[_cachedPeopleKey] ?? <Map<String, dynamic>>[],
      _recentPeopleKey: data[_recentPeopleKey] ?? <Map<String, dynamic>>[],
      _callHistoryKey: data[_callHistoryKey] ?? <Map<String, dynamic>>[],
    };
    await file.writeAsString(jsonEncode(normalized));
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
