import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/services/sentry_service.dart';
import 'package:two_space_app/core/widgets/app_logo.dart';
import 'package:two_space_app/core/widgets/language_switcher.dart';
import 'package:two_space_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:two_space_app/features/auth/presentation/widgets/auth_background.dart';
import 'package:two_space_app/features/auth/providers/auth_notifier.dart';

/// Modern LoginScreen using Riverpod for state management
/// All auth logic delegated to AuthNotifier
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static final RegExp _emailLikePattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isCovering = true; // start hidden for entrance animation
  final bool _swapBlobs = false;

  @override
  void initState() {
    super.initState();
    // Reveal animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isCovering = false);
    });
  }

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final identifier = _emailCtl.text.trim();
    final password = _passCtl.text.trim();
    final notifier = ref.read(authProvider.notifier);

    if (_emailLikePattern.hasMatch(identifier)) {
      setState(() {
        _loading = false;
        _errorMessage = 'Use your Aegis username to sign in.';
      });
      return;
    }

    // Close keyboard
    FocusScope.of(context).unfocus();

    try {
      // Standard email + password login
      await notifier.login(identifier, password);
      // Navigation happens automatically via auth listener
    } catch (e, stackTrace) {
      SentryService.captureException(
        e,
        stackTrace: stackTrace,
        hint: {'screen': 'login'},
      );
      if (mounted) {
        setState(
            () => _errorMessage = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return AuthBackground(
      title: l10n.loginTitle,
      isCovering: _isCovering,
      swapBlobs: _swapBlobs,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Переключатель языка — правый верхний угол
            const Align(
              alignment: Alignment.topRight,
              child: LanguageSwitcherButton(),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: AppLogo(),
              ),
            ),

            Text(
              l10n.welcomeBack,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: theme.colorScheme.error,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          size: 20, color: theme.colorScheme.error),
                      onPressed: () => setState(() => _errorMessage = null),
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ],
                ),
              ),

            AutofillGroup(
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailCtl,
                    keyboardType: TextInputType.text,
                    autofillHints: const [AutofillHints.username],
                    textInputAction: TextInputAction.next,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    cursorColor: theme.colorScheme.primary,
                    decoration: InputDecoration(
                      labelText: l10n.emailOrUsernameLabel,
                      hintText: 'username',
                      prefixIcon: Icon(Icons.person_outline,
                          color: theme.colorScheme.primary),
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface.withAlpha(50),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? l10n.validationEnterEmailOrUsername
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passCtl,
                    obscureText: _obscurePassword,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    cursorColor: theme.colorScheme.primary,
                    decoration: InputDecoration(
                      labelText: l10n.passwordLabel,
                      prefixIcon: Icon(Icons.lock_outline,
                          color: theme.colorScheme.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface.withAlpha(50),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? l10n.validationEnterPassword
                        : null,
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ForgotPasswordScreen(),
                  ),
                ),
                child: Text(
                  l10n.forgotPassword,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFBB86FC)
                        : theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _loading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 4,
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      l10n.loginButton,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                    child: Divider(
                        color: theme.dividerColor.withValues(alpha: 0.2))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    l10n.orDivider,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                    child: Divider(
                        color: theme.dividerColor.withValues(alpha: 0.2))),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _socialButton(Icons.g_mobiledata, 'Google', () {}, isDark),
                const SizedBox(width: 16),
                _socialButton(Icons.apple, 'Apple', () {}, isDark),
              ],
            ),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.noAccount,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() => _isCovering = true);
                    if (mounted) context.go('/register');
                  },
                  child: Text(
                    l10n.registerTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _socialButton(
      IconData icon, String label, VoidCallback onPressed, bool isDark) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isDark ? Colors.white10 : Colors.white,
        ),
        child: Icon(
          icon,
          size: 32,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
