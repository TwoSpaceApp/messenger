import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/features/auth/data/services/auth_service.dart';

class TfaSetupScreen extends StatefulWidget {
  const TfaSetupScreen({super.key});

  @override
  State<TfaSetupScreen> createState() => _TfaSetupScreenState();
}

class _TfaSetupScreenState extends State<TfaSetupScreen> {
  String? _secret;
  String? _otpAuthUri;
  String? _recoveryPhrase;
  String? _error;
  bool _loading = true;
  bool _isDisabling = false;
  final _enableCodeController = TextEditingController();
  final _disableCodeController = TextEditingController();
  final _disableRecoveryController = TextEditingController();

  @override
  void dispose() {
    _enableCodeController.dispose();
    _disableCodeController.dispose();
    _disableRecoveryController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchTfaSetup();
  }

  Future<void> _fetchTfaSetup() async {
    setState(() => _loading = true);
    try {
      final authService = AuthService();
      final result = await authService.requestTotpSetup();
      setState(() {
        _secret = result['secret'];
        _otpAuthUri = result['otpauth_uri'];
        _recoveryPhrase = result['recovery_phrase'];
        _error = null;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _verifyTfa() async {
    final l10n = AppLocalizations.of(context)!;
    if (_enableCodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.twoFactorCodeRequiredMessage)),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final authService = AuthService();
      await authService.verifyTotpSetup(_enableCodeController.text.trim());
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.twoFactorEnabledMessage)),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.twoFactorEnableFailed(e.toString())),
        ),
      );
    }
  }

  Future<void> _disableTfa() async {
    final l10n = AppLocalizations.of(context)!;
    final code = _disableCodeController.text.trim();
    final recoveryPhrase = _disableRecoveryController.text.trim();
    if (code.isEmpty && recoveryPhrase.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.twoFactorDisableCredentialsRequired)),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final authService = AuthService();
      await authService.verifyTotpSetup(
        code,
        disable: true,
        recoveryPhrase: recoveryPhrase.isEmpty ? null : recoveryPhrase,
      );
      setState(() {
        _loading = false;
        _isDisabling = false;
        _disableCodeController.clear();
        _disableRecoveryController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.twoFactorDisabledMessage)),
      );
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.twoFactorDisableFailed(e.toString())),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.twoFactorLabel)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? AppEmptyState(
                  title: l10n.twoFactorLabel,
                  message: _error!,
                  icon: Icons.security,
                )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.twoFactorSetupTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.twoFactorSetupDescription),
                  const SizedBox(height: 20),
                  if (_otpAuthUri != null)
                    Center(
                      child: QrImageView(
                        data: _otpAuthUri!,
                        size: 200,
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (_secret != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.twoFactorSecretTitle),
                            const SizedBox(height: 8),
                            SelectableText(
                              _secret!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_recoveryPhrase != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.twoFactorRecoveryPhraseTitle),
                            const SizedBox(height: 8),
                            SelectableText(
                              _recoveryPhrase!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextField(
                    controller: _enableCodeController,
                    decoration: InputDecoration(
                      labelText: l10n.twoFactorVerificationCodeLabel,
                      hintText: l10n.twoFactorVerificationCodeHint,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _verifyTfa,
                    child: Text(l10n.twoFactorVerifyEnableAction),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _isDisabling = !_isDisabling);
                    },
                    icon: Icon(
                      _isDisabling ? Icons.expand_less : Icons.expand_more,
                    ),
                    label: Text(l10n.twoFactorDisableSectionTitle),
                  ),
                  if (_isDisabling) ...[
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.twoFactorDisableSectionDescription,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _disableCodeController,
                              decoration: InputDecoration(
                                labelText: l10n.twoFactorVerificationCodeLabel,
                                hintText: l10n.twoFactorDisableCodeHint,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _disableRecoveryController,
                              decoration: InputDecoration(
                                labelText: l10n.twoFactorRecoveryPhraseFieldLabel,
                                hintText: l10n.twoFactorRecoveryPhraseFieldHint,
                              ),
                              minLines: 2,
                              maxLines: 4,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.tonal(
                              onPressed: _disableTfa,
                              child: Text(l10n.twoFactorDisableAction),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
