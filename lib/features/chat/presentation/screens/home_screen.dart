import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/widgets/app_logo.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:two_space_app/features/chat/presentation/screens/create_chat_screen.dart';
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
    _loadUserAndRooms();
    _subscribeToRooms();
  }

  @override
  void dispose() {
    _roomsSub?.cancel();
    super.dispose();
  }

  Future<void> _loadUserAndRooms() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
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
    };
  }

  String _formatRoomTime(DateTime? time) {
    if (time == null) return '';
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
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

  void _openCreateChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateChatScreen()),
    ).then((result) {
      if (result != null) {
        _loadUserAndRooms();
      }
    });
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
              // Header with TwoSpace logo
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const AppLogo(large: false),
                    const SizedBox(width: 8),
                    Text(
                      l10n.chatsTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    // Search button
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: _openSearch,
                    ),
                    // Settings button
                    IconButton(
                      icon: const Icon(Icons.settings_outlined,
                          color: Colors.white),
                      onPressed: _openSettings,
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
        child: FloatingActionButton(
          onPressed: _openCreateChat,
          child: const Icon(Icons.add),
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
      return AppEmptyState(
        title: AppLocalizations.of(context)!.noChats,
        message: AppLocalizations.of(context)!.createRoomTitle,
        icon: Icons.chat_bubble_outline_rounded,
        actionLabel: AppLocalizations.of(context)!.newChatTitle,
        onAction: _openCreateChat,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
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
                  child: UserAvatar(
                    avatarUrl: r['avatar'],
                    name: r['name'],
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
                        ((r['lastMessage'] as String?)?.isNotEmpty ?? false)
                          ? r['lastMessage'] as String
                            : AppLocalizations.of(context)!.noMessages,
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

        // Use staggered entry animation
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
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
    ).then((_) => _loadUserAndRooms());
  }
}
