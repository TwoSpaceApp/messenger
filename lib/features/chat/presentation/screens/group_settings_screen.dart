import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/group.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/chat/data/services/aegis_group_service.dart';
import 'package:two_space_app/features/chat/presentation/widgets/feature_in_development_dialog.dart';
import 'package:two_space_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:two_space_app/features/profile/presentation/widgets/user_avatar.dart';

class _GroupSettingsSection {
  const _GroupSettingsSection({
    required this.title,
    required this.icon,
    required this.content,
    this.destructive = false,
  });

  final String title;
  final IconData icon;
  final Widget content;
  final bool destructive;
}

class GroupSettingsScreen extends StatefulWidget {
  const GroupSettingsScreen({
    required this.roomId,
    super.key,
  });

  final String roomId;

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  late AegisGroupService _groupService;
  final AegisChatService _chatService = AegisChatService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int _selectedTabIndex = 0;
  bool _isLoading = false;
  bool _isSavingGroupInfo = false;
  int _joinRule = 1;
  int _historyVisibility = 1;
  GroupRoom? _currentGroup;

  @override
  void initState() {
    super.initState();
    _groupService = AegisGroupService();
    _loadGroupData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _canManageMembers =>
      _currentGroup?.currentUserRole == GroupRole.owner ||
      _currentGroup?.currentUserRole == GroupRole.admin;

  bool get _canDeleteGroup => _currentGroup?.currentUserRole == GroupRole.owner;

  void _openMemberProfile(GroupMember member) {
    if (member.userId.trim().isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  Future<void> _loadGroupData() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    try {
      final group = await _groupService.getGroupRoom(widget.roomId);
      final settings = await _groupService.getRoomSettingsState(widget.roomId);
      if (!mounted) return;
      setState(() {
        _currentGroup = group;
        _nameController.text = group?.name ?? '';
        _descriptionController.text = group?.description ?? '';
        _joinRule = (settings['joinRule'] as int?) ?? _joinRule;
        _historyVisibility =
            (settings['historyVisibility'] as int?) ?? _historyVisibility;
      });
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loadError(e.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    var bytes = file.bytes;
    if (bytes == null && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }
    if (bytes == null) return;

    setState(() => _isSavingGroupInfo = true);
    try {
      await _chatService.setRoomAvatar(
        widget.roomId,
        bytes,
        fileName: file.name,
      );
      await _loadGroupData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.roomAvatarUpdated)),
      );
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.genericError(e.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingGroupInfo = false);
      }
    }
  }

  Future<void> _saveGroupInfo() async {
    final l10n = AppLocalizations.of(context)!;
    final group = _currentGroup;
    if (group == null) return;

    final nextName = _nameController.text.trim();
    final nextDescription = _descriptionController.text.trim();
    if (nextName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.roomNameLabel)),
      );
      return;
    }

    setState(() => _isSavingGroupInfo = true);
    try {
      await _chatService.updateRoomDetails(
        widget.roomId,
        name: nextName == group.name ? null : nextName,
        description: nextDescription == (group.description ?? '')
            ? group.description
            : nextDescription,
      );
      await _loadGroupData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingSaved)),
      );
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.genericError(e.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSavingGroupInfo = false);
      }
    }
  }

  Future<void> _copyGroupLink() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final linkInfo = await _chatService.getRoomLinkInfo(widget.roomId);
      final link = linkInfo['preferredLink'];
      if (link == null || link.isEmpty) {
        throw Exception(l10n.errorGeneric);
      }
      await Clipboard.setData(ClipboardData(text: link));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.textCopied)));
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.genericError(e.toString()))),
      );
    }
  }

  Future<void> _pickJoinRule() async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final value in [0, 1, 2])
                ListTile(
                  title: Text(_joinRuleTitle(l10n, value)),
                  subtitle: Text(_joinRuleSubtitle(l10n, value)),
                  trailing: _joinRule == value
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(value),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (!mounted || selected == null) return;
    setState(() => _joinRule = selected);
    await _updateJoinRule(selected);
  }

  Future<void> _pickHistoryVisibility() async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final value in [0, 1, 2])
                ListTile(
                  title: Text(_historyVisibilityTitle(l10n, value)),
                  subtitle: Text(_historyVisibilitySubtitle(l10n, value)),
                  trailing: _historyVisibility == value
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(value),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (!mounted || selected == null) return;
    setState(() => _historyVisibility = selected);
    await _updateHistoryVisibility(selected);
  }

  String _joinRuleTitle(AppLocalizations l10n, int value) {
    switch (value) {
      case 0:
        return l10n.roomJoinRulePublic;
      case 2:
        return l10n.roomJoinRuleApproval;
      default:
        return l10n.roomJoinRuleInviteOnly;
    }
  }

  String _joinRuleSubtitle(AppLocalizations l10n, int value) {
    switch (value) {
      case 0:
        return l10n.roomJoinRulePublicDescription;
      case 2:
        return l10n.roomJoinRuleApprovalDescription;
      default:
        return l10n.roomJoinRuleInviteOnlyDescription;
    }
  }

  String _historyVisibilityTitle(AppLocalizations l10n, int value) {
    switch (value) {
      case 0:
        return l10n.roomHistoryVisibilityWorldReadable;
      case 2:
        return l10n.roomHistoryVisibilityInvited;
      default:
        return l10n.roomHistoryVisibilityJoined;
    }
  }

  String _historyVisibilitySubtitle(AppLocalizations l10n, int value) {
    switch (value) {
      case 0:
        return l10n.roomHistoryVisibilityWorldReadableDescription;
      case 2:
        return l10n.roomHistoryVisibilityInvitedDescription;
      default:
        return l10n.roomHistoryVisibilityJoinedDescription;
    }
  }

  Future<void> _updateJoinRule(int value) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _groupService.setJoinRuleValue(widget.roomId, value);
      await _loadGroupData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingSaved)),
      );
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.genericError(e.toString()))),
      );
    }
  }

  Future<void> _updateHistoryVisibility(int value) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _groupService.setHistoryVisibility(widget.roomId, value);
      await _loadGroupData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingSaved)),
      );
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.genericError(e.toString()))),
      );
    }
  }

  List<_GroupSettingsSection> _sections(AppLocalizations l10n) {
    return [
      _GroupSettingsSection(
        title: l10n.groupInfoTab,
        icon: Icons.info_outline,
        content: _buildInfoTab(),
      ),
      _GroupSettingsSection(
        title: l10n.groupMembersTab,
        icon: Icons.people_outline,
        content: _buildMembersTab(),
      ),
      _GroupSettingsSection(
        title: l10n.groupRolesTab,
        icon: Icons.admin_panel_settings_outlined,
        content: _buildRolesTab(),
      ),
      if (_canManageMembers)
        _GroupSettingsSection(
          title: l10n.groupBansTab,
          icon: Icons.block_outlined,
          content: _buildBanListTab(),
        ),
      if (_canDeleteGroup)
        _GroupSettingsSection(
          title: l10n.groupDeleteTab,
          icon: Icons.delete_outline,
          content: _buildDeleteTab(),
          destructive: true,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 980;
        final isTablet = constraints.maxWidth >= 680;

        if (_isLoading || _currentGroup == null) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Text(_currentGroup?.name ?? l10n.groupInfoTab),
              centerTitle: !isWideScreen,
            ),
            body: const ScreenBackground(
              child: AppLoadingState(),
            ),
          );
        }

        final sections = _sections(l10n);
        final selectedIndex = _selectedTabIndex.clamp(0, sections.length - 1);
        if (selectedIndex != _selectedTabIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _selectedTabIndex = selectedIndex);
            }
          });
        }

        final horizontalPadding = isWideScreen
            ? 28.0
            : isTablet
            ? 20.0
            : 12.0;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(_currentGroup!.name),
            centerTitle: !isWideScreen,
          ),
          body: ScreenBackground(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    16,
                    horizontalPadding,
                    24,
                  ),
                  child: isWideScreen
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 300,
                              child: _buildNavigationPane(
                                sections: sections,
                                compact: false,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildContentPane(
                                sections: sections,
                                compact: false,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTopSummaryCard(),
                            const SizedBox(height: 16),
                            _buildNavigationPane(
                              sections: sections,
                              compact: true,
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: _buildContentPane(
                                sections: sections,
                                compact: true,
                              ),
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
  }

  Widget _buildNavigationPane({
    required List<_GroupSettingsSection> sections,
    required bool compact,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: compact ? 0 : UITokens.cardElevation,
      color: compact ? theme.colorScheme.surfaceContainerLow : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UITokens.cornerLg),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 20),
        child: compact
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var i = 0; i < sections.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          right: i == sections.length - 1 ? 0 : 10,
                        ),
                        child: _buildSectionChip(i, sections[i]),
                      ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildGroupIdentity(
                    theme,
                    _currentGroup!,
                    dense: false,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.roomSettingsLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < sections.length; i++) ...[
                    _buildSectionTile(i, sections[i]),
                    if (i != sections.length - 1) const SizedBox(height: 6),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _buildTopSummaryCard() {
    return Card(
      elevation: UITokens.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UITokens.cornerLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildGroupIdentity(
          Theme.of(context),
          _currentGroup!,
          dense: true,
        ),
      ),
    );
  }

  Widget _buildGroupIdentity(
    ThemeData theme,
    GroupRoom group, {
    required bool dense,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: dense
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        UserAvatar(
          avatarUrl: group.avatarUrl,
          name: group.name,
          radius: dense ? 28 : 42,
        ),
        SizedBox(height: dense ? 12 : 16),
        Text(
          group.name,
          textAlign: dense ? TextAlign.start : TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if ((group.description ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            group.description!.trim(),
            textAlign: dense ? TextAlign.start : TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: dense ? 2 : 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 14),
        Wrap(
          alignment: dense ? WrapAlignment.start : WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildMetaBadge(
              icon: group.visibility == GroupVisibility.public
                  ? Icons.public
                  : Icons.lock_outline,
              label: group.visibility == GroupVisibility.public
                  ? l10n.publicLabel
                  : l10n.privateLabel,
            ),
            _buildMetaBadge(
              icon: Icons.group_outlined,
              label: l10n.membersCount(group.memberCount),
            ),
            _buildMetaBadge(
              icon: Icons.shield_outlined,
              label: _roleLabel(group.currentUserRole, l10n),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetaBadge({
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.75,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildSectionChip(int index, _GroupSettingsSection section) {
    final theme = Theme.of(context);
    final isSelected = _selectedTabIndex == index;
    final icon = Icon(
      section.icon,
      size: 18,
      color: isSelected
          ? theme.colorScheme.onPrimaryContainer
          : section.destructive
          ? theme.colorScheme.error
          : theme.colorScheme.onSurfaceVariant,
    );
    if (isSelected) {
      return ShadButton.secondary(
        onPressed: () => setState(() => _selectedTabIndex = index),
        leading: icon,
        child: Text(section.title),
      );
    }
    return ShadButton.outline(
      onPressed: () => setState(() => _selectedTabIndex = index),
      leading: icon,
      child: Text(
        section.title,
        style: TextStyle(
          color: section.destructive ? theme.colorScheme.error : null,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionTile(int index, _GroupSettingsSection section) {
    final theme = Theme.of(context);
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      borderRadius: BorderRadius.circular(UITokens.corner),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? section.destructive
                    ? theme.colorScheme.errorContainer.withValues(alpha: 0.7)
                    : theme.colorScheme.primaryContainer.withValues(alpha: 0.78)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(UITokens.corner),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              section.icon,
              color: isSelected
                  ? section.destructive
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onPrimaryContainer
                  : section.destructive
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                section.title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? section.destructive
                            ? theme.colorScheme.onErrorContainer
                            : theme.colorScheme.onPrimaryContainer
                      : section.destructive
                      ? theme.colorScheme.error
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentPane({
    required List<_GroupSettingsSection> sections,
    required bool compact,
  }) {
    final theme = Theme.of(context);
    final section = sections[_selectedTabIndex.clamp(0, sections.length - 1)];
    return Card(
      elevation: UITokens.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UITokens.cornerLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.all(compact ? 16 : 20),
            decoration: BoxDecoration(
              color: section.destructive
                  ? theme.colorScheme.errorContainer.withValues(alpha: 0.55)
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.55,
                    ),
            ),
            child: Row(
              children: [
                Icon(
                  section.icon,
                  color: section.destructive
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: RepaintBoundary(child: section.content)),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final group = _currentGroup!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: 260,
                      child: _buildInfoBlock(
                        label: l10n.nameField,
                        value: group.name,
                      ),
                    ),
                    SizedBox(
                      width: 260,
                      child: _buildInfoBlock(
                        label: l10n.roomVisibilityLabel,
                        value: group.visibility == GroupVisibility.public
                            ? l10n.publicLabel
                            : l10n.privateLabel,
                        trailing: Chip(
                          label: Text(
                            group.visibility == GroupVisibility.public
                                ? l10n.publicLabel
                                : l10n.privateLabel,
                          ),
                          avatar: Icon(
                            group.visibility == GroupVisibility.public
                                ? Icons.public
                                : Icons.lock_outline,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 260,
                      child: _buildInfoBlock(
                        label: l10n.membersLabel,
                        value: l10n.membersCount(group.memberCount),
                      ),
                    ),
                    SizedBox(
                      width: 260,
                      child: _buildInfoBlock(
                        label: l10n.groupRolesTab,
                        value: _roleLabel(group.currentUserRole, l10n),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildInfoBlock(
                  label: l10n.descriptionOptionalLabel,
                  value: group.description ?? l10n.noDescription,
                  fullWidth: true,
                ),
                if (_canManageMembers) ...[
                  const SizedBox(height: 24),
                  ShadInput(
                    controller: _nameController,
                    placeholder: Text(l10n.roomNameLabel),
                    leading: const Icon(Icons.edit_outlined, size: 18),
                  ),
                  const SizedBox(height: 12),
                  ShadInput(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 5,
                    placeholder: Text(l10n.descriptionOptionalLabel),
                    leading: const Icon(Icons.description_outlined, size: 18),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ShadButton.outline(
                        onPressed: _isSavingGroupInfo
                            ? null
                            : _pickAndUploadAvatar,
                        leading: const Icon(Icons.image_outlined, size: 18),
                        child: Text(l10n.uploadAvatarButton),
                      ),
                      ShadButton(
                        onPressed: _isSavingGroupInfo ? null : _saveGroupInfo,
                        leading: _isSavingGroupInfo
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        child: Text(l10n.saveButton),
                      ),
                    ],
                  ),
                ],
                ...[
                  const SizedBox(height: 24),
                  ShadButton.outline(
                    onPressed: _copyGroupLink,
                    leading: const Icon(Icons.link_outlined, size: 18),
                    child: Text(l10n.copyLinkAction),
                  ),
                ],
                if (_canManageMembers) ...[
                  const SizedBox(height: 24),
                  _buildInfoBlock(
                    label: l10n.roomJoinRuleLabel,
                    value: _joinRuleSubtitle(l10n, _joinRule),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 320,
                          child: ShadButton.outline(
                            onPressed: _pickJoinRule,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${l10n.roomJoinRuleLabel}: ${_joinRuleTitle(l10n, _joinRule)}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.expand_more_rounded, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 320,
                          child: ShadButton.outline(
                            onPressed: _pickHistoryVisibility,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${l10n.roomHistoryVisibilityLabel}: ${_historyVisibilityTitle(l10n, _historyVisibility)}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.expand_more_rounded, size: 18),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _historyVisibilitySubtitle(l10n, _historyVisibility),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    fullWidth: true,
                  ),
                ],
                if (group.backgroundColor != null) ...[
                  const SizedBox(height: 24),
                  _buildInfoBlock(
                    label: l10n.backgroundColorLabel,
                    value: group.backgroundColor,
                    trailing: Container(
                      width: 96,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _parseColor(group.backgroundColor),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                    ),
                    fullWidth: true,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMembersTab() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final members = _currentGroup?.members ?? [];

    if (members.isEmpty) {
      return Center(
        child: Text(
          l10n.noMembers,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: members.length + (_canManageMembers ? 1 : 0),
      itemBuilder: (context, index) {
        if (_canManageMembers && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.person_add_alt_1_outlined),
                title: Text(l10n.inviteAction),
                subtitle: Text(l10n.copyLinkAction),
                trailing: const Icon(Icons.chevron_right),
                onTap: _copyGroupLink,
              ),
            ),
          );
        }

        final member = members[index - (_canManageMembers ? 1 : 0)];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            onTap: () => _openMemberProfile(member),
            leading: UserAvatar(
              avatarUrl: member.avatarUrl,
              name: member.displayName,
              radius: 20,
            ),
            title: Text(
              member.displayName,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(
                    member.role.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: _getRoleColor(
                    member.role,
                    theme,
                  ).withValues(alpha: 0.2),
                  side: BorderSide(
                    color: _getRoleColor(
                      member.role,
                      theme,
                    ).withValues(alpha: 0.5),
                  ),
                ),
                if (member.userId.isNotEmpty)
                  Text(
                    member.userId,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            trailing: _canManageMembers
                ? PopupMenuButton<void>(
                    icon: Icon(
                      Icons.more_vert,
                      color: theme.colorScheme.outline,
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem<void>(
                        onTap: () => _showRoleDialog(member),
                        child: Row(
                          children: [
                            const Icon(Icons.admin_panel_settings, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.roleAction),
                          ],
                        ),
                      ),
                      PopupMenuItem<void>(
                        onTap: () => _showFreezeDialog(member),
                        child: Row(
                          children: [
                            const Icon(Icons.lock, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.freezeAction),
                          ],
                        ),
                      ),
                      PopupMenuItem<void>(
                        onTap: () => _banUser(member),
                        child: Row(
                          children: [
                            const Icon(Icons.block, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.banAction),
                          ],
                        ),
                      ),
                    ],
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildRolesTab() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final members = _currentGroup?.members ?? [];
    final owners = members.where((m) => m.role == GroupRole.owner).toList();
    final admins = members.where((m) => m.role == GroupRole.admin).toList();
    final regular = members.where((m) => m.role == GroupRole.member).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRoleSection(
            l10n.ownersLabel,
            owners,
            _getRoleColor(GroupRole.owner, theme),
          ),
          const SizedBox(height: 16),
          _buildRoleSection(
            l10n.administratorsLabel,
            admins,
            _getRoleColor(GroupRole.admin, theme),
          ),
          const SizedBox(height: 16),
          _buildRoleSection(
            '👤 ${l10n.membersLabel}',
            regular,
            _getRoleColor(GroupRole.member, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSection(
    String title,
    List<GroupMember> members,
    Color roleColor,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: roleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$title (${members.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (members.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    l10n.noMembers,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              )
            else
              ...members.map(
                (member) => InkWell(
                  onTap: () => _openMemberProfile(member),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        UserAvatar(
                          avatarUrl: member.avatarUrl,
                          name: member.displayName,
                          radius: 16,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.displayName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (member.userId.isNotEmpty)
                                Text(
                                  member.userId,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanListTab() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final banned = _currentGroup?.bannedMembers ?? [];

    if (banned.isEmpty) {
      return Center(
        child: Text(
          l10n.noBannedUsers,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: List.generate(banned.length, (index) {
          final member = banned[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            color: theme.colorScheme.error.withValues(alpha: 0.05),
            child: ListTile(
              onTap: () => _openMemberProfile(member),
              leading: UserAvatar(
                avatarUrl: member.avatarUrl,
                name: member.displayName,
                radius: 20,
              ),
              title: Text(
                member.displayName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.error,
                ),
              ),
              subtitle: Text(l10n.bannedLabel),
              trailing: ShadIconButton.ghost(
                width: 34,
                height: 34,
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.error,
                  size: 18,
                ),
                onPressed: () async {
                  try {
                    await _groupService.unbanUser(widget.roomId, member.userId);
                    await _loadGroupData();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.userUnbanned)),
                    );
                  } on Object catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.genericError(e.toString()))),
                    );
                  }
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDeleteTab() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            color: theme.colorScheme.error.withValues(alpha: 0.1),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      color: theme.colorScheme.error,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.deleteGroupLabel,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.deleteGroupWarning,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ShadButton(
                      onPressed: _showDeleteConfirmation,
                      leading: const Icon(Icons.delete_forever, size: 18),
                      child: Text(
                        l10n.deleteGroupLabel,
                        style: TextStyle(
                          color: theme.colorScheme.onError,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRoleDialog(GroupMember member) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.changeRoleTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: member.role == GroupRole.admin
                  ? const Icon(Icons.radio_button_checked_rounded)
                  : const Icon(Icons.radio_button_off_rounded),
              title: Text(l10n.adminRole),
              onTap: () async {
                Navigator.pop(dialogContext);
                try {
                  await _groupService.setUserRole(
                    widget.roomId,
                    member.userId,
                    GroupRole.admin,
                  );
                  await _loadGroupData();
                } on Object catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.genericError(e.toString()))),
                  );
                }
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: member.role == GroupRole.member
                  ? const Icon(Icons.radio_button_checked_rounded)
                  : const Icon(Icons.radio_button_off_rounded),
              title: Text(l10n.memberRole),
              onTap: () async {
                Navigator.pop(dialogContext);
                try {
                  await _groupService.setUserRole(
                    widget.roomId,
                    member.userId,
                    GroupRole.member,
                  );
                  await _loadGroupData();
                } on Object catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.genericError(e.toString()))),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFreezeDialog(GroupMember member) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.freezeUserTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final entry in [
              MapEntry(l10n.oneHour, const Duration(hours: 1)),
              MapEntry(l10n.oneDay, const Duration(days: 1)),
              MapEntry(l10n.sevenDays, const Duration(days: 7)),
            ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(entry.key),
                onTap: () async {
                  Navigator.pop(dialogContext);
                  try {
                    await _groupService.freezeUser(
                      widget.roomId,
                      member.userId,
                      duration: entry.value,
                    );
                    await _loadGroupData();
                  } on Object catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.genericError(e.toString()))),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _banUser(GroupMember member) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _groupService.banUser(widget.roomId, member.userId);
      await _loadGroupData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.userBanned)),
      );
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.genericError(e.toString()))),
      );
    }
  }

  void _showDeleteConfirmation() {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await _groupService.deleteGroup(widget.roomId);
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.groupDeleted)));
              } on AegisFeatureInDevelopmentException {
                if (!mounted) return;
                await showFeatureInDevelopmentDialog(
                  context,
                  feature: l10n.delete,
                );
              } on Object catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.genericError(e.toString()))),
                );
              }
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBlock({
    required String label,
    required String? value,
    Widget? trailing,
    bool fullWidth = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(UITokens.corner),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            (value?.trim().isNotEmpty ?? false) ? value!.trim() : '-',
            style: theme.textTheme.bodyLarge,
          ),
          if (trailing != null) ...[
            const SizedBox(height: 12),
            trailing,
          ],
        ],
      ),
    );
  }

  String _roleLabel(GroupRole role, AppLocalizations l10n) {
    switch (role) {
      case GroupRole.owner:
        return l10n.ownersLabel;
      case GroupRole.admin:
        return l10n.adminRole;
      case GroupRole.member:
        return l10n.memberRole;
      case GroupRole.guest:
        return l10n.guestRole;
    }
  }

  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return Colors.grey.shade300;
    }
    try {
      final colorString = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$colorString', radix: 16));
    } catch (_) {
      return Colors.grey.shade300;
    }
  }

  Color _getRoleColor(GroupRole role, ThemeData theme) {
    switch (role) {
      case GroupRole.owner:
        return theme.colorScheme.error;
      case GroupRole.admin:
        return Colors.orange;
      case GroupRole.member:
        return theme.colorScheme.primary;
      case GroupRole.guest:
        return theme.colorScheme.outline;
    }
  }
}
