import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/services/navigation_service.dart';
import 'package:two_space_app/core/widgets/feature_in_development_dialog.dart';
import 'package:two_space_app/core/widgets/inline_notice_card.dart';
import 'package:two_space_app/core/widgets/screen_background.dart';

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
        ScaffoldMessenger.of(
          navCtx,
        ).showSnackBar(SnackBar(content: Text(l10n.validationEnterEmail)));
      return;
    }
    setState(() => _loading = true);
    try {
      // Password reset flow is not connected to the backend yet.
      if (!mounted) return;
      await showFeatureInDevelopmentDialog(
        context,
        feature: l10n.forgotPasswordTitle,
      );
      // appNavigatorKey.currentState?.pop();
    } catch (e) {
      if (!mounted) return;
      final navCtx = appNavigatorKey.currentContext;
      if (navCtx != null)
        ScaffoldMessenger.of(navCtx).showSnackBar(
          SnackBar(content: Text(l10n.errorWithDetail(e.toString()))),
        );
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(l10n.forgotPasswordTitle)),
      body: ScreenBackground(
        child: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(UITokens.spaceMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: UITokens.spaceSm),
                    Text(
                      l10n.forgotPasswordDescription,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: UITokens.space),
                    InlineNoticeCard(
                      icon: Icons.construction_rounded,
                      badge: l10n.featureInDevelopmentLabel,
                      title: l10n.forgotPasswordTitle,
                      message: l10n.featureInDevelopmentMessage(
                        l10n.forgotPasswordTitle,
                      ),
                    ),
                    const SizedBox(height: UITokens.space),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: l10n.emailLabel),
                    ),
                    const SizedBox(height: UITokens.spaceMd),
                    ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const CircularProgressIndicator()
                          : Text(l10n.sendResetButton),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
