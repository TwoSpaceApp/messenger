import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/profile/presentation/widgets/user_avatar.dart';

class ChatSettingsScreen extends StatefulWidget {
  const ChatSettingsScreen(
      {required this.roomId, required this.initialName, super.key});
  final String roomId;
  final String initialName;

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  final _nameController = TextEditingController();
  bool _saving = false;
  bool _isPublic = false;
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _members = [];
  bool _loadingMembers = false;
  final _svc = AegisChatService();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
  }

  Future<void> _pickAndUploadAvatar() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    setState(() => _saving = true);
    try {
      final bytes = await File(path).readAsBytes();
        await AegisChatService()
          .setRoomAvatar(widget.roomId, bytes, fileName: path.split('/').last);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.roomAvatarUpdated)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.roomAvatarUploadError(e.toString()))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveSettings() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      final name = _nameController.text.trim();
      if (name.isNotEmpty)
        await AegisChatService().setRoomName(widget.roomId, name);
      // set join rule
      await AegisChatService()
          .setJoinRule(widget.roomId, _isPublic ? 'public' : 'invite');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.roomSettingsSaved)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.roomSettingsSaveError(e.toString()))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildSectionContent(String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'members':
        return _buildMembers();
      case 'settings':
        return _buildSettings();
      default:
        return Center(child: Text(l10n.stubPlaceholder(key)));
    }
  }

  Widget _buildMembers() {
    final l10n = AppLocalizations.of(context)!;
    if (_loadingMembers)
      return const AppLoadingState(compact: true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.membersLabel, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemBuilder: (c, i) {
              final m = _members[i];
              return ListTile(
                leading: CircleAvatar(
                    backgroundImage: m['avatarUrl'] != null
                        ? NetworkImage(m['avatarUrl']!)
                        : null,
                    child: m['avatarUrl'] == null
                        ? Text((m['displayName'] ?? m['userId'] ?? '?')![0])
                        : null),
                title: Text(m['displayName'] ?? m['userId'] ?? ''),
                subtitle: Text(m['userId'] ?? ''),
              );
            },
            separatorBuilder: (_, __) => const Divider(),
            itemCount: _members.length,
          ),
        ),
      ],
    );
  }

  Widget _buildSettings() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.generalLabel,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: l10n.roomNameLabel)),
          const SizedBox(height: 12),
          Row(children: [
            ElevatedButton.icon(
                onPressed: _saving ? null : _pickAndUploadAvatar,
                icon: const Icon(Icons.image),
                label: Text(l10n.uploadAvatarButton))
          ]),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(l10n.publicRoomOption),
            subtitle: Text(l10n.publicRoomSubtitle),
            value: _isPublic,
            onChanged: (v) => setState(() => _isPublic = v),
          ),
          const SizedBox(height: 8),
          Row(children: [
            TextButton(
                onPressed: _saving ? null : _saveSettings,
                child: _saving
                    ? const CircularProgressIndicator()
                    : Text(l10n.saveButton))
          ]),
        ],
      ),
    );
  }

  Future<void> _loadMembers() async {
    setState(() {
      _loadingMembers = true;
      _members = [];
    });
    try {
      // Force refresh members list from server
      await _svc.clearRoomCache(widget.roomId);
      final list = await _svc.getRoomMembers(widget.roomId, forceRefresh: true);
      if (!mounted) return;
      setState(() {
        _members = list;
      });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                AppLocalizations.of(context)!.loadMembersError(e.toString()))));
    } finally {
      if (mounted) setState(() => _loadingMembers = false);
    }
  }

  Future<void> _showLeaveConfirmation() async {
    final l10n = AppLocalizations.of(context)!;
    // Telegram-like multi-step confirmation for leaving a room
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.leaveRoomTitle),
        content: Text(l10n.leaveRoomContent),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancelButton)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.leaveAction,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // Perform the leave action
    setState(() => _saving = true);
    try {
      await AegisChatService().leaveRoom(widget.roomId);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.leftRoom)));
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        Navigator.pop(context);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.leaveRoomError(e.toString()))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _handleDangerAction(String key) async {
    final l10n = AppLocalizations.of(context)!;
    if (key == 'leave') {
      await _showLeaveConfirmation();
    } else if (key == 'report') {
      // TODO: Implement report spam/abuse flow
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.reportNotImplemented)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sections = [
      {'key': 'invite', 'title': l10n.inviteAction, 'icon': Icons.person_add},
      {'key': 'members', 'title': l10n.membersLabel, 'icon': Icons.group},
      {'key': 'threads', 'title': l10n.threadsLabel, 'icon': Icons.alt_route},
      {'key': 'pinned', 'title': l10n.pinnedLabel, 'icon': Icons.push_pin},
      {'key': 'files', 'title': l10n.filesLabel, 'icon': Icons.folder},
      {'key': 'media', 'title': l10n.mediaLabel, 'icon': Icons.image},
      {
        'key': 'extensions',
        'title': l10n.extensionsLabel,
        'icon': Icons.extension
      },
      {'key': 'copylink', 'title': l10n.copyLinkAction, 'icon': Icons.link},
      {'key': 'polls', 'title': l10n.pollsLabel, 'icon': Icons.poll},
      {'key': 'export', 'title': l10n.exportChatAction, 'icon': Icons.download},
      {'key': 'settings', 'title': l10n.settingsLabel, 'icon': Icons.settings},
      {
        'key': 'report',
        'title': l10n.reportAction,
        'icon': Icons.flag,
        'danger': true
      },
      {
        'key': 'leave',
        'title': l10n.leaveRoomAction,
        'icon': Icons.exit_to_app,
        'danger': true
      },
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.roomTitle(widget.initialName))),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final isMobile = maxW < 900;
          final leftWidth = isMobile ? maxW : maxW * 0.28;
          final leftCol = Container(
            width: isMobile ? null : leftWidth.clamp(200, 360),
            color:
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.02),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: FutureBuilder<Map<String, String?>>(
                    future:
                      AegisChatService().getRoomNameAndAvatar(widget.roomId),
                    builder: (c, s) {
                      final meta = s.data ??
                          {'name': widget.initialName, 'avatar': null};
                      return GlassCard(
                        child: ListTile(
                          leading: meta['avatar'] != null
                              ? UserAvatar(
                                  avatarUrl: meta['avatar'], radius: 22)
                              : CircleAvatar(
                                  child: Text((meta['name'] ??
                                              widget.initialName)
                                          .isNotEmpty
                                      ? (meta['name'] ?? widget.initialName)[0]
                                      : '?')),
                          title: Text(meta['name'] ?? widget.initialName,
                              style: Theme.of(context).textTheme.titleMedium),
                          subtitle: Text(l10n.roomSettingsLabel),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () async {
                                    setState(() {});
                                    await AegisChatService()
                                        .clearRoomCache(widget.roomId);
                                  }),
                              IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: _pickAndUploadAvatar),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: sections.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final s = sections[index];
                      final isDanger = s['danger'] == true;
                      final isSelected = _selectedIndex == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12)),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              final key = s['key']! as String;
                              final isDanger = s['danger'] == true;

                              // Handle danger actions with confirmation
                              if (isDanger) {
                                await _handleDangerAction(key);
                                return;
                              }

                              setState(() => _selectedIndex = index);
                              if (key == 'members') await _loadMembers();
                              if (isMobile) {
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => ChatSettingDetailPage(
                                            keyName: key,
                                            title: s['title']! as String,
                                            roomId: widget.roomId,
                                            contentBuilder:
                                                _buildSectionContent)));
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              child: Row(
                                children: [
                                  AnimatedScale(
                                    scale: isSelected ? 1.12 : 1.0,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOutCubic,
                                    child: CircleAvatar(
                                        backgroundColor: isDanger
                                            ? Colors.red
                                            : (isSelected
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .surface),
                                        child: Icon(s['icon']! as IconData,
                                            size: 18,
                                            color: isDanger
                                                ? Colors.white
                                                : (isSelected
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary
                                                    : Theme.of(context)
                                                        .colorScheme
                                                        .onSurface))),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Text(s['title']! as String,
                                          style: isDanger
                                              ? const TextStyle(
                                                  color: Colors.red)
                                              : (isSelected
                                                  ? TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary)
                                                  : null))),
                                  if (s['key'] == 'pinned')
                                    const Chip(label: Text('0')),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
          if (isMobile) return leftCol;
          return Row(
            children: [
              SizedBox(width: leftWidth.clamp(200, 360), child: leftCol),
              const VerticalDivider(width: 12, thickness: 1),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: GlassCard(
                          child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _buildSectionContent(
                                  sections[_selectedIndex]['key']!
                                      as String))))),
            ],
          );
        },
      ),
    );
  }
}

class ChatSettingDetailPage extends StatelessWidget {
  const ChatSettingDetailPage(
      {required this.keyName,
      required this.title,
      required this.roomId,
      required this.contentBuilder,
      super.key});
  final String keyName;
  final String title;
  final String roomId;
  final Widget Function(String) contentBuilder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
          padding: const EdgeInsets.all(12),
          child: GlassCard(child: contentBuilder(keyName))),
    );
  }
}
