import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/features/auth/data/services/aegis_auth_service.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:two_space_app/features/chat/presentation/widgets/chat_creation_scaffold.dart';

class CreateChannelScreen extends StatefulWidget {
  const CreateChannelScreen({super.key});

  @override
  State<CreateChannelScreen> createState() => _CreateChannelScreenState();
}

class _CreateChannelScreenState extends State<CreateChannelScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _aliasController = TextEditingController();
  final AegisChatService _chatService = AegisChatService();
  final AegisAuthService _authService = AegisAuthService();

  Uint8List? _avatarBytes;
  String? _avatarFileName;
  bool _isPublic = true;
  bool _loading = false;
  String? _errorMessage;

  String get _normalizedChannelLink => normalizePublicAlias(_aliasController.text);

  String? _channelLinkError(AppLocalizations l10n) {
    if (!_isPublic) {
      return null;
    }
    final value = _aliasController.text.trim();
    if (value.isEmpty) {
      return null;
    }
    if (_normalizedChannelLink.isEmpty ||
        !RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(_normalizedChannelLink)) {
      return l10n.channelLinkFormatError;
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _aliasController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return;
      }
      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        return;
      }
      setState(() {
        _avatarBytes = bytes;
        _avatarFileName = file.name;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.filePickError(chatCreationFriendlyError(error)))),
      );
    }
  }

  Future<void> _createChannel() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = l10n.enterRoomNameError);
      return;
    }
    final channelLinkError = _channelLinkError(l10n);
    if (channelLinkError != null) {
      setState(() => _errorMessage = channelLinkError);
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final warnings = <String>[];

    try {
      final roomId = await _chatService.createRoom(
        name: name,
        topic: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        isPublic: _isPublic,
      );

      final avatarBytes = _avatarBytes;
      if (avatarBytes != null) {
        try {
          await _chatService.setRoomAvatar(
            roomId,
            avatarBytes,
            fileName: _avatarFileName,
          );
        } catch (error) {
          warnings.add(chatCreationFriendlyError(error));
        }
      }

      final alias = _normalizedChannelLink;
      if (_isPublic && alias.isNotEmpty) {
        final channelId = int.tryParse(roomId.replaceFirst('channel:', ''));
        if (channelId != null) {
          try {
            final response = await _authService.rawClient.updateChannelLinks(
              channelId,
              publicAlias: alias,
            );
            if (!response.success) {
              warnings.add(response.message ?? l10n.errorGeneric);
            }
          } catch (error) {
            warnings.add(chatCreationFriendlyError(error));
          }
        }
      }

      if (!mounted) {
        return;
      }

      if (warnings.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(warnings.first)),
        );
      }

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chat: Chat(
              id: roomId,
              name: name,
              members: const <String>[],
              roomType: _isPublic ? 'public' : 'private',
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = chatCreationFriendlyError(error);
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final channelLinkError = _channelLinkError(l10n);

    return ChatCreationScaffold(
      title: l10n.createChannelTitle,
      subtitle: l10n.createChannelSubtitle,
      icon: Icons.campaign_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(UITokens.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _loading ? null : _pickAvatar,
                    child: CircleAvatar(
                      radius: 42,
                      backgroundImage: _avatarBytes == null
                          ? null
                          : MemoryImage(_avatarBytes!),
                      child: _avatarBytes == null
                          ? const Icon(Icons.add_a_photo_outlined)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: UITokens.spaceLg),
                TextField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: chatCreationInputDecoration(
                    context: context,
                    label: l10n.roomNameLabel,
                    icon: Icons.alternate_email_rounded,
                  ),
                ),
                const SizedBox(height: UITokens.spaceMd),
                TextField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: chatCreationInputDecoration(
                    context: context,
                    label: l10n.shortDescriptionLabel,
                    icon: Icons.notes_rounded,
                  ),
                ),
                const SizedBox(height: UITokens.spaceMd),
                SwitchListTile.adaptive(
                  value: _isPublic,
                  onChanged: _loading
                      ? null
                      : (value) => setState(() {
                          _isPublic = value;
                          _errorMessage = null;
                        }),
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _isPublic ? l10n.publicLabel : l10n.privateLabel,
                  ),
                  subtitle: Text(
                    _isPublic
                        ? l10n.roomJoinRulePublicDescription
                        : l10n.roomJoinRuleInviteOnlyDescription,
                  ),
                ),
                if (_isPublic) ...[
                  const SizedBox(height: UITokens.spaceSm),
                  TextField(
                    controller: _aliasController,
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() => _errorMessage = null),
                    decoration: chatCreationInputDecoration(
                      context: context,
                      label: l10n.publicAliasLabel,
                      icon: Icons.link_rounded,
                      hint: l10n.publicAliasHint,
                      helper: channelLinkError ?? l10n.channelPublicLinkHelper,
                    ),
                  ),
                  if (channelLinkError != null) ...[
                    const SizedBox(height: UITokens.spaceXsSm),
                    Text(
                      channelLinkError,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(height: UITokens.spaceMd),
          ChatCreationErrorBanner(message: _errorMessage),
          if (_errorMessage != null) const SizedBox(height: UITokens.spaceMd),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading ? null : _createChannel,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.campaign_outlined),
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
