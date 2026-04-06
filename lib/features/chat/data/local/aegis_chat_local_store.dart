import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:drift/drift.dart' hide Column;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:two_space_app/features/chat/data/local/aegis_chat_database.dart';

class AegisChatStorageBootstrap {
  const AegisChatStorageBootstrap({
    required this.conversations,
    required this.profiles,
    required this.storedRoomIds,
  });

  final List<Map<String, dynamic>> conversations;
  final Map<int, Map<String, dynamic>> profiles;
  final Set<String> storedRoomIds;
}

class AegisChatLocalStore {
  AegisChatLocalStore({AegisChatDatabase? database})
      : _database = database ?? AegisChatDatabase();

  static const String _migrationMetadataKey = 'legacy_json_import_completed';

  final AegisChatDatabase _database;

  bool _initialized = false;
  late File _legacyStoreFile;
  late Directory _legacyStoreDir;
  late Directory _legacyMessagesDir;
  late File _legacyConversationsFile;
  late File _legacyProfilesFile;

  Future<AegisChatStorageBootstrap> initialize() async {
    if (_initialized) {
      return _loadBootstrap();
    }

    await _prepareLegacyPaths();
    await _migrateLegacyStoreIfNeeded();
    _initialized = true;
    return _loadBootstrap();
  }

  Future<List<Map<String, dynamic>>> loadRoomMessagesJson(
    String roomId, {
    int? limit,
  }) async {
    final query = _database.select(_database.aegisMessages)
      ..where((table) => table.roomId.equals(roomId))
      ..orderBy([
        (table) => OrderingTerm.desc(table.sentAtEpochMs),
      ]);
    if (limit != null) {
      query.limit(limit);
    }
    final rows = await query.get();
    // Reverse to chronological order (we fetched newest-first for LIMIT).
    final ordered = rows.reversed;

    return ordered
        .map(
          (row) => <String, dynamic>{
            'id': row.id,
            'senderId': row.senderId,
            'content': row.content,
            'time': DateTime.fromMillisecondsSinceEpoch(
              row.sentAtEpochMs,
              isUtc: true,
            )
                .toIso8601String(),
            'type': row.type,
            'mediaId': row.mediaId,
            if (row.replyToMessageId != null)
              'replyToMessageId': row.replyToMessageId,
            'isDelivered': row.isDelivered,
            'isRead': row.isRead,
            if (row.deliveredAtEpochMs != null)
              'deliveredAt': DateTime.fromMillisecondsSinceEpoch(
                row.deliveredAtEpochMs!,
                isUtc: true,
              ).toIso8601String(),
            if (row.readAtEpochMs != null)
              'readAt': DateTime.fromMillisecondsSinceEpoch(
                row.readAtEpochMs!,
                isUtc: true,
              ).toIso8601String(),
          },
        )
        .toList(growable: false);
  }

  Future<void> saveChanges({
    required Iterable<Map<String, dynamic>> conversationsJson,
    required Map<int, Map<String, dynamic>> profilesJsonByUserId,
    required Map<String, List<Map<String, dynamic>>> upsertMessagesJsonByRoomId,
    required Map<String, Set<String>> deletedMessageIdsByRoomId,
    required Set<String> deletedRoomIds,
    required bool writeConversations,
    required bool writeProfiles,
  }) async {
    await _database.transaction(() async {
      if (deletedRoomIds.isNotEmpty) {
        await (_database.delete(_database.aegisMessages)
              ..where((table) => table.roomId.isIn(deletedRoomIds)))
            .go();
        await (_database.delete(_database.aegisConversations)
              ..where((table) => table.id.isIn(deletedRoomIds)))
            .go();
      }

      for (final entry in deletedMessageIdsByRoomId.entries) {
        if (deletedRoomIds.contains(entry.key) || entry.value.isEmpty) {
          continue;
        }
        await (_database.delete(_database.aegisMessages)
              ..where((table) => table.id.isIn(entry.value)))
            .go();
      }

      for (final entry in upsertMessagesJsonByRoomId.entries) {
        if (deletedRoomIds.contains(entry.key) || entry.value.isEmpty) {
          continue;
        }
        await _database.batch((batch) {
          batch.insertAllOnConflictUpdate(
            _database.aegisMessages,
            entry.value
                .map((message) => _messageCompanionFromJson(entry.key, message))
                .toList(growable: false),
          );
        });
      }

      if (writeConversations) {
        await _database.batch((batch) {
          batch.insertAllOnConflictUpdate(
            _database.aegisConversations,
            conversationsJson
                .map(_conversationCompanionFromJson)
                .toList(growable: false),
          );
        });
      }

      if (writeProfiles) {
        await _database.batch((batch) {
          batch.insertAllOnConflictUpdate(
            _database.aegisProfiles,
            profilesJsonByUserId.entries
                .map(
                  (entry) => _profileCompanionFromJson(entry.key, entry.value),
                )
                .toList(growable: false),
          );
        });
      }
    });
  }

  Future<void> close() => _database.close();

  Future<void> _prepareLegacyPaths() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    _legacyStoreFile = File(p.join(documentsDir.path, 'aegis_chat_store.json'));
    _legacyStoreDir = Directory(p.join(documentsDir.path, 'aegis_chat_store'));
    _legacyMessagesDir = Directory(p.join(_legacyStoreDir.path, 'messages'));
    _legacyConversationsFile =
        File(p.join(_legacyStoreDir.path, 'conversations.json'));
    _legacyProfilesFile = File(p.join(_legacyStoreDir.path, 'profiles.json'));
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

    final dump = await _loadLegacyDump();
    if (dump == null) {
      await _writeMetadata(_migrationMetadataKey, 'true');
      return;
    }

    await _replaceAllWithDump(dump);
    await _writeMetadata(_migrationMetadataKey, 'true');
  }

  Future<bool> _hasAnyRows() async {
    final hasConversation = await (_database.select(_database.aegisConversations)
          ..limit(1))
        .getSingleOrNull();
    if (hasConversation != null) return true;

    final hasMessage = await (_database.select(_database.aegisMessages)
          ..limit(1))
        .getSingleOrNull();
    if (hasMessage != null) return true;

    final hasProfile = await (_database.select(_database.aegisProfiles)
          ..limit(1))
        .getSingleOrNull();
    return hasProfile != null;
  }

  Future<String?> _readMetadata(String key) async {
    final row = await (_database.select(_database.aegisMetadata)
          ..where((table) => table.key.equals(key))
          ..limit(1))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> _writeMetadata(String key, String value) {
    return _database
        .into(_database.aegisMetadata)
        .insertOnConflictUpdate(
          AegisMetadataCompanion.insert(
            key: key,
            value: value,
          ),
        );
  }

  Future<AegisChatStorageBootstrap> _loadBootstrap() async {
    final conversationRows = await (_database.select(_database.aegisConversations)
          ..orderBy([
            (table) => OrderingTerm.desc(table.updatedAtEpochMs),
          ]))
        .get();
    final profileRows = await _database.select(_database.aegisProfiles).get();
    final storedRoomRows = await _database.customSelect(
      'SELECT DISTINCT room_id FROM aegis_messages',
    ).get();

    final conversations = conversationRows
        .map(_conversationJsonFromRow)
        .toList(growable: false);
    final profiles = <int, Map<String, dynamic>>{};
    for (final row in profileRows) {
      final payload = jsonDecode(row.payloadJson);
      if (payload is Map<String, dynamic>) {
        profiles[row.userId] = Map<String, dynamic>.from(payload);
      }
    }

    return AegisChatStorageBootstrap(
      conversations: conversations,
      profiles: profiles,
      storedRoomIds: storedRoomRows
          .map((row) => row.read<String>('room_id'))
          .toSet(),
    );
  }

  Future<void> _replaceAllWithDump(_LegacyChatStoreDump dump) async {
    await _database.transaction(() async {
      await _database.delete(_database.aegisMessages).go();
      await _database.delete(_database.aegisConversations).go();
      await _database.delete(_database.aegisProfiles).go();

      if (dump.conversations.isNotEmpty) {
        await _database.batch((batch) {
          batch.insertAll(
            _database.aegisConversations,
            dump.conversations
                .map(_conversationCompanionFromJson)
                .toList(growable: false),
          );
        });
      }

      if (dump.profiles.isNotEmpty) {
        await _database.batch((batch) {
          batch.insertAll(
            _database.aegisProfiles,
            dump.profiles.entries
                .map(
                  (entry) => _profileCompanionFromJson(entry.key, entry.value),
                )
                .toList(growable: false),
          );
        });
      }

      for (final entry in dump.messagesByRoom.entries) {
        if (entry.value.isEmpty) {
          continue;
        }
        await _database.batch((batch) {
          batch.insertAll(
            _database.aegisMessages,
            entry.value
                .map((message) => _messageCompanionFromJson(entry.key, message))
                .toList(growable: false),
          );
        });
      }
    });
  }

  Future<_LegacyChatStoreDump?> _loadLegacyDump() async {
    if (await _legacyStoreFile.exists()) {
      return _readLegacySingleFileStore();
    }

    final hasSplitStore = await _legacyConversationsFile.exists() ||
        await _legacyProfilesFile.exists() ||
        await _legacyMessagesDir.exists();
    if (!hasSplitStore) {
      return null;
    }
    return _readLegacySplitStore();
  }

  Future<_LegacyChatStoreDump?> _readLegacySingleFileStore() async {
    final raw = await _legacyStoreFile.readAsString();
    if (raw.trim().isEmpty) {
      return null;
    }

    final decoded = await Isolate.run<Map<String, dynamic>>(
      () => Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
    final conversations = (decoded['conversations'] as List<dynamic>? ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
    final profilesRaw = decoded['profiles'] as Map<String, dynamic>? ?? {};
    final profiles = <int, Map<String, dynamic>>{};
    for (final entry in profilesRaw.entries) {
      final userId = int.tryParse(entry.key);
      if (userId == null || entry.value is! Map) {
        continue;
      }
      profiles[userId] = Map<String, dynamic>.from(entry.value as Map);
    }

    final messagesRaw = decoded['messages'] as Map<String, dynamic>? ?? {};
    final messagesByRoom = <String, List<Map<String, dynamic>>>{};
    for (final entry in messagesRaw.entries) {
      final list = entry.value as List<dynamic>? ?? const <dynamic>[];
      messagesByRoom[entry.key] = list
          .map((message) => Map<String, dynamic>.from(message as Map))
          .toList(growable: false);
    }

    return _LegacyChatStoreDump(
      conversations: conversations,
      profiles: profiles,
      messagesByRoom: messagesByRoom,
    );
  }

  Future<_LegacyChatStoreDump?> _readLegacySplitStore() async {
    final conversations = await _readLegacyConversations();
    final profiles = await _readLegacyProfiles();
    final messagesByRoom = await _readLegacyMessages();

    if (conversations.isEmpty && profiles.isEmpty && messagesByRoom.isEmpty) {
      return null;
    }

    return _LegacyChatStoreDump(
      conversations: conversations,
      profiles: profiles,
      messagesByRoom: messagesByRoom,
    );
  }

  Future<List<Map<String, dynamic>>> _readLegacyConversations() async {
    if (!await _legacyConversationsFile.exists()) {
      return const <Map<String, dynamic>>[];
    }
    final raw = await _legacyConversationsFile.readAsString();
    if (raw.trim().isEmpty) {
      return const <Map<String, dynamic>>[];
    }
    final decoded = await Isolate.run<List<dynamic>>(
      () => List<dynamic>.from(jsonDecode(raw) as List),
    );
    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(growable: false);
  }

  Future<Map<int, Map<String, dynamic>>> _readLegacyProfiles() async {
    if (!await _legacyProfilesFile.exists()) {
      return const <int, Map<String, dynamic>>{};
    }
    final raw = await _legacyProfilesFile.readAsString();
    if (raw.trim().isEmpty) {
      return const <int, Map<String, dynamic>>{};
    }
    final decoded = await Isolate.run<Map<String, dynamic>>(
      () => Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
    final profiles = <int, Map<String, dynamic>>{};
    for (final entry in decoded.entries) {
      final userId = int.tryParse(entry.key);
      if (userId == null || entry.value is! Map) {
        continue;
      }
      profiles[userId] = Map<String, dynamic>.from(entry.value as Map);
    }
    return profiles;
  }

  Future<Map<String, List<Map<String, dynamic>>>> _readLegacyMessages() async {
    if (!await _legacyMessagesDir.exists()) {
      return const <String, List<Map<String, dynamic>>>{};
    }
    final files = await _legacyMessagesDir
        .list()
        .where((entity) => entity is File)
        .cast<File>()
        .toList();
    final messagesByRoom = <String, List<Map<String, dynamic>>>{};
    for (final file in files) {
      try {
        final roomId = _roomIdFromFileName(p.basenameWithoutExtension(file.path));
        final raw = await file.readAsString();
        if (raw.trim().isEmpty) {
          messagesByRoom[roomId] = const <Map<String, dynamic>>[];
          continue;
        }
        final decoded = await Isolate.run<List<dynamic>>(
          () => List<dynamic>.from(jsonDecode(raw) as List),
        );
        messagesByRoom[roomId] = decoded
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList(growable: false);
      } catch (_) {}
    }
    return messagesByRoom;
  }

  String _roomIdFromFileName(String fileName) =>
      utf8.decode(base64Url.decode(fileName));

  AegisConversationsCompanion _conversationCompanionFromJson(
    Map<String, dynamic> json,
  ) {
    final members = (json['memberUserIds'] as List<dynamic>? ?? const <dynamic>[])
        .map((value) => value.toString())
        .toList(growable: false);
    final updatedAt = DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);

    return AegisConversationsCompanion.insert(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      kind: json['kind'] as String? ?? 'direct',
      updatedAtEpochMs: updatedAt.millisecondsSinceEpoch,
      lastMessage: Value(json['lastMessage'] as String?),
      unreadCount: Value(json['unreadCount'] as int? ?? 0),
      avatarUrl: Value(json['avatarUrl'] as String?),
      description: Value(json['description'] as String?),
      peerUserId: Value(json['peerUserId'] as int?),
      peerUsername: Value(json['peerUsername'] as String?),
      channelId: Value(json['channelId'] as int?),
      isPublic: Value(json['isPublic'] as bool? ?? false),
      showMessageHistory: Value(json['showMessageHistory'] as bool? ?? false),
      memberUserIdsJson: Value(jsonEncode(members)),
    );
  }

  Map<String, dynamic> _conversationJsonFromRow(AegisConversation row) {
    final membersDecoded = jsonDecode(row.memberUserIdsJson);
    final members = membersDecoded is List<dynamic>
        ? membersDecoded.map((value) => value.toString()).toList(growable: false)
        : const <String>[];

    return <String, dynamic>{
      'id': row.id,
      'title': row.title,
      'kind': row.kind,
      'updatedAt':
          DateTime.fromMillisecondsSinceEpoch(row.updatedAtEpochMs).toIso8601String(),
      'lastMessage': row.lastMessage,
      'unreadCount': row.unreadCount,
      'avatarUrl': row.avatarUrl,
      'description': row.description,
      'peerUserId': row.peerUserId,
      'peerUsername': row.peerUsername,
      'channelId': row.channelId,
      'isPublic': row.isPublic,
      'showMessageHistory': row.showMessageHistory,
      'memberUserIds': members,
    };
  }

  AegisMessagesCompanion _messageCompanionFromJson(
    String roomId,
    Map<String, dynamic> json,
  ) {
    final time = DateTime.tryParse(json['time'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final deliveredAt = json['deliveredAt'] is String
        ? DateTime.tryParse(json['deliveredAt'] as String)
        : null;
    final readAt = json['readAt'] is String
        ? DateTime.tryParse(json['readAt'] as String)
        : null;
    return AegisMessagesCompanion.insert(
      id: json['id'] as String,
      roomId: roomId,
      senderId: json['senderId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      sentAtEpochMs: time.millisecondsSinceEpoch,
      type: Value(json['type'] as String? ?? 'm.text'),
      mediaId: Value(json['mediaId'] as String?),
      replyToMessageId: Value((json['replyToMessageId'] as num?)?.toInt()),
      isDelivered: Value(json['isDelivered'] as bool? ?? false),
      isRead: Value(json['isRead'] as bool? ?? false),
      deliveredAtEpochMs: Value(deliveredAt?.millisecondsSinceEpoch),
      readAtEpochMs: Value(readAt?.millisecondsSinceEpoch),
    );
  }

  AegisProfilesCompanion _profileCompanionFromJson(
    int userId,
    Map<String, dynamic> json,
  ) {
    final lastSeenAt = json['lastSeenAt'] is String
        ? DateTime.tryParse(json['lastSeenAt'] as String)
        : null;
    return AegisProfilesCompanion(
      userId: Value(userId),
      payloadJson: Value(jsonEncode(json)),
      username: Value(json['username'] as String?),
      displayName: Value(json['displayName'] as String?),
      avatarUrl: Value(json['avatarUrl'] as String?),
      presenceStatus: Value(json['presenceStatus'] as String?),
      isOnline: Value(json['isOnline'] as bool? ?? false),
      lastSeenAtEpochMs: Value(lastSeenAt?.millisecondsSinceEpoch),
    );
  }
}

class _LegacyChatStoreDump {
  const _LegacyChatStoreDump({
    required this.conversations,
    required this.profiles,
    required this.messagesByRoom,
  });

  final List<Map<String, dynamic>> conversations;
  final Map<int, Map<String, dynamic>> profiles;
  final Map<String, List<Map<String, dynamic>>> messagesByRoom;
}
