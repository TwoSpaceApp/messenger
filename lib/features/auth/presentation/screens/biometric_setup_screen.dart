import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/core/widgets/section_page_header.dart';
import 'package:two_space_app/features/auth/data/services/biometric_auth_service.dart';

class BiometricSetupScreen extends StatefulWidget {
  const BiometricSetupScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  final biometricService = BiometricAuthService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final body = ScreenBackground(
      child: SafeArea(
        top: !widget.embedded,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UITokens.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.embedded) ...[
                SectionPageHeader(
                  title: l10n.biometricSetupTitle,
                  subtitle: l10n.biometricAuthSubtitle,
                  leading: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                const SizedBox(height: UITokens.spaceMd),
              ],
              Text(
                l10n.authMethodsLabel,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: UITokens.spaceMd),

              // Biometric option
              FutureBuilder<bool>(
                future: biometricService.canAuthenticate(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!) {
                    return const SizedBox.shrink();
                  }

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.fingerprint),
                      title: Text(l10n.biometricAuthLabel),
                      subtitle: Text(l10n.biometricAuthSubtitle),
                      trailing: Switch(
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
              const SizedBox(height: UITokens.spaceMd),

              // PIN code option
              Card(
                child: ListTile(
                  leading: const Icon(Icons.lock),
                  title: Text(l10n.pinCodeLabel),
                  subtitle: Text(l10n.pinCodeSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _showPinDialog(context, biometricService);
                  },
                ),
              ),
              const SizedBox(height: UITokens.spaceXLg),

              // Info section
              Container(
                padding: const EdgeInsets.all(UITokens.space),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(UITokens.corner),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aboutSecurityLabel,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: UITokens.spaceSm),
                    Text(
                      l10n.aboutSecurityContent,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.biometricSetupTitle),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: body,
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
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.setPinCode),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            maxLength: 6,
            decoration: InputDecoration(
              labelText: l10n.pinHint,
              errorText: _errorText,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () async {
            final pin = _pinController.text.trim();
            if (pin.length < 4 || pin.length > 6) {
              setState(() => _errorText = l10n.pinLengthError);
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
