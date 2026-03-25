import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/config/app_colors.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

    // TODO: Implement password change logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.passwordChangeSuccess)),
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
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      // TODO: Implement account deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.deleteFeatureLater)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.accountSettingsTitle),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: ScreenBackground(
        child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Change password
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  l10n.changePasswordSection,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        decoration: InputDecoration(
                          labelText: l10n.currentPasswordLabel,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureCurrentPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => setState(() =>
                                _obscureCurrentPassword =
                                    !_obscureCurrentPassword),
                          ),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(UITokens.cornerSm)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        decoration: InputDecoration(
                          labelText: l10n.newPasswordLabel,
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureNewPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => setState(() =>
                                _obscureNewPassword = !_obscureNewPassword),
                          ),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(UITokens.cornerSm)),
                          helperText: l10n.minPasswordHelper,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: l10n.confirmPasswordLabel,
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () => setState(() =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword),
                          ),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(UITokens.cornerSm)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _changePassword,
                          icon: const Icon(Icons.check),
                          label: Text(l10n.changePasswordButton),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(UITokens.cornerSm)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contact data
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  l10n.contactDataSection,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              GlassCard(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: Text(l10n.emailLabel),
                        subtitle: const Text('—'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(AppStrings.routeChangeEmail),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: Text(l10n.phoneLabel),
                        subtitle: const Text('—'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(AppStrings.routeChangePhone),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ],
                  ),
                ),
              ),

              // Danger zone
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  l10n.dangerZoneSection,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.danger(context),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              GlassCard(
                child: Container(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _deleteAccount,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.delete_forever,
                                color: AppColors.danger(context)),
                            const SizedBox(width: 16),
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
                                          color:
                                              Theme.of(context).colorScheme.error.withValues(alpha: 0.6),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                color: AppColors.danger(context)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
