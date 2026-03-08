import 'package:flutter/material.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/services/navigation_service.dart';
// ui_tokens not needed here

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      final navCtx = appNavigatorKey.currentContext;
      if (navCtx != null)
        ScaffoldMessenger.of(navCtx)
            .showSnackBar(SnackBar(content: Text(l10n.validationEnterEmail)));
      return;
    }
    setState(() => _loading = true);
    try {
      // AppwriteService not available
      if (!mounted) return;
      final navCtx = appNavigatorKey.currentContext;
      if (navCtx != null)
        ScaffoldMessenger.of(navCtx).showSnackBar(
            SnackBar(content: Text(l10n.forgotPasswordUnavailable)));
      // appNavigatorKey.currentState?.pop();
    } catch (e) {
      if (!mounted) return;
      final navCtx = appNavigatorKey.currentContext;
      if (navCtx != null)
        ScaffoldMessenger.of(navCtx).showSnackBar(
            SnackBar(content: Text(l10n.errorWithDetail(e.toString()))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.forgotPasswordTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text(l10n.forgotPasswordDescription,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const CircularProgressIndicator()
                    : Text(l10n.sendResetButton)),
          ],
        ),
      ),
    );
  }
}
