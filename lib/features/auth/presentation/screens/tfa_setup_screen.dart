import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/section_page_header.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/core/widgets/section_card.dart';
import 'package:two_space_app/features/auth/data/services/auth_service.dart';

class TfaSetupScreen extends StatefulWidget {
  const TfaSetupScreen({super.key, this.embedded = false});

  final bool embedded;

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
    final l10n = AppLocalizations.of(context)!;
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
        _error = _cleanError(e, fallback: l10n.errorGeneric);
      });
    }
  }

  String _cleanError(Object error, {required String fallback}) {
    final text = error.toString().replaceFirst(RegExp('^Exception: '), '').trim();
    if (text.isEmpty || text == 'Exception') {
      return fallback;
    }
    return text;
  }

  Future<void> _copyToClipboard(String value) async {
    if (value.trim().isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.textCopied)),
    );
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
          content: Text(l10n.twoFactorEnableFailed(_cleanError(e, fallback: l10n.errorGeneric))),
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

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.twoFactorDisableSectionTitle),
            content: Text(l10n.twoFactorDisableConfirmContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(l10n.confirm),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) {
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
          content: Text(l10n.twoFactorDisableFailed(_cleanError(e, fallback: l10n.errorGeneric))),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final body = _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? AppEmptyState(
                  title: l10n.twoFactorLabel,
                  message: _error!,
                  icon: Icons.security,
                )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.embedded) ...[
                        SectionPageHeader(
                          title: l10n.twoFactorLabel,
                          subtitle: l10n.twoFactorSetupDescription,
                          leading: IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        l10n.twoFactorSetupTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.twoFactorSetupDescription),
                      const SizedBox(height: 20),
                      SectionCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_otpAuthUri != null)
                              Center(
                                child: QrImageView(
                                  data: _otpAuthUri!,
                                  size: 208,
                                ),
                              ),
                            if (_secret != null) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: Text(l10n.twoFactorSecretTitle)),
                                  TextButton.icon(
                                    onPressed: () => _copyToClipboard(_secret!),
                                    icon: const Icon(Icons.copy_all_rounded, size: 16),
                                    label: Text(l10n.copyAction),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                _secret!,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                            if (_recoveryPhrase != null) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(child: Text(l10n.twoFactorRecoveryPhraseTitle)),
                                  TextButton.icon(
                                    onPressed: () => _copyToClipboard(_recoveryPhrase!),
                                    icon: const Icon(Icons.copy_all_rounded, size: 16),
                                    label: Text(l10n.copyAction),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                _recoveryPhrase!,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SectionCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                          ],
                        ),
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
                        SectionCard(
                          padding: const EdgeInsets.all(20),
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
                      ],
                    ],
                  ),
                ),
              ),
            );

    final content = ScreenBackground(child: body);

    if (widget.embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.twoFactorLabel)),
      body: content,
    );
  }
}
