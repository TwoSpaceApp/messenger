import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/feature_in_development_dialog.dart';
import 'package:two_space_app/features/auth/presentation/widgets/auth_surface.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _loading = false;
  String? _currentEmail;

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    try {
      // Backend email management is not available yet.
      if (!mounted) return;
      setState(() => _currentEmail = null);
    } catch (_) {}
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailCtrl.text.trim();
    _pwdCtrl.text.trim();
    if (email.isEmpty) return;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      // Backend email management is not available yet.
      if (!mounted) return;
      await showFeatureInDevelopmentDialog(
        context,
        feature: l10n.changeEmailTitle,
      );
      // navState.pop(true);
    } on Object catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.changeEmailError(e.toString()))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.changeEmailTitle)),
      body: ValueListenableBuilder<bool>(
        valueListenable: SettingsService.paleVioletNotifier,
        builder: (c, pale, _) {
          final theme = Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              filled: pale,
              fillColor: pale ? const Color(0xFFF6F0FF) : null,
            ),
          );
          return Theme(
            data: theme,
            child: AuthSurface(
              icon: Icons.mail_outline_rounded,
              title: l10n.changeEmailTitle,
              subtitle: l10n.changeEmailDescription,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_currentEmail != null) ...[
                    Text(
                      '${l10n.currentPrefix} $_currentEmail',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                  ],
                  ShadInput(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    leading: const Icon(Icons.alternate_email_rounded, size: 18),
                    placeholder: Text(l10n.newEmailLabel),
                  ),
                  const SizedBox(height: 12),
                  ShadInput(
                    controller: _pwdCtrl,
                    obscureText: true,
                    leading: const Icon(Icons.lock_outline_rounded, size: 18),
                    placeholder: Text(l10n.currentPasswordLabel),
                  ),
                  const SizedBox(height: 16),
                  ShadButton(
                    onPressed: _loading ? null : _submit,
                    width: double.infinity,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.changeEmailButton),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
