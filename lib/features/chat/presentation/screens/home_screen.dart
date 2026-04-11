import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/utils/message_time_formatter.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/inline_notice_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/core/widgets/section_card.dart';
import 'package:two_space_app/core/widgets/unread_badge.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/chat/presentation/screens/create_chat_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/create_channel_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/create_group_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/join_room_screen.dart';
import 'package:two_space_app/features/profile/presentation/widgets/user_avatar.dart';

enum _NewChatAction { direct, group, channel, join }

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
      final text = e.toString().toLowerCase();
      if (text.contains('notauthenticatedexception') ||
          text.contains('необходима аутентификация')) {
        if (mounted) {
          setState(() {
            _rooms = const <Map<String, dynamic>>[];
            _errorMessage = null;
          });
        }
        return;
      }
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  ({IconData icon, String title, String message}) _describeRoomError(
    String raw,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final text = raw.toLowerCase();
    final clean = raw.replaceFirst(RegExp('^Exception: '), '').trim();

    if (text.contains('timeout') ||
        text.contains('timed out') ||
        text.contains('no response for seq')) {
      return (
        icon: Icons.schedule_rounded,
        title: l10n.chatListTimeoutTitle,
        message: l10n.chatListTimeoutMessage(
          clean.isEmpty ? l10n.errorGeneric : clean,
        ),
      );
    }
    if (text.contains('notauthenticatedexception') ||
        text.contains('authentication') ||
        text.contains('session') ||
        text.contains('unauthorized')) {
      return (
        icon: Icons.lock_outline_rounded,
        title: l10n.loginRequired,
        message: l10n.loginRequiredContent,
      );
    }
    if (text.contains('socket') ||
        text.contains('connection') ||
        text.contains('network') ||
        text.contains('handshake')) {
      return (
        icon: Icons.wifi_off_rounded,
        title: l10n.chatListOfflineTitle,
        message: l10n.chatListOfflineMessage(
          clean.isEmpty ? l10n.errorGeneric : clean,
        ),
      );
    }
    return (
      icon: Icons.cloud_off_rounded,
      title: l10n.errorGeneric,
      message: clean.isEmpty ? l10n.errorGeneric : clean,
    );
  }

  void _subscribeToRooms() {
    _roomsSub?.cancel();
    _roomsSub = _chat.watchChats().listen(
      (chats) {
        final nextRooms = chats.map(_roomFromChat).toList(growable: false);
        if (!mounted) return;
        if (_roomListsEqual(_rooms, nextRooms) &&
            !_loading &&
            _errorMessage == null) {
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

  String? _directUserIdForRoom(Map<String, dynamic> room) {
    if (room['roomType'] != 'direct') {
      return null;
    }
    final roomId = room['id']?.toString() ?? '';
    if (!roomId.startsWith('dm:')) {
      return null;
    }
    final userId = roomId.substring(3).trim();
    return userId.isEmpty ? null : userId;
  }

  Future<void> _openRoomProfile(Map<String, dynamic> room) async {
    final userId = _directUserIdForRoom(room);
    if (userId == null || !mounted) {
      return;
    }
    await context.push(
      AppStrings.routeProfile,
      extra: <String, dynamic>{
        'userId': userId,
        'initialName': room['name']?.toString(),
        'initialAvatar': room['avatar']?.toString(),
      },
    );
  }

  Future<void> _leaveOrRemoveRoom(Map<String, dynamic> room) async {
    final l10n = AppLocalizations.of(context)!;
    final roomId = room['id']?.toString() ?? '';
    if (roomId.isEmpty) {
      return;
    }
    final isDirect = room['roomType'] == 'direct';
    var confirmed = true;
    if (!isDirect) {
      confirmed =
          await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(l10n.leaveRoomTitle),
              content: Text(l10n.leaveRoomContent),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(l10n.cancelButton),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(l10n.leaveRoomAction),
                ),
              ],
            ),
          ) ??
          false;
    }
    if (!confirmed || !mounted) {
      return;
    }

    try {
      await _chat.leaveRoom(roomId);
      if (!mounted) {
        return;
      }
      await _loadUserAndRooms();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.genericError(e.toString()))),
      );
    }
  }

  Future<void> _showRoomQuickActions(
    Map<String, dynamic> room,
    Offset globalPosition,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final isDirect = room['roomType'] == 'direct';
    final overlay = Overlay.maybeOf(context);
    final overlayBox = overlay?.context.findRenderObject();
    if (overlayBox is! RenderBox) {
      return;
    }
    final action = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(globalPosition.dx, globalPosition.dy, 1, 1),
        Offset.zero & overlayBox.size,
      ),
      items: <PopupMenuEntry<String>>[
        if (isDirect)
          PopupMenuItem<String>(
            value: 'profile',
            child: Text(l10n.peopleViewProfileAction),
          ),
        if (isDirect) const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'remove',
          child: Text(isDirect ? l10n.deleteButton : l10n.leaveRoomAction),
        ),
      ],
    );

    switch (action) {
      case 'profile':
        await _openRoomProfile(room);
      case 'remove':
        await _leaveOrRemoveRoom(room);
      case null:
        return;
    }
  }

  Future<void> _showStartChatSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final action = await showModalBottomSheet<_NewChatAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final maxHeight = MediaQuery.sizeOf(context).height * 0.82;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              UITokens.spaceMd,
              UITokens.spaceMd,
              UITokens.spaceMd,
              UITokens.spaceMd,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: SectionCard(
                radius: UITokens.corner2XL,
                padding: const EdgeInsets.all(UITokens.spaceMd),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: UITokens.dragHandleWidth,
                          height: UITokens.dragHandleHeight,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant
                                .withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(
                              UITokens.cornerPill,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: UITokens.spaceMd),
                      Text(
                        l10n.newChatChooserTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: UITokens.spaceXsSm),
                      Text(
                        l10n.newChatChooserSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: UITokens.spaceSmMd),
                      _NewChatActionTile(
                        icon: Icons.person_add_alt_1_rounded,
                        title: l10n.newChatTitle,
                        subtitle: l10n.createDirectChatSubtitle,
                        onTap: () => Navigator.of(
                          context,
                        ).pop(_NewChatAction.direct),
                      ),
                      const SizedBox(height: UITokens.spaceXsSm),
                      _NewChatActionTile(
                        icon: Icons.groups_rounded,
                        title: l10n.groupChatTab,
                        subtitle: l10n.createGroupSubtitle,
                        onTap: () => Navigator.of(
                          context,
                        ).pop(_NewChatAction.group),
                      ),
                      const SizedBox(height: UITokens.spaceXsSm),
                      _NewChatActionTile(
                        icon: Icons.campaign_outlined,
                        title: l10n.channelChatTab,
                        subtitle: l10n.createChannelSubtitle,
                        onTap: () => Navigator.of(
                          context,
                        ).pop(_NewChatAction.channel),
                      ),
                      const SizedBox(height: UITokens.spaceXsSm),
                      _NewChatActionTile(
                        icon: Icons.link_rounded,
                        title: l10n.joinByCodeTitle,
                        subtitle: l10n.joinByCodeSubtitle,
                        onTap: () => Navigator.of(
                          context,
                        ).pop(_NewChatAction.join),
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

    if (!mounted || action == null) {
      return;
    }

    final Widget destination = switch (action) {
      _NewChatAction.direct => const CreateChatScreen(),
      _NewChatAction.group => const CreateGroupScreen(),
      _NewChatAction.channel => const CreateChannelScreen(),
      _NewChatAction.join => const JoinRoomScreen(),
    };

    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
    if (result != null) {
      unawaited(_chat.refreshChatsQuietly());
    }
  }

  Widget _buildHeroHeader(
    ThemeData theme,
    AppLocalizations l10n,
    int roomCount,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UITokens.spaceMd,
        UITokens.spaceMd,
        UITokens.spaceMd,
        UITokens.spaceSmMd,
      ),
      child: SectionCard(
        radius: UITokens.cornerXL,
        padding: const EdgeInsets.fromLTRB(
          UITokens.spaceMdLg,
          UITokens.spaceMdLg,
          UITokens.spaceMdLg,
          UITokens.spaceMd,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  const SizedBox(height: UITokens.spaceXSm),
                  Text(
                    roomCount > 0
                        ? l10n.chatsSubtitle
                        : l10n.chatsQuickStartTitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: UITokens.space),
            IconButton.filled(
              onPressed: _showStartChatSheet,
              icon: const Icon(Icons.add_comment_outlined),
              tooltip: l10n.peopleQuickNewChat,
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.92),
                foregroundColor: theme.colorScheme.primary,
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.64,
                  ),
                ),
                minimumSize: const Size(56, 56),
              ),
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
              final maxWidth =
                  constraints.maxWidth >= UITokens.desktopBreakpoint
                  ? 920.0
                  : double.infinity;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    children: [
                      _buildHeroHeader(theme, l10n, _rooms.length),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          UITokens.spaceMd,
                          0,
                          UITokens.spaceMd,
                          UITokens.spaceSm,
                        ),
                        child: InlineNoticeCard(
                          icon: Icons.science_outlined,
                          badge: l10n.betaTestLabel,
                          title: l10n.homeBetaWelcomeTitle,
                          message: l10n.homeBetaWelcomeBody,
                        ),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: UITokens.durationMd,
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
      padding: EdgeInsets.fromLTRB(
        UITokens.spaceSm,
        UITokens.spaceSm,
        UITokens.spaceSm,
        bottomInset,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: UITokens.spaceSm),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(UITokens.cornerLg),
              ),
              padding: const EdgeInsets.all(UITokens.space),
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
                  const SizedBox(width: UITokens.space),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(width: 150, height: 16, color: Colors.white),
                        const SizedBox(height: UITokens.spaceSm),
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
    if (_errorMessage != null && rooms.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.all(UITokens.space),
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
        padding: const EdgeInsets.all(UITokens.space),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Center(
              child: AppEmptyState(
                title: l10n.noChats,
                message: l10n.chatsSubtitle,
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
      itemCount: rooms.length + (_errorMessage != null ? 1 : 0),
      itemBuilder: (c, i) {
        if (_errorMessage != null && i == 0) {
          final error = _describeRoomError(_errorMessage!);
          return Padding(
            padding: const EdgeInsets.only(bottom: UITokens.spaceSm),
            child: SectionCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    error.icon,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: UITokens.space),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          error.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: UITokens.spaceXS),
                        Text(
                          error.message,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppColors.subtitleText(context),
                              ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _loadUserAndRooms,
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            ),
          );
        }
        final roomIndex = i - (_errorMessage != null ? 1 : 0);
        final r = rooms[roomIndex];
        final id = r['id'] as String;
        final unreadCount = r['unreadCount'] as int? ?? 0;

        final item = Padding(
          padding: const EdgeInsets.only(bottom: UITokens.spaceSm),
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
                const SizedBox(width: UITokens.space),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['name'],
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: UITokens.spaceXS),
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
                      const SizedBox(height: UITokens.spaceSm),
                      UnreadBadge(count: unreadCount),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPressStart: (details) =>
              _showRoomQuickActions(r, details.globalPosition),
          onSecondaryTapDown: (details) =>
              _showRoomQuickActions(r, details.globalPosition),
          child: item,
        );
      },
    );
  }

  void _openChat(String id) {
    final room = _rooms.firstWhere(
      (e) => e['id'] == id,
      orElse: () => {'id': id, 'name': id},
    );
    context.push(
      '${AppStrings.routeChat}/${Uri.encodeComponent(id)}',
      extra: Chat(
        id: id,
        name: (room['name'] as String?) ?? id,
        avatarUrl: room['avatar'] as String?,
        roomType: room['roomType'] as String?,
        members: const [],
        isOnline: room['isOnline'] == true,
        presenceStatus: room['presenceStatus'] as String?,
        lastSeenAt: room['lastSeenAt'] as DateTime?,
      ),
    );
  }
}

class _NewChatActionTile extends StatelessWidget {
  const _NewChatActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SectionCard(
      onTap: onTap,
      padding: const EdgeInsets.all(UITokens.spaceSmMd),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(UITokens.cornerLg),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: UITokens.spaceSmMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: UITokens.space2XS),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: UITokens.spaceXsSm),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
