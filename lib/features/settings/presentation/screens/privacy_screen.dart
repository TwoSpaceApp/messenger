import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/services/biometric_service.dart';
import 'package:two_space_app/core/widgets/section_page_header.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final bool _loading = false;

  @override
  void initState() {
    super.initState();
    SettingsService.loadDeferredSettings();
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, UITokens.spaceSm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSurfaceTile(BuildContext context, Widget child) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UITokens.cornerSm),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final list = ListView(
      padding: const EdgeInsets.all(UITokens.space),
      children: [
        if (widget.embedded) ...[
          SectionPageHeader(
            title: l10n.privacyTitle,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const SizedBox(height: UITokens.space),
        ],
        _buildSectionTitle(context, l10n.contactDataSection),
        ValueListenableBuilder<bool>(
          valueListenable: SettingsService.showEmailNotifier,
          builder: (context, isEnabled, _) {
            return _buildSurfaceTile(
              context,
              SwitchListTile(
                title: Text(l10n.emailLabel),
                subtitle: Text(l10n.privacyTitle),
                secondary: const Icon(Icons.email_outlined),
                value: isEnabled,
                onChanged: _loading
                    ? null
                    : (value) async {
                        await SettingsService.setShowEmail(value);
                      },
              ),
            );
          },
        ),
        const SizedBox(height: UITokens.spaceSm),
        ValueListenableBuilder<bool>(
          valueListenable: SettingsService.showPhoneNotifier,
          builder: (context, isEnabled, _) {
            return _buildSurfaceTile(
              context,
              SwitchListTile(
                title: Text(l10n.phoneLabel),
                subtitle: Text(l10n.privacyTitle),
                secondary: const Icon(Icons.phone_outlined),
                value: isEnabled,
                onChanged: _loading
                    ? null
                    : (value) async {
                        await SettingsService.setShowPhone(value);
                      },
              ),
            );
          },
        ),
        const SizedBox(height: UITokens.space),
        _buildSectionTitle(context, l10n.securitySection),
        ValueListenableBuilder<bool>(
          valueListenable: SettingsService.biometricsNotifier,
          builder: (context, isEnabled, child) {
            return SwitchListTile(
              title: Text(l10n.biometricsEnable),
              subtitle: Text(l10n.biometricsSetup),
              secondary: const Icon(Icons.fingerprint),
              value: isEnabled,
              onChanged: _loading
                  ? null
                  : (v) async {
                      if (v) {
                        final authenticated =
                            await BiometricService.authenticate(
                              l10n.biometricsSetup,
                            );
                        if (authenticated) {
                          await SettingsService.setBiometricsEnabled(true);
                        }
                      } else {
                        await SettingsService.setBiometricsEnabled(false);
                      }
                    },
            );
          },
        ),
        const SizedBox(height: UITokens.spaceSm),
        ValueListenableBuilder<int>(
          valueListenable: SettingsService.sessionTimeoutDaysNotifier,
          builder: (c, days, _) {
            return Column(
              children: [
                Material(
                  color: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UITokens.cornerSm),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.lock_clock),
                    title: Text(l10n.sessionExpiry),
                    subtitle: Text(l10n.sessionExpirySubtitle(days)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _loading
                        ? null
                        : () async {
                            final width = MediaQuery.of(context).size.width;
                            final horizontalInset = (width * 0.08).clamp(
                              12.0,
                              28.0,
                            );
                            final controller = TextEditingController(
                              text: days.toString(),
                            );
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                insetPadding: EdgeInsets.symmetric(
                                  horizontal: horizontalInset,
                                  vertical: 24,
                                ),
                                title: Text(l10n.sessionExpiryDaysTitle),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(l10n.sessionExpiryDaysContent),
                                    const SizedBox(height: UITokens.spaceSm),
                                    TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: l10n.daysLabel,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: Text(l10n.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final v =
                                          int.tryParse(
                                            controller.text.trim(),
                                          ) ??
                                          -1;
                                      if (v < 7 || v > 365) {
                                        // show inline error
                                        ScaffoldMessenger.of(ctx).showSnackBar(
                                          SnackBar(
                                            content: Text(l10n.enterDaysError),
                                          ),
                                        );
                                        return;
                                      }
                                      Navigator.of(ctx).pop(true);
                                    },
                                    child: Text(l10n.save),
                                  ),
                                ],
                              ),
                            );
                            if (ok ?? false) {
                              final v =
                                  int.tryParse(controller.text.trim()) ?? days;
                              final newV = v.clamp(7, 365);
                              final messenger = ScaffoldMessenger.of(context);
                              await SettingsService.setSessionTimeoutDays(newV);
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(l10n.sessionExpirySet(newV)),
                                ),
                              );
                            }
                          },
                  ),
                ),
                const SizedBox(height: UITokens.space),
              ],
            );
          },
        ),
        _buildSurfaceTile(
          context,
          ListTile(
            leading: const Icon(Icons.devices_rounded),
            title: Text(l10n.activeSessionsLabel),
            subtitle: Text(l10n.activeSessionsSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppStrings.routeActiveSessions),
          ),
        ),
        const SizedBox(height: UITokens.spaceSm),
        _buildSurfaceTile(
          context,
          ListTile(
            leading: const Icon(Icons.security),
            title: Text(l10n.twoFactorLabel),
            subtitle: Text(l10n.twoFactorPrivacySubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppStrings.routeTfaSetup),
          ),
        ),
      ],
    );

    final content = Material(color: Colors.transparent, child: list);

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: ScreenBackground(child: content),
    );
  }
}
