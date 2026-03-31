import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:two_space_app/core/config/environment.dart';
import 'package:two_space_app/core/network/aegis/aegis_client.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/services/dev_logger.dart';
import 'package:two_space_app/features/auth/data/services/aegis_identity_service.dart';

export 'package:two_space_app/core/network/aegis/message_payloads.dart'
    show User, UserSearchResponse, UserSearchResult;

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
  final AegisClient _client = AegisClient();
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

  Future<String?> getStoredToken() async {
    _token ??= await _secure.read(key: _kAegisTokenKey);
    return _token;
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
      _log.info(
          'Подключение к ${Environment.aegisHost}:${Environment.aegisPort}');
      await _client.connect(
        Environment.aegisHost,
        Environment.aegisPort,
        timeout: Environment.aegisConnectTimeout,
        transportMaskingKey: Environment.aegisTransportMaskingKey,
        useTls: Environment.aegisUseTls,
      );
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
        final response = await _client.authenticateWithPassword(
          username: identifier,
          password: password,
        );
        _username = response.username;
        _userId = response.userId;
        if (response.sessionToken.isNotEmpty) {
          _token = response.sessionToken;
        }
      } else {
        final response = await _client.authenticateWithToken(_token!);
        _username = response.username;
        _userId = response.userId;
        if (response.sessionToken.isNotEmpty) {
          _token = response.sessionToken;
        }
      }
      await _saveSession();
      _ensureKeepAlive();
      _log.info('Сессия восстановлена для $_username');
      return true;
    } catch (e) {
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
  Future<User> register({
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
    final response = await _client.authenticateWithPassword(
      username: identifier,
      password: password,
    );

    _token = response.sessionToken.isNotEmpty
        ? response.sessionToken
        : '$identifier:$password';
    _username = response.username.isNotEmpty ? response.username : identifier;
    _userId = response.userId > 0 ? response.userId : null;

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
    } catch (e) {
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
    } catch (e) {
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
      } catch (e) {
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
      } catch (e) {
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
