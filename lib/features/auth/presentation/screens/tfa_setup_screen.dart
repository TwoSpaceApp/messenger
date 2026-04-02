import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/widgets/app_state_views.dart';
import 'package:two_space_app/features/auth/data/services/auth_service.dart';
import 'package:two_space_app/features/auth/presentation/widgets/auth_surface.dart';

class TfaSetupScreen extends StatefulWidget {
  const TfaSetupScreen({super.key});

  @override
  State<TfaSetupScreen> createState() => _TfaSetupScreenState();
}

class _TfaSetupScreenState extends State<TfaSetupScreen> {
  String? _secret;
  String? _otpAuthUri;
  String? _error;
  bool _loading = true;
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTfaSetup();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _fetchTfaSetup() async {
    setState(() => _loading = true);
    try {
      final authService = AuthService();
      final result = await authService.requestTotpSetup();
      setState(() {
        _secret = result['secret'];
        _otpAuthUri = result['otpauth_uri'];
        _error = null;
        _loading = false;
      });
    } on Object catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _verifyTfa() async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the code from your authenticator app'),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final authService = AuthService();
      await authService.verifyTotpSetup(_codeController.text);
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('TFA enabled successfully!')),
      );
      Navigator.pop(context);
    } on Object catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify TFA: $e')),
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
          : AuthSurface(
              icon: Icons.qr_code_rounded,
              title: l10n.twoFactorLabel,
              subtitle:
                  'Scan QR in authenticator app and confirm with one-time code.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_otpAuthUri != null)
                    Center(
                      child: RepaintBoundary(
                        child: ShadCard(
                          child: QrImageView(
                            data: _otpAuthUri!,
                            size: 180,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (_secret != null)
                    ShadCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Manual key:'),
                          const SizedBox(height: 6),
                          SelectableText(
                            _secret!,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          ShadButton.link(
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: _secret!),
                              );
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Secret copied')),
                              );
                            },
                            child: const Text('Copy key'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  ShadInput(
                    controller: _codeController,
                    placeholder: const Text(
                      'Enter code from authenticator app',
                    ),
                    leading: const Icon(Icons.verified_user_outlined, size: 18),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  ShadButton(
                    onPressed: _verifyTfa,
                    width: double.infinity,
                    child: const Text('Verify & Enable'),
                  ),
                ],
              ),
            ),
    );
  }
}
