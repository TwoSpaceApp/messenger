import 'dart:async';

import 'package:flutter/material.dart';
import 'package:two_space_app/core/config/ui_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/constants/app_strings.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/core/services/sentry_service.dart';
import 'package:two_space_app/core/utils/user_facing_error.dart';
import 'package:two_space_app/core/widgets/app_logo.dart';
import 'package:two_space_app/core/widgets/language_switcher.dart';
import 'package:two_space_app/features/auth/data/services/aegis_auth_service.dart';
import 'package:two_space_app/features/auth/data/services/login_protection_service.dart';
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
  final LoginProtectionService _loginProtection = LoginProtectionService();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isCovering = true; // start hidden for entrance animation
  final bool _swapBlobs = false;
  Timer? _cooldownTicker;

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
    _cooldownTicker?.cancel();
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  void _startCooldownTicker() {
    if (!_loginProtection.isCoolingDown) {
      _cooldownTicker?.cancel();
      _cooldownTicker = null;
      return;
    }
    _cooldownTicker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _cooldownTicker?.cancel();
        _cooldownTicker = null;
        return;
      }
      if (!_loginProtection.isCoolingDown) {
        setState(() {
          if ((_errorMessage ?? '').isNotEmpty) {
            _errorMessage = null;
          }
        });
        _cooldownTicker?.cancel();
        _cooldownTicker = null;
        return;
      }
      setState(() {});
    });
  }

  void _recordFailedAttempt(AppLocalizations l10n) {
    _loginProtection.recordFailure();
    if (_loginProtection.isCoolingDown) {
      _startCooldownTicker();
      _errorMessage = l10n.loginCooldownMessage(
        _loginProtection.remainingCooldownSeconds,
      );
    }
  }

  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _errorMessage = null);
    if (_loginProtection.isCoolingDown) {
      setState(() {
        _errorMessage = l10n.loginCooldownMessage(
          _loginProtection.remainingCooldownSeconds,
        );
      });
      _startCooldownTicker();
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final identifier = _emailCtl.text.trim();
    final password = _passCtl.text;
    final notifier = ref.read(authProvider.notifier);

    if (_emailLikePattern.hasMatch(identifier)) {
      setState(() {
        _loading = false;
        _errorMessage = l10n.loginUsernameOnlyError;
      });
      return;
    }

    // Close keyboard
    FocusScope.of(context).unfocus();

    try {
      // Standard email + password login
      await notifier.login(identifier, password);
      _loginProtection.recordSuccess();
      // Navigation happens automatically via auth listener
    } on TwoFactorRequiredException {
      await _completeTwoFactorLogin(identifier, password);
    } on TwoFactorInvalidException {
      setState(() => _recordFailedAttempt(l10n));
      await _completeTwoFactorLogin(identifier, password, invalidCode: true);
    } catch (e, stackTrace) {
      SentryService.captureException(
        e,
        stackTrace: stackTrace,
        hint: {'screen': 'login'},
      );
      if (mounted) {
        setState(
          () {
            _recordFailedAttempt(l10n);
            _errorMessage ??= UserFacingError.format(e, l10n);
          },
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _completeTwoFactorLogin(
    String identifier,
    String password, {
    bool invalidCode = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    while (mounted) {
      if (_loginProtection.isCoolingDown) {
        setState(() {
          _errorMessage = l10n.loginCooldownMessage(
            _loginProtection.remainingCooldownSeconds,
          );
        });
        _startCooldownTicker();
        return;
      }

      final credentials = await _promptForTwoFactorCredentials(
        invalidCode: invalidCode,
      );
      if (!mounted || credentials == null) {
        return;
      }

      try {
        await ref
            .read(authProvider.notifier)
            .login(
              identifier,
              password,
              twoFactorCode: credentials.$1?.isEmpty ?? true
                  ? null
                  : credentials.$1,
              recoveryPhrase: credentials.$2?.isEmpty ?? true
                  ? null
                  : credentials.$2,
            );
        return;
      } on TwoFactorInvalidException {
        setState(() => _recordFailedAttempt(l10n));
        if (_loginProtection.isCoolingDown) {
          return;
        }
        invalidCode = true;
        continue;
      } catch (e, stackTrace) {
        SentryService.captureException(
          e,
          stackTrace: stackTrace,
          hint: {'screen': 'login-2fa'},
        );
        if (!mounted) {
          return;
        }
        setState(
          () {
            _recordFailedAttempt(l10n);
            _errorMessage ??= UserFacingError.format(e, l10n);
          },
        );
        return;
      }
    }
  }

  Future<(String?, String?)?> _promptForTwoFactorCredentials({
    bool invalidCode = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final codeController = TextEditingController();
    final recoveryController = TextEditingController();
    try {
      return await showDialog<(String?, String?)>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(l10n.twoFactorLabel),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.twoFactorSubtitle),
                const SizedBox(height: UITokens.space),
                if (invalidCode)
                  Padding(
                    padding: const EdgeInsets.only(bottom: UITokens.space),
                    child: Text(
                      l10n.twoFactorInvalidCodeMessage,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                TextField(
                  controller: codeController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.twoFactorVerificationCodeLabel,
                    hintText: l10n.twoFactorVerificationCodeHint,
                  ),
                ),
                const SizedBox(height: UITokens.space),
                TextField(
                  controller: recoveryController,
                  decoration: InputDecoration(
                    labelText: l10n.twoFactorRecoveryPhraseFieldLabel,
                    hintText: l10n.twoFactorLoginRecoveryHint,
                  ),
                  minLines: 2,
                  maxLines: 4,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  MaterialLocalizations.of(context).cancelButtonLabel,
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(
                  (
                    codeController.text.trim(),
                    recoveryController.text.trim(),
                  ),
                ),
                child: Text(l10n.loginButton),
              ),
            ],
          );
        },
      );
    } finally {
      codeController.dispose();
      recoveryController.dispose();
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
            const SizedBox(height: UITokens.spaceSm),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: UITokens.spaceXLg),
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
            const SizedBox(height: UITokens.spaceXL),

            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: UITokens.spaceXLg),
                padding: const EdgeInsets.all(UITokens.space),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(UITokens.corner),
                  border: Border.all(
                    color: theme.colorScheme.error.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error),
                    const SizedBox(width: UITokens.space),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 20,
                        color: theme.colorScheme.error,
                      ),
                      onPressed: () => setState(() => _errorMessage = null),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
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
                      hintText: l10n.authUsernameHint,
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: theme.colorScheme.primary,
                      ),
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(UITokens.cornerLg),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface.withAlpha(50),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(UITokens.cornerLg),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(UITokens.cornerLg),
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
                  const SizedBox(height: UITokens.spaceMd),
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
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: theme.colorScheme.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(UITokens.cornerLg),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface.withAlpha(50),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(UITokens.cornerLg),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(UITokens.cornerLg),
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

            const SizedBox(height: UITokens.spaceXLg),

            ElevatedButton(
              onPressed:
                  (_loading || _loginProtection.isCoolingDown)
                  ? null
                  : _handleLogin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: UITokens.spaceMd),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UITokens.cornerLg),
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
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.loginButton,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),

            const SizedBox(height: UITokens.spaceXLg),

            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UITokens.spaceMd,
                  ),
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
                    color: theme.dividerColor.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),

            const SizedBox(height: UITokens.spaceXLg),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _socialButton(
                  Icons.g_mobiledata,
                  l10n.continueWithGoogle,
                  () {},
                  isDark,
                ),
                const SizedBox(width: UITokens.spaceMd),
                _socialButton(
                  Icons.apple,
                  l10n.continueWithApple,
                  () {},
                  isDark,
                ),
              ],
            ),

            const SizedBox(height: UITokens.spaceXL),

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
                    if (mounted) context.go(AppStrings.routeRegister);
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
    IconData icon,
    String label,
    VoidCallback onPressed,
    bool isDark,
  ) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(UITokens.corner),
        child: Container(
          padding: const EdgeInsets.all(UITokens.space),
          decoration: BoxDecoration(
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(UITokens.corner),
            color: isDark ? Colors.white10 : Colors.white,
          ),
          child: Icon(
            icon,
            size: UITokens.authSocialIconSize,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
