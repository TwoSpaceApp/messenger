import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:two_space_app/core/config/environment.dart';
import 'package:two_space_app/core/network/aegis/aegis_client.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/services/dev_logger.dart';

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
  AegisAuthService._internal();
  static final AegisAuthService _instance = AegisAuthService._internal();

  final DevLogger _log = DevLogger('AegisAuthService');
  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  final AegisClient _client = AegisClient();

  String? _token;
  String? _username;
  int? _userId;

  bool get isConnected => _client.isConnected;
  bool get isAuthenticated => _client.isAuthenticated;
  String? get token => _token;
  String? get username => _username;
  int? get userId => _userId;

  // ─── Соединение ───────────────────────────────────────────────────────────

  /// Подключиться к Aegis-серверу (не аутентифицирует).
  Future<void> connect() async {
    if (_client.isConnected) return;
    _log.info(
        'Подключение к ${Environment.aegisHost}:${Environment.aegisPort}');
    await _client.connect(
      Environment.aegisHost,
      Environment.aegisPort,
      timeout: Environment.aegisConnectTimeout,
    );
    _log.info('TCP-соединение установлено');
  }

  /// Подключиться (если не подключён) и аутентифицировать по сохранённому токену.
  /// Возвращает `true` если сессия восстановлена успешно.
  Future<bool> restoreSession() async {
    try {
      _token = await _secure.read(key: _kAegisTokenKey);
      _username = await _secure.read(key: _kAegisUsernameKey);
      final idStr = await _secure.read(key: _kAegisUserIdKey);
      _userId = idStr != null ? int.tryParse(idStr) : null;

      if (_token == null) return false;

      await connect();
      await _client.authenticate(_token!);
      _log.info('Сессия восстановлена для $_username');
      return true;
    } catch (e) {
      _log.warning('Не удалось восстановить сессию: $e');
      await clearSession();
      return false;
    }
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

    final response = await _client.register(
      username,
      email,
      password,
      'client_public_key_placeholder', // TODO: X3DH keypair
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
    final rawToken = '$identifier:$password';
    await _client.authenticate(rawToken);

    _token = rawToken;
    _username = identifier;

    await _saveSession();
    _log.info('Вход выполнен: $identifier');
  }

  // ─── Выход ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    _log.info('Выход...');
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
    _token = null;
    _username = null;
    _userId = null;
    await _secure.delete(key: _kAegisTokenKey);
    await _secure.delete(key: _kAegisUsernameKey);
    await _secure.delete(key: _kAegisUserIdKey);
  }

  void _ensureAuthenticated() {
    if (!_client.isAuthenticated) {
      throw NotAuthenticatedException();
    }
  }

  /// Нижний уровень: сырой клиент для расширенных операций.
  AegisClient get rawClient => _client;
}

// ─── Вспомогательные исключения ───────────────────────────────────────────────

class NotAuthenticatedException implements Exception {
  @override
  String toString() => 'NotAuthenticatedException: необходима аутентификация';
}
