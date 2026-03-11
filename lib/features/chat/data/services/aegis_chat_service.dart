import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

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
    this.lastMessage,
    this.unreadCount = 0,
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
        lastMessage: json['lastMessage'] as String?,
        unreadCount: json['unreadCount'] as int? ?? 0,
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
  final String? lastMessage;
  final int unreadCount;
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
    String? lastMessage,
    int? unreadCount,
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
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
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
      lastMessage: lastMessage.isNotEmpty ? lastMessage : (this.lastMessage ?? ''),
      roomType: kind,
      lastMessageTime: updatedAt,
      unreadCount: unreadCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'kind': kind,
        'updatedAt': updatedAt.toIso8601String(),
        if (lastMessage != null) 'lastMessage': lastMessage,
        'unreadCount': unreadCount,
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
  final StreamController<void> _chatChanges = StreamController<void>.broadcast();
  final Map<String, StreamController<void>> _roomChanges =
      <String, StreamController<void>>{};

  bool _initialized = false;
  bool _attached = false;
  Future<void>? _bootstrapFuture;
  StreamSubscription<Message>? _incomingSub;
  late Directory _storeDir;
  late Directory _messagesDir;
  late File _legacyStoreFile;
  late File _conversationsFile;
  late File _profilesFile;
  Timer? _persistTimer;
  Future<void>? _persistInFlight;
  final Set<String> _dirtyRoomIds = <String>{};
  final Set<String> _deletedRoomIds = <String>{};

  final Map<String, _StoredConversation> _conversations = {};
  final Map<String, List<AegisRoomMessage>> _messages = {};
  final Map<int, Map<String, dynamic>> _profileCache = {};
  final Map<String, Future<Map<String, dynamic>>> _userInfoRequests =
      <String, Future<Map<String, dynamic>>>{};
  final Set<String> _storedRoomIds = <String>{};
  final Set<String> _hydratedRoomIds = <String>{};
  StreamSubscription<List<Chat>>? _syncSub;
  bool _chatChangeQueued = false;
  final Set<String> _queuedRoomIds = <String>{};

  String get homeserver => 'aegis://${_auth.username ?? 'server'}';

  Future<void> _init() async {
    if (_initialized) return;
    final dir = await getApplicationDocumentsDirectory();
    _legacyStoreFile = File(p.join(dir.path, 'aegis_chat_store.json'));
    _storeDir = Directory(p.join(dir.path, 'aegis_chat_store'));
    _messagesDir = Directory(p.join(_storeDir.path, 'messages'));
    _conversationsFile = File(p.join(_storeDir.path, 'conversations.json'));
    _profilesFile = File(p.join(_storeDir.path, 'profiles.json'));

    if (!await _storeDir.exists()) {
      await _storeDir.create(recursive: true);
    }
    if (!await _messagesDir.exists()) {
      await _messagesDir.create(recursive: true);
    }

    if (await _conversationsFile.exists() || await _profilesFile.exists()) {
      await _loadSplitStore();
    } else if (await _legacyStoreFile.exists()) {
      await _loadLegacyStore();
      _dirtyRoomIds.addAll(_messages.keys);
      await _flushPersistNow();
    }
    _initialized = true;
  }

  Future<void> _loadLegacyStore() async {
    final raw = await _legacyStoreFile.readAsString();
    if (raw.trim().isEmpty) return;

    final json = await Isolate.run<Map<String, dynamic>>(
      () => Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
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
          .toList()
        ..sort((a, b) => a.time.compareTo(b.time));
    }
    _storedRoomIds.addAll(_messages.keys);
    _hydratedRoomIds.addAll(_messages.keys);
    for (final entry in profiles.entries) {
      final id = int.tryParse(entry.key);
      if (id != null && entry.value is Map<String, dynamic>) {
        _profileCache[id] = Map<String, dynamic>.from(
          entry.value as Map<String, dynamic>,
        );
      }
    }
  }

  Future<void> _loadSplitStore() async {
    if (await _conversationsFile.exists()) {
      final raw = await _conversationsFile.readAsString();
      if (raw.trim().isNotEmpty) {
        final conversations = await Isolate.run<List<dynamic>>(
          () => List<dynamic>.from(jsonDecode(raw) as List),
        );
        for (final item in conversations) {
          final conversation =
              _StoredConversation.fromJson(item as Map<String, dynamic>);
          _conversations[conversation.id] = conversation;
        }
      }
    }

    if (await _profilesFile.exists()) {
      final raw = await _profilesFile.readAsString();
      if (raw.trim().isNotEmpty) {
        final profiles = await Isolate.run<Map<String, dynamic>>(
          () => Map<String, dynamic>.from(jsonDecode(raw) as Map),
        );
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

    final files = await _messagesDir
        .list()
        .where((entity) => entity is File)
        .cast<File>()
        .toList();
    for (final file in files) {
      final roomId = _roomIdFromFileName(p.basenameWithoutExtension(file.path));
      _storedRoomIds.add(roomId);
    }
  }

  Future<void> _ensureRoomMessagesLoaded(String roomId) async {
    if (_hydratedRoomIds.contains(roomId)) return;
    _hydratedRoomIds.add(roomId);

    if (!_storedRoomIds.contains(roomId)) {
      _messages.putIfAbsent(roomId, () => <AegisRoomMessage>[]);
      return;
    }

    final file = _messageFileForRoom(roomId);
    if (!await file.exists()) {
      _messages.putIfAbsent(roomId, () => <AegisRoomMessage>[]);
      return;
    }

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      _messages[roomId] = <AegisRoomMessage>[];
      return;
    }

    final decoded = await Isolate.run<List<dynamic>>(
      () => List<dynamic>.from(jsonDecode(raw) as List),
    );
    _messages[roomId] = decoded
        .map((e) => AegisRoomMessage.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  String _messageFileKey(String roomId) =>
      base64Url.encode(utf8.encode(roomId));

  String _roomIdFromFileName(String fileName) =>
      utf8.decode(base64Url.decode(fileName));

  File _messageFileForRoom(String roomId) =>
      File(p.join(_messagesDir.path, '${_messageFileKey(roomId)}.json'));

  Future<void> ensureReady() async {
    await _init();
    await _auth.ensureSession();
    _ensureIncomingAttached();
  }

  void _ensureIncomingAttached() {
    if (_attached) return;
    _attached = true;
    _incomingSub = _auth.rawClient.messages.listen(_handleIncomingMessage);
  }

  Future<void> _ensureChatBootstrap() async {
    final inFlight = _bootstrapFuture;
    if (inFlight != null) {
      await inFlight;
      return;
    }
    final future = _refreshChatsFromServer();
    _bootstrapFuture = future;
    try {
      await future;
    } finally {
      if (identical(_bootstrapFuture, future)) {
        _bootstrapFuture = null;
      }
    }
  }

  Future<void> dispose() async {
    await _flushPersistNow();
    await _incomingSub?.cancel();
    _attached = false;
    for (final controller in _roomChanges.values) {
      await controller.close();
    }
    _roomChanges.clear();
  }

  Stream<List<Chat>> watchChats() async* {
    await _init();
    yield _currentChatsSnapshot();
    unawaited(_refreshChatsQuietly());
    await for (final _ in _chatChanges.stream) {
      yield _currentChatsSnapshot();
    }
  }

  Stream<List<AegisRoomMessage>> watchRoomMessages(String roomId,
      {int limit = 100}) async* {
    await ensureReady();
    await _ensureRoomMessagesLoaded(roomId);
    if ((_messages[roomId] ?? const <AegisRoomMessage>[]).length < limit) {
      try {
        await loadMessages(roomId: roomId, limit: limit, forceRefresh: true);
      } catch (_) {}
    }
    yield _roomMessagesSnapshot(roomId, limit: limit);
    await for (final _ in _roomChangeController(roomId).stream) {
      yield _roomMessagesSnapshot(roomId, limit: limit);
    }
  }

  Future<List<Chat>> getChats() async {
    await _init();
    return _currentChatsSnapshot();
  }

  List<Chat> _currentChatsSnapshot() {
    final items = _conversations.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items.map(_conversationToChat).toList();
  }

  Chat _conversationToChat(_StoredConversation conversation) {
    final lastMessage = conversation.lastMessage ??
        (_hydratedRoomIds.contains(conversation.id)
            ? _lastMessage(conversation.id)
            : '');

    var title = conversation.title;
    var avatarUrl = conversation.avatarUrl;
    var isOnline = false;
    String? presenceStatus;
    DateTime? lastSeenAt;

    final peerUserId = conversation.peerUserId;
    if (peerUserId != null) {
      final profile = _profileCache[peerUserId];
      if (profile != null) {
        final displayName = profile['displayName']?.toString();
        final username = profile['username']?.toString();
        title = (displayName?.isNotEmpty ?? false)
            ? displayName!
            : ((username?.isNotEmpty ?? false) ? username! : title);
        avatarUrl = profile['avatarUrl']?.toString() ?? avatarUrl;
        presenceStatus = profile['presenceStatus']?.toString();
        isOnline = profile['isOnline'] == true || presenceStatus == 'online';
        lastSeenAt = _dateTimeFromDynamic(profile['lastSeenAt']);
      }
    }

    return Chat(
      id: conversation.id,
      name: title,
      members: conversation.memberUserIds,
      avatarUrl: avatarUrl,
      lastMessage: lastMessage,
      roomType: conversation.kind,
      lastMessageTime: conversation.updatedAt,
      unreadCount: conversation.unreadCount,
      isOnline: isOnline,
      presenceStatus: presenceStatus,
      lastSeenAt: lastSeenAt,
    );
  }

  DateTime? _dateTimeFromDynamic(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  bool _syncProfileIntoConversations(int userId, Map<String, dynamic> info) {
    var changed = false;
    final nextTitle =
        (info['displayName'] ?? info['username'])?.toString().trim();
    final nextAvatar = info['avatarUrl']?.toString();

    for (final entry in _conversations.entries.toList(growable: false)) {
      final conversation = entry.value;
      if (conversation.peerUserId != userId) continue;

      final updated = conversation.copyWith(
        title: (nextTitle?.isNotEmpty ?? false) ? nextTitle : conversation.title,
        avatarUrl: (nextAvatar?.isNotEmpty ?? false)
            ? nextAvatar
            : conversation.avatarUrl,
      );
      if (jsonEncode(updated.toJson()) == jsonEncode(conversation.toJson())) {
        continue;
      }
      _conversations[entry.key] = updated;
      changed = true;
    }

    return changed;
  }

  Future<List<String>> getJoinedRooms() async {
    final chats = await getChats();
    return chats.map((e) => e.id).toList();
  }

  Future<Map<String, String?>> getRoomNameAndAvatar(String roomId) async {
    await _init();
    final room = _conversations[roomId];
    if (room == null) {
      return {
        'name': roomId,
        'avatar': null,
      };
    }
    final chat = _conversationToChat(room);
    return {
      'name': chat.name,
      'avatar': chat.avatarUrl,
    };
  }

  Future<List<AegisRoomMessage>> loadMessages({
    required String roomId,
    int limit = 100,
    bool forceRefresh = false,
  }) async {
    await ensureReady();
    await _ensureRoomMessagesLoaded(roomId);
    if (!_conversations.containsKey(roomId)) {
      try {
        await _ensureChatBootstrap();
      } catch (_) {}
    }

    final cached = _roomMessagesSnapshot(roomId, limit: limit);
    if (!forceRefresh && cached.isNotEmpty) {
      unawaited(
        _refreshRoomMessages(roomId, limit: limit).then((changed) {
          if (changed) {
            _emitRoomChanged(roomId);
            _emitChanged();
          }
        }).catchError((_) {}),
      );
      return cached;
    }

    try {
      final changed = await _refreshRoomMessages(roomId, limit: limit);
      if (changed) {
        _emitRoomChanged(roomId);
        _emitChanged();
      }
    } catch (_) {
      if (cached.isNotEmpty) return cached;
    }
    return _roomMessagesSnapshot(roomId, limit: limit);
  }

  List<AegisRoomMessage> _roomMessagesSnapshot(String roomId, {int limit = 100}) {
    final messages = _messages[roomId] ?? const <AegisRoomMessage>[];
    if (messages.length <= limit) {
      return List<AegisRoomMessage>.from(messages);
    }
    return List<AegisRoomMessage>.from(messages.sublist(messages.length - limit));
  }

  Map<String, dynamic>? peekUserInfo(String userId) {
    final parsedId = int.tryParse(userId.replaceFirst('@', '').split(':').first);
    if (parsedId == null) return null;
    return _profileCache[parsedId];
  }

  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    await ensureReady();
    final parsedId = int.tryParse(userId.replaceFirst('@', '').split(':').first);
    if (parsedId != null && _profileCache.containsKey(parsedId)) {
      return _profileCache[parsedId]!;
    }

    final cacheKey = parsedId?.toString() ?? userId;
    final pending = _userInfoRequests[cacheKey];
    if (pending != null) {
      return pending;
    }

    final request = () async {
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
          'id': userId,
          'username': userId,
          'displayName': userId,
          'avatarUrl': null,
          'avatars': const <Map<String, dynamic>>[],
          'presenceStatus': null,
          'isOnline': false,
          'lastSeenAt': null,
        };
      }

      final info = <String, dynamic>{
        'id': profile.id.toString(),
        'username': profile.username,
        'displayName': profile.displayName ?? profile.username,
        'avatarUrl': profile.avatarUrl,
        'avatars': profile.avatars
            .map(
              (avatar) => <String, dynamic>{
                'id': avatar.id,
                'avatarUrl': avatar.avatarUrl,
                'isPrimary': avatar.isPrimary,
                'createdAt': avatar.createdAt.toIso8601String(),
              },
            )
            .toList(growable: false),
        'presenceStatus': profile.presenceStatus,
        'isOnline': profile.presenceStatus == 'online',
        'bio': profile.bio,
        'email': profile.email,
        'lastSeenAt': profile.lastSeenAt?.toIso8601String(),
      };
      _profileCache[profile.id] = info;
      final conversationChanged = _syncProfileIntoConversations(profile.id, info);
      unawaited(_persist());
      if (conversationChanged) {
        _emitChanged();
      }
      return info;
    }();

    _userInfoRequests[cacheKey] = request;
    try {
      return await request;
    } finally {
      _userInfoRequests.remove(cacheKey);
    }
  }

  Future<String?> getCurrentUserId() async {
    await ensureReady();
    final userId = _auth.userId;
    if (userId == null) return _auth.username;
    return userId.toString();
  }

  Future<String> createDirectChat(String userId) async {
    final target = await _resolveUser(userId);
    final targetInfo = await getUserInfo(target.id.toString());
    final roomId = 'dm:${target.id}';
    final conversation = _StoredConversation(
      id: roomId,
      title: targetInfo['displayName'] as String? ?? target.username,
      kind: 'direct',
      updatedAt: DateTime.now(),
      avatarUrl: targetInfo['avatarUrl'] as String?,
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
    unawaited(_refreshChatsFromServer());
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
    await ensureReady();
    final conversation = _conversations[roomId];
    final messageId = int.tryParse(eventId);
    if (conversation != null && messageId != null) {
      final response = await _auth.rawClient.editMessage(
        messageId: messageId,
        newContent: text,
        scope: conversation.kind == 'direct' ? 'private' : 'channel',
        channelId: conversation.kind == 'direct' ? null : conversation.channelId,
      );
      if (!response.success) {
        throw Exception(response.message ?? 'Unable to edit message');
      }
    }
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
    _dirtyRoomIds.add(roomId);
    await _persist();
    _emitRoomChanged(roomId);
    _emitChanged();
  }

  Future<void> redactEvent(String roomId, String eventId) async {
    await ensureReady();
    final conversation = _conversations[roomId];
    final messageId = int.tryParse(eventId);
    if (conversation != null && messageId != null) {
      final response = await _auth.rawClient.deleteMessage(
        messageId: messageId,
        scope: conversation.kind == 'direct' ? 'private' : 'channel',
        channelId: conversation.kind == 'direct' ? null : conversation.channelId,
      );
      if (!response.success) {
        throw Exception(response.message ?? 'Unable to delete message');
      }
    }
    _messages[roomId]?.removeWhere((element) => element.id == eventId);
    _dirtyRoomIds.add(roomId);
    await _persist();
    _emitRoomChanged(roomId);
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
    _dirtyRoomIds.remove(roomId);
    _deletedRoomIds.add(roomId);
    _storedRoomIds.remove(roomId);
    _hydratedRoomIds.remove(roomId);
    final controller = _roomChanges.remove(roomId);
    await controller?.close();
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
    await ensureReady();
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
    final payloadBytes = (bytes as List<int>).toList();
    await target.writeAsBytes(payloadBytes);
    final conversation = _conversations[roomId];
    if (conversation != null) {
      if (conversation.channelId != null) {
        final dataUrl = 'data:image/png;base64,${base64Encode(payloadBytes)}';
        final response = await _auth.rawClient.editChannel(
          channelId: conversation.channelId!,
          avatarUrl: dataUrl,
        );
        if (!response.success) {
          throw Exception(response.message ?? 'Unable to update room avatar');
        }
      }
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
    _syncSub?.cancel();
    _syncSub = watchChats().listen((_) {
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

  void stopSync() {
    _syncSub?.cancel();
    _syncSub = null;
  }

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
            'presenceStatus': user.presenceStatus,
            'prefs': <String, dynamic>{
              'online': user.presenceStatus == 'online',
              if (user.presenceStatus != null)
                'presenceStatus': user.presenceStatus,
            },
          },
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> getRoomMembers(String roomId,
      {bool forceRefresh = false}) async {
    await _init();
    final room = _conversations[roomId];
    if (room == null) return const <Map<String, dynamic>>[];
    return Future.wait(
      room.memberUserIds.map((id) async {
        final info = await getUserInfo(id);
        return {
          'userId': id,
          'displayName': info['displayName'] ?? info['username'] ?? id,
          'avatarUrl': info['avatarUrl'],
        };
      }),
    );
  }

  Future<void> refreshChats() async {
    await ensureReady();
    await _ensureChatBootstrap();
    final changed = await _refreshChatsFromServer();
    if (changed) {
      _emitChanged();
    }
  }

  Future<void> refreshChatsQuietly() => _refreshChatsQuietly();

  Future<void> _refreshChatsQuietly() async {
    try {
      await refreshChats();
    } catch (_) {
      // Keep cached chats visible when the network is unavailable.
    }
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

  Future<Map<String, String?>> getRoomLinkInfo(
    String roomId, {
    bool regeneratePrivateInvite = false,
  }) async {
    await ensureReady();
    final room = _conversations[roomId];
    if (room == null || room.channelId == null) {
      throw Exception('Links are only available for channels');
    }

    ChannelLinkResponse response;
    if (room.isPublic || regeneratePrivateInvite) {
      response = await _auth.rawClient.updateChannelLinks(
        room.channelId!,
        publicAlias: room.isPublic
            ? _buildChannelAlias(room.title, room.channelId!)
            : null,
        regeneratePrivateInvite: regeneratePrivateInvite,
      );
    } else {
      response = await _auth.rawClient.getChannelLinks(room.channelId!);
    }

    if (!response.success || response.link == null) {
      throw Exception(response.message ?? 'Unable to fetch room link');
    }

    final link = response.link!;
    return {
      'publicAlias': link.publicAlias,
      'publicLink': link.publicLink,
      'privateInviteLink': link.privateInviteLink,
      'preferredLink': room.isPublic
          ? (link.publicLink ?? link.privateInviteLink)
          : link.privateInviteLink,
    };
  }

  Future<Map<String, dynamic>> resolveRoomLink(String linkOrAlias) async {
    await ensureReady();
    final response = await _auth.rawClient.resolveChannelLink(linkOrAlias.trim());
    if (!response.success || response.channel == null) {
      throw Exception(response.message ?? 'Unable to resolve room link');
    }

    final channel = response.channel!;
    return {
      'id': channel.id,
      'name': channel.name,
      'description': channel.description,
      'memberCount': channel.memberCount,
      'type': switch (channel.type) {
        ChannelType.group => 'group',
        ChannelType.private => 'private',
        ChannelType.public => 'public',
      },
    };
  }

  Future<Chat> joinRoomByLink(String linkOrAlias) async {
    await ensureReady();
    final response = await _auth.rawClient.joinChannelByLink(linkOrAlias.trim());
    if (!response.success || response.channel == null) {
      throw Exception(response.message ?? 'Unable to join room');
    }

    final channel = response.channel!;
    final roomId = 'channel:${channel.id}';
    final roomKind = switch (channel.type) {
      ChannelType.group => 'group',
      ChannelType.private => 'private',
      ChannelType.public => 'public',
    };

    final existing = _conversations[roomId];
    _conversations[roomId] = _StoredConversation(
      id: roomId,
      title: channel.name,
      kind: roomKind,
      updatedAt: DateTime.now(),
      lastMessage: existing?.lastMessage,
      unreadCount: existing?.unreadCount ?? 0,
      avatarUrl: existing?.avatarUrl,
      description: channel.description,
      channelId: channel.id,
      isPublic: channel.type == ChannelType.public,
      showMessageHistory: existing?.showMessageHistory ?? false,
      memberUserIds: existing?.memberUserIds ?? <String>[],
    );

    await _persist();
    _emitChanged();
    return _conversationToChat(_conversations[roomId]!);
  }

  String _buildChannelAlias(String title, int channelId) {
    final slug = title
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (slug.isEmpty) {
      return 'channel-$channelId';
    }
    return '$slug-$channelId';
  }

  Future<void> clearRoomCache(String roomId) async {}

  Future<List<double>> getWaveformForMedia(String mediaId, String? localPath,
          {int samples = 50}) async =>
      const <double>[];

  Future<Chat> getOrCreateDirectChat(String otherUserId) async {
    final roomId = await createDirectChat(otherUserId);
    final conversation = _conversations[roomId]!;
    return _conversationToChat(conversation);
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

  Future<void> setUserRole(String roomId, String userId, GroupRole role) async {
    await ensureReady();
    final room = _conversations[roomId];
    final targetUserId = int.tryParse(userId);
    if (room?.channelId == null || targetUserId == null) return;

    final response = await _auth.rawClient.updateMemberRole(
      scope: 'channel',
      targetId: room!.channelId!,
      targetUserId: targetUserId,
      newRole: _mapGroupRole(role),
    );
    if (!response.success) {
      throw Exception(response.message ?? 'Unable to update member role');
    }
  }

  Future<void> freezeUser(
    String roomId,
    String userId,
    DateTime? until,
    String? reason,
  ) async {
    await ensureReady();
    final room = _conversations[roomId];
    final targetUserId = int.tryParse(userId);
    if (room?.channelId == null || targetUserId == null) return;

    final response = await _auth.rawClient.updateMemberPermissions(
      scope: 'channel',
      targetId: room!.channelId!,
      targetUserId: targetUserId,
      canSendMessages: false,
    );
    if (!response.success) {
      throw Exception(response.message ?? 'Unable to freeze member');
    }
  }

  Future<void> banUser(String roomId, String userId) async {
    await ensureReady();
    final room = _conversations[roomId];
    final targetUserId = int.tryParse(userId);
    if (room?.channelId == null || targetUserId == null) return;

    final response = await _auth.rawClient.updateMemberPermissions(
      scope: 'channel',
      targetId: room!.channelId!,
      targetUserId: targetUserId,
      canSendMessages: false,
      canInviteUsers: false,
      canEditInfo: false,
      canPinMessages: false,
    );
    if (!response.success) {
      throw Exception(response.message ?? 'Unable to restrict member');
    }
  }

  Future<void> unbanUser(String roomId, String userId) async {
    await ensureReady();
    final room = _conversations[roomId];
    final targetUserId = int.tryParse(userId);
    if (room?.channelId == null || targetUserId == null) return;

    final response = await _auth.rawClient.updateMemberPermissions(
      scope: 'channel',
      targetId: room!.channelId!,
      targetUserId: targetUserId,
      canSendMessages: true,
      canInviteUsers: true,
      canEditInfo: true,
      canPinMessages: true,
    );
    if (!response.success) {
      throw Exception(response.message ?? 'Unable to restore member access');
    }
  }

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
        'avatars': response.profile!.avatars
            .map(
              (avatar) => <String, dynamic>{
                'id': avatar.id,
                'avatarUrl': avatar.avatarUrl,
                'isPrimary': avatar.isPrimary,
                'createdAt': avatar.createdAt.toIso8601String(),
              },
            )
            .toList(growable: false),
        'presenceStatus': response.profile!.presenceStatus,
        'isOnline': response.profile!.presenceStatus == 'online',
        'bio': response.profile!.bio,
        'email': response.profile!.email,
        'lastSeenAt': response.profile!.lastSeenAt?.toIso8601String(),
      };
      await _persist();
      _emitChanged();
    }
  }

  Future<Map<String, dynamic>> uploadMyAvatar(
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    await ensureReady();
    final response = await _auth.rawClient.uploadUserAvatar(
      imageBytes,
      mimeType: mimeType,
    );
    if (!response.success) {
      throw Exception(response.message ?? 'Unable to update avatar');
    }

    final profile = response.profile;
    if (profile == null) {
      final currentUserId = await getCurrentUserId();
      if (currentUserId == null) {
        return const <String, dynamic>{};
      }
      return getUserInfo(currentUserId);
    }

    final info = <String, dynamic>{
      'id': profile.id.toString(),
      'username': profile.username,
      'displayName': profile.displayName ?? profile.username,
      'avatarUrl': profile.avatarUrl,
      'avatars': profile.avatars
          .map(
            (avatar) => <String, dynamic>{
              'id': avatar.id,
              'avatarUrl': avatar.avatarUrl,
              'isPrimary': avatar.isPrimary,
              'createdAt': avatar.createdAt.toIso8601String(),
            },
          )
          .toList(growable: false),
      'presenceStatus': profile.presenceStatus,
      'isOnline': profile.presenceStatus == 'online',
      'bio': profile.bio,
      'email': profile.email,
      'lastSeenAt': profile.lastSeenAt?.toIso8601String(),
    };
    _profileCache[profile.id] = info;
    await _persist();
    _emitChanged();
    return info;
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
    if (list.length > 1 && list[list.length - 2].time.isAfter(message.time)) {
      list.sort((a, b) => a.time.compareTo(b.time));
    }
    final room = _conversations[roomId];
    if (room != null) {
      _conversations[roomId] = room.copyWith(
        updatedAt: message.time,
        lastMessage: message.content,
      );
    }
    _storedRoomIds.add(roomId);
    _hydratedRoomIds.add(roomId);
    _dirtyRoomIds.add(roomId);
    await _persist();
    _emitRoomChanged(roomId);
    _emitChanged();
  }

  void _handleIncomingMessage(Message message) {
    if (message.type != MessageType.privateChatMessageEvent &&
        message.type != MessageType.channelMessageEvent &&
        message.type != MessageType.privateChatMessage &&
        message.type != MessageType.channelMessage) {
      return;
    }
    try {
      if (message.type == MessageType.privateChatMessageEvent ||
          message.type == MessageType.privateChatMessage) {
        final event = PrivateChatMessageEvent.fromBytes(message.payload);
        final me = _auth.userId;
        final peerId = event.fromUserId == me ? event.toUserId : event.fromUserId;
        final roomId = 'dm:$peerId';
        _conversations.putIfAbsent(
          roomId,
          () => _StoredConversation(
            id: roomId,
            title: event.fromUsername ?? event.username ?? peerId.toString(),
            kind: 'direct',
            updatedAt: event.createdAt,
            peerUserId: peerId,
            peerUsername: event.fromUsername ?? event.username,
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
              id: event.id.toString(),
              senderId: event.fromUserId.toString(),
              content: event.content,
              time: event.createdAt,
            ),
          ),
        );
      }

      if (message.type == MessageType.channelMessageEvent ||
          message.type == MessageType.channelMessage) {
        final event = ChannelMessageEvent.fromBytes(message.payload);
        final channelId = event.channelId;
        final roomId = 'channel:$channelId';
        _conversations.putIfAbsent(
          roomId,
          () => _StoredConversation(
            id: roomId,
            title: event.channelName ?? 'Channel $channelId',
            kind: 'group',
            updatedAt: event.createdAt,
            channelId: channelId,
            memberUserIds: <String>[event.fromUserId.toString()],
          ),
        );
        unawaited(
          _appendMessage(
            roomId,
            AegisRoomMessage(
              id: event.id.toString(),
              senderId: event.fromUserId.toString(),
              content: event.content,
              time: event.createdAt,
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

  Future<bool> _refreshChatsFromServer() async {
    final response = await _auth.rawClient.getChatList();
    if (!response.success) {
      throw Exception(response.message ?? 'Unable to load chat list');
    }

    final me = (_auth.userId ?? 0).toString();
    var changed = false;
    final directPeerIds = <String>{};

    for (final item in response.chats) {
      final roomId = item.peerUserId != null
          ? 'dm:${item.peerUserId}'
          : 'channel:${item.channelId ?? item.chatId}';
      if (item.peerUserId != null) {
        directPeerIds.add(item.peerUserId.toString());
      }
      final existing = _conversations[roomId];
      final next = _StoredConversation(
        id: roomId,
        title: item.title,
        kind: item.type == 'direct' ? 'direct' : item.type,
        updatedAt: item.lastMessageAt ?? existing?.updatedAt ?? DateTime.now(),
        lastMessage: item.lastMessage ?? existing?.lastMessage,
        unreadCount: item.unreadCount,
        avatarUrl: item.avatarUrl ?? existing?.avatarUrl,
        description: existing?.description,
        peerUserId: item.peerUserId ?? existing?.peerUserId,
        peerUsername: existing?.peerUsername,
        channelId: item.channelId ?? existing?.channelId,
        isPublic: existing?.isPublic ?? item.type == 'channel',
        showMessageHistory: existing?.showMessageHistory ?? false,
        memberUserIds: (existing?.memberUserIds.isNotEmpty ?? false)
            ? existing!.memberUserIds
            : <String>[
                if (me != '0') me,
                if (item.peerUserId != null) item.peerUserId.toString(),
              ],
      );

      if (existing == null || jsonEncode(existing.toJson()) != jsonEncode(next.toJson())) {
        _conversations[roomId] = next;
        changed = true;
      }
    }

    if (directPeerIds.isNotEmpty) {
      await Future.wait(
        directPeerIds.map(
          (peerId) => getUserInfo(peerId).catchError((_) => <String, dynamic>{}),
        ),
      );
    }

    if (changed) {
      await _persist();
    }
    return changed;
  }

  Future<bool> _refreshRoomMessages(String roomId, {int limit = 100}) async {
    await _ensureRoomMessagesLoaded(roomId);
    final conversation = _conversations[roomId];
    if (conversation == null) return false;

    List<AegisRoomMessage> nextMessages;
    if (conversation.kind == 'direct' && conversation.peerUserId != null) {
      final response = await _auth.rawClient.getPrivateHistory(
        conversation.peerUserId!,
        limit: limit,
      );
      if (!response.success) {
        throw Exception(response.message ?? 'Unable to load direct messages');
      }
      nextMessages = response.messages
          .map(
            (item) => AegisRoomMessage(
              id: item.id.toString(),
              senderId: item.fromUserId.toString(),
              content: item.content,
              time: item.createdAt,
              type: _mapMessageType(item.contentType),
            ),
          )
          .toList();
    } else if (conversation.channelId != null) {
      final response = await _auth.rawClient.getChannelHistory(
        conversation.channelId!,
        limit: limit,
      );
      if (!response.success) {
        throw Exception(response.message ?? 'Unable to load room history');
      }
      nextMessages = response.messages
          .map(
            (item) => AegisRoomMessage(
              id: item.id.toString(),
              senderId: item.fromUserId.toString(),
              content: item.content,
              time: item.createdAt,
              type: _mapMessageType(item.contentType),
            ),
          )
          .toList();
    } else {
      return false;
    }

    nextMessages.sort((a, b) => a.time.compareTo(b.time));
    final currentMessages = _messages[roomId] ?? const <AegisRoomMessage>[];
    if (_sameMessages(currentMessages, nextMessages)) {
      return false;
    }
    _messages[roomId] = nextMessages;
    _storedRoomIds.add(roomId);
    _hydratedRoomIds.add(roomId);
    _dirtyRoomIds.add(roomId);
    await _persist();
    return true;
  }

  bool _sameMessages(
    List<AegisRoomMessage> current,
    List<AegisRoomMessage> next,
  ) {
    if (identical(current, next)) return true;
    if (current.length != next.length) return false;
    for (var index = 0; index < current.length; index++) {
      final left = current[index];
      final right = next[index];
      if (left.id != right.id ||
          left.content != right.content ||
          left.time != right.time ||
          left.type != right.type ||
          left.mediaId != right.mediaId ||
          left.senderId != right.senderId) {
        return false;
      }
    }
    return true;
  }

  String _mapMessageType(MessageContentType type) {
    switch (type) {
      case MessageContentType.image:
        return 'm.image';
      case MessageContentType.video:
        return 'm.video';
      case MessageContentType.audio:
        return 'm.audio';
      case MessageContentType.file:
        return 'm.file';
      case MessageContentType.location:
        return 'm.location';
      case MessageContentType.text:
        return 'm.text';
    }
  }

  int _mapGroupRole(GroupRole role) {
    switch (role) {
      case GroupRole.owner:
        return 3;
      case GroupRole.admin:
        return 2;
      case GroupRole.member:
        return 1;
      case GroupRole.guest:
        return 0;
    }
  }

  Future<void> _persist() async {
    _persistTimer?.cancel();
    _persistTimer = Timer(
      const Duration(milliseconds: 700),
      () => unawaited(_flushPersistNow()),
    );
  }

  Future<void> _flushPersistNow() async {
    _persistTimer?.cancel();
    _persistTimer = null;
    final inFlight = _persistInFlight;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final dirtyRoomIds = Set<String>.from(_dirtyRoomIds);
    final deletedRoomIds = Set<String>.from(_deletedRoomIds);

    final future = () async {
    await _init();
    final conversationsPayload =
        _conversations.values.map((e) => e.toJson()).toList(growable: false);
    final profilesPayload = _profileCache.map(
      (key, value) => MapEntry(key.toString(), value),
    );

    final conversationsJson =
        await Isolate.run<String>(() => jsonEncode(conversationsPayload));
    final profilesJson =
        await Isolate.run<String>(() => jsonEncode(profilesPayload));

    await Future.wait([
      _conversationsFile.writeAsString(conversationsJson),
      _profilesFile.writeAsString(profilesJson),
    ]);

    await Future.wait(
      dirtyRoomIds.map((roomId) async {
        final payload = (_messages[roomId] ?? const <AegisRoomMessage>[])
            .map((e) => e.toJson())
            .toList(growable: false);
        final encoded = await Isolate.run<String>(() => jsonEncode(payload));
        await _messageFileForRoom(roomId).writeAsString(encoded);
      }),
    );

    await Future.wait(
      deletedRoomIds.map((roomId) async {
        final file = _messageFileForRoom(roomId);
        if (await file.exists()) {
          await file.delete();
        }
      }),
    );

    if (await _legacyStoreFile.exists()) {
      await _legacyStoreFile.delete();
    }
    }();

    _persistInFlight = future;
    try {
      await future;
      _dirtyRoomIds.removeAll(dirtyRoomIds);
      _deletedRoomIds.removeAll(deletedRoomIds);
    } finally {
      if (identical(_persistInFlight, future)) {
        _persistInFlight = null;
      }
    }
  }

  StreamController<void> _roomChangeController(String roomId) {
    return _roomChanges.putIfAbsent(
      roomId,
      StreamController<void>.broadcast,
    );
  }

  void _emitRoomChanged(String roomId) {
    final controller = _roomChanges[roomId];
    if (controller == null || controller.isClosed) return;
    if (!_queuedRoomIds.add(roomId)) return;
    scheduleMicrotask(() {
      _queuedRoomIds.remove(roomId);
      if (!controller.isClosed) {
        controller.add(null);
      }
    });
  }

  void _emitChanged() {
    if (_chatChanges.isClosed || _chatChangeQueued) return;
    _chatChangeQueued = true;
    scheduleMicrotask(() {
      _chatChangeQueued = false;
      if (!_chatChanges.isClosed) {
        _chatChanges.add(null);
      }
    });
  }
}

class _ResolvedUser {
  _ResolvedUser({required this.id, required this.username});

  final int id;
  final String username;
}
