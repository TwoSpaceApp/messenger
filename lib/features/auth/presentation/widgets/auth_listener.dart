import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:two_space_app/core/l10n/app_localizations.dart';
import 'package:two_space_app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:two_space_app/features/auth/providers/auth_notifier.dart';
import 'package:two_space_app/features/chat/data/services/chat_matrix_service.dart';

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
    AsyncValue<AuthState>? previous,
    AsyncValue<AuthState> next,
  ) {
    next.whenOrNull(
      data: (state) {
        // Only navigate if state actually changed
        final previousState = previous?.value;
        if (previousState?.isAuthenticated == state.isAuthenticated) {
          return; // No change, skip navigation
        }

        if (state.isAuthenticated) {
          // User just logged in - show welcome screen first
          _navigateToWelcome(state.userId);
        } else if (previousState?.isAuthenticated ?? false) {
          // User just logged out
          _navigateToLogin();
        }
      },
      error: (error, stackTrace) {
        // Show error message
        _showErrorSnackBar(error.toString());
      },
    );
  }

  Future<void> _navigateToWelcome(String? userId) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    // Get user info for welcome screen
    var userName = l10n.userDefault;
    String? avatarUrl;

    if (userId != null) {
      try {
        final matrixService = ChatMatrixService();
        final userInfo = await matrixService.getUserInfo(userId);
        userName = userInfo['displayName'] as String? ??
            userId.split(':').first.replaceAll('@', '');
        avatarUrl = userInfo['avatarUrl'] as String?;
      } catch (_) {
        userName = userId.split(':').first.replaceAll('@', '');
      }
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WelcomeScreen(
          name: userName,
          avatarUrl: avatarUrl,
        ),
      ),
    );
  }

  void _navigateToLogin() {
    if (!mounted) return;

    // Get current route
    final currentRoute = ModalRoute.of(context)?.settings.name;

    // Only navigate if not already on login
    if (currentRoute != '/login' && currentRoute != null) {
      context.go('/login');
    }
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
