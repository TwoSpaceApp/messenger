import 'package:share_plus/share_plus.dart' as share;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/models/group.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:two_space_app/features/chat/presentation/widgets/chat_creation_scaffold.dart';
import 'package:two_space_app/features/people/data/models/person_entry.dart';
import 'package:two_space_app/features/profile/presentation/screens/search_contacts_screen.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final AegisChatService _chatService = AegisChatService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _participantController = TextEditingController();

  final List<_SelectedParticipant> _participants = <_SelectedParticipant>[];

  bool _isLoading = false;
  bool _isPublic = false;
  bool _showHistory = true;
  int _step = 0;
  List<int>? _avatarBytes;
  String? _avatarFileName;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _participantController.dispose();
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

  Future<void> _pickParticipantFromContacts() async {
    final selected = await Navigator.push<PersonEntry>(
      context,
      MaterialPageRoute(
        builder: (_) => const SearchContactsScreen(
          purpose: SearchContactsPurpose.newChat,
        ),
      ),
    );
    final remoteId = selected?.remoteUserId;
    if (selected == null || remoteId == null || !mounted) {
      return;
    }
    _addParticipant(
      _SelectedParticipant(
        userId: remoteId,
        displayName: selected.displayName,
      ),
    );
  }

  Future<void> _addParticipantById() async {
    final query = _participantController.text.trim();
    if (query.isEmpty) {
      return;
    }
    try {
      final results = await _chatService.searchUsers(query);
      if (results.isEmpty) {
        throw Exception(AppLocalizations.of(context)!.contactIdDescription);
      }
      final match = results.firstWhere(
        (entry) {
          final id = entry['id']?.toString();
          final nickname = entry['nickname']?.toString();
          return id == query || nickname == query;
        },
        orElse: () => results.first,
      );
      _participantController.clear();
      _addParticipant(
        _SelectedParticipant(
          userId: match['id']?.toString() ?? '',
          displayName: match['name']?.toString() ?? query,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(chatCreationFriendlyError(error))),
      );
    }
  }

  void _addParticipant(_SelectedParticipant participant) {
    if (participant.userId.isEmpty) {
      return;
    }
    final exists = _participants.any(
      (entry) => entry.userId == participant.userId,
    );
    if (exists) {
      return;
    }
    setState(() {
      _participants.add(participant);
      _errorMessage = null;
    });
  }

  void _removeParticipant(String userId) {
    setState(() {
      _participants.removeWhere((entry) => entry.userId == userId);
    });
  }

  void _goToParticipants() {
    final l10n = AppLocalizations.of(context)!;
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = l10n.enterRoomNameError);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _step = 1;
      _errorMessage = null;
    });
  }

  void _backToDetails() {
    FocusScope.of(context).unfocus();
    setState(() => _step = 0);
  }

  Future<void> _showInviteLinkSheet(String inviteLink) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(UITokens.spaceMd),
            child: GlassCard(
              padding: const EdgeInsets.all(UITokens.spaceLg),
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
                            .withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(UITokens.cornerPill),
                      ),
                    ),
                  ),
                  const SizedBox(height: UITokens.spaceLg),
                  Text(
                    l10n.inviteLinkReadyTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: UITokens.spaceXsSm),
                  Text(l10n.inviteLinkReadySubtitle),
                  const SizedBox(height: UITokens.spaceMd),
                  SelectableText(inviteLink),
                  const SizedBox(height: UITokens.spaceLg),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: inviteLink));
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.textCopied)),
                            );
                          },
                          icon: const Icon(Icons.link_rounded),
                          label: Text(l10n.copyLinkAction),
                        ),
                      ),
                      const SizedBox(width: UITokens.space),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await share.SharePlus.instance.share(
                              share.ShareParams(text: inviteLink),
                            );
                          },
                          icon: const Icon(Icons.share_outlined),
                          label: Text(l10n.shareAction),
                        ),
                      ),
                      const SizedBox(width: UITokens.space),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.openChatAction),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _createGroup() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = l10n.enterRoomNameError);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final group = await _chatService.createGroupRoom(
        name: name,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        visibility: _isPublic
            ? GroupVisibility.public
            : GroupVisibility.private,
        showMessageHistory: _showHistory,
        avatarBytes: _avatarBytes,
        avatarFileName: _avatarFileName,
      );

      String? inviteLink;
      try {
        final linkInfo = await _chatService.getRoomLinkInfo(group.roomId);
        inviteLink = linkInfo['preferredLink'];
      } catch (_) {}

      if (inviteLink != null && inviteLink.isNotEmpty) {
        for (final participant in _participants) {
          try {
            final roomId = await _chatService.createDirectChat(participant.userId);
            await _chatService.sendMessage(roomId: roomId, text: inviteLink);
          } catch (_) {}
        }
      }

      if (!mounted) {
        return;
      }

      if (inviteLink != null && inviteLink.isNotEmpty) {
        await _showInviteLinkSheet(inviteLink);
      }

      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chat: Chat(
              id: group.roomId,
              name: group.name,
              members: group.members.map((member) => member.userId).toList(),
              roomType: 'group',
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _errorMessage = chatCreationFriendlyError(error));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final detailsActive = _step == 0;

    return ChatCreationScaffold(
      title: l10n.groupChatTab,
      subtitle: l10n.createGroupSubtitle,
      icon: Icons.groups_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _GroupStepChip(
                  index: 0,
                  title: l10n.groupChatTab,
                  active: detailsActive,
                ),
              ),
              const SizedBox(width: UITokens.spaceSm),
              Expanded(
                child: _GroupStepChip(
                  index: 1,
                  title: l10n.selectedParticipantsTitle,
                  active: !detailsActive,
                ),
              ),
            ],
          ),
          const SizedBox(height: UITokens.spaceMd),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: detailsActive
                ? GlassCard(
                    key: const ValueKey('group-details-step'),
                    padding: const EdgeInsets.all(UITokens.spaceLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: _isLoading ? null : _pickAvatar,
                            child: CircleAvatar(
                              radius: 42,
                              backgroundImage: _avatarBytes == null
                                  ? null
                                  : MemoryImage(Uint8List.fromList(_avatarBytes!)),
                              child: _avatarBytes == null
                                  ? const Icon(Icons.group_add_rounded, size: 30)
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: UITokens.spaceLg),
                        TextField(
                          controller: _nameController,
                          enabled: !_isLoading,
                          textInputAction: TextInputAction.next,
                          decoration: chatCreationInputDecoration(
                            context: context,
                            label: l10n.roomNameLabel,
                            icon: Icons.forum_outlined,
                          ),
                        ),
                        const SizedBox(height: UITokens.spaceMd),
                        TextField(
                          controller: _descriptionController,
                          enabled: !_isLoading,
                          minLines: 3,
                          maxLines: 4,
                          decoration: chatCreationInputDecoration(
                            context: context,
                            label: l10n.shortDescriptionLabel,
                            icon: Icons.notes_rounded,
                          ),
                        ),
                        const SizedBox(height: UITokens.spaceMd),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: _isPublic,
                          onChanged: _isLoading
                              ? null
                              : (value) => setState(() => _isPublic = value),
                          title: Text(_isPublic ? l10n.publicLabel : l10n.privateLabel),
                          subtitle: Text(
                            _isPublic
                                ? l10n.roomJoinRulePublicDescription
                                : l10n.roomJoinRuleInviteOnlyDescription,
                          ),
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: _showHistory,
                          onChanged: _isLoading
                              ? null
                              : (value) => setState(() => _showHistory = value),
                          title: Text(l10n.groupHistoryTitle),
                          subtitle: Text(
                            _showHistory
                                ? l10n.roomHistoryVisibilityJoinedDescription
                                : l10n.roomHistoryVisibilityInvitedDescription,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    key: const ValueKey('group-participants-step'),
                    children: [
                      GlassCard(
                        padding: const EdgeInsets.all(UITokens.spaceLg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text.trim().isEmpty
                                  ? l10n.groupChatTab
                                  : _nameController.text.trim(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: UITokens.spaceXsSm),
                            Text(
                              l10n.groupParticipantsOptionalHint,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: UITokens.spaceSm),
                            Wrap(
                              spacing: UITokens.spaceSm,
                              runSpacing: UITokens.spaceSm,
                              children: [
                                _GroupSummaryChip(
                                  icon: _isPublic ? Icons.public_rounded : Icons.lock_outline_rounded,
                                  label: _isPublic ? l10n.publicLabel : l10n.privateLabel,
                                ),
                                _GroupSummaryChip(
                                  icon: Icons.history_toggle_off_rounded,
                                  label: _showHistory
                                      ? l10n.roomHistoryVisibilityJoinedDescription
                                      : l10n.roomHistoryVisibilityInvitedDescription,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UITokens.spaceMd),
                      GlassCard(
                        padding: const EdgeInsets.all(UITokens.spaceLg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.selectedParticipantsTitle,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: UITokens.spaceXsSm),
                            Text(
                              l10n.groupParticipantsOptionalHint,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: UITokens.spaceSmMd),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _isLoading ? null : _pickParticipantFromContacts,
                                icon: const Icon(Icons.person_search_rounded),
                                label: Text(l10n.searchContactsTitle),
                              ),
                            ),
                            const SizedBox(height: UITokens.spaceMd),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _participantController,
                                    enabled: !_isLoading,
                                    onSubmitted: (_) => _addParticipantById(),
                                    decoration: chatCreationInputDecoration(
                                      context: context,
                                      label: l10n.contactIdLabel,
                                      hint: l10n.contactIdDescription,
                                      icon: Icons.alternate_email_rounded,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: UITokens.space),
                                FilledButton(
                                  onPressed: _isLoading ? null : _addParticipantById,
                                  child: Text(l10n.addParticipantAction),
                                ),
                              ],
                            ),
                            if (_participants.isNotEmpty) ...[
                              const SizedBox(height: UITokens.spaceMd),
                              Wrap(
                                spacing: UITokens.spaceSm,
                                runSpacing: UITokens.spaceSm,
                                children: _participants
                                    .map(
                                      (participant) => Chip(
                                        label: Text(participant.displayName),
                                        onDeleted: () => _removeParticipant(participant.userId),
                                      ),
                                    )
                                    .toList(growable: false),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: UITokens.spaceMd),
          ChatCreationErrorBanner(message: _errorMessage),
          if (_errorMessage != null) const SizedBox(height: UITokens.spaceMd),
          Row(
            children: [
              if (!detailsActive) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _backToDetails,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: Text(l10n.back),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(UITokens.cornerXLg),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: UITokens.spaceSmMd),
              ],
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isLoading
                      ? null
                      : detailsActive
                          ? _goToParticipants
                          : _createGroup,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(detailsActive ? Icons.arrow_forward_rounded : Icons.groups_rounded),
                  label: Text(detailsActive ? l10n.next : l10n.createButton),
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
        ],
      ),
    );
  }
}

class _GroupStepChip extends StatelessWidget {
  const _GroupStepChip({
    required this.index,
    required this.title,
    required this.active,
  });

  final int index;
  final String title;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(
        horizontal: UITokens.spaceMd,
        vertical: UITokens.spaceSm,
      ),
      decoration: BoxDecoration(
        color: active
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.95)
            : theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(UITokens.cornerXLg),
        border: Border.all(
          color: active
              ? theme.colorScheme.primary.withValues(alpha: 0.28)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 11,
            backgroundColor: active
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            child: Text(
              '${index + 1}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: active
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: UITokens.spaceSm),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupSummaryChip extends StatelessWidget {
  const _GroupSummaryChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UITokens.spaceSmMd,
        vertical: UITokens.spaceXsSm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(UITokens.cornerPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: UITokens.space2XS),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedParticipant {
  const _SelectedParticipant({
    required this.userId,
    required this.displayName,
  });

  final String userId;
  final String displayName;
}
