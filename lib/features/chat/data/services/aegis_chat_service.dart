import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/models/group.dart';
import 'package:two_space_app/core/network/aegis/aegis_client.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';
import 'package:two_space_app/features/auth/data/services/aegis_auth_service.dart';

class AegisRoomMessage {
  AegisRoomMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.time,
    this.type = 'm.text',
    this.mediaId,
  });

  factory AegisRoomMessage.fromJson(Map<String, dynamic> json) {
    return AegisRoomMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String? ?? '',
      time: DateTime.tryParse(json['time'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      type: json['type'] as String? ?? 'm.text',
      mediaId: json['mediaId'] as String?,
    );
  }

  final String id;
  final String senderId;
  final String content;
  final DateTime time;
  final String type;
  final String? mediaId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'content': content,
        'time': time.toIso8601String(),
        'type': type,
        if (mediaId != null) 'mediaId': mediaId,
      };
}

class _StoredConversation {
  _StoredConversation({
    required this.id,
    required this.title,
    required this.kind,
    required this.updatedAt,
    this.avatarUrl,
    this.description,
    this.peerUserId,
    this.peerUsername,
    this.channelId,
    this.isPublic = false,
    this.showMessageHistory = false,
    this.memberUserIds = const <String>[],
  });

  factory _StoredConversation.fromJson(Map<String, dynamic> json) {
    return _StoredConversation(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      kind: json['kind'] as String? ?? 'direct',
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      avatarUrl: json['avatarUrl'] as String?,
      description: json['description'] as String?,
      peerUserId: json['peerUserId'] as int?,
      peerUsername: json['peerUsername'] as String?,
      channelId: json['channelId'] as int?,
      isPublic: json['isPublic'] as bool? ?? false,
      showMessageHistory: json['showMessageHistory'] as bool? ?? false,
      memberUserIds: (json['memberUserIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
    );
  }

  final String id;
  final String title;
  final String kind;
  final DateTime updatedAt;
  final String? avatarUrl;
  final String? description;
  final int? peerUserId;
  final String? peerUsername;
  final int? channelId;
  final bool isPublic;
  final bool showMessageHistory;
  final List<String> memberUserIds;

  _StoredConversation copyWith({
    String? title,
    DateTime? updatedAt,
    String? avatarUrl,
    String? description,
    bool? isPublic,
    bool? showMessageHistory,
    List<String>? memberUserIds,
  }) {
    return _StoredConversation(
      id: id,
      title: title ?? this.title,
      kind: kind,
      updatedAt: updatedAt ?? this.updatedAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      description: description ?? this.description,
      peerUserId: peerUserId,
      peerUsername: peerUsername,
      channelId: channelId,
      isPublic: isPublic ?? this.isPublic,
      showMessageHistory: showMessageHistory ?? this.showMessageHistory,
      memberUserIds: memberUserIds ?? this.memberUserIds,
    );
  }

  Chat toChat(String lastMessage) {
    return Chat(
      id: id,
      name: title,
      members: memberUserIds,
      avatarUrl: avatarUrl,
      lastMessage: lastMessage,
      roomType: kind,
      lastMessageTime: updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'kind': kind,
        'updatedAt': updatedAt.toIso8601String(),
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (description != null) 'description': description,
        if (peerUserId != null) 'peerUserId': peerUserId,
        if (peerUsername != null) 'peerUsername': peerUsername,
        if (channelId != null) 'channelId': channelId,
        'isPublic': isPublic,
        'showMessageHistory': showMessageHistory,
        'memberUserIds': memberUserIds,
      };
}

class AegisChatService {
  factory AegisChatService() => _instance;
  AegisChatService._internal();

  static final AegisChatService _instance = AegisChatService._internal();

  final AegisAuthService _auth = AegisAuthService();
  final StreamController<void> _changes = StreamController<void>.broadcast();

  bool _initialized = false;
  bool _attached = false;
  StreamSubscription<Message>? _incomingSub;
  late File _storeFile;

  final Map<String, _StoredConversation> _conversations = {};
  final Map<String, List<AegisRoomMessage>> _messages = {};
  final Map<int, Map<String, dynamic>> _profileCache = {};

  String get homeserver => 'aegis://${_auth.username ?? 'server'}';

  Future<void> _init() async {
    if (_initialized) return;
    final dir = await getApplicationDocumentsDirectory();
    _storeFile = File(p.join(dir.path, 'aegis_chat_store.json'));
    if (await _storeFile.exists()) {
      final raw = await _storeFile.readAsString();
      if (raw.trim().isNotEmpty) {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        final conversations = json['conversations'] as List<dynamic>? ?? [];
        final messages = json['messages'] as Map<String, dynamic>? ?? {};
        final profiles = json['profiles'] as Map<String, dynamic>? ?? {};

        for (final item in conversations) {
          final conversation =
              _StoredConversation.fromJson(item as Map<String, dynamic>);
          _conversations[conversation.id] = conversation;
        }
        for (final entry in messages.entries) {
          _messages[entry.key] = (entry.value as List<dynamic>)
              .map((e) => AegisRoomMessage.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        for (final entry in profiles.entries) {
          final id = int.tryParse(entry.key);
          if (id != null && entry.value is Map<String, dynamic>) {
            _profileCache[id] = Map<String, dynamic>.from(
              entry.value as Map<String, dynamic>,
            );
          }
        }
      }
    }
    _initialized = true;
  }

  Future<void> ensureReady() async {
    await _init();
    if (!_auth.isAuthenticated) {
      final restored = await _auth.restoreSession();
      if (!restored) {
        throw Exception('Not authenticated');
      }
    }
    if (!_attached) {
      _attached = true;
      _incomingSub = _auth.rawClient.messages.listen(_handleIncomingMessage);
    }
  }

  Future<void> dispose() async {
    await _incomingSub?.cancel();
    _attached = false;
  }

  Stream<List<Chat>> watchChats() async* {
    await _init();
    yield await getChats();
    await for (final _ in _changes.stream) {
      yield await getChats();
    }
  }

  Stream<List<AegisRoomMessage>> watchRoomMessages(String roomId) async* {
    await _init();
    yield await loadMessages(roomId: roomId);
    await for (final _ in _changes.stream) {
      yield await loadMessages(roomId: roomId);
    }
  }

  Future<List<Chat>> getChats() async {
    await _init();
    final items = _conversations.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items
        .map((conversation) => conversation.toChat(_lastMessage(conversation.id)))
        .toList();
  }

  Future<List<String>> getJoinedRooms() async {
    final chats = await getChats();
    return chats.map((e) => e.id).toList();
  }

  Future<Map<String, String?>> getRoomNameAndAvatar(String roomId) async {
    await _init();
    final room = _conversations[roomId];
    return {
      'name': room?.title ?? roomId,
      'avatar': room?.avatarUrl,
    };
  }

  Future<List<AegisRoomMessage>> loadMessages({
    required String roomId,
    int limit = 100,
  }) async {
    await _init();
    final messages = List<AegisRoomMessage>.from(_messages[roomId] ?? const []);
    messages.sort((a, b) => a.time.compareTo(b.time));
    if (messages.length <= limit) {
      return messages;
    }
    return messages.sublist(messages.length - limit);
  }

  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    await ensureReady();
    final parsedId = int.tryParse(userId.replaceFirst('@', '').split(':').first);
    if (parsedId != null && _profileCache.containsKey(parsedId)) {
      return _profileCache[parsedId]!;
    }

    ProfileGetResponsePayload response;
    if (parsedId != null) {
      response = await _auth.rawClient.getProfile(userId: parsedId);
    } else {
      final normalized = userId.replaceFirst('@', '').split(':').first;
      response = await _auth.rawClient.getProfile(username: normalized);
    }

    final profile = response.profile;
    if (profile == null) {
      return {
        'displayName': userId,
        'avatarUrl': null,
      };
    }

    final info = <String, dynamic>{
      'id': profile.id.toString(),
      'username': profile.username,
      'displayName': profile.displayName ?? profile.username,
      'avatarUrl': profile.avatarUrl,
      'bio': profile.bio,
      'email': profile.email,
      'lastSeenAt': profile.lastSeenAt?.toIso8601String(),
    };
    _profileCache[profile.id] = info;
    await _persist();
    return info;
  }

  Future<String?> getCurrentUserId() async {
    await ensureReady();
    final userId = _auth.userId;
    if (userId == null) return _auth.username;
    return userId.toString();
  }

  Future<String> createDirectChat(String userId) async {
    final target = await _resolveUser(userId);
    final roomId = 'dm:${target.id}';
    final conversation = _StoredConversation(
      id: roomId,
      title: target.username,
      kind: 'direct',
      updatedAt: DateTime.now(),
      peerUserId: target.id,
      peerUsername: target.username,
      memberUserIds: <String>[
        if (_auth.userId != null) _auth.userId.toString(),
        target.id.toString(),
      ],
    );
    _conversations[roomId] = conversation;
    await _persist();
    _emitChanged();
    return roomId;
  }

  Future<String> createRoom({
    required String name,
    String? topic,
    bool isPublic = false,
  }) async {
    await ensureReady();
    final response = await _auth.rawClient.createChannel(
      name,
      description: topic,
      type: isPublic ? ChannelType.public : ChannelType.private,
    );
    final channelId = response.channelId ?? response.channel?.id;
    if (!response.success || channelId == null) {
      throw Exception(response.message ?? 'Unable to create room');
    }
    final roomId = 'channel:$channelId';
    _conversations[roomId] = _StoredConversation(
      id: roomId,
      title: name,
      kind: isPublic ? 'public' : 'private',
      updatedAt: DateTime.now(),
      description: topic,
      channelId: channelId,
      isPublic: isPublic,
      memberUserIds: <String>[
        if (_auth.userId != null) _auth.userId.toString(),
      ],
    );
    await _persist();
    _emitChanged();
    return roomId;
  }

  Future<String?> sendMessage({
    required String roomId,
    required String text,
    String type = 'm.text',
    String? mediaFileId,
  }) async {
    await ensureReady();
    final conversation = _conversations[roomId];
    if (conversation == null) {
      throw Exception('Unknown conversation');
    }

    int? messageId;
    if (conversation.kind == 'direct') {
      final peerId = conversation.peerUserId;
      if (peerId == null) throw Exception('Missing peer user id');
      final response = await _auth.rawClient.sendPrivateMessage(
        peerId,
        mediaFileId ?? text,
      );
      messageId = response.messageId ?? response.message?.id;
      if (!response.success) {
        throw Exception(response.messageText ?? 'Unable to send message');
      }
    } else {
      final channelId = conversation.channelId;
      if (channelId == null) throw Exception('Missing channel id');
      final response = await _auth.rawClient.sendChannelMessage(
        channelId,
        mediaFileId ?? text,
      );
      messageId = response.messageId ?? response.message?.id;
      if (!response.success) {
        throw Exception(response.messageText ?? 'Unable to send message');
      }
    }

    final message = AegisRoomMessage(
      id: (messageId ?? DateTime.now().microsecondsSinceEpoch).toString(),
      senderId: (_auth.userId ?? 0).toString(),
      content: text,
      time: DateTime.now(),
      type: type,
      mediaId: mediaFileId,
    );
    await _appendMessage(roomId, message);
    return message.id;
  }

  Future<void> sendReply(
    String roomId,
    String replyToId, {
    required String body,
    String? formattedBody,
  }) async {
    await sendMessage(roomId: roomId, text: body);
  }

  Future<void> editMessage(String roomId, String eventId, String text,
      {String? formattedBody}) async {
    await _init();
    final list = _messages[roomId];
    if (list == null) return;
    final index = list.indexWhere((element) => element.id == eventId);
    if (index == -1) return;
    final previous = list[index];
    list[index] = AegisRoomMessage(
      id: previous.id,
      senderId: previous.senderId,
      content: text,
      time: previous.time,
      type: previous.type,
      mediaId: previous.mediaId,
    );
    await _persist();
    _emitChanged();
  }

  Future<void> redactEvent(String roomId, String eventId) async {
    await _init();
    _messages[roomId]?.removeWhere((element) => element.id == eventId);
    await _persist();
    _emitChanged();
  }

  Future<void> sendReaction({
    required String roomId,
    required String eventId,
    required String reaction,
  }) async {}

  Future<Map<String, dynamic>> getReactions(String roomId, String eventId) async {
    return const <String, dynamic>{};
  }

  Future<List<String>> getPinnedEvents(String roomId) async => const <String>[];

  Future<void> setPinnedEvents(String roomId, List<String> eventIds) async {}

  Future<void> leaveRoom(String roomId) async {
    await _init();
    _conversations.remove(roomId);
    _messages.remove(roomId);
    await _persist();
    _emitChanged();
  }

  Future<void> setRoomName(String roomId, String name) async {
    await ensureReady();
    final conversation = _conversations[roomId];
    if (conversation == null) return;
    if (conversation.channelId != null) {
      final response = await _auth.rawClient.editChannel(
        channelId: conversation.channelId!,
        name: name,
      );
      if (!response.success) {
        throw Exception(response.message ?? 'Unable to rename room');
      }
    }
    _conversations[roomId] = conversation.copyWith(
      title: name,
      updatedAt: DateTime.now(),
    );
    await _persist();
    _emitChanged();
  }

  Future<String> setRoomAvatar(String roomId, dynamic bytes,
      {String? fileName}) async {
    await _init();
    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(dir.path, 'aegis_media'));
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    final target = File(
      p.join(
        mediaDir.path,
        fileName ?? 'avatar_${DateTime.now().microsecondsSinceEpoch}.bin',
      ),
    );
    await target.writeAsBytes((bytes as List<int>).toList());
    final conversation = _conversations[roomId];
    if (conversation != null) {
      _conversations[roomId] = conversation.copyWith(
        avatarUrl: target.path,
        updatedAt: DateTime.now(),
      );
      await _persist();
      _emitChanged();
    }
    return target.path;
  }

  Future<String?> uploadMedia(
    List<int> bytes,
    String contentType,
    String fileName,
  ) async {
    await _init();
    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(p.join(dir.path, 'aegis_media'));
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    final target = File(
      p.join(mediaDir.path, '${DateTime.now().microsecondsSinceEpoch}_$fileName'),
    );
    await target.writeAsBytes(bytes);
    return target.path;
  }

  Future<String> downloadMediaToTempFile(String mediaId) async {
    final file = File(mediaId);
    if (await file.exists()) {
      return file.path;
    }
    throw Exception('File not found');
  }

  void startSync([Function(Map<String, dynamic>)? onEvent]) {
    if (onEvent == null) return;
    watchChats().listen((_) {
      onEvent(<String, dynamic>{
        'rooms': {
          'join': {
            for (final roomId in _conversations.keys)
              roomId: {
                'timeline': {
                  'events': [
                    {'type': 'm.room.message'}
                  ]
                }
              }
          }
        }
      });
    });
  }

  void stopSync() {}

  Future<List<Map<String, dynamic>>> searchMessages({
    required String query,
    String type = 'all',
  }) async {
    await _init();
    final q = query.trim().toLowerCase();
    final results = <Map<String, dynamic>>[];
    for (final entry in _messages.entries) {
      for (final message in entry.value) {
        final body = message.content.toLowerCase();
        final media = message.mediaId?.toLowerCase() ?? '';
        final matches = switch (type) {
          'media' => media.isNotEmpty || message.type != 'm.text',
          'messages' => body.contains(q),
          'users' => message.senderId.contains(q),
          _ => body.contains(q) || message.senderId.contains(q),
        };
        if (!matches) continue;
        results.add({
          'roomId': entry.key,
          'sender': message.senderId,
          'content': {'body': message.content},
          'eventId': message.id,
        });
      }
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    await ensureReady();
    final response = await _auth.searchUsers(query);
    return response.users
        .map(
          (user) => <String, dynamic>{
            'id': user.id.toString(),
            'name': user.username,
            'nickname': user.username,
            'email': user.email,
            'prefs': const <String, dynamic>{},
          },
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> getRoomMembers(String roomId,
      {bool forceRefresh = false}) async {
    await _init();
    final room = _conversations[roomId];
    if (room == null) return const <Map<String, dynamic>>[];
    final members = <Map<String, dynamic>>[];
    for (final id in room.memberUserIds) {
      final info = await getUserInfo(id);
      members.add({
        'userId': id,
        'displayName': info['displayName'] ?? info['username'] ?? id,
        'avatarUrl': info['avatarUrl'],
      });
    }
    return members;
  }

  Future<void> setJoinRule(String roomId, String rule) async {
    await _init();
    final room = _conversations[roomId];
    if (room == null) return;
    _conversations[roomId] = room.copyWith(
      isPublic: rule == 'public',
      updatedAt: DateTime.now(),
    );
    await _persist();
    _emitChanged();
  }

  Future<void> clearRoomCache(String roomId) async {}

  Future<List<double>> getWaveformForMedia(String mediaId, String? localPath,
          {int samples = 50}) async =>
      const <double>[];

  Future<Chat> getOrCreateDirectChat(String otherUserId) async {
    final roomId = await createDirectChat(otherUserId);
    final conversation = _conversations[roomId]!;
    return conversation.toChat(_lastMessage(roomId));
  }

  Future<GroupRoom> createGroupRoom({
    required String name,
    required GroupVisibility visibility,
    required bool showMessageHistory,
    String? description,
  }) async {
    await ensureReady();
    final response = await _auth.rawClient.createChannel(
      name,
      description: description,
      type: ChannelType.group,
    );
    final channelId = response.channelId ?? response.channel?.id;
    if (!response.success || channelId == null) {
      throw Exception(response.message ?? 'Unable to create group');
    }
    final roomId = 'channel:$channelId';
    final me = (_auth.userId ?? 0).toString();
    _conversations[roomId] = _StoredConversation(
      id: roomId,
      title: name,
      kind: 'group',
      updatedAt: DateTime.now(),
      description: description,
      channelId: channelId,
      isPublic: visibility == GroupVisibility.public,
      showMessageHistory: showMessageHistory,
      memberUserIds: <String>[me],
    );
    await _persist();
    _emitChanged();
    return getGroupRoom(roomId) ??
        GroupRoom(
          roomId: roomId,
          name: name,
          description: description,
          currentUserRole: GroupRole.owner,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
  }

  GroupRoom? getGroupRoom(String roomId) {
    final room = _conversations[roomId];
    if (room == null) return null;
    return GroupRoom(
      roomId: room.id,
      name: room.title,
      description: room.description,
      visibility:
          room.isPublic ? GroupVisibility.public : GroupVisibility.private,
      currentUserRole: GroupRole.owner,
      memberCount: room.memberUserIds.length,
      showMessageHistory: room.showMessageHistory,
      createdAt: room.updatedAt,
      updatedAt: room.updatedAt,
      members: room.memberUserIds
          .map(
            (id) => GroupMember(
              userId: id,
              displayName: _profileCache[int.tryParse(id) ?? -1]?['displayName']
                      as String? ??
                  id,
              role: id == (_auth.userId ?? 0).toString()
                  ? GroupRole.owner
                  : GroupRole.member,
              joinedAt: room.updatedAt,
            ),
          )
          .toList(),
    );
  }

  Future<void> setShowMessageHistory(String roomId, bool value) async {
    await _init();
    final room = _conversations[roomId];
    if (room == null) return;
    _conversations[roomId] = room.copyWith(
      showMessageHistory: value,
      updatedAt: DateTime.now(),
    );
    await _persist();
    _emitChanged();
  }

  Future<void> setUserRole(String roomId, String userId, GroupRole role) async {}

  Future<void> freezeUser(
    String roomId,
    String userId,
    DateTime? until,
    String? reason,
  ) async {}

  Future<void> banUser(String roomId, String userId) async {}

  Future<void> unbanUser(String roomId, String userId) async {}

  Future<void> kickUser(String roomId, String userId) async {
    await _init();
    final room = _conversations[roomId];
    if (room == null) return;
    _conversations[roomId] = room.copyWith(
      memberUserIds: room.memberUserIds.where((e) => e != userId).toList(),
      updatedAt: DateTime.now(),
    );
    await _persist();
    _emitChanged();
  }

  Future<void> deleteGroup(String roomId) => leaveRoom(roomId);

  Future<void> updateMyProfile({
    String? displayName,
    String? bio,
    String? username,
    String? avatarUrl,
  }) async {
    await ensureReady();
    final response = await _auth.rawClient.updateProfile(
      displayName: displayName,
      bio: bio,
      username: username,
      avatarUrl: avatarUrl,
    );
    if (!response.success) {
      throw Exception(response.message ?? 'Unable to update profile');
    }
    if (response.profile != null) {
      _profileCache[response.profile!.id] = {
        'id': response.profile!.id.toString(),
        'username': response.profile!.username,
        'displayName': response.profile!.displayName,
        'avatarUrl': response.profile!.avatarUrl,
        'bio': response.profile!.bio,
        'email': response.profile!.email,
      };
      await _persist();
      _emitChanged();
    }
  }

  Future<_ResolvedUser> _resolveUser(String raw) async {
    await ensureReady();
    final normalized = raw.trim().replaceFirst('@', '').split(':').first;
    final asInt = int.tryParse(normalized);
    if (asInt != null) {
      final info = await getUserInfo(asInt.toString());
      return _ResolvedUser(
        id: asInt,
        username: info['username'] as String? ?? normalized,
      );
    }

    final search = await _auth.searchUsers(normalized);
    final exact = search.users.firstWhere(
      (user) => user.username.toLowerCase() == normalized.toLowerCase(),
      orElse: () => search.users.first,
    );
    return _ResolvedUser(id: exact.id, username: exact.username);
  }

  Future<void> _appendMessage(String roomId, AegisRoomMessage message) async {
    final list = _messages.putIfAbsent(roomId, () => <AegisRoomMessage>[]);
    list.removeWhere((element) => element.id == message.id);
    list.add(message);
    final room = _conversations[roomId];
    if (room != null) {
      _conversations[roomId] = room.copyWith(updatedAt: message.time);
    }
    await _persist();
    _emitChanged();
  }

  void _handleIncomingMessage(Message message) {
    if (message.type != MessageType.privateChatMessage &&
        message.type != MessageType.channelMessage) {
      return;
    }
    try {
      final payload = jsonDecode(utf8.decode(message.payload));
      if (payload is! Map<String, dynamic>) return;
      if (payload.containsKey('Success')) return;

      if (message.type == MessageType.privateChatMessage) {
        final fromUserId = payload['FromUserId'] as int?;
        final toUserId = payload['ToUserId'] as int?;
        final content = payload['Content'] as String?;
        if (fromUserId == null || toUserId == null || content == null) return;
        final me = _auth.userId;
        final peerId = fromUserId == me ? toUserId : fromUserId;
        final roomId = 'dm:$peerId';
        _conversations.putIfAbsent(
          roomId,
          () => _StoredConversation(
            id: roomId,
            title: payload['Username'] as String? ?? peerId.toString(),
            kind: 'direct',
            updatedAt: DateTime.now(),
            peerUserId: peerId,
            peerUsername: payload['Username'] as String?,
            memberUserIds: <String>[
              if (me != null) me.toString(),
              peerId.toString(),
            ],
          ),
        );
        unawaited(
          _appendMessage(
            roomId,
            AegisRoomMessage(
              id: (payload['Id'] ?? DateTime.now().microsecondsSinceEpoch)
                  .toString(),
              senderId: fromUserId.toString(),
              content: content,
              time: DateTime.tryParse(payload['CreatedAt'] as String? ?? '') ??
                  DateTime.now(),
            ),
          ),
        );
      }

      if (message.type == MessageType.channelMessage) {
        final channelId = payload['ChannelId'] as int?;
        final fromUserId = payload['FromUserId'] as int?;
        final content = payload['Content'] as String?;
        if (channelId == null || fromUserId == null || content == null) return;
        final roomId = 'channel:$channelId';
        _conversations.putIfAbsent(
          roomId,
          () => _StoredConversation(
            id: roomId,
            title: 'Channel $channelId',
            kind: 'group',
            updatedAt: DateTime.now(),
            channelId: channelId,
            memberUserIds: <String>[fromUserId.toString()],
          ),
        );
        unawaited(
          _appendMessage(
            roomId,
            AegisRoomMessage(
              id: (payload['Id'] ?? DateTime.now().microsecondsSinceEpoch)
                  .toString(),
              senderId: fromUserId.toString(),
              content: content,
              time: DateTime.tryParse(payload['CreatedAt'] as String? ?? '') ??
                  DateTime.now(),
            ),
          ),
        );
      }
    } catch (_) {}
  }

  String _lastMessage(String roomId) {
    final list = _messages[roomId];
    if (list == null || list.isEmpty) return '';
    return list.last.content;
  }

  Future<void> _persist() async {
    await _init();
    final data = <String, dynamic>{
      'conversations': _conversations.values.map((e) => e.toJson()).toList(),
      'messages': _messages.map(
        (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
      ),
      'profiles': _profileCache.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    };
    await _storeFile.writeAsString(jsonEncode(data));
  }

  void _emitChanged() {
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }
}

class _ResolvedUser {
  _ResolvedUser({required this.id, required this.username});

  final int id;
  final String username;
}
