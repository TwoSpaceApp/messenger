import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/features/auth/providers/auth_notifier.dart';

/// Listens to authentication state changes and handles automatic navigation
///
/// Wrap your app with this widget to enable automatic routing:
/// - When user logs in → show welcome screen, then navigate to home
/// - When user logs out → navigate to login
/// - On auth errors → show error message
///
/// Usage in main.dart:
/// ```dart
/// MaterialApp(
///   home: AuthListener(
///     child: AuthGate(),
///   ),
/// )
/// ```
class AuthListener extends ConsumerStatefulWidget {
  const AuthListener({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<AuthListener> createState() => _AuthListenerState();
}

class _AuthListenerState extends ConsumerState<AuthListener> {
  void _handleAuthStateChange(
    AsyncValue<AuthState>? _,
    AsyncValue<AuthState> next,
  ) {
    next.whenOrNull(
      error: (error, stackTrace) {
        // Show error message
        _showErrorSnackBar(error.toString());
      },
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.authorizationError(message)),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: l10n.close,
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes within build method
    ref.listen<AsyncValue<AuthState>>(
      authProvider,
      _handleAuthStateChange,
    );

    return widget.child;
  }
}
