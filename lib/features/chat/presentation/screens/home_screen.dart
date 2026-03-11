import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/utils/message_time_formatter.dart';
import 'package:two_space_app/core/widgets/app_logo.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/create_chat_screen.dart';
import 'package:two_space_app/features/chat/presentation/widgets/start_chat_bottom_sheet.dart';
import 'package:two_space_app/features/profile/presentation/screens/search_contacts_screen.dart';
import 'package:two_space_app/features/profile/presentation/widgets/user_avatar.dart';
import 'package:two_space_app/features/settings/presentation/screens/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const Duration _refreshInterval = Duration(seconds: 45);
  final AegisChatService _chat = AegisChatService();
  List<Map<String, dynamic>> _rooms = [];
  bool _loading = true;
  String? _errorMessage;
  StreamSubscription<List<Chat>>? _roomsSub;
  Timer? _refreshTimer;

  final String _searchQuery = '';

  List<Map<String, dynamic>> get _filteredRooms {
    if (_searchQuery.isEmpty) return _rooms;
    return _rooms.where((r) {
      final name = (r['name'] as String?)?.toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    unawaited(_loadCachedRooms());
    _subscribeToRooms();
    _startBackgroundRefresh();
  }

  @override
  void dispose() {
    _roomsSub?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadCachedRooms() async {
    try {
      final chats = await _chat.getChats();
      if (!mounted) return;
      setState(() {
        _rooms = chats.map(_roomFromChat).toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _loadUserAndRooms() async {
    if (!mounted) return;
    if (_rooms.isEmpty) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    } else {
      setState(() => _errorMessage = null);
    }

    try {
      await _chat.refreshChats();
      final chats = await _chat.getChats();
      final out = chats.map(_roomFromChat).toList();
      if (mounted) setState(() => _rooms = out);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startBackgroundRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      unawaited(_chat.refreshChatsQuietly());
    });
  }

  void _subscribeToRooms() {
    _roomsSub?.cancel();
    _roomsSub = _chat.watchChats().listen(
      (chats) {
        if (!mounted) return;
        setState(() {
          _rooms = chats.map(_roomFromChat).toList();
          _loading = false;
          _errorMessage = null;
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          _errorMessage = error.toString();
          _loading = false;
        });
      },
    );
  }

  Map<String, dynamic> _roomFromChat(Chat chat) {
    return {
      'id': chat.id,
      'name': chat.name.isNotEmpty ? chat.name : chat.id,
      'avatar': chat.avatarUrl,
      'lastMessage': chat.lastMessage,
      'time': chat.lastMessageTime,
      'roomType': chat.roomType,
      'isOnline': chat.isOnline,
      'presenceStatus': chat.presenceStatus,
      'lastSeenAt': chat.lastSeenAt,
    };
  }

  String? _presenceLabel(Map<String, dynamic> room) {
    final l10n = AppLocalizations.of(context)!;
    final roomType = room['roomType'] as String?;
    if (roomType != 'direct') return null;

    final presenceStatus = room['presenceStatus'] as String?;
    final lastSeenAt = room['lastSeenAt'] as DateTime?;

    switch (presenceStatus) {
      case 'online':
        return l10n.onlineLabel;
      case 'recently':
        return l10n.statusLastSeenRecently;
      case 'long_ago':
        return l10n.offlineLabel;
      case 'was_online':
      case 'offline':
        if (lastSeenAt != null) {
          return MessageTimeFormatter.formatConversationTime(lastSeenAt);
        }
        return l10n.offlineLabel;
      default:
        if (room['isOnline'] == true) return l10n.onlineLabel;
        return null;
    }
  }

  Color _presenceColor(Map<String, dynamic> room) {
    final presenceStatus = room['presenceStatus'] as String?;
    if (presenceStatus == 'online' || room['isOnline'] == true) {
      return const Color(0xFF4CD964);
    }
    if (presenceStatus == 'recently') {
      return Colors.amberAccent;
    }
    return Colors.white54;
  }

  bool _showPresenceBadge(Map<String, dynamic> room) {
    final presenceStatus = room['presenceStatus'] as String?;
    return room['isOnline'] == true ||
        presenceStatus == 'online' ||
        presenceStatus == 'recently';
  }

  String _roomSubtitle(Map<String, dynamic> room) {
    final l10n = AppLocalizations.of(context)!;
    final lastMessage = ((room['lastMessage'] as String?)?.isNotEmpty ?? false)
        ? room['lastMessage'] as String
        : l10n.noMessages;
    final presence = _presenceLabel(room);
    if (presence == null || presence.isEmpty) {
      return lastMessage;
    }
    return '$presence • $lastMessage';
  }

  String _formatRoomTime(DateTime? time) {
    return MessageTimeFormatter.formatConversationTime(time);
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchContactsScreen()),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _openCreateGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateChatScreen(
          initialMode: CreateChatMode.group,
        ),
      ),
    ).then((result) {
      if (result != null) {
        unawaited(_chat.refreshChatsQuietly());
      }
    });
  }

  void _openJoinByCode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateChatScreen(
          initialMode: CreateChatMode.join,
        ),
      ),
    ).then((result) {
      if (result != null) {
        unawaited(_chat.refreshChatsQuietly());
      }
    });
  }

  Future<void> _showStartChatSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StartChatBottomSheet(
        onCreateGroup: _openCreateGroup,
        onInviteUser: _openSearch,
        onJoinByAddress: _openJoinByCode,
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: GlassCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AppLogo(large: false),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.chatsTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.chatsSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _openSearch,
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.white),
                  onPressed: _openSettings,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              l10n.chatsQuickStartTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildQuickAction(
                  context,
                  icon: Icons.edit_outlined,
                  title: l10n.newChatTitle,
                  subtitle: l10n.inviteUserSubtitle,
                  onTap: _openSearch,
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  context,
                  icon: Icons.groups_outlined,
                  title: l10n.createRoomTitle,
                  subtitle: l10n.createRoomSubtitle,
                  onTap: _openCreateGroup,
                ),
                const SizedBox(width: 10),
                _buildQuickAction(
                  context,
                  icon: Icons.link_outlined,
                  title: l10n.joinByCodeTitle,
                  subtitle: l10n.joinByCodeSubtitle,
                  onTap: _openJoinByCode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeroHeader(theme, l10n),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Row(
                  children: [
                    Text(
                      l10n.chatsRecentTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: _loading ? _buildShimmerLoading() : _buildChatList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: _showStartChatSheet,
          icon: const Icon(Icons.add_comment_outlined),
          label: Text(l10n.newChatTitle),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.white.withValues(alpha: 0.1),
            highlightColor: Colors.white.withValues(alpha: 0.2),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 150, height: 16, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(width: 100, height: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatList() {
    final rooms = _filteredRooms;
    if (_errorMessage != null) {
      return AppErrorState(
        title: AppLocalizations.of(context)!.errorGeneric,
        message: _errorMessage!,
        actionLabel: AppLocalizations.of(context)!.retry,
        onAction: _loadUserAndRooms,
      );
    }

    if (rooms.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return Padding(
        padding: const EdgeInsets.all(12),
        child: GlassCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.forum_outlined,
                size: 56,
                color: Colors.white70,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noChats,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.chatsSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openSearch,
                      icon: const Icon(Icons.search),
                      label: Text(l10n.newChatTitle),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openCreateGroup,
                      icon: const Icon(Icons.groups_outlined),
                      label: Text(l10n.createRoomTitle),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      cacheExtent: 500,
      itemCount: rooms.length,
      itemBuilder: (c, i) {
        final r = rooms[i];
        final id = r['id'] as String;

        final item = Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            onTap: () => _openChat(id),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Hero(
                  tag: 'avatar_$id',
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      UserAvatar(
                        avatarUrl: r['avatar'],
                        name: r['name'],
                      ),
                      if ((r['roomType'] as String?) == 'direct' &&
                          _showPresenceBadge(r))
                        Positioned(
                          right: -1,
                          bottom: -1,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: _presenceColor(r),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF1B2025),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _roomSubtitle(r),
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white70),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatRoomTime(r['time'] as DateTime?),
                      style:
                          const TextStyle(fontSize: 12, color: Colors.white54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

        return item;
      },
    );
  }

  void _openChat(String id) {
    final room = _rooms.firstWhere(
      (e) => e['id'] == id,
      orElse: () => {'id': id, 'name': id},
    );
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ChatScreen(
          chat: Chat(
            id: id,
            name: (room['name'] as String?) ?? id,
            avatarUrl: room['avatar'] as String?,
            roomType: room['roomType'] as String?,
            members: const [],
            isOnline: room['isOnline'] == true,
            presenceStatus: room['presenceStatus'] as String?,
            lastSeenAt: room['lastSeenAt'] as DateTime?,
          ),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
      ),
    );
  }
}
