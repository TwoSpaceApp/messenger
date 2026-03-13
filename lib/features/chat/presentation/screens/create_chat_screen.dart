import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/widgets/app_logo.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:two_space_app/features/profile/presentation/screens/search_contacts_screen.dart';

enum CreateChatMode { direct, group, join }

class CreateChatScreen extends StatefulWidget {
  const CreateChatScreen({
    this.initialMode = CreateChatMode.direct,
    super.key,
  });

  final CreateChatMode initialMode;

  @override
  State<CreateChatScreen> createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen>
    with SingleTickerProviderStateMixin {
  final _userIdController = TextEditingController();
  final _roomNameController = TextEditingController();
  final _roomTopicController = TextEditingController();
  final _joinLinkController = TextEditingController();
  late TabController _tabController;

  bool _loading = false;
  bool _isPrivate = true;
  String? _errorMessage;
  final AegisChatService _chatService = AegisChatService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialMode.index,
    );
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _roomNameController.dispose();
    _roomTopicController.dispose();
    _joinLinkController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String _friendlyError(Object error) {
    return error.toString().replaceFirst(RegExp('^Exception: '), '');
  }

  Future<void> _openContacts() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchContactsScreen()),
    );
  }

  Future<void> _openChat(Chat chat) async {
    if (!mounted) return;
    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(chat: chat)),
    );
  }

  Future<void> _createDirectChat() async {
    final l10n = AppLocalizations.of(context)!;
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      setState(() => _errorMessage = l10n.enterUserIdError);
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final roomId = await _chatService.createDirectChat(userId);
      final userInfo = await _chatService.getUserInfo(userId);
      await _openChat(
        Chat(
          id: roomId,
          name: userInfo['displayName'] as String? ?? userId,
          members: [userId],
          avatarUrl: userInfo['avatarUrl'] as String?,
          roomType: 'direct',
          isOnline: userInfo['isOnline'] == true,
          presenceStatus: userInfo['presenceStatus'] as String?,
          lastSeenAt: userInfo['lastSeenAt'] is String
              ? DateTime.tryParse(userInfo['lastSeenAt'] as String)
              : null,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = _friendlyError(e);
        });
      }
    }
  }

  Future<void> _createGroupChat() async {
    final l10n = AppLocalizations.of(context)!;
    final roomName = _roomNameController.text.trim();
    if (roomName.isEmpty) {
      setState(() => _errorMessage = l10n.enterRoomNameError);
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final roomId = await _chatService.createRoom(
        name: roomName,
        topic: _roomTopicController.text.trim(),
        isPublic: !_isPrivate,
      );
      await _openChat(Chat(id: roomId, name: roomName, members: const []));
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = _friendlyError(e);
        });
      }
    }
  }

  Future<void> _joinRoomByLink() async {
    final linkOrAlias = _joinLinkController.text.trim();
    if (linkOrAlias.isEmpty) {
      setState(() =>
          _errorMessage = AppLocalizations.of(context)!.joinLinkHint);
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final chat = await _chatService.joinRoomByLink(linkOrAlias);
      await _openChat(chat);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = _friendlyError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth =
                  constraints.maxWidth >= UITokens.desktopBreakpoint ? 920.0 : double.infinity;
              final isNarrow = constraints.maxWidth < UITokens.mobileBreakpoint;
              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const AppLogo(large: false),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.newChatTitle,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    l10n.chatsSubtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      GlassCard(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: EdgeInsets.zero,
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: isNarrow,
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white60,
                          indicatorColor: theme.colorScheme.primary,
                          tabs: [
                            Tab(text: l10n.directChatTab),
                            Tab(text: l10n.groupChatTab),
                            Tab(text: l10n.joinByCodeTitle),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildDirectChatTab(),
                            _buildGroupChatTab(),
                            _buildJoinChatTab(),
                          ],
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

  Widget _buildDirectChatTab() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.searchContactsTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.inviteUserSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(180),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _openContacts,
                    icon: const Icon(Icons.search),
                    label: Text(l10n.searchContactsTitle),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.contactIdLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.contactIdDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(180),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _userIdController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: l10n.contactIdLabel,
                    labelStyle: TextStyle(color: Colors.white.withAlpha(180)),
                    hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withAlpha(50)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                if (_errorMessage != null && _tabController.index == 0) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _createDirectChat,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.startChatButton),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.white.withAlpha(180)),
                    const SizedBox(width: 12),
                    Text(
                      l10n.hintCardTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.contactIdExplanation,
                  style: TextStyle(
                    color: Colors.white.withAlpha(180),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupChatTab() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.createNewRoomTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _roomNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: l10n.roomNameLabel,
                    labelStyle: TextStyle(color: Colors.white.withAlpha(180)),
                    prefixIcon: const Icon(Icons.group, color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withAlpha(50)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _roomTopicController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: l10n.descriptionOptionalLabel,
                    labelStyle: TextStyle(color: Colors.white.withAlpha(180)),
                    prefixIcon:
                        const Icon(Icons.description, color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withAlpha(50)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    l10n.privateGroupLabel,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    _isPrivate
                        ? l10n.privateGroupSubtitle
                        : l10n.publicRoomSubtitle,
                    style: TextStyle(color: Colors.white.withAlpha(150)),
                  ),
                  value: _isPrivate,
                  onChanged: (v) => setState(() => _isPrivate = v),
                ),
                if (_errorMessage != null && _tabController.index == 1) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _createGroupChat,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.createRoomButton),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinChatTab() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.joinByCodeTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.joinByCodeSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha(180),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _joinLinkController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: l10n.joinByCodeTitle,
                    hintText: l10n.joinLinkHint,
                    labelStyle: TextStyle(color: Colors.white.withAlpha(180)),
                    hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
                    prefixIcon: const Icon(Icons.link, color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withAlpha(50)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                if (_errorMessage != null && _tabController.index == 2) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _joinRoomByLink,
                    icon: const Icon(Icons.login),
                    label: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.joinByCodeTitle),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
