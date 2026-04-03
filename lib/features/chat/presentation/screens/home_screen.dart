import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/utils/message_time_formatter.dart';
import 'package:two_space_app/core/widgets/app_logo.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/core/widgets/section_card.dart';
import 'package:two_space_app/core/widgets/unread_badge.dart';
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
  final AegisChatService _chat = AegisChatService();
  List<Map<String, dynamic>> _rooms = [];
  bool _loading = true;
  String? _errorMessage;
  StreamSubscription<List<Chat>>? _roomsSub;
  Future<void>? _roomRefreshInFlight;

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
    _subscribeToRooms();
    unawaited(_loadUserAndRooms());
  }

  @override
  void dispose() {
    _roomsSub?.cancel();
    super.dispose();
  }

  Future<void> _loadUserAndRooms() async {
    final inFlight = _roomRefreshInFlight;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final future = _refreshRoomIndex();
    _roomRefreshInFlight = future;
    try {
      await future;
    } finally {
      if (identical(_roomRefreshInFlight, future)) {
        _roomRefreshInFlight = null;
      }
    }
  }

  Future<void> _refreshRoomIndex() async {
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
      await _chat.refreshChatIndex(
        preloadRooms: 0,
        messageLimit: 0,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _subscribeToRooms() {
    _roomsSub?.cancel();
    _roomsSub = _chat.watchChats().listen(
      (chats) {
        final nextRooms = chats.map(_roomFromChat).toList(growable: false);
        if (!mounted) return;
        if (_roomListsEqual(_rooms, nextRooms) && !_loading && _errorMessage == null) {
          return;
        }
        setState(() {
          _rooms = nextRooms;
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
      'unreadCount': chat.unreadCount,
      'roomType': chat.roomType,
      'isOnline': chat.isOnline,
      'presenceStatus': chat.presenceStatus,
      'lastSeenAt': chat.lastSeenAt,
    };
  }

  bool _roomListsEqual(
    List<Map<String, dynamic>> left,
    List<Map<String, dynamic>> right,
  ) {
    if (identical(left, right)) return true;
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      final leftItem = left[index];
      final rightItem = right[index];
      if (leftItem['id'] != rightItem['id'] ||
          leftItem['name'] != rightItem['name'] ||
          leftItem['avatar'] != rightItem['avatar'] ||
          leftItem['lastMessage'] != rightItem['lastMessage'] ||
          leftItem['time'] != rightItem['time'] ||
          leftItem['unreadCount'] != rightItem['unreadCount'] ||
          leftItem['roomType'] != rightItem['roomType'] ||
          leftItem['isOnline'] != rightItem['isOnline'] ||
          leftItem['presenceStatus'] != rightItem['presenceStatus'] ||
          leftItem['lastSeenAt'] != rightItem['lastSeenAt']) {
        return false;
      }
    }
    return true;
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
      return AppColors.onlineStatus(context);
    }
    if (presenceStatus == 'recently') {
      return AppColors.recentlyStatus(context);
    }
    return AppColors.offlineStatus(context);
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

  Widget _buildHeroHeader(
    ThemeData theme,
    AppLocalizations l10n,
    int roomCount,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: SectionCard(
        radius: UITokens.cornerXL,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const AppLogo(large: false),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.chatsTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$roomCount',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        l10n.noMessages,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _showStartChatSheet,
              icon: const Icon(Icons.add_comment_outlined),
              label: const SizedBox.shrink(),
              style: FilledButton.styleFrom(
                minimumSize: const Size(52, 52),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(
                Icons.search,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: _openSearch,
            ),
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: _openSettings,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth >= UITokens.desktopBreakpoint
                  ? 920.0
                  : double.infinity;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    children: [
                      _buildHeroHeader(theme, l10n, _rooms.length),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          child: _loading
                              ? _buildShimmerLoading()
                              : RefreshIndicator.adaptive(
                                  onRefresh: _loadUserAndRooms,
                                  child: _buildChatList(),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    final baseColor = AppColors.skeletonBase(context);
    final highlightColor = AppColors.skeletonHighlight(context);
    final bottomInset = MediaQuery.of(context).padding.bottom + 124;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(8, 8, 8, bottomInset),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
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
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.all(12),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Center(
              child: AppErrorState(
                title: AppLocalizations.of(context)!.errorGeneric,
                message: _errorMessage!,
                actionLabel: AppLocalizations.of(context)!.retry,
                onAction: _loadUserAndRooms,
              ),
            ),
          ),
        ],
      );
    }

    if (rooms.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.all(12),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
              child: AppEmptyState(
                title: l10n.noChats,
                message: l10n.peopleSubtitle,
                icon: Icons.forum_outlined,
                actionLabel: l10n.peopleQuickNewChat,
                onAction: _showStartChatSheet,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(
        8,
        8,
        8,
        MediaQuery.of(context).padding.bottom + 124,
      ),
      cacheExtent: 500,
      itemCount: rooms.length,
      itemBuilder: (c, i) {
        final r = rooms[i];
        final id = r['id'] as String;
        final unreadCount = r['unreadCount'] as int? ?? 0;

        final item = Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SectionCard(
            onTap: () => _openChat(id),
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
                                color: AppColors.presenceRing(context),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _roomSubtitle(r),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.subtitleText(context),
                            ),
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
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.hintText(context),
                          ),
                    ),
                    if (unreadCount > 0) ...[
                      const SizedBox(height: 8),
                      UnreadBadge(count: unreadCount),
                    ],
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
