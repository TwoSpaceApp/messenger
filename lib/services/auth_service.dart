import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:two_space_app/services/matrix_service.dart';
import 'package:two_space_app/services/chat_matrix_service.dart';
import 'package:two_space_app/services/dev_logger.dart';
import 'package:two_space_app/config/environment.dart';
import 'package:two_space_app/services/aegis_auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keys used in secure storage for Matrix tokens per-user
const _kMatrixTokenKeyPrefix = 'matrix_token_';
const _kMatrixRefreshKeyPrefix = 'matrix_refresh_';
const _kMatrixDeviceIdPrefix = 'matrix_device_';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService({dynamic accountClient}) {
    if (accountClient != null) {
      _instance._accountClient = accountClient;
    }
    return _instance;
  }
  AuthService._internal();

  dynamic _accountClient;
  dynamic get accountClient => _accountClient;
  
  final DevLogger _logger = DevLogger('AuthService');

  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  final ChatMatrixService _matrixService = ChatMatrixService();
  final AegisAuthService _aegis = AegisAuthService();

  // ChatMatrixService storage keys (kept here to avoid tight coupling to its private consts)
  static const String _kChatMatrixAccessTokenKey = 'matrix_access_token';
  static const String _kChatMatrixRefreshTokenKey = 'matrix_refresh_token';

  // Email/password sign in using real Matrix login
  Future<void> signInWithEmail(String email, String password) async {
    _logger.info('🔐 Matrix login attempt: $email');
    try {
      await _matrixService.login(email, password);
      _logger.info('✓ Matrix login successful');
    } catch (e) {
      _logger.warning('❌ Matrix login failed: $e');
      rethrow;
    }
  }

  /// Return currently cached JWT, or null if none.
  Future<String?> getJwt() async {
    return await MatrixService.getJwt();
  }

  /// Ensure we have valid credentials: check ChatMatrixService for stored tokens
  Future<bool> ensureJwt() async {
    try {
      await _matrixService.init();
      return _matrixService.isLoggedIn;
    } catch (e) {
      _logger.debug('Не удалось проверить авторизацию: $e');
      return false;
    }
  }

  /// Sign out current user: delete session on server and clear stored JWT/cookie
  Future<void> signOut() async {
    _logger.info('🚪 Выход из аккаунта...');
    // Прежде всего выходим из Aegis
    try {
      await _aegis.logout();
      _logger.info('✓ Aegis сессия завершена');
    } catch (e) {
      _logger.debug('⚠️ Aegis logout ошибка: $e');
    }
    // Зачищаем Matrix креденшиалы
    try {
      await _matrixService.clearCredentials();
      _logger.info('✓ Matrix credentials cleared');
    } catch (e) {
      _logger.debug('❌ Ошибка очистки Matrix credentials: $e');
    }
    try {
      await MatrixService.deleteCurrentSession();
      _logger.info('✓ Сессия удалена');
    } catch (e) {
      _logger.debug('❌ Ошибка удаления сессии: $e');
    }
    try {
      await MatrixService.saveSessionCookie(null);
    } catch (e) {
      _logger.debug('❌ Ошибка очистки cookie: $e');
    }
    try {
      await MatrixService.clearJwt();
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

  Future<dynamic> registerUser(String name, String email, String password) async {
    _logger.info('📝 Регистрация: $name / $email');
    try {
      final user = await _aegis.register(
        username: name,
        email: email,
        password: password,
      );
      _logger.info('✓ Зарегистрирован: ${user.username}');
      return {'id': user.id.toString(), 'name': user.username, 'email': user.email};
    } catch (e) {
      _logger.warning('❌ Ошибка регистрации: $e');
      rethrow;
    }
  }

  /// Sign in to a Matrix homeserver using password login and store the
  /// returned access token securely for the current Appwrite user id.
  ///
  /// Note: this assumes Matrix accounts already exist for the user (same
  /// localpart or separate accounts). If not, account provisioning should be
  /// performed on the server (out of scope for this patch).
  Future<void> signInMatrix(String username, String password) async {
    final homeserver = Environment.matrixHomeserverUrl;
    if (homeserver.isEmpty) throw Exception('Matrix homeserver not configured');
    // Normalize homeserver URL: ensure scheme present
    var base = homeserver.trim();
    if (!base.startsWith('http://') && !base.startsWith('https://')) base = 'https://$base';
    base = base.replaceAll(RegExp(r'/$'), '');

    // Normalize username: support full MXID (@local:domain) or email-like input (local@domain) or plain localpart
    String loginUser = username;
    try {
      if (username.startsWith('@') && username.contains(':')) {
        // form @local:domain
        final withoutAt = username.substring(1);
        final parts = withoutAt.split(':');
        if (parts.isNotEmpty) loginUser = parts[0];
      } else if (username.contains('@') && !username.startsWith('@')) {
        // email-like: take local part before @
        loginUser = username.split('@').first;
      }
    } catch (e) {
      _logger.debug('Ошибка нормализации имени пользователя: $e');
    }

    final uri = Uri.parse('$base/_matrix/client/v3/login');
    final body = jsonEncode({
      'type': 'm.login.password',
      'identifier': {'type': 'm.id.user', 'user': loginUser},
      'password': password,
    });
    final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Matrix login failed ${res.statusCode}: ${res.body}');
    }
  final js = jsonDecode(res.body) as Map<String, dynamic>;
  final token = js['access_token'] as String?;
  final refresh = js['refresh_token'] as String?;
  final deviceId = js['device_id'] as String?;
  final userId = js['user_id'] as String?;
  if (token == null || userId == null) throw Exception('Matrix login response missing token/user_id');
    // Save token keyed by current app user id if available, otherwise by matrix user id
    String keyId = userId;
    try {
      final me = await MatrixService().getCurrentUserId();
      if (me != null && me.isNotEmpty) keyId = me;
    } catch (e) {
      _logger.debug('Не удалось получить текущий userId: $e');
    }
    await _secure.write(key: '$_kMatrixTokenKeyPrefix$keyId', value: token);
    // Remember current matrix user id for other services
    try {
      await MatrixService.setCurrentUserId(userId);
    } catch (e) {
      _logger.debug('Не удалось сохранить userId: $e');
    }
    // Save optional refresh token and device id if present
    if (refresh != null && refresh.isNotEmpty) {
      await _secure.write(key: '$_kMatrixRefreshKeyPrefix$keyId', value: refresh);
    }
    if (deviceId != null && deviceId.isNotEmpty) {
      await _secure.write(key: '$_kMatrixDeviceIdPrefix$keyId', value: deviceId);
    }
  }

  /// Attempt to refresh Matrix access token using stored refresh token for user.
  /// Returns new access token on success, or null on failure.
  Future<String?> refreshMatrixTokenForUser({String? appUserId}) async {
    String keyId = appUserId ?? '';
    if (keyId.isEmpty) {
      try {
        final me = await MatrixService().getCurrentUserId();
        if (me != null) keyId = me;
      } catch (_) {}
    }
    if (keyId.isEmpty) return null;
    final refresh = await _secure.read(key: '$_kMatrixRefreshKeyPrefix$keyId');
    if (refresh == null || refresh.isEmpty) return null;
    final homeserver = Environment.matrixHomeserverUrl;
    if (homeserver.isEmpty) return null;
    final uri = Uri.parse('$homeserver/_matrix/client/v3/refresh');
    try {
      final body = jsonEncode({'refresh_token': refresh});
      final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: body).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final js = jsonDecode(res.body) as Map<String, dynamic>;
        final newAccess = js['access_token'] as String?;
        final newRefresh = js['refresh_token'] as String?;
        if (newAccess != null && newAccess.isNotEmpty) {
          await _secure.write(key: '$_kMatrixTokenKeyPrefix$keyId', value: newAccess);
          if (newRefresh != null && newRefresh.isNotEmpty) {
            await _secure.write(key: '$_kMatrixRefreshKeyPrefix$keyId', value: newRefresh);
          }
          return newAccess;
        }
      }
      // On 401 or other client errors, clear refresh to force re-login
      if (res.statusCode >= 400 && res.statusCode < 500) {
        await _secure.delete(key: '$_kMatrixRefreshKeyPrefix$keyId');
        await _secure.delete(key: '$_kMatrixTokenKeyPrefix$keyId');
      }
    } catch (e) {
      _logger.debug('Ошибка обновления токена: $e');
    }
    return null;
  }

  /// Retrieve stored Matrix access token for given app user id (or current user if null)
  Future<String?> getMatrixTokenForUser({String? appUserId}) async {
    // Прежде всего ищем Aegis-токен
    if (_aegis.token != null) return _aegis.token;

    // Primary source: ChatMatrixService stores token globally.
    await _matrixService.init();
    final direct = await _secure.read(key: _kChatMatrixAccessTokenKey);
    if (direct != null && direct.isNotEmpty) return direct;

    // Backward-compatible fallback: per-user storage (older logic).
    String? keyId = appUserId;
    if (keyId == null || keyId.isEmpty) {
      keyId = await _matrixService.getCurrentUserId();
    }
    if (keyId != null && keyId.isNotEmpty) {
      final token = await _secure.read(key: '$_kMatrixTokenKeyPrefix$keyId');
      if (token != null && token.isNotEmpty) return token;
    }

    // If no access token, try refresh (best-effort) and re-read.
    final refreshed = await tryRefreshMatrixToken(appUserId: keyId);
    if (refreshed != null && refreshed.isNotEmpty) return refreshed;
    return null;
  }

  /// Best-effort refresh of Matrix access token.
  /// Returns new access token on success, otherwise null.
  Future<String?> tryRefreshMatrixToken({String? appUserId}) async {
    // Prefer ChatMatrixService refresh token (global key), fallback to per-user refresh.
    final globalRefresh = await _secure.read(key: _kChatMatrixRefreshTokenKey);
    if (globalRefresh != null && globalRefresh.isNotEmpty) {
      try {
        await _matrixService.refreshAccessToken(refreshToken: globalRefresh);
        final after = await _secure.read(key: _kChatMatrixAccessTokenKey);
        if (after != null && after.isNotEmpty) return after;
      } catch (_) {
        // Non-fatal: fall back to per-user refresh path.
      }
    }
    return refreshMatrixTokenForUser(appUserId: appUserId);
  }

  /// Exchange an SSO/login token (returned by Synapse after OIDC) for a Matrix session.
  /// This calls POST /_matrix/client/v3/login with type 'm.login.token'.
  Future<void> loginWithSsoToken(String token) async {
    final homeserver = Environment.matrixHomeserverUrl;
    if (homeserver.isEmpty) throw Exception('Не настроен Matrix homeserver');
    var base = homeserver.trim();
    if (!base.startsWith('http://') && !base.startsWith('https://')) base = 'https://$base';
    base = base.replaceAll(RegExp(r'/$'), '');
    final uri = Uri.parse('$base/_matrix/client/v3/login');
    final body = jsonEncode({'type': 'm.login.token', 'token': token});
    final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: body).timeout(const Duration(seconds: 15));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Ошибка обмена SSO токена ${res.statusCode}: ${res.body}');
    }
    final js = jsonDecode(res.body) as Map<String, dynamic>;
    final tokenResp = js['access_token'] as String?;
    final refresh = js['refresh_token'] as String?;
    final deviceId = js['device_id'] as String?;
    final userId = js['user_id'] as String?;
    if (tokenResp == null || userId == null) throw Exception('В ответе SSO отсутствует токен или user_id');
    String keyId = userId;
    try {
      final me = await MatrixService().getCurrentUserId();
      if (me != null && me.isNotEmpty) keyId = me;
    } catch (e) {
      _logger.debug('Не удалось получить текущий userId: $e');
    }
    await _secure.write(key: '$_kMatrixTokenKeyPrefix$keyId', value: tokenResp);
    try { 
      await MatrixService.setCurrentUserId(userId); 
    } catch (e) {
      _logger.debug('Не удалось сохранить userId: $e');
    }
    if (refresh != null && refresh.isNotEmpty) await _secure.write(key: '$_kMatrixRefreshKeyPrefix$keyId', value: refresh);
    if (deviceId != null && deviceId.isNotEmpty) await _secure.write(key: '$_kMatrixDeviceIdPrefix$keyId', value: deviceId);
  }

  /// Return current application user id from Matrix service.
  Future<String?> getCurrentUserId() async {
    // В первую очередь возвращаем Aegis-пользователя
    if (_aegis.username != null) return _aegis.username;
    return await _matrixService.getCurrentUserId();
  }

  /// Clear stored Matrix token for current app user (sign out)
  Future<void> clearMatrixTokenForCurrentUser() async {
    try {
      final me = await MatrixService().getCurrentUserId();
      if (me != null) await _secure.delete(key: '$_kMatrixTokenKeyPrefix$me');
    } catch (e) {
      _logger.debug('Не удалось очистить токен: $e');
    }
  }

  Future<dynamic> sendPhoneToken(String phone) async {
    return await MatrixService.createPhoneToken(phone);
  }

  /// Send a login token to email (passwordless login / verification)
  Future<dynamic> sendEmailToken(String email) async {
    // Prefer Appwrite SDK if available, else try Matrix facade (if implemented)
    if (accountClient != null) {
      try {
        // Appwrite SDK: try to create an email session (passwordless) if supported
        // Fallback: request passwordless session or magic URL.
        if (accountClient.createEmailSession != null) {
          final tokenResp = await accountClient.createEmailSession(email: email);
          return tokenResp;
        }
      } catch (_) {}
    }

    // Try Matrix-level path (server-provided endpoint must implement this)
      try {
        final res = await MatrixService.createEmailSession(email, '');
        return res;
      } catch (e) {
        throw Exception('Email token delivery not implemented; configure MATRIX_EMAIL_TOKEN_ENDPOINT. $e');
      }
  }

  // Request TOTP setup and return secret/otpauth URI
  Future<Map<String,dynamic>> requestTotpSetup() async {
    if (!Environment.useMatrix) throw Exception('Matrix is not enabled');
    final endpoint = Environment.matrixHomeserverUrl;
    if (endpoint.isEmpty) throw Exception('TOTP endpoint not configured');
    final uri = Uri.parse(endpoint);
    final res = await http.post(uri, headers: {'Content-Type': 'application/json'});
    if (res.statusCode >= 200 && res.statusCode < 300) return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('Ошибка requestTotpSetup ${res.statusCode}: ${res.body}');
  }

  // Verify the TOTP token and enable/disable TOTP on server-side
  Future<void> verifyTotpSetup(String code, {bool disable = false}) async {
    if (!Environment.useMatrix) throw Exception('Matrix is not enabled');
    final endpoint = Environment.matrixHomeserverUrl;
    if (endpoint.isEmpty) throw Exception('TOTP verify endpoint not configured');
    final uri = Uri.parse(endpoint);
    final body = jsonEncode({'code': code, 'action': disable ? 'disable' : 'enable'});
    final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: body);
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    throw Exception('Ошибка verifyTotpSetup ${res.statusCode}: ${res.body}');
  }

  // For session creation from token (phone flow), ensure JWT saved after session creation
  Future<void> createSessionFromToken(String userId, String secret) async {
    // When using Matrix, prefer token-based login: if the token is a Matrix
    // login token that Synapse recognizes for m.login.token, exchange it here
    // and save the returned access token.
    if (Environment.useMatrix) {
      if (secret.isEmpty) throw Exception('Пустой токен');
      await loginWithSsoToken(secret);
      return;
    }

    if (accountClient != null) {
      await accountClient.createPhoneSession(userId: userId, secret: secret);
      final jwtResp = await accountClient.createJWT();
      final jwt = jwtResp is Map && jwtResp.containsKey('jwt') ? jwtResp['jwt'] as String : null;
      if (jwt == null) throw Exception('Не удалось получить JWT после создания сессии');
      await MatrixService.saveJwt(jwt);
      return;
    }

    // REST fallback - create session and then jwt
    final base = MatrixService.v1Endpoint();
    final uri = Uri.parse('$base/account/sessions/token');
    final resp = await http.post(uri,
        headers: {'X-Appwrite-Project': Environment.appwriteProjectId, 'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'secret': secret}));
    if (resp.statusCode < 200 || resp.statusCode >= 300) throw Exception('Не удалось создать сессию: ${resp.statusCode} ${resp.body}');
    final jwtUri = Uri.parse('$base/account/jwt');
    final receivedCookie = resp.headers['set-cookie'];
    final jwtHeaders = <String, String>{'X-Appwrite-Project': Environment.appwriteProjectId};
    if (receivedCookie != null && receivedCookie.isNotEmpty) jwtHeaders['cookie'] = receivedCookie;
    final jwtResp = await http.post(jwtUri, headers: jwtHeaders);
    if (jwtResp.statusCode < 200 || jwtResp.statusCode >= 300) {
      throw Exception('Не удалось создать JWT: ${jwtResp.statusCode} ${jwtResp.body}');
    }
    final jwtJson = jsonDecode(jwtResp.body) as Map<String, dynamic>;
    final jwt = jwtJson['jwt'] as String?;
    if (jwt == null) throw Exception('JWT отсутствует в ответе');
    if (receivedCookie != null && receivedCookie.isNotEmpty) await MatrixService.saveSessionCookie(receivedCookie);
    await MatrixService.saveJwt(jwt);
  }

  /// Attempt to restore previous session from stored token.
  /// Returns true if session was successfully restored, false otherwise.
  Future<bool> restoreSessionFromToken() async {
    // Сначала пробуем Aegis
    try {
      final restored = await _aegis.restoreSession();
      if (restored) {
        _logger.info('✓ Aegis сессия восстановлена');
        return true;
      }
    } catch (e) {
      _logger.debug('Не удалось восстановить Aegis-сессию: $e');
    }
    // Фолбэк на Matrix
    try {
      final userId = await MatrixService().getCurrentUserId();
      if (userId == null || userId.isEmpty) return false;
      final token = await getMatrixTokenForUser(appUserId: userId);
      if (token == null || token.isEmpty) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  // Backwards-compatible method names for Riverpod providers
  Future<void> login(String identifier, String password) async {
    return await loginUser(identifier, password);
  }

  Future<void> logout() async {
    return await signOut();
  }
}
