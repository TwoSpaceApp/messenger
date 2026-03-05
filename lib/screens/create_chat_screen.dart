import 'package:flutter/material.dart';
import 'package:two_space_app/services/chat_matrix_service.dart';
import 'package:two_space_app/widgets/screen_background.dart';
import 'package:two_space_app/widgets/glass_card.dart';
import 'package:two_space_app/widgets/app_logo.dart';
import 'package:two_space_app/models/chat.dart';
import 'package:two_space_app/screens/chat_screen.dart';
import 'package:two_space_app/l10n/app_localizations.dart';

class CreateChatScreen extends StatefulWidget {
  const CreateChatScreen({super.key});

  @override
  State<CreateChatScreen> createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen> with SingleTickerProviderStateMixin {
  final _userIdController = TextEditingController();
  final _roomNameController = TextEditingController();
  final _roomTopicController = TextEditingController();
  late TabController _tabController;
  
  bool _loading = false;
  bool _isPrivate = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _roomNameController.dispose();
    _roomTopicController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _createDirectChat() async {
    final l10n = AppLocalizations.of(context)!;
    final userId = _userIdController.text.trim();
    if (userId.isEmpty) {
      setState(() => _errorMessage = l10n.enterUserIdError);
      return;
    }

    // Normalize userId
    String normalizedUserId = userId;
    if (!userId.startsWith('@')) {
      // Assume it's a username, add @ and domain
      final matrixService = ChatMatrixService();
      final domain = matrixService.homeserver.replaceAll('https://', '').replaceAll('http://', '');
      normalizedUserId = '@$userId:$domain';
    } else if (!userId.contains(':')) {
      final matrixService = ChatMatrixService();
      final domain = matrixService.homeserver.replaceAll('https://', '').replaceAll('http://', '');
      normalizedUserId = '$userId:$domain';
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final matrixService = ChatMatrixService();
      final roomId = await matrixService.createDirectChat(normalizedUserId);
      
      if (mounted) {
        // Navigate to the chat
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chat: Chat(id: roomId, name: userId, members: [normalizedUserId]),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
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
      final matrixService = ChatMatrixService();
      final roomId = await matrixService.createRoom(
        name: roomName,
        topic: _roomTopicController.text.trim(),
        isPublic: !_isPrivate,
      );
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chat: Chat(id: roomId, name: roomName, members: []),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const AppLogo(large: false),
                    const SizedBox(width: 8),
                    Text(
                      l10n.newChatTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Tab bar
              GlassCard(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.zero,
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  indicatorColor: theme.colorScheme.primary,
                  tabs: [
                    Tab(text: l10n.directChatTab),
                    Tab(text: l10n.groupChatTab),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDirectChatTab(),
                    _buildGroupChatTab(),
                  ],
                ),
              ),
            ],
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
                  l10n.startDirectChatTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.matrixIdDescription,
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
                      labelText: l10n.matrixIdLabel,
                    hintText: '@username:server.com',
                    labelStyle: TextStyle(color: Colors.white.withAlpha(180)),
                    hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
                    prefixIcon: const Icon(Icons.person, color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withAlpha(50)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.white.withAlpha(180)),
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
                    l10n.matrixIdExplanation,
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
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
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
                    prefixIcon: const Icon(Icons.description, color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withAlpha(50)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
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
}
