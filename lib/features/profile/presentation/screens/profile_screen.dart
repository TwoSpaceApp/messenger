import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/core/utils/user_content_sanitizer.dart';
import 'package:two_space_app/core/utils/user_facing_error.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/inline_notice_card.dart';
import 'package:two_space_app/core/widgets/section_page_header.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/chat/data/services/chat_backend_factory.dart';
import 'package:two_space_app/features/chat/presentation/screens/call_screen.dart';
import 'package:two_space_app/features/profile/presentation/widgets/user_avatar.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

enum ProfileScreenVariant { account, contact }

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    required this.userId,
    super.key,
    this.initialName,
    this.initialAvatar,
    this.startInEdit = false,
    this.embedded = false,
    this.variant = ProfileScreenVariant.contact,
  });
  final String userId;
  final String? initialName;
  final String? initialAvatar;
  final bool startInEdit;
  final bool embedded;
  final ProfileScreenVariant variant;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AegisChatService _chatService = AegisChatService();
  Map<String, dynamic>? _user;
  String? _loadErrorMessage;
  bool _loading = true;
  bool _actionLoading = false;
  bool _isMe = false;
  bool _editMode = false;
  final ValueNotifier<double> _avatarStretch = ValueNotifier(0);

  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _locationController = TextEditingController();
  final _birthdayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _editMode = widget.startInEdit;
    _warmUpSettings();
    _loadUser();
  }

  bool get _isAccountProfile => widget.variant == ProfileScreenVariant.account;

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

  Future<void> _warmUpSettings() async {
    await SettingsService.loadDeferredSettings();
    if (mounted) {
      setState(() {});
    }
  }

  Map<String, dynamic> _composeProfileState(
    Map<String, dynamic> userInfo,
    String fallbackId,
  ) {
    return <String, dynamic>{
      'id': userInfo['id']?.toString() ?? fallbackId,
      'displayName': userInfo['displayName'] ?? widget.initialName,
      'username': userInfo['username'] ?? '',
      'avatar': userInfo['avatarUrl'] ?? widget.initialAvatar,
      'avatars': userInfo['avatars'] ?? const <Map<String, dynamic>>[],
      'bio': userInfo['bio'] ?? '',
      'location': userInfo['location'] ?? '',
      'birthday': userInfo['birthday'] ?? '',
      'email': userInfo['email'],
      'createdAt': userInfo['createdAt'],
      'presenceStatus': userInfo['presenceStatus'],
      'lastSeenAt': userInfo['lastSeenAt'],
      'showEmail': userInfo['showEmail'] == true,
      'showPhone': userInfo['showPhone'] == true,
    };
  }

  Map<String, dynamic> _fallbackProfileState() {
    return <String, dynamic>{
      'id': widget.userId,
      'displayName': _fallbackProfileName(),
      'username': _fallbackUsername(),
      'avatar': widget.initialAvatar,
      'avatars': const <Map<String, dynamic>>[],
      'bio': '',
      'location': '',
      'birthday': '',
      'email': null,
      'createdAt': null,
      'presenceStatus': null,
      'lastSeenAt': null,
      'showEmail': false,
      'showPhone': false,
    };
  }

  void _applyLoadedUser(Map<String, dynamic> userInfo, {required bool isMe}) {
    if (!mounted) {
      return;
    }
    setState(() {
      _isMe = isMe;
      _user = _composeProfileState(userInfo, widget.userId);
      _loadErrorMessage = null;
      _loading = false;
    });
    _initializeControllers();
  }

  Future<void> _loadUser() async {
    try {
      if (_isAccountProfile) {
        final userInfo = Map<String, dynamic>.from(
          await _chatService.getOwnUserInfo(),
        );
        _applyLoadedUser(userInfo, isMe: true);
        return;
      }

      final currentUserId = await _chatService.getCurrentUserId();
      var userInfo = Map<String, dynamic>.from(
        await _chatService.getUserInfo(widget.userId),
      );

      _isMe = _matchesCurrentUser(currentUserId, userInfo);
      if (_isMe) {
        userInfo = <String, dynamic>{
          ...userInfo,
          ...Map<String, dynamic>.from(
            await _chatService.getOwnUserInfo(),
          ),
        };
      }

      _applyLoadedUser(userInfo, isMe: _isMe);
    } catch (error) {
      final l10n = AppLocalizations.of(context);
      if (mounted) {
        setState(() {
          _loading = false;
          _user = _fallbackProfileState();
          _loadErrorMessage = UserFacingError.format(error, l10n);
        });
        _initializeControllers();
      }
    }
  }

  bool _matchesCurrentUser(
    String? currentUserId,
    Map<String, dynamic> userInfo,
  ) {
    final candidates = <String>{
      _normalizeProfileToken(widget.userId),
      _normalizeProfileToken(userInfo['id']?.toString()),
      _normalizeProfileToken(userInfo['username']?.toString()),
    }..removeWhere((value) => value.isEmpty);

    final current = _normalizeProfileToken(currentUserId);
    if (current.isEmpty) {
      return false;
    }
    return candidates.contains(current);
  }

  String _normalizeProfileToken(String? value) {
    if (value == null) {
      return '';
    }
    return value.trim().replaceFirst('@', '').split(':').first.toLowerCase();
  }

  String _fallbackUsername() {
    final normalized = widget.userId
        .replaceAll('@', '')
        .split(':')
        .first
        .trim();
    return normalized.isEmpty ? widget.userId.trim() : normalized;
  }

  String _fallbackProfileName() {
    final initial = widget.initialName?.trim();
    if (initial != null && initial.isNotEmpty) {
      return initial;
    }
    return _fallbackUsername();
  }

  void _initializeControllers() {
    if (_user != null) {
      _nameController.text = (_user!['displayName'] as String?)?.trim() ?? '';
      _nicknameController.text = (_user!['username'] as String?)?.trim() ?? '';
      _aboutController.text = (_user!['bio'] as String?)?.trim() ?? '';
      _locationController.text = (_user!['location'] as String?)?.trim() ?? '';
      _birthdayController.text = (_user!['birthday'] as String?)?.trim() ?? '';
    }
  }

  Future<void> _pickAvatar() async {
    final l10n = AppLocalizations.of(context)!;
    if (_actionLoading) return;

    Uint8List? avatarBytes;
    String mimePathOrName = '';
    Object? galleryError;

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        avatarBytes = await image.readAsBytes();
        mimePathOrName = image.path;
      }
    } catch (error) {
      galleryError = error;
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
        final denied =
            raw.contains('permission') ||
            raw.contains('denied') ||
            raw.contains('access') ||
            raw.contains('operation not permitted');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              denied
                  ? l10n.filePickError(l10n.fileAccessDeniedMessage)
                  : l10n.filePickError(
                      UserFacingError.format(
                        galleryError ?? e,
                        AppLocalizations.of(context),
                      ),
                    ),
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
      _applyLoadedUser(Map<String, dynamic>.from(uploaded), isMe: _isMe);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileSaved)),
      );
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString().toLowerCase();
      final denied =
          raw.contains('permission') ||
          raw.contains('denied') ||
          raw.contains('access') ||
          raw.contains('operation not permitted');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            denied
                ? l10n.avatarFileAccessDeniedMessage
                : UserFacingError.format(e, AppLocalizations.of(context)),
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
      final displayName = UserContentSanitizer.sanitizeOptionalText(
        _nameController.text,
        maxLength: 120,
      );
      final username = UserContentSanitizer.sanitizeUsername(
        _nicknameController.text,
      );
      final bio = UserContentSanitizer.sanitizeOptionalText(
        _aboutController.text,
        maxLength: 512,
      );
      final location = UserContentSanitizer.sanitizeOptionalText(
        _locationController.text,
        maxLength: 120,
        preserveNewlines: false,
      );

      final updated = await _chatService.updateMyProfile(
        displayName: displayName,
        username: username.isEmpty ? null : username,
        bio: bio,
        location: location,
        birthDate: _birthdayController.text.trim(),
      );

      if (!mounted) return;
      _applyLoadedUser(Map<String, dynamic>.from(updated), isMe: true);
      setState(() => _editMode = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileSaved)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            UserFacingError.format(e, AppLocalizations.of(context)),
          ),
        ),
      );
    }
  }

  String _displayName() {
    if (_user == null) return widget.initialName ?? widget.userId;
    final displayName = (_user!['displayName'] as String?)?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    final username = (_user!['username'] as String?)?.trim();
    if (username != null && username.isNotEmpty) {
      return username;
    }
    final email = (_user!['email'] as String?)?.trim() ?? '';
    if (email.isNotEmpty) {
      return email.split('@').first;
    }
    return _fallbackProfileName();
  }

  bool _hasReadableProfileData() {
    if (_user == null) {
      return false;
    }
    final name = (_user!['displayName'] as String?)?.trim() ?? '';
    final bio = (_user!['bio'] as String?)?.trim() ?? '';
    final location = (_user!['location'] as String?)?.trim() ?? '';
    final birthday = (_user!['birthday'] as String?)?.trim() ?? '';
    return name.isNotEmpty ||
        bio.isNotEmpty ||
        location.isNotEmpty ||
        birthday.isNotEmpty;
  }

  String _emptyProfileHint(AppLocalizations l10n) {
    if (_isMe) {
      return l10n.profileEmptySelfHint;
    }
    return l10n.profileEmptyOtherHint;
  }

  String? _avatarUrl() {
    if (_user != null) {
      return (_user!['avatar'] as String?) ?? widget.initialAvatar;
    }
    return widget.initialAvatar;
  }

  String _username() {
    final usernameValue = (_user?['username'] as String?)?.trim();
    if (usernameValue != null && usernameValue.isNotEmpty) {
      return usernameValue;
    }
    return '';
  }

  Future<void> _openDirectChat() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _actionLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final cs = createChatBackend();
      final mappedChat = await cs.getOrCreateDirectChat(widget.userId);
      final chat = Chat.fromMap(mappedChat);
      if (!mounted) {
        return;
      }
      await context.push(
        '${AppStrings.routeChat}/${Uri.encodeComponent(chat.id)}',
        extra: chat,
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.createChatError(
              UserFacingError.format(error, AppLocalizations.of(context)),
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _actionLoading = false);
      }
    }
  }

  void _openCall() {
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
  }

  Widget _buildContactActionButtons(AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactButtons = constraints.maxWidth < 500;
        final messageButton = _buildActionButton(
          icon: _actionLoading ? null : Icons.chat_bubble_outline,
          label: l10n.writeMessageButton,
          loading: _actionLoading,
          fullWidth: true,
          onPressed: _actionLoading ? null : _openDirectChat,
        );
        final callButton = _buildActionButton(
          icon: Icons.call_outlined,
          label: l10n.callButton,
          fullWidth: true,
          onPressed: _openCall,
        );

        if (compactButtons) {
          return Column(
            children: [
              messageButton,
              const SizedBox(height: UITokens.spaceSmMd),
              callButton,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: messageButton),
            const SizedBox(width: UITokens.spaceSmMd),
            Expanded(child: callButton),
          ],
        );
      },
    );
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

  Future<void> _pickBirthday() async {
    final currentText = _birthdayController.text.trim();
    final initialDate = DateTime.tryParse(currentText) ?? DateTime(2000);
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selected == null || !mounted) {
      return;
    }
    _birthdayController.text =
        '${selected.year.toString().padLeft(4, '0')}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
    setState(() {});
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
    if ((status == 'was_online' || status == 'offline') && lastSeenAt != null) {
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

  void _startInlineEdit() {
    _initializeControllers();
    setState(() => _editMode = true);
  }

  void _cancelInlineEdit() {
    _initializeControllers();
    setState(() => _editMode = false);
  }

  Future<void> _copyProfileId() async {
    final l10n = AppLocalizations.of(context)!;
    final profileId = _profileId();
    if (profileId.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: profileId));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.textCopied)),
    );
  }

  void _showModerationStub(String feature) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.featureInDevelopmentMessage(feature))),
    );
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
    final usernameLabel = username.isNotEmpty ? '@$username' : profileId;
    final presenceLabel = _presenceLabel(l10n);
    final body = _loading
        ? const AppLoadingState()
        : LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= UITokens.desktopBreakpoint;
              final isTablet =
                  constraints.maxWidth >= UITokens.tabletBreakpoint;
              final horizontalPadding = constraints.maxWidth >= 1400
                  ? 40.0
                  : isWide
                  ? 28.0
                  : isTablet
                  ? 20.0
                  : 14.0;
              final heroPanelWidth = (constraints.maxWidth * 0.34).clamp(
                320.0,
                420.0,
              );
              final heroPanel = ValueListenableBuilder<double>(
                valueListenable: _avatarStretch,
                builder: (context, stretch, _) => _buildHeroPanel(
                  context: context,
                  l10n: l10n,
                  name: name,
                  avatar: avatar,
                  username: usernameLabel,
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
                  constraints: const BoxConstraints(
                    maxWidth: UITokens.contentMaxWidth,
                  ),
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
                          _avatarStretch.value +
                              (-notification.overscroll * 0.6),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (widget.embedded) ...[
                            SectionPageHeader(
                              title: _isAccountProfile
                                  ? l10n.accountProfileTitle
                                  : l10n.profileTitle,
                              subtitle: _isAccountProfile
                                  ? (_editMode
                                        ? l10n.accountProfileEditSubtitle
                                        : l10n.accountProfileSubtitle)
                                  : l10n.otherProfileSubtitle,
                              leading: IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(Icons.arrow_back_rounded),
                              ),
                            ),
                            const SizedBox(height: UITokens.spaceMd),
                          ],
                          if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: heroPanelWidth,
                                  child: heroPanel,
                                ),
                                const SizedBox(width: UITokens.spaceXLg),
                                Expanded(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth:
                                          UITokens.readableContentMaxWidth,
                                    ),
                                    child: detailsPanel,
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                heroPanel,
                                const SizedBox(height: UITokens.spaceMd),
                                detailsPanel,
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          _isAccountProfile ? l10n.accountProfileTitle : l10n.profileTitle,
        ),
        centerTitle: false,
        actions: const [],
      ),
      body: ScreenBackground(child: body),
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
                      duration: UITokens.durationXS,
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
                      padding: const EdgeInsets.all(UITokens.spaceXS),
                      child: AnimatedSwitcher(
                        duration: UITokens.durationSm,
                        child: UserAvatar(
                          key: ValueKey(avatar ?? 'noavatar_${widget.userId}'),
                          avatarUrl: avatar,
                          name: name,
                          radius: (avatarSize / 2) - 8,
                        ),
                      ),
                    ),
                    if (_isAccountProfile && _editMode)
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: FilledButton(
                          onPressed: _pickAvatar,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 0),
                            padding: const EdgeInsets.all(UITokens.spaceSmMd),
                            shape: const CircleBorder(),
                          ),
                          child: const Icon(
                            Icons.camera_alt_outlined,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: UITokens.spaceMd),
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
                      const SizedBox(height: UITokens.spaceXSm),
                      Text(
                        username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (presenceLabel != null) ...[
                        const SizedBox(height: UITokens.spaceSmMd),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: UITokens.spaceSmMd,
                            vertical: UITokens.spaceXSm,
                          ),
                          decoration: BoxDecoration(
                            color: _presenceColor(
                              context,
                            ).withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(
                              UITokens.cornerPill,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: _presenceColor(context),
                              ),
                              const SizedBox(width: UITokens.spaceSm),
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
            const SizedBox(height: UITokens.spaceMdSm),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (profileId.isNotEmpty)
                  _buildMetaChip(
                    context,
                    icon: Icons.badge_outlined,
                    label: profileId,
                  ),
                if (username.isNotEmpty)
                  _buildMetaChip(
                    context,
                    icon: Icons.alternate_email_rounded,
                    label: username,
                  ),
                if (_user?['email'] is String &&
                    (_user!['email'] as String).isNotEmpty)
                  _buildMetaChip(
                    context,
                    icon: Icons.mail_outline_rounded,
                    label: _user!['email'] as String,
                  ),
              ],
            ),
            if (_isAccountProfile) ...[
              const SizedBox(height: UITokens.spaceMd),
              Wrap(
                spacing: UITokens.spaceSmMd,
                runSpacing: UITokens.spaceSmMd,
                children: [
                  FilledButton.icon(
                    onPressed: _actionLoading
                        ? null
                        : (_editMode ? _saveProfile : _startInlineEdit),
                    icon: Icon(
                      _editMode ? Icons.save_rounded : Icons.edit_rounded,
                    ),
                    label: Text(
                      _editMode
                          ? l10n.saveProfileButton
                          : l10n.editProfileButton,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _copyProfileId,
                    icon: const Icon(Icons.copy_rounded),
                    label: Text(l10n.copyAegisIdButton),
                  ),
                  if (_editMode)
                    TextButton(
                      onPressed: _cancelInlineEdit,
                      child: Text(l10n.cancelButton),
                    ),
                ],
              ),
            ] else ...[
              const SizedBox(height: UITokens.spaceMd),
              _buildContactActionButtons(l10n),
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
        padding: const EdgeInsets.all(UITokens.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_loadErrorMessage != null) ...[
              InlineNoticeCard(
                icon: Icons.error_outline_rounded,
                title: l10n.errorGeneric,
                message: _loadErrorMessage!,
              ),
              const SizedBox(height: UITokens.spaceMd),
            ],
            if (_loadErrorMessage == null && !_editMode && !_hasReadableProfileData()) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(UITokens.spaceMdSm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(UITokens.cornerLg),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.4,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: UITokens.space),
                    Expanded(
                      child: Text(
                        _emptyProfileHint(l10n),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: UITokens.spaceMd),
            ],
            if (!_isAccountProfile) ...[
              InlineNoticeCard(
                icon: Icons.shield_outlined,
                badge: l10n.featureInDevelopmentLabel,
                title: l10n.profileModerationNoticeTitle,
                message: l10n.profileModerationNoticeMessage,
              ),
              const SizedBox(height: UITokens.spaceMd),
              Wrap(
                spacing: UITokens.spaceSmMd,
                runSpacing: UITokens.spaceSmMd,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showModerationStub(l10n.blockUserAction),
                    icon: const Icon(Icons.block_outlined),
                    label: Text(l10n.blockUserAction),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showModerationStub(l10n.reportUserAction),
                    icon: const Icon(Icons.flag_outlined),
                    label: Text(l10n.reportUserAction),
                  ),
                ],
              ),
              const SizedBox(height: UITokens.spaceMd),
            ],
            if (_editMode)
              Column(
                children: [
                  _buildEditableField(
                    l10n.nameField,
                    _nameController,
                    Icons.person,
                  ),
                  const SizedBox(height: UITokens.space),
                  _buildEditableField(
                    l10n.nicknameField,
                    _nicknameController,
                    Icons.alternate_email,
                  ),
                  const SizedBox(height: UITokens.space),
                  _buildEditableField(
                    l10n.aboutField,
                    _aboutController,
                    Icons.info_outline,
                    maxLines: 4,
                  ),
                  const SizedBox(height: UITokens.space),
                  _buildEditableField(
                    l10n.locationField,
                    _locationController,
                    Icons.location_on_outlined,
                  ),
                  const SizedBox(height: UITokens.space),
                  _buildEditableField(
                    l10n.birthdayField,
                    _birthdayController,
                    Icons.cake_outlined,
                    readOnly: true,
                    onTap: _pickBirthday,
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
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(UITokens.cornerSm),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < infoTiles.length; i++) ...[
            _buildTelegramInfoRow(infoTiles[i].label, infoTiles[i].value),
            if (i != infoTiles.length - 1)
              Divider(
                height: 1,
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTelegramInfoRow(String title, String? value) {
    final theme = Theme.of(context);
    final normalizedValue = value?.trim() ?? '';
    final isEmpty = normalizedValue.isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UITokens.spaceMdSm,
        vertical: UITokens.space,
      ),
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
          const SizedBox(width: UITokens.space),
          Expanded(
            flex: 6,
            child: Text(
              isEmpty ? AppLocalizations.of(context)!.noData : normalizedValue,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isEmpty ? theme.colorScheme.onSurfaceVariant : null,
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
    final displayName = (_user?['displayName'] as String?)?.trim();
    final about = (_user?['bio'] as String?)?.trim();
    final location = (_user?['location'] as String?)?.trim();
    final birthday = (_user?['birthday'] as String?)?.trim();
    final email = (_user?['email'] as String?)?.trim();
    final createdAt = _formattedCreatedAt();
    final status = _presenceLabel(l10n);

    final values = <({String label, String? value})>[
      (label: l10n.nameField, value: displayName),
      (label: l10n.nicknameField, value: username),
      (label: l10n.aboutField, value: about),
      (label: l10n.locationField, value: location),
      (label: l10n.birthdayField, value: birthday),
      (label: l10n.emailLabel, value: email),
      (label: l10n.profileStatusLabel, value: status),
      (label: l10n.registeredAtLabel, value: createdAt),
      (label: l10n.aegisIdLabel, value: profileId),
    ];
    return values;
  }

  String? _formattedCreatedAt() {
    final raw = _user?['createdAt']?.toString().trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }
    return '${parsed.day.toString().padLeft(2, '0')}.${parsed.month.toString().padLeft(2, '0')}.${parsed.year}';
  }

  Widget _buildMetaChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Container(
      constraints: const BoxConstraints(
        maxWidth: UITokens.compactSheetMaxWidth,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: UITokens.space,
        vertical: UITokens.spaceSmMd,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(UITokens.cornerPill),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: UITokens.spaceSm),
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

  Widget _buildActionButton({
    required IconData? icon,
    required String label,
    VoidCallback? onPressed,
    bool fullWidth = false,
    bool loading = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(fullWidth ? double.infinity : 180, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: UITokens.spaceLg,
          vertical: UITokens.space,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UITokens.cornerSm),
        ),
      ),
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: UITokens.borderThick,
              ),
            )
          : icon != null
          ? Icon(icon)
          : const SizedBox.shrink(),
      label: Text(label),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
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
