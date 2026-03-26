import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:share_plus/share_plus.dart' as share;
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/navigation/app_route_observer.dart';
import 'package:two_space_app/core/sound/waveform_painter.dart';
import 'package:two_space_app/core/utils/message_time_formatter.dart';
import 'package:two_space_app/core/utils/storage_service.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/chat/data/services/aegis_group_service.dart';
import 'package:two_space_app/features/chat/data/services/draft_service.dart';
import 'package:two_space_app/features/chat/data/services/voice_service.dart';
import 'package:two_space_app/features/chat/presentation/screens/chat_settings_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/group_settings_screen.dart';
import 'package:two_space_app/features/chat/presentation/widgets/media_player.dart';
import 'package:two_space_app/features/chat/presentation/widgets/message_status_icon.dart';
import 'package:two_space_app/features/chat/presentation/widgets/typing_indicator.dart';
import 'package:two_space_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:two_space_app/features/profile/presentation/widgets/user_avatar.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

Future<bool> _pathExists(String path) async {
  try {
    return await File(path).exists();
  } catch (_) {
    return false;
  }
}

class ChatScreen extends StatefulWidget {
  final Chat chat;
  final String? searchQuery;
  final String? searchType; // 'all' | 'messages' | 'media' | 'users'
  final String? scrollToEventId;

  const ChatScreen({required this.chat, super.key, this.searchQuery, this.searchType, this.scrollToEventId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatTimelineState {
  const _ChatTimelineState({
    this.messages = const <_Msg>[],
    this.loading = true,
    this.loadingMoreHistory = false,
    this.hasMoreHistory = true,
    this.highlighted = const <String>{},
    this.imageMediaIds = const <String>[],
    this.imageIndexByMessageId = const <String, int>{},
  });

  final List<_Msg> messages;
  final bool loading;
  final bool loadingMoreHistory;
  final bool hasMoreHistory;
  final Set<String> highlighted;
  final List<String> imageMediaIds;
  final Map<String, int> imageIndexByMessageId;

  _ChatTimelineState copyWith({
    List<_Msg>? messages,
    bool? loading,
    bool? loadingMoreHistory,
    bool? hasMoreHistory,
    Set<String>? highlighted,
    List<String>? imageMediaIds,
    Map<String, int>? imageIndexByMessageId,
  }) {
    return _ChatTimelineState(
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
      loadingMoreHistory: loadingMoreHistory ?? this.loadingMoreHistory,
      hasMoreHistory: hasMoreHistory ?? this.hasMoreHistory,
      highlighted: highlighted ?? this.highlighted,
      imageMediaIds: imageMediaIds ?? this.imageMediaIds,
      imageIndexByMessageId:
          imageIndexByMessageId ?? this.imageIndexByMessageId,
    );
  }
}

class _ChatScreenState extends State<ChatScreen>
  with WidgetsBindingObserver, RouteAware {
  static const int _historyPageSize = 80;
  static const int _userInfoBatchSize = 6;
  static const Duration _searchDebounce = Duration(milliseconds: 260);
  static const Duration _historyLoadThrottle = Duration(milliseconds: 700);
  final AegisChatService _svc = AegisChatService();
  final TextEditingController _controller = TextEditingController();
  final DraftService _draftService = DraftService();
  final ValueNotifier<_ChatTimelineState> _timeline =
      ValueNotifier(const _ChatTimelineState());
  List<Map<String, dynamic>> _searchResults = [];
  bool _searching = false;
  final Map<String, Map<String, dynamic>> _reactions = {};
  final ScrollController _listController = ScrollController();
  final Map<String, GlobalKey> _messageKeys = {};
  final Map<String, String> _mediaDownloads = {};
  String? _scrollToEventId;
  bool _sending = false;
  final bool _isTyping = false;
  static const int _maxAudioPlayers = 5;
  final Map<String, AudioPlayer> _audioPlayers = {};
  final List<String> _audioPlayerAccessOrder = [];
  late final VoiceService _voiceService;
  StreamSubscription<List<AegisRoomMessage>>? _messagesSub;
  int _historyLimit = _historyPageSize;
  DateTime? _lastHistoryLoadAt;
  Future<void>? _loadOlderMessagesFuture;
  String? _currentUserId;
  List<AegisRoomMessage>? _pendingMessageBatch;
  bool _drainingMessageBatch = false;
  String? _headerName;
  String? _headerAvatarUrl;
  String? _headerPresenceStatus;
  DateTime? _headerLastSeenAt;
  Timer? _searchDebounceTimer;
  int _searchRequestId = 0;
  double? _uploadProgress;
  String? _uploadLabel;
  final List<_ComposerAttachment> _pendingAttachments = <_ComposerAttachment>[];
  bool _desktopDropActive = false;
  final Map<String, _Msg> _pendingOutgoingMessages = <String, _Msg>{};
  int _nextPendingMessageId = 0;
  ModalRoute<dynamic>? _route;
  bool _routeObserverAttached = false;
  bool _routeHasFocus = false;
  bool _screenHasFocus = false;
  AppLifecycleState _lifecycleState =
      SchedulerBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
  
  // Group-related state
  // String? _groupBackgroundColor;
  // String? _groupBackgroundImageUrl;

  List<_Msg> get _messages => _timeline.value.messages;
  bool get _loading => _timeline.value.loading;
  bool get _loadingMoreHistory => _timeline.value.loadingMoreHistory;
  bool get _hasMoreHistory => _timeline.value.hasMoreHistory;
  Set<String> get _highlighted => _timeline.value.highlighted;
  List<String> get _imageMediaIds => _timeline.value.imageMediaIds;
  Map<String, int> get _imageIndexByMessageId =>
      _timeline.value.imageIndexByMessageId;

  void _updateTimeline(
    _ChatTimelineState Function(_ChatTimelineState current) update,
  ) {
    final next = update(_timeline.value);
    _timeline.value = next;
  }

  void _setHighlighted(Set<String> messageIds) {
    _updateTimeline((current) => current.copyWith(highlighted: messageIds));
  }

  String _addPendingOutgoingMessage({
    required String text,
    required String type,
    String? mediaId,
  }) {
    final tempId = 'pending:${_nextPendingMessageId++}';
    final pending = _Msg(
      id: tempId,
      text: text,
      isOwn: true,
      time: DateTime.now(),
      senderId: _currentUserId,
      type: type,
      mediaId: mediaId,
      isPending: true,
    );
    _pendingOutgoingMessages[tempId] = pending;
    _updateTimeline(
      (current) => current.copyWith(
        messages: _mergePendingMessages(
          current.messages.where((message) => !message.isPending).toList(),
        ),
      ),
    );
    _scrollToLatest(animated: true);
    return tempId;
  }

  void _removePendingOutgoingMessage(String tempId) {
    if (_pendingOutgoingMessages.remove(tempId) == null) {
      return;
    }
    _updateTimeline(
      (current) => current.copyWith(
        messages: _mergePendingMessages(
          current.messages.where((message) => !message.isPending).toList(),
        ),
      ),
    );
  }

  List<_Msg> _mergePendingMessages(List<_Msg> persistedMessages) {
    if (_pendingOutgoingMessages.isEmpty) {
      return persistedMessages;
    }
    final combined = List<_Msg>.from(persistedMessages)
      ..addAll(_pendingOutgoingMessages.values);
    combined.sort((left, right) => left.time.compareTo(right.time));
    return combined;
  }

  List<_Msg> _visibleMessagesFor(List<_Msg> messages) {
    final q = (widget.searchQuery ?? '').trim().toLowerCase();
    final type = widget.searchType ?? 'all';
    if (q.isEmpty && type == 'all') return messages;
    return messages.where((m) {
      if (type == 'messages') return m.text.toLowerCase().contains(q);
      if (type == 'media') {
        // crude media detection: contains mxc:// or http and common extensions
        final t = m.text.toLowerCase();
        if (t.contains('mxc://') || t.contains('http')) return true;
        final exts = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.mp4', '.mov'];
        return exts.any(t.endsWith);
      }
      if (type == 'users') return m.text.toLowerCase().contains('@') || m.text.toLowerCase().contains('invite');
      // all
      return q.isEmpty || m.text.toLowerCase().contains(q);
    }).toList();
  }

  bool _sameVisualMessages(List<_Msg> left, List<_Msg> right) {
    if (identical(left, right)) return true;
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      final current = left[index];
      final next = right[index];
      if (current.id != next.id ||
          current.text != next.text ||
          current.isOwn != next.isOwn ||
          current.time != next.time ||
          current.senderId != next.senderId ||
          current.senderName != next.senderName ||
          current.senderAvatar != next.senderAvatar ||
          current.type != next.type ||
          current.mediaId != next.mediaId ||
          current.isDelivered != next.isDelivered ||
          current.isRead != next.isRead ||
          current.deliveredAt != next.deliveredAt ||
          current.readAt != next.readAt ||
          current.isPending != next.isPending) {
        return false;
      }
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _voiceService = VoiceService();
    _voiceService.init();
    _listController.addListener(_handleListScroll);
    unawaited(_loadCurrentUserId());
    _subscribeToMessages();
    _loadGroupSettings();
    _scrollToEventId = widget.scrollToEventId;
    _primeChatHeader();
    // Load draft if exists
    _loadDraft();
    final initialQuery = (widget.searchQuery ?? '').trim();
    if (initialQuery.isNotEmpty) {
      _scheduleServerSearch(initialQuery, widget.searchType ?? 'all');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_routeObserverAttached) {
      appRouteObserver.unsubscribe(this);
    }
    _searchDebounceTimer?.cancel();
    _messagesSub?.cancel();
    _timeline.dispose();
    _listController.removeListener(_handleListScroll);
    _listController.dispose();
    _controller.dispose();
    for (final player in _audioPlayers.values) {
      unawaited(player.dispose());
    }
    _audioPlayerAccessOrder.clear();
    _voiceService.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chat.id != widget.chat.id && _screenHasFocus) {
      unawaited(_svc.setActiveRoom(widget.chat.id));
    }
    final oldQ = (oldWidget.searchQuery ?? '').trim();
    final newQ = (widget.searchQuery ?? '').trim();
    if (oldWidget.scrollToEventId != widget.scrollToEventId) _scrollToEventId = widget.scrollToEventId;
    if (oldQ != newQ || oldWidget.searchType != widget.searchType) {
      _scheduleServerSearch(newQ, widget.searchType ?? 'all');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route == _route) {
      return;
    }
    if (_routeObserverAttached) {
      appRouteObserver.unsubscribe(this);
      _routeObserverAttached = false;
    }
    _route = route;
    if (route != null) {
      appRouteObserver.subscribe(this, route);
      _routeObserverAttached = true;
      _routeHasFocus = route.isCurrent;
      _syncFocusBinding();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    _syncFocusBinding();
  }

  @override
  void didPush() {
    _setRouteFocus(true);
  }

  @override
  void didPopNext() {
    _setRouteFocus(true);
  }

  @override
  void didPushNext() {
    _setRouteFocus(false);
  }

  @override
  void didPop() {
    _setRouteFocus(false);
  }

  void _setRouteFocus(bool hasFocus) {
    _routeHasFocus = hasFocus;
    _syncFocusBinding();
  }

  void _syncFocusBinding() {
    final nextFocus =
        _routeHasFocus && _lifecycleState == AppLifecycleState.resumed;
    if (_screenHasFocus == nextFocus) {
      return;
    }
    _screenHasFocus = nextFocus;
    unawaited(_svc.setActiveRoom(nextFocus ? widget.chat.id : null));
  }

  void _scheduleServerSearch(String query, String type) {
    _searchDebounceTimer?.cancel();
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        _searchResults = [];
        _searching = false;
      });
      return;
    }
    _searchDebounceTimer = Timer(_searchDebounce, () {
      unawaited(_performServerSearch(query, type));
    });
  }

  void _subscribeToMessages() {
    _messagesSub?.cancel();
    _messagesSub = _svc.watchRoomMessages(
      widget.chat.id,
      limit: _historyLimit,
    ).listen(
      _scheduleMessagesApply,
      onError: (_) {
        if (mounted) {
          _updateTimeline((current) => current.copyWith(loading: false));
        }
      },
    );
  }

  String? get _directPeerUserId {
    if (!widget.chat.id.startsWith('dm:')) return null;
    final peerId = widget.chat.id.substring(3);
    return peerId.isEmpty ? null : peerId;
  }

  void _primeChatHeader() {
    _headerName = widget.chat.name;
    _headerAvatarUrl = widget.chat.avatarUrl;
    _headerPresenceStatus = widget.chat.presenceStatus;
    _headerLastSeenAt = widget.chat.lastSeenAt;

    final peerUserId = _directPeerUserId;
    if (peerUserId == null) return;

    final cached = _svc.peekUserInfo(peerUserId);
    if (cached != null) {
      _applyHeaderUserInfo(cached, notify: false);
    }
    unawaited(_loadHeaderUserInfo(peerUserId));
  }

  Future<void> _loadHeaderUserInfo(String peerUserId) async {
    try {
      final info = await _svc.getUserInfo(peerUserId);
      _applyHeaderUserInfo(info);
    } catch (_) {}
  }

  void _applyHeaderUserInfo(
    Map<String, dynamic> info, {
    bool notify = true,
  }) {
    if (!mounted && notify) return;

    final displayName = info['displayName']?.toString();
    final username = info['username']?.toString();
    final avatarUrl = info['avatarUrl']?.toString();
    final presenceStatus = info['presenceStatus']?.toString();
    final lastSeenAt = info['lastSeenAt'] is String
        ? DateTime.tryParse(info['lastSeenAt'] as String)
        : null;

    void update() {
      _headerName = (displayName?.isNotEmpty ?? false)
          ? displayName
          : ((username?.isNotEmpty ?? false) ? username : _headerName);
      _headerAvatarUrl = (avatarUrl?.isNotEmpty ?? false)
          ? avatarUrl
          : _headerAvatarUrl;
      _headerPresenceStatus = presenceStatus;
      _headerLastSeenAt = lastSeenAt;
    }

    if (notify) {
      setState(update);
    } else {
      update();
    }
  }

  String? _headerPresenceLabel(AppLocalizations l10n) {
    switch (_headerPresenceStatus) {
      case 'online':
        return l10n.onlineLabel;
      case 'recently':
        return l10n.statusLastSeenRecently;
      case 'long_ago':
        return l10n.offlineLabel;
      case 'was_online':
      case 'offline':
        if (_headerLastSeenAt != null) {
          return MessageTimeFormatter.formatConversationTime(_headerLastSeenAt);
        }
        return l10n.offlineLabel;
      default:
        if (widget.chat.isOnline) {
          return l10n.onlineLabel;
        }
        return null;
    }
  }

  Color _headerPresenceColor(BuildContext context) {
    switch (_headerPresenceStatus) {
      case 'online':
        return AppColors.onlineStatus(context);
      case 'recently':
        return AppColors.recentlyStatus(context);
      default:
        return AppColors.offlineStatus(context);
    }
  }

  void _handleListScroll() {
    if (!_listController.hasClients || _loadingMoreHistory || !_hasMoreHistory) {
      return;
    }
    final lastHistoryLoadAt = _lastHistoryLoadAt;
    if (lastHistoryLoadAt != null &&
        DateTime.now().difference(lastHistoryLoadAt) < _historyLoadThrottle) {
      return;
    }
    if (_listController.position.pixels <= 180) {
      unawaited(_loadOlderMessages());
    }
  }

  Future<void> _loadCurrentUserId() async {
    _currentUserId ??= await _svc.getCurrentUserId();
  }

  void _scheduleMessagesApply(List<AegisRoomMessage> messages) {
    _pendingMessageBatch = messages;
    if (_drainingMessageBatch) return;
    unawaited(_drainPendingMessages());
  }

  Future<void> _drainPendingMessages() async {
    _drainingMessageBatch = true;
    try {
      while (_pendingMessageBatch != null) {
        final batch = _pendingMessageBatch!;
        _pendingMessageBatch = null;
        await _applyMessages(batch);
      }
    } finally {
      _drainingMessageBatch = false;
    }
  }

  Future<void> _prefetchUserInfo(Set<String> senderIds) async {
    final ids = senderIds
        .where((id) => id.isNotEmpty && _svc.peekUserInfo(id) == null)
        .toList(growable: false);
    if (ids.isEmpty) return;

    final fetched = <String, Map<String, dynamic>>{};
    for (var index = 0; index < ids.length; index += _userInfoBatchSize) {
      final chunk = ids.sublist(
        index,
        math.min(index + _userInfoBatchSize, ids.length),
      );
      final results = await Future.wait(
        chunk.map((id) async {
          final info = await _svc.getUserInfo(id);
          return MapEntry(id, info);
        }),
      );
      for (final entry in results) {
        fetched[entry.key] = entry.value;
      }
    }

    if (!mounted || fetched.isEmpty) return;
    var hasVisualUpdates = false;
    final updatedMessages = List<_Msg>.from(_messages);
    for (var index = 0; index < updatedMessages.length; index++) {
      final message = updatedMessages[index];
      final info = fetched[message.senderId];
      if (info == null) continue;
      final nextName = info['displayName']?.toString() ?? message.senderName;
      final nextAvatar = info['avatarUrl']?.toString() ?? message.senderAvatar;
      if (nextName == message.senderName && nextAvatar == message.senderAvatar) {
        continue;
      }
      hasVisualUpdates = true;
      updatedMessages[index] = _Msg(
        id: message.id,
        text: message.text,
        isOwn: message.isOwn,
        time: message.time,
        senderId: message.senderId,
        senderName: nextName,
        senderAvatar: nextAvatar,
        type: message.type,
        mediaId: message.mediaId,
        isDelivered: message.isDelivered,
        isRead: message.isRead,
        deliveredAt: message.deliveredAt,
        readAt: message.readAt,
      );
    }

    if (!hasVisualUpdates) return;
    _updateTimeline((current) => current.copyWith(messages: updatedMessages));
  }

  Future<void> _loadOlderMessages() async {
    final inFlight = _loadOlderMessagesFuture;
    if (inFlight != null) {
      await inFlight;
      return;
    }
    if (_loadingMoreHistory || !_hasMoreHistory || !mounted) return;
    final now = DateTime.now();
    final lastHistoryLoadAt = _lastHistoryLoadAt;
    if (lastHistoryLoadAt != null &&
        now.difference(lastHistoryLoadAt) < _historyLoadThrottle) {
      return;
    }
    _lastHistoryLoadAt = now;

    final future = () async {
    final previousMaxExtent = _listController.hasClients
        ? _listController.position.maxScrollExtent
        : 0.0;

    _updateTimeline((current) => current.copyWith(loadingMoreHistory: true));
    _historyLimit += _historyPageSize;
    await _loadMessages(forceRefresh: true);
    _subscribeToMessages();

    // Use a double post-frame callback so the extent is read after the
    // list has fully laid out the newly prepended items.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_listController.hasClients) return;
        final nextMaxExtent = _listController.position.maxScrollExtent;
        final delta = nextMaxExtent - previousMaxExtent;
        if (delta > 0) {
          _listController.jumpTo(_listController.position.pixels + delta);
        }
      });
    });

    if (mounted) {
      _updateTimeline(
        (current) => current.copyWith(loadingMoreHistory: false),
      );
    }
    }();

    _loadOlderMessagesFuture = future;
    try {
      await future;
    } finally {
      if (identical(_loadOlderMessagesFuture, future)) {
        _loadOlderMessagesFuture = null;
      }
    }
  }

  Future<void> _performServerSearch(String q, String type) async {
    final query = q.trim();
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() { _searchResults = []; _searching = false; });
      return;
    }
    final requestId = ++_searchRequestId;
    if (!mounted) return;
    setState(() { _searching = true; _searchResults = []; });
    try {
      final res = await _svc.searchMessages(query: query, type: type);
      if (!mounted || requestId != _searchRequestId) return;
      setState(() { _searchResults = res; });
    } catch (_) {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() { _searchResults = []; });
    } finally {
      if (mounted && requestId == _searchRequestId) {
        setState(() => _searching = false);
      }
    }
  }

  bool _shouldStickToLatest() {
    if (!_listController.hasClients) return true;
    final position = _listController.position;
    return position.maxScrollExtent - position.pixels < 160;
  }

  void _scrollToLatest({bool animated = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listController.hasClients) return;
      final offset = _listController.position.maxScrollExtent;
      if (animated) {
        _listController.animateTo(
          offset,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
        );
      } else {
        _listController.jumpTo(offset);
      }
    });
  }

  void _openImageGallery({
    required List<String> mediaIds,
    required int initialIndex,
  }) {
    if (mediaIds.isEmpty || initialIndex < 0 || initialIndex >= mediaIds.length) {
      return;
    }
    showDialog<void>(
      context: context,
      builder: (_) => _ChatImageGalleryDialog(
        mediaIds: mediaIds,
        initialIndex: initialIndex,
        svc: _svc,
        mediaDownloads: _mediaDownloads,
      ),
    );
  }


  Future<void> _loadMessages({bool forceRefresh = false}) async {
    final msgs = await _svc.loadMessages(
      roomId: widget.chat.id,
      limit: _historyLimit,
      forceRefresh: forceRefresh,
    );
    await _applyMessages(msgs);
  }

  Future<void> _applyMessages(List<AegisRoomMessage> msgs) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldStickToLatest = _shouldStickToLatest();
    try {
      await _loadCurrentUserId();
      final me = _currentUserId;
      final missingSenderIds = <String>{};
      final out = <_Msg>[];
      final imageMediaIds = <String>[];
      final imageIndexByMessageId = <String, int>{};
      for (var index = 0; index < msgs.length; index++) {
        if (index > 0 && index % 40 == 0) {
          await Future<void>.delayed(Duration.zero);
          if (!mounted) {
            return;
          }
        }
        final m = msgs[index];
        final cached = _svc.peekUserInfo(m.senderId) ??
            const <String, dynamic>{};
        if (cached.isEmpty && m.senderId.isNotEmpty) {
          missingSenderIds.add(m.senderId);
        }
        final senderName = cached['displayName'] ?? m.senderId;
        final senderAvatar = cached['avatarUrl'];

        // Determine isOwn in a tolerant way
        bool isOwn = false;
        try {
          String normalize(String? mx) {
            if (mx == null || mx.isEmpty) return '';
            var s = mx;
            if (s.startsWith('@')) s = s.substring(1);
            if (s.contains(':')) s = s.split(':').first;
            return s.toLowerCase();
          }
          final meNorm = normalize(me);
          final senderNorm = normalize(m.senderId);
          isOwn = meNorm.isNotEmpty && meNorm == senderNorm;
        } catch (_) { 
          isOwn = me != null && me == m.senderId; 
        }
        final nextMessage = _Msg(
          id: m.id,
          text: m.content,
          isOwn: isOwn,
          time: m.time,
          senderId: m.senderId,
          senderName: senderName,
          senderAvatar: senderAvatar,
          type: m.type,
          mediaId: m.mediaId,
          isDelivered: m.isDelivered,
          isRead: m.isRead,
          deliveredAt: m.deliveredAt,
          readAt: m.readAt,
        );
        out.add(nextMessage);
        final mediaId = nextMessage.mediaId;
        if (nextMessage.type == 'm.image' && mediaId != null && mediaId.isNotEmpty) {
          imageIndexByMessageId[nextMessage.id] = imageMediaIds.length;
          imageMediaIds.add(mediaId);
        }
      }
      
        final mergedMessages = _mergePendingMessages(out);

        if (!mounted) return;
      final nextMessageIds = out.map((message) => message.id).toSet();
      final nextHighlighted = _highlighted
          .where(nextMessageIds.contains)
          .toSet();
      _messageKeys.removeWhere(
        (messageId, _) => !nextMessageIds.contains(messageId),
      );
      final shouldUpdateTimeline =
          !_sameVisualMessages(_messages, mergedMessages) ||
          _hasMoreHistory != (msgs.length >= _historyLimit) ||
          _loading ||
          !_sameStringList(_imageMediaIds, imageMediaIds) ||
          !_sameIntMap(_imageIndexByMessageId, imageIndexByMessageId) ||
          !_sameStringSet(_highlighted, nextHighlighted);
      if (shouldUpdateTimeline) {
        _updateTimeline(
          (current) => current.copyWith(
            messages: mergedMessages,
            imageMediaIds: imageMediaIds,
            imageIndexByMessageId: imageIndexByMessageId,
            hasMoreHistory: msgs.length >= _historyLimit,
            loading: false,
            highlighted: nextHighlighted,
          ),
        );
      }
      if (missingSenderIds.isNotEmpty) {
        unawaited(_prefetchUserInfo(missingSenderIds));
      }
      unawaited(_svc.markRoomRead(widget.chat.id));
      
      // If we have an initial scroll target, try to scroll to it
      if (_scrollToEventId != null && _scrollToEventId!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            final targetId = _scrollToEventId!;
            final key = _messageKeys[targetId];
            if (key != null && key.currentContext != null) {
              await Scrollable.ensureVisible(key.currentContext!, duration: const Duration(milliseconds: 450), alignment: 0.4, curve: Curves.easeInOut);
              _setHighlighted(<String>{targetId});
            } else {
              // Fallback: jump to a ratio-estimated position so the item enters
              // the viewport, then use ensureVisible for pixel-perfect alignment.
              final idx = _messages.indexWhere((m) => m.id == targetId);
              if (idx >= 0 && _listController.hasClients) {
                final total = _messages.length;
                final ratio = total > 1 ? idx / (total - 1) : 1.0;
                final estimated = (ratio * _listController.position.maxScrollExtent)
                    .clamp(0.0, _listController.position.maxScrollExtent);
                _listController.jumpTo(estimated);
                // After the jump is painted, try ensureVisible for exact alignment.
                WidgetsBinding.instance.addPostFrameCallback((_) async {
                  try {
                    final k = _messageKeys[targetId];
                    if (k?.currentContext != null) {
                      await Scrollable.ensureVisible(
                        k!.currentContext!,
                        duration: const Duration(milliseconds: 350),
                        alignment: 0.4,
                        curve: Curves.easeInOut,
                      );
                    }
                    if (mounted) {
                      _setHighlighted(<String>{targetId});
                    }
                  } catch (_) {}
                });
              }
            }
          } catch (_) {}
          _scrollToEventId = null;
        });
      } else if (shouldStickToLatest) {
        _scrollToLatest();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.loadMessagesError(e.toString()))));
    } finally {
      if (mounted && _loading) {
        _updateTimeline((current) => current.copyWith(loading: false));
      }
    }
  }

  Future<void> _loadGroupSettings() async {
    try {
      final groupService = AegisGroupService();
      await groupService.getGroupRoom(widget.chat.id);
    } catch (_) {
      // Not a group room or error loading settings
    }
  }

  Future<void> _openChatSettings() async {
    final isGroupRoom = widget.chat.roomType == 'group';
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => isGroupRoom
            ? GroupSettingsScreen(roomId: widget.chat.id)
            : ChatSettingsScreen(
                roomId: widget.chat.id,
                initialName: widget.chat.name,
                roomType: widget.chat.roomType,
              ),
      ),
    );
    if (!mounted) return;
    await _loadMessages(forceRefresh: true);
  }

  void _openUserProfile(
    String userId, {
    String? initialName,
    String? initialAvatar,
  }) {
    if (userId.trim().isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          userId: userId,
          initialName: initialName,
          initialAvatar: initialAvatar,
        ),
      ),
    );
  }

  /// Load draft message for this chat
  Future<void> _loadDraft() async {
    try {
      final draft = await _draftService.getDraft(widget.chat.id);
      if (draft != null && mounted) {
        setState(() {
          _controller.text = draft.content;
        });
      }
    } catch (_) {
      // Draft loading failed, ignore
    }
  }

  Future<void> _sendReplyForEvent(String eventId) async {
    // prompt for reply text then send as a reply
    final l10n = AppLocalizations.of(context)!;
    final text = await showDialog<String>(context: context, builder: (c) {
      final ctl = TextEditingController();
      return AlertDialog(
        title: Text(l10n.replyAction),
        content: TextField(controller: ctl, decoration: InputDecoration(hintText: l10n.replyHint)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text(l10n.cancelButton)),
          ElevatedButton(onPressed: () => Navigator.pop(c, ctl.text.trim()), child: Text(l10n.sendButton)),
        ],
      );
    });
    if (text == null || text.isEmpty) return;
    try {
      final formatted = '<mx-reply><blockquote>${text.replaceAll('<', '&lt;').replaceAll('>', '&gt;')}</blockquote></mx-reply>';
      await _svc.sendReply(widget.chat.id, eventId, body: text, formattedBody: formatted);
    } catch (e) {
      if (mounted) _showErrorMessage(l10n.replyError(e.toString()));
    }
  }



  Future<void> _pinUnpinEvent(String eventId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final pinned = await _svc.getPinnedEvents(widget.chat.id);
      if (pinned.contains(eventId)) {
        pinned.remove(eventId);
      } else {
        pinned.insert(0, eventId);
      }
      await _svc.setPinnedEvents(widget.chat.id, pinned);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.pinnedUpdated), duration: const Duration(seconds: 2)));
    } catch (e) {
      if (mounted) _showErrorMessage(l10n.pinError(e.toString()));
    }
  }

  Future<void> _redactEvent(String eventId) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: Text(l10n.deleteMessageTitle), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l10n.cancelButton)), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: Text(l10n.deleteButton))]));
    if (ok != true) return;
    try {
      await _svc.redactEvent(widget.chat.id, eventId);
    } catch (e) {
      if (mounted) _showErrorMessage(l10n.deleteError(e.toString()));
    }
  }

  Future<void> _editEvent(String eventId, String currentText) async {
    final l10n = AppLocalizations.of(context)!;
    final newText = await showDialog<String>(context: context, builder: (c) {
      final ctl = TextEditingController(text: currentText);
      return AlertDialog(
        title: Text(l10n.editMessageTitle),
        content: TextField(
          controller: ctl,
          decoration: InputDecoration(hintText: l10n.editMessageHint),
          maxLines: null,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text(l10n.cancelButton)),
          ElevatedButton(onPressed: () => Navigator.pop(c, ctl.text.trim()), child: Text(l10n.saveButton)),
        ],
      );
    });
    if (newText == null || newText.isEmpty) return;
    try {
      await _svc.editMessage(widget.chat.id, eventId, newText);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.messageEdited), duration: const Duration(seconds: 2)));
    } catch (e) {
      if (mounted) _showErrorMessage(l10n.editError(e.toString()));
    }
  }

  void _toggleReactionLocally(String messageId, String reaction) {
    if (!mounted) return;
    setState(() {
      final current = Map<String, dynamic>.from(
        _reactions[messageId] ?? const <String, dynamic>{},
      );
      final existing = Map<String, dynamic>.from(
        current[reaction] as Map<String, dynamic>? ?? const <String, dynamic>{},
      );
      final hasMine = (existing['myEventId'] as String?)?.isNotEmpty ?? false;
      final count = (existing['count'] as int?) ?? 0;

      if (hasMine) {
        final nextCount = count - 1;
        if (nextCount <= 0) {
          current.remove(reaction);
        } else {
          current[reaction] = {
            ...existing,
            'count': nextCount,
            'myEventId': null,
          };
        }
      } else {
        current[reaction] = {
          ...existing,
          'count': count + 1,
          'myEventId': 'local',
        };
      }

      if (current.isEmpty) {
        _reactions.remove(messageId);
      } else {
        _reactions[messageId] = current;
      }
    });
  }

  void _showEmojiBurst(BuildContext context, String emoji, Offset position) {
    final overlay = Overlay.of(context);
    late OverlayEntry burstEntry;
    
    burstEntry = OverlayEntry(builder: (ctx) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 600),
        onEnd: () => burstEntry.remove(),
        builder: (context, val, child) {
          return Stack(
            children: List.generate(6, (index) {
              final angle = (index / 6) * 2 * math.pi;
              final distance = val * 60;
              final dx = position.dx + math.cos(angle) * distance;
              final dy = position.dy + math.sin(angle) * distance - (val * 40); // curve up
              
              return Positioned(
                left: dx - 12, // center offset
                top: dy - 12,
                child: Transform.scale(
                  scale: math.max(0, 1.0 - val), // shrink
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24, decoration: TextDecoration.none),
                  ),
                ),
              );
            }),
          );
        },
      );
    });
    
    overlay.insert(burstEntry);
  }

  Future<void> _showMessageActions(_Msg m, Offset globalPos) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final actions = <({IconData icon, String label, Future<void> Function() run})>[
      (
        icon: Icons.reply,
        label: l10n.replyAction,
        run: () async => _sendReplyForEvent(m.id),
      ),
      if (m.isOwn)
        (
          icon: Icons.edit,
          label: l10n.editShort,
          run: () async => _editEvent(m.id, m.text),
        ),
      (
        icon: Icons.push_pin,
        label: l10n.pinAction,
        run: () async => _pinUnpinEvent(m.id),
      ),
      if (m.isOwn)
        (
          icon: Icons.delete_outline,
          label: l10n.deleteButton,
          run: () async => _redactEvent(m.id),
        ),
      (
        icon: Icons.share_outlined,
        label: l10n.shareAction,
        run: () async => _shareMessage(m),
      ),
      (
        icon: Icons.emoji_emotions_outlined,
        label: l10n.moreButton,
        run: () async {
          final picked = await _showEmojiPickerDialog();
          if (picked == null) {
            return;
          }
          try {
            _showEmojiBurst(context, picked, globalPos);
            await _svc.sendReaction(
              roomId: widget.chat.id,
              eventId: m.id,
              reaction: picked,
            );
            _toggleReactionLocally(m.id, picked);
          } catch (_) {}
        },
      ),
    ];

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final maxHeight = MediaQuery.of(sheetContext).size.height * 0.72;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 560,
                  maxHeight: maxHeight,
                ),
                child: Material(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 42,
                              height: 4,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.outlineVariant,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            m.text.isEmpty ? l10n.messageInputHint : m.text,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final emoji in ['👍', '❤️', '😂', '🔥', '😮', '🎉'])
                                InkWell(
                                  borderRadius: BorderRadius.circular(999),
                                  onTap: () async {
                                    Navigator.of(sheetContext).pop();
                                    _showEmojiBurst(context, emoji, globalPos);
                                    try {
                                      await _svc.sendReaction(
                                        roomId: widget.chat.id,
                                        eventId: m.id,
                                        reaction: emoji,
                                      );
                                      _toggleReactionLocally(m.id, emoji);
                                    } catch (_) {}
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              for (final action in actions)
                                SizedBox(
                                  width: 160,
                                  child: ShadButton.secondary(
                                    onPressed: () async {
                                      Navigator.of(sheetContext).pop();
                                      await action.run();
                                    },
                                    leading: Icon(action.icon, size: 18),
                                    child: Text(
                                      action.label,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String?> _showEmojiPickerDialog() async {
    String? chosen;
    await showDialog(context: context, builder: (c) {
      final size = MediaQuery.of(c).size;
      final width = math.min<double>(size.width * 0.9, 420);
      final height = math.min<double>(size.height * 0.72, 520);
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: MaterialLocalizations.of(c).closeButtonTooltip,
                  onPressed: () => Navigator.of(c).pop(),
                  icon: const Icon(Icons.close),
                ),
              ),
              Expanded(
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    chosen = emoji.emoji;
                    Navigator.of(c).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
    return chosen;
  }

  /// Share a message with system share sheet
  Future<void> _shareMessage(_Msg message) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await share.Share.share(message.text);
    } catch (e) {
      if (mounted) {
        _showErrorMessage(l10n.shareError(e.toString()));
      }
    }
  }

  Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _pendingAttachments.isEmpty) return;
    if (_pendingAttachments.isNotEmpty) {
      await _sendComposerPayload();
      return;
    }
    final l10n = AppLocalizations.of(context)!;
    final pendingId = _addPendingOutgoingMessage(
      text: text,
      type: 'm.text',
    );
    setState(() => _sending = true);
    _controller.clear();
    try {
      await _svc.sendMessage(roomId: widget.chat.id, text: text);
      _removePendingOutgoingMessage(pendingId);
      _scrollToLatest(animated: true);
      // Clear draft after successful send
      await _draftService.deleteDraft(widget.chat.id);
    } catch (e) {
      _removePendingOutgoingMessage(pendingId);
      if (mounted) {
        _controller.text = text;
      }
      if (mounted) _showErrorMessage(l10n.sendError(e.toString()));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _recordVoiceMessage() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_voiceService.isInitialized) {
      if (mounted) {
        _showErrorMessage(l10n.voiceRecordingUnsupported);
      }
      return;
    }
    
    final path = await _voiceService.startRecording();
    if (path == null) {
      if (mounted) {
        _showErrorMessage(l10n.microphonePermissionRequired);
      }
      return;
    }
    setState(() {});
  }

  void _showErrorMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.danger(context),
      ),
    );
  }

  void _setUploadProgress(String label, double progress) {
    if (!mounted) {
      return;
    }
    setState(() {
      _uploadLabel = label;
      _uploadProgress = progress.clamp(0.0, 1.0);
    });
  }

  void _clearUploadProgress() {
    if (!mounted) {
      return;
    }
    setState(() {
      _uploadLabel = null;
      _uploadProgress = null;
    });
  }

  Future<void> _stopVoiceAndSend() async {
    final l10n = AppLocalizations.of(context)!;
    final path = await _voiceService.stopRecording();
    if (path == null || !await _pathExists(path)) {
      if (mounted) _showErrorMessage(l10n.recordingError);
      return;
    }

    final fileName = path.split(Platform.pathSeparator).last;

    setState(() => _sending = true);
    try {
      await _svc.sendMessage(
        roomId: widget.chat.id,
        text: '',
        type: 'm.audio',
        mediaFileId: path,
        onMediaSendProgress: (progress) => _setUploadProgress(fileName, progress),
      );
      if (mounted) {
        _scrollToLatest(animated: true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.genericError(e.toString()))));
    } finally {
      if (mounted) {
        _clearUploadProgress();
        setState(() => _sending = false);
      }
    }
  }

  String _attachmentMessageType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp')) {
      return 'm.image';
    }
    if (lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.webm')) {
      return 'm.video';
    }
    if (lower.endsWith('.ogg') || lower.endsWith('.m4a') || lower.endsWith('.mp3') || lower.endsWith('.wav')) {
      return 'm.audio';
    }
    return 'm.file';
  }

  bool _supportsInlineCaption(String type) =>
      type == 'm.image' || type == 'm.video';

  Future<void> _enqueuePickerSelection(FilePickerResult result) async {
    final additions = <_ComposerAttachment>[];
    for (final file in result.files) {
      final path = file.path;
      if (path == null) {
        continue;
      }
      if (_pendingAttachments.any((attachment) => attachment.path == path) ||
          additions.any((attachment) => attachment.path == path)) {
        continue;
      }
      additions.add(
        _ComposerAttachment(
          path: path,
          name: file.name,
          sizeBytes: file.size,
          type: _attachmentMessageType(file.name),
        ),
      );
    }

    if (additions.isEmpty || !mounted) {
      return;
    }

    setState(() {
      _pendingAttachments.addAll(additions);
    });
  }

  Future<void> _enqueueDroppedFiles(List<String> paths) async {
    final additions = <_ComposerAttachment>[];
    for (final path in paths) {
      if (path.isEmpty ||
          _pendingAttachments.any((attachment) => attachment.path == path) ||
          additions.any((attachment) => attachment.path == path)) {
        continue;
      }
      try {
        final file = File(path);
        if (!await file.exists()) {
          continue;
        }
        final stat = await file.stat();
        if (stat.type != FileSystemEntityType.file) {
          continue;
        }
        final name = path.split(Platform.pathSeparator).last;
        additions.add(
          _ComposerAttachment(
            path: path,
            name: name,
            sizeBytes: stat.size,
            type: _attachmentMessageType(name),
          ),
        );
      } catch (_) {}
    }

    if (additions.isEmpty || !mounted) {
      return;
    }

    setState(() {
      _pendingAttachments.addAll(additions);
      _desktopDropActive = false;
    });
  }

  Future<void> _pickAttachments() async {
    final res = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (res == null || res.files.isEmpty) return;
    await _enqueuePickerSelection(res);
  }

  Future<void> _sendComposerPayload() async {
    final l10n = AppLocalizations.of(context)!;
    final text = _controller.text.trim();
    final attachments = List<_ComposerAttachment>.from(_pendingAttachments);

    if (text.isEmpty && attachments.isEmpty) {
      return;
    }

    setState(() => _sending = true);
    try {
      final shouldInlineCaption = text.isNotEmpty &&
          attachments.isNotEmpty &&
          _supportsInlineCaption(attachments.first.type);

      if (text.isNotEmpty && attachments.isNotEmpty && !shouldInlineCaption) {
        await _svc.sendMessage(roomId: widget.chat.id, text: text);
      }

      for (var index = 0; index < attachments.length; index++) {
        final attachment = attachments[index];
        await _svc.sendMessage(
          roomId: widget.chat.id,
          text: index == 0 && shouldInlineCaption
              ? text
              : attachment.defaultMessageText,
          type: attachment.type,
          mediaFileId: attachment.path,
          onMediaSendProgress: (progress) =>
              _setUploadProgress(attachment.name, progress),
        );
      }

      if (text.isNotEmpty && attachments.isEmpty) {
        await _svc.sendMessage(roomId: widget.chat.id, text: text);
      }

      if (!mounted) return;
      setState(() {
        _controller.clear();
        _pendingAttachments.clear();
      });
      _scrollToLatest(animated: true);
      await _draftService.deleteDraft(widget.chat.id);
      if (attachments.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.fileSent),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(
          attachments.isNotEmpty
              ? l10n.attachmentSendError(e.toString())
              : l10n.sendError(e.toString()),
        );
      }
    } finally {
      if (mounted) {
        _clearUploadProgress();
        setState(() => _sending = false);
      }
    }
  }

  void _removePendingAttachment(_ComposerAttachment attachment) {
    setState(() {
      _pendingAttachments.removeWhere((item) => item.path == attachment.path);
    });
  }

  Widget _buildUploadProgressCard(ColorScheme colorScheme) {
    final progress = _uploadProgress;
    final label = _uploadLabel;
    if (progress == null || label == null) {
      return const SizedBox.shrink();
    }

    final percent = (progress * 100).clamp(0, 100).round();
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.upload_rounded, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$percent%',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentPreviewTray(ColorScheme colorScheme) {
    if (_pendingAttachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: SizedBox(
        height: 138,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _pendingAttachments.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final attachment = _pendingAttachments[index];
            return _ComposerAttachmentCard(
              attachment: attachment,
              colorScheme: colorScheme,
              sending: _sending,
              onRemove: () => _removePendingAttachment(attachment),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopDropOverlay(ColorScheme colorScheme) {
    if (!_desktopDropActive) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.72),
              width: 2,
            ),
          ),
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.file_upload_outlined, color: colorScheme.primary, size: 34),
                    const SizedBox(height: 10),
                    Text(
                      AppLocalizations.of(context)!.dropFilesTitle,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.dropFilesSubtitle,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final headerName = _headerName ?? widget.chat.name;
    final headerAvatarUrl = _headerAvatarUrl ?? widget.chat.avatarUrl;
    final presenceLabel = _directPeerUserId != null ? _headerPresenceLabel(l10n) : null;
    final bodyWidget = ValueListenableBuilder(
      valueListenable: SettingsService.themeNotifier,
      builder: (context, themeSettings, _) {
        final bubbleRounding = themeSettings.bubbleRounding;
        final dynamicBubbles = themeSettings.dynamicBubbles;
        return ValueListenableBuilder<_ChatTimelineState>(
      valueListenable: _timeline,
      builder: (context, timeline, _) {
        if (timeline.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if ((widget.searchQuery ?? '').trim().isNotEmpty) {
          if (_searching) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemBuilder: (c, i) {
              final item = _searchResults[i];
              final ev = item['event'] as Map<String, dynamic>? ?? {};
              final content = ev['content'] as Map<String, dynamic>? ?? {};
              final body = content['body']?.toString() ?? '';
              final sender = ev['sender']?.toString() ?? '';
              final tsNum = ev['origin_server_ts'] as num?;
              final ts = tsNum != null
                  ? DateTime.fromMillisecondsSinceEpoch(tsNum.toInt())
                  : null;
              final roomId = (item['context'] is Map)
                  ? ((item['context'] as Map)['room_id']?.toString() ?? '')
                  : '';

              final info = _svc.peekUserInfo(sender) ?? {};
              final avatar = info['avatarUrl']?.toString();
              final displayName = info['displayName']?.toString() ?? sender;

              return ListTile(
                leading: avatar != null
                    ? UserAvatar(avatarUrl: avatar, radius: 18)
                    : CircleAvatar(
                        radius: 18,
                        child: Text(displayName.isNotEmpty ? displayName[0] : '?'),
                      ),
                title: Text(body, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '$displayName${roomId.isNotEmpty ? ' • $roomId' : ''}${ts != null ? ' • ${MessageTimeFormatter.formatTime(ts)}' : ''}',
                ),
                onTap: () async {
                  if (roomId.isEmpty) return;
                  final infoRoom = await _svc.getRoomNameAndAvatar(roomId);
                  final chat = Chat(
                    id: roomId,
                    name: infoRoom['name'] ?? roomId,
                    avatarUrl: infoRoom['avatar'],
                    members: [],
                  );
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chat: chat,
                        scrollToEventId: ev['event_id']?.toString(),
                      ),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (_, __) => const Divider(),
            itemCount: _searchResults.length,
          );
        }

        final visibleMessages = _visibleMessagesFor(timeline.messages);
        final viewportWidth = MediaQuery.of(context).size.width;
        final bubbleMaxWidth = math.min<double>(viewportWidth * 0.72, 560);
        return ListView.custom(
          controller: _listController,
          padding: const EdgeInsets.all(12),
          cacheExtent: 400,
          childrenDelegate: SliverChildBuilderDelegate(
            (c, i) {
          if (timeline.loadingMoreHistory && i == 0) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          final messageIndex = i - (timeline.loadingMoreHistory ? 1 : 0);
          final m = visibleMessages[messageIndex];
          final shouldTrackKey =
              _scrollToEventId == m.id || timeline.highlighted.contains(m.id);
          final key = shouldTrackKey
              ? _messageKeys.putIfAbsent(m.id, GlobalKey.new)
              : null;
            final caption = _messageCaption(m);
          final bubbleContent = Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (!m.isOwn) Text(m.senderName ?? m.senderId ?? '', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: AppColors.subtitleText(context))),
              const SizedBox(height: 6),
              if (m.type == 'm.image' && (m.mediaId != null && m.mediaId!.isNotEmpty))
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                  child: _ImageMessageWidget(
                    mediaId: m.mediaId!,
                    svc: _svc,
                    mediaDownloads: _mediaDownloads,
                    maxWidth: bubbleMaxWidth,
                    onOpenGallery: () {
                      final index = timeline.imageIndexByMessageId[m.id];
                      if (index == null) return;
                      _openImageGallery(
                        mediaIds: timeline.imageMediaIds,
                        initialIndex: index,
                      );
                    },
                  ),
                )
              else if (m.type == 'm.video' && (m.mediaId != null && m.mediaId!.isNotEmpty))
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                  child: _VideoMessageWidget(
                    message: m,
                    svc: _svc,
                    mediaDownloads: _mediaDownloads,
                    maxWidth: bubbleMaxWidth,
                  ),
                )
              else if (m.type == 'm.audio' || (m.text.toLowerCase().endsWith('.ogg') || (m.mediaId?.toLowerCase().endsWith('.ogg') ?? false)))
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: bubbleMaxWidth * 0.85),
                  child: _AudioMessageWidget(message: m, svc: _svc, audioPlayers: _audioPlayers),
                )
              else if (m.type == 'm.file')
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
                  child: _FileMessageWidget(message: m, svc: _svc),
                )
              else
                Text(
                  m.text,
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: m.isOwn ? AppColors.ownBubbleText(context) : AppColors.otherBubbleText(context),
                  ),
                ),
              if (caption != null) ...[
                const SizedBox(height: 8),
                Text(
                  caption,
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: m.isOwn ? AppColors.ownBubbleText(context) : AppColors.otherBubbleText(context),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    MessageTimeFormatter.formatTime(m.time),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: m.isOwn ? AppColors.ownBubbleText(context).withValues(alpha: 0.68) : AppColors.otherBubbleText(context).withValues(alpha: 0.68),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (m.isOwn) ...[
                    const SizedBox(width: 4),
                    MessageStatusIcon(
                      isPending: m.isPending,
                      isDelivered: m.isDelivered,
                      isRead: m.isRead,
                    ),
                  ],
                ],
              ),
              // reactions row
              if ((_reactions[m.id] ?? {}).isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 4, children: [
                  for (final entry in (_reactions[m.id] ?? {}).entries)
                    GestureDetector(
                      onTap: () async {
                        // toggle reaction: if myEventId present -> redact it, else send reaction
                        final data = entry.value as Map<String, dynamic>;
                        final myEvent = data['myEventId'] as String?;
                        try {
                          if (myEvent == 'local') {
                            _toggleReactionLocally(m.id, entry.key);
                          } else if (myEvent != null && myEvent.isNotEmpty) {
                            await _svc.redactEvent(widget.chat.id, myEvent);
                            _toggleReactionLocally(m.id, entry.key);
                          } else {
                            await _svc.sendReaction(roomId: widget.chat.id, eventId: m.id, reaction: entry.key);
                            _toggleReactionLocally(m.id, entry.key);
                          }
                        } catch (_) {}
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.reactionBackground(context), borderRadius: BorderRadius.circular(12)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(entry.key, style: TextStyle(fontSize: 14, color: ((entry.value as Map)['myEventId'] != null) ? Theme.of(context).colorScheme.primary : AppColors.subtitleText(context))),
                          const SizedBox(width: 6),
                          Text('${(entry.value as Map)['count']}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtitleText(context))),
                        ]),
                      ),
                    ),
                ]),
              ]
            ]);

          // Date separator
          final showDateSep = messageIndex == 0 ||
              _differentDay(visibleMessages[messageIndex - 1].time, m.time);

          final messageWidget = Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: RepaintBoundary(
              child: Dismissible(
                key: Key('dismiss_${m.id}'),
                direction: DismissDirection.startToEnd,
                confirmDismiss: (direction) async {
                  _sendReplyForEvent(m.id);
                  return false; // don't actually dismiss
                },
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  child: Icon(Icons.reply, color: Theme.of(context).colorScheme.primary),
                ),
                child: KeyedSubtree(
                  key: key,
                  child: Row(
                    mainAxisAlignment:
                        m.isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!m.isOwn)
                        GestureDetector(
                          onTap: () => _openUserProfile(
                            m.senderId ?? '',
                            initialName: m.senderName,
                            initialAvatar: m.senderAvatar,
                          ),
                          child: UserAvatar(
                            avatarUrl: m.senderAvatar,
                            name: m.senderName ?? '?',
                            radius: 16,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: GestureDetector(
                          onLongPressStart: (details) =>
                              _showMessageActions(m, details.globalPosition),
                          child: _SquishyBubble(
                            isOwn: m.isOwn,
                              highlighted: timeline.highlighted.contains(m.id),
                            bubbleRounding: bubbleRounding,
                            dynamicBubbles: dynamicBubbles,
                            child: bubbleContent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

          if (!showDateSep) return messageWidget;
          final l10nLocal = AppLocalizations.of(context)!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DateSeparator(
                label: MessageTimeFormatter.formatDateSeparator(
                  m.time,
                  todayLabel: l10nLocal.callsTodaySection,
                  yesterdayLabel: l10nLocal.yesterdayLabel,
                ),
              ),
              messageWidget,
            ],
          );
        },
          childCount: visibleMessages.length +
              (timeline.loadingMoreHistory ? 1 : 0),
          addAutomaticKeepAlives: false,
          addSemanticIndexes: false,
          ),
        );
      },
    );
      },
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.85),
        title: InkWell(
          onTap: _directPeerUserId != null
              ? () => _openUserProfile(
                    _directPeerUserId!,
                    initialName: headerName,
                    initialAvatar: headerAvatarUrl,
                  )
              : _openChatSettings,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Hero(
                tag: 'avatar_${widget.chat.id}',
                child: UserAvatar(
                  avatarUrl: headerAvatarUrl,
                  name: headerName,
                  radius: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      headerName,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (presenceLabel != null)
                      Text(
                        presenceLabel,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: _headerPresenceColor(context),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: ScreenBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth >= (UITokens.desktopBreakpoint + 100)
                  ? 980.0
                  : double.infinity;
              final colorScheme = Theme.of(context).colorScheme;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: DropTarget(
                    onDragEntered: (_) {
                      if (!mounted) return;
                      setState(() => _desktopDropActive = true);
                    },
                    onDragExited: (_) {
                      if (!mounted) return;
                      setState(() => _desktopDropActive = false);
                    },
                    onDragDone: (detail) {
                      final paths = detail.files
                          .map((file) => file.path)
                          .where((path) => path.isNotEmpty)
                          .toList(growable: false);
                      unawaited(_enqueueDroppedFiles(paths));
                    },
                    child: Stack(
                      children: [
                        Column(children: [
                          Expanded(child: bodyWidget),
                          if (_isTyping)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: TypingIndicator(dotColor: AppColors.subtitleText(context)),
                                ),
                              ),
                            ),
                          if (_pendingAttachments.isNotEmpty)
                            _buildAttachmentPreviewTray(colorScheme),
                          if (_uploadProgress != null)
                            _buildUploadProgressCard(colorScheme),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(children: [
                                IconButton(
                                  icon: Icon(Icons.attach_file, color: colorScheme.onSurfaceVariant),
                                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                                  onPressed: _sending ? null : _pickAttachments,
                                ),
                                if (!_voiceService.isRecording && _pendingAttachments.isEmpty)
                                  IconButton(
                                    icon: Icon(Icons.mic, color: colorScheme.onSurfaceVariant),
                                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                                    onPressed: _sending ? null : _recordVoiceMessage,
                                  )
                                else if (_voiceService.isRecording)
                                  IconButton(
                                    icon: Icon(Icons.mic, color: AppColors.recording(context)),
                                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                                    onPressed: _voiceService.isRecording ? _stopVoiceAndSend : null,
                                  )
                                else
                                  const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    style: TextStyle(color: colorScheme.onSurface),
                                    decoration: InputDecoration(
                                      hintText: _pendingAttachments.isNotEmpty
                                          ? AppLocalizations.of(context)!.addCaptionHint
                                          : AppLocalizations.of(context)!.messageInputHint,
                                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                                      border: InputBorder.none,
                                    ),
                                    enabled: !_voiceService.isRecording,
                                    maxLines: null,
                                  ),
                                ),
                                IconButton(
                                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                                  icon: _sending
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Icon(Icons.send, color: colorScheme.primary),
                                  onPressed: (_sending || _voiceService.isRecording)
                                      ? null
                                      : _sendText,
                                ),
                              ]),
                            ),
                          ),
                        ]),
                        _buildDesktopDropOverlay(colorScheme),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Msg {
  final String id;
  final String text;
  final bool isOwn;
  final DateTime time;
  final String? senderId;
  final String? senderName;
  final String? senderAvatar;
  final String? type;
  final String? mediaId;
  final bool isDelivered;
  final bool isRead;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final bool isPending;

  _Msg({required this.id, required this.text, required this.isOwn, required this.time, this.senderId, this.senderName, this.senderAvatar, this.type, this.mediaId, this.isDelivered = false, this.isRead = false, this.deliveredAt, this.readAt, this.isPending = false});
}

class _ComposerAttachment {
  const _ComposerAttachment({
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.type,
  });

  final String path;
  final String name;
  final int sizeBytes;
  final String type;

  bool get isVisual => type == 'm.image' || type == 'm.video';

  String get defaultMessageText => isVisual ? '' : name;

  IconData get icon {
    switch (type) {
      case 'm.image':
        return Icons.image_outlined;
      case 'm.video':
        return Icons.videocam_outlined;
      case 'm.audio':
        return Icons.audio_file_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }
}

class _ComposerAttachmentCard extends StatelessWidget {
  const _ComposerAttachmentCard({
    required this.attachment,
    required this.colorScheme,
    required this.sending,
    required this.onRemove,
  });

  final _ComposerAttachment attachment;
  final ColorScheme colorScheme;
  final bool sending;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 156,
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: _ComposerAttachmentVisual(
                      attachment: attachment,
                      colorScheme: colorScheme,
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.58),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints.tightFor(width: 30, height: 30),
                      padding: EdgeInsets.zero,
                      tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                      onPressed: sending ? null : onRemove,
                      icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  StorageService.formatBytes(attachment.sizeBytes),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposerAttachmentVisual extends StatefulWidget {
  const _ComposerAttachmentVisual({
    required this.attachment,
    required this.colorScheme,
  });

  final _ComposerAttachment attachment;
  final ColorScheme colorScheme;

  @override
  State<_ComposerAttachmentVisual> createState() =>
      _ComposerAttachmentVisualState();
}

class _ComposerAttachmentVisualState extends State<_ComposerAttachmentVisual> {
  Future<Uint8List?>? _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    _resetThumbnailFuture();
  }

  @override
  void didUpdateWidget(covariant _ComposerAttachmentVisual oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.attachment.path != widget.attachment.path ||
        oldWidget.attachment.type != widget.attachment.type) {
      _resetThumbnailFuture();
    }
  }

  void _resetThumbnailFuture() {
    _thumbnailFuture = widget.attachment.type == 'm.video'
        ? VideoThumbnail.thumbnailData(
            video: widget.attachment.path,
            imageFormat: ImageFormat.JPEG,
            maxWidth: 320,
            quality: 56,
          )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.attachment.type == 'm.image') {
      return Image.file(
        File(widget.attachment.path),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }

    if (widget.attachment.type == 'm.video') {
      return FutureBuilder<Uint8List?>(
        future: _thumbnailFuture,
        builder: (context, snapshot) {
          final bytes = snapshot.data;
          if (bytes == null || bytes.isEmpty) {
            return Stack(
              fit: StackFit.expand,
              children: [
                _buildFallback(),
                const Center(
                  child: Icon(Icons.play_circle_fill_rounded, color: Colors.white70, size: 34),
                ),
              ],
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(bytes, fit: BoxFit.cover),
              Container(color: Colors.black.withValues(alpha: 0.18)),
              const Center(
                child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 34),
              ),
            ],
          );
        },
      );
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.colorScheme.primary.withValues(alpha: 0.24),
            widget.colorScheme.surfaceContainerHighest,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          widget.attachment.icon,
          color: widget.colorScheme.primary,
          size: 34,
        ),
      ),
    );
  }
}

bool _looksLikeFileName(String value) {
  final lower = value.trim().toLowerCase();
  if (lower.isEmpty) {
    return false;
  }
  const fileExtensions = <String>[
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.webp',
    '.mp4',
    '.mov',
    '.webm',
    '.ogg',
    '.m4a',
    '.mp3',
    '.wav',
    '.pdf',
    '.doc',
    '.docx',
    '.xls',
    '.xlsx',
    '.zip',
    '.rar',
    '.txt',
  ];
  return fileExtensions.any(lower.endsWith);
}

String? _messageCaption(_Msg message) {
  if (message.type != 'm.image' && message.type != 'm.video') {
    return null;
  }
  final text = message.text.trim();
  if (text.isEmpty || _looksLikeFileName(text)) {
    return null;
  }
  return text;
}

bool _sameStringList(List<String> left, List<String> right) {
  if (identical(left, right)) return true;
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

bool _sameStringSet(Set<String> left, Set<String> right) {
  if (identical(left, right)) return true;
  if (left.length != right.length) return false;
  for (final value in left) {
    if (!right.contains(value)) return false;
  }
  return true;
}

bool _sameIntMap(Map<String, int> left, Map<String, int> right) {
  if (identical(left, right)) return true;
  if (left.length != right.length) return false;
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) return false;
  }
  return true;
}

class _ImageMessageWidget extends StatefulWidget {
  const _ImageMessageWidget({
    required this.mediaId,
    required this.svc,
    required this.mediaDownloads,
    required this.maxWidth,
    required this.onOpenGallery,
  });

  final String mediaId;
  final AegisChatService svc;
  final Map<String, String> mediaDownloads;
  final double maxWidth;
  final VoidCallback onOpenGallery;

  @override
  State<_ImageMessageWidget> createState() => _ImageMessageWidgetState();
}

class _ImageMessageWidgetState extends State<_ImageMessageWidget>
    with AutomaticKeepAliveClientMixin {
  String? _localPath;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadImage());
  }

  @override
  void didUpdateWidget(covariant _ImageMessageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mediaId != widget.mediaId) {
      _localPath = null;
      _error = null;
      _loading = true;
      unawaited(_loadImage());
    }
  }

  Future<void> _loadImage() async {
    final cachedPath = widget.mediaDownloads[widget.mediaId];
    if (cachedPath != null && await _pathExists(cachedPath)) {
      if (mounted) {
        setState(() {
          _localPath = cachedPath;
          _loading = false;
        });
      }
      return;
    }

    try {
      final path = await widget.svc.downloadMediaToTempFile(widget.mediaId);
      widget.mediaDownloads[widget.mediaId] = path;
      if (!mounted) return;
      setState(() {
        _localPath = path;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) {
      return Container(
        width: widget.maxWidth,
        height: widget.maxWidth * 0.62,
        color: AppColors.mediaPlaceholder(context),
      );
    }
    if (_error != null || _localPath == null) {
      return Container(
        width: widget.maxWidth * 0.68,
        height: widget.maxWidth * 0.42,
        color: AppColors.mediaPlaceholder(context),
        child: Center(
          child: Icon(Icons.broken_image, color: AppColors.iconMuted(context)),
        ),
      );
    }
    return GestureDetector(
      onTap: widget.onOpenGallery,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.mediaSurface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.mediaBorder(context)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: widget.maxWidth,
              maxHeight: widget.maxWidth * 1.35,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: AppColors.mediaSurface(context),
                    child: Image.file(
                      File(_localPath!),
                      fit: BoxFit.contain,
                      cacheWidth: 1200,
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.48),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.open_in_full_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _AudioMessageWidget extends StatefulWidget {
  final _Msg message;
  final AegisChatService svc;
  final Map<String, AudioPlayer> audioPlayers;
  const _AudioMessageWidget({required this.message, required this.svc, required this.audioPlayers});
  @override
  State<_AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _VideoMessageWidget extends StatefulWidget {
  const _VideoMessageWidget({
    required this.message,
    required this.svc,
    required this.mediaDownloads,
    required this.maxWidth,
  });

  final _Msg message;
  final AegisChatService svc;
  final Map<String, String> mediaDownloads;
  final double maxWidth;

  @override
  State<_VideoMessageWidget> createState() => _VideoMessageWidgetState();
}

class _VideoMessageWidgetState extends State<_VideoMessageWidget> {
  String? _localPath;
  Uint8List? _thumbnailBytes;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_prepare());
  }

  @override
  void didUpdateWidget(covariant _VideoMessageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.mediaId != widget.message.mediaId) {
      _localPath = null;
      _thumbnailBytes = null;
      _error = null;
      _loading = true;
      unawaited(_prepare());
    }
  }

  Future<Uint8List?> _buildThumbnail(String path) {
    return VideoThumbnail.thumbnailData(
      video: path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: math.min(widget.maxWidth * 2, 1200).round(),
      quality: 82,
      timeMs: 300,
    );
  }

  Future<void> _prepare() async {
    try {
      final mediaRef = widget.message.mediaId;
      if (mediaRef == null || mediaRef.trim().isEmpty) {
        if (!mounted) return;
        setState(() {
          _error = Exception('Video metadata is missing');
          _loading = false;
        });
        return;
      }
      final cachedPath = widget.mediaDownloads[mediaRef];
      if (cachedPath != null && await _pathExists(cachedPath)) {
        if (!mounted) return;
        setState(() {
          _localPath = cachedPath;
          _loading = false;
        });
        return;
      }
      final path = await widget.svc.downloadMediaToTempFile(mediaRef);
      widget.mediaDownloads[mediaRef] = path;
      final thumbnail = await _buildThumbnail(path);
      if (!mounted) return;
      setState(() {
        _localPath = path;
        _thumbnailBytes = thumbnail;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  String _label() {
    final raw = widget.message.mediaId ?? 'video';
    return raw.split('/').last;
  }

  Future<void> _open() async {
    final path = _localPath;
    if (path == null || path.isEmpty) return;
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MediaPlayer(localPath: path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        width: widget.maxWidth,
        height: widget.maxWidth * 0.56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.mediaPlaceholder(context),
        ),
      );
    }

    if (_error != null || _localPath == null) {
      return Container(
        width: widget.maxWidth,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.mediaPlaceholder(context),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image, color: AppColors.iconMuted(context)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                AppLocalizations.of(context)!.videoUnavailable,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _open,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: widget.maxWidth,
            decoration: BoxDecoration(
              color: AppColors.mediaSurface(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.mediaBorder(context)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: widget.maxWidth,
                      height: widget.maxWidth * 0.56,
                      child: _thumbnailBytes != null
                          ? Image.memory(
                              _thumbnailBytes!,
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                            )
                          : const ColoredBox(
                              color: Colors.black45,
                              child: Center(
                                child: Icon(
                                  Icons.movie_creation_outlined,
                                  size: 48,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.08),
                              Colors.black.withValues(alpha: 0.32),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Positioned.fill(
                      child: Center(
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          size: 56,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.videocam_rounded, size: 14, color: Colors.white),
                            SizedBox(width: 6),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Text(
                    _label(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatImageGalleryDialog extends StatefulWidget {
  const _ChatImageGalleryDialog({
    required this.mediaIds,
    required this.initialIndex,
    required this.svc,
    required this.mediaDownloads,
  });

  final List<String> mediaIds;
  final int initialIndex;
  final AegisChatService svc;
  final Map<String, String> mediaDownloads;

  @override
  State<_ChatImageGalleryDialog> createState() => _ChatImageGalleryDialogState();
}

class _ChatImageGalleryDialogState extends State<_ChatImageGalleryDialog> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<String> _resolvePath(String mediaId) async {
    final cached = widget.mediaDownloads[mediaId];
    if (cached != null && await _pathExists(cached)) {
      return cached;
    }
    final path = await widget.svc.downloadMediaToTempFile(mediaId);
    widget.mediaDownloads[mediaId] = path;
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(8),
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (value) => setState(() => _currentIndex = value),
            itemCount: widget.mediaIds.length,
            itemBuilder: (context, index) {
              final mediaId = widget.mediaIds[index];
              return FutureBuilder<String>(
                future: _resolvePath(mediaId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return InteractiveViewer(
                    maxScale: 4,
                    child: Center(
                      child: Image.file(
                        File(snapshot.data!),
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
              ),
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          Positioned(
            top: 14,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${_currentIndex + 1}/${widget.mediaIds.length}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FileMessageWidget extends StatelessWidget {
  const _FileMessageWidget({
    required this.message,
    required this.svc,
  });

  final _Msg message;
  final AegisChatService svc;

  String _fileLabel() {
    final raw = (message.text.trim().isNotEmpty ? message.text : message.mediaId) ?? 'file';
    return raw.split('/').last;
  }

  IconData _icon() {
    if (message.type == 'm.video') {
      return Icons.movie_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  Future<void> _openFile(BuildContext context) async {
    final mediaRef = message.mediaId;
    if (mediaRef == null || mediaRef.isEmpty) {
      return;
    }

    final path = await svc.downloadMediaToTempFile(mediaRef);
    await share.Share.shareXFiles([share.XFile(path)], subject: _fileLabel());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openFile(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.mediaPlaceholder(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.mediaBorder(context)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon(), color: AppColors.iconMuted(context)),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  _fileLabel(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudioMessageWidgetState extends State<_AudioMessageWidget>
    with TickerProviderStateMixin {
  String? _localPath;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _playing = false;
  bool _preparing = false;
  AudioPlayer? _player;
  List<double> _waveform = [];
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<void>? _completeSub;
  StreamSubscription<PlayerState>? _stateSub;
  Timer? _positionThrottle;
  Duration? _pendingPosition;
  Future<void>? _prepareFuture;
  late final AnimationController _waveformPulse;
  late final AnimationController _interactionPulse;
  bool _hovering = false;
  bool _pressing = false;

  @override
  void initState() {
    super.initState();
    _waveformPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _interactionPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      value: 0,
    );
  }

  void _syncInteractionAnimation() {
    final target = _pressing ? 1.0 : (_hovering ? 0.55 : 0.0);
    _interactionPulse.animateTo(
      target,
      duration: Duration(milliseconds: _pressing ? 110 : 180),
      curve: _pressing ? Curves.easeOutCubic : Curves.easeOut,
    );
  }

  void _setHovering(bool value) {
    if (_hovering == value) {
      return;
    }
    _hovering = value;
    _syncInteractionAnimation();
  }

  void _setPressing(bool value) {
    if (_pressing == value) {
      return;
    }
    _pressing = value;
    _syncInteractionAnimation();
  }

  void _syncWaveformAnimation() {
    if (_playing) {
      if (!_waveformPulse.isAnimating) {
        _waveformPulse.repeat();
      }
      return;
    }
    if (_waveformPulse.isAnimating) {
      _waveformPulse.stop();
    }
  }

  Future<void> _ensurePrepared() async {
    if (_player != null && _localPath != null) return;
    final inFlight = _prepareFuture;
    if (inFlight != null) return inFlight;

    final future = () async {
      if (mounted) {
        setState(() => _preparing = true);
      }
      try {
        final mediaRef = widget.message.mediaId ?? widget.message.text;
        final path = await widget.svc.downloadMediaToTempFile(mediaRef);
        if (!mounted) return;
        _localPath = path;

        if (_waveform.isEmpty) {
          try {
            final waveform = await widget.svc.getWaveformForMedia(
              widget.message.mediaId ?? '',
              path,
              samples: 40,
            );
            if (mounted && waveform.isNotEmpty) {
              _waveform = waveform;
            }
          } catch (_) {}
        }

        _player = widget.audioPlayers[widget.message.id] ?? AudioPlayer();
        widget.audioPlayers[widget.message.id] = _player!;
        // Evict oldest audio players to bound memory.
        while (widget.audioPlayers.length > _ChatScreenState._maxAudioPlayers) {
          final oldest = widget.audioPlayers.keys.first;
          if (oldest == widget.message.id) break;
          final old = widget.audioPlayers.remove(oldest);
          unawaited(old?.dispose());
        }
        await _player!.setReleaseMode(ReleaseMode.stop);
        await _player!.setSource(DeviceFileSource(_localPath!));
        _durationSub ??= _player!.onDurationChanged.listen((duration) {
          if (mounted) {
            setState(() => _duration = duration);
          }
        });
        _positionSub ??= _player!.onPositionChanged.listen((position) {
          _pendingPosition = position;
          _positionThrottle ??= Timer(
            const Duration(milliseconds: 100),
            () {
              _positionThrottle = null;
              if (mounted) {
                setState(() => _position = _pendingPosition ?? position);
              }
            },
          );
        });
        _completeSub ??= _player!.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() {
              _playing = false;
              _position = Duration.zero;
            });
            _syncWaveformAnimation();
          }
        });
        _stateSub ??= _player!.onPlayerStateChanged.listen((state) {
          if (!mounted) {
            return;
          }
          setState(() {
            _playing = state == PlayerState.playing;
          });
          _syncWaveformAnimation();
        });
      } catch (_) {
      } finally {
        _prepareFuture = null;
        if (mounted) {
          setState(() => _preparing = false);
        }
      }
    }();

    _prepareFuture = future;
    return future;
  }

  @override
  void dispose() {
    _durationSub?.cancel();
    _positionSub?.cancel();
    _completeSub?.cancel();
    _stateSub?.cancel();
    _positionThrottle?.cancel();
    _waveformPulse.dispose();
    _interactionPulse.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    await _ensurePrepared();
    if (_player == null || _localPath == null) return;
    if (_playing) {
      await _player!.pause();
      setState(() => _playing = false);
      _syncWaveformAnimation();
    } else {
      try {
        if (_position > Duration.zero &&
            (_duration == Duration.zero || _position < _duration)) {
          await _player!.resume();
        } else {
          await _player!.seek(Duration.zero);
          await _player!.resume();
        }
      } catch (e) {
        try {
          await _player!.setSource(DeviceFileSource(_localPath!));
          await _player!.seek(Duration.zero);
          await _player!.resume();
        } catch (_) {}
      }
      setState(() => _playing = true);
      _syncWaveformAnimation();
    }
  }

  Future<void> _seekTo(double rel) async {
    await _ensurePrepared();
    if (_player == null || _duration == Duration.zero) return;
    final ms = (_duration.inMilliseconds * rel).round();
    await _player!.seek(Duration(milliseconds: ms));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final samples = _waveform.isNotEmpty
        ? _waveform
        : List<double>.generate(36, (i) => 0.22 + ((i % 5) * 0.06));
    final progress = (_duration.inMilliseconds > 0)
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final totalLabel =
        _duration > Duration.zero ? _formatDuration(_duration) : _formatDuration(_position);
    final currentLabel = _formatDuration(_position);

    return AnimatedBuilder(
      animation: _interactionPulse,
      builder: (context, _) {
        final interactionValue = _interactionPulse.value;
        final accent = theme.colorScheme.primary;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => _setHovering(true),
          onExit: (_) {
            _setHovering(false);
            _setPressing(false);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: (_) => _setPressing(true),
            onTapUp: (_) => _setPressing(false),
            onTapCancel: () => _setPressing(false),
            child: Transform.scale(
              scale: 1 - (interactionValue * 0.012),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.fromLTRB(8, 8, 10, 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.07 + interactionValue * 0.04),
                        accent.withValues(alpha: (_playing ? 0.12 : 0.05) + interactionValue * 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: Color.lerp(
                        Colors.white.withValues(alpha: 0.06),
                        accent.withValues(alpha: 0.30),
                        (_playing ? 0.55 : 0.18) + interactionValue * 0.32,
                      )!,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: (_playing ? 0.12 : 0.04) + interactionValue * 0.08),
                        blurRadius: 16 + interactionValue * 10,
                        offset: Offset(0, 6 + interactionValue * 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      AnimatedScale(
                        duration: const Duration(milliseconds: 140),
                        curve: Curves.easeOutBack,
                        scale: _pressing ? 0.92 : (_hovering ? 1.03 : 1),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _preparing ? null : _togglePlay,
                            child: Ink(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accent.withValues(alpha: _playing ? 0.22 : 0.14),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: _playing ? 0.18 : 0.10),
                                ),
                              ),
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 180),
                                  transitionBuilder: (child, animation) {
                                    return ScaleTransition(
                                      scale: CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOutBack,
                                      ),
                                      child: FadeTransition(opacity: animation, child: child),
                                    );
                                  },
                                  child: _preparing
                                      ? const SizedBox(
                                          key: ValueKey('loading'),
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Icon(
                                          _playing
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          key: ValueKey<bool>(_playing),
                                          size: _playing ? 24 : 28,
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTapDown: (details) {
                                if (_duration == Duration.zero || constraints.maxWidth <= 0) {
                                  return;
                                }
                                final rel = (details.localPosition.dx / constraints.maxWidth)
                                    .clamp(0.0, 1.0);
                                _seekTo(rel);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.06),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _playing
                                                    ? accent
                                                    : Colors.white.withValues(alpha: 0.6),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '$currentLabel / $totalLabel',
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: Colors.white.withValues(alpha: 0.84),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 46,
                                    width: double.infinity,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface.withValues(
                                          alpha: 0.08 + interactionValue * 0.04,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: (_playing ? 0.12 : 0.06) + interactionValue * 0.06,
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        child: AnimatedBuilder(
                                          animation: Listenable.merge([
                                            _waveformPulse,
                                            _interactionPulse,
                                          ]),
                                          builder: (context, _) {
                                            return RepaintBoundary(
                                              child: CustomPaint(
                                                painter: WaveformPainter(
                                                  samples,
                                                  baseColor: Colors.white.withValues(alpha: 0.24),
                                                  playedColor: accent,
                                                  progress: progress,
                                                  pulsePhase: _waveformPulse.value,
                                                  isPlaying: _playing,
                                                  strokeWidth: 3,
                                                ),
                                                child: const SizedBox.expand(),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}

bool _differentDay(DateTime a, DateTime b) {
  final la = a.toLocal();
  final lb = b.toLocal();
  return la.year != lb.year || la.month != lb.month || la.day != lb.day;
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.dateSeparatorBg(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.dateSeparatorText(context),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _SquishyBubble extends StatefulWidget {
  final Widget child;
  final bool isOwn;
  final bool highlighted;
  final double bubbleRounding;
  final bool dynamicBubbles;

  const _SquishyBubble({
    required this.child,
    required this.isOwn,
    required this.bubbleRounding,
    required this.dynamicBubbles,
    this.highlighted = false,
  });

  @override
  State<_SquishyBubble> createState() => _SquishyBubbleState();
}

class _SquishyBubbleState extends State<_SquishyBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), 
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
         if (widget.dynamicBubbles) _controller.forward();
      },
      onTapUp: (_) {
         if (widget.dynamicBubbles) _controller.reverse();
      },
      onTapCancel: () {
         if (widget.dynamicBubbles) _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: widget.isOwn ? AppColors.ownBubble(context) : AppColors.otherBubble(context),
            borderRadius: BorderRadius.circular(widget.bubbleRounding),
             border: widget.highlighted 
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
              : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
