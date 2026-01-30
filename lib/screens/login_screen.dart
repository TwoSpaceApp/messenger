import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../providers/auth_notifier.dart';
import '../utils/responsive.dart';
import 'otp_screen.dart';
import 'sso_webview_screen.dart';

/// Simplified LoginScreen using Riverpod for state management
/// All auth logic delegated to AuthNotifier
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  Future<void> _login() => _handleLogin();

  Future<void> _handleLogin() async {
    setState(() => _loading = true);

    final identifier = _emailCtl.text.trim();
    final password = _passCtl.text.trim();
    final notifier = ref.read(authNotifierProvider.notifier);

    try {
      // Standard email + password login
      await notifier.login(identifier, password);
      // Navigation happens automatically via auth listener
    } catch (e) {
      if (mounted) {
        _showError('Ошибка входа: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handlePhoneLogin(String phone) async {
    if (!mounted) return;
    final code = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => OtpScreen(phone: phone)),
    );
    if (code == null || code.isEmpty) return;
    _showError('Вход по телефону временно недоступен');
  }

  Future<void> _handleMagicLinkLogin(String email) async {
    if (!mounted) return;
    final code = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => OtpScreen(phone: email)),
    );
    if (code == null || code.isEmpty) return;
    _showError('Вход по коду временно недоступен');
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 500;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailCtl,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Введите email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Login'),
              ),
              const SizedBox(height: 12),
              _ssoButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ssoButtons() {
    return const SizedBox.shrink();
  }

  Widget _buildAppIcon() {
    return Container(
      padding: EdgeInsets.all(20 * Responsive.scaleWidth(context)),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
      child: Icon(
        Icons.chat,
        size: 48 * Responsive.scaleWidth(context),
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
