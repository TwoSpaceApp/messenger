import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/services/biometric_service.dart';
import 'package:two_space_app/core/widgets/glass_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final bool _loading = false;

  Future<int?> _showSessionTimeoutDialog(
    BuildContext context,
    AppLocalizations l10n,
    int days,
  ) async {
    final controller = TextEditingController(text: days.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: GlassCard(
          borderRadius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.sessionExpiryDaysTitle,
                style: Theme.of(
                  dialogContext,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(l10n.sessionExpiryDaysContent),
              const SizedBox(height: 16),
              ShadInput(
                controller: controller,
                keyboardType: TextInputType.number,
                placeholder: Text(l10n.daysLabel),
                leading: const Icon(Icons.calendar_month_outlined, size: 18),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ShadButton.outline(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      height: 44,
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ShadButton(
                      onPressed: () {
                        final value =
                            int.tryParse(controller.text.trim()) ?? -1;
                        if (value < 7 || value > 365) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text(l10n.enterDaysError)),
                          );
                          return;
                        }
                        Navigator.of(dialogContext).pop(value);
                      },
                      height: 44,
                      child: Text(l10n.save),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.privacyTitle),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ScreenBackground(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            GlassCard(
              borderRadius: 20,
              child: ValueListenableBuilder<bool>(
                valueListenable: SettingsService.biometricsNotifier,
                builder: (context, isEnabled, child) {
                  return ShadSwitch(
                    value: isEnabled,
                    enabled: !_loading,
                    onChanged: _loading
                        ? null
                        : (v) async {
                            if (v) {
                              final authenticated =
                                  await BiometricService.authenticate(
                                    l10n.biometricsSetup,
                                  );
                              if (authenticated) {
                                await SettingsService.setBiometricsEnabled(
                                  true,
                                );
                              }
                            } else {
                              await SettingsService.setBiometricsEnabled(false);
                            }
                          },
                    label: Row(
                      children: [
                        const Icon(Icons.fingerprint),
                        const SizedBox(width: 12),
                        Expanded(child: Text(l10n.biometricsEnable)),
                      ],
                    ),
                    sublabel: Padding(
                      padding: const EdgeInsets.only(left: 36),
                      child: Text(l10n.biometricsSetup),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              borderRadius: 20,
              padding: EdgeInsets.zero,
              child: ValueListenableBuilder<int>(
                valueListenable: SettingsService.sessionTimeoutDaysNotifier,
                builder: (context, days, _) {
                  return ListTile(
                    leading: const Icon(Icons.lock_clock),
                    title: Text(l10n.sessionExpiry),
                    subtitle: Text(l10n.sessionExpirySubtitle(days)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _loading
                        ? null
                        : () async {
                            final value = await _showSessionTimeoutDialog(
                              context,
                              l10n,
                              days,
                            );
                            if (value == null) {
                              return;
                            }
                            final newValue = value.clamp(7, 365);
                            await SettingsService.setSessionTimeoutDays(
                              newValue,
                            );
                            if (!mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.sessionExpirySet(newValue)),
                              ),
                            );
                          },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              borderRadius: 20,
              padding: EdgeInsets.zero,
              child: ListTile(
                leading: const Icon(Icons.security),
                title: Text(l10n.twoFactorLabel),
                subtitle: Text(l10n.twoFactorPrivacySubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppStrings.routeTfaSetup),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
