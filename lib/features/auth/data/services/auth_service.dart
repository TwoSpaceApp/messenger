import 'dart:typed_data';

import 'package:two_space_app/core/services/dev_logger.dart';
import 'package:two_space_app/features/auth/data/services/aegis_auth_service.dart';

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

  Future<String?> getJwt() async {
    return getMatrixTokenForUser();
  }

  Future<bool> ensureJwt() async {
    return restoreSessionFromToken();
  }

  Future<void> signOut() async {
    _logger.info('🚪 Выход из аккаунта...');
    try {
      await _aegis.logout();
      _logger.info('✓ Aegis сессия завершена');
    } catch (e) {
      _logger.debug('⚠️ Aegis logout ошибка: $e');
    }
    try {
      await clearMatrixTokenForCurrentUser();
      _logger.info('✓ Токены очищены');
    } catch (e) {
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
    } catch (e) {
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
      return {
        'id': user.id.toString(),
        'name': user.username,
        'email': user.email
      };
    } catch (e) {
      _logger.warning('❌ Ошибка регистрации: $e');
      rethrow;
    }
  }

  Future<void> signInMatrix(String username, String password) async {
    return loginUser(username, password);
  }

  Future<String?> refreshMatrixTokenForUser({String? appUserId}) async {
    return getMatrixTokenForUser(appUserId: appUserId);
  }

  Future<String?> getMatrixTokenForUser({String? appUserId}) async {
    if (_aegis.token != null) return _aegis.token;
    final storedAegisToken = await _aegis.getStoredToken();
    if (storedAegisToken != null && storedAegisToken.isNotEmpty) {
      return storedAegisToken;
    }
    return null;
  }

  Future<String?> tryRefreshMatrixToken({String? appUserId}) async {
    return getMatrixTokenForUser(appUserId: appUserId);
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

  Future<void> clearMatrixTokenForCurrentUser() async {
    try {
      final token = await _aegis.getStoredToken();
      if (token != null && token.isNotEmpty) {
        await _aegis.logout();
      }
    } catch (e) {
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
    throw UnsupportedError('TOTP setup is not supported in Aegis mode');
  }

  Future<void> verifyTotpSetup(String code, {bool disable = false}) async {
    throw UnsupportedError('TOTP setup is not supported in Aegis mode');
  }

  Future<void> createSessionFromToken(String userId, String secret) async {
    throw UnsupportedError('Token session flow is not supported in Aegis mode');
  }

  Future<bool> restoreSessionFromToken() async {
    try {
      final restored = await _aegis.restoreSession();
      if (restored) {
        _logger.info('✓ Aegis сессия восстановлена');
        return true;
      }
    } catch (e) {
      _logger.debug('Не удалось восстановить Aegis-сессию: $e');
    }
    return false;
  }

  // Backwards-compatible method names for Riverpod providers
  Future<void> login(String identifier, String password) async {
    return loginUser(identifier, password);
  }

  Future<void> logout() async {
    return signOut();
  }
}
