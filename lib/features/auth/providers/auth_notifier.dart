import 'dart:async';

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
    final storedSession = await _authService.getStoredSessionSnapshot();
    if (storedSession != null) {
      unawaited(_restoreStoredSessionInBackground());
      return AuthState.authenticated(
        userId: storedSession.userId,
        token: storedSession.token,
      );
    }
    return _loadAuthState();
  }

  Future<void> _restoreStoredSessionInBackground() async {
    try {
      final restored = await _authService.restoreSessionFromToken();
      if (restored) {
        state = AsyncValue.data(await _resolveAuthenticatedState());
        return;
      }

      final storedSession = await _authService.getStoredSessionSnapshot();
      if (storedSession == null) {
        state = const AsyncValue.data(AuthState.unauthenticated());
      }
    } on Object catch (e, stackTrace) {
      final storedSession = await _authService.getStoredSessionSnapshot();
      if (storedSession == null) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  Future<AuthState> _resolveAuthenticatedState() async {
    final token = await _authService.getAuthToken();
    final userId = await _authService.getCurrentUserId();
    if (token != null && token.isNotEmpty && userId != null && userId.isNotEmpty) {
      return AuthState.authenticated(userId: userId, token: token);
    }
    return const AuthState.unauthenticated();
  }

  Future<AuthState> _loadAuthState() async {
    try {
      final restored = await _authService.restoreSessionFromToken();
      if (!restored) {
        final storedSession = await _authService.getStoredSessionSnapshot();
        if (storedSession != null) {
          return AuthState.authenticated(
            userId: storedSession.userId,
            token: storedSession.token,
          );
        }
        return const AuthState.unauthenticated();
      }

      return _resolveAuthenticatedState();
    } on Object catch (e) {
      final storedSession = await _authService.getStoredSessionSnapshot();
      if (storedSession != null) {
        return AuthState.authenticated(
          userId: storedSession.userId,
          token: storedSession.token,
        );
      }
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
    try {
      await _authService.registerUser(
        username,
        email,
        password,
        displayName: displayName,
        avatarBytes: avatarBytes,
      );
      final nextState = await _loadAuthState();
      if (!nextState.isAuthenticated) {
        throw Exception('Регистрация завершена, но вход не выполнен');
      }
      state = AsyncValue.data(nextState);
    } on Object catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
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
