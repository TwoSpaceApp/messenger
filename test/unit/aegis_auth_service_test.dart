// ignore_for_file: use_setters_to_change_properties, discarded_futures, document_ignores

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:two_space_app/core/network/aegis/aegis_client.dart';
import 'package:two_space_app/core/network/aegis/exceptions.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/utils/secure_store.dart';
import 'package:two_space_app/features/auth/data/services/aegis_auth_service.dart';

class FakeAegisClient extends AegisClient {
  FakeAegisClient() : super.withoutApiCredentials();

  bool _connected = false;
  bool _authenticated = false;
  String? _sessionToken;
  String? _username;
  int? _userId;

  final _disconnectsController = StreamController<void>.broadcast();
  final _sessionTerminatedController =
      StreamController<SessionTerminatedEventPayload>.broadcast();

  bool loginShouldSucceed = true;
  bool loginWithTokenShouldSucceed = true;
  String loginError = 'Login failed';
  String tokenError = 'Invalid token';
  bool throwTwoFactorRequired = false;
  bool throwTwoFactorInvalid = false;
  bool throwEmailNotVerified = false;
  bool simulateNullTokenAfterLogin = false;
  bool registerShouldSucceed = true;
  String registerError = 'Registration failed';

  @override
  bool get isConnected => _connected;

  @override
  bool get isAuthenticated => _authenticated;

  @override
  String? get sessionToken => _sessionToken;

  @override
  String? get username => _username;

  @override
  int? get userId => _userId;

  @override
  Stream<void> get disconnects => _disconnectsController.stream;

  @override
  Stream<SessionTerminatedEventPayload> get sessionTerminatedEvents =>
      _sessionTerminatedController.stream;

  @override
  Future<void> connect(
    String host,
    int port, {
    Duration? timeout,
    String? transportMaskingKey,
    bool useTls = false,
    bool enableMaskingAutoFallback = true,
    bool allowLegacyHandshakeFallback = false,
    String? trustedServerHandshakeSigningPublicKeyBase64,
    bool requireSignedHandshake = false,
  }) async {
    _connected = true;
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    _authenticated = false;
    _sessionToken = null;
  }

  @override
  Future<void> ping() async {}

  @override
  Future<void> login(
    String username,
    String password, {
    String clientInfo = 'aegis-dart-client',
    String? twoFactorCode,
    String? recoveryPhrase,
  }) async {
    if (throwTwoFactorRequired) {
      throw Exception('Two-factor code required');
    }
    if (throwTwoFactorInvalid) {
      throw Exception('Invalid two-factor code');
    }
    if (throwEmailNotVerified) {
      throw Exception('Email is not verified');
    }
    if (!loginShouldSucceed) {
      throw Exception(loginError);
    }
    _authenticated = true;
    if (!simulateNullTokenAfterLogin) {
      _sessionToken = 'test_token_$username';
    }
    _username = username;
    _userId = 123;
  }

  @override
  Future<void> loginWithToken(String token) async {
    if (!loginWithTokenShouldSucceed) {
      throw Exception(tokenError);
    }
    _authenticated = true;
    _sessionToken = token;
    _username = 'testuser';
    _userId = 123;
  }

  @override
  Future<RegistrationResponse> register(
    String username,
    String email,
    String password,
    String publicKey,
  ) async {
    if (!registerShouldSucceed) {
      return RegistrationResponse(
        success: false,
        message: registerError,
      );
    }
    return RegistrationResponse(
      success: true,
      user: RegisteredUserInfo(id: 456, username: username),
    );
  }

  @override
  Future<ProfileGetResponse> getOwnProfile() async {
    return ProfileGetResponse(
      success: true,
      profile: ProfileData(
        id: _userId ?? 1,
        username: _username ?? 'testuser',
        avatars: [],
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<UserSearchResponse> searchUsers(
    String query, {
    int limit = 20,
  }) async {
    return UserSearchResponse(
      success: true,
      users: [],
    );
  }

  @override
  Future<ProfileUpdateResponse> updateProfile({
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? username,
    String? location,
    String? birthDate,
  }) async {
    return ProfileUpdateResponse(
      success: true,
      profile: ProfileData(
        id: _userId ?? 1,
        username: _username ?? 'testuser',
        displayName: displayName,
        avatarUrl: avatarUrl,
        avatars: [],
        bio: bio,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  void requireConnected() {
    if (!_connected) throw NotConnectedException();
  }

  @override
  void requireAuthenticated() {
    if (!_connected) throw NotConnectedException();
    if (!_authenticated) throw Exception('auth.not_authenticated');
  }

  void setConnected(bool value) {
    _connected = value;
  }

  void setAuthenticated(bool value) {
    _authenticated = value;
  }

  void setSessionToken(String? token) {
    _sessionToken = token;
  }

  void setUsername(String? username) {
    _username = username;
  }

  void setUserId(int? id) {
    _userId = id;
  }

  void emitDisconnect() {
    _disconnectsController.add(null);
  }

  void emitSessionTerminated(SessionTerminatedEventPayload event) {
    _sessionTerminatedController.add(event);
  }

  @override
  void dispose() {
    _disconnectsController.close();
    _sessionTerminatedController.close();
    super.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  const pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');
  final store = <String, String>{};

  late FakeAegisClient fakeClient;
  late AegisAuthService service;

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
      final arguments = (call.arguments as Map<Object?, Object?>?) ?? const {};
      final key = arguments['key'] as String?;

      switch (call.method) {
        case 'read':
          return key == null ? null : store[key];
        case 'write':
          if (key != null) {
            store[key] = arguments['value'] as String? ?? '';
          }
          return null;
        case 'delete':
          if (key != null) {
            store.remove(key);
          }
          return null;
        case 'deleteAll':
          store.clear();
          return null;
        case 'readAll':
          return Map<String, String>.from(store);
        case 'containsKey':
          return key != null && store.containsKey(key);
      }
      return null;
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
      return '/tmp/test_support_dir';
    });
  });

  setUp(() {
    store.clear();
    SecureStore.clearMemoryCache();
    fakeClient = FakeAegisClient();
    service = AegisAuthService.testing(fakeClient);
  });

  tearDown(() {
    fakeClient.dispose();
  });

  group('exception types', () {
    test('TwoFactorRequiredException has correct message', () {
      expect(
        TwoFactorRequiredException().toString(),
        'Two-factor code required',
      );
    });

    test('TwoFactorInvalidException has correct message', () {
      expect(
        TwoFactorInvalidException().toString(),
        'Invalid two-factor code',
      );
    });

    test('EmailNotVerifiedException has correct message', () {
      expect(
        EmailNotVerifiedException().toString(),
        'Email is not verified',
      );
    });

    test('NotAuthenticatedException has correct message', () {
      final ex = NotAuthenticatedException();
      expect(ex.toString(), contains('NotAuthenticatedException'));
      expect(ex.toString(), contains('auth.not_authenticated'));
    });

    test('NotAuthenticatedException accepts custom message', () {
      final ex = NotAuthenticatedException('custom message');
      expect(ex.toString(), contains('custom message'));
    });
  });

  group('client listener setup', () {
    test('disconnect triggers session recovery when authenticated', () async {
      fakeClient.setConnected(true);
      fakeClient.setAuthenticated(true);
      fakeClient.setSessionToken('test_token');

      await service.login(identifier: 'testuser', password: 'pass');

      fakeClient.emitDisconnect();
      await Future<void>.delayed(Duration.zero);

      expect(fakeClient.isConnected, isTrue);
    });

    test(
      'disconnect does not trigger recovery when logout is in progress',
      () async {
        await service.login(identifier: 'u', password: 'p');
        await service.logout();

        fakeClient.setConnected(false);
        fakeClient.emitDisconnect();
        await Future<void>.delayed(Duration.zero);

        expect(service.isAuthenticated, false);
        expect(service.isConnected, false);
      },
    );

    test('session terminated clears session and disconnects', () async {
      store['aegis_auth_token'] = 'test_token';
      store['aegis_username'] = 'testuser';
      store['aegis_user_id'] = '123';

      fakeClient.setConnected(true);
      fakeClient.setAuthenticated(true);
      fakeClient.setSessionToken('test_token');
      fakeClient.setUsername('testuser');
      fakeClient.setUserId(123);

      fakeClient.emitSessionTerminated(
        const SessionTerminatedEventPayload(
          reason: 'session_expired',
          revokedByConnectionId: 999,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(store.containsKey('aegis_auth_token'), false);
      expect(service.isAuthenticated, false);
    });
  });

  group('connect', () {
    test('connects to server', () async {
      expect(fakeClient.isConnected, false);
      await service.connect();
      expect(fakeClient.isConnected, true);
    });

    test('does not reconnect if already connected', () async {
      fakeClient.setConnected(true);
      await service.connect();
      expect(fakeClient.isConnected, true);
    });

    test('deduplicates concurrent connect calls', () async {
      final future1 = service.connect();
      final future2 = service.connect();
      await Future.wait([future1, future2]);
      expect(fakeClient.isConnected, true);
    });
  });

  group('login', () {
    test('saves session token to SecureStore', () async {
      await service.login(identifier: 'testuser', password: 'pass');
      expect(store['aegis_auth_token'], 'test_token_testuser');
      expect(store['aegis_username'], 'testuser');
      expect(store['aegis_user_id'], '123');
    });

    test('sets in-memory state', () async {
      await service.login(identifier: 'testuser', password: 'pass');
      expect(service.isAuthenticated, true);
      expect(service.isConnected, true);
      expect(service.token, 'test_token_testuser');
      expect(service.username, 'testuser');
      expect(service.userId, 123);
    });

    test('throws TwoFactorRequiredException', () async {
      fakeClient.throwTwoFactorRequired = true;
      expect(
        () => service.login(identifier: 'u', password: 'p'),
        throwsA(isA<TwoFactorRequiredException>()),
      );
    });

    test('throws TwoFactorInvalidException', () async {
      fakeClient.throwTwoFactorInvalid = true;
      expect(
        () => service.login(identifier: 'u', password: 'p'),
        throwsA(isA<TwoFactorInvalidException>()),
      );
    });

    test('throws EmailNotVerifiedException', () async {
      fakeClient.throwEmailNotVerified = true;
      expect(
        () => service.login(identifier: 'u', password: 'p'),
        throwsA(isA<EmailNotVerifiedException>()),
      );
    });

    test('throws on session token missing from client', () async {
      fakeClient.simulateNullTokenAfterLogin = true;
      await expectLater(
        service.login(identifier: 'u', password: 'p'),
        throwsException,
      );
    });

    test('throws on login failure', () async {
      fakeClient.loginShouldSucceed = false;
      expect(
        () => service.login(identifier: 'u', password: 'p'),
        throwsException,
      );
    });
  });

  group('logout', () {
    test('clears session from SecureStore', () async {
      await service.login(identifier: 'testuser', password: 'pass');
      expect(store['aegis_auth_token'], isNotNull);

      await service.logout();
      expect(store.containsKey('aegis_auth_token'), false);
      expect(store.containsKey('aegis_username'), false);
      expect(store.containsKey('aegis_user_id'), false);
    });

    test('clears in-memory state', () async {
      await service.login(identifier: 'testuser', password: 'pass');
      expect(service.isAuthenticated, true);

      await service.logout();
      expect(service.isAuthenticated, false);
      expect(service.token, isNull);
      expect(service.username, isNull);
      expect(service.userId, isNull);
    });

    test('disconnects from server', () async {
      await service.login(identifier: 'u', password: 'p');
      expect(fakeClient.isConnected, true);

      await service.logout();
      expect(fakeClient.isConnected, false);
    });
  });

  group('clearSession', () {
    test('clears in-memory state', () async {
      fakeClient.setSessionToken('tok');
      fakeClient.setUsername('u');
      fakeClient.setUserId(1);

      store['aegis_auth_token'] = 'tok';
      store['aegis_username'] = 'u';
      store['aegis_user_id'] = '1';

      await service.clearSession();

      expect(service.token, isNull);
      expect(service.username, isNull);
      expect(service.userId, isNull);
    });

    test('clears stored session from SecureStore', () async {
      store['aegis_auth_token'] = 'tok';
      store['aegis_username'] = 'u';
      store['aegis_user_id'] = '1';

      await service.clearSession();

      expect(store.containsKey('aegis_auth_token'), false);
      expect(store.containsKey('aegis_username'), false);
      expect(store.containsKey('aegis_user_id'), false);
    });
  });

  group('restoreSession', () {
    test('returns true when already connected and authenticated', () async {
      fakeClient.setConnected(true);
      fakeClient.setAuthenticated(true);
      fakeClient.setSessionToken('tok');

      final result = await service.restoreSession();
      expect(result, true);
    });

    test('restores from stored token', () async {
      store['aegis_auth_token'] = 'opaque_token_123';
      store['aegis_username'] = 'testuser';
      store['aegis_user_id'] = '123';

      final result = await service.restoreSession();
      expect(result, true);
      expect(service.isAuthenticated, true);
    });

    test('returns false when no token is stored', () async {
      final result = await service.restoreSession();
      expect(result, false);
    });

    test('returns false when stored token is invalid', () async {
      store['aegis_auth_token'] = 'invalid_token';
      fakeClient.loginWithTokenShouldSucceed = false;

      final result = await service.restoreSession();
      expect(result, false);
    });

    test('deduplicates concurrent restoreSession calls', () async {
      store['aegis_auth_token'] = 'tok';
      store['aegis_username'] = 'u';
      store['aegis_user_id'] = '123';

      await Future.wait([
        service.restoreSession(),
        service.restoreSession(),
      ]);
      expect(service.isAuthenticated, true);
    });
  });

  group('ensureSession', () {
    test('returns immediately when connected and authenticated', () async {
      fakeClient.setConnected(true);
      fakeClient.setAuthenticated(true);
      fakeClient.setSessionToken('tok');

      await service.ensureSession();
      expect(service.isAuthenticated, true);
    });

    test('restores session when not authenticated', () async {
      store['aegis_auth_token'] = 'opaque_token_123';
      store['aegis_username'] = 'testuser';
      store['aegis_user_id'] = '123';

      await service.ensureSession();
      expect(service.isAuthenticated, true);
    });

    test('throws NotAuthenticatedException when no session available', () {
      expect(
        service.ensureSession(),
        throwsA(isA<NotAuthenticatedException>()),
      );
    });

    test('deduplicates concurrent ensureSession calls', () async {
      store['aegis_auth_token'] = 'tok';
      store['aegis_username'] = 'u';
      store['aegis_user_id'] = '123';

      await Future.wait([
        service.restoreSession(),
        service.restoreSession(),
      ]);
      expect(service.isAuthenticated, true);
    });
  });

  group('getStoredToken/Username', () {
    test('getStoredToken returns null when no token stored', () async {
      final result = await service.getStoredToken();
      expect(result, isNull);
    });

    test('getStoredToken returns stored token', () async {
      store['aegis_auth_token'] = 'stored_token_456';
      final result = await service.getStoredToken();
      expect(result, 'stored_token_456');
    });

    test('getStoredUsername returns null when no username stored', () async {
      final result = await service.getStoredUsername();
      expect(result, isNull);
    });

    test('getStoredUsername returns stored username', () async {
      store['aegis_username'] = 'stored_user';
      final result = await service.getStoredUsername();
      expect(result, 'stored_user');
    });
  });

  group('rawClient', () {
    test('returns the underlying client', () {
      expect(service.rawClient, same(fakeClient));
    });
  });

  group('searchUsers', () {
    test('delegates to client searchUsers', () async {
      store['aegis_auth_token'] = 'tok';
      store['aegis_username'] = 'u';
      store['aegis_user_id'] = '123';
      await service.ensureSession();

      fakeClient.setConnected(true);
      fakeClient.setAuthenticated(true);
      fakeClient.setSessionToken('tok');

      final result = await service.searchUsers('test', limit: 10);
      expect(result.users, isEmpty);
    });
  });

  group('getOwnProfile', () {
    test('returns profile when authenticated', () async {
      store['aegis_auth_token'] = 'tok';
      store['aegis_username'] = 'testuser';
      store['aegis_user_id'] = '123';
      await service.ensureSession();

      final result = await service.getOwnProfile();
      expect(result.success, true);
      expect(result.profile, isNotNull);
      expect(result.profile!.username, 'testuser');
    });
  });

  group('completeProfileSetup', () {
    test('updates profile successfully', () async {
      store['aegis_auth_token'] = 'tok';
      store['aegis_username'] = 'u';
      store['aegis_user_id'] = '123';
      await service.ensureSession();

      await service.completeProfileSetup(
        displayName: 'Test User',
        bio: 'Hello',
      );
    });
  });
}
