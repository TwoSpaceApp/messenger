import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/utils/user_facing_error.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/feature_in_development_dialog.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/inline_notice_card.dart';
import 'package:two_space_app/core/widgets/section_page_header.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/auth/data/services/biometric_auth_service.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final AegisChatService _chatService = AegisChatService();
  final BiometricAuthService _biometricAuthService = BiometricAuthService();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _accountLoading = true;
  bool _biometricsAvailable = false;
  bool _biometricsEnabled = false;
  String? _accountError;
  Map<String, dynamic>? _accountProfile;

  @override
  void initState() {
    super.initState();
    _loadAccountState();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadAccountState() async {
    if (mounted) {
      setState(() {
        _accountLoading = true;
        _accountError = null;
      });
    }

    Object? profileError;

    Future<Map<String, dynamic>?> loadProfile() async {
      try {
        final profile = await _chatService.getOwnUserInfo();
        return Map<String, dynamic>.from(profile);
      } catch (error) {
        profileError = error;
        return null;
      }
    }

    Future<bool> loadBiometricAvailability() async {
      try {
        return await _biometricAuthService.canAuthenticate();
      } catch (_) {
        return false;
      }
    }

    Future<bool> loadBiometricEnabled() async {
      try {
        return await _biometricAuthService.isBiometricEnabled();
      } catch (_) {
        return false;
      }
    }

    final results = await Future.wait<Object?>([
      loadProfile(),
      loadBiometricAvailability(),
      loadBiometricEnabled(),
    ]);
    if (!mounted) {
      return;
    }

    final loadedProfile = results[0] as Map<String, dynamic>?;
    setState(() {
      _accountProfile = loadedProfile;
      _biometricsAvailable = results[1]! as bool;
      _biometricsEnabled = results[2]! as bool;
      _accountError = loadedProfile == null && profileError != null
          ? UserFacingError.format(profileError!, AppLocalizations.of(context))
          : null;
      _accountLoading = false;
    });
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UITokens.spaceMd,
        UITokens.spaceXLg,
        UITokens.spaceMd,
        UITokens.space,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: color ?? Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProfileSummaryCard(
    BuildContext context,
    AppLocalizations l10n,
    String primaryLabel,
    String displayName,
    String username,
    String? email,
    String profileId,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UITokens.spaceMd,
        UITokens.spaceMd,
        UITokens.spaceMd,
        UITokens.spaceSm,
      ),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(UITokens.spaceMd),
          child: _accountLoading
              ? Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: UITokens.borderThick,
                      ),
                    ),
                    const SizedBox(width: UITokens.spaceMd),
                    Text(l10n.loading),
                  ],
                )
              : _accountProfile == null
              ? AppErrorState(
                  title: l10n.accountSettingsTitle,
                  message: _accountError ?? l10n.errorGeneric,
                  actionLabel: l10n.retry,
                  onAction: _loadAccountState,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      primaryLabel,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (displayName.isNotEmpty && username.isNotEmpty) ...[
                      const SizedBox(height: UITokens.spaceXS),
                      Text(
                        '@$username',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    if (email != null || profileId.isNotEmpty) ...[
                      const SizedBox(height: UITokens.spaceSm),
                      Text(
                        email ?? profileId,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildChangePasswordSection(AppLocalizations l10n) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(UITokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InlineNoticeCard(
              icon: Icons.construction_rounded,
              badge: l10n.featureInDevelopmentLabel,
              title: l10n.changePasswordSection,
              message: l10n.featureInDevelopmentMessage(
                l10n.changePasswordSection,
              ),
            ),
            const SizedBox(height: UITokens.spaceMd),
            TextField(
              controller: _currentPasswordController,
              obscureText: _obscureCurrentPassword,
              decoration: InputDecoration(
                labelText: l10n.currentPasswordLabel,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () => setState(
                    () => _obscureCurrentPassword = !_obscureCurrentPassword,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(UITokens.cornerSm),
                ),
              ),
            ),
            const SizedBox(height: UITokens.spaceMd),
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              decoration: InputDecoration(
                labelText: l10n.newPasswordLabel,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _obscureNewPassword = !_obscureNewPassword),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(UITokens.cornerSm),
                ),
                helperText: l10n.minPasswordHelper,
              ),
            ),
            const SizedBox(height: UITokens.spaceMd),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: l10n.confirmPasswordLabel,
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(UITokens.cornerSm),
                ),
              ),
            ),
            const SizedBox(height: UITokens.spaceMd),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _changePassword,
                icon: const Icon(Icons.check),
                label: Text(l10n.changePasswordButton),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: UITokens.space,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UITokens.cornerSm),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactDataSection(
    AppLocalizations l10n,
    String? email,
    String profileId,
  ) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UITokens.spaceMd,
          vertical: UITokens.space,
        ),
        child: Column(
          children: [
            InlineNoticeCard(
              icon: Icons.info_outline_rounded,
              badge: l10n.featureInDevelopmentLabel,
              title: l10n.contactDataSection,
              message: l10n.featureInDevelopmentMessage(
                l10n.contactDataSection,
              ),
            ),
            const SizedBox(height: UITokens.spaceMd),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(l10n.emailLabel),
              subtitle: Text(email ?? l10n.updateTrustUnavailable),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppStrings.routeChangeEmail),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: UITokens.spaceSm,
              ),
            ),
            if (profileId.isNotEmpty) ...[
              const Divider(height: UITokens.borderThin),
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: Text(l10n.contactIdLabel),
                subtitle: Text(profileId),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: UITokens.spaceSm,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection(AppLocalizations l10n) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UITokens.spaceMd,
          vertical: UITokens.space,
        ),
        child: Column(
          children: [
            InlineNoticeCard(
              icon: Icons.security_rounded,
              badge: l10n.featureInDevelopmentLabel,
              title: l10n.twoFactorLabel,
              message: l10n.featureInDevelopmentMessage(l10n.twoFactorLabel),
            ),
            const Divider(height: UITokens.borderThin),
            ListTile(
              leading: const Icon(Icons.fingerprint_rounded),
              title: Text(l10n.biometricAuthLabel),
              subtitle: Text(_biometricsSubtitle(l10n)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppStrings.routeBiometricSetup),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: UITokens.spaceSm,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZoneSection(AppLocalizations l10n) {
    return GlassCard(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(UITokens.corner),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _deleteAccount,
            borderRadius: BorderRadius.circular(UITokens.corner),
            child: Padding(
              padding: const EdgeInsets.all(UITokens.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InlineNoticeCard(
                    icon: Icons.warning_amber_rounded,
                    badge: l10n.featureInDevelopmentLabel,
                    title: l10n.deleteAccountTitle,
                    message: l10n.featureInDevelopmentMessage(
                      l10n.deleteAccountTitle,
                    ),
                  ),
                  const SizedBox(height: UITokens.spaceMdSm),
                  Row(
                    children: [
                      Icon(
                        Icons.delete_forever,
                        color: AppColors.danger(context),
                      ),
                      const SizedBox(width: UITokens.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.deleteAccountLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppColors.danger(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            Text(
                              l10n.deleteAccountSubtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .error
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.danger(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _displayName() {
    final profile = _accountProfile;
    if (profile == null) {
      return '';
    }

    final displayName = profile['displayName']?.toString().trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final username = profile['username']?.toString().trim();
    if (username != null && username.isNotEmpty) {
      return username;
    }

    return profile['id']?.toString().trim() ?? '';
  }

  String _username() {
    return _accountProfile?['username']?.toString().trim() ?? '';
  }

  String? _email() {
    final value = _accountProfile?['email']?.toString().trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  String _profileId() {
    return _accountProfile?['id']?.toString().trim() ?? '';
  }

  String _biometricsSubtitle(AppLocalizations l10n) {
    if (!_biometricsAvailable) {
      return l10n.updateTrustUnavailable;
    }
    if (_biometricsEnabled) {
      return l10n.biometricEnabledLabel;
    }
    return l10n.biometricsSetup;
  }

  Future<void> _changePassword() async {
    final l10n = AppLocalizations.of(context)!;
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.passwordMismatch)),
      );
      return;
    }

    if (_newPasswordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.passwordTooShort)),
      );
      return;
    }

    await showFeatureInDevelopmentDialog(
      context,
      feature: l10n.changePasswordSection,
    );

    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteAccountTitle),
        content: Text(
          l10n.deleteAccountContent,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await showFeatureInDevelopmentDialog(
        context,
        feature: l10n.deleteAccountTitle,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = _displayName();
    final username = _username();
    final email = _email();
    final profileId = _profileId();
    final primaryLabel = displayName.isNotEmpty
      ? displayName
      : (username.isNotEmpty ? '@$username' : profileId);
    final content = SafeArea(
      top: !widget.embedded,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.embedded)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  UITokens.spaceMd,
                  UITokens.space,
                  UITokens.spaceMd,
                  UITokens.spaceSm,
                ),
                child: SectionPageHeader(
                  title: l10n.accountSettingsTitle,
                  leading: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
              ),
            _buildProfileSummaryCard(
              context,
              l10n,
              primaryLabel,
              displayName,
              username,
              email,
              profileId,
            ),
            _buildSectionTitle(context, l10n.changePasswordSection),
            _buildChangePasswordSection(l10n),
            _buildSectionTitle(context, l10n.contactDataSection),
            _buildContactDataSection(l10n, email, profileId),
            _buildSectionTitle(context, l10n.biometricSetupTitle),
            _buildSecuritySection(l10n),
            _buildSectionTitle(
              context,
              l10n.dangerZoneSection,
              color: AppColors.danger(context),
            ),
            _buildDangerZoneSection(l10n),
            const SizedBox(height: UITokens.spaceXL),
          ],
        ),
      ),
    );

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.accountSettingsTitle),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: ScreenBackground(child: content),
    );
  }
}
