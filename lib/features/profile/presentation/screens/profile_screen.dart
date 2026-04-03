import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/services/navigation_service.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/chat/data/services/chat_backend_factory.dart';
import 'package:two_space_app/features/chat/presentation/screens/call_screen.dart';
import 'package:two_space_app/features/profile/presentation/widgets/user_avatar.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen(
      {required this.userId, super.key, this.initialName, this.initialAvatar});
  final String userId;
  final String? initialName;
  final String? initialAvatar;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AegisChatService _chatService = AegisChatService();
  Map<String, dynamic>? _user;
  bool _loading = true;
  bool _actionLoading = false;
  bool _isMe = false;
  bool _isEditing = false;
  final ValueNotifier<double> _avatarStretch = ValueNotifier(0);

  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _locationController = TextEditingController();
  final _birthdayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _aboutController.dispose();
    _locationController.dispose();
    _birthdayController.dispose();
    _avatarStretch.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    try {
      final results = await Future.wait<dynamic>([
        _chatService.getCurrentUserId(),
        _chatService.getUserInfo(widget.userId),
      ]);
      final currentUserId = results[0] as String?;
      final userInfo = Map<String, dynamic>.from(results[1] as Map<String, dynamic>);

      // Determine if this is my profile
      _isMe = currentUserId != null && widget.userId == currentUserId;

      if (mounted) {
        setState(() {
          _user = {
            'id': userInfo['id']?.toString() ?? widget.userId,
            'name': userInfo['displayName'] ??
                widget.initialName ??
                userInfo['username'] ??
                widget.userId,
            'username': userInfo['username'] ?? '',
            'avatar': userInfo['avatarUrl'] ?? widget.initialAvatar,
            'avatars': userInfo['avatars'] ?? const <Map<String, dynamic>>[],
            'bio': userInfo['bio'] ?? '',
            'location': userInfo['location'] ?? '',
            'birthday': userInfo['birthday'] ?? '',
            'email': userInfo['email'],
            'presenceStatus': userInfo['presenceStatus'],
            'lastSeenAt': userInfo['lastSeenAt'],
            'prefs': {
              'nickname': userInfo['username'] ?? '',
              'about': userInfo['bio'] ?? '',
              'avatarUrl': userInfo['avatarUrl'] ?? widget.initialAvatar,
            },
          };
          _loading = false;
        });
        _initializeControllers();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _user = {
            'id': widget.userId,
            'name': widget.initialName ?? widget.userId,
            'username': widget.userId.replaceAll('@', '').split(':').first,
            'prefs': {
              'nickname': widget.userId.replaceAll('@', '').split(':').first,
              'about': '',
            },
          };
        });
        _initializeControllers();
      }
    }
  }

  void _initializeControllers() {
    if (_user != null) {
      final prefs = (_user!['prefs'] is Map)
          ? Map<String, dynamic>.from(_user!['prefs'])
          : <String, dynamic>{};
      _nameController.text = (_user!['name'] as String?)?.trim() ?? '';
      _nicknameController.text = (prefs['nickname'] as String?)?.trim() ?? '';
      _aboutController.text = (prefs['about'] as String?)?.trim() ??
          (_user!['bio'] as String?)?.trim() ??
          '';
      _locationController.text = (_user!['location'] as String?)?.trim() ?? '';
      _birthdayController.text = (_user!['birthday'] as String?)?.trim() ?? '';
    }
  }

  Future<void> _pickAvatar() async {
    final l10n = AppLocalizations.of(context)!;
    if (_actionLoading) return;

    Uint8List? avatarBytes;
    String mimePathOrName = '';

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        avatarBytes = await image.readAsBytes();
        mimePathOrName = image.path;
      }
    } catch (_) {
      // Ignore and fallback to FilePicker below.
    }

    if (avatarBytes == null) {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          withData: true,
        );
        if (result == null || result.files.isEmpty) {
          return;
        }
        final file = result.files.single;
        avatarBytes = file.bytes;
        mimePathOrName = file.name;
        if (avatarBytes == null && file.path != null) {
          avatarBytes = await File(file.path!).readAsBytes();
          mimePathOrName = file.path!;
        }
      } catch (e) {
        if (!mounted) return;
        final raw = e.toString().toLowerCase();
        final denied = raw.contains('permission') ||
            raw.contains('denied') ||
            raw.contains('access') ||
            raw.contains('operation not permitted');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              denied
                  ? l10n.filePickError('Нет доступа к выбранному файлу')
                  : l10n.filePickError(e.toString()),
            ),
          ),
        );
        return;
      }
    }

    if (avatarBytes == null || avatarBytes.isEmpty) {
      return;
    }

    try {
      setState(() => _actionLoading = true);
      final uploaded = await _chatService.uploadMyAvatar(
        avatarBytes,
        mimeType: _mimeTypeForPath(mimePathOrName),
      );
      if (!mounted) return;
      setState(() {
        _user = {
          ...?_user,
          'avatar': uploaded['avatarUrl'] ?? _user?['avatar'],
          'avatars': uploaded['avatars'] ?? _user?['avatars'],
          'presenceStatus': uploaded['presenceStatus'] ?? _user?['presenceStatus'],
          'lastSeenAt': uploaded['lastSeenAt'] ?? _user?['lastSeenAt'],
          'prefs': {
            if (_user?['prefs'] is Map)
              ...Map<String, dynamic>.from(_user!['prefs'] as Map),
            'avatarUrl': uploaded['avatarUrl'] ?? _user?['avatar'],
          },
        };
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileSaved)),
      );
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString().toLowerCase();
      final denied = raw.contains('permission') ||
          raw.contains('denied') ||
          raw.contains('access') ||
          raw.contains('operation not permitted');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            denied
                ? 'Нет доступа к файлу аватара. Попробуйте выбрать другой файл.'
                : e.toString().replaceAll('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _actionLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final displayName = _nameController.text.trim();
      final username = _nicknameController.text.trim();
      final bio = _aboutController.text.trim();

      await _chatService.updateMyProfile(
        displayName: displayName.isEmpty ? null : displayName,
        username: username.isEmpty ? null : username,
        bio: bio.isEmpty ? null : bio,
        location: _locationController.text.trim(),
        birthDate: _birthdayController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _isEditing = false;
        _user = {
          ...?_user,
          'name': displayName.isEmpty ? (_user?['name'] ?? '') : displayName,
          'username':
              username.isEmpty ? (_user?['username'] ?? '') : username,
          'bio': bio,
          'presenceStatus': _user?['presenceStatus'],
          'lastSeenAt': _user?['lastSeenAt'],
          'prefs': {
            if (_user?['prefs'] is Map)
              ...Map<String, dynamic>.from(_user!['prefs'] as Map),
            'nickname': username,
            'about': bio,
            'avatarUrl': _avatarUrl(),
          },
          'location': _locationController.text.trim(),
          'birthday': _birthdayController.text.trim(),
        };
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileSaved)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  String _displayName() {
    try {
      if (_user == null) return widget.initialName ?? widget.userId;
      final prefs = (_user!['prefs'] is Map)
          ? Map<String, dynamic>.from(_user!['prefs'])
          : <String, dynamic>{};
      final name = (_user!['name'] as String?)?.trim();
      if (name != null && name.isNotEmpty) return name;
      final nick = (prefs['nickname'] as String?)?.trim();
      if (nick != null && nick.isNotEmpty) return nick;
      final email = (_user!['email'] as String?) ?? '';
      if (email.isNotEmpty) return email.split('@').first;
    } catch (_) {}
    return widget.initialName ?? widget.userId;
  }

  String? _avatarUrl() {
    try {
      if (_user != null) {
        final prefs = (_user!['prefs'] is Map)
            ? Map<String, dynamic>.from(_user!['prefs'])
            : <String, dynamic>{};
        return (prefs['avatarUrl'] as String?) ?? (_user!['avatar'] as String?);
      }
    } catch (_) {}
    return widget.initialAvatar;
  }

  String _username() {
    final usernameValue = (_user?['username'] as String?)?.trim();
    if (usernameValue != null && usernameValue.isNotEmpty) {
      return usernameValue;
    }
    final prefs = (_user?['prefs'] is Map)
        ? Map<String, dynamic>.from(_user!['prefs'] as Map)
        : <String, dynamic>{};
    return (prefs['nickname'] as String?)?.trim() ??
        widget.userId.replaceAll('@', '').split(':').first;
  }

  String _profileId() {
    return ((_user?['id'] as String?)?.trim().isNotEmpty ?? false)
        ? _user!['id'] as String
        : widget.userId;
  }

  String _mimeTypeForPath(String path) {
    final normalized = path.toLowerCase();
    if (normalized.endsWith('.png')) return 'image/png';
    if (normalized.endsWith('.webp')) return 'image/webp';
    if (normalized.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  DateTime? _lastSeenAt() {
    final raw = _user?['lastSeenAt'];
    if (raw is DateTime) return raw;
    if (raw is String && raw.isNotEmpty) return DateTime.tryParse(raw);
    return null;
  }

  String? _presenceLabel(AppLocalizations l10n) {
    final status = (_user?['presenceStatus'] as String?)?.toLowerCase();
    final lastSeenAt = _lastSeenAt();
    if (status == 'online') {
      return l10n.statusOnline;
    }
    if (status == 'recently') {
      return l10n.statusLastSeenRecently;
    }
    if ((status == 'was_online' || status == 'offline') &&
        lastSeenAt != null) {
      return _relativeTime(lastSeenAt, l10n);
    }
    if (status == 'long_ago') {
      return l10n.offlineLabel;
    }
    if (lastSeenAt != null) {
      return _relativeTime(lastSeenAt, l10n);
    }
    return null;
  }

  Color _presenceColor(BuildContext context) {
    final status = (_user?['presenceStatus'] as String?)?.toLowerCase();
    if (status == 'online') {
      return AppColors.onlineStatus(context);
    }
    return Theme.of(context).colorScheme.outline;
  }

  String _relativeTime(DateTime value, AppLocalizations l10n) {
    final delta = DateTime.now().difference(value);
    if (delta.inSeconds < 60) return l10n.lessThanMinuteAgo;
    if (delta.inMinutes < 60) return l10n.minutesAgo(delta.inMinutes);
    if (delta.inHours < 24) return l10n.hoursAgo(delta.inHours);
    if (delta.inDays < 7) return l10n.daysAgo(delta.inDays);
    return '${value.day}.${value.month.toString().padLeft(2, '0')}';
  }

  bool _updateAvatarStretch(double next) {
    final normalized = next.clamp(0.0, 72.0);
    if ((_avatarStretch.value - normalized).abs() < 0.5) {
      return false;
    }
    _avatarStretch.value = normalized;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = _displayName();
    final avatar = _avatarUrl();
    final username = _username();
    final profileId = _profileId();
    final presenceLabel = _presenceLabel(l10n);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        centerTitle: false,
        actions: [
          if (_isMe)
            IconButton(
              icon: Icon(_isEditing ? Icons.check : Icons.edit),
              onPressed: _isEditing
                  ? _saveProfile
                  : () => setState(() => _isEditing = true),
              tooltip: _isEditing ? l10n.saveTooltip : l10n.editTooltip,
            ),
        ],
      ),
      body: ScreenBackground(
        child: _loading
          ? const AppLoadingState()
          : LayoutBuilder(
              builder: (context, constraints) {
            final isWide = constraints.maxWidth >= UITokens.desktopBreakpoint;
            final isTablet = constraints.maxWidth >= UITokens.tabletBreakpoint;
                final horizontalPadding = constraints.maxWidth >= 1400
                    ? 40.0
                    : isWide
                        ? 28.0
                        : isTablet
                            ? 20.0
                  : 14.0;
              final heroPanelWidth =
                (constraints.maxWidth * 0.34).clamp(320.0, 420.0);
                final heroPanel = ValueListenableBuilder<double>(
                  valueListenable: _avatarStretch,
                  builder: (context, stretch, _) => _buildHeroPanel(
                    context: context,
                    l10n: l10n,
                    name: name,
                    avatar: avatar,
                    username: username,
                    profileId: profileId,
                    presenceLabel: presenceLabel,
                    isWide: isWide,
                    avatarStretch: stretch,
                  ),
                );
                final detailsPanel = _buildDetailsPanel(
                  context: context,
                  l10n: l10n,
                  username: username,
                  profileId: profileId,
                );

                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.axis != Axis.vertical) {
                          return false;
                        }

                        if (notification is OverscrollNotification &&
                            notification.metrics.pixels <=
                                notification.metrics.minScrollExtent &&
                            notification.overscroll < 0) {
                          _updateAvatarStretch(
                            _avatarStretch.value + (-notification.overscroll * 0.6),
                          );
                        } else if (notification is ScrollUpdateNotification &&
                            notification.metrics.pixels >
                                notification.metrics.minScrollExtent &&
                            _avatarStretch.value > 0) {
                          _updateAvatarStretch(0);
                        } else if (notification is ScrollEndNotification &&
                            _avatarStretch.value > 0) {
                          _updateAvatarStretch(0);
                        }
                        return false;
                      },
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          isWide ? 24 : 16,
                          horizontalPadding,
                          24,
                        ),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: heroPanelWidth, child: heroPanel),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 760),
                                      child: detailsPanel,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  heroPanel,
                                  const SizedBox(height: 16),
                                  detailsPanel,
                                ],
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }

  Widget _buildHeroPanel({
    required BuildContext context,
    required AppLocalizations l10n,
    required String name,
    required String? avatar,
    required String username,
    required String profileId,
    required String? presenceLabel,
    required bool isWide,
    required double avatarStretch,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final baseAvatarSize = isWide ? 124.0 : 102.0;
    final avatarSize = baseAvatarSize + avatarStretch;

    return Card(
      elevation: UITokens.cardElevation,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UITokens.cornerLg),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primary.withValues(alpha: 0.12),
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(isWide ? 28 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOut,
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            primary,
                            primary.withValues(alpha: 0.58),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.22),
                            blurRadius: 24 + (avatarStretch * 0.2),
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: UserAvatar(
                          key: ValueKey(avatar ?? 'noavatar_${widget.userId}'),
                          avatarUrl: avatar,
                          name: name,
                          radius: (avatarSize / 2) - 8,
                        ),
                      ),
                    ),
                    if (_isMe && _isEditing)
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: FilledButton(
                          onPressed: _pickAvatar,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 0),
                            padding: const EdgeInsets.all(10),
                            shape: const CircleBorder(),
                          ),
                          child: const Icon(Icons.camera_alt_outlined, size: 18),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '@$username',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (presenceLabel != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _presenceColor(context).withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, size: 8, color: _presenceColor(context)),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  presenceLabel,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: _presenceColor(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildMetaChip(
                  context,
                  icon: Icons.badge_outlined,
                  label: 'ID: $profileId',
                ),
                if (_user?['email'] is String && (_user!['email'] as String).isNotEmpty)
                  _buildMetaChip(
                    context,
                    icon: Icons.alternate_email,
                    label: _user!['email'] as String,
                  ),
              ],
            ),
            if (!_isMe) ...[
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compactButtons = constraints.maxWidth < 500;
                  if (compactButtons) {
                    return Column(
                      children: [
                        _buildActionButton(
                          icon: _actionLoading ? null : Icons.chat_bubble_outline,
                          label: l10n.writeMessageButton,
                          loading: _actionLoading,
                          fullWidth: true,
                          onPressed: _actionLoading
                              ? null
                              : () async {
                                  setState(() => _actionLoading = true);
                                  final messenger = ScaffoldMessenger.of(context);
                                  final navState = appNavigatorKey.currentState;
                                  try {
                                    final cs = createChatBackend();
                                    final m = await cs.getOrCreateDirectChat(widget.userId);
                                    final chat = Chat.fromMap(m);
                                    if (!mounted) return;
                                    navState?.pop(chat);
                                  } catch (e) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.createChatError(e.toString())),
                                      ),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() => _actionLoading = false);
                                    }
                                  }
                                },
                        ),
                        const SizedBox(height: 10),
                        _buildActionButton(
                          icon: Icons.call_outlined,
                          label: l10n.callButton,
                          fullWidth: true,
                          onPressed: () async {
                            final roomName =
                                'call_${widget.userId.replaceAll(RegExp('[^a-zA-Z0-9_-]'), '_')}_${DateTime.now().millisecondsSinceEpoch}';
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CallScreen(
                                  room: roomName,
                                  isVideo: true,
                                  displayName: _displayName(),
                                  avatarUrl: _avatarUrl(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: _actionLoading ? null : Icons.chat_bubble_outline,
                          label: l10n.writeMessageButton,
                          loading: _actionLoading,
                          fullWidth: true,
                          onPressed: _actionLoading
                              ? null
                              : () async {
                                  setState(() => _actionLoading = true);
                                  final messenger = ScaffoldMessenger.of(context);
                                  final navState = appNavigatorKey.currentState;
                                  try {
                                    final cs = createChatBackend();
                                    final m = await cs.getOrCreateDirectChat(widget.userId);
                                    final chat = Chat.fromMap(m);
                                    if (!mounted) return;
                                    navState?.pop(chat);
                                  } catch (e) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.createChatError(e.toString())),
                                      ),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() => _actionLoading = false);
                                    }
                                  }
                                },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.call_outlined,
                          label: l10n.callButton,
                          fullWidth: true,
                          onPressed: () async {
                            final roomName =
                                'call_${widget.userId.replaceAll(RegExp('[^a-zA-Z0-9_-]'), '_')}_${DateTime.now().millisecondsSinceEpoch}';
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CallScreen(
                                  room: roomName,
                                  isVideo: true,
                                  displayName: _displayName(),
                                  avatarUrl: _avatarUrl(),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsPanel({
    required BuildContext context,
    required AppLocalizations l10n,
    required String username,
    required String profileId,
  }) {
    final theme = Theme.of(context);
    final infoTiles = _buildInfoTiles(l10n, username, profileId);

    return Card(
      elevation: UITokens.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UITokens.cornerLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? l10n.editTooltip : l10n.profileTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isEditing ? l10n.profileSubtitle : l10n.peopleViewProfileAction,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            if (_isEditing)
              Column(
                children: [
                  _buildEditableField(l10n.nameField, _nameController, Icons.person),
                  const SizedBox(height: 12),
                  _buildEditableField(
                    l10n.nicknameField,
                    _nicknameController,
                    Icons.alternate_email,
                  ),
                  const SizedBox(height: 12),
                  _buildEditableField(
                    l10n.aboutField,
                    _aboutController,
                    Icons.info_outline,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),
                  _buildEditableField(
                    l10n.locationField,
                    _locationController,
                    Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildEditableField(
                    l10n.birthdayField,
                    _birthdayController,
                    Icons.cake_outlined,
                  ),
                ],
              )
            else
              _buildInfoList(infoTiles),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoList(List<({String label, String? value})> infoTiles) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(UITokens.cornerSm),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < infoTiles.length; i++) ...[
            _buildTelegramInfoRow(infoTiles[i].label, infoTiles[i].value),
            if (i != infoTiles.length - 1)
              Divider(
                height: 1,
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.4),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTelegramInfoRow(String title, String? value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value?.isNotEmpty ?? false ? value! : '-',
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<({String label, String? value})> _buildInfoTiles(
    AppLocalizations l10n,
    String username,
    String profileId,
  ) {
    final values = <({String label, String? value})>[
      (
        label: l10n.aboutField,
        value: (_user != null)
            ? (_user!['prefs']?['about'] ?? _user!['bio'] ?? '') as String?
            : '',
      ),
    ];

    if (_user != null) {
      final prefs = (_user!['prefs'] is Map)
          ? Map<String, dynamic>.from(_user!['prefs'] as Map)
          : <String, dynamic>{};
      final email = (_user!['email'] as String?) ?? '';
      final phone = (_user!['phone'] as String?) ?? '';
      final serverShowEmail = prefs['showEmail'] == true;
      final serverShowPhone = prefs['showPhone'] == true;
      final shouldShowEmail =
          _isMe ? SettingsService.showEmailNotifier.value : serverShowEmail;
      final shouldShowPhone =
          _isMe ? SettingsService.showPhoneNotifier.value : serverShowPhone;

      if (email.isNotEmpty && shouldShowEmail) {
        values.add((label: l10n.emailLabel, value: email));
      }
      if (phone.isNotEmpty && shouldShowPhone) {
        values.add((label: l10n.phoneLabel, value: phone));
      }
    }

    values.addAll([
      (label: l10n.nicknameField, value: username),
      (label: l10n.contactIdLabel, value: profileId),
      (
        label: l10n.locationField,
        value: (_user != null) ? (_user!['location'] as String?) ?? '' : '',
      ),
      (
        label: l10n.birthdayField,
        value: (_user != null) ? (_user!['birthday'] as String?) ?? '' : '',
      ),
    ]);
    return values;
  }

  Widget _buildMetaChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData? icon,
      required String label,
      VoidCallback? onPressed,
      bool fullWidth = false,
      bool loading = false}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(fullWidth ? double.infinity : 180, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UITokens.cornerSm)),
      ),
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2))
          : icon != null
              ? Icon(icon)
              : const SizedBox.shrink(),
      label: Text(label),
    );
  }

  Widget _buildEditableField(
      String label, TextEditingController controller, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UITokens.cornerSm),
        ),
      ),
    );
  }

}
