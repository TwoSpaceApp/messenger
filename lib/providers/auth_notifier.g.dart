// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for AuthService singleton

@ProviderFor(authService)
const authServiceProvider = AuthServiceProvider._();

/// Provider for AuthService singleton

final class AuthServiceProvider
    extends $FunctionalProvider<AuthService, AuthService, AuthService>
    with $Provider<AuthService> {
  /// Provider for AuthService singleton
  const AuthServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authServiceHash();

  @$internal
  @override
  $ProviderElement<AuthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthService create(Ref ref) {
    return authService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthService>(value),
    );
  }
}

String _$authServiceHash() => r'1a086f396b6916ee8c5a9a14df3ece637f134805';

/// Main authentication notifier managing auth state
///
/// Usage:
/// ```dart
/// // Watch auth state
/// final authState = ref.watch(authNotifierProvider);
///
/// // Perform login
/// await ref.read(authNotifierProvider.notifier).login(username, password);
///
/// // Logout
/// await ref.read(authNotifierProvider.notifier).logout();
/// ```

@ProviderFor(AuthNotifier)
const authProvider = AuthNotifierProvider._();

/// Main authentication notifier managing auth state
///
/// Usage:
/// ```dart
/// // Watch auth state
/// final authState = ref.watch(authNotifierProvider);
///
/// // Perform login
/// await ref.read(authNotifierProvider.notifier).login(username, password);
///
/// // Logout
/// await ref.read(authNotifierProvider.notifier).logout();
/// ```
final class AuthNotifierProvider
    extends $AsyncNotifierProvider<AuthNotifier, AuthState> {
  /// Main authentication notifier managing auth state
  ///
  /// Usage:
  /// ```dart
  /// // Watch auth state
  /// final authState = ref.watch(authNotifierProvider);
  ///
  /// // Perform login
  /// await ref.read(authNotifierProvider.notifier).login(username, password);
  ///
  /// // Logout
  /// await ref.read(authNotifierProvider.notifier).logout();
  /// ```
  const AuthNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authNotifierHash();

  @$internal
  @override
  AuthNotifier create() => AuthNotifier();
}

String _$authNotifierHash() => r'dd2b74be48d77bc8a69f649b173e2fe7b94baf1a';

/// Main authentication notifier managing auth state
///
/// Usage:
/// ```dart
/// // Watch auth state
/// final authState = ref.watch(authNotifierProvider);
///
/// // Perform login
/// await ref.read(authNotifierProvider.notifier).login(username, password);
///
/// // Logout
/// await ref.read(authNotifierProvider.notifier).logout();
/// ```

abstract class _$AuthNotifier extends $AsyncNotifier<AuthState> {
  FutureOr<AuthState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<AuthState>, AuthState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<AuthState>, AuthState>,
        AsyncValue<AuthState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Convenience provider for checking if user is authenticated

@ProviderFor(isAuthenticated)
const isAuthenticatedProvider = IsAuthenticatedProvider._();

/// Convenience provider for checking if user is authenticated

final class IsAuthenticatedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Convenience provider for checking if user is authenticated
  const IsAuthenticatedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isAuthenticatedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isAuthenticatedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return isAuthenticated(ref);
  }
}

String _$isAuthenticatedHash() => r'c4ebbdbf555f57b44766e435523e030c1080e5a2';

/// Convenience provider for getting current user ID

@ProviderFor(currentUserId)
const currentUserIdProvider = CurrentUserIdProvider._();

/// Convenience provider for getting current user ID

final class CurrentUserIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Convenience provider for getting current user ID
  const CurrentUserIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentUserIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentUserIdHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return currentUserId(ref);
  }
}

String _$currentUserIdHash() => r'a3d5220af1599b59ba610bdc763274684f9db2cc';
