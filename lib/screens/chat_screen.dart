import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart' as share;
import 'package:two_space_app/services/chat_matrix_service.dart';
import 'package:two_space_app/widgets/user_avatar.dart';
import 'package:two_space_app/services/auth_service.dart';
import 'package:two_space_app/services/voice_service.dart';
import 'package:two_space_app/services/group_matrix_service.dart';
import 'package:two_space_app/services/draft_service.dart';
import 'package:two_space_app/services/call_service.dart';
import 'package:two_space_app/models/chat.dart';
import 'package:two_space_app/screens/profile_screen.dart';
import 'package:two_space_app/widgets/group_background_widget.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as math;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:two_space_app/models/matrix.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final Chat chat;
  final String? searchQuery;
  final String? searchType; // 'all' | 'messages' | 'media' | 'users'
  final String? scrollToEventId;

  const ChatScreen({super.key, required this.chat, this.searchQuery, this.searchType, this.scrollToEventId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ChatMatrixService _svc = ChatMatrixService();
  final TextEditingController _controller = TextEditingController();
  final DraftService _draftService = DraftService();
  List<Map<String, dynamic>> _searchResults = [];
  bool _searching = false;
  List<_Msg> _messages = [];
  final Map<String, Map<String, dynamic>> _reactions = {};
  final ScrollController _listController = ScrollController();
  final Map<String, GlobalKey> _messageKeys = {};
  String? _scrollToEventId;
  final Set<String> _highlighted = {};
  bool _loading = true;
  bool _sending = false;
  final Map<String, AudioPlayer> _audioPlayers = {};
  final Map<String, Map<String, dynamic>> _userInfoCache = {};
  late final VoiceService _voiceService;
  
  // Group-related state
  String? _groupBackgroundColor;
  String? _groupBackgroundImageUrl;

  List<_Msg> get _visibleMessages {
    final q = (widget.searchQuery ?? '').trim().toLowerCase();
    final type = (widget.searchType ?? 'all');
    if (q.isEmpty && type == 'all') return _messages;
    return _messages.where((m) {
      if (type == 'messages') return m.text.toLowerCase().contains(q);
      if (type == 'media') {
        // crude media detection: contains mxc:// or http and common extensions
        final t = m.text.toLowerCase();
        if (t.contains('mxc://') || t.contains('http')) return true;
        final exts = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.mp4', '.mov'];
        return exts.any((e) => t.endsWith(e));
      }
      if (type == 'users') return m.text.toLowerCase().contains('@') || m.text.toLowerCase().contains('invite');
      // all
      return q.isEmpty ? true : m.text.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _voiceService = VoiceService();
    _voiceService.init();
    _loadMessages();
    _loadGroupSettings();
    _scrollToEventId = widget.scrollToEventId;
    // Load draft if exists
    _loadDraft();
    // start sync loop to receive new events
    _svc.startSync((js) {
      _handleSync(js);
    });
  }

  @override
  void dispose() {
    _svc.stopSync();
    _listController.dispose();
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

  void _handleSync(Map<String, dynamic> js) {
    try {
      final rooms = js['rooms'] as Map<String, dynamic>? ?? {};
      final join = rooms['join'] as Map<String, dynamic>? ?? {};
      if (join.containsKey(widget.chat.id)) {
        final room = join[widget.chat.id] as Map<String, dynamic>;
        final timeline = room['timeline'] as Map<String, dynamic>?;
        final events = (timeline?['events'] as List? ?? []);
        for (final ev in events) {
          final e = ev as Map<String, dynamic>;
          final type = e['type'] as String?;
          final content = e['content'] as Map<String, dynamic>? ?? {};

          switch (type) {
            case 'm.room.message':
              if (mounted) _loadMessages();
              break;
            case 'm.call.invite':
              final callId = content['call_id'] as String?;
              final senderId = e['sender'] as String?;
              if (callId != null && senderId != null) {
                // In a real app, you'd get the sender's name and avatar
                ref.read(callServiceProvider.notifier).receiveCall(
                  widget.chat.id,
                  callId,
                  senderId,
                  'Unknown Caller',
                  null,
                );
              }
              break;
            case 'm.call.answer':
              final callId = content['call_id'] as String?;
              if (callId != null && ref.read(callServiceProvider).callId == callId) {
                ref.read(callServiceProvider.notifier).answerCall();
              }
              break;
            case 'm.call.hangup':
              final callId = content['call_id'] as String?;
              if (callId != null && ref.read(callServiceProvider).callId == callId) {
                ref.read(callServiceProvider.notifier).hangupCall();
              }
              break;
          }
        }
      }
    } catch (_) {}
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


  Future<void> _loadMessages() async {
    setState(() => _loading = true);
    try {
      final msgs = await _svc.loadMessages(roomId: widget.chat.id, limit: 100);
      final auth = AuthService();
      final me = await auth.getCurrentUserId();
      
      // Собираем уникальные ID отправителей для параллельной загрузки
      final senderIds = msgs.map((m) => m.senderId).toSet();
      
      // Параллельно загружаем информацию о всех отправителях
      await Future.wait(
        senderIds.map((id) async {
          if (!_userInfoCache.containsKey(id)) {
            try {
              final info = await _svc.getUserInfo(id);
              _userInfoCache[id] = info;
            } catch (_) {
              _userInfoCache[id] = {};
            }
          }
        }),
      );
      
      final out = <_Msg>[];
      for (final m in msgs) {
        final cached = _userInfoCache[m.senderId] ?? {};
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
          isOwn = (me != null && me == m.senderId); 
        }
        out.add(_Msg(id: m.id, text: m.content, isOwn: isOwn, time: m.time, senderId: m.senderId, senderName: senderName, senderAvatar: senderAvatar, type: m.type, mediaId: m.mediaId));
      }
      
      if (!mounted) return;
      setState(() {
        _messages = out;
        _loading = false;
      });
      
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
                final approxItemHeight = 84.0;
                final N = _messages.length;
                final revIdx = (N - 1 - idx);
                final offset = revIdx * approxItemHeight;
                await _listController.animateTo(offset.clamp(0.0, _listController.position.maxScrollExtent), duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
                setState(() { _highlighted.clear(); _highlighted.add(targetId); });
              }
            }
          } catch (_) {}
          _scrollToEventId = null;
        });
      }
      // fetch reactions for messages in background
      for (final m in out) {
        () async {
          try {
            final r = await _svc.getReactions(widget.chat.id, m.id);
            if (mounted) setState(() => _reactions[m.id] = r);
          } catch (_) {}
        }();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки сообщений: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadGroupSettings() async {
    try {
      final groupService = GroupMatrixService();
      final groupRoom = await groupService.getGroupRoom(widget.chat.id);
      if (mounted && groupRoom != null) {
        setState(() {
          _groupBackgroundColor = groupRoom.backgroundColor;
          _groupBackgroundImageUrl = groupRoom.backgroundImageUrl;
        });
      }
    } catch (_) {
      // Not a group room or error loading settings
    }
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
    final text = await showDialog<String>(context: context, builder: (c) {
      final ctl = TextEditingController();
      return AlertDialog(
        title: const Text('Ответить'),
        content: TextField(controller: ctl, decoration: const InputDecoration(hintText: 'Текст ответа')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, null), child: const Text('Отмена')),
          ElevatedButton(onPressed: () => Navigator.pop(c, ctl.text.trim()), child: const Text('Отправить')),
        ],
      );
    });
    if (text == null || text.isEmpty) return;
    try {
      final formatted = '<mx-reply><blockquote>${text.replaceAll('<', '&lt;').replaceAll('>', '&gt;')}</blockquote></mx-reply>';
      await _svc.sendReply(widget.chat.id, eventId, text, formattedText: formatted);
      await _loadMessages();
    } catch (e) {
      if (mounted) _showErrorMessage('Ошибка ответа: $e');
    }
  }



  Future<void> _pinUnpinEvent(String eventId) async {
    try {
      final pinned = await _svc.getPinnedEvents(widget.chat.id);
      if (pinned.contains(eventId)) {
        pinned.remove(eventId);
      } else {
        pinned.insert(0, eventId);
      }
      await _svc.setPinnedEvents(widget.chat.id, pinned);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Закрепления обновлены'), duration: Duration(seconds: 2)));
    } catch (e) {
      if (mounted) _showErrorMessage('Ошибка закрепа: $e');
    }
  }

  Future<void> _redactEvent(String eventId) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Удалить сообщение?'), actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Отмена')), ElevatedButton(onPressed: () => Navigator.pop(c, true), child: const Text('Удалить'))]));
    if (ok != true) return;
    try {
      await _svc.redactEvent(widget.chat.id, eventId);
      await _loadMessages();
    } catch (e) {
      if (mounted) _showErrorMessage('Ошибка удаления: $e');
    }
  }

  Future<void> _editEvent(String eventId, String currentText) async {
    final newText = await showDialog<String>(context: context, builder: (c) {
      final ctl = TextEditingController(text: currentText);
      return AlertDialog(
        title: const Text('Редактировать сообщение'),
        content: TextField(
          controller: ctl,
          decoration: const InputDecoration(hintText: 'Новый текст'),
          maxLines: null,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, null), child: const Text('Отмена')),
          ElevatedButton(onPressed: () => Navigator.pop(c, ctl.text.trim()), child: const Text('Сохранить')),
        ],
      );
    });
    if (newText == null || newText.isEmpty) return;
    try {
      await _svc.editMessage(widget.chat.id, eventId, newText);
      await _loadMessages();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сообщение отредактировано'), duration: Duration(seconds: 2)));
    } catch (e) {
      if (mounted) _showErrorMessage('Ошибка редактирования: $e');
    }
  }

  Future<void> _showMessageActions(_Msg m, Offset globalPos) async {
  final overlay = Overlay.of(context);
    OverlayEntry? entry;
    entry = OverlayEntry(builder: (ctx) {
      final mq = MediaQuery.of(ctx);
      final left = math.max(8.0, globalPos.dx - 120);
      final top = math.max(8.0, globalPos.dy - 80 - mq.viewPadding.top);
      return GestureDetector(
        onTap: () { entry?.remove(); },
        behavior: HitTestBehavior.translucent,
        child: Stack(children: [
          Positioned(left: left, top: top, child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.85, end: 1.0),
            duration: const Duration(milliseconds: 180),
            builder: (ctx, s, child2) => Transform.scale(scale: s, child: Opacity(opacity: ((s - 0.85) / 0.15).clamp(0.0, 1.0), child: child2)),
            child: Material(
              color: Colors.transparent,
              child: Stack(children: [
                // triangle pointer
                Positioned(left: 20, top: -8, child: Transform.rotate(angle: 0.0, child: ClipPath(clipper: _TriangleClipper(), child: Container(width: 18, height: 12, color: Theme.of(context).colorScheme.surface)))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)]),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    // reactions row
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      for (final e in ['👍','❤️','😂','🔥','😮','🎉'])
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: InkWell(
                            onTap: () async {
                              entry?.remove();
                              try {
                                await _svc.sendReaction(roomId: widget.chat.id, eventId: m.id, reaction: e);
                                await _loadMessages();
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
                      TextButton.icon(onPressed: () { entry?.remove(); _sendReplyForEvent(m.id); }, icon: const Icon(Icons.reply), label: const Text('Ответ')), 
                      if (m.isOwn) TextButton.icon(onPressed: () { entry?.remove(); _editEvent(m.id, m.text); }, icon: const Icon(Icons.edit), label: const Text('Редакт.')), 
                      TextButton.icon(onPressed: () { entry?.remove(); _pinUnpinEvent(m.id); }, icon: const Icon(Icons.push_pin), label: const Text('Закрепить')), 
                      if (m.isOwn) TextButton.icon(onPressed: () { entry?.remove(); _redactEvent(m.id); }, icon: const Icon(Icons.delete), label: const Text('Удалить')),
                      TextButton.icon(onPressed: () { entry?.remove(); _shareMessage(m); }, icon: const Icon(Icons.share), label: const Text('Поделиться')),
                      TextButton.icon(onPressed: () async { entry?.remove(); final picked = await _showEmojiPickerDialog(); if (picked != null) { try { await _svc.sendReaction(roomId: widget.chat.id, eventId: m.id, reaction: picked); await _loadMessages(); } catch (_) {} } }, icon: const Icon(Icons.emoji_emotions), label: const Text('Ещё')),
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
        }, 
        config: const Config(
          
          bgColor: Color(0xFF0B0320),
          indicatorColor: Color(0xFF1F5FFF),
          iconColorSelected: Color(0xFF1F5FFF),
        )
      )));
    });
    return chosen;
  }

  /// Share a message with system share sheet
  Future<void> _shareMessage(_Msg message) async {
    try {
      await share.Share.share(message.text);
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Не удалось поделиться: $e');
      }
    }
  }

  Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await _svc.sendMessage(widget.chat.id, text, type: 'm.text');
      setState(() {
        _messages.insert(0, _Msg(id: DateTime.now().millisecondsSinceEpoch.toString(), text: text, isOwn: true, time: DateTime.now(), senderId: '', senderName: 'You', senderAvatar: null, type: 'm.text'));
        _controller.text = '';
      });
      // Clear draft after successful send
      await _draftService.deleteDraft(widget.chat.id);
    } catch (e) {
      if (mounted) _showErrorMessage('Отправка не удалась: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _recordVoiceMessage() async {
    if (!_voiceService.isInitialized) {
      if (mounted) {
        _showErrorMessage('Запись голоса не поддерживается на этой платформе');
      }
      return;
    }
    
    final path = await _voiceService.startRecording();
    if (path == null) {
      if (mounted) {
        _showErrorMessage('Нужно разрешение микрофона');
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
    final path = await _voiceService.stopRecording();
    if (path == null || !File(path).existsSync()) {
      if (mounted) _showErrorMessage('Ошибка записи');
      return;
    }

    setState(() => _sending = true);
    try {
      await _svc.sendMessage(widget.chat.id, path, type: 'm.audio', mediaFileId: path);
      
      if (mounted) {
        setState(() {
          _messages.insert(0, _Msg(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: path,
            isOwn: true,
            time: DateTime.now(),
            senderId: '',
            senderName: 'You',
            senderAvatar: null,
            type: 'm.audio',
            mediaId: path,
          ));
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _sendAttachment() async {
    final res = await FilePicker.platform.pickFiles();
    if (res == null || res.files.isEmpty) return;
    final path = res.files.single.path;
    if (path == null) return;
    setState(() => _sending = true);
    try {
      final bytes = await File(path).readAsBytes();
      final mxc = await _svc.uploadMedia(bytes, 'application/octet-stream', res.files.single.name);
      await _svc.sendMessage(widget.chat.id, '', type: 'm.image', mediaFileId: mxc);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Файл отправлен'), duration: Duration(seconds: 2)));
    } catch (e) {
      if (mounted) _showErrorMessage('Ошибка отправки вложения: $e');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              subtitle: Text('$displayName${roomId.isNotEmpty ? ' • $roomId' : ''}${ts != null ? ' • ${ts.hour.toString().padLeft(2,'0')}:${ts.minute.toString().padLeft(2,'0')}' : ''}'),
              onTap: () async {
                if (roomId.isEmpty) return;
                final infoRoom = await _svc.getRoomNameAndAvatar(roomId);
                final chat = Chat(id: roomId, name: infoRoom['name'] ?? roomId, avatarUrl: infoRoom['avatar'], members: [], lastMessage: '');
                Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chat: chat, scrollToEventId: ev['event_id']?.toString())));
              },
            );
          },
          separatorBuilder: (_, __) => const Divider(),
          itemCount: _searchResults.length,
        );
      }
    } else {
      bodyWidget = ListView.separated(
        reverse: true,
        controller: _listController,
        padding: const EdgeInsets.all(12),
        cacheExtent: 1000, // Увеличиваем кэш для лучшей производительности
        addRepaintBoundaries: true, // Добавляем репaint boundaries для оптимизации
        itemBuilder: (c, i) {
          final m = _visibleMessages[i];
          final key = _messageKeys.putIfAbsent(m.id, () => GlobalKey());
          final bubble = Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(color: m.isOwn ? const Color(0xFF0077FF) : const Color(0xFF2E3338), borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (!m.isOwn) Text(m.senderName ?? m.senderId ?? '', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.white70)),
              const SizedBox(height: 6),
              if (m.type == 'm.image' && (m.mediaId != null && m.mediaId!.isNotEmpty))
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300, maxHeight: 240),
                    child: FutureBuilder<String>(
                      future: _svc.downloadMediaToTempFile(m.mediaId!),
                      builder: (ctx, snap) {
                        if (snap.connectionState != ConnectionState.done) return Container(width: 280, height: 180, color: const Color(0xFF21262C));
                        if (snap.hasError || snap.data == null) return Container(width: 120, height: 80, color: const Color(0xFF21262C), child: const Center(child: Icon(Icons.broken_image, color: Colors.white54)));
                        return Image.file(File(snap.data!), fit: BoxFit.cover, width: 280, height: 180);
                      },
                    ),
                  ),
                )
              else if (m.type == 'm.audio' || (m.text.toLowerCase().endsWith('.ogg') || (m.mediaId?.toLowerCase().endsWith('.ogg') ?? false)))
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                  child: _AudioMessageWidget(message: m, svc: _svc, audioPlayers: _audioPlayers),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                  child: Text(
                    m.text,
                    softWrap: true,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
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
                          if (myEvent != null && myEvent.isNotEmpty) {
                            await _svc.redactEvent(widget.chat.id, myEvent);
                          } else {
                            await _svc.sendReaction(roomId: widget.chat.id, eventId: m.id, reaction: entry.key);
                          }
                          final r = await _svc.getReactions(widget.chat.id, m.id);
                          if (mounted) setState(() => _reactions[m.id] = r);
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
            ]),
          );
          return KeyedSubtree(
            key: key,
            child: Row(
              mainAxisAlignment: m.isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!m.isOwn)
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userId: m.senderId ?? ''))),
                    child: UserAvatar(avatarUrl: m.senderAvatar, name: (m.senderName ?? '?'), radius: 16),
                  ),
                const SizedBox(width: 8),
                Flexible(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 8.0, end: 0.0),
                    duration: Duration(milliseconds: 240 + (i % 5) * 30),
                    builder: (context, val, child) => Transform.translate(offset: Offset(0, val), child: Opacity(opacity: 1.0 - (val / 12.0).clamp(0.0, 1.0), child: child)),
                    child: GestureDetector(
                      onLongPressStart: (details) => _showMessageActions(m, details.globalPosition),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 400),
                                      curve: Curves.easeInOut,
                                      decoration: _highlighted.contains(m.id)
                                          ? BoxDecoration(border: Border.all(color: const Color(0xFF0077FF), width: 2), color: const Color(0xFF0077FF).withOpacity(0.08), borderRadius: BorderRadius.circular(16))
                                          : null,
                                      child: bubble,
                                    ),
                    ),
                  ),
                ),
                if (m.isOwn) const SizedBox(width: 8),
                if (m.isOwn) const CircleAvatar(radius: 16, child: Text('Y')),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 2),
        itemCount: _visibleMessages.length,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // For simplicity, we'll assume the other user is the first member of the chat
              // In a real app, you would have a more robust way to determine the other user
              final otherUser = widget.chat.members.firstWhere((m) => m != 'me', orElse: () => 'unknown');
              ref.read(callServiceProvider.notifier).startCall(
                widget.chat.id,
                otherUser,
                widget.chat.name, // Assuming chat name is the other user's name
                widget.chat.avatarUrl,
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1D2227),
      body: Column(children: [
        Expanded(child: bodyWidget),
        Padding(
          padding: const EdgeInsets.all(8.0),
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
                  decoration: const InputDecoration(
                    hintText: 'Send a message...',
                    hintStyle: TextStyle(color: Colors.white54),
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

class _AudioMessageWidget extends StatefulWidget {
  final _Msg message;
  final ChatMatrixService svc;
  final Map<String, AudioPlayer> audioPlayers;
  const _AudioMessageWidget({required this.message, required this.svc, required this.audioPlayers});
  @override
  State<_AudioMessageWidget> createState() => _AudioMessageWidgetState();
}

class _AudioMessageWidgetState extends State<_AudioMessageWidget> {
  String? _localPath;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _playing = false;
  AudioPlayer? _player;
  List<double> _waveform = [];

  // No fake controller needed; removed unused variable

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final m = widget.message.mediaId ?? widget.message.text;
        final path = await widget.svc.downloadMediaToTempFile(m);
      if (!mounted) return;
      setState(() => _localPath = path);
      // request waveform (cached by service)
      try {
        final wf = await widget.svc.getWaveformForMedia(mediaId: widget.message.mediaId ?? '', localPath: path, samples: 24);
        if (mounted) setState(() => _waveform = wf);
      } catch (_) {}
      _player = widget.audioPlayers[widget.message.id] ?? AudioPlayer();
      widget.audioPlayers[widget.message.id] = _player!;
      // ensure player is in low-latency mode for small clips
      await _player!.setReleaseMode(ReleaseMode.stop);
      _player!.onDurationChanged.listen((d) => setState(() => _duration = d));
      _player!.onPositionChanged.listen((p) => setState(() => _position = p));
      _player!.onPlayerComplete.listen((_) => setState(() { _playing = false; _position = Duration.zero; }));
    } catch (_) {}
  }

  @override
  void dispose() {
    // Do not dispose shared players here
    super.dispose();
  }

  Future<void> _togglePlay() async {
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
    if (_player == null || _duration == Duration.zero) return;
    final ms = (_duration.inMilliseconds * rel).round();
    await _player!.seek(Duration(milliseconds: ms));
  }

  @override
  Widget build(BuildContext context) {
    final samples = (_waveform.isNotEmpty) ? _waveform : List<double>.generate(24, (i) => 0.2 + (i.isEven ? 0.12 : 0.0));
    final bars = Row(mainAxisSize: MainAxisSize.min, children: List.generate(samples.length, (i) { final h = 12.0 + (samples[i] * 48.0); return Container(margin: const EdgeInsets.symmetric(horizontal: 2), width: 4, height: h, decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12), borderRadius: BorderRadius.circular(2))); }));
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
        IconButton(icon: _playing ? const Icon(Icons.pause_circle) : const Icon(Icons.play_circle), onPressed: _togglePlay),
        Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: math.min(MediaQuery.of(context).size.width * 0.35, 260.0),
              height: 36,
              color: Theme.of(context).colorScheme.surface.withOpacity(0.08),
              child: Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: bars)),
            ),
          ),
          Positioned.fill(
            child: FractionallySizedBox(
              widthFactor: progress,
              alignment: Alignment.centerLeft,
              child: Container(decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.18), borderRadius: BorderRadius.circular(8))),
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
