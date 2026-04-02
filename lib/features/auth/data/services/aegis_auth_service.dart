import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:two_space_app/core/config/environment.dart';
import 'package:two_space_app/core/network/aegis/aegis_client.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/official_api_credentials.dart';
import 'package:two_space_app/core/services/dev_logger.dart';
import 'package:two_space_app/features/auth/data/services/aegis_identity_service.dart';

export 'package:two_space_app/core/network/aegis/message_payloads.dart'
    show RegisteredUserInfo, User, UserSearchResponse, UserSearchResult;

const _kAegisTokenKey = 'aegis_auth_token';
const _kAegisUsernameKey = 'aegis_username';
const _kAegisUserIdKey = 'aegis_user_id';

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
    });
  }
  static final AegisAuthService _instance = AegisAuthService._internal();

  final DevLogger _log = DevLogger('AegisAuthService');
  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  final AegisClient _client = _buildClient();
  final AegisIdentityService _identity = AegisIdentityService();

  String? _token;
  String? _username;
  int? _userId;
  Timer? _keepAliveTimer;
  Future<bool>? _restoreSessionFuture;
  Future<void>? _connectFuture;
  Future<void>? _ensureSessionFuture;
  Future<void>? _sessionRecoveryFuture;

  bool get isConnected => _client.isConnected;
  bool get isAuthenticated => _client.isAuthenticated;
  String? get token => _token;
  String? get username => _username;
  int? get userId => _userId;

  bool get _usingEnvAppCredentials =>
      Environment.aegisAppId != null ||
      (Environment.aegisAppHash?.isNotEmpty ?? false);

  Future<String?> getStoredToken() async {
    _token ??= await _secure.read(key: _kAegisTokenKey);
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
    _username ??= await _secure.read(key: _kAegisUsernameKey);
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

    final future = () async {
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
              await _client.disconnect();
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
    }();

    _connectFuture = future;
    try {
      await future;
    } finally {
      if (identical(_connectFuture, future)) {
        _connectFuture = null;
      }
    }
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

    final future = _ensureSessionInternal();
    _ensureSessionFuture = future;
    try {
      await future;
    } finally {
      if (identical(_ensureSessionFuture, future)) {
        _ensureSessionFuture = null;
      }
    }
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

    final future = _restoreSessionInternal();
    _restoreSessionFuture = future;
    future.whenComplete(() => _restoreSessionFuture = null);
    return future;
  }

  Future<bool> _restoreSessionInternal() async {
    try {
      _token = await _secure.read(key: _kAegisTokenKey);
      _username = await _secure.read(key: _kAegisUsernameKey);
      final idStr = await _secure.read(key: _kAegisUserIdKey);
      _userId = idStr != null ? int.tryParse(idStr) : null;

      if (_token == null) return false;

      await connect();
      if (_token!.contains(':')) {
        final separatorIndex = _token!.indexOf(':');
        final identifier = _token!.substring(0, separatorIndex);
        final password = _token!.substring(separatorIndex + 1);
        await _client.login(identifier, password);
        _username = _client.username ?? identifier;
        _userId = _client.userId;
      } else {
        await _client.loginWithToken(_token!);
        _username = _client.username;
        _userId = _client.userId;
      }
      await _saveSession();
      _ensureKeepAlive();
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
    _log.info('Зарегистрирован: ${user.username} (id=${user.id})');

    // После регистрации сервер может вернуть токен — используем username как token
    // (реальный auth-flow: после Register → Auth)
    await _loginAfterRegister(username: username, password: password);

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

    final response = await _client.updateProfile(
      displayName: (normalizedDisplayName?.isNotEmpty ?? false)
          ? normalizedDisplayName
          : null,
      bio: (normalizedBio?.isNotEmpty ?? false) ? normalizedBio : null,
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Не удалось обновить профиль');
    }

    if (avatarBytes != null) {
      final avatarResponse = await _client.uploadUserAvatar(avatarBytes);
      if (!avatarResponse.success) {
        throw Exception(avatarResponse.message ?? 'Не удалось обновить аватар');
      }
    }
  }

  // ─── Вход ─────────────────────────────────────────────────────────────────

  /// Войти по username/email + пароль.
  ///
  /// Под капотом: соединяемся, отправляем Auth-запрос, сохраняем токен.
  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    _log.info('Вход: $identifier');
    await connect();

    // TODO(security): сервер текущей версии принимает токен в формате
    //   «identifier:password» и самостоятельно валидирует его.
    //   В будущих версиях сервер должен возвращать непрозрачный сессионный
    //   токен (UUID / JWT), который и нужно сохранять вместо пароля.
    //   До этого момента plain-текст пароля попадает в FlutterSecureStorage
    //   (шифруется Keystore/Keychain) и в память клиента.
    try {
      await _client.login(identifier, password);
    } on Object catch (e) {
      _log.error('Login failed [${_classifyConnectionError(e)}]: $e');
      final errorText = e.toString().toLowerCase();
      if (errorText.contains('app credentials required') ||
          errorText.contains('invalid app credentials')) {
        throw Exception(
          'Сервер отклонил app credentials. Клиент уже пробует встроенные official credentials автоматически; если ошибка сохраняется, проблема уже на стороне сервера или в несовместимом handshake.',
        );
      }
      rethrow;
    }

    _token = '$identifier:$password';
    _username = (_client.username?.isNotEmpty ?? false)
        ? _client.username
        : identifier;
    _userId = _client.userId;

    await _saveSession();
    _ensureKeepAlive();
    _log.info('Вход выполнен: $_username');
  }

  // ─── Выход ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    _log.info('Выход...');
    _stopKeepAlive();
    await clearSession();
    try {
      await _client.disconnect();
    } on Object catch (e) {
      _log.debug('Ошибка при disconnect: $e');
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
    try {
      await login(identifier: username, password: password);
    } on Object catch (e) {
      _log.warning('Автологин после регистрации не удался: $e');
      // Не бросаем — регистрация прошла успешно
    }
  }

  Future<void> _saveSession() async {
    if (_token != null)
      await _secure.write(key: _kAegisTokenKey, value: _token);
    if (_username != null)
      await _secure.write(key: _kAegisUsernameKey, value: _username);
    if (_userId != null)
      await _secure.write(key: _kAegisUserIdKey, value: _userId!.toString());
  }

  Future<void> clearSession() async {
    _stopKeepAlive();
    _token = null;
    _username = null;
    _userId = null;
    await _secure.delete(key: _kAegisTokenKey);
    await _secure.delete(key: _kAegisUsernameKey);
    await _secure.delete(key: _kAegisUserIdKey);
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

    final future = () async {
      try {
        if (_client.isConnected) {
          await _client.disconnect();
        }
      } catch (_) {}

      try {
        await ensureSession();
      } on Object catch (e) {
        _log.debug('Автовосстановление сессии не удалось: $e');
      }
    }();

    _sessionRecoveryFuture = future;
    try {
      await future;
    } finally {
      if (identical(_sessionRecoveryFuture, future)) {
        _sessionRecoveryFuture = null;
      }
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

  AegisClient get rawClient => _client;
}

class NotAuthenticatedException implements Exception {
  @override
  String toString() => 'NotAuthenticatedException: необходима аутентификация';
}
