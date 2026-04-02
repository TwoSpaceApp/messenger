import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/feature_in_development_dialog.dart';
import 'package:two_space_app/features/auth/presentation/widgets/auth_surface.dart';
import 'package:two_space_app/features/settings/data/services/settings_service.dart';

class ChangePhoneScreen extends StatefulWidget {
  const ChangePhoneScreen({super.key});

  @override
  State<ChangePhoneScreen> createState() => _ChangePhoneScreenState();
}

class _ChangePhoneScreenState extends State<ChangePhoneScreen> {
  final _phoneCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _loading = false;
  String? _currentPhone;

  @override
  void initState() {
    super.initState();
    _loadCurrentPhone();
  }

  Future<void> _loadCurrentPhone() async {
    try {
      // Backend phone management is not available yet.
      if (!mounted) return;
      setState(() => _currentPhone = null);
    } catch (_) {}
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final phone = _phoneCtrl.text.trim();
    _pwdCtrl.text.trim();
    if (phone.isEmpty) return;
    setState(() => _loading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      // Backend phone management is not available yet.
      if (!mounted) return;
      await showFeatureInDevelopmentDialog(
        context,
        feature: l10n.changePhoneTitle,
      );
      // navState.pop(true);
    } on Object catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.changePhoneError(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePhoneTitle)),
      body: ValueListenableBuilder<bool>(
        valueListenable: SettingsService.paleVioletNotifier,
        builder: (c, pale, _) {
          final theme = Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: pale,
              fillColor: pale ? const Color(0xFFF6F0FF) : null,
            ),
          );
          return Theme(
            data: theme,
            child: AuthSurface(
              icon: Icons.phone_outlined,
              title: l10n.changePhoneTitle,
              subtitle: l10n.changePhoneDescription,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_currentPhone != null) ...[
                    Text(
                      '${l10n.currentPrefix} $_currentPhone',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                  ],
                  ShadInput(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    leading: const Icon(Icons.phone_outlined, size: 18),
                    placeholder: Text(l10n.newPhoneLabel),
                  ),
                  const SizedBox(height: 12),
                  ShadInput(
                    controller: _pwdCtrl,
                    obscureText: true,
                    leading: const Icon(Icons.lock_outline_rounded, size: 18),
                    placeholder: Text(l10n.currentPasswordOptional),
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
                        : Text(l10n.changePhoneButton),
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
