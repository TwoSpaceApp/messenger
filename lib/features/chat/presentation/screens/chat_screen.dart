import 'dart:async';
import 'dart:io';
// import 'package:audioplayers/audioplayers.dart';  // Disabled for Linux
import 'dart:math' as math;

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart' as share;
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/utils/message_time_formatter.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/chat/data/services/aegis_group_service.dart';
import 'package:two_space_app/features/chat/data/services/draft_service.dart';
import 'package:two_space_app/features/chat/data/services/voice_service.dart';
import 'package:two_space_app/features/chat/presentation/screens/chat_settings_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/group_settings_screen.dart';
import 'package:two_space_app/features/chat/presentation/widgets/typing_indicator.dart';
import 'package:two_space_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:two_space_app/features/profile/presentation/widgets/user_avatar.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

// Stub for AudioPlayer when audioplayers is disabled
class AudioPlayer {
  Future<void> setReleaseMode(dynamic mode) async {}
  Future<void> play(dynamic source) async {}
  Future<void> setSource(dynamic source) async {}
  Future<void> pause() async {}
  Future<void> resume() async {}
  Future<void> stop() async {}
  Future<void> seek(Duration position) async {}
  Future<void> dispose() async {}
  Stream<dynamic> get onPlayerStateChanged => const Stream.empty();
  Stream<Duration> get onPositionChanged => const Stream.empty();
  Stream<Duration> get onDurationChanged => const Stream.empty();
  Stream<void> get onPlayerComplete => const Stream.empty();
}

class ReleaseMode {
  static const stop = null;
}

class DeviceFileSource {
  final String path;
  DeviceFileSource(this.path);
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

class _ChatScreenState extends State<ChatScreen> {
  static const int _historyPageSize = 80;
  static const int _userInfoBatchSize = 6;
  final AegisChatService _svc = AegisChatService();
  final TextEditingController _controller = TextEditingController();
  final DraftService _draftService = DraftService();
  List<Map<String, dynamic>> _searchResults = [];
  bool _searching = false;
  List<_Msg> _messages = [];
  final Map<String, Map<String, dynamic>> _reactions = {};
  final ScrollController _listController = ScrollController();
  final Map<String, GlobalKey> _messageKeys = {};
  final Map<String, String> _mediaDownloads = {};
  String? _scrollToEventId;
  final Set<String> _highlighted = {};
  bool _loading = true;
  bool _loadingMoreHistory = false;
  bool _hasMoreHistory = true;
  bool _sending = false;
  final bool _isTyping = false;
  final Map<String, AudioPlayer> _audioPlayers = {};
  final Map<String, Map<String, dynamic>> _userInfoCache = {};
  late final VoiceService _voiceService;
  StreamSubscription<List<AegisRoomMessage>>? _messagesSub;
  int _historyLimit = _historyPageSize;
  String? _currentUserId;
  List<AegisRoomMessage>? _pendingMessageBatch;
  bool _drainingMessageBatch = false;
  String? _headerName;
  String? _headerAvatarUrl;
  String? _headerPresenceStatus;
  DateTime? _headerLastSeenAt;
  
  // Group-related state
  // String? _groupBackgroundColor;
  // String? _groupBackgroundImageUrl;

  List<_Msg> get _visibleMessages {
    final q = (widget.searchQuery ?? '').trim().toLowerCase();
    final type = widget.searchType ?? 'all';
    if (q.isEmpty && type == 'all') return _messages;
    return _messages.where((m) {
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

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    _listController.removeListener(_handleListScroll);
    _listController.dispose();
    _controller.dispose();
    for (final player in _audioPlayers.values) {
      unawaited(player.dispose());
    }
    _voiceService.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldQ = (oldWidget.searchQuery ?? '').trim();
    final newQ = (widget.searchQuery ?? '').trim();
    if (oldWidget.scrollToEventId != widget.scrollToEventId) _scrollToEventId = widget.scrollToEventId;
    if (oldQ != newQ) {
      _performServerSearch(newQ, widget.searchType ?? 'all');
    }
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
          setState(() => _loading = false);
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

  Color _headerPresenceColor() {
    switch (_headerPresenceStatus) {
      case 'online':
        return const Color(0xFF4CD964);
      case 'recently':
        return Colors.amberAccent;
      default:
        return Colors.white60;
    }
  }

  void _handleListScroll() {
    if (!_listController.hasClients || _loadingMoreHistory || !_hasMoreHistory) {
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
        .where((id) => id.isNotEmpty && !_userInfoCache.containsKey(id))
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
    setState(() {
      _userInfoCache.addAll(fetched);
      _messages = _messages.map((message) {
        final info = fetched[message.senderId];
        if (info == null) return message;
        return _Msg(
          id: message.id,
          text: message.text,
          isOwn: message.isOwn,
          time: message.time,
          senderId: message.senderId,
          senderName: info['displayName']?.toString() ?? message.senderName,
          senderAvatar: info['avatarUrl']?.toString() ?? message.senderAvatar,
          type: message.type,
          mediaId: message.mediaId,
        );
      }).toList(growable: false);
    });
  }

  Future<void> _loadOlderMessages() async {
    if (_loadingMoreHistory || !_hasMoreHistory || !mounted) return;
    final previousMaxExtent = _listController.hasClients
        ? _listController.position.maxScrollExtent
        : 0.0;

    setState(() => _loadingMoreHistory = true);
    _historyLimit += _historyPageSize;
    await _loadMessages(forceRefresh: true);
    _subscribeToMessages();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listController.hasClients) return;
      final nextMaxExtent = _listController.position.maxScrollExtent;
      final delta = nextMaxExtent - previousMaxExtent;
      if (delta > 0) {
        _listController.jumpTo(_listController.position.pixels + delta);
      }
    });

    if (mounted) {
      setState(() => _loadingMoreHistory = false);
    }
  }

  Future<void> _performServerSearch(String q, String type) async {
    if (q.isEmpty) {
      setState(() { _searchResults = []; _searching = false; });
      return;
    }
    setState(() { _searching = true; _searchResults = []; });
    try {
      final res = await _svc.searchMessages(query: q, type: type);
      setState(() { _searchResults = res; });
    } catch (_) {
      setState(() { _searchResults = []; });
    } finally {
      if (mounted) setState(() => _searching = false);
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
      for (final m in msgs) {
        final cached = _userInfoCache[m.senderId] ??
            _svc.peekUserInfo(m.senderId) ??
            const <String, dynamic>{};
        if (cached.isNotEmpty) {
          _userInfoCache[m.senderId] = cached;
        } else if (m.senderId.isNotEmpty) {
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
        out.add(_Msg(id: m.id, text: m.content, isOwn: isOwn, time: m.time, senderId: m.senderId, senderName: senderName, senderAvatar: senderAvatar, type: m.type, mediaId: m.mediaId));
      }
      
      if (!mounted) return;
      setState(() {
        _messages = out;
        _hasMoreHistory = msgs.length >= _historyLimit;
        _loading = false;
      });
      if (missingSenderIds.isNotEmpty) {
        unawaited(_prefetchUserInfo(missingSenderIds));
      }
      
      // If we have an initial scroll target, try to scroll to it
      if (_scrollToEventId != null && _scrollToEventId!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            final targetId = _scrollToEventId!;
            final key = _messageKeys[targetId];
            if (key != null && key.currentContext != null) {
              await Scrollable.ensureVisible(key.currentContext!, duration: const Duration(milliseconds: 450), alignment: 0.4, curve: Curves.easeInOut);
              setState(() { _highlighted.clear(); _highlighted.add(targetId); });
            } else {
              // Fallback to index-based scroll
              final idx = _messages.indexWhere((m) => m.id == targetId);
              if (idx >= 0 && _listController.hasClients) {
                const approxItemHeight = 84.0;
                final offset = idx * approxItemHeight;
                await _listController.animateTo(offset.clamp(0.0, _listController.position.maxScrollExtent), duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
                setState(() { _highlighted.clear(); _highlighted.add(targetId); });
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
      if (mounted) setState(() => _loading = false);
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
  final overlay = Overlay.of(context);
    OverlayEntry? entry;
    entry = OverlayEntry(builder: (ctx) {
      final mq = MediaQuery.of(ctx);
      final left = math.max<double>(8, globalPos.dx - 120.0);
      final top = math.max<double>(8, globalPos.dy - 80.0 - mq.viewPadding.top);
      return GestureDetector(
        onTap: () { entry?.remove(); },
        behavior: HitTestBehavior.translucent,
        child: Stack(children: [
          Positioned(left: left, top: top, child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.85, end: 1),
            duration: const Duration(milliseconds: 180),
            builder: (ctx, s, child2) => Transform.scale(scale: s, child: Opacity(opacity: ((s - 0.85) / 0.15).clamp(0.0, 1.0), child: child2)),
            child: Material(
              color: Colors.transparent,
              child: Stack(children: [
                // triangle pointer
                Positioned(left: 20, top: -8, child: Transform.rotate(angle: 0, child: ClipPath(clipper: _TriangleClipper(), child: Container(width: 18, height: 12, color: Theme.of(context).colorScheme.surface)))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)]),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    // reactions row
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      for (final e in ['👍','❤️','😂','🔥','😮','🎉'])
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () async {
                              entry?.remove();
                              _showEmojiBurst(context, e, globalPos);
                              try {
                                await _svc.sendReaction(roomId: widget.chat.id, eventId: m.id, reaction: e);
                                _toggleReactionLocally(m.id, e);
                              } catch (_) {}
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, shape: BoxShape.circle),
                              child: Text(e, style: const TextStyle(fontSize: 18)),
                            ),
                          ),
                        ),
                    ]),
                    const SizedBox(height: 6),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      TextButton.icon(onPressed: () { entry?.remove(); _sendReplyForEvent(m.id); }, icon: const Icon(Icons.reply), label: Text(l10n.replyAction)), 
                      if (m.isOwn) TextButton.icon(onPressed: () { entry?.remove(); _editEvent(m.id, m.text); }, icon: const Icon(Icons.edit), label: Text(l10n.editShort)), 
                      TextButton.icon(onPressed: () { entry?.remove(); _pinUnpinEvent(m.id); }, icon: const Icon(Icons.push_pin), label: Text(l10n.pinAction)), 
                      if (m.isOwn) TextButton.icon(onPressed: () { entry?.remove(); _redactEvent(m.id); }, icon: const Icon(Icons.delete), label: Text(l10n.deleteButton)),
                      TextButton.icon(onPressed: () { entry?.remove(); _shareMessage(m); }, icon: const Icon(Icons.share), label: Text(l10n.shareAction)),
                      TextButton.icon(onPressed: () async { entry?.remove(); final picked = await _showEmojiPickerDialog(); if (picked != null) { try { _showEmojiBurst(context, picked, globalPos); await _svc.sendReaction(roomId: widget.chat.id, eventId: m.id, reaction: picked); _toggleReactionLocally(m.id, picked); } catch (_) {} } }, icon: const Icon(Icons.emoji_emotions), label: Text(l10n.moreButton)),
                    ]),
                  ]),
                ),
              ]),
            ),
          )),
        ]),
      );
    });
  overlay.insert(entry);
  }

  Future<String?> _showEmojiPickerDialog() async {
    String? chosen;
    await showDialog(context: context, builder: (c) {
      return Dialog(child: SizedBox(width: 360, height: 420, child: EmojiPicker(
        onEmojiSelected: (category, emoji) { 
          chosen = emoji.emoji; 
          Navigator.of(c).pop(); 
        }
      )));
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
    if (text.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _sending = true);
    try {
      await _svc.sendMessage(roomId: widget.chat.id, text: text);
      setState(() {
        _controller.text = '';
      });
      _scrollToLatest(animated: true);
      // Clear draft after successful send
      await _draftService.deleteDraft(widget.chat.id);
    } catch (e) {
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
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  Future<void> _stopVoiceAndSend() async {
    final l10n = AppLocalizations.of(context)!;
    final path = await _voiceService.stopRecording();
    if (path == null || !File(path).existsSync()) {
      if (mounted) _showErrorMessage(l10n.recordingError);
      return;
    }

    setState(() => _sending = true);
    try {
      await _svc.sendMessage(
        roomId: widget.chat.id,
        text: '',
        type: 'm.audio',
        mediaFileId: path,
      );
      if (mounted) {
        _scrollToLatest(animated: true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.genericError(e.toString()))));
    } finally {
      if (mounted) setState(() => _sending = false);
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

  Future<void> _sendAttachment() async {
    final l10n = AppLocalizations.of(context)!;
    final res = await FilePicker.platform.pickFiles();
    if (res == null || res.files.isEmpty) return;
    final path = res.files.single.path;
    if (path == null) return;
    setState(() => _sending = true);
    try {
      await _svc.sendMessage(
        roomId: widget.chat.id,
        text: res.files.single.name,
        type: _attachmentMessageType(res.files.single.name),
        mediaFileId: path,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.fileSent), duration: const Duration(seconds: 2)));
    } catch (e) {
      if (mounted) _showErrorMessage(l10n.attachmentSendError(e.toString()));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final headerName = _headerName ?? widget.chat.name;
    final headerAvatarUrl = _headerAvatarUrl ?? widget.chat.avatarUrl;
    final presenceLabel = _directPeerUserId != null ? _headerPresenceLabel(l10n) : null;
    final Widget bodyWidget;
    if (_loading) {
      bodyWidget = const Center(child: CircularProgressIndicator());
    } else if ((widget.searchQuery ?? '').trim().isNotEmpty) {
      if (_searching) {
        bodyWidget = const Center(child: CircularProgressIndicator());
      } else {
        bodyWidget = ListView.separated(
          padding: const EdgeInsets.all(8),
          itemBuilder: (c, i) {
            final item = _searchResults[i];
            final ev = item['event'] as Map<String, dynamic>? ?? {};
            final content = ev['content'] as Map<String, dynamic>? ?? {};
            final body = content['body']?.toString() ?? '';
            final sender = ev['sender']?.toString() ?? '';
            final tsNum = ev['origin_server_ts'] as num?;
            final ts = tsNum != null ? DateTime.fromMillisecondsSinceEpoch(tsNum.toInt()) : null;
            final roomId = (item['context'] is Map) ? ((item['context'] as Map)['room_id']?.toString() ?? '') : '';
            
            // Используем кэшированную информацию вместо отдельного FutureBuilder
            final info = _userInfoCache[sender] ?? {};
            final avatar = info['avatarUrl']?.toString();
            final displayName = info['displayName']?.toString() ?? sender;
            
            return ListTile(
              leading: avatar != null ? UserAvatar(avatarUrl: avatar, radius: 18) : CircleAvatar(radius: 18, child: Text(displayName.isNotEmpty ? displayName[0] : '?')),
              title: Text(body, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text('$displayName${roomId.isNotEmpty ? ' • $roomId' : ''}${ts != null ? ' • ${MessageTimeFormatter.formatTime(ts)}' : ''}'),
              onTap: () async {
                if (roomId.isEmpty) return;
                final infoRoom = await _svc.getRoomNameAndAvatar(roomId);
                final chat = Chat(id: roomId, name: infoRoom['name'] ?? roomId, avatarUrl: infoRoom['avatar'], members: []);
                Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chat: chat, scrollToEventId: ev['event_id']?.toString())));
              },
            );
          },
          separatorBuilder: (_, __) => const Divider(),
          itemCount: _searchResults.length,
        );
      }
    } else {
      final visibleMessages = _visibleMessages;
      bodyWidget = ListView.custom(
        controller: _listController,
        padding: const EdgeInsets.all(12),
        cacheExtent: 1000, // Увеличиваем кэш для лучшей производительности
        childrenDelegate: SliverChildBuilderDelegate(
          (c, i) {
          if (_loadingMoreHistory && i == 0) {
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
          final contentIndex = i - (_loadingMoreHistory ? 1 : 0);
          if (contentIndex.isOdd) {
            return const SizedBox(height: 2);
          }
          final messageIndex = contentIndex ~/ 2;
          final m = visibleMessages[messageIndex];
          final shouldTrackKey = _scrollToEventId == m.id || _highlighted.contains(m.id);
          final key = shouldTrackKey
              ? _messageKeys.putIfAbsent(m.id, GlobalKey.new)
              : null;
          final bubbleContent = Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (!m.isOwn) Text(m.senderName ?? m.senderId ?? '', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.white70)),
              const SizedBox(height: 6),
              if (m.type == 'm.image' && (m.mediaId != null && m.mediaId!.isNotEmpty))
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300, maxHeight: 240),
                    child: _ImageMessageWidget(
                      mediaId: m.mediaId!,
                      svc: _svc,
                      mediaDownloads: _mediaDownloads,
                    ),
                  ),
                )
              else if (m.type == 'm.audio' || (m.text.toLowerCase().endsWith('.ogg') || (m.mediaId?.toLowerCase().endsWith('.ogg') ?? false)))
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                  child: _AudioMessageWidget(message: m, svc: _svc, audioPlayers: _audioPlayers),
                )
              else if (m.type == 'm.file' || m.type == 'm.video')
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                  child: _FileMessageWidget(message: m, svc: _svc),
                )
              else
                Text(
                  m.text,
                  softWrap: true,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    MessageTimeFormatter.formatTime(m.time),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.68),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                        decoration: BoxDecoration(color: const Color(0xFF21262C), borderRadius: BorderRadius.circular(12)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(entry.key, style: TextStyle(fontSize: 14, color: ((entry.value as Map)['myEventId'] != null) ? const Color(0xFF0077FF) : Colors.white70)),
                          const SizedBox(width: 6),
                          Text('${(entry.value as Map)['count']}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
                        ]),
                      ),
                    ),
                ]),
              ]
            ]);
          return RepaintBoundary(
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
              child: const Icon(Icons.reply, color: Colors.blue),
            ),
            child: KeyedSubtree(
              key: key,
              child: Row(
                mainAxisAlignment: m.isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!m.isOwn)
                    GestureDetector(
                      onTap: () => _openUserProfile(
                        m.senderId ?? '',
                        initialName: m.senderName,
                        initialAvatar: m.senderAvatar,
                      ),
                      child: UserAvatar(avatarUrl: m.senderAvatar, name: m.senderName ?? '?', radius: 16),
                    ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: GestureDetector(
                      onLongPressStart: (details) => _showMessageActions(m, details.globalPosition),
                      child: _SquishyBubble(
                        isOwn: m.isOwn,
                        highlighted: _highlighted.contains(m.id),
                        child: bubbleContent,
                      ),
                    ),
                  ),
                  if (m.isOwn) const SizedBox(width: 8),
                  if (m.isOwn) const CircleAvatar(radius: 16, child: Text('Y')),
                ],
              ),
            ),
          ));
        },
          childCount: (visibleMessages.isEmpty ? 0 : visibleMessages.length * 2 - 1) + (_loadingMoreHistory ? 1 : 0),
          addAutomaticKeepAlives: false,
          addSemanticIndexes: false,
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF21262C).withValues(alpha: 0.7),
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
                          color: _headerPresenceColor(),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _openChatSettings,
          ),
        ],
      ),
      body: ScreenBackground(
        child: SafeArea(
          child: Column(children: [
        
        Expanded(child: bodyWidget),
        if (_isTyping)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E3338),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const TypingIndicator(dotColor: Colors.white70),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF21262C),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.attach_file, color: Colors.white54), onPressed: _sending ? null : _sendAttachment),
              if (!_voiceService.isRecording)
                IconButton(
                  icon: const Icon(Icons.mic, color: Colors.white54),
                  onPressed: _sending ? null : _recordVoiceMessage,
                )
              else
                IconButton(
                  icon: const Icon(Icons.mic, color: Colors.red),
                  onPressed: _voiceService.isRecording ? _stopVoiceAndSend : null,
                ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.messageInputHint,
                    hintStyle: const TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                  enabled: !_voiceService.isRecording,
                  maxLines: null,
                ),
              ),
              IconButton(
                icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send, color: Color(0xFF0077FF)),
                onPressed: (_sending || _voiceService.isRecording) ? null : _sendText,
              ),
            ]),
          ),
        )
      ]),
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

  _Msg({required this.id, required this.text, required this.isOwn, required this.time, this.senderId, this.senderName, this.senderAvatar, this.type, this.mediaId});
}

class _ImageMessageWidget extends StatefulWidget {
  const _ImageMessageWidget({
    required this.mediaId,
    required this.svc,
    required this.mediaDownloads,
  });

  final String mediaId;
  final AegisChatService svc;
  final Map<String, String> mediaDownloads;

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
    if (cachedPath != null && File(cachedPath).existsSync()) {
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
        width: 280,
        height: 180,
        color: const Color(0xFF21262C),
      );
    }
    if (_error != null || _localPath == null) {
      return Container(
        width: 120,
        height: 80,
        color: const Color(0xFF21262C),
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.white54),
        ),
      );
    }
    return Image.file(
      File(_localPath!),
      fit: BoxFit.cover,
      width: 280,
      height: 180,
      cacheWidth: 560,
      cacheHeight: 360,
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
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon(), color: Colors.white70),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  _fileLabel(),
                  maxLines: 2,
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
    );
  }
}

class _AudioMessageWidgetState extends State<_AudioMessageWidget> {
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
  Future<void>? _prepareFuture;

  // No fake controller needed; removed unused variable

  @override
  void initState() {
    super.initState();
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
              samples: 24,
            );
            if (mounted && waveform.isNotEmpty) {
              _waveform = waveform;
            }
          } catch (_) {}
        }

        _player = widget.audioPlayers[widget.message.id] ?? AudioPlayer();
        widget.audioPlayers[widget.message.id] = _player!;
        await _player!.setReleaseMode(ReleaseMode.stop);
        _durationSub ??= _player!.onDurationChanged.listen((duration) {
          if (mounted) {
            setState(() => _duration = duration);
          }
        });
        _positionSub ??= _player!.onPositionChanged.listen((position) {
          if (mounted) {
            setState(() => _position = position);
          }
        });
        _completeSub ??= _player!.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() {
              _playing = false;
              _position = Duration.zero;
            });
          }
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
    super.dispose();
  }

  Future<void> _togglePlay() async {
    await _ensurePrepared();
    if (_player == null || _localPath == null) return;
    if (_playing) {
      await _player!.pause();
      setState(() => _playing = false);
    } else {
      try {
        await _player!.play(DeviceFileSource(_localPath!));
      } catch (e) {
        // fallback: try setting source then resume
        try {
          await _player!.setSource(DeviceFileSource(_localPath!));
          await _player!.resume();
        } catch (_) {}
      }
      setState(() => _playing = true);
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
    final samples = (_waveform.isNotEmpty) ? _waveform : List<double>.generate(24, (i) => 0.2 + (i.isEven ? 0.12 : 0.0));
    final bars = Row(mainAxisSize: MainAxisSize.min, children: List.generate(samples.length, (i) { final h = 12.0 + (samples[i] * 48.0); return Container(margin: const EdgeInsets.symmetric(horizontal: 2), width: 4, height: h, decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(2))); }));
    final progress = (_duration.inMilliseconds > 0) ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0) : 0.0;
    return GestureDetector(
      onTapDown: (ev) {
        // allow tapping waveform to seek
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && _duration.inMilliseconds > 0) {
          final local = box.globalToLocal(ev.globalPosition);
          _seekTo((local.dx / box.size.width).clamp(0.0, 1.0));
        }
      },
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          icon: _preparing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : (_playing
                  ? const Icon(Icons.pause_circle)
                  : const Icon(Icons.play_circle)),
          onPressed: _preparing ? null : _togglePlay,
        ),
        Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: math.min(MediaQuery.of(context).size.width * 0.35, 260),
              height: 36,
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.08),
              child: Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: bars)),
            ),
          ),
          Positioned.fill(
            child: FractionallySizedBox(
              widthFactor: progress,
              alignment: Alignment.centerLeft,
              child: Container(decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(8))),
            ),
          ),
        ]),
        const SizedBox(width: 8),
        Text(_formatDuration(_position)),
      ]),
    );
  }

  String _formatDuration(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.moveTo(0, size.height);
    p.lineTo(size.width / 2, 0);
    p.lineTo(size.width, size.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _SquishyBubble extends StatefulWidget {
  final Widget child;
  final bool isOwn;
  final bool highlighted;

  const _SquishyBubble({
    required this.child,
    required this.isOwn,
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
    return ValueListenableBuilder(
      valueListenable: SettingsService.themeNotifier,
      builder: (context, themeSettings, _) {
       final radius = themeSettings.bubbleRounding;
        return GestureDetector(
          onTapDown: (_) {
             if (themeSettings.dynamicBubbles) _controller.forward();
          },
          onTapUp: (_) {
             if (themeSettings.dynamicBubbles) _controller.reverse();
          },
          onTapCancel: () {
             if (themeSettings.dynamicBubbles) _controller.reverse();
          },
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: widget.isOwn ? const Color(0xFF0077FF) : const Color(0xFF2E3338),
                borderRadius: BorderRadius.circular(radius),
                 border: widget.highlighted 
                  ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                  : null,
              ),
              child: widget.child,
            ),
          ),
        );
      }
    );
  }
}
