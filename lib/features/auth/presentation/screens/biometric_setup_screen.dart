import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/features/auth/data/services/biometric_auth_service.dart';
import 'package:two_space_app/features/auth/presentation/widgets/auth_surface.dart';

class BiometricSetupScreen extends StatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  final biometricService = BiometricAuthService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.biometricSetupTitle),
      ),
      body: AuthSurface(
        icon: Icons.security_rounded,
        title: l10n.biometricSetupTitle,
        subtitle: l10n.authMethodsLabel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<bool>(
              future: biometricService.canAuthenticate(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!) {
                  return const SizedBox.shrink();
                }

                return ShadCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.fingerprint),
                    title: Text(l10n.biometricAuthLabel),
                    subtitle: Text(l10n.biometricAuthSubtitle),
                    trailing: ShadSwitch(
                      value: true,
                      onChanged: (value) async {
                        if (value) {
                          final authenticated = await biometricService
                              .authenticate();
                          if (authenticated) {
                            await biometricService.setBiometricEnabled(true);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.biometricEnabledLabel),
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ShadCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.pin_outlined),
                title: Text(l10n.pinCodeLabel),
                subtitle: Text(l10n.pinCodeSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showPinDialog(context, biometricService),
              ),
            ),
            const SizedBox(height: 12),
            ShadCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.aboutSecurityLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.aboutSecurityContent,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPinDialog(BuildContext context, BiometricAuthService service) {
    showDialog(
      context: context,
      builder: (ctx) => PinInputDialog(biometricService: service),
    );
  }
}

class PinInputDialog extends StatefulWidget {
  const PinInputDialog({required this.biometricService, super.key});
  final BiometricAuthService biometricService;

  @override
  State<PinInputDialog> createState() => _PinInputDialogState();
}

class _PinInputDialogState extends State<PinInputDialog> {
  final _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.setPinCode),
      content: ShadInput(
        controller: _pinController,
        keyboardType: TextInputType.number,
        obscureText: true,
        placeholder: Text(l10n.pinHint),
        leading: const Icon(Icons.lock_outline_rounded, size: 18),
      ),
      actions: [
        ShadButton.outline(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ShadButton(
          onPressed: () async {
            final pin = _pinController.text.trim();
            if (pin.length < 4 || pin.length > 6) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.pinLengthError)),
              );
              return;
            }

            await widget.biometricService.setPinCode(pin);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.pinSetSuccess),
                ),
              );
            }
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
