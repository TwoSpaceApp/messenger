import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/utils/user_facing_error.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';
import 'package:two_space_app/core/widgets/section_card.dart';
import 'package:two_space_app/core/widgets/section_page_header.dart';
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
  bool _submitting = false;
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
    // Fire-and-forget: TFA setup load result handled within the method
    // ignore: discarded_futures
    _fetchTfaSetup();
  }

  Future<void> _fetchTfaSetup({bool showLoader = true}) async {
    if (!mounted) {
      return;
    }
    setState(() {
      if (showLoader) {
        _loading = true;
      }
      _error = null;
    });
    final l10n = AppLocalizations.of(context)!;
    try {
      final authService = AuthService();
      final result = await authService.requestTotpSetup();
      if (!mounted) {
        return;
      }
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
        _error = UserFacingError.format(e, l10n);
      });
    }
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
    setState(() => _submitting = true);
    try {
      final authService = AuthService();
      await authService.verifyTotpSetup(_enableCodeController.text.trim());
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.twoFactorEnabledMessage)),
      );
      context.pop();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.twoFactorEnableFailed(
              UserFacingError.format(e, l10n),
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
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

    final confirmed =
        await showDialog<bool>(
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

    setState(() => _submitting = true);
    try {
      final authService = AuthService();
      await authService.verifyTotpSetup(
        code,
        disable: true,
        recoveryPhrase: recoveryPhrase.isEmpty ? null : recoveryPhrase,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isDisabling = false;
        _disableCodeController.clear();
        _disableRecoveryController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.twoFactorDisabledMessage)),
      );
      await _fetchTfaSetup(showLoader: false);
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.twoFactorDisableFailed(
              UserFacingError.format(e, l10n),
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? AppErrorState(
            title: l10n.twoFactorLabel,
            message: _error!,
            actionLabel: l10n.retry,
            onAction: _fetchTfaSetup,
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(UITokens.spaceMd),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: UITokens.sectionContentMaxWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.embedded) ...[
                      SectionPageHeader(
                        title: l10n.twoFactorLabel,
                        leading: IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        actions: [
                          IconButton(
                            onPressed: _submitting ? null : _fetchTfaSetup,
                            icon: const Icon(Icons.refresh_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: UITokens.spaceMd),
                    ],
                    if (!widget.embedded) ...[
                      Text(
                        l10n.twoFactorSetupTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: UITokens.spaceSm),
                      Text(l10n.twoFactorSetupDescription),
                      const SizedBox(height: UITokens.spaceLg),
                    ],
                    SectionCard(
                      padding: const EdgeInsets.all(UITokens.spaceLg),
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
                            const SizedBox(height: UITokens.spaceMd),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(l10n.twoFactorSecretTitle),
                                ),
                                TextButton.icon(
                                  onPressed: () => _copyToClipboard(_secret!),
                                  icon: const Icon(
                                    Icons.copy_all_rounded,
                                    size: 16,
                                  ),
                                  label: Text(l10n.copyAction),
                                ),
                              ],
                            ),
                            const SizedBox(height: UITokens.spaceSm),
                            SelectableText(
                              _secret!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          if (_recoveryPhrase != null) ...[
                            const SizedBox(height: UITokens.spaceMd),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.twoFactorRecoveryPhraseTitle,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () =>
                                      _copyToClipboard(_recoveryPhrase!),
                                  icon: const Icon(
                                    Icons.copy_all_rounded,
                                    size: 16,
                                  ),
                                  label: Text(l10n.copyAction),
                                ),
                              ],
                            ),
                            const SizedBox(height: UITokens.spaceSm),
                            SelectableText(
                              _recoveryPhrase!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: UITokens.spaceMd),
                    SectionCard(
                      padding: const EdgeInsets.all(UITokens.spaceLg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _enableCodeController,
                            enabled: !_submitting,
                            decoration: InputDecoration(
                              labelText: l10n.twoFactorVerificationCodeLabel,
                              hintText: l10n.twoFactorVerificationCodeHint,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: UITokens.spaceXLg),
                          ElevatedButton(
                            onPressed: _submitting ? null : _verifyTfa,
                            child: Text(
                              _submitting
                                  ? l10n.loading
                                  : l10n.twoFactorVerifyEnableAction,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: UITokens.spaceXLg),
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
                      const SizedBox(height: UITokens.space),
                      SectionCard(
                        padding: const EdgeInsets.all(UITokens.spaceLg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.twoFactorDisableSectionDescription,
                            ),
                            const SizedBox(height: UITokens.space),
                            TextField(
                              controller: _disableCodeController,
                              enabled: !_submitting,
                              decoration: InputDecoration(
                                labelText: l10n.twoFactorVerificationCodeLabel,
                                hintText: l10n.twoFactorDisableCodeHint,
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: UITokens.space),
                            TextField(
                              controller: _disableRecoveryController,
                              enabled: !_submitting,
                              decoration: InputDecoration(
                                labelText:
                                    l10n.twoFactorRecoveryPhraseFieldLabel,
                                hintText: l10n.twoFactorRecoveryPhraseFieldHint,
                              ),
                              minLines: 2,
                              maxLines: 4,
                            ),
                            const SizedBox(height: UITokens.spaceMd),
                            FilledButton.tonal(
                              onPressed: _submitting ? null : _disableTfa,
                              child: Text(
                                _submitting
                                    ? l10n.loading
                                    : l10n.twoFactorDisableAction,
                              ),
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
      appBar: AppBar(
        title: Text(l10n.twoFactorLabel),
        actions: [
          IconButton(
            onPressed: (_loading || _submitting) ? null : _fetchTfaSetup,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: content,
    );
  }
}
