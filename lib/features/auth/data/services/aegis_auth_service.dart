import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:two_space_app/core/config/environment.dart';
import 'package:two_space_app/core/network/aegis/aegis_client.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/official_api_credentials.dart';
import 'package:two_space_app/core/services/dev_http_client.dart' as http;
import 'package:two_space_app/core/services/dev_logger.dart';
import 'package:two_space_app/core/utils/secure_store.dart';
import 'package:two_space_app/core/utils/user_facing_error.dart';
import 'package:two_space_app/features/auth/data/services/aegis_identity_service.dart';

export 'package:two_space_app/core/network/aegis/message_payloads.dart'
  show
    ActiveSessionInfo,
    RegisteredUserInfo,
    User,
    UserSearchResponse,
    UserSearchResult;

const _kAegisTokenKey = 'aegis_auth_token';
const _kAegisUsernameKey = 'aegis_username';
const _kAegisUserIdKey = 'aegis_user_id';

class TwoFactorRequiredException implements Exception {
  @override
  String toString() => 'Two-factor code required';
}

class TwoFactorInvalidException implements Exception {
  @override
  String toString() => 'Invalid two-factor code';
}

class EmailNotVerifiedException implements Exception {
  @override
  String toString() => 'Email is not verified';
}

/// Обёртка над [AegisClient] для аутентификации в приложении.
///
/// Управляет жизненным циклом TCP-соединения, токенами сессии
/// и предоставляет простой Flutter-friendly API.
class AegisAuthService {
  factory AegisAuthService() => _instance;
  AegisAuthService._internal() {
    _client.disconnects.listen((_) {
      _stopKeepAlive();
      _log.warning('Соединение с Aegis-сервером разорвано');
      if (_suppressDisconnectRecovery) {
        _log.debug('Пропускаю auto-recovery для управляемого disconnect');
        return;
      }
      if (!_logoutInProgress && (_token?.isNotEmpty ?? false)) {
        unawaited(_recoverSessionAfterKeepAliveFailure());
      }
    });
    _client.sessionTerminatedEvents.listen((event) {
      _log.warning('Current session was terminated by server: ${event.reason}');
      if (_logoutInProgress) {
        return;
      }
      unawaited(_handleSessionTerminated());
    });
  }
  static final AegisAuthService _instance = AegisAuthService._internal();

  final DevLogger _log = DevLogger('AegisAuthService');
  final AegisClient _client = _buildClient();
  final AegisIdentityService _identity = AegisIdentityService();
  final StreamController<void> _sessionRestoredController =
      StreamController<void>.broadcast();

  String? _token;
  String? _username;
  int? _userId;
  Timer? _keepAliveTimer;
  Future<bool>? _restoreSessionFuture;
  Future<void>? _connectFuture;
  Future<void>? _ensureSessionFuture;
  Future<void>? _sessionRecoveryFuture;
  bool _logoutInProgress = false;
  bool _suppressDisconnectRecovery = false;

  bool get isConnected => _client.isConnected;
  bool get isAuthenticated => _client.isAuthenticated;
  String? get token => _token;
  String? get username => _username;
  int? get userId => _userId;
  Stream<void> get sessionRestored => _sessionRestoredController.stream;

  bool get _usingEnvAppCredentials =>
      Environment.aegisAppId != null ||
      (Environment.aegisAppHash?.isNotEmpty ?? false);

  Future<void> _hydrateStoredSessionFields() async {
    final stored = await SecureStore.readMany(const <String>[
      _kAegisTokenKey,
      _kAegisUsernameKey,
      _kAegisUserIdKey,
    ]);
    _token ??= stored[_kAegisTokenKey];
    _username ??= stored[_kAegisUsernameKey];
    final storedUserId = stored[_kAegisUserIdKey];
    _userId ??= storedUserId == null ? null : int.tryParse(storedUserId);
  }

  Future<String?> getStoredToken() async {
    if (_token == null) {
      await _hydrateStoredSessionFields();
    }
    return _token;
  }

  static AegisClient _buildClient() {
    const official = AegisOfficialApiCredentials.credentials;
    final appId = Environment.aegisAppId;
    final appHash = Environment.aegisAppHash;

    final resolvedAppId = appId ?? official.appId;
    final resolvedAppHash = (appHash != null && appHash.isNotEmpty)
        ? appHash
        : official.appHash;

    return AegisClient.withApiCredentials(
      AegisApiCredentials(appId: resolvedAppId, appHash: resolvedAppHash),
    );
  }

  void _logConnectionProfile() {
    final maskingEnabled =
        Environment.aegisTransportMaskingKey?.isNotEmpty ?? false;
    final appId =
        Environment.aegisAppId ?? AegisOfficialApiCredentials.credentials.appId;
    final appHashSource = (Environment.aegisAppHash?.isNotEmpty ?? false)
        ? 'env'
        : 'official-fallback';

    _log.info(
      'Aegis profile: host=${Environment.aegisHost}:${Environment.aegisPort}, '
      'tls=${Environment.aegisUseTls}, masking=$maskingEnabled, '
      'appId=$appId, appHashSource=$appHashSource',
    );
  }

  String _classifyConnectionError(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('app credentials required') ||
        text.contains('invalid app credentials')) {
      return 'handshake_rejected_app_credentials';
    }
    if (text.contains('handshake') && text.contains('failed')) {
      return 'handshake_failed';
    }
    if (text.contains('no route to host') ||
        text.contains('connection refused')) {
      return 'network_unreachable';
    }
    if (text.contains('timeout') || text.contains('timed out')) {
      return 'network_timeout';
    }
    if (text.contains('socket') || text.contains('connection')) {
      return 'socket_error';
    }
    return 'unknown';
  }

  bool _shouldTryTlsFallback(Object error, {required bool configuredTls}) {
    // Avoid auto-upgrading plain TCP to TLS when TLS is disabled in env.
    // This mostly adds noisy TLS handshake failures and masks root causes.
    if (!configuredTls) {
      return false;
    }
    final text = error.toString().toLowerCase();
    if (text.contains('app credentials required')) {
      return false;
    }
    return text.contains('timeout') ||
        text.contains('timed out') ||
        text.contains('no response for seq=') ||
        text.contains('failed connect with masking and fallback');
  }

  Future<String?> getStoredUsername() async {
    if (_username == null) {
      await _hydrateStoredSessionFields();
    }
    return _username;
  }

  // ─── Соединение ───────────────────────────────────────────────────────────

  /// Подключиться к Aegis-серверу (не аутентифицирует).
  Future<void> connect() async {
    if (_client.isConnected) {
      _ensureKeepAlive();
      return;
    }
    final inFlight = _connectFuture;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final completer = Completer<void>();
    final future = completer.future;
    _connectFuture = future;

    unawaited(() async {
      try {
        _logConnectionProfile();
        _log.info(
          'Подключение к ${Environment.aegisHost}:${Environment.aegisPort}',
        );
        final configuredTls = Environment.aegisUseTls;
        try {
          await _client.connect(
            Environment.aegisHost,
            Environment.aegisPort,
            timeout: Environment.aegisConnectTimeout,
            transportMaskingKey: Environment.aegisTransportMaskingKey,
            useTls: configuredTls,
          );
        } on Object catch (e) {
          if (_usingEnvAppCredentials &&
              e.toString().toLowerCase().contains('app credentials')) {
            _log.warning(
              'Server rejected configured app credentials, official fallback was attempted automatically: $e',
            );
          }
          if (_shouldTryTlsFallback(e, configuredTls: configuredTls)) {
            final fallbackTls = !configuredTls;
            _log.warning(
              'Primary connect failed, retry with TLS=$fallbackTls: $e',
            );
            try {
              if (_client.isConnected) {
                await _disconnectClient();
              }
            } catch (_) {}

            try {
              await _client.connect(
                Environment.aegisHost,
                Environment.aegisPort,
                timeout: Environment.aegisConnectTimeout,
                transportMaskingKey: Environment.aegisTransportMaskingKey,
                useTls: fallbackTls,
              );
              _log.info(
                'Connected using TLS fallback mode (env TLS=$configuredTls, active TLS=$fallbackTls)',
              );
            } on Object catch (fallbackError) {
              final code = _classifyConnectionError(fallbackError);
              _log.error('Connect failed [$code]: $fallbackError');
              rethrow;
            }
          } else {
            final code = _classifyConnectionError(e);
            _log.error('Connect failed [$code]: $e');
            rethrow;
          }
        }
        _ensureKeepAlive();
        _log.info('TCP-соединение установлено');
        completer.complete();
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      } finally {
        if (identical(_connectFuture, future)) {
          _connectFuture = null;
        }
      }
    }());

    await future;
  }

  Future<void> ensureSession() async {
    if (_client.isConnected && _client.isAuthenticated) {
      _ensureKeepAlive();
      return;
    }

    final inFlight = _ensureSessionFuture;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final completer = Completer<void>();
    final future = completer.future;
    _ensureSessionFuture = future;

    unawaited(() async {
      try {
        await _ensureSessionInternal();
        completer.complete();
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      } finally {
        if (identical(_ensureSessionFuture, future)) {
          _ensureSessionFuture = null;
        }
      }
    }());

    await future;
  }

  Future<void> _ensureSessionInternal() async {
    var restored = await restoreSession();
    if (restored) {
      _ensureKeepAlive();
      return;
    }

    final hasStoredToken = (await getStoredToken())?.isNotEmpty ?? false;
    if (hasStoredToken) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      restored = await restoreSession();
      if (restored) {
        _ensureKeepAlive();
        return;
      }
    }

    throw NotAuthenticatedException();
  }

  /// Подключиться (если не подключён) и аутентифицировать по сохранённому токену.
  /// Возвращает `true` если сессия восстановлена успешно.
  Future<bool> restoreSession() async {
    if (_client.isConnected && _client.isAuthenticated) {
      _ensureKeepAlive();
      return true;
    }
    final inFlight = _restoreSessionFuture;
    if (inFlight != null) return inFlight;

    final completer = Completer<bool>();
    final future = completer.future;
    _restoreSessionFuture = future;

    unawaited(() async {
      try {
        final restored = await _restoreSessionInternal();
        completer.complete(restored);
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      } finally {
        if (identical(_restoreSessionFuture, future)) {
          _restoreSessionFuture = null;
        }
      }
    }());

    return future;
  }

  Future<bool> _restoreSessionInternal() async {
    try {
      await _hydrateStoredSessionFields();

      if (_token == null) return false;

      await connect();
      if (_looksLikeLegacyCredentialPair(_token!)) {
        final separatorIndex = _token!.indexOf(':');
        final identifier = _token!.substring(0, separatorIndex);
        final password = _token!.substring(separatorIndex + 1);
        await _client.login(identifier, password);
        _token = _client.sessionToken ?? _token;
      } else {
        await _client.loginWithToken(_token!);
        _token = _client.sessionToken ?? _token;
      }
      _username = _client.username ?? _username;
      _userId = _client.userId ?? _userId;
      await _saveSession();
      _ensureKeepAlive();
      _sessionRestoredController.add(null);
      _log.info('Сессия восстановлена для $_username');
      return true;
    } on Object catch (e) {
      _log.error(
        'Restore session failed [${_classifyConnectionError(e)}]: $e',
      );
      _log.warning('Не удалось восстановить сессию: $e');
      if (_isAuthRejectionError(e)) {
        await clearSession();
      } else {
        _stopKeepAlive();
      }
      return false;
    }
  }

  bool _looksLikeLegacyCredentialPair(String value) {
    final separatorIndex = value.indexOf(':');
    if (separatorIndex <= 0 || separatorIndex >= value.length - 1) {
      return false;
    }

    // Opaque session tokens returned by the server are hex-like and do not
    // contain separators. Historically the app stored identifier:password.
    return true;
  }

  bool _isAuthRejectionError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('invalid token') ||
        message.contains('invalid credentials') ||
        message.contains('unauthorized') ||
        message.contains('not authenticated') ||
        message.contains('authentication failed');
  }

  // ─── Регистрация ──────────────────────────────────────────────────────────

  /// Зарегистрировать нового пользователя.
  ///
  /// После успешной регистрации автоматически сохраняет токен и
  /// аутентифицирует клиент.
  Future<RegisteredUserInfo> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _log.info('Регистрация: $username / $email');
    await connect();
    final publicKey = await _identity.getOrCreatePublicKey();
    _log.debug('Публичный ключ для регистрации получен, длина=${publicKey.length}');

    final response = await _client.register(
      username,
      email,
      password,
      publicKey,
    );

    if (!response.success || response.user == null) {
      final msg = response.message ?? 'Ошибка регистрации';
      _log.warning('Регистрация провалена: $msg');
      throw Exception(msg);
    }

    final user = response.user!;
    _log.info(
      'Зарегистрирован: ${user.username} (id=${user.id}), запускаю auto-login',
    );

    try {
      await _loginAfterRegister(username: username, password: password);
    } on EmailNotVerifiedException {
      throw Exception('auth.register.verify_email_before_login');
    } on Object catch (e) {
      throw Exception(
        'auth.register.auto_login_failed::${UserFacingError.format(e)}',
      );
    }

    return user;
  }

  Future<void> completeProfileSetup({
    String? displayName,
    String? bio,
    Uint8List? avatarBytes,
  }) async {
    await ensureSession();

    final normalizedDisplayName = displayName?.trim();
    final normalizedBio = bio?.trim();

    _log.info(
      'Завершение профиля: displayName=${normalizedDisplayName?.isNotEmpty ?? false}, '
      'bio=${normalizedBio?.isNotEmpty ?? false}, avatarBytes=${avatarBytes?.length ?? 0}',
    );

    final response = await _client.updateProfile(
      displayName: (normalizedDisplayName?.isNotEmpty ?? false)
          ? normalizedDisplayName
          : null,
      bio: (normalizedBio?.isNotEmpty ?? false) ? normalizedBio : null,
    );

    if (!response.success) {
      throw Exception(response.message ?? 'auth.profile.update_failed');
    }

    _log.debug(
      'Profile update success message=${response.message} '
      'profileId=${response.profile?.id} createdAt=${response.profile?.createdAt}',
    );

    if (avatarBytes != null) {
      _log.info('Загрузка аватара после регистрации, bytes=${avatarBytes.length}');
      final avatarResponse = await _client.uploadUserAvatar(avatarBytes);
      if (!avatarResponse.success) {
        throw Exception(avatarResponse.message ?? 'auth.avatar.update_failed');
      }
      _log.debug('Avatar update success message=${avatarResponse.message}');
    }
  }

  // ─── Вход ─────────────────────────────────────────────────────────────────

  /// Войти по username/email + пароль.
  ///
  /// Под капотом: соединяемся, отправляем Auth-запрос, сохраняем токен.
  Future<void> login({
    required String identifier,
    required String password,
    String? twoFactorCode,
    String? recoveryPhrase,
  }) async {
    _log.info('Вход: $identifier');
    await connect();

    try {
      await _client.login(
        identifier,
        password,
        twoFactorCode: twoFactorCode,
        recoveryPhrase: recoveryPhrase,
      );
    } on Object catch (e) {
      _log.error('Login failed [${_classifyConnectionError(e)}]: $e');
      final errorText = e.toString().toLowerCase();
      if (errorText.contains('app credentials required') ||
          errorText.contains('invalid app credentials')) {
        throw Exception('auth.login.app_credentials_rejected');
      }
      if (errorText.contains('two-factor code required')) {
        throw TwoFactorRequiredException();
      }
      if (errorText.contains('email is not verified')) {
        throw EmailNotVerifiedException();
      }
      if (errorText.contains('invalid two-factor code')) {
        throw TwoFactorInvalidException();
      }
      rethrow;
    }

    _token = _client.sessionToken;
    _username = (_client.username?.isNotEmpty ?? false)
        ? _client.username
        : identifier;
    _userId = _client.userId;

    if (_token == null || _token!.isEmpty) {
      throw Exception('auth.login.session_token_missing');
    }

    await _saveSession();
    _ensureKeepAlive();
    _sessionRestoredController.add(null);
    _log.info('Вход выполнен: $_username');
  }

  Future<void> createSessionFromToken(
    String token, {
    String? username,
    int? userId,
  }) async {
    _token = token;
    _username = username;
    _userId = userId;

    await connect();
    await _client.loginWithToken(token);

    _token = _client.sessionToken ?? token;
    _username = _client.username ?? username;
    _userId = _client.userId ?? userId;

    await _saveSession();
    _ensureKeepAlive();
    _sessionRestoredController.add(null);
  }

  Future<Map<String, dynamic>> requestTotpSetup() async {
    await ensureSession();
    final response = await http.post(
      _botApiUri('/api/auth/2fa/setup'),
      headers: _authHeaders(),
    );

    final payload = _decodeJsonResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        _extractApiError(payload, fallback: 'auth.totp.setup_failed'),
      );
    }

    return <String, dynamic>{
      'secret': payload['secret'] ?? payload['Secret'],
      'otpauth_uri': payload['otpAuthUri'] ?? payload['OtpauthUri'],
      'recovery_phrase': payload['recoveryPhrase'] ?? payload['RecoveryPhrase'],
    };
  }

  Future<void> verifyTotpSetup(
    String code, {
    bool disable = false,
    String? recoveryPhrase,
  }) async {
    await ensureSession();
    final response = await http.post(
      _botApiUri(disable ? '/api/auth/2fa/disable' : '/api/auth/2fa/enable'),
      headers: _authHeaders(),
      body: jsonEncode({
        'Code': code,
        if (disable && recoveryPhrase != null) 'RecoveryPhrase': recoveryPhrase,
      }),
    );

    final payload = _decodeJsonResponse(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        _extractApiError(
          payload,
          fallback: disable ? 'auth.totp.disable_failed' : 'auth.totp.verify_failed',
        ),
      );
    }
  }

  Future<List<ActiveSessionInfo>> listActiveSessions() async {
    await ensureSession();

    late final Object protocolError;
    try {
      final response = await _client.listActiveSessions();
      if (!response.success) {
        throw Exception(response.message ?? 'auth.sessions.list_failed');
      }
      return response.sessions;
    } on Object catch (error) {
      protocolError = error;
      _log.debug('Session list over Aegis protocol failed: $error');
    }

    try {
      final response = await _listActiveSessionsViaHttp();
      if (!response.success) {
        throw Exception(response.message ?? 'auth.sessions.list_failed');
      }
      return response.sessions;
    } on Object {
      _throwStoredError(protocolError);
    }
  }

  Future<void> revokeSession(String sessionId) async {
    await ensureSession();

    late final Object protocolError;
    try {
      final response = await _client.revokeSession(sessionId);
      if (!response.success) {
        throw Exception(response.message ?? 'auth.sessions.revoke_failed');
      }
      return;
    } on Object catch (error) {
      protocolError = error;
      _log.debug('Session revoke over Aegis protocol failed: $error');
    }

    try {
      await _revokeSessionViaHttp(sessionId);
    } on Object {
      _throwStoredError(protocolError);
    }
  }

  // ─── Выход ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    _log.info('Выход...');
    _logoutInProgress = true;
    _stopKeepAlive();
    try {
      await clearSession();
      try {
        await _disconnectClient();
      } on Object catch (e) {
        _log.debug('Ошибка при disconnect: $e');
      }
    } finally {
      _logoutInProgress = false;
    }
  }

  // ─── Поиск пользователей ──────────────────────────────────────────────────

  Future<UserSearchResponse> searchUsers(String query, {int limit = 20}) async {
    _ensureAuthenticated();
    return _client.searchUsers(query, limit: limit);
  }

  // ─── Приватное ────────────────────────────────────────────────────────────

  Future<void> _loginAfterRegister({
    required String username,
    required String password,
  }) async {
    await login(identifier: username, password: password);
  }

  Future<void> _saveSession() async {
    if (_token != null)
      await SecureStore.write(_kAegisTokenKey, _token!);
    if (_username != null)
      await SecureStore.write(_kAegisUsernameKey, _username!);
    if (_userId != null)
      await SecureStore.write(_kAegisUserIdKey, _userId!.toString());
  }

  Future<void> clearSession() async {
    _stopKeepAlive();
    _token = null;
    _username = null;
    _userId = null;
    await SecureStore.delete(_kAegisTokenKey);
    await SecureStore.delete(_kAegisUsernameKey);
    await SecureStore.delete(_kAegisUserIdKey);
  }

  void _ensureKeepAlive() {
    _keepAliveTimer ??= Timer.periodic(const Duration(seconds: 90), (_) async {
      if (!_client.isConnected || !_client.isAuthenticated) {
        return;
      }
      try {
        await _client.ping();
      } on Object catch (e) {
        _log.debug('Ping keep-alive не удался: $e');
        unawaited(_recoverSessionAfterKeepAliveFailure());
      }
    });
  }

  Future<void> _recoverSessionAfterKeepAliveFailure() async {
    final inFlight = _sessionRecoveryFuture;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final completer = Completer<void>();
    final future = completer.future;
    _sessionRecoveryFuture = future;

    unawaited(() async {
      try {
        try {
          if (_client.isConnected) {
            await _disconnectClient();
          }
        } catch (_) {}

        try {
          await ensureSession();
        } on Object catch (e) {
          _log.debug('Автовосстановление сессии не удалось: $e');
        }
        completer.complete();
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      } finally {
        if (identical(_sessionRecoveryFuture, future)) {
          _sessionRecoveryFuture = null;
        }
      }
    }());

    await future;
  }

  Future<void> _disconnectClient() async {
    final previousSuppression = _suppressDisconnectRecovery;
    _suppressDisconnectRecovery = true;
    try {
      await _client.disconnect();
    } finally {
      _suppressDisconnectRecovery = previousSuppression;
    }
  }

  void _stopKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }

  void _ensureAuthenticated() {
    if (!_client.isAuthenticated) {
      throw NotAuthenticatedException();
    }
  }

  Uri _botApiUri(String path) {
    final base = Uri.parse(Environment.aegisBotApiBaseUrl);
    return base.resolve(path);
  }

  Future<SessionListResponse> _listActiveSessionsViaHttp() async {
    final endpoints = <String>[
      '/api/auth/sessions',
      '/api/auth/sessions/list',
    ];

    Object? lastError;
    for (final endpoint in endpoints) {
      try {
        final response = await http.get(
          _botApiUri(endpoint),
          headers: _authHeaders(),
        );
        final payload = _decodeJsonResponse(response);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return SessionListResponse.fromJson(
            _normalizeSessionListPayload(payload),
          );
        }
        lastError = Exception(
          _extractApiError(
            payload,
            fallback: 'auth.sessions.list_failed',
          ),
        );
      } on Object catch (error) {
        lastError = error;
      }
    }

    if (lastError != null) {
      _throwStoredError(lastError);
    }
    throw Exception('auth.sessions.list_failed');
  }

  Future<void> _revokeSessionViaHttp(String sessionId) async {
    final operations = <Future<http.Response> Function()>[
      () => http.post(
        _botApiUri('/api/auth/sessions/revoke'),
        headers: _authHeaders(),
        body: jsonEncode({'SessionId': sessionId}),
      ),
      () => http.post(
        _botApiUri('/api/auth/sessions/$sessionId/revoke'),
        headers: _authHeaders(),
      ),
      () => http.delete(
        _botApiUri('/api/auth/sessions/$sessionId'),
        headers: _authHeaders(),
      ),
    ];

    Object? lastError;
    for (final operation in operations) {
      try {
        final response = await operation();
        final payload = _decodeJsonResponse(response);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final result = SessionRevokeResponse.fromJson(payload);
          if (!result.success) {
            throw Exception(result.message ?? 'auth.sessions.revoke_failed');
          }
          return;
        }
        lastError = Exception(
          _extractApiError(payload, fallback: 'auth.sessions.revoke_failed'),
        );
      } on Object catch (error) {
        lastError = error;
      }
    }

    if (lastError != null) {
      _throwStoredError(lastError);
    }
    throw Exception('auth.sessions.revoke_failed');
  }

  Future<void> _handleSessionTerminated() async {
    _stopKeepAlive();
    await clearSession();
    try {
      if (_client.isConnected) {
        await _disconnectClient();
      }
    } on Object catch (error) {
      _log.debug('Disconnect after session termination failed: $error');
    }
  }

  Map<String, dynamic> _normalizeSessionListPayload(
    Map<String, dynamic> payload,
  ) {
    final directList = payload['value'];
    if (directList is List) {
      return <String, dynamic>{'Success': true, 'Sessions': directList};
    }

    if (payload['Sessions'] is List || payload['ActiveSessions'] is List) {
      return payload;
    }

    final nested = payload['Data'] ?? payload['Result'];
    if (nested is Map<String, dynamic>) {
      return nested;
    }
    if (nested is Map) {
      return nested.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    if (nested is List) {
      return <String, dynamic>{'Success': true, 'Sessions': nested};
    }

    return payload;
  }

  Map<String, String> _authHeaders() {
    final token = _token;
    if (token == null || token.isEmpty) {
      throw NotAuthenticatedException();
    }

    return <String, String>{
      'Content-Type': 'application/json',
      'X-Session-Token': token,
    };
  }

  Map<String, dynamic> _decodeJsonResponse(http.Response response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return decoded.map<String, dynamic>(
        (key, value) => MapEntry(key.toString(), value),
      );
    }

    return <String, dynamic>{'value': decoded};
  }

  String _extractApiError(
    Map<String, dynamic> payload, {
    required String fallback,
  }) {
    final error = payload['error'] ?? payload['Error'] ?? payload['message'] ?? payload['Message'];
    final text = error?.toString().trim();
    if (text == null || text.isEmpty) {
      return fallback;
    }
    return text;
  }

  Never _throwStoredError(Object error) {
    if (error is Error) {
      throw error;
    }
    if (error is Exception) {
      throw error;
    }
    throw Exception(error.toString());
  }

  AegisClient get rawClient => _client;
}

class NotAuthenticatedException implements Exception {
  @override
  String toString() => 'NotAuthenticatedException: auth.not_authenticated';
}
