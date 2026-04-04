import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_space_app/features/auth/data/services/auth_service.dart';
import 'package:two_space_app/features/settings/presentation/screens/dev_menu_screen.dart';

enum AuthStatus { authenticated, unauthenticated, error }

class AuthState {
  const AuthState._({
    required this.status,
    this.userId,
    this.token,
    this.message,
  });

  const AuthState.authenticated({
    required String userId,
    required String token,
  }) : this._(
         status: AuthStatus.authenticated,
         userId: userId,
         token: token,
       );

  const AuthState.unauthenticated()
    : this._(status: AuthStatus.unauthenticated);

  const AuthState.error({required String message})
    : this._(status: AuthStatus.error, message: message);

  final AuthStatus status;
  final String? userId;
  final String? token;
  final String? message;

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthNotifier extends AsyncNotifier<AuthState> {
  AuthService? _authServiceInstance;

  AuthService get _authService {
    _authServiceInstance ??= ref.read(authServiceProvider);
    return _authServiceInstance!;
  }

  @override
  Future<AuthState> build() async {
    return _loadAuthState();
  }

  Future<AuthState> _loadAuthState() async {
    try {
      final restored = await _authService.restoreSessionFromToken();
      if (!restored) {
        return const AuthState.unauthenticated();
      }

      final token = await _authService.getAuthToken();
      if (token != null && token.isNotEmpty) {
        final userId = await _authService.getCurrentUserId();
        if (userId != null && userId.isNotEmpty) {
          return AuthState.authenticated(userId: userId, token: token);
        }
      }
      return const AuthState.unauthenticated();
    } on Object catch (e) {
      if (FeatureFlags.ignoreServerOffline.value) {
        final previousState = state.asData?.value;
        if (previousState?.isAuthenticated ?? false) {
          return previousState!;
        }
      }
      return AuthState.error(message: e.toString());
    }
  }

  Future<void> login(
    String username,
    String password, {
    String? twoFactorCode,
    String? recoveryPhrase,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authService.login(
        username,
        password,
        twoFactorCode: twoFactorCode,
        recoveryPhrase: recoveryPhrase,
      );
      state = AsyncValue.data(await _loadAuthState());
    } on Object catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<void> register(
    String username,
    String email,
    String password, {
    String? displayName,
    Uint8List? avatarBytes,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.registerUser(
        username,
        email,
        password,
        displayName: displayName,
        avatarBytes: avatarBytes,
      );
      return _loadAuthState();
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _authService.logout();
      state = const AsyncValue.data(AuthState.unauthenticated());
    } on Object catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> resetPassword(String email) async {
    // This is a mock implementation - replace with actual service call
    try {
      // In a real app, this would call:
      // await _authService.requestPasswordReset(email);
      print('Password reset requested for: $email');
    } on Object catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_loadAuthState);
  }

  Future<bool> validateSession() async {
    try {
      final currentState = await future;
      return currentState.isAuthenticated;
    } on Object catch (_) {
      return false;
    }
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final authState = await ref.watch(authProvider.future);
  return authState.isAuthenticated;
});

final currentUserIdProvider = FutureProvider<String?>((ref) async {
  final authState = await ref.watch(authProvider.future);
  return authState.userId;
});
