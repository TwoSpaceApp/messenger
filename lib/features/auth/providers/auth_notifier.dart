import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:two_space_app/features/auth/data/services/auth_service.dart';

part 'auth_notifier.freezed.dart';
part 'auth_notifier.g.dart';

@freezed
class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState.authenticated({
    required String userId,
    required String token,
  }) = _Authenticated;

  const factory AuthState.unauthenticated() = _Unauthenticated;

  const factory AuthState.error({required String message}) = _Error;

  bool get isAuthenticated => maybeMap(
        authenticated: (_) => true,
        orElse: () => false,
      );

  String? get userId => maybeMap(
        authenticated: (s) => s.userId,
        orElse: () => null,
      );

  String? get token => maybeMap(
        authenticated: (s) => s.token,
        orElse: () => null,
      );
}

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  return AuthService();
}

@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
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
      final token = await _authService.getMatrixTokenForUser();
      if (token != null && token.isNotEmpty) {
        final userId = await _authService.getCurrentUserId();
        if (userId != null && userId.isNotEmpty) {
          return AuthState.authenticated(userId: userId, token: token);
        }
      }
      return const AuthState.unauthenticated();
    } catch (e) {
      return AuthState.error(message: e.toString());
    }
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.login(username, password);
      return _loadAuthState();
    });
  }

  Future<void> register(String name, String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authService.registerUser(name, email, password);
      await _authService.login(email, password);
      return _loadAuthState();
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _authService.logout();
      state = const AsyncValue.data(AuthState.unauthenticated());
    } catch (e) {
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
    } catch (e) {
      return false;
    }
  }
}

@riverpod
Future<bool> isAuthenticated(Ref ref) async {
  // Since we are using riverpod_generator, the provider is generated.
  // We need to use `authProvider` manually here.
  final authState = await ref.watch(authProvider.future);
  return authState.isAuthenticated;
}

@riverpod
Future<String?> currentUserId(Ref ref) async {
  final authState = await ref.watch(authProvider.future);
  return authState.userId;
}
