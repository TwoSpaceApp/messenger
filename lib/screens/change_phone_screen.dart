import 'package:flutter/material.dart';
import 'package:two_space_app/l10n/app_localizations.dart';
import 'package:two_space_app/services/settings_service.dart';

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
      // AppwriteService not available, skip loading current phone
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
    Navigator.of(context);
    try {
      // AppwriteService not available, skip server update
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.phoneCannotBeChanged)));
      // navState.pop(true);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.changePhoneError(e.toString()))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePhoneTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder<bool>(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.changePhoneDescription),
                  if (_currentPhone != null) ...[
                    const SizedBox(height: 8),
                    Text(l10n.currentPrefix, style: Theme.of(context).textTheme.bodySmall),
                    Text(_currentPhone ?? '', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 12),
                  TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: InputDecoration(labelText: l10n.newPhoneLabel)),
                  const SizedBox(height: 12),
                  TextField(controller: _pwdCtrl, obscureText: true, decoration: InputDecoration(labelText: l10n.currentPasswordOptional)),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l10n.changePhoneButton),
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
