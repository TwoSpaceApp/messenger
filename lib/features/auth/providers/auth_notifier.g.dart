// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authService)
const authServiceProvider = AuthServiceProvider._();

final class AuthServiceProvider
    extends $FunctionalProvider<AuthService, AuthService, AuthService>
    with $Provider<AuthService> {
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

@ProviderFor(AuthNotifier)
const authProvider = AuthNotifierProvider._();

final class AuthNotifierProvider
    extends $AsyncNotifierProvider<AuthNotifier, AuthState> {
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

String _$authNotifierHash() => r'234447d251b1a440e41b7bdf8bdfb74344f46481';

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

@ProviderFor(isAuthenticated)
const isAuthenticatedProvider = IsAuthenticatedProvider._();

final class IsAuthenticatedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
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

String _$isAuthenticatedHash() => r'97f64fde56d0f39c3d9a4a98f1dc408267324c72';

@ProviderFor(currentUserId)
const currentUserIdProvider = CurrentUserIdProvider._();

final class CurrentUserIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
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

String _$currentUserIdHash() => r'ea209d75e499fdb51f7130f745101f30569769f8';
