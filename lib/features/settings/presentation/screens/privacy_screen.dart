import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/services/biometric_service.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
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
                                  l10n.biometricsSetup);
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
          // Session persistence setting (silent re-login)
          ValueListenableBuilder<int>(
            valueListenable: SettingsService.sessionTimeoutDaysNotifier,
            builder: (c, days, _) {
              return Column(
                children: [
                  Material(
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      leading: const Icon(Icons.lock_clock),
                      title: Text(l10n.sessionExpiry),
                      subtitle: Text(l10n.sessionExpirySubtitle(days)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _loading
                          ? null
                          : () async {
                              final controller =
                                  TextEditingController(text: days.toString());
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(l10n.sessionExpiryDaysTitle),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(l10n.sessionExpiryDaysContent),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: controller,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            labelText: l10n.daysLabel),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(false),
                                        child: Text(l10n.cancel)),
                                    TextButton(
                                      onPressed: () {
                                        final v = int.tryParse(
                                                controller.text.trim()) ??
                                            -1;
                                        if (v < 7 || v > 365) {
                                          // show inline error
                                          ScaffoldMessenger.of(ctx)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      l10n.enterDaysError)));
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
                                    int.tryParse(controller.text.trim()) ??
                                        days;
                                final newV = v.clamp(7, 365);
                                final messenger = ScaffoldMessenger.of(context);
                                await SettingsService.setSessionTimeoutDays(
                                    newV);
                                messenger.showSnackBar(SnackBar(
                                    content:
                                        Text(l10n.sessionExpirySet(newV))));
                              }
                            },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
          Material(
            color: Theme.of(context).colorScheme.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    );
  }
}
