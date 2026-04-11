import 'dart:typed_data';

import 'package:two_space_app/core/services/dev_logger.dart';
import 'package:two_space_app/features/auth/data/services/aegis_auth_service.dart';

class StoredAuthSession {
  const StoredAuthSession({required this.userId, required this.token});

  final String userId;
  final String token;
}

class AuthService {
  factory AuthService({dynamic accountClient}) {
    if (accountClient != null) {
      _instance._accountClient = accountClient;
    }
    return _instance;
  }
  AuthService._internal();
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();

  dynamic _accountClient;
  dynamic get accountClient => _accountClient;

  final DevLogger _logger = DevLogger('AuthService');

  final AegisAuthService _aegis = AegisAuthService();

  Future<void> signInWithEmail(String email, String password) async {
    return loginUser(email, password);
  }

  Future<String?> getAuthToken() async {
    if (_aegis.token != null) return _aegis.token;
    final storedToken = await _aegis.getStoredToken();
    if (storedToken != null && storedToken.isNotEmpty) {
      return storedToken;
    }
    return null;
  }

  Future<StoredAuthSession?> getStoredSessionSnapshot() async {
    final values = await Future.wait<String?>([
      getAuthToken(),
      getCurrentUserId(),
    ]);
    final token = values[0];
    if (token == null || token.isEmpty) {
      return null;
    }

    final userId = values[1];
    if (userId == null || userId.isEmpty) {
      return null;
    }

    return StoredAuthSession(userId: userId, token: token);
  }

  Future<bool> ensureStoredSession() async {
    return restoreSessionFromToken();
  }

  Future<void> signOut() async {
    _logger.info('🚪 Выход из аккаунта...');
    try {
      await _aegis.logout();
      _logger.info('✓ Aegis сессия завершена');
    } on Object catch (e) {
      _logger.debug('⚠️ Aegis logout ошибка: $e');
    }
    try {
      await clearStoredSession();
      _logger.info('✓ Токены очищены');
    } on Object catch (e) {
      _logger.debug('❌ Ошибка очистки: $e');
    }
  }

  // Backwards compatible wrappers used by existing screens
  Future<void> loginUser(String identifier, String password) async {
    _logger.info('🔐 Вход: $identifier');
    try {
      await _aegis.login(identifier: identifier, password: password);
      _logger.info('✓ Вход через Aegis успешен');
      return;
    } on Object catch (e) {
      _logger.warning('❌ Aegis вход не удался: $e');
      rethrow;
    }
  }

  Future<dynamic> registerUser(
    String username,
    String email,
    String password, {
    String? displayName,
    Uint8List? avatarBytes,
  }) async {
    _logger.info('📝 Регистрация: $username / $email');
    try {
      final user = await _aegis.register(
        username: username,
        email: email,
        password: password,
      );
      if ((displayName?.trim().isNotEmpty ?? false) || avatarBytes != null) {
        await _aegis.completeProfileSetup(
          displayName: displayName,
          avatarBytes: avatarBytes,
        );
      }
      _logger.info('✓ Зарегистрирован: ${user.username}');
      return {'id': user.id.toString(), 'name': user.username, 'email': email};
    } on Object catch (e) {
      _logger.warning('❌ Ошибка регистрации: $e');
      rethrow;
    }
  }

  Future<String?> refreshAuthToken({String? appUserId}) async {
    return getAuthToken();
  }

  Future<void> loginWithSsoToken(String token) async {
    throw UnsupportedError('SSO token flow is not supported in Aegis mode');
  }

  Future<String?> getCurrentUserId() async {
    if (_aegis.userId != null) return _aegis.userId.toString();
    if (_aegis.username != null) return _aegis.username;
    final storedAegisUsername = await _aegis.getStoredUsername();
    if (storedAegisUsername != null && storedAegisUsername.isNotEmpty) {
      return storedAegisUsername;
    }
    return null;
  }

  Future<String?> tryRefreshAuthToken({String? appUserId}) async {
    return getAuthToken();
  }

  Future<void> clearStoredSession() async {
    try {
      final token = await _aegis.getStoredToken();
      if (token != null && token.isNotEmpty) {
        await _aegis.logout();
      }
    } on Object catch (e) {
      _logger.debug('Не удалось очистить токен: $e');
    }
  }

  Future<dynamic> sendPhoneToken(String phone) async {
    throw UnsupportedError('Phone token flow is not supported in Aegis mode');
  }

  Future<dynamic> sendEmailToken(String email) async {
    throw UnsupportedError('Email token flow is not supported in Aegis mode');
  }

  Future<Map<String, dynamic>> requestTotpSetup() async {
    return _aegis.requestTotpSetup();
  }

  Future<void> verifyTotpSetup(
    String code, {
    bool disable = false,
    String? recoveryPhrase,
  }) async {
    return _aegis.verifyTotpSetup(
      code,
      disable: disable,
      recoveryPhrase: recoveryPhrase,
    );
  }

  Future<void> createSessionFromToken(String userId, String secret) async {
    final parsedUserId = int.tryParse(userId);
    await _aegis.createSessionFromToken(
      secret,
      userId: parsedUserId,
      username: parsedUserId == null ? userId : null,
    );
  }

  Future<bool> restoreSessionFromToken() async {
    try {
      final restored = await _aegis.restoreSession();
      if (restored) {
        _logger.info('✓ Aegis сессия восстановлена');
        return true;
      }
    } on Object catch (e) {
      _logger.debug('Не удалось восстановить Aegis-сессию: $e');
    }
    return false;
  }

  // Backwards-compatible method names for Riverpod providers
  Future<void> login(
    String identifier,
    String password, {
    String? twoFactorCode,
    String? recoveryPhrase,
  }) async {
    _logger.info('🔐 Вход: $identifier');
    try {
      await _aegis.login(
        identifier: identifier,
        password: password,
        twoFactorCode: twoFactorCode,
        recoveryPhrase: recoveryPhrase,
      );
      _logger.info('✓ Вход через Aegis успешен');
      return;
    } on Object catch (e) {
      _logger.warning('❌ Aegis вход не удался: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    return signOut();
  }

  Future<List<ActiveSessionInfo>> listActiveSessions() {
    return _aegis.listActiveSessions();
  }

  Future<void> revokeSession(String sessionId) {
    return _aegis.revokeSession(sessionId);
  }
}
