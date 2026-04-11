import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/chat/data/services/chat_backend_factory.dart';
import 'package:two_space_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:two_space_app/features/chat/presentation/widgets/chat_creation_scaffold.dart';
import 'package:two_space_app/features/people/data/models/person_entry.dart';
import 'package:two_space_app/features/profile/presentation/screens/search_contacts_screen.dart';

class CreateChatScreen extends StatefulWidget {
  const CreateChatScreen({super.key});

  @override
  State<CreateChatScreen> createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen> {
  final _userIdController = TextEditingController();
  final AegisChatService _chatService = AegisChatService();

  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _openContacts() async {
    final selected = await Navigator.push<PersonEntry>(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchContactsScreen(
          purpose: SearchContactsPurpose.newChat,
        ),
      ),
    );
    if (selected == null || selected.remoteUserId == null || !mounted) {
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _userIdController.text = selected.remoteUserId!;
    });

    try {
      final backend = createChatBackend();
      final map = await backend.getOrCreateDirectChat(selected.remoteUserId!);
      await _openChat(Chat.fromMap(map));
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = chatCreationFriendlyError(error);
      });
    }
  }

  Future<void> _openChat(Chat chat) async {
    if (!mounted) {
      return;
    }
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
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = chatCreationFriendlyError(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChatCreationScaffold(
      title: l10n.newChatTitle,
      subtitle: l10n.createDirectChatSubtitle,
      icon: Icons.person_add_alt_1_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(UITokens.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.contactIdExplanation,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: UITokens.spaceMd),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _openContacts,
                    icon: const Icon(Icons.manage_search_rounded),
                    label: Text(l10n.searchContactsTitle),
                  ),
                ),
                const SizedBox(height: UITokens.spaceMd),
                TextField(
                  controller: _userIdController,
                  enabled: !_loading,
                  decoration: chatCreationInputDecoration(
                    context: context,
                    label: l10n.contactIdLabel,
                    hint: l10n.contactIdDescription,
                    icon: Icons.alternate_email_rounded,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: UITokens.spaceMd),
          ChatCreationErrorBanner(message: _errorMessage),
          if (_errorMessage != null) const SizedBox(height: UITokens.spaceMd),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _createDirectChat,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chat_bubble_outline_rounded),
              label: Text(l10n.createButton),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UITokens.cornerXLg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
