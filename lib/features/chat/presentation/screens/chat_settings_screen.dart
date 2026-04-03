// ignore_for_file: deprecated_member_use, unnecessary_underscores

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' as share;
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/utils/message_time_formatter.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/chat/presentation/widgets/feature_in_development_dialog.dart';
import 'package:two_space_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:two_space_app/features/profile/presentation/widgets/user_avatar.dart';

enum _RoomSettingsStatus { ready, inDevelopment, destructive, action }

class _RoomSettingsSection {
  const _RoomSettingsSection({
    required this.key,
    required this.title,
    required this.icon,
    this.status = _RoomSettingsStatus.ready,
  });

  final String key;
  final String title;
  final IconData icon;
  final _RoomSettingsStatus status;
}


class ChatSettingsScreen extends StatefulWidget {
  const ChatSettingsScreen({
    required this.roomId,
    required this.initialName,
    this.roomType,
    super.key,
  });

  final String roomId;
  final String initialName;
  final String? roomType;

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  final _nameController = TextEditingController();
  final AegisChatService _svc = AegisChatService();

  bool _saving = false;
  int _joinRule = 1;
  int _historyVisibility = 1;
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _members = <Map<String, dynamic>>[];
  bool _loadingMembers = false;
  Future<Map<String, dynamic>>? _overviewFuture;
  Future<List<AegisRoomMessage>>? _roomMessagesFuture;

  bool get _isDirectChat =>
      widget.roomType == 'direct' || widget.roomId.startsWith('dm:');

  bool get _isGroupRoom => widget.roomType == 'group';

  bool get _isPublicRoom => widget.roomType == 'public' || _joinRule == 0;

  bool get _supportsLinks => !_isDirectChat && !_isGroupRoom;

  String? get _directPeerUserId {
    if (!_isDirectChat || !widget.roomId.startsWith('dm:')) return null;
    return widget.roomId.substring(3);
  }

  void _openDirectProfile(Map<String, dynamic> data) {
    final userId = data['userId']?.toString() ?? (_directPeerUserId ?? '');
    if (userId.isEmpty) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          userId: userId,
          initialName: data['name']?.toString() ?? widget.initialName,
          initialAvatar: data['avatar']?.toString(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _joinRule = widget.roomType == 'public' ? 0 : 1;
    _overviewFuture = _loadOverview();
    _loadRoomSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<_RoomSettingsSection> _sections(AppLocalizations l10n) {
    final sections = <_RoomSettingsSection>[
      _RoomSettingsSection(
        key: 'info',
        title: l10n.groupInfoTab,
        icon: Icons.info_outline,
      ),
      if (!_isDirectChat)
        _RoomSettingsSection(
          key: 'members',
          title: l10n.membersLabel,
          icon: Icons.group_outlined,
        ),
      _RoomSettingsSection(
        key: 'media',
        title: l10n.mediaLabel,
        icon: Icons.perm_media_outlined,
      ),
      _RoomSettingsSection(
        key: 'files',
        title: l10n.filesLabel,
        icon: Icons.insert_drive_file_outlined,
      ),
      if (!_isDirectChat && !_isGroupRoom)
        _RoomSettingsSection(
          key: 'settings',
          title: l10n.settingsLabel,
          icon: Icons.settings_outlined,
        ),
      if (_supportsLinks)
        _RoomSettingsSection(
          key: 'copylink',
          title: l10n.copyLinkAction,
          icon: Icons.link_outlined,
          status: _RoomSettingsStatus.action,
        ),
      _RoomSettingsSection(
        key: 'export',
        title: l10n.exportChatAction,
        icon: Icons.ios_share_outlined,
        status: _RoomSettingsStatus.action,
      ),
      _RoomSettingsSection(
        key: 'report',
        title: l10n.reportAction,
        icon: Icons.flag_outlined,
        status: _RoomSettingsStatus.inDevelopment,
      ),
      if (!_isDirectChat)
        _RoomSettingsSection(
          key: 'leave',
          title: l10n.leaveRoomAction,
          icon: Icons.logout,
          status: _RoomSettingsStatus.destructive,
        ),
    ];
    return sections;
  }

  String _friendlyError(Object error) {
    return error.toString().replaceFirst(RegExp('^Exception: '), '');
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

  Future<Map<String, dynamic>> _loadOverview() async {
    final roomMeta = await _svc.getRoomNameAndAvatar(widget.roomId);

    if (_isDirectChat) {
      final peerUserId = _directPeerUserId;
      if (peerUserId == null) {
        return {
          'name': roomMeta['name'] ?? widget.initialName,
          'avatar': roomMeta['avatar'],
        };
      }

      final userInfo = await _svc.getUserInfo(peerUserId);
      return {
        'name': userInfo['displayName'] ?? userInfo['username'] ?? widget.initialName,
        'avatar': userInfo['avatarUrl'] ?? roomMeta['avatar'],
        'userId': userInfo['id']?.toString() ?? peerUserId,
        'presenceStatus': userInfo['presenceStatus']?.toString(),
        'lastSeenAt': userInfo['lastSeenAt']?.toString(),
      };
    }

    final members = await _svc.getRoomMembers(widget.roomId);
    return {
      'name': roomMeta['name'] ?? widget.initialName,
      'avatar': roomMeta['avatar'],
      'memberCount': members.length,
      'visibility': _isPublicRoom ? 'public' : 'private',
    };
  }

  Future<void> _loadRoomSettings() async {
    if (_isDirectChat) {
      return;
    }
    try {
      final settings = await _svc.getRoomSettingsState(widget.roomId);
      if (!mounted) return;
      setState(() {
        _joinRule = (settings['joinRule'] as int?) ?? _joinRule;
        _historyVisibility =
            (settings['historyVisibility'] as int?) ?? _historyVisibility;
      });
    } catch (_) {}
  }

  Future<List<AegisRoomMessage>> _loadRoomMessages() {
    return _roomMessagesFuture ??=
      _svc.loadMessages(roomId: widget.roomId, limit: 500);
  }

  Future<void> _loadMembers() async {
    setState(() {
      _loadingMembers = true;
      _members = <Map<String, dynamic>>[];
    });
    try {
      await _svc.clearRoomCache(widget.roomId);
      final list = await _svc.getRoomMembers(widget.roomId, forceRefresh: true);
      if (!mounted) return;
      setState(() => _members = list);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.loadMembersError(_friendlyError(e)),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingMembers = false);
    }
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
      await _svc.setRoomAvatar(widget.roomId, bytes, fileName: path.split('/').last);
      _overviewFuture = _loadOverview();
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.roomAvatarUpdated)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.roomAvatarUploadError(_friendlyError(e)))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveSettings() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      final name = _nameController.text.trim();
      if (name.isNotEmpty) {
        await _svc.setRoomName(widget.roomId, name);
      }
      await _svc.setJoinRuleValue(widget.roomId, _joinRule);
      await _svc.setHistoryVisibility(widget.roomId, _historyVisibility);
      _overviewFuture = _loadOverview();
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.roomSettingsSaved)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.roomSettingsSaveError(_friendlyError(e)))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _copyRoomLink() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      final linkInfo = await _svc.getRoomLinkInfo(widget.roomId);
      final link = linkInfo['preferredLink'];
      if (link == null || link.isEmpty) {
        throw Exception(l10n.errorGeneric);
      }
      await Clipboard.setData(ClipboardData(text: link));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.textCopied)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.genericError(_friendlyError(e)))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _exportChat() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    try {
      final messages = await _loadRoomMessages();
      final overview = await _loadOverview();
      final tempDir = await getTemporaryDirectory();
      final safeId = widget.roomId.replaceAll(RegExp('[^a-zA-Z0-9_-]'), '_');
      final file = File('${tempDir.path}/$safeId.json');
      final payload = {
        'roomId': widget.roomId,
        'roomType': widget.roomType,
        'name': overview['name'] ?? widget.initialName,
        'messages': messages.map((message) => message.toJson()).toList(),
      };
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(payload));
      await share.Share.shareXFiles(
        [share.XFile(file.path)],
        subject: overview['name']?.toString() ?? widget.initialName,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.genericError(_friendlyError(e)))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _showLeaveConfirmation() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.leaveRoomTitle),
        content: Text(l10n.leaveRoomContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.leaveAction,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _saving = true);
    try {
      await _svc.leaveRoom(widget.roomId);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.leftRoom)));
      Navigator.pop(context);
      } on AegisFeatureInDevelopmentException {
        if (!mounted) return;
        await showFeatureInDevelopmentDialog(
          context,
          feature: l10n.leaveAction,
        );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.leaveRoomError(_friendlyError(e)))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _chatTypeLabel(AppLocalizations l10n) {
    if (_isDirectChat) return l10n.directChatTab;
    if (_isGroupRoom) return l10n.groupChatTab;
    return _isPublicRoom ? l10n.publicLabel : l10n.privateLabel;
  }

  String? _presenceLabel(AppLocalizations l10n, Map<String, dynamic> data) {
    final status = data['presenceStatus']?.toString();
    final lastSeenAt = DateTime.tryParse(data['lastSeenAt']?.toString() ?? '');
    switch (status) {
      case 'online':
        return l10n.onlineLabel;
      case 'recently':
        return l10n.statusLastSeenRecently;
      case 'was_online':
      case 'offline':
        if (lastSeenAt != null) {
          return MessageTimeFormatter.formatConversationTime(lastSeenAt);
        }
        return l10n.offlineLabel;
      case 'long_ago':
        return l10n.offlineLabel;
      default:
        return null;
    }
  }

  bool _isMediaMessage(AegisRoomMessage message) {
    return message.type == 'm.image' ||
        message.type == 'm.video' ||
        message.type == 'm.audio';
  }

  bool _isFileMessage(AegisRoomMessage message) {
    if (message.type == 'm.file') return true;
    if (message.mediaId == null || message.mediaId!.isEmpty) return false;
    return !_isMediaMessage(message);
  }

  String _messageTitle(AegisRoomMessage message, AppLocalizations l10n) {
    final raw = message.mediaId ?? message.content;
    if (raw.trim().isEmpty) return l10n.noDescription;
    return raw.split('/').last;
  }

  Future<void> _handleSectionTap(_RoomSettingsSection section, bool isMobile) async {
    switch (section.key) {
      case 'members':
        await _loadMembers();
      case 'copylink':
        await _copyRoomLink();
        return;
      case 'export':
        await _exportChat();
        return;
      case 'leave':
        await _showLeaveConfirmation();
        return;
      default:
        break;
    }

    final sections = _sections(AppLocalizations.of(context)!);
    final nextIndex = sections.indexWhere((item) => item.key == section.key);
    if (nextIndex >= 0) {
      setState(() => _selectedIndex = nextIndex);
    }

    if (isMobile) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _ChatSettingDetailPage(
            title: section.title,
            child: _buildSectionContent(section.key),
          ),
        ),
      );
    }
  }

  Widget _buildOverviewSection() {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<Map<String, dynamic>>(
      future: _overviewFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const AppLoadingState(compact: true);
        }
        final data = snapshot.data!;
        final presence = _isDirectChat ? _presenceLabel(l10n, data) : null;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                onTap: _isDirectChat ? () => _openDirectProfile(data) : null,
                child: Row(
                  children: [
                    UserAvatar(
                      avatarUrl: data['avatar']?.toString(),
                      name: data['name']?.toString() ?? widget.initialName,
                      radius: 28,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name']?.toString() ?? widget.initialName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            presence ?? _chatTypeLabel(l10n),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.generalLabel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: l10n.roomVisibilityLabel,
                      value: _chatTypeLabel(l10n),
                    ),
                    if (_isDirectChat)
                      _InfoRow(
                        label: l10n.contactIdLabel,
                        value: data['userId']?.toString() ?? (_directPeerUserId ?? widget.roomId),
                      ),
                    if (!_isDirectChat)
                      _InfoRow(
                        label: l10n.membersLabel,
                        value: l10n.membersCount((data['memberCount'] as int?) ?? 0),
                      ),
                  ],
                ),
              ),
              if (_supportsLinks) ...[
                const SizedBox(height: 12),
                GlassCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.link_outlined),
                    title: Text(l10n.copyLinkAction),
                    subtitle: Text(l10n.publicRoomSubtitle),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _saving ? null : _copyRoomLink,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMembersSection() {
    final l10n = AppLocalizations.of(context)!;
    if (_loadingMembers) return const AppLoadingState(compact: true);
    if (_members.isEmpty) {
      return AppEmptyState(
        title: l10n.noMembers,
        message: l10n.noDescription,
        icon: Icons.group_outlined,
      );
    }

    return ListView.separated(
      itemCount: _members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final member = _members[index];
        final title = member['displayName']?.toString() ?? member['userId']?.toString() ?? '';
        return GlassCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () {
              final userId = member['userId']?.toString() ?? '';
              if (userId.isEmpty) {
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    userId: userId,
                    initialName: title,
                    initialAvatar: member['avatarUrl']?.toString(),
                  ),
                ),
              );
            },
            leading: UserAvatar(
              avatarUrl: member['avatarUrl']?.toString(),
              name: title,
              radius: 22,
            ),
            title: Text(title),
            subtitle: Text(member['userId']?.toString() ?? ''),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentSection({required bool mediaOnly}) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<List<AegisRoomMessage>>(
      future: _loadRoomMessages(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const AppLoadingState(compact: true);
        }

        final messages = snapshot.data!
            .where(mediaOnly ? _isMediaMessage : _isFileMessage)
            .toList(growable: false)
            .reversed
            .toList(growable: false);

        if (messages.isEmpty) {
          return AppEmptyState(
            title: mediaOnly ? l10n.mediaLabel : l10n.filesLabel,
            message: mediaOnly ? l10n.noSharedMedia : l10n.noSharedFiles,
            icon: mediaOnly ? Icons.perm_media_outlined : Icons.insert_drive_file_outlined,
          );
        }

        return ListView.separated(
          itemCount: messages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final message = messages[index];
            return GlassCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  mediaOnly ? Icons.perm_media_outlined : Icons.insert_drive_file_outlined,
                ),
                title: Text(
                  _messageTitle(message, l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  MessageTimeFormatter.formatConversationTime(message.time),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsSection() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.generalLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.roomNameLabel),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _pickAndUploadAvatar,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(l10n.uploadAvatarButton),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _joinRule,
                  decoration: InputDecoration(labelText: l10n.roomJoinRuleLabel),
                  items: [0, 1, 2]
                      .map(
                        (value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text(_joinRuleTitle(l10n, value)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: _saving
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() => _joinRule = value);
                        },
                ),
                const SizedBox(height: 8),
                Text(
                  _joinRuleSubtitle(l10n, _joinRule),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _historyVisibility,
                  decoration: InputDecoration(
                    labelText: l10n.roomHistoryVisibilityLabel,
                  ),
                  items: [0, 1, 2]
                      .map(
                        (value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text(_historyVisibilityTitle(l10n, value)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: _saving
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() => _historyVisibility = value);
                        },
                ),
                const SizedBox(height: 8),
                Text(
                  _historyVisibilitySubtitle(l10n, _historyVisibility),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _saving ? null : _saveSettings,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.saveButton),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInDevelopmentSection(String feature) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                l10n.featureInDevelopmentLabel,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              feature,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.featureInDevelopmentMessage(feature),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContent(String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'info':
        return _buildOverviewSection();
      case 'members':
        return _buildMembersSection();
      case 'media':
        return _buildAttachmentSection(mediaOnly: true);
      case 'files':
        return _buildAttachmentSection(mediaOnly: false);
      case 'settings':
        return _buildSettingsSection();
      case 'report':
        return _buildInDevelopmentSection(l10n.reportAction);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sections = _sections(l10n);
    if (_selectedIndex >= sections.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(widget.initialName)),
      body: ScreenBackground(
        child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          final leftWidth = isMobile ? constraints.maxWidth : constraints.maxWidth * 0.3;
          final currentSection = sections[_selectedIndex];

          final navigation = Container(
            width: isMobile ? null : leftWidth.clamp(220, 360),
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.02),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _overviewFuture,
                    builder: (context, snapshot) {
                      final data = snapshot.data;
                      final name = data?['name']?.toString() ?? widget.initialName;
                      final avatar = data?['avatar']?.toString();
                      return GlassCard(
                        onTap: _isDirectChat && data != null
                            ? () => _openDirectProfile(data)
                            : null,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: UserAvatar(
                            avatarUrl: avatar,
                            name: name,
                            radius: 22,
                          ),
                          title: Text(name),
                          subtitle: Text(_chatTypeLabel(l10n)),
                          trailing: !_isDirectChat && !_isGroupRoom
                              ? IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: _saving ? null : _pickAndUploadAvatar,
                                )
                              : null,
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
                      final section = sections[index];
                      final isSelected = _selectedIndex == index;
                      final isDanger = section.status == _RoomSettingsStatus.destructive;
                      final isWip = section.status == _RoomSettingsStatus.inDevelopment;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.surfaceContainerHighest
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _handleSectionTap(section, isMobile),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isDanger
                                        ? Theme.of(context).colorScheme.error
                                        : isSelected
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).colorScheme.surface,
                                    child: Icon(
                                      section.icon,
                                      size: 18,
                                      color: isDanger
                                          ? Colors.white
                                          : isSelected
                                              ? Theme.of(context).colorScheme.onPrimary
                                              : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      section.title,
                                      style: TextStyle(
                                        color: isDanger
                                            ? Theme.of(context).colorScheme.error
                                            : isSelected
                                                ? Theme.of(context).colorScheme.primary
                                                : null,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (isWip)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        l10n.featureInDevelopmentLabel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSecondaryContainer,
                                        ),
                                      ),
                                    ),
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

          if (isMobile) {
            return navigation;
          }

          return Row(
            children: [
              SizedBox(width: leftWidth.clamp(220, 360), child: navigation),
              const VerticalDivider(width: 12, thickness: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GlassCard(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _buildSectionContent(currentSection.key),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ChatSettingDetailPage extends StatelessWidget {
  const _ChatSettingDetailPage({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(title)),
      body: ScreenBackground(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: GlassCard(child: child),
        ),
      ),
    );
  }
}
