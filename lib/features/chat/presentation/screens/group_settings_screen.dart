// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/group.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/features/chat/data/services/group_matrix_service.dart';

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
  late GroupMatrixService _groupService;
  int _selectedTabIndex = 0;
  bool _isLoading = false;
  GroupRoom? _currentGroup;

  @override
  void initState() {
    super.initState();
    _groupService = GroupMatrixService();
    _loadGroupData();
  }

  Future<void> _loadGroupData() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    try {
      final group = await _groupService.getGroupRoom(widget.roomId);
      if (mounted) {
        setState(() => _currentGroup = group);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.loadError(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _canManageMembers =>
      _currentGroup?.currentUserRole == GroupRole.owner ||
      _currentGroup?.currentUserRole == GroupRole.admin;

  bool get _canDeleteGroup => _currentGroup?.currentUserRole == GroupRole.owner;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 800;
        return Scaffold(
          appBar: AppBar(
            title: Text(_currentGroup?.name ?? l10n.groupInfoTab),
            centerTitle: !isWideScreen,
            elevation: 2,
          ),
          body: _isLoading || _currentGroup == null
              ? const AppLoadingState(label: 'Загружаем параметры группы…')
              : Row(
                  children: [
                    if (isWideScreen) _buildSidebar(),
                    Expanded(child: _buildSettingsContent()),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSidebar() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      width: 250,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  _buildTab(0, l10n.groupInfoTab, Icons.info),
                  _buildTab(1, l10n.groupMembersTab, Icons.people),
                  _buildTab(2, l10n.groupRolesTab, Icons.admin_panel_settings),
                  if (_canManageMembers)
                    _buildTab(3, l10n.groupBansTab, Icons.block),
                  if (_canDeleteGroup)
                    _buildTab(4, l10n.groupDeleteTab, Icons.delete),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildInfoTab(),
                _buildMembersTab(),
                _buildRolesTab(),
                if (_canManageMembers) _buildBanListTab(),
                if (_canDeleteGroup) _buildDeleteTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTab(0, l10n.groupInfoTab, Icons.info),
                _buildTab(1, l10n.groupMembersTab, Icons.people),
                _buildTab(2, l10n.groupRolesTab, Icons.admin_panel_settings),
                if (_canManageMembers)
                  _buildTab(3, l10n.groupBansTab, Icons.block),
                if (_canDeleteGroup)
                  _buildTab(4, l10n.groupDeleteTab, Icons.delete),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Content
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _buildInfoTab(),
                _buildMembersTab(),
                _buildRolesTab(),
                if (_canManageMembers) _buildBanListTab(),
                if (_canDeleteGroup) _buildDeleteTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = _selectedTabIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    isSelected ? theme.colorScheme.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? theme.colorScheme.primary : null,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.nameField,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentGroup?.name ?? l10n.noDescription,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.descriptionOptionalLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentGroup?.description ?? l10n.noDescription,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.roomVisibilityLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(
                    _currentGroup?.visibility == GroupVisibility.public
                        ? l10n.publicLabel
                        : l10n.privateLabel,
                  ),
                  backgroundColor:
                      _currentGroup?.visibility == GroupVisibility.public
                          ? theme.colorScheme.primary.withValues(alpha: 0.08)
                          : theme.colorScheme.tertiary.withValues(alpha: 0.2),
                  avatar: Icon(
                    _currentGroup?.visibility == GroupVisibility.public
                        ? Icons.public
                        : Icons.lock,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.membersCount(_currentGroup?.memberCount ?? 0),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                if (_canManageMembers) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.messageHistoryToggle,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.outline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.showHistoryToggleLabel),
                    subtitle: Text(l10n.showHistorySubtitle),
                    value: _currentGroup?.showMessageHistory ?? false,
                    onChanged: (value) async {
                      try {
                        await _groupService.setShowMessageHistory(
                            widget.roomId, value);
                        await _loadGroupData();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.settingSaved)),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(l10n.genericError(e.toString()))),
                          );
                        }
                      }
                    },
                  ),
                ],
                if (_currentGroup?.backgroundColor != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    l10n.backgroundColorLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.outline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _parseColor(_currentGroup?.backgroundColor),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
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
      padding: const EdgeInsets.all(8),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  theme.colorScheme.primary.withValues(alpha: 0.08),
              backgroundImage: member.avatarUrl != null
                  ? NetworkImage(member.avatarUrl!)
                  : null,
              child: member.avatarUrl == null
                  ? Text(member.displayName.isNotEmpty
                      ? member.displayName[0]
                      : '?')
                  : null,
            ),
            title: Text(
              member.displayName,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
            subtitle: Chip(
              label: Text(
                member.role.toString().split('.').last.toUpperCase(),
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor:
                  _getRoleColor(member.role, theme).withValues(alpha: 0.2),
              side: BorderSide(
                color: _getRoleColor(member.role, theme).withValues(alpha: 0.5),
              ),
            ),
            trailing: _canManageMembers
                ? PopupMenuButton(
                    icon:
                        Icon(Icons.more_vert, color: theme.colorScheme.outline),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Icons.admin_panel_settings, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.roleAction)
                          ],
                        ),
                        onTap: () => _showRoleDialog(member),
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Icons.lock, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.freezeAction)
                          ],
                        ),
                        onTap: () => _showFreezeDialog(member),
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Icons.block, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.banAction)
                          ],
                        ),
                        onTap: () => _banUser(member),
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Icons.exit_to_app, size: 18),
                            const SizedBox(width: 8),
                            Text(l10n.kickAction)
                          ],
                        ),
                        onTap: () => _kickUser(member),
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
              l10n.ownersLabel, owners, _getRoleColor(GroupRole.owner, theme)),
          const SizedBox(height: 16),
          _buildRoleSection(l10n.administratorsLabel, admins,
              _getRoleColor(GroupRole.admin, theme)),
          const SizedBox(height: 16),
          _buildRoleSection('👤 ${l10n.membersLabel}', regular,
              _getRoleColor(GroupRole.member, theme)),
        ],
      ),
    );
  }

  Widget _buildRoleSection(
      String title, List<GroupMember> members, Color roleColor) {
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
                Text(
                  '$title (${members.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
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
                (m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: roleColor.withValues(alpha: 0.2),
                        backgroundImage: m.avatarUrl != null
                            ? NetworkImage(m.avatarUrl!)
                            : null,
                        radius: 16,
                        child: m.avatarUrl == null
                            ? Text(
                                m.displayName.isNotEmpty
                                    ? m.displayName[0]
                                    : '?',
                                style: TextStyle(color: roleColor),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.displayName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (m.userId.isNotEmpty)
                              Text(
                                m.userId,
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
      padding: const EdgeInsets.all(8),
      child: Column(
        children: List.generate(banned.length, (index) {
          final member = banned[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.red.withValues(alpha: 0.05),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.withValues(alpha: 0.2),
                backgroundImage: member.avatarUrl != null
                    ? NetworkImage(member.avatarUrl!)
                    : null,
                child: member.avatarUrl == null
                    ? Text(member.displayName.isNotEmpty
                        ? member.displayName[0]
                        : '?')
                    : null,
              ),
              title: Text(
                member.displayName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
              subtitle: Text(l10n.bannedLabel),
              trailing: IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () async {
                  try {
                    await _groupService.unbanUser(widget.roomId, member.userId);
                    await _loadGroupData();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.userUnbanned)),
                      );
                    }
                  } catch (e) {
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
            color: Colors.red.withValues(alpha: 0.1),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_rounded,
                        color: Colors.red, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.deleteGroupLabel,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.red,
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
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _showDeleteConfirmation,
                      icon: const Icon(Icons.delete_forever),
                      label: Text(
                        l10n.deleteGroupLabel,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changeRoleTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<GroupRole>(
              title: Text(l10n.adminRole),
              value: GroupRole.admin,
              groupValue: member.role,
              onChanged: (role) async {
                Navigator.pop(context);
                if (role != null) {
                  try {
                    await _groupService.setUserRole(
                      widget.roomId,
                      member.userId,
                      role,
                    );
                    await _loadGroupData();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(l10n.genericError(e.toString()))),
                      );
                    }
                  }
                }
              },
            ),
            RadioListTile<GroupRole>(
              title: Text(l10n.memberRole),
              value: GroupRole.member,
              groupValue: member.role,
              onChanged: (role) async {
                Navigator.pop(context);
                if (role != null) {
                  try {
                    await _groupService.setUserRole(
                      widget.roomId,
                      member.userId,
                      role,
                    );
                    await _loadGroupData();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(l10n.genericError(e.toString()))),
                      );
                    }
                  }
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                title: Text(entry.key),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await _groupService.freezeUser(
                      widget.roomId,
                      member.userId,
                      duration: entry.value,
                    );
                    await _loadGroupData();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(l10n.genericError(e.toString()))),
                      );
                    }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.userBanned)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.genericError(e.toString()))),
        );
      }
    }
  }

  Future<void> _kickUser(GroupMember member) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _groupService.kickUser(widget.roomId, member.userId);
      await _loadGroupData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.userKicked)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.genericError(e.toString()))),
        );
      }
    }
  }

  void _showDeleteConfirmation() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _groupService.deleteGroup(widget.roomId);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.groupDeleted)),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.genericError(e.toString()))),
                  );
                }
              }
            },
            child:
                Text(l10n.delete, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
        return Colors.red;
      case GroupRole.admin:
        return Colors.orange;
      case GroupRole.member:
        return theme.colorScheme.primary;
      case GroupRole.guest:
        return Colors.grey;
    }
  }
}
