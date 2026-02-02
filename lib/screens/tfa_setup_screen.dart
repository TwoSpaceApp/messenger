import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/auth_service.dart';

class TfaSetupScreen extends StatefulWidget {
  const TfaSetupScreen({super.key});

  @override
  State<TfaSetupScreen> createState() => _TfaSetupScreenState();
}

class _TfaSetupScreenState extends State<TfaSetupScreen> {
  String? _secret;
  String? _otpAuthUri;
  bool _loading = true;
  final _codeController = TextEditingController();

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
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get TFA setup: $e')),
      );
    }
  }

  Future<void> _verifyTfa() async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the code from your authenticator app')),
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
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify TFA: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up Two-Factor Auth')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_otpAuthUri != null)
                    Center(
                      child: QrImageView(
                        data: _otpAuthUri!,
                        version: QrVersions.auto,
                        size: 200.0,
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (_secret != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text('Or enter this secret key into your authenticator app:'),
                            const SizedBox(height: 8),
                            SelectableText(_secret!, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'Verification Code',
                      hintText: 'Enter code from authenticator app',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _verifyTfa,
                    child: const Text('Verify & Enable'),
                  ),
                ],
              ),
            ),
    );
  }
}
