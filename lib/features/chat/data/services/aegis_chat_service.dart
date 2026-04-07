import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/models/group.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';
import 'package:two_space_app/core/services/dev_logger.dart';
import 'package:two_space_app/core/utils/aegis_avatar_url.dart';
import 'package:two_space_app/core/utils/user_content_sanitizer.dart';
import 'package:two_space_app/features/auth/data/services/aegis_auth_service.dart';
import 'package:two_space_app/features/chat/data/local/aegis_chat_local_store.dart';
import 'package:two_space_app/features/chat/data/services/offline_queue_service.dart';

class AegisFeatureInDevelopmentException implements Exception {
  const AegisFeatureInDevelopmentException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AegisRoomMessage {
  AegisRoomMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.time,
    this.type = 'm.text',
    this.mediaId,
    this.replyToMessageId,
    this.isDelivered = false,
    this.isRead = false,
    this.deliveredAt,
    this.readAt,
  });

  factory AegisRoomMessage.fromJson(Map<String, dynamic> json) {
    return AegisRoomMessage(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as String? ?? '',
      time:
          DateTime.tryParse(json['time'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      type: json['type'] as String? ?? 'm.text',
      mediaId: json['mediaId'] as String?,
      replyToMessageId: (json['replyToMessageId'] as num?)?.toInt(),
      isDelivered: json['isDelivered'] as bool? ?? false,
      isRead: json['isRead'] as bool? ?? false,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.tryParse(json['deliveredAt'] as String)
          : null,
      readAt: json['readAt'] != null
          ? DateTime.tryParse(json['readAt'] as String)
          : null,
    );
  }

  final String id;
  final String senderId;
  final String content;
  final DateTime time;
  final String type;
  final String? mediaId;
  final int? replyToMessageId;
  final bool isDelivered;
  final bool isRead;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'content': content,
    'time': time.toIso8601String(),
    'type': type,
    if (mediaId != null) 'mediaId': mediaId,
    if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
    'isDelivered': isDelivered,
    'isRead': isRead,
    if (deliveredAt != null) 'deliveredAt': deliveredAt!.toIso8601String(),
    if (readAt != null) 'readAt': readAt!.toIso8601String(),
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
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
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
      memberUserIds:
          (json['memberUserIds'] as List<dynamic>?)
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
      lastMessage: lastMessage.isNotEmpty
          ? lastMessage
          : (this.lastMessage ?? ''),
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
  static const int _maxMediaUploadBytes = 15 * 1024 * 1024;
  static const int _mediaCacheMaxBytes = 512 * 1024 * 1024;
  static const Duration _mediaCacheMaxAge = Duration(days: 14);

  factory AegisChatService() => _instance;
  AegisChatService._internal();

  static final AegisChatService _instance = AegisChatService._internal();

  final AegisAuthService _auth = AegisAuthService();
  final DevLogger _log = DevLogger('AegisChatService');
  final OfflineQueueService _offlineQueue = OfflineQueueService();
  final StreamController<void> _chatChanges =
      StreamController<void>.broadcast();
  final Map<String, StreamController<void>> _roomChanges =
      <String, StreamController<void>>{};

  bool _initialized = false;
  bool _attached = false;
  Future<bool>? _bootstrapFuture;
  StreamSubscription<Message>? _incomingSub;
  StreamSubscription<MessageStatusEvent>? _messageStatusSub;
  StreamSubscription<ReadSyncEventPayload>? _readSyncSub;
  StreamSubscription<void>? _sessionRestoredSub;
  late Directory _storeDir;
  final AegisChatLocalStore _localStore = AegisChatLocalStore();
  Timer? _persistTimer;
  Future<void>? _persistInFlight;
  Future<bool>? _chatRefreshInFlight;
  Future<void>? _offlineFlushInFlight;
  final Map<String, Map<String, AegisRoomMessage>> _dirtyMessagesByRoom =
      <String, Map<String, AegisRoomMessage>>{};
  final Map<String, Set<String>> _deletedMessageIdsByRoom =
      <String, Set<String>>{};
  final Set<String> _deletedRoomIds = <String>{};
  bool _conversationsDirty = false;
  bool _profilesDirty = false;
  bool _persistQueuedWhileWriting = false;
  DateTime? _lastChatRefreshAt;

  static const Duration _persistDebounce = Duration(seconds: 4);
  static const Duration _chatRefreshCooldown = Duration(seconds: 20);

  final Map<String, _StoredConversation> _conversations = {};

  /// Reverse index: peerUserId → set of roomIds for fast profile→conversation sync.
  final Map<int, Set<String>> _peerUserIdToRoomIds = <int, Set<String>>{};
  static const int _maxCachedRooms = 30;
  static const int _maxProfileCacheSize = 500;

  final Map<String, List<AegisRoomMessage>> _messages = {};
  final Map<String, Map<String, Map<String, dynamic>>> _roomReactions =
      <String, Map<String, Map<String, dynamic>>>{};
  final Map<String, List<String>> _pinnedEventIdsByRoom =
      <String, List<String>>{};

  /// Tracks access order for LRU eviction of message cache.
  final List<String> _messageAccessOrder = <String>[];
  final Map<int, Map<String, dynamic>> _profileCache = {};
  final Map<String, Future<Map<String, dynamic>>> _userInfoRequests =
      <String, Future<Map<String, dynamic>>>{};
  final Map<String, String> _mediaPathCache = <String, String>{};
  final Map<String, Future<String>> _mediaResolveInFlight =
      <String, Future<String>>{};
  final Set<String> _storedRoomIds = <String>{};
  final Set<String> _hydratedRoomIds = <String>{};
  StreamSubscription<List<Chat>>? _syncSub;
  bool _chatChangeQueued = false;
  final Map<String, Timer> _roomEmitTimers = <String, Timer>{};
  Timer? _chatEmitTimer;
  String? _activeRoomId;

  String get homeserver => 'aegis://${_auth.username ?? 'server'}';

  Future<void> _init() async {
    if (_initialized) return;
    final dir = await getApplicationDocumentsDirectory();
    _storeDir = Directory(p.join(dir.path, 'aegis_chat_store'));

    if (!await _storeDir.exists()) {
      await _storeDir.create(recursive: true);
    }

    Future.delayed(const Duration(seconds: 30), _cleanupMediaCache);

    final bootstrap = await _localStore.initialize();
    await OfflineQueueService.initialize();
    for (final item in bootstrap.conversations) {
      final conversation = _StoredConversation.fromJson(item);
      _conversations[conversation.id] = conversation;
      // Build reverse index for fast profile→conversation sync.
      if (conversation.peerUserId != null) {
        _peerUserIdToRoomIds
            .putIfAbsent(conversation.peerUserId!, () => <String>{})
            .add(conversation.id);
      }
    }
    _profileCache.addAll(bootstrap.profiles);
    _storedRoomIds.addAll(bootstrap.storedRoomIds);
    _sessionRestoredSub ??= _auth.sessionRestored.listen((_) {
      unawaited(_handleSessionRestored());
    });
    _initialized = true;
  }

  Future<void> _ensureRoomMessagesLoaded(String roomId) async {
    if (_hydratedRoomIds.contains(roomId)) {
      _touchMessageCache(roomId);
      return;
    }
    _hydratedRoomIds.add(roomId);

    if (!_storedRoomIds.contains(roomId)) {
      _messages.putIfAbsent(roomId, () => <AegisRoomMessage>[]);
      _touchMessageCache(roomId);
      return;
    }

    final decoded = await _localStore.loadRoomMessagesJson(roomId, limit: 500);
    if (decoded.isEmpty) {
      _messages[roomId] = <AegisRoomMessage>[];
      _touchMessageCache(roomId);
      return;
    }
    _messages[roomId] = decoded.map(AegisRoomMessage.fromJson).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    _storedRoomIds.add(roomId);
    _touchMessageCache(roomId);
  }

  /// Moves [roomId] to the front of the LRU access order and evicts
  /// the least recently used rooms when the cache exceeds its limit.
  void _touchMessageCache(String roomId) {
    _messageAccessOrder.remove(roomId);
    _messageAccessOrder.insert(0, roomId);
    while (_messageAccessOrder.length > _maxCachedRooms) {
      final evicted = _messageAccessOrder.removeLast();
      _messages.remove(evicted);
      _hydratedRoomIds.remove(evicted);
    }
  }

  Future<void> ensureReady() async {
    await _init();
    await _auth.ensureSession();
    _ensureIncomingAttached();
    unawaited(_flushOfflineQueue());
  }

  Future<void> _handleSessionRestored() async {
    _ensureIncomingAttached();
    await _flushOfflineQueue();
    unawaited(_refreshChatsQuietly());
  }

  void _markConversationsDirty() {
    _conversationsDirty = true;
  }

  void _markProfilesDirty() {
    _profilesDirty = true;
  }

  void _storeConversation(_StoredConversation conversation) {
    final existing = _conversations[conversation.id];
    if (existing != null && _storedConversationEquals(existing, conversation)) {
      return;
    }
    // Maintain reverse index for fast profile→conversation sync.
    if (existing?.peerUserId != null) {
      _peerUserIdToRoomIds[existing!.peerUserId!]?.remove(conversation.id);
    }
    if (conversation.peerUserId != null) {
      _peerUserIdToRoomIds
          .putIfAbsent(conversation.peerUserId!, () => <String>{})
          .add(conversation.id);
    }
    _conversations[conversation.id] = conversation;
    _markConversationsDirty();
  }

  bool _purgeRoomState(String roomId, {bool markDeletedRoom = true}) {
    final existing = _conversations.remove(roomId);
    if (existing?.peerUserId != null) {
      final peerUserId = existing!.peerUserId!;
      final roomIds = _peerUserIdToRoomIds[peerUserId];
      roomIds?.remove(roomId);
      if (roomIds != null && roomIds.isEmpty) {
        _peerUserIdToRoomIds.remove(peerUserId);
      }
    }
    if (existing != null) {
      _markConversationsDirty();
    }

    final hadState = existing != null ||
        _messages.containsKey(roomId) ||
        _roomReactions.containsKey(roomId) ||
        _pinnedEventIdsByRoom.containsKey(roomId) ||
        _storedRoomIds.contains(roomId) ||
        _hydratedRoomIds.contains(roomId);

    _messages.remove(roomId);
    _roomReactions.remove(roomId);
    _pinnedEventIdsByRoom.remove(roomId);
    _messageAccessOrder.remove(roomId);
    _dirtyMessagesByRoom.remove(roomId);
    _deletedMessageIdsByRoom.remove(roomId);
    _storedRoomIds.remove(roomId);
    _hydratedRoomIds.remove(roomId);
    if (_activeRoomId == roomId) {
      _activeRoomId = null;
    }
    if (markDeletedRoom) {
      _deletedRoomIds.add(roomId);
    }
    return hadState;
  }

  void _storeProfile(int userId, Map<String, dynamic> info) {
    final existing = _profileCache[userId];
    if (existing != null && _dynamicEquals(existing, info)) {
      return;
    }
    _profileCache[userId] = info;
    // Evict oldest entries when cache exceeds limit.
    if (_profileCache.length > _maxProfileCacheSize) {
      final keysToRemove = _profileCache.keys
          .take(_profileCache.length - _maxProfileCacheSize)
          .toList(growable: false);
      for (final key in keysToRemove) {
        _profileCache.remove(key);
      }
    }
    _markProfilesDirty();
  }

  void _ensureIncomingAttached() {
    if (_attached) return;
    _attached = true;
    _incomingSub = _auth.rawClient.messages.listen(_handleIncomingMessage);
    _messageStatusSub ??= _auth.rawClient.messageStatusEvents.listen(
      _handleMessageStatusEvent,
    );
    _readSyncSub ??= _auth.rawClient.readSyncEvents.listen(_handleReadSyncEvent);
  }

  Future<bool> _ensureChatBootstrap() async {
    final inFlight = _bootstrapFuture;
    if (inFlight != null) {
      return inFlight;
    }
    final future = _refreshChatsFromServer();
    _bootstrapFuture = future;
    try {
      return await future;
    } finally {
      if (identical(_bootstrapFuture, future)) {
        _bootstrapFuture = null;
      }
    }
  }

  Future<void> dispose() async {
    await _flushPersistNow();
    await _incomingSub?.cancel();
    await _messageStatusSub?.cancel();
    await _readSyncSub?.cancel();
    await _sessionRestoredSub?.cancel();
    await _localStore.close();
    _attached = false;
    for (final timer in _roomEmitTimers.values) {
      timer.cancel();
    }
    _roomEmitTimers.clear();
    _chatEmitTimer?.cancel();
    _chatEmitTimer = null;
    for (final controller in _roomChanges.values) {
      await controller.close();
    }
    _roomChanges.clear();
  }

  bool get _shouldExposeChatCache =>
      _auth.isAuthenticated || _conversations.isNotEmpty;

  Stream<List<Chat>> watchChats() async* {
    await _init();
    var lastSnapshot = _currentChatsSnapshot();
    yield lastSnapshot;
    await for (final _ in _chatChanges.stream) {
      final next = _currentChatsSnapshot();
      if (!_chatListEquals(lastSnapshot, next)) {
        lastSnapshot = next;
        yield next;
      }
    }
  }

  Stream<int> watchUnreadChatsCount() async* {
    await _init();
    var lastCount = _currentUnreadChatsCount();
    yield lastCount;
    await for (final _ in _chatChanges.stream) {
      final nextCount = _currentUnreadChatsCount();
      if (nextCount != lastCount) {
        lastCount = nextCount;
        yield nextCount;
      }
    }
  }

  bool _chatListEquals(List<Chat> a, List<Chat> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].name != b[i].name ||
          a[i].lastMessage != b[i].lastMessage ||
          a[i].avatarUrl != b[i].avatarUrl ||
          a[i].lastMessageTime != b[i].lastMessageTime ||
          a[i].unreadCount != b[i].unreadCount ||
          a[i].isOnline != b[i].isOnline ||
          a[i].presenceStatus != b[i].presenceStatus) {
        return false;
      }
    }
    return true;
  }

  Stream<List<AegisRoomMessage>> watchRoomMessages(
    String roomId, {
    int limit = 100,
  }) async* {
    await ensureReady();
    await _ensureRoomMessagesLoaded(roomId);
    if ((_messages[roomId] ?? const <AegisRoomMessage>[]).length < limit) {
      try {
        await loadMessages(roomId: roomId, limit: limit);
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
    if (!_shouldExposeChatCache) {
      return const <Chat>[];
    }

    final items = _conversations.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items.map(_conversationToChat).toList();
  }

  int _currentUnreadChatsCount() {
    if (!_shouldExposeChatCache) {
      return 0;
    }

    var total = 0;
    for (final conversation in _conversations.values) {
      if (conversation.unreadCount > 0) {
        total++;
      }
    }
    return total;
  }

  Chat _conversationToChat(_StoredConversation conversation) {
    final lastMessage =
        conversation.lastMessage ??
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
        avatarUrl =
            normalizeAegisAvatarUrl(profile['avatarUrl']?.toString()) ??
            avatarUrl;
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
    final nextTitle = (info['displayName'] ?? info['username'])
        ?.toString()
        .trim();
    final nextAvatar = normalizeAegisAvatarUrl(info['avatarUrl']?.toString());

    // Use reverse index for O(1) lookup instead of iterating all conversations.
    final roomIds = _peerUserIdToRoomIds[userId];
    if (roomIds == null || roomIds.isEmpty) return false;

    for (final roomId in roomIds.toList(growable: false)) {
      final conversation = _conversations[roomId];
      if (conversation == null) continue;

      final updated = conversation.copyWith(
        title: (nextTitle?.isNotEmpty ?? false)
            ? nextTitle
            : conversation.title,
        avatarUrl: (nextAvatar?.isNotEmpty ?? false)
            ? nextAvatar
            : conversation.avatarUrl,
      );
      if (_storedConversationEquals(updated, conversation)) {
        continue;
      }
      _storeConversation(updated);
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
      return {'name': roomId, 'avatar': null};
    }
    final chat = _conversationToChat(room);
    return {'name': chat.name, 'avatar': chat.avatarUrl};
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
        _refreshRoomMessages(roomId, limit: limit)
            .then((changed) {
              if (changed) {
                _emitRoomChanged(roomId);
                _emitChanged();
              }
            })
            .catchError((_) {}),
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

  List<AegisRoomMessage> _roomMessagesSnapshot(
    String roomId, {
    int limit = 100,
  }) {
    final messages = _messages[roomId] ?? const <AegisRoomMessage>[];
    if (messages.length <= limit) {
      return List<AegisRoomMessage>.from(messages);
    }
    return List<AegisRoomMessage>.from(
      messages.sublist(messages.length - limit),
    );
  }

  Map<String, dynamic>? peekUserInfo(String userId) {
    final parsedId = int.tryParse(
      userId.replaceFirst('@', '').split(':').first,
    );
    if (parsedId == null) return null;
    return _profileCache[parsedId];
  }

  String _normalizeConversationKind(String rawType, {int? peerUserId}) {
    if (peerUserId != null) {
      return 'direct';
    }

    switch (rawType.trim().toLowerCase()) {
      case 'direct':
      case 'dm':
      case 'privatechat':
      case 'private_chat':
        return 'direct';
      case 'channel':
      case 'public':
      case 'broadcast':
        return 'channel';
      case 'group':
      case 'chat':
      case 'private':
      case 'private_group':
      case 'privategroup':
        return 'group';
      default:
        return rawType.trim().isEmpty ? 'channel' : rawType.trim().toLowerCase();
    }
  }

  Map<String, dynamic>? _conversationProfileFallback(int userId) {
    final roomIds = _peerUserIdToRoomIds[userId];
    if (roomIds == null || roomIds.isEmpty) {
      return null;
    }

    for (final roomId in roomIds) {
      final conversation = _conversations[roomId];
      if (conversation == null) {
        continue;
      }

      final title = conversation.title.trim();
      final avatarUrl = normalizeAegisAvatarUrl(conversation.avatarUrl);
      final hasTitle = title.isNotEmpty;
      final hasAvatar = avatarUrl?.isNotEmpty ?? false;
      if (!hasTitle && !hasAvatar) {
        continue;
      }

      return <String, dynamic>{
        'id': userId.toString(),
        'displayName': hasTitle ? title : userId.toString(),
        'avatarUrl': hasAvatar ? avatarUrl : null,
      };
    }

    return null;
  }

  bool _profileCacheNeedsRefresh(int userId, Map<String, dynamic> info) {
    final idText = userId.toString();
    final username = info['username']?.toString().trim() ?? '';
    final displayName = info['displayName']?.toString().trim() ?? '';
    final avatarUrl = normalizeAegisAvatarUrl(info['avatarUrl']?.toString());
    final avatars = info['avatars'];
    final bio = info['bio']?.toString().trim() ?? '';
    final location = info['location']?.toString().trim() ?? '';
    final birthday = info['birthday']?.toString().trim() ?? '';
    final email = info['email']?.toString().trim() ?? '';
    final presenceStatus = info['presenceStatus']?.toString().trim() ?? '';
    final lastSeenAt = info['lastSeenAt']?.toString().trim() ?? '';

    final hasRichFields =
        (avatarUrl?.isNotEmpty ?? false) ||
        (avatars is List && avatars.isNotEmpty) ||
        bio.isNotEmpty ||
        location.isNotEmpty ||
        birthday.isNotEmpty ||
        email.isNotEmpty ||
        presenceStatus.isNotEmpty ||
        lastSeenAt.isNotEmpty;

    final usernameLooksOpaque = username.isEmpty || username == idText;
    final displayNameLooksOpaque =
        displayName.isEmpty ||
        displayName == idText ||
        (displayName == username && usernameLooksOpaque);

    return usernameLooksOpaque && displayNameLooksOpaque && !hasRichFields;
  }

  bool _looksLikeOpaqueIdentity(
    String? value, {
    required int userId,
    String? username,
  }) {
    final text = value?.trim();
    if (text == null || text.isEmpty) {
      return true;
    }
    if (text == userId.toString()) {
      return true;
    }
    final normalizedUsername = username?.trim();
    if (normalizedUsername == null || normalizedUsername.isEmpty) {
      return false;
    }
    return text == normalizedUsername && RegExp(r'^\d+$').hasMatch(text);
  }

  bool _isAuthRejectionMessage(String? message) {
    final normalized = message?.toLowerCase().trim() ?? '';
    if (normalized.isEmpty) {
      return false;
    }
    return normalized.contains('not authenticated') ||
        normalized.contains('unauthorized') ||
        normalized.contains('auth.not_authenticated') ||
        normalized.contains('notauthenticatedexception');
  }

  bool _isUserNotFoundMessage(String? message) {
    final normalized = message?.toLowerCase().trim() ?? '';
    return normalized.contains('user not found');
  }

  Future<T> _retryAfterSessionRecovery<T>(Future<T> Function() action) async {
    await _auth.recoverSession();
    return action();
  }

  Future<T> _runAuthedRequest<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on Object catch (error) {
      if (_isAuthRejectionMessage(error.toString())) {
        return _retryAfterSessionRecovery(request);
      }
      rethrow;
    }
  }

  Future<T> _runAuthedSuccessRequest<T>(
    Future<T> Function() request, {
    required bool Function(T response) isSuccess,
    String? Function(T response)? messageOf,
  }) async {
    var response = await _runAuthedRequest(request);
    if (!isSuccess(response) && _isAuthRejectionMessage(messageOf?.call(response))) {
      response = await _retryAfterSessionRecovery(request);
    }
    return response;
  }

  Exception _profileResponseException(String? message, String fallback) {
    final normalized = message?.trim();
    return Exception(
      normalized == null || normalized.isEmpty ? fallback : normalized,
    );
  }

  Map<String, dynamic> _applyConversationProfileFallback(
    int userId,
    Map<String, dynamic> info,
  ) {
    final fallback = _conversationProfileFallback(userId);
    if (fallback == null) {
      return info;
    }

    final fallbackDisplayName = fallback['displayName']?.toString().trim();
    final fallbackAvatarUrl = fallback['avatarUrl']?.toString();
    final username = info['username']?.toString();
    final displayName = info['displayName']?.toString();
    final avatarUrl = info['avatarUrl']?.toString();

    return <String, dynamic>{
      ...info,
      if ((fallbackDisplayName?.isNotEmpty ?? false) &&
          _looksLikeOpaqueIdentity(
            displayName,
            userId: userId,
            username: username,
          ))
        'displayName': fallbackDisplayName,
      if ((avatarUrl == null || avatarUrl.isEmpty) &&
          (fallbackAvatarUrl?.isNotEmpty ?? false))
        'avatarUrl': fallbackAvatarUrl,
    };
  }

  void _seedProfileFromChatListItem(ChatListItem item) {
    final peerUserId = item.peerUserId;
    if (peerUserId == null) {
      return;
    }

    final existing = _profileCache[peerUserId];
    final seeded = <String, dynamic>{
      'id': peerUserId.toString(),
      'username': existing?['username']?.toString() ?? peerUserId.toString(),
      'displayName': item.title.trim().isNotEmpty
          ? item.title.trim()
          : existing?['displayName']?.toString() ?? peerUserId.toString(),
      'avatarUrl': normalizeAegisAvatarUrl(item.avatarUrl) ?? existing?['avatarUrl'],
      'avatars': existing?['avatars'] ?? const <Map<String, dynamic>>[],
      'presenceStatus': item.presenceStatus ?? existing?['presenceStatus'],
      'isOnline': item.presenceStatus == 'online' || existing?['isOnline'] == true,
      'bio': existing?['bio'],
      'location': existing?['location'],
      'birthday': existing?['birthday'],
      'email': existing?['email'],
      'lastSeenAt': existing?['lastSeenAt'],
    };

    _storeProfile(peerUserId, seeded);
  }

  Map<String, dynamic> _profileToInfo(dynamic profile) {
    return <String, dynamic>{
      'id': profile.id.toString(),
      'username': UserContentSanitizer.sanitizeUsername(profile.username),
      'displayName': UserContentSanitizer.sanitizeOptionalText(
            profile.displayName,
            maxLength: 120,
          ) ??
          UserContentSanitizer.sanitizeUsername(profile.username),
      'avatarUrl': normalizeAegisAvatarUrl(profile.avatarUrl),
      'avatars': profile.avatars
          .map(
            (avatar) => <String, dynamic>{
              'id': avatar.id,
              'avatarUrl': normalizeAegisAvatarUrl(avatar.avatarUrl),
              'isPrimary': avatar.isPrimary,
              'createdAt': avatar.createdAt.toIso8601String(),
            },
          )
          .toList(growable: false),
      'presenceStatus': profile.presenceStatus,
      'isOnline': profile.presenceStatus == 'online',
      'bio': UserContentSanitizer.sanitizeOptionalText(
        profile.bio,
        maxLength: 512,
      ),
      'location': UserContentSanitizer.sanitizeOptionalText(
        profile.location,
        maxLength: 120,
        preserveNewlines: false,
      ),
      'birthday': profile.birthDate,
      'email': UserContentSanitizer.sanitizeOptionalText(
        profile.email,
        maxLength: 160,
        preserveNewlines: false,
      ),
      'createdAt': profile.createdAt?.toIso8601String(),
      'lastSeenAt': profile.lastSeenAt?.toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> getUserInfo(
    String userId, {
    bool skipEnsureReady = false,
  }) async {
    if (!skipEnsureReady) {
      await ensureReady();
    }
    final parsedId = int.tryParse(
      userId.replaceFirst('@', '').split(':').first,
    );
    if (parsedId != null && _profileCache.containsKey(parsedId)) {
      final cached = _profileCache[parsedId]!;
      if (!_profileCacheNeedsRefresh(parsedId, cached)) {
        return cached;
      }
    }

    final cacheKey = parsedId?.toString() ?? userId;
    final pending = _userInfoRequests[cacheKey];
    if (pending != null) {
      return pending;
    }

    final request = () async {
      Future<ProfileGetResponse> sendRequest() async {
        if (parsedId != null) {
          return _auth.rawClient.getProfile(userId: parsedId);
        }
        final normalized = userId.replaceFirst('@', '').split(':').first;
        return _auth.rawClient.getProfile(username: normalized);
      }

      ProfileGetResponse response;
      try {
        response = await sendRequest();
      } on Object catch (error) {
        if (_isAuthRejectionMessage(error.toString())) {
          response = await _retryAfterSessionRecovery(sendRequest);
        } else {
          rethrow;
        }
      }

      if (!response.success) {
        if (_isAuthRejectionMessage(response.message)) {
          response = await _retryAfterSessionRecovery(sendRequest);
        }
        if (!response.success && !_isUserNotFoundMessage(response.message)) {
          throw _profileResponseException(
            response.message,
            'Unable to load profile',
          );
        }
      }

      final profile = response.profile;
      if (profile == null) {
        final fallback = parsedId == null
            ? null
            : _conversationProfileFallback(parsedId);
        return {
          'id': userId,
          'username': userId,
          'displayName': fallback?['displayName'] ?? userId,
          'avatarUrl': fallback?['avatarUrl'],
          'avatars': const <Map<String, dynamic>>[],
          'presenceStatus': null,
          'isOnline': false,
          'lastSeenAt': null,
        };
      }

      final info = _applyConversationProfileFallback(
        profile.id,
        _profileToInfo(profile),
      );
      _storeProfile(profile.id, info);
      final conversationChanged = _syncProfileIntoConversations(
        profile.id,
        info,
      );
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

  Future<Map<String, dynamic>> getOwnUserInfo({
    bool forceRefresh = false,
  }) async {
    await ensureReady();
    final selfId = _auth.userId;
    if (!forceRefresh && selfId != null) {
      final cached = _profileCache[selfId];
      if (cached != null && !_profileCacheNeedsRefresh(selfId, cached)) {
        return cached;
      }
    }

    Future<ProfileGetResponse> sendRequest() => _auth.rawClient.getOwnProfile();

    ProfileGetResponse response;
    try {
      response = await sendRequest();
    } on Object catch (error) {
      if (_isAuthRejectionMessage(error.toString())) {
        response = await _retryAfterSessionRecovery(sendRequest);
      } else {
        rethrow;
      }
    }

    if (!response.success) {
      if (_isAuthRejectionMessage(response.message)) {
        response = await _retryAfterSessionRecovery(sendRequest);
      }
      if (!response.success) {
        throw _profileResponseException(
          response.message,
          'Unable to load own profile',
        );
      }
    }

    final profile = response.profile;
    if (profile == null) {
      final userId = await getCurrentUserId();
      if (userId == null || userId.isEmpty) {
        return const <String, dynamic>{
          'id': '',
          'username': '',
          'displayName': '',
          'avatarUrl': null,
          'avatars': <Map<String, dynamic>>[],
          'presenceStatus': null,
          'isOnline': false,
          'bio': null,
          'email': null,
          'lastSeenAt': null,
        };
      }
      return getUserInfo(userId, skipEnsureReady: true);
    }

    final info = _profileToInfo(profile);
    _storeProfile(profile.id, info);
    final conversationChanged = _syncProfileIntoConversations(profile.id, info);
    unawaited(_persist());
    if (conversationChanged) {
      _emitChanged();
    }
    return info;
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
    _storeConversation(conversation);
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
    final response = await _runAuthedSuccessRequest(
      () => _auth.rawClient.createChannel(
        name,
        description: topic,
        type: isPublic ? ChannelType.public : ChannelType.private,
      ),
      isSuccess: (response) => response.success,
      messageOf: (response) => response.message,
    );
    final channelId = response.channelId > 0 ? response.channelId : null;
    if (!response.success || channelId == null) {
      throw Exception(response.message ?? 'Unable to create room');
    }
    final roomId = 'channel:$channelId';
    _storeConversation(
      _StoredConversation(
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
      ),
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
    int? replyToMessageId,
    void Function(double progress)? onMediaSendProgress,
  }) async {
    await _init();
    final conversation = _conversations[roomId];
    if (conversation == null) {
      throw Exception('Unknown conversation');
    }

    try {
      await ensureReady();
      final sentMessage = await _sendMessageNow(
        roomId: roomId,
        text: text,
        type: type,
        mediaFileId: mediaFileId,
        replyToMessageId: replyToMessageId,
        onMediaSendProgress: onMediaSendProgress,
      );
      unawaited(_refreshChatsFromServer());
      return sentMessage.id;
    } on Object catch (error) {
      if (!_shouldQueueSendFailure(error)) {
        rethrow;
      }

      final queuedMessage = await _queueOfflineMessage(
        roomId: roomId,
        text: text,
        type: type,
        mediaFileId: mediaFileId,
        replyToMessageId: replyToMessageId,
        error: error,
      );
      _log.warning('Message queued for offline delivery in $roomId: $error');
      return queuedMessage.id;
    }
  }

  Future<AegisRoomMessage> _sendMessageNow({
    required String roomId,
    required String text,
    required String type,
    String? mediaFileId,
    int? replyToMessageId,
    void Function(double progress)? onMediaSendProgress,
    String? replacingLocalMessageId,
  }) async {
    final conversation = _conversations[roomId];
    if (conversation == null) {
      throw Exception('Unknown conversation');
    }

    if (mediaFileId != null && mediaFileId.isNotEmpty && type != 'm.text') {
      final mediaFile = File(mediaFileId);
      if (!await mediaFile.exists()) {
        throw Exception('Media file not found');
      }

      final fileSize = await mediaFile.length();
      if (fileSize > _maxMediaUploadBytes) {
        throw Exception(
          'Media file too large: $fileSize bytes. '
          'Maximum allowed: $_maxMediaUploadBytes bytes (15MB).',
        );
      }

      onMediaSendProgress?.call(0.02);
      final bytes = await _readMediaFileWithProgress(
        mediaFile,
        onProgress: onMediaSendProgress,
      );
      final fileName = p.basename(mediaFile.path);
      final mimeType = _inferMimeType(fileName, type: type);
      final sentMessage = await _sendMediaMessage(
        roomId: roomId,
        bytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
        caption: text,
        messageType: type,
        onProgress: onMediaSendProgress,
        replacingLocalMessageId: replacingLocalMessageId,
      );
      onMediaSendProgress?.call(1);
      return sentMessage;
    }

    int? messageId;
    if (conversation.peerUserId != null || conversation.kind == 'direct') {
      final peerId = conversation.peerUserId;
      if (peerId == null) throw Exception('Missing peer user id');
      final response = await _runAuthedSuccessRequest(
        () => _auth.rawClient.sendPrivateMessage(
          peerId,
          mediaFileId ?? text,
        ),
        isSuccess: (response) => response.success,
        messageOf: (response) => response.messageText,
      );
      messageId = response.messageId > 0 ? response.messageId : null;
      if (!response.success) {
        throw Exception(
          _normalizeDirectSendError(response.messageText),
        );
      }
    } else if (conversation.kind == 'group') {
      final groupId = conversation.channelId;
      if (groupId == null) throw Exception('Missing group id');
      final response = await _runAuthedSuccessRequest(
        () => _auth.rawClient.sendGroupMessage(
          groupId,
          mediaFileId ?? text,
          replyToMessageId: replyToMessageId,
        ),
        isSuccess: (response) => response.success,
        messageOf: (response) => response.messageText,
      );
      messageId = response.messageId;
      if (!response.success) {
        throw Exception(response.messageText ?? 'Unable to send message');
      }
    } else {
      final channelId = conversation.channelId;
      if (channelId == null) throw Exception('Missing channel id');
      final response = await _runAuthedSuccessRequest(
        () => _auth.rawClient.sendChannelMessage(
          channelId,
          mediaFileId ?? text,
          replyToMessageId: replyToMessageId,
        ),
        isSuccess: (response) => response.success,
        messageOf: (response) => response.messageText,
      );
      messageId = response.messageId > 0 ? response.messageId : null;
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
      replyToMessageId: replyToMessageId,
    );
    if (replacingLocalMessageId != null) {
      await _replaceQueuedMessage(
        roomId,
        localMessageId: replacingLocalMessageId,
        sentMessage: message,
      );
    } else {
      await _appendMessage(roomId, message);
    }
    return message;
  }

  String _normalizeDirectSendError(String? serverMessage) {
    final raw = (serverMessage ?? '').trim();
    final normalized = raw.toLowerCase();

    if (normalized.isEmpty) {
      return 'Unable to send direct message';
    }

    if (normalized.contains('internal server error')) {
      return 'Direct messages are unavailable on the current server';
    }

    return raw;
  }

  Future<AegisRoomMessage> _sendMediaMessage({
    required String roomId,
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
    required String messageType,
    String? caption,
    void Function(double progress)? onProgress,
    String? replacingLocalMessageId,
  }) async {
    final conversation = _conversations[roomId];
    if (conversation == null) {
      throw Exception('Unknown conversation');
    }

    final chatType = switch (conversation.kind) {
      'direct' => ChatTargetType.private,
      'group' => ChatTargetType.group,
      _ => ChatTargetType.channel,
    };
    final chatId = conversation.kind == 'direct'
        ? conversation.peerUserId
        : conversation.channelId;
    if (chatId == null) {
      throw Exception('Missing chat target id');
    }

    final response = await _runAuthedSuccessRequest(
      () => _auth.rawClient.sendMedia(
        chatType: chatType,
        chatId: chatId,
        mediaBytes: bytes,
        mediaKind: _mapMediaKind(messageType, mimeType),
        caption: caption,
        fileName: fileName,
        mimeType: mimeType,
      ),
      isSuccess: (response) => response.success,
      messageOf: (response) => response.messageText,
    );
    if (!response.success) {
      throw Exception(response.messageText ?? 'Unable to send media');
    }

    onProgress?.call(0.98);
    final storedPath = await _storeMediaBytes(
      bytes,
      preferredFileName: '${response.messageId}_${_sanitizeFileName(fileName)}',
    );
    if (storedPath == null || storedPath.isEmpty) {
      throw Exception('Failed to store media file locally');
    }
    final message = AegisRoomMessage(
      id: response.messageId.toString(),
      senderId: (_auth.userId ?? 0).toString(),
      content: caption ?? '',
      time: DateTime.now(),
      type: messageType,
      mediaId: storedPath,
    );
    if (replacingLocalMessageId != null) {
      await _replaceQueuedMessage(
        roomId,
        localMessageId: replacingLocalMessageId,
        sentMessage: message,
      );
    } else {
      await _appendMessage(roomId, message);
    }
    return message;
  }

  Future<AegisRoomMessage> _queueOfflineMessage({
    required String roomId,
    required String text,
    required String type,
    required Object error,
    String? mediaFileId,
    int? replyToMessageId,
  }) async {
    final localMessageId =
        'local:${DateTime.now().microsecondsSinceEpoch}:${math.Random().nextInt(1 << 20)}';
    final queuedAt = DateTime.now();
    final roomMessage = AegisRoomMessage(
      id: localMessageId,
      senderId: (_auth.userId ?? 0).toString(),
      content: text,
      time: queuedAt,
      type: type,
      mediaId: mediaFileId,
      replyToMessageId: replyToMessageId,
    );

    await _appendMessage(roomId, roomMessage);
    await _offlineQueue.queueMessage(
      OfflineMessage(
        chatId: roomId,
        content: text,
        type: type,
        createdAt: queuedAt,
        localMessageId: localMessageId,
        mediaFileId: mediaFileId,
        replyToMessageId: replyToMessageId,
        errorMessage: error.toString(),
      ),
    );
    return roomMessage;
  }

  bool _shouldQueueSendFailure(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('notauthenticated') ||
        text.contains('not connected') ||
        text.contains('socket') ||
        text.contains('connection') ||
        text.contains('timeout') ||
        text.contains('timed out') ||
        text.contains('handshake') ||
        text.contains('broken pipe') ||
        text.contains('connection reset') ||
        text.contains('closed');
  }

  bool _isTransientQueueFailure(Object error) => _shouldQueueSendFailure(error);

  Future<void> _flushOfflineQueue() async {
    final inFlight = _offlineFlushInFlight;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final future = _flushOfflineQueueInternal();
    _offlineFlushInFlight = future;
    try {
      await future;
    } finally {
      if (identical(_offlineFlushInFlight, future)) {
        _offlineFlushInFlight = null;
      }
    }
  }

  Future<void> _flushOfflineQueueInternal() async {
    try {
      await _auth.ensureSession();
    } on Object catch (_) {
      return;
    }

    final pendingMessages = await _offlineQueue.getPendingMessages();
    if (pendingMessages.isEmpty) {
      return;
    }

    for (final queued in pendingMessages) {
      final recordId = queued.id;
      if (recordId == null) {
        continue;
      }

      try {
        final sentMessage = await _sendMessageNow(
          roomId: queued.chatId,
          text: queued.content,
          type: queued.type,
          mediaFileId: queued.mediaFileId,
          replyToMessageId: queued.replyToMessageId,
          replacingLocalMessageId: queued.localMessageId,
        );
        await _offlineQueue.removeMessage(recordId);
        _log.info(
          'Flushed offline message ${queued.localMessageId} -> ${sentMessage.id}',
        );
      } on Object catch (error) {
        await _offlineQueue.updateErrorMessage(recordId, error.toString());
        if (_isTransientQueueFailure(error)) {
          break;
        }

        final text = error.toString().toLowerCase();
        if (text.contains('unknown conversation') ||
            text.contains('media file not found') ||
            text.contains('missing chat target id') ||
            text.contains('missing peer user id') ||
            text.contains('missing channel id') ||
            text.contains('missing group id')) {
          _log.warning(
            'Dropping permanently failed offline message ${queued.localMessageId}: $error',
          );
          await _offlineQueue.removeMessage(recordId);
          if (queued.localMessageId != null) {
            await _removeLocalQueuedMessage(
              queued.chatId,
              queued.localMessageId!,
            );
          }
          continue;
        }

        break;
      }
    }
  }

  Future<void> _replaceQueuedMessage(
    String roomId, {
    required String localMessageId,
    required AegisRoomMessage sentMessage,
  }) async {
    final list = _messages.putIfAbsent(roomId, () => <AegisRoomMessage>[]);
    final existingIndex = list.indexWhere(
      (element) => element.id == localMessageId,
    );
    if (existingIndex >= 0) {
      list[existingIndex] = sentMessage;
    } else {
      list.add(sentMessage);
    }
    if (list.length > 1) {
      list.sort((a, b) => a.time.compareTo(b.time));
    }

    final room = _conversations[roomId];
    if (room != null) {
      _storeConversation(
        room.copyWith(
          updatedAt: sentMessage.time,
          lastMessage: sentMessage.content,
        ),
      );
    }

    _markMessageDirty(roomId, sentMessage);
    final deletedIds = _deletedMessageIdsByRoom[roomId];
    deletedIds?.remove(localMessageId);
    if (deletedIds != null && deletedIds.isEmpty) {
      _deletedMessageIdsByRoom.remove(roomId);
    }
    await _persist();
    _emitRoomChanged(roomId);
    _emitChanged();
  }

  Future<void> _removeLocalQueuedMessage(
    String roomId,
    String localMessageId,
  ) async {
    final list = _messages[roomId];
    if (list == null) {
      return;
    }
    list.removeWhere((message) => message.id == localMessageId);
    _markMessageDeleted(roomId, localMessageId);
    await _persist();
    _emitRoomChanged(roomId);
    _emitChanged();
  }

  Future<Uint8List> _readMediaFileWithProgress(
    File mediaFile, {
    void Function(double progress)? onProgress,
  }) async {
    final totalLength = await mediaFile.length();
    if (totalLength <= 0) {
      return mediaFile.readAsBytes();
    }

    const chunkSize = 64 * 1024;
    final builder = BytesBuilder(copy: false);
    final handle = await mediaFile.open();
    var loaded = 0;

    try {
      while (true) {
        final chunk = await handle.read(chunkSize);
        if (chunk.isEmpty) {
          break;
        }
        builder.add(chunk);
        loaded += chunk.length;
        final progress = (loaded * 82) / (totalLength * 100);
        onProgress?.call(progress.clamp(0.02, 0.82));
        await Future<void>.delayed(Duration.zero);
      }
    } finally {
      await handle.close();
    }

    return builder.takeBytes();
  }

  Future<void> sendReply(
    String roomId,
    String replyToId, {
    required String body,
    String? formattedBody,
  }) async {
    final replyToMessageId = _resolveCanonicalReplyToMessageId(
      roomId,
      replyToId,
    );
    if (replyToMessageId == null) {
      throw Exception(
        'Reply is only available after the original message is delivered',
      );
    }
    await sendMessage(
      roomId: roomId,
      text: body,
      replyToMessageId: replyToMessageId,
    );
  }

  int? _resolveCanonicalReplyToMessageId(String roomId, String replyToId) {
    final directId = int.tryParse(replyToId);
    if (directId != null && directId > 0) {
      return directId;
    }

    final roomMessages = _messages[roomId];
    if (roomMessages == null) {
      return null;
    }

    for (final message in roomMessages) {
      if (message.id != replyToId) {
        continue;
      }
      final canonicalId = int.tryParse(message.id);
      return canonicalId != null && canonicalId > 0 ? canonicalId : null;
    }

    return null;
  }

  Future<void> editMessage(
    String roomId,
    String eventId,
    String text, {
    String? formattedBody,
  }) async {
    await _runGuardedRoomOperation(roomId, () async {
      await ensureReady();
      final conversation = _conversations[roomId];
      final messageId = int.tryParse(eventId);
      if (conversation != null && messageId != null) {
        final response = await _auth.rawClient.editMessage(
          messageId,
          text,
          scope: conversation.kind == 'direct'
              ? 'private'
              : conversation.kind == 'group'
              ? 'group'
              : 'channel',
          channelId: conversation.kind == 'direct' || conversation.kind == 'group'
              ? null
              : conversation.channelId,
          groupId: conversation.kind == 'group' ? conversation.channelId : null,
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
        replyToMessageId: previous.replyToMessageId,
        isDelivered: previous.isDelivered,
        isRead: previous.isRead,
        deliveredAt: previous.deliveredAt,
        readAt: previous.readAt,
      );
      _markMessageDirty(roomId, list[index]);
      await _persist();
      _emitRoomChanged(roomId);
      _emitChanged();
    });
  }

  Future<void> redactEvent(String roomId, String eventId) async {
    await _runGuardedRoomOperation(roomId, () async {
      await ensureReady();
      final conversation = _conversations[roomId];
      final messageId = int.tryParse(eventId);
      if (conversation != null && messageId != null) {
        final response = await _auth.rawClient.deleteMessage(
          messageId,
          scope: conversation.kind == 'direct'
              ? 'private'
              : conversation.kind == 'group'
              ? 'group'
              : 'channel',
          channelId: conversation.kind == 'direct' || conversation.kind == 'group'
              ? null
              : conversation.channelId,
          groupId: conversation.kind == 'group' ? conversation.channelId : null,
        );
        if (!response.success) {
          throw Exception(response.message ?? 'Unable to delete message');
        }
      }
      _messages[roomId]?.removeWhere((element) => element.id == eventId);
      _markMessageDeleted(roomId, eventId);
      await _persist();
      _emitRoomChanged(roomId);
      _emitChanged();
    });
  }

  Future<void> sendReaction({
    required String roomId,
    required String eventId,
    required String reaction,
  }) async {
    await _runGuardedRoomOperation(roomId, () async {
      await ensureReady();
      final conversation = _conversations[roomId];
      final messageId = int.tryParse(eventId);
      if (conversation == null || messageId == null) {
        throw Exception('Unable to react to this message');
      }

      final response = await _auth.rawClient.postReaction(
        _roomScope(conversation),
        messageId,
        reaction,
      );
      if (!response.success) {
        throw Exception(response.message ?? 'Unable to update reactions');
      }

      _updateReactionCache(roomId, eventId, response.reactions);
      _emitRoomChanged(roomId);
    });
  }

  Future<Map<String, dynamic>> getReactions(
    String roomId,
    String eventId,
  ) async {
    await ensureReady();
    return Map<String, dynamic>.from(
      _roomReactions[roomId]?[eventId] ?? const <String, dynamic>{},
    );
  }

  Future<List<String>> getPinnedEvents(String roomId) async {
    await ensureReady();
    return List<String>.from(_pinnedEventIdsByRoom[roomId] ?? const <String>[]);
  }

  Future<void> setPinnedEvents(String roomId, List<String> eventIds) async {
    await _runGuardedRoomOperation(roomId, () async {
      await ensureReady();
      final conversation = _conversations[roomId];
      if (conversation == null || conversation.channelId == null) {
        throw Exception('Pinned messages are only available for rooms');
      }
      if (conversation.kind == 'direct') {
        throw Exception('Pinned messages are not supported in direct chats');
      }

      final current = Set<String>.from(
        _pinnedEventIdsByRoom[roomId] ?? const <String>[],
      );
      final target = eventIds.toSet();

      for (final eventId in target.difference(current)) {
        final messageId = int.tryParse(eventId);
        if (messageId == null) {
          continue;
        }
        final response = await _auth.rawClient.pinMessage(
          _roomScope(conversation),
          messageId,
          conversation.channelId!,
        );
        if (!response.success) {
          throw Exception(response.message ?? 'Unable to pin message');
        }
      }

      for (final eventId in current.difference(target)) {
        final messageId = int.tryParse(eventId);
        if (messageId == null) {
          continue;
        }
        final response = await _auth.rawClient.unpinMessage(
          _roomScope(conversation),
          messageId,
          conversation.channelId!,
        );
        if (!response.success) {
          throw Exception(response.message ?? 'Unable to unpin message');
        }
      }

      _setPinnedEventsCache(roomId, eventIds);
      _emitRoomChanged(roomId);
    });
  }

  Future<void> leaveRoom(String roomId) async {
    await ensureReady();
    final room = _conversations[roomId];
    if (room != null && room.kind != 'direct' && room.channelId != null) {
      if (room.kind == 'group') {
        final response = await _runAuthedSuccessRequest(
          () => _auth.rawClient.leaveGroup(room.channelId!),
          isSuccess: (response) => response.success,
          messageOf: (response) => response.message,
        );
        if (!response.success) {
          throw Exception(response.message ?? 'Unable to leave group');
        }
      } else {
        final response = await _runAuthedSuccessRequest(
          () => _auth.rawClient.leaveChannel(room.channelId!),
          isSuccess: (response) => response.success,
          messageOf: (response) => response.message,
        );
        if (!response.success) {
          throw Exception(response.message ?? 'Unable to leave room');
        }
      }
    }
    if (room?.peerUserId != null) {
      final peerUserId = room!.peerUserId!;
      final roomIds = _peerUserIdToRoomIds[peerUserId];
      roomIds?.remove(roomId);
      if (roomIds != null && roomIds.isEmpty) {
        _peerUserIdToRoomIds.remove(peerUserId);
      }
    }
    if (_conversations.remove(roomId) != null) {
      _markConversationsDirty();
    }
    _messages.remove(roomId);
    _roomReactions.remove(roomId);
    _pinnedEventIdsByRoom.remove(roomId);
    _messageAccessOrder.remove(roomId);
    _dirtyMessagesByRoom.remove(roomId);
    _deletedMessageIdsByRoom.remove(roomId);
    _deletedRoomIds.add(roomId);
    _storedRoomIds.remove(roomId);
    _hydratedRoomIds.remove(roomId);
    final controller = _roomChanges.remove(roomId);
    _roomEmitTimers.remove(roomId)?.cancel();
    await controller?.close();
    await _persist();
    _emitChanged();
  }

  void _handleMessageStatusEvent(MessageStatusEvent event) {
    if (!event.success || event.messageIds.isEmpty) {
      return;
    }

    final processedAt = event.processedAt ?? DateTime.now();
    final updatedRooms = <String>{};

    for (final entry in _messages.entries) {
      final roomId = entry.key;
      final list = entry.value;
      var roomUpdated = false;

      for (var index = 0; index < list.length; index++) {
        final message = list[index];
        final messageId = int.tryParse(message.id);
        if (messageId == null || !event.messageIds.contains(messageId)) {
          continue;
        }

        final nextDelivered = message.isDelivered || event.isDeliveredUpdate;
        final nextRead = message.isRead || event.isReadUpdate;
        final nextDeliveredAt =
            message.deliveredAt ??
            (event.isDeliveredUpdate ? processedAt : null);
        final nextReadAt =
            message.readAt ?? (event.isReadUpdate ? processedAt : null);

        if (nextDelivered == message.isDelivered &&
            nextRead == message.isRead &&
            nextDeliveredAt == message.deliveredAt &&
            nextReadAt == message.readAt) {
          continue;
        }

        list[index] = AegisRoomMessage(
          id: message.id,
          senderId: message.senderId,
          content: message.content,
          time: message.time,
          type: message.type,
          mediaId: message.mediaId,
          replyToMessageId: message.replyToMessageId,
          isDelivered: nextDelivered,
          isRead: nextRead,
          deliveredAt: nextDeliveredAt,
          readAt: nextReadAt,
        );
        _markMessageDirty(roomId, list[index]);
        roomUpdated = true;
      }

      if (roomUpdated) {
        updatedRooms.add(roomId);
      }
    }

    if (updatedRooms.isEmpty) {
      return;
    }

    unawaited(_persist());
    for (final roomId in updatedRooms) {
      _emitRoomChanged(roomId);
    }
    _emitChanged();
  }

  void _handleReadSyncEvent(ReadSyncEventPayload event) {
    if (event.messageIds.isEmpty) {
      return;
    }

    _handleMessageStatusEvent(
      MessageStatusEvent(
        success: true,
        messageIds: event.messageIds,
        processedAt: event.readAt,
      ),
    );
  }

  Future<void> setRoomName(String roomId, String name) async {
    await ensureReady();
    final conversation = _conversations[roomId];
    if (conversation == null) return;
    if (conversation.channelId != null) {
      if (conversation.kind == 'group') {
        final response = await _runAuthedSuccessRequest(
          () => _auth.rawClient.updateGroup(
            conversation.channelId!,
            name: name,
          ),
          isSuccess: (response) => response.success,
          messageOf: (response) => response.message,
        );
        if (!response.success) {
          throw Exception(response.message ?? 'Unable to rename room');
        }
      } else {
        final response = await _runAuthedSuccessRequest(
          () => _auth.rawClient.updateChannel(
            conversation.channelId!,
            name: name,
          ),
          isSuccess: (response) => response.success,
          messageOf: (response) => response.message,
        );
        if (!response.success) {
          throw Exception(response.message ?? 'Unable to rename room');
        }
      }
    }
    _storeConversation(
      conversation.copyWith(title: name, updatedAt: DateTime.now()),
    );
    await _persist();
    _emitChanged();
  }

  Future<void> setRoomDescription(String roomId, String? description) async {
    await ensureReady();
    final conversation = _conversations[roomId];
    if (conversation == null) return;

    if (conversation.channelId != null) {
      if (conversation.kind == 'group') {
        final response = await _runAuthedSuccessRequest(
          () => _auth.rawClient.updateGroup(
            conversation.channelId!,
            description: description,
          ),
          isSuccess: (response) => response.success,
          messageOf: (response) => response.message,
        );
        if (!response.success) {
          throw Exception(
            response.message ?? 'Unable to update room description',
          );
        }
      } else {
        final response = await _runAuthedSuccessRequest(
          () => _auth.rawClient.updateChannel(
            conversation.channelId!,
            description: description,
          ),
          isSuccess: (response) => response.success,
          messageOf: (response) => response.message,
        );
        if (!response.success) {
          throw Exception(
            response.message ?? 'Unable to update room description',
          );
        }
      }
    }

    _storeConversation(
      conversation.copyWith(
        description: description,
        updatedAt: DateTime.now(),
      ),
    );
    await _persist();
    _emitChanged();
  }

  Future<void> updateRoomDetails(
    String roomId, {
    String? name,
    String? description,
  }) async {
    await ensureReady();
    final conversation = _conversations[roomId];
    if (conversation == null) return;

    if (conversation.channelId != null) {
      if (conversation.kind == 'group') {
        final response = await _runAuthedSuccessRequest(
          () => _auth.rawClient.updateGroup(
            conversation.channelId!,
            name: name,
            description: description,
          ),
          isSuccess: (response) => response.success,
          messageOf: (response) => response.message,
        );
        if (!response.success) {
          throw Exception(response.message ?? 'Unable to update room');
        }
      } else {
        final response = await _runAuthedSuccessRequest(
          () => _auth.rawClient.updateChannel(
            conversation.channelId!,
            name: name,
            description: description,
          ),
          isSuccess: (response) => response.success,
          messageOf: (response) => response.message,
        );
        if (!response.success) {
          throw Exception(response.message ?? 'Unable to update room');
        }
      }
    }

    _storeConversation(
      conversation.copyWith(
        title: name ?? conversation.title,
        description: description,
        updatedAt: DateTime.now(),
      ),
    );
    await _persist();
    _emitChanged();
  }

  Future<String> setRoomAvatar(
    String roomId,
    dynamic bytes, {
    String? fileName,
  }) async {
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
    final resolvedMimeType = _inferMimeType(target.path, type: 'm.image');
    await target.writeAsBytes(payloadBytes);
    final conversation = _conversations[roomId];
    if (conversation != null) {
      if (conversation.channelId != null) {
        if (conversation.kind == 'group') {
          final response = await _runAuthedSuccessRequest(
            () => _auth.rawClient.uploadGroupAvatar(
              conversation.channelId!,
              Uint8List.fromList(payloadBytes),
              mimeType: resolvedMimeType,
            ),
            isSuccess: (response) => response.success,
            messageOf: (response) => response.message,
          );
          if (!response.success) {
            throw Exception(response.message ?? 'Unable to update room avatar');
          }
        } else {
          final response = await _runAuthedSuccessRequest(
            () => _auth.rawClient.uploadChannelAvatar(
              conversation.channelId!,
              Uint8List.fromList(payloadBytes),
              mimeType: resolvedMimeType,
            ),
            isSuccess: (response) => response.success,
            messageOf: (response) => response.message,
          );
          if (!response.success) {
            throw Exception(response.message ?? 'Unable to update room avatar');
          }
        }
      }
      _storeConversation(
        conversation.copyWith(
          avatarUrl: target.path,
          updatedAt: DateTime.now(),
        ),
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
    return _storeMediaBytes(
      bytes,
      preferredFileName:
          '${DateTime.now().microsecondsSinceEpoch}_${_sanitizeFileName(fileName)}',
    );
  }

  Future<String> downloadMediaToTempFile(String mediaId) async {
    final normalizedId = mediaId.trim();
    if (normalizedId.isEmpty) {
      throw Exception('Media id is empty');
    }

    final cachedPath = _mediaPathCache[normalizedId];
    if (cachedPath != null && await File(cachedPath).exists()) {
      return cachedPath;
    }

    final inFlight = _mediaResolveInFlight[normalizedId];
    if (inFlight != null) {
      return inFlight;
    }

    final resolveFuture = () async {
      if (normalizedId.startsWith('data:')) {
        final inlineBytes = UriData.parse(normalizedId).contentAsBytes();
        final stableFileName =
            'inline_${normalizedId.hashCode.abs()}_${inlineBytes.length}.bin';
        final storedPath = await _storeMediaBytes(
          inlineBytes,
          preferredFileName: stableFileName,
        );
        if (storedPath != null && storedPath.isNotEmpty) {
          _mediaPathCache[normalizedId] = storedPath;
          return storedPath;
        }
      }

      final file = File(normalizedId);
      if (await file.exists()) {
        _mediaPathCache[normalizedId] = file.path;
        return file.path;
      }
      throw Exception('Media file not found');
    }();

    _mediaResolveInFlight[normalizedId] = resolveFuture;
    try {
      return await resolveFuture;
    } finally {
      _mediaResolveInFlight.remove(normalizedId);
    }
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
                    {'type': 'm.room.message'},
                  ],
                },
              },
          },
        },
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

  Future<List<Map<String, dynamic>>> getRoomMembers(
    String roomId, {
    bool forceRefresh = false,
  }) async {
    await _init();
    final room = _conversations[roomId];
    if (room == null) return const <Map<String, dynamic>>[];
    if (room.kind == 'group' && room.channelId != null) {
      final response = await _runAuthedSuccessRequest(
        () => _auth.rawClient.getGroupMembers(room.channelId!),
        isSuccess: (response) => response.success,
        messageOf: (response) => response.message,
      );
      if (!response.success) {
        throw Exception(response.message ?? 'Unable to load group members');
      }
      _storeConversation(
        room.copyWith(
          memberUserIds: response.members
              .map((member) => member.userId.toString())
              .toList(growable: false),
          updatedAt: DateTime.now(),
        ),
      );
      return Future.wait(response.members.map(_memberSummaryToRoomMemberMap));
    }
    if (room.kind != 'direct' && room.channelId != null) {
      final response = await _runAuthedSuccessRequest(
        () => _auth.rawClient.getChannelMembers(room.channelId!),
        isSuccess: (response) => response.success,
        messageOf: (response) => response.message,
      );
      if (!response.success) {
        throw Exception(response.message ?? 'Unable to load channel members');
      }
      _storeConversation(
        room.copyWith(
          memberUserIds: response.members
              .map((member) => member.userId.toString())
              .toList(growable: false),
          updatedAt: DateTime.now(),
        ),
      );
      return Future.wait(response.members.map(_memberSummaryToRoomMemberMap));
    }
    final ids = room.memberUserIds;
    // Fetch all members in parallel with bounded concurrency.
    final results = await Future.wait(
      ids.map((id) async {
        try {
          final info = await getUserInfo(id);
          return {
            'userId': id,
            'displayName': info['displayName'] ?? info['username'] ?? id,
            'avatarUrl': info['avatarUrl'],
          };
        } catch (_) {
          return {'userId': id, 'displayName': id, 'avatarUrl': null};
        }
      }),
    );
    return results;
  }

  Future<void> refreshChats({bool force = false}) async {
    await ensureReady();
    final bootstrapChanged = await _ensureChatBootstrap();
    final changed =
        bootstrapChanged || await _refreshChatsFromServer(force: force);
    if (changed) {
      _emitChanged();
    }
  }

  Future<void> refreshChatIndex({
    int messageLimit = 50,
    int preloadRooms = 6,
  }) async {
    try {
      await ensureReady();
    } on NotAuthenticatedException {
      return;
    }

    var changed = false;
    changed = await _refreshChatsFromServer(force: true) || changed;
    if (changed) {
      _emitChanged();
    }

    if (preloadRooms <= 0 || messageLimit <= 0) {
      return;
    }

    // Lazy background refresh of top rooms — don't block caller
    final roomsToRefresh =
        (_conversations.values.toList()
              ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)))
            .take(preloadRooms)
            .map((conversation) => conversation.id)
            .toList(growable: false);

    unawaited(_refreshRoomsBatch(roomsToRefresh, messageLimit));
  }

  Future<void> _refreshRoomsBatch(List<String> roomIds, int limit) async {
    const batchSize = 3;
    for (var i = 0; i < roomIds.length; i += batchSize) {
      final batch = roomIds.sublist(
        i,
        (i + batchSize).clamp(0, roomIds.length),
      );
      final results = await Future.wait<bool>(
        batch.map(
          (id) =>
              _refreshRoomMessages(id, limit: limit).catchError((_) => false),
        ),
      );
      if (results.any((v) => v)) {
        _emitChanged();
      }
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

  Future<void> setActiveRoom(String? roomId) async {
    await ensureReady();
    _activeRoomId = roomId;
    if (roomId != null && roomId.isNotEmpty) {
      await markRoomRead(roomId);
    }
  }

  Future<void> markRoomRead(String roomId) async {
    await ensureReady();
    final room = _conversations[roomId];
    if (room == null) {
      return;
    }

    final selfUserId = (_auth.userId ?? 0).toString();
    final list = _messages[roomId] ?? const <AegisRoomMessage>[];
    final unreadIds = <int>[];
    var updatedAnyMessage = false;
    final now = DateTime.now();

    for (var index = 0; index < list.length; index++) {
      final message = list[index];
      if (message.senderId == selfUserId) {
        continue;
      }

      final parsedId = int.tryParse(message.id);
      if (parsedId != null && !message.isRead) {
        unreadIds.add(parsedId);
      }

      if (message.isRead) {
        continue;
      }

      list[index] = AegisRoomMessage(
        id: message.id,
        senderId: message.senderId,
        content: message.content,
        time: message.time,
        type: message.type,
        mediaId: message.mediaId,
        replyToMessageId: message.replyToMessageId,
        isDelivered: true,
        isRead: true,
        deliveredAt: message.deliveredAt ?? now,
        readAt: message.readAt ?? now,
      );
      _markMessageDirty(roomId, list[index]);
      updatedAnyMessage = true;
    }

    if (updatedAnyMessage || room.unreadCount != 0) {
      _storeConversation(room.copyWith(unreadCount: 0));
      unawaited(_persist());
      _emitRoomChanged(roomId);
      _emitChanged();
    }

    if (unreadIds.isNotEmpty) {
      unawaited(() async {
        try {
          await _runAuthedRequest(
            () => _auth.rawClient.sendReadReceipt(unreadIds),
          );
        } catch (_) {}
      }());
    }
  }

  Future<void> setJoinRule(String roomId, String rule) async {
    final normalized = switch (rule) {
      'public' => 0,
      'approval' => 2,
      _ => 1,
    };
    await setJoinRuleValue(roomId, normalized);
  }

  Future<void> setJoinRuleValue(String roomId, int joinRule) async {
    await _init();
    final room = _conversations[roomId];
    if (room == null) return;
    if (room.channelId != null && room.kind != 'direct') {
      final response = await _runAuthedSuccessRequest(
        () => _auth.rawClient.updateRoomSettings(
          _roomScope(room),
          room.channelId!,
          joinRule: joinRule,
        ),
        isSuccess: (response) => response.success,
        messageOf: (response) => response.message,
      );
      if (!response.success) {
        throw Exception(response.message ?? 'Unable to update room visibility');
      }
    }
    _storeConversation(
      room.copyWith(isPublic: joinRule == 0, updatedAt: DateTime.now()),
    );
    await _persist();
    _emitChanged();
  }

  Future<Map<String, dynamic>> getRoomSettingsState(String roomId) async {
    await ensureReady();
    final room = _conversations[roomId];
    if (room == null || room.channelId == null || room.kind == 'direct') {
      return {
        'joinRule': (room?.isPublic ?? false) ? 0 : 1,
        'historyVisibility': (room?.showMessageHistory ?? false) ? 1 : 2,
      };
    }

    final response = await _runAuthedSuccessRequest(
      () => _auth.rawClient.getRoomSettings(
        _roomScope(room),
        room.channelId!,
      ),
      isSuccess: (response) => response.success,
      messageOf: (response) => response.message,
    );
    if (!response.success) {
      throw Exception(response.message ?? 'Unable to load room settings');
    }

    _storeConversation(
      room.copyWith(
        isPublic: response.joinRule == 0,
        showMessageHistory: response.historyVisibility != 2,
        updatedAt: DateTime.now(),
      ),
    );
    return {
      'joinRule': response.joinRule,
      'historyVisibility': response.historyVisibility,
    };
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
      response = await _runAuthedSuccessRequest(
        () => _auth.rawClient.updateChannelLinks(
          room.channelId!,
          publicAlias: room.isPublic
              ? _buildChannelAlias(room.title, room.channelId!)
              : null,
          regeneratePrivateInvite: regeneratePrivateInvite,
        ),
        isSuccess: (response) => response.success,
        messageOf: (response) => response.message,
      );
    } else {
      response = await _runAuthedSuccessRequest(
        () => _auth.rawClient.getChannelLinks(room.channelId!),
        isSuccess: (response) => response.success,
        messageOf: (response) => response.message,
      );
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

  Future<void> updateRoomPublicAlias(String roomId, String publicAlias) async {
    await ensureReady();
    final room = _conversations[roomId];
    if (room == null || room.channelId == null || !room.isPublic) {
      throw Exception('Links are only available for public channels');
    }

    final response = await _runAuthedSuccessRequest(
      () => _auth.rawClient.updateChannelLinks(
        room.channelId!,
        publicAlias: publicAlias.trim(),
      ),
      isSuccess: (response) => response.success,
      messageOf: (response) => response.message,
    );
    if (!response.success) {
      throw Exception(response.message ?? 'Unable to update room link');
    }
  }

  Future<Map<String, dynamic>> resolveRoomLink(String linkOrAlias) async {
    await ensureReady();
    final response = await _runAuthedSuccessRequest(
      () => _auth.rawClient.resolveChannelLink(
        linkOrAlias.trim(),
      ),
      isSuccess: (response) => response.success,
      messageOf: (response) => response.message,
    );
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
    final response = await _runAuthedSuccessRequest(
      () => _auth.rawClient.joinChannelByLink(
        linkOrAlias.trim(),
      ),
      isSuccess: (response) => response.success,
      messageOf: (response) => response.message,
    );
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
    _storeConversation(
      _StoredConversation(
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
      ),
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

  Future<void> clearRoomCache(String roomId) async {
    await _init();
    if (!_purgeRoomState(roomId)) {
      return;
    }
    await _persist();
    _emitRoomChanged(roomId);
    _emitChanged();
  }

  Future<void> flushNow() => _flushPersistNow();

  Future<List<double>> getWaveformForMedia(
    String mediaId,
    String? localPath, {
    int samples = 50,
  }) async {
    final targetSamples = samples.clamp(12, 72);
    var resolvedPath = localPath;
    if (resolvedPath == null || resolvedPath.isEmpty) {
      if (mediaId.isEmpty) {
        return const <double>[];
      }
      try {
        resolvedPath = await downloadMediaToTempFile(mediaId);
      } catch (_) {
        return const <double>[];
      }
    }

    final file = File(resolvedPath);
    if (!await file.exists()) {
      return const <double>[];
    }

    return Isolate.run(() {
      final bytes = file.readAsBytesSync();
      if (bytes.isEmpty) {
        return const <double>[];
      }

      final skipLead = math.min(bytes.length ~/ 12, 4096);
      final skipTail = math.min(bytes.length ~/ 20, 2048);
      final startOffset = math.max(0, math.min(skipLead, bytes.length - 1));
      final endOffset = math.max(startOffset + 1, bytes.length - skipTail);
      final usableLength = endOffset - startOffset;
      final blockSize = math.max(1, usableLength ~/ targetSamples);
      final waveform = <double>[];
      for (var index = 0; index < targetSamples; index++) {
        final start = startOffset + (index * blockSize);
        if (start >= endOffset) {
          break;
        }
        final end = math.min(endOffset, start + blockSize);
        var total = 0.0;
        for (var offset = start; offset < end; offset++) {
          total += (bytes[offset] - 128).abs() / 128;
        }
        final average = total / math.max(1, end - start);
        waveform.add(average.clamp(0.05, 1.0));
      }

      if (waveform.isEmpty) {
        return const <double>[];
      }

      final peak = waveform.reduce(math.max);
      if (peak <= 0) {
        return List<double>.filled(waveform.length, 0.18);
      }

      final normalized = waveform
          .map((value) => (value / peak).clamp(0.08, 1.0))
          .toList(growable: false);
      final smoothed = <double>[];
      for (var index = 0; index < normalized.length; index++) {
        final previous = index > 0 ? normalized[index - 1] : normalized[index];
        final current = normalized[index];
        final next = index < normalized.length - 1
            ? normalized[index + 1]
            : normalized[index];
        smoothed.add(((previous + current + next) / 3).clamp(0.08, 1.0));
      }
      return smoothed;
    });
  }

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
    List<int>? avatarBytes,
    String? avatarFileName,
  }) async {
    await ensureReady();
    final response = await _runAuthedSuccessRequest(
      () => _auth.rawClient.createGroup(
        name,
        description: description,
      ),
      isSuccess: (response) => response.success,
      messageOf: (response) => response.message,
    );
    final groupId = response.groupId > 0 ? response.groupId : null;
    if (!response.success || groupId == null) {
      throw Exception(response.message ?? '');
    }
    final roomId = 'channel:$groupId';
    final me = (_auth.userId ?? 0).toString();
    _storeConversation(
      _StoredConversation(
        id: roomId,
        title: name,
        kind: 'group',
        updatedAt: DateTime.now(),
        description: description,
        channelId: groupId,
        isPublic: visibility == GroupVisibility.public,
        showMessageHistory: showMessageHistory,
        memberUserIds: <String>[me],
      ),
    );
    final settingsResponse = await _runAuthedSuccessRequest(
      () => _auth.rawClient.updateRoomSettings(
        'group',
        groupId,
        joinRule: visibility == GroupVisibility.public ? 0 : 1,
        historyVisibility: showMessageHistory ? 1 : 2,
      ),
      isSuccess: (response) => response.success,
      messageOf: (response) => response.message,
    );
    if (!settingsResponse.success) {
      throw Exception(
        settingsResponse.message ?? 'Unable to initialize group settings',
      );
    }
    if (avatarBytes != null && avatarBytes.isNotEmpty) {
      await setRoomAvatar(roomId, avatarBytes, fileName: avatarFileName);
    }
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
      visibility: room.isPublic
          ? GroupVisibility.public
          : GroupVisibility.private,
      currentUserRole: GroupRole.owner,
      memberCount: room.memberUserIds.length,
      showMessageHistory: room.showMessageHistory,
      createdAt: room.updatedAt,
      updatedAt: room.updatedAt,
      members: room.memberUserIds
          .map(
            (id) => GroupMember(
              userId: id,
              displayName:
                  _profileCache[int.tryParse(id) ?? -1]?['displayName']
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

  Future<GroupRoom?> loadGroupRoom(String roomId) async {
    await ensureReady();
    final room = _conversations[roomId];
    if (room == null || room.kind != 'group' || room.channelId == null) {
      return getGroupRoom(roomId);
    }

    final settings = await _runAuthedSuccessRequest(
      () => _auth.rawClient.getRoomSettings(
        'group',
        room.channelId!,
      ),
      isSuccess: (response) => response.success,
      messageOf: (response) => response.message,
    );
    if (!settings.success) {
      throw Exception(settings.message ?? 'Unable to load group settings');
    }

    final membersResponse = await _runAuthedSuccessRequest(
      () => _auth.rawClient.getGroupMembers(
        room.channelId!,
      ),
      isSuccess: (response) => response.success,
      messageOf: (response) => response.message,
    );
    if (!membersResponse.success) {
      throw Exception(
        membersResponse.message ?? 'Unable to load group members',
      );
    }

    final memberIds = membersResponse.members
        .map((member) => member.userId.toString())
        .toList(growable: false);
    final updatedRoom = room.copyWith(
      isPublic: settings.joinRule == 0,
      showMessageHistory: settings.historyVisibility != 2,
      memberUserIds: memberIds,
      updatedAt: DateTime.now(),
    );
    _storeConversation(updatedRoom);

    final members = await Future.wait(
      membersResponse.members.map((member) async {
        final info = await _memberSummaryToRoomMemberMap(member);
        return GroupMember(
          userId: info['userId'] as String,
          displayName: info['displayName'] as String,
          avatarUrl: info['avatarUrl'] as String?,
          role: _mapMemberRole(member.role),
          joinedAt: member.joinedAt,
        );
      }),
    );

    final currentUserId = (_auth.userId ?? 0).toString();
    final currentUserRole = members
        .firstWhere(
          (member) => member.userId == currentUserId,
          orElse: () => GroupMember(
            userId: currentUserId,
            displayName: currentUserId,
            role: GroupRole.member,
            joinedAt: updatedRoom.updatedAt,
          ),
        )
        .role;

    await _persist();
    _emitChanged();
    return GroupRoom(
      roomId: updatedRoom.id,
      name: updatedRoom.title,
      description: updatedRoom.description,
      avatarUrl: updatedRoom.avatarUrl,
      visibility: updatedRoom.isPublic
          ? GroupVisibility.public
          : GroupVisibility.private,
      currentUserRole: currentUserRole,
      memberCount: members.length,
      showMessageHistory: updatedRoom.showMessageHistory,
      createdAt: updatedRoom.updatedAt,
      updatedAt: updatedRoom.updatedAt,
      members: members,
    );
  }

  Future<void> setShowMessageHistory(String roomId, bool value) async {
    await setHistoryVisibility(roomId, value ? 1 : 2);
  }

  Future<void> setHistoryVisibility(
    String roomId,
    int historyVisibility,
  ) async {
    await ensureReady();
    final room = _conversations[roomId];
    if (room == null) return;
    if (room.channelId != null && room.kind != 'direct') {
      final response = await _runAuthedSuccessRequest(
        () => _auth.rawClient.updateRoomSettings(
          _roomScope(room),
          room.channelId!,
          historyVisibility: historyVisibility,
        ),
        isSuccess: (response) => response.success,
        messageOf: (response) => response.message,
      );
      if (!response.success) {
        throw Exception(
          response.message ?? 'Unable to update history visibility',
        );
      }
    }
    _storeConversation(
      room.copyWith(
        showMessageHistory: historyVisibility != 2,
        updatedAt: DateTime.now(),
      ),
    );
    await _persist();
    _emitChanged();
  }

  Future<void> setUserRole(String roomId, String userId, GroupRole role) async {
    await ensureReady();
    final room = _conversations[roomId];
    final targetUserId = int.tryParse(userId);
    if (room?.channelId == null || targetUserId == null) return;
    final targetId = room!.channelId!;

    final response = await _runAuthedSuccessRequest(
      () => _auth.rawClient.updateMemberRole(
        scope: _roomScope(room),
        targetId: targetId,
        targetUserId: targetUserId,
        newRole: _mapGroupRole(role),
      ),
      isSuccess: (response) => response.success,
      messageOf: (response) => response.message,
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
    final targetId = room!.channelId!;

    final response = await _runAuthedSuccessRequest(
      () => _auth.rawClient.updateMemberPermissions(
        scope: _roomScope(room),
        targetId: targetId,
        targetUserId: targetUserId,
        canSendMessages: false,
      ),
      isSuccess: (response) => response.success,
      messageOf: (response) => response.message,
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
    final targetId = room!.channelId!;

    final response = await _runAuthedSuccessRequest(
      () => _auth.rawClient.updateMemberPermissions(
        scope: _roomScope(room),
        targetId: targetId,
        targetUserId: targetUserId,
        canSendMessages: false,
        canInviteUsers: false,
        canEditInfo: false,
        canPinMessages: false,
      ),
      isSuccess: (response) => response.success,
      messageOf: (response) => response.message,
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
    final targetId = room!.channelId!;

    final response = await _runAuthedSuccessRequest(
      () => _auth.rawClient.updateMemberPermissions(
        scope: _roomScope(room),
        targetId: targetId,
        targetUserId: targetUserId,
        canSendMessages: true,
        canInviteUsers: true,
        canEditInfo: true,
        canPinMessages: true,
      ),
      isSuccess: (response) => response.success,
      messageOf: (response) => response.message,
    );
    if (!response.success) {
      throw Exception(response.message ?? 'Unable to restore member access');
    }
  }

  Future<void> kickUser(String roomId, String userId) async {
    await ensureReady();
    final room = _conversations[roomId];
    final targetUserId = int.tryParse(userId);
    if (room == null) return;

    if (room.channelId != null && targetUserId != null) {
      final response = await _runAuthedSuccessRequest(
        () => _auth.rawClient.updateMemberPermissions(
          scope: _roomScope(room),
          targetId: room.channelId!,
          targetUserId: targetUserId,
          canSendMessages: false,
          canInviteUsers: false,
          canEditInfo: false,
          canPinMessages: false,
        ),
        isSuccess: (response) => response.success,
        messageOf: (response) => response.message,
      );
      if (!response.success) {
        throw Exception(response.message ?? 'Unable to remove member');
      }
    }

    _conversations[roomId] = room.copyWith(
      memberUserIds: room.memberUserIds.where((e) => e != userId).toList(),
      updatedAt: DateTime.now(),
    );
    await _persist();
    _emitChanged();
  }

  Future<void> deleteGroup(String roomId) async {
    throw const AegisFeatureInDevelopmentException(
      'Group deletion is not supported by the server yet',
    );
  }

  Future<Map<String, dynamic>> updateMyProfile({
    String? displayName,
    String? bio,
    String? username,
    String? avatarUrl,
    String? location,
    String? birthDate,
  }) async {
    await ensureReady();
    Future<ProfileUpdateResponse> sendRequest() => _auth.rawClient.updateProfile(
      displayName: displayName,
      bio: bio,
      username: username,
      avatarUrl: avatarUrl,
      location: location,
      birthDate: birthDate,
    );

    ProfileUpdateResponse response;
    try {
      response = await sendRequest();
    } on Object catch (error) {
      if (_isAuthRejectionMessage(error.toString())) {
        response = await _retryAfterSessionRecovery(sendRequest);
      } else {
        rethrow;
      }
    }

    if (!response.success) {
      if (_isAuthRejectionMessage(response.message)) {
        response = await _retryAfterSessionRecovery(sendRequest);
      }
      if (!response.success) {
        throw _profileResponseException(
          response.message,
          'Unable to update profile',
        );
      }
    }

    if (response.profile != null) {
      final profile = response.profile!;
      final info = _profileToInfo(profile);
      _storeProfile(profile.id, info);
      _syncProfileIntoConversations(profile.id, info);
      await _persist();
      _emitChanged();
      return info;
    }

    return getOwnUserInfo(forceRefresh: true);
  }

  Future<Map<String, dynamic>> uploadMyAvatar(
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    await ensureReady();
    final response = await _runAuthedSuccessRequest(
      () => _auth.rawClient.uploadUserAvatar(
        imageBytes,
        mimeType: mimeType,
      ),
      isSuccess: (response) => response.success,
      messageOf: (response) => response.message,
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

    final info = _profileToInfo(profile);
    _storeProfile(profile.id, info);
    _syncProfileIntoConversations(profile.id, info);
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
    // Deduplicate: skip if message with same id already exists
    final existingIndex = list.indexWhere((e) => e.id == message.id);
    if (existingIndex >= 0) {
      // Update existing message content if changed
      final existing = list[existingIndex];
      if (existing.content == message.content &&
          existing.type == message.type) {
        return; // No change, skip
      }
      list[existingIndex] = message;
    } else {
      list.add(message);
      if (list.length > 1 && list[list.length - 2].time.isAfter(message.time)) {
        list.sort((a, b) => a.time.compareTo(b.time));
      }
    }
    final room = _conversations[roomId];
    if (room != null) {
      final isIncomingForInactiveRoom =
          message.senderId != (_auth.userId ?? 0).toString() &&
          _activeRoomId != roomId;
      _storeConversation(
        room.copyWith(
          updatedAt: message.time,
          lastMessage: message.content,
          unreadCount: isIncomingForInactiveRoom
              ? room.unreadCount + 1
              : (_activeRoomId == roomId ? 0 : room.unreadCount),
        ),
      );
    }
    _storedRoomIds.add(roomId);
    _hydratedRoomIds.add(roomId);
    _markMessageDirty(roomId, message);
    await _persist();
    _emitRoomChanged(roomId);
    _emitChanged();
  }

  void _markMessageDirty(String roomId, AegisRoomMessage message) {
    _dirtyMessagesByRoom.putIfAbsent(
      roomId,
      () => <String, AegisRoomMessage>{},
    )[message.id] = message;
    final deletedIds = _deletedMessageIdsByRoom[roomId];
    if (deletedIds != null) {
      deletedIds.remove(message.id);
      if (deletedIds.isEmpty) {
        _deletedMessageIdsByRoom.remove(roomId);
      }
    }
  }

  void _markMessageDeleted(String roomId, String messageId) {
    final dirtyMessages = _dirtyMessagesByRoom[roomId];
    if (dirtyMessages != null) {
      dirtyMessages.remove(messageId);
      if (dirtyMessages.isEmpty) {
        _dirtyMessagesByRoom.remove(roomId);
      }
    }
    _deletedMessageIdsByRoom
        .putIfAbsent(roomId, () => <String>{})
        .add(messageId);
  }

  void _handleIncomingMessage(Message message) {
    if (message.type != MessageType.privateChatMessageEvent &&
        message.type != MessageType.groupMessageEvent &&
        message.type != MessageType.channelMessageEvent &&
        message.type != MessageType.messageReactionEvent &&
        message.type != MessageType.messagePinEvent &&
        message.type != MessageType.privateChatMessage &&
        message.type != MessageType.channelMessage) {
      return;
    }
    try {
      if (message.type == MessageType.privateChatMessageEvent ||
          message.type == MessageType.privateChatMessage) {
        final event = PrivateChatMessageEvent.fromBytes(message.payload);
        final me = _auth.userId;
        final peerId = event.fromUserId == me
            ? event.toUserId
            : event.fromUserId;
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
        unawaited(() async {
          final roomMessage = await _historyItemToRoomMessage(
            messageId: event.id.toString(),
            senderId: event.fromUserId.toString(),
            content: event.content,
            contentType: event.contentType,
            createdAt: event.createdAt,
            replyToMessageId: event.replyToMessageId,
            isDelivered: event.deliveredTo.isNotEmpty,
            isRead: event.readBy.isNotEmpty,
          );
          await _appendMessage(roomId, roomMessage);
          if (event.fromUserId != me) {
            final messageId = int.tryParse(roomMessage.id);
            if (messageId != null && messageId > 0) {
              try {
                await _runAuthedRequest(
                  () => _auth.rawClient.sendDeliveryReceipt(<int>[messageId]),
                );
              } catch (_) {}
            }
            if (_activeRoomId == roomId) {
              await markRoomRead(roomId);
            }
          }
        }());
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
            title: event.channelName ?? channelId.toString(),
            kind: 'channel',
            updatedAt: event.createdAt,
            channelId: channelId,
            memberUserIds: <String>[event.fromUserId.toString()],
          ),
        );
        unawaited(() async {
          final roomMessage = await _historyItemToRoomMessage(
            messageId: event.id.toString(),
            senderId: event.fromUserId.toString(),
            content: event.content,
            contentType: event.contentType,
            createdAt: event.createdAt,
            replyToMessageId: event.replyToMessageId,
            isDelivered: event.deliveredTo.isNotEmpty,
            isRead: event.readBy.isNotEmpty,
          );
          await _appendMessage(roomId, roomMessage);
          if (event.fromUserId != _auth.userId) {
            final messageId = int.tryParse(roomMessage.id);
            if (messageId != null && messageId > 0) {
              try {
                await _runAuthedRequest(
                  () => _auth.rawClient.sendDeliveryReceipt(<int>[messageId]),
                );
              } catch (_) {}
            }
            if (_activeRoomId == roomId) {
              await markRoomRead(roomId);
            }
          }
        }());
      }

      if (message.type == MessageType.groupMessageEvent) {
        final event = GroupMessageEvent.fromBytes(message.payload);
        final roomId = 'channel:${event.groupId}';
        _conversations.putIfAbsent(
          roomId,
          () => _StoredConversation(
            id: roomId,
            title: event.groupName ?? event.groupId.toString(),
            kind: 'group',
            updatedAt: event.createdAt,
            channelId: event.groupId,
            memberUserIds: <String>[event.fromUserId.toString()],
          ),
        );
        unawaited(() async {
          final roomMessage = await _historyItemToRoomMessage(
            messageId: event.id.toString(),
            senderId: event.fromUserId.toString(),
            content: event.content,
            contentType: event.contentType,
            createdAt: event.createdAt,
          );
          await _appendMessage(roomId, roomMessage);
          if (event.fromUserId != _auth.userId) {
            final messageId = int.tryParse(roomMessage.id);
            if (messageId != null && messageId > 0) {
              try {
                await _runAuthedRequest(
                  () => _auth.rawClient.sendDeliveryReceipt(<int>[messageId]),
                );
              } catch (_) {}
            }
            if (_activeRoomId == roomId) {
              await markRoomRead(roomId);
            }
          }
        }());
      }

      if (message.type == MessageType.messageReactionEvent) {
        final event = MessageReactionEvent.fromBytes(message.payload);
        final roomId = _findRoomIdByMessageId(event.messageId);
        if (roomId != null) {
          _updateReactionCache(
            roomId,
            event.messageId.toString(),
            event.reactions,
          );
          _emitRoomChanged(roomId);
        }
      }

      if (message.type == MessageType.messagePinEvent) {
        final event = MessagePinEvent.fromBytes(message.payload);
        final roomId = _roomIdForScope(event.scope, event.targetId);
        if (roomId != null) {
          final current = List<String>.from(
            _pinnedEventIdsByRoom[roomId] ?? const <String>[],
          );
          final eventId = event.messageId.toString();
          current.remove(eventId);
          if (event.pinned) {
            current.insert(0, eventId);
          }
          _setPinnedEventsCache(roomId, current);
          _emitRoomChanged(roomId);
        }
      }
    } catch (_) {}
  }

  String _lastMessage(String roomId) {
    final list = _messages[roomId];
    if (list == null || list.isEmpty) return '';
    return list.last.content;
  }

  bool _isUnavailableRoomError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('user not found') ||
        text.contains('not a member of this channel') ||
        text.contains('not a member of this group') ||
        text.contains('not a member of this room') ||
        text.contains('unknown conversation') ||
        text.contains('conversation not found') ||
        text.contains('chat not found') ||
        text.contains('room not found') ||
        text.contains('channel not found') ||
        text.contains('group not found');
  }

  Future<bool> _clearRoomIfUnavailable(String roomId, Object error) async {
    if (!_conversations.containsKey(roomId) || !_isUnavailableRoomError(error)) {
      return false;
    }
    _log.warning(
      'Clearing stale room cache for $roomId after server rejection: $error',
    );
    await clearRoomCache(roomId);
    unawaited(_refreshChatsQuietly());
    return true;
  }

  Future<T> _runGuardedRoomOperation<T>(
    String roomId,
    Future<T> Function() operation, {
    String unavailableMessage = 'Chat is no longer available and was removed from cache',
  }) async {
    try {
      return await operation();
    } on Object catch (error) {
      if (_isAuthRejectionMessage(error.toString())) {
        try {
          await _auth.recoverSession();
          return await operation();
        } on Object catch (recoveredError) {
          if (await _clearRoomIfUnavailable(roomId, recoveredError)) {
            throw Exception(unavailableMessage);
          }
          rethrow;
        }
      }
      if (await _clearRoomIfUnavailable(roomId, error)) {
        throw Exception(unavailableMessage);
      }
      rethrow;
    }
  }

  Future<bool> _refreshChatsFromServer({bool force = false}) async {
    final inFlight = _chatRefreshInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final now = DateTime.now();
    if (!force && _lastChatRefreshAt != null) {
      final age = now.difference(_lastChatRefreshAt!);
      if (age < _chatRefreshCooldown) {
        return false;
      }
    }

    final future = () async {
      final response = await _runAuthedSuccessRequest(
        () => _auth.rawClient.getChatList(),
        isSuccess: (response) => response.success,
        messageOf: (response) => response.message,
      );
      if (!response.success) {
        throw Exception(response.message ?? 'Unable to load chat list');
      }

      final me = (_auth.userId ?? 0).toString();
      var changed = false;
      final directPeerIds = <String>{};
      final seenRoomIds = <String>{};

      for (final item in response.chats) {
        _seedProfileFromChatListItem(item);
        final roomId = item.peerUserId != null
            ? 'dm:${item.peerUserId}'
            : 'channel:${item.channelId ?? item.chatId}';
        seenRoomIds.add(roomId);
        if (item.peerUserId != null) {
          directPeerIds.add(item.peerUserId.toString());
        }
        final existing = _conversations[roomId];
        final next = _StoredConversation(
          id: roomId,
          title: item.title,
          kind: _normalizeConversationKind(
            item.type,
            peerUserId: item.peerUserId,
          ),
          updatedAt:
              item.lastMessageAt ?? existing?.updatedAt ?? DateTime.now(),
          lastMessage: item.lastMessage ?? existing?.lastMessage,
          unreadCount: item.unreadCount,
          avatarUrl:
              normalizeAegisAvatarUrl(item.avatarUrl) ?? existing?.avatarUrl,
          description: existing?.description,
          peerUserId: item.peerUserId ?? existing?.peerUserId,
          peerUsername: existing?.peerUsername,
          channelId: item.peerUserId != null
              ? existing?.channelId
              : (item.channelId ?? item.chatId),
          isPublic: existing?.isPublic ?? item.type == 'channel',
          showMessageHistory: existing?.showMessageHistory ?? false,
          memberUserIds: (existing?.memberUserIds.isNotEmpty ?? false)
              ? existing!.memberUserIds
              : <String>[
                  if (me != '0') me,
                  if (item.peerUserId != null) item.peerUserId.toString(),
                ],
        );

        if (existing == null || !_storedConversationEquals(existing, next)) {
          _storeConversation(next);
          changed = true;
        }
      }

      final staleRoomIds = _conversations.keys
          .where((roomId) => !seenRoomIds.contains(roomId))
          .toList(growable: false);
      for (final roomId in staleRoomIds) {
        if (_purgeRoomState(roomId)) {
          changed = true;
        }
      }

      if (directPeerIds.isNotEmpty) {
        final missingProfileIds = directPeerIds
            .where(
              (peerId) =>
                  !_profileCache.containsKey(int.tryParse(peerId) ?? -1),
            )
            .toList(growable: false);
        const batchSize = 6;
        for (
          var index = 0;
          index < missingProfileIds.length;
          index += batchSize
        ) {
          final end = (index + batchSize).clamp(0, missingProfileIds.length);
          final chunk = missingProfileIds.sublist(index, end);
          await Future.wait(
            chunk.map(
              (peerId) => getUserInfo(
                peerId,
                skipEnsureReady: true,
              ).catchError((_) => <String, dynamic>{}),
            ),
          );
        }
      }

      if (changed) {
        await _persist();
      }
      _lastChatRefreshAt = DateTime.now();
      return changed;
    }();

    _chatRefreshInFlight = future;
    try {
      return await future;
    } finally {
      if (identical(_chatRefreshInFlight, future)) {
        _chatRefreshInFlight = null;
      }
    }
  }

  Future<bool> _refreshRoomMessages(String roomId, {int limit = 100}) async {
    await _ensureRoomMessagesLoaded(roomId);
    final conversation = _conversations[roomId];
    if (conversation == null) return false;

    List<AegisRoomMessage> nextMessages;
    try {
      if (conversation.kind == 'direct' && conversation.peerUserId != null) {
        final response = await _runAuthedSuccessRequest(
          () => _auth.rawClient.getPrivateHistory(
            conversation.peerUserId!,
            limit: limit,
          ),
          isSuccess: (response) => response.success,
          messageOf: (response) => response.message,
        );
        if (!response.success) {
          throw Exception(response.message ?? 'Unable to load direct messages');
        }
        nextMessages = await Future.wait(
          response.messages.map((item) {
            final status = _extractHistoryStatus(item);
            return _historyItemToRoomMessage(
              messageId: item.id.toString(),
              senderId: item.fromUserId.toString(),
              content: item.content,
              contentType: item.contentType,
              createdAt: item.createdAt,
              replyToMessageId: _extractHistoryReplyToMessageId(item),
              isDelivered: status.$1,
              isRead: status.$2,
              deliveredAt: status.$3,
              readAt: status.$4,
            );
          }),
        );
      } else if (conversation.kind == 'group' && conversation.channelId != null) {
        final response = await _runAuthedSuccessRequest(
          () => _auth.rawClient.getGroupHistory(
            conversation.channelId!,
            limit: limit,
          ),
          isSuccess: (response) => response.success,
          messageOf: (response) => response.message,
        );
        if (!response.success) {
          throw Exception(response.message ?? 'Unable to load room history');
        }
        nextMessages = await Future.wait(
          response.messages.map((item) {
            final status = _extractHistoryStatus(item);
            return _historyItemToRoomMessage(
              messageId: item.id.toString(),
              senderId: item.fromUserId.toString(),
              content: item.content,
              contentType: item.contentType,
              createdAt: item.createdAt,
              replyToMessageId: _extractHistoryReplyToMessageId(item),
              isDelivered: status.$1,
              isRead: status.$2,
              deliveredAt: status.$3,
              readAt: status.$4,
            );
          }),
        );
        _setPinnedEventsCache(
          roomId,
          response.messages
              .where((item) => item.isPinned)
              .map((item) => item.id.toString())
              .toList(growable: false),
        );
      } else if (conversation.channelId != null) {
        final response = await _runAuthedSuccessRequest(
          () => _auth.rawClient.getChannelHistory(
            conversation.channelId!,
            limit: limit,
          ),
          isSuccess: (response) => response.success,
          messageOf: (response) => response.message,
        );
        if (!response.success) {
          throw Exception(response.message ?? 'Unable to load room history');
        }
        nextMessages = await Future.wait(
          response.messages.map((item) {
            final status = _extractHistoryStatus(item);
            return _historyItemToRoomMessage(
              messageId: item.id.toString(),
              senderId: item.fromUserId.toString(),
              content: item.content,
              contentType: item.contentType,
              createdAt: item.createdAt,
              replyToMessageId: _extractHistoryReplyToMessageId(item),
              isDelivered: status.$1,
              isRead: status.$2,
              deliveredAt: status.$3,
              readAt: status.$4,
            );
          }),
        );
      } else {
        return false;
      }
    } on Object catch (error) {
      if (await _clearRoomIfUnavailable(roomId, error)) {
        throw Exception('Chat is no longer available and was removed from cache');
      }
      rethrow;
    }

    nextMessages.sort((a, b) => a.time.compareTo(b.time));
    final currentMessages = _messages[roomId] ?? const <AegisRoomMessage>[];
    if (_sameMessages(currentMessages, nextMessages)) {
      return false;
    }
    _messages[roomId] = nextMessages;
    _storedRoomIds.add(roomId);
    _hydratedRoomIds.add(roomId);
    _markMessageBatchDirty(roomId, currentMessages, nextMessages);
    await _persist();
    return true;
  }

  void _markMessageBatchDirty(
    String roomId,
    List<AegisRoomMessage> current,
    List<AegisRoomMessage> next,
  ) {
    if (next.isEmpty) {
      return;
    }

    final currentById = <String, AegisRoomMessage>{
      for (final message in current) message.id: message,
    };
    for (final message in next) {
      final existing = currentById[message.id];
      if (existing == null || !_sameMessage(existing, message)) {
        _markMessageDirty(roomId, message);
      }
    }
  }

  bool _sameMessage(AegisRoomMessage left, AegisRoomMessage right) {
    return left.id == right.id &&
        left.content == right.content &&
        left.time == right.time &&
        left.type == right.type &&
        left.mediaId == right.mediaId &&
        left.replyToMessageId == right.replyToMessageId &&
        left.senderId == right.senderId &&
        left.isDelivered == right.isDelivered &&
        left.isRead == right.isRead &&
        left.deliveredAt == right.deliveredAt &&
        left.readAt == right.readAt;
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
      if (!_sameMessage(left, right)) {
        return false;
      }
    }
    return true;
  }

  (bool, bool, DateTime?, DateTime?) _extractHistoryStatus(dynamic item) {
    Map<String, dynamic> payload;
    try {
      payload = Map<String, dynamic>.from((item as dynamic).toJson() as Map);
    } catch (_) {
      return (false, false, null, null);
    }

    bool readBool(String lower, String upper) =>
        payload[lower] as bool? ?? payload[upper] as bool? ?? false;

    DateTime? readDate(String lower, String upper) {
      final value = payload[lower] ?? payload[upper];
      if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    bool readList(String lower, String upper) {
      final value = payload[lower] ?? payload[upper];
      return value is List && value.isNotEmpty;
    }

    return (
      readBool('isDelivered', 'IsDelivered') ||
          readList('deliveredTo', 'DeliveredTo'),
      readBool('isRead', 'IsRead') || readList('readBy', 'ReadBy'),
      readDate('deliveredAt', 'DeliveredAt'),
      readDate('readAt', 'ReadAt'),
    );
  }

  int? _extractHistoryReplyToMessageId(dynamic item) {
    Map<String, dynamic> payload;
    try {
      payload = Map<String, dynamic>.from((item as dynamic).toJson() as Map);
    } catch (_) {
      return null;
    }

    final value = payload['replyToMessageId'] ?? payload['ReplyToMessageId'];
    return (value as num?)?.toInt();
  }

  Future<Map<String, dynamic>> _memberSummaryToRoomMemberMap(
    MemberSummary member,
  ) async {
    final cached = _profileCache[member.userId];
    if (cached == null) {
      try {
        final info = await getUserInfo(member.userId.toString());
        _storeProfile(member.userId, info);
      } catch (_) {}
    }
    final profile = _profileCache[member.userId];
    return {
      'userId': member.userId.toString(),
      'displayName': profile?['displayName'] ?? member.username,
      'avatarUrl': profile?['avatarUrl'],
      'role': member.role,
      'joinedAt': member.joinedAt.toIso8601String(),
      'canSendMessages': member.canSendMessages,
      'canDeleteOthersMessages': member.canDeleteOthersMessages,
      'canPinMessages': member.canPinMessages,
      'canManageRoles': member.canManageRoles,
    };
  }

  GroupRole _mapMemberRole(String role) {
    switch (role.trim().toLowerCase()) {
      case 'owner':
        return GroupRole.owner;
      case 'admin':
      case 'moderator':
        return GroupRole.admin;
      case 'guest':
        return GroupRole.guest;
      default:
        return GroupRole.member;
    }
  }

  String _roomScope(_StoredConversation room) {
    switch (room.kind) {
      case 'group':
        return 'group';
      case 'direct':
        return 'private';
      default:
        return 'channel';
    }
  }

  String? _roomIdForScope(String scope, int targetId) {
    switch (scope) {
      case 'group':
      case 'channel':
        return 'channel:$targetId';
      default:
        return null;
    }
  }

  String? _findRoomIdByMessageId(int messageId) {
    final targetId = messageId.toString();
    for (final entry in _messages.entries) {
      if (entry.value.any((message) => message.id == targetId)) {
        return entry.key;
      }
    }
    return null;
  }

  void _updateReactionCache(
    String roomId,
    String eventId,
    List<ReactionCount> reactions,
  ) {
    final normalized = <String, dynamic>{
      for (final reaction in reactions)
        reaction.emoji: <String, dynamic>{
          'count': reaction.count,
          if (reaction.byMe) 'myEventId': 'remote',
        },
    };
    final roomReactions = _roomReactions.putIfAbsent(
      roomId,
      () => <String, Map<String, dynamic>>{},
    );
    roomReactions[eventId] = normalized;
  }

  void _setPinnedEventsCache(String roomId, List<String> eventIds) {
    _pinnedEventIdsByRoom[roomId] = List<String>.from(eventIds);
  }

  bool _storedConversationEquals(
    _StoredConversation left,
    _StoredConversation right,
  ) {
    if (identical(left, right)) return true;
    return left.id == right.id &&
        left.title == right.title &&
        left.kind == right.kind &&
        left.updatedAt == right.updatedAt &&
        left.lastMessage == right.lastMessage &&
        left.unreadCount == right.unreadCount &&
        left.avatarUrl == right.avatarUrl &&
        left.description == right.description &&
        left.peerUserId == right.peerUserId &&
        left.peerUsername == right.peerUsername &&
        left.channelId == right.channelId &&
        left.isPublic == right.isPublic &&
        left.showMessageHistory == right.showMessageHistory &&
        _listEquals(left.memberUserIds, right.memberUserIds);
  }

  bool _listEquals(List<dynamic> left, List<dynamic> right) {
    if (identical(left, right)) return true;
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (!_dynamicEquals(left[index], right[index])) {
        return false;
      }
    }
    return true;
  }

  bool _dynamicEquals(dynamic left, dynamic right) {
    if (identical(left, right)) return true;
    if (left is Map && right is Map) {
      if (left.length != right.length) return false;
      for (final key in left.keys) {
        if (!right.containsKey(key)) return false;
        if (!_dynamicEquals(left[key], right[key])) return false;
      }
      return true;
    }
    if (left is List && right is List) {
      return _listEquals(left, right);
    }
    return left == right;
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

  Future<AegisRoomMessage> _historyItemToRoomMessage({
    required String messageId,
    required String senderId,
    required String content,
    required MessageContentType contentType,
    required DateTime createdAt,
    int? replyToMessageId,
    bool isDelivered = false,
    bool isRead = false,
    DateTime? deliveredAt,
    DateTime? readAt,
  }) async {
    final attachment = tryParseMediaAttachment(content, contentType);
    String? mediaId;
    var resolvedContent = content;

    if (attachment != null) {
      resolvedContent = (attachment.text?.trim().isNotEmpty ?? false)
          ? attachment.text!.trim()
          : attachment.fileName;
      mediaId = _buildInlineMediaDataUri(
        mimeType: attachment.mimeType,
        base64Data: attachment.base64Data,
      );
    }

    return AegisRoomMessage(
      id: messageId,
      senderId: senderId,
      content: resolvedContent,
      time: createdAt,
      type: _mapMessageType(contentType),
      mediaId: mediaId,
      replyToMessageId: replyToMessageId,
      isDelivered: isDelivered,
      isRead: isRead,
      deliveredAt: deliveredAt,
      readAt: readAt,
    );
  }

  String _buildInlineMediaDataUri({
    required String mimeType,
    required String base64Data,
  }) {
    final normalizedMimeType = mimeType.trim().isEmpty
        ? 'application/octet-stream'
        : mimeType.trim();
    return 'data:$normalizedMimeType;base64,$base64Data';
  }

  Future<String?> _storeMediaBytes(
    List<int> bytes, {
    required String preferredFileName,
  }) async {
    await _init();
    if (bytes.isEmpty) {
      throw Exception('Media bytes are empty');
    }
    final mediaDir = Directory(p.join(_storeDir.path, 'aegis_media'));
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    final target = File(p.join(mediaDir.path, preferredFileName));
    if (await target.exists()) {
      final currentLength = await target.length();
      if (currentLength == bytes.length) {
        return target.path;
      }
    }
    await target.writeAsBytes(bytes, flush: true);
    return target.path;
  }

  Future<void> _cleanupMediaCache() async {
    try {
      await _init();
      final mediaDir = Directory(p.join(_storeDir.path, 'aegis_media'));
      if (!await mediaDir.exists()) {
        return;
      }

      final entities = await mediaDir
          .list()
          .where((entity) => entity is File)
          .cast<File>()
          .toList();

      final now = DateTime.now();
      var totalBytes = 0;
      final survivors = <_MediaCacheEntry>[];

      for (final file in entities) {
        try {
          final stat = await file.stat();
          final age = now.difference(stat.modified);
          if (age > _mediaCacheMaxAge) {
            await file.delete();
            continue;
          }
          totalBytes += stat.size;
          survivors.add(
            _MediaCacheEntry(
              file: file,
              size: stat.size,
              modified: stat.modified,
            ),
          );
        } catch (_) {}
      }

      if (totalBytes > _mediaCacheMaxBytes) {
        survivors.sort(
          (left, right) => left.modified.compareTo(right.modified),
        );
        for (final entry in survivors) {
          if (totalBytes <= _mediaCacheMaxBytes) {
            break;
          }
          try {
            await entry.file.delete();
            totalBytes -= entry.size;
          } catch (_) {}
        }
      }

      _mediaPathCache.removeWhere((_, value) => !File(value).existsSync());
    } catch (_) {}
  }

  String _sanitizeFileName(String value) {
    final cleaned = value.replaceAll(RegExp('[^a-zA-Z0-9._-]+'), '_');
    return cleaned.isEmpty ? 'file.bin' : cleaned;
  }

  String _inferMimeType(String fileName, {String? type}) {
    final lower = fileName.toLowerCase();
    if (type == 'm.audio' || lower.endsWith('.ogg') || lower.endsWith('.m4a')) {
      return lower.endsWith('.m4a') ? 'audio/mp4' : 'audio/ogg';
    }
    if (type == 'm.video' || lower.endsWith('.mp4') || lower.endsWith('.mov')) {
      return lower.endsWith('.mov') ? 'video/quicktime' : 'video/mp4';
    }
    if (type == 'm.image' ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp')) {
      if (lower.endsWith('.png')) return 'image/png';
      if (lower.endsWith('.gif')) return 'image/gif';
      if (lower.endsWith('.webp')) return 'image/webp';
      return 'image/jpeg';
    }
    return 'application/octet-stream';
  }

  MediaKind _mapMediaKind(String messageType, String mimeType) {
    if (messageType == 'm.audio' || mimeType.startsWith('audio/')) {
      return MediaKind.voice;
    }
    if (messageType == 'm.video' || mimeType.startsWith('video/')) {
      return MediaKind.video;
    }
    if (messageType == 'm.image' || mimeType.startsWith('image/')) {
      return MediaKind.photo;
    }
    return MediaKind.file;
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
      _persistDebounce,
      () => unawaited(_flushPersistNow()),
    );
  }

  Future<void> _flushPersistNow() async {
    _persistTimer?.cancel();
    _persistTimer = null;
    final inFlight = _persistInFlight;
    if (inFlight != null) {
      _persistQueuedWhileWriting = true;
      await inFlight;
      return;
    }

    if (!_conversationsDirty &&
        !_profilesDirty &&
        _dirtyMessagesByRoom.isEmpty &&
        _deletedMessageIdsByRoom.isEmpty &&
        _deletedRoomIds.isEmpty) {
      return;
    }

    final dirtyMessagesByRoom = <String, Map<String, AegisRoomMessage>>{
      for (final entry in _dirtyMessagesByRoom.entries)
        entry.key: Map<String, AegisRoomMessage>.from(entry.value),
    };
    final deletedMessageIdsByRoom = <String, Set<String>>{
      for (final entry in _deletedMessageIdsByRoom.entries)
        entry.key: Set<String>.from(entry.value),
    };
    final deletedRoomIds = Set<String>.from(_deletedRoomIds);
    final writeConversations = _conversationsDirty;
    final writeProfiles = _profilesDirty;
    _persistQueuedWhileWriting = false;

    final future = () async {
      await _init();
      final upsertMessagesJsonByRoomId = <String, List<Map<String, dynamic>>>{};
      for (final entry in dirtyMessagesByRoom.entries) {
        if (deletedRoomIds.contains(entry.key) || entry.value.isEmpty) {
          continue;
        }
        final messages = entry.value.values.toList(growable: false);
        upsertMessagesJsonByRoomId[entry.key] = await Isolate.run(() {
          return messages
              .map((message) => message.toJson())
              .toList(growable: false);
        });
      }

      await _localStore.saveChanges(
        conversationsJson: writeConversations
            ? _conversations.values.map((c) => c.toJson())
            : const <Map<String, dynamic>>[],
        profilesJsonByUserId: writeProfiles
            ? Map<int, Map<String, dynamic>>.from(_profileCache)
            : const <int, Map<String, dynamic>>{},
        upsertMessagesJsonByRoomId: upsertMessagesJsonByRoomId,
        deletedMessageIdsByRoomId: deletedMessageIdsByRoom,
        deletedRoomIds: deletedRoomIds,
        writeConversations: writeConversations,
        writeProfiles: writeProfiles,
      );
    }();

    _persistInFlight = future;
    try {
      await future;
      for (final entry in dirtyMessagesByRoom.entries) {
        final currentDirty = _dirtyMessagesByRoom[entry.key];
        if (currentDirty == null) {
          continue;
        }
        currentDirty.removeWhere(
          (messageId, _) => entry.value.containsKey(messageId),
        );
        if (currentDirty.isEmpty) {
          _dirtyMessagesByRoom.remove(entry.key);
        }
      }
      for (final entry in deletedMessageIdsByRoom.entries) {
        final currentDeleted = _deletedMessageIdsByRoom[entry.key];
        if (currentDeleted == null) {
          continue;
        }
        currentDeleted.removeAll(entry.value);
        if (currentDeleted.isEmpty) {
          _deletedMessageIdsByRoom.remove(entry.key);
        }
      }
      _deletedRoomIds.removeAll(deletedRoomIds);
      if (writeConversations) {
        _conversationsDirty = false;
      }
      if (writeProfiles) {
        _profilesDirty = false;
      }
    } finally {
      if (identical(_persistInFlight, future)) {
        _persistInFlight = null;
      }
      if (_persistQueuedWhileWriting ||
          _conversationsDirty ||
          _profilesDirty ||
          _dirtyMessagesByRoom.isNotEmpty ||
          _deletedMessageIdsByRoom.isNotEmpty ||
          _deletedRoomIds.isNotEmpty) {
        unawaited(_persist());
      }
    }
  }

  StreamController<void> _roomChangeController(String roomId) {
    return _roomChanges.putIfAbsent(roomId, StreamController<void>.broadcast);
  }

  void _emitRoomChanged(String roomId) {
    final controller = _roomChanges[roomId];
    if (controller == null || controller.isClosed) return;
    _roomEmitTimers[roomId]?.cancel();
    _roomEmitTimers[roomId] = Timer(const Duration(milliseconds: 40), () {
      _roomEmitTimers.remove(roomId);
      if (!controller.isClosed) {
        controller.add(null);
      }
    });
  }

  void _emitChanged() {
    if (_chatChanges.isClosed || _chatChangeQueued) return;
    _chatChangeQueued = true;
    _chatEmitTimer?.cancel();
    _chatEmitTimer = Timer(const Duration(milliseconds: 40), () {
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

class _MediaCacheEntry {
  _MediaCacheEntry({
    required this.file,
    required this.size,
    required this.modified,
  });

  final File file;
  final int size;
  final DateTime modified;
}
