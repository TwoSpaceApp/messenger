import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
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
      // AppwriteService not available, skip loading current email
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
    Navigator.of(context);
    try {
      // AppwriteService not available, skip server update
      if (!mounted) return;
      messenger
          .showSnackBar(SnackBar(content: Text(l10n.emailCannotBeChanged)));
      // navState.pop(true);
    } catch (e) {
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ValueListenableBuilder<bool>(
          valueListenable: SettingsService.paleVioletNotifier,
          builder: (c, pale, _) {
            final theme = Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: pale,
                fillColor: pale ? const Color(0xFFF6F0FF) : null,
              ),
            );
            return Theme(
              data: theme,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.changeEmailDescription),
                  if (_currentEmail != null) ...[
                    const SizedBox(height: 8),
                    Text(l10n.currentPrefix,
                        style: Theme.of(context).textTheme.bodySmall),
                    Text(_currentEmail ?? '',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          InputDecoration(labelText: l10n.newEmailLabel)),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _pwdCtrl,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: l10n.currentPasswordLabel)),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l10n.changeEmailButton),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
