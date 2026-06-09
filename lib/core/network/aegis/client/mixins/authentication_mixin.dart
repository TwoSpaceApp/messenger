import 'dart:convert';

import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/client/aegis_client_base.dart';
import 'package:two_space_app/core/network/aegis/logger.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';

mixin AegisAuthenticationMixin on AegisClientBase {

  Future<void> login(
    String username,
    String password, {
    String clientInfo = 'aegis-dart-client',
    String? twoFactorCode,
    String? recoveryPhrase,
  }) async {
    requireConnected();
    final payload = msgpack.serialize({
      'Username': username,
      'Password': password,
      'ClientInfo': clientInfo,
      ...?twoFactorCode == null
          ? null
          : <String, String>{'TwoFactorCode': twoFactorCode},
      ...?recoveryPhrase == null
          ? null
          : <String, String>{'RecoveryPhrase': recoveryPhrase},
    });
    await _doAuthenticate(payload);
  }

  Future<void> loginWithToken(String token) async {
    requireConnected();
    final payload = msgpack.serialize({
      'Token': token,
      'ClientInfo': 'aegis-dart-client',
    });
    await _doAuthenticate(payload);
  }

  Future<void> authenticate(dynamic authPayloadOrToken) async {
    requireConnected();
    List<int> payload;
    if (authPayloadOrToken is List<int>) {
      payload = authPayloadOrToken;
    } else if (authPayloadOrToken is String &&
        authPayloadOrToken.trim().startsWith('{')) {
      payload = msgpack.serialize(jsonDecode(authPayloadOrToken));
    } else {
      payload = msgpack.serialize({
        'Token': authPayloadOrToken,
        'ClientInfo': 'aegis-dart-client',
      });
    }
    await _doAuthenticate(payload);
  }

  Future<void> _doAuthenticate(List<int> payload) async {
    final msg = Message.withType(MessageType.auth, payload);
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.auth, MessageType.ack},
    );

    final authResponse = AuthResponse.fromBytes(response.payload);
    AegisLogger.info(
      'Auth response success=${authResponse.success} '
      'userId=${authResponse.userId} username=${authResponse.username} '
      'error=${authResponse.error}',
    );
    if (!authResponse.success) {
      final error = authResponse.error;
      throw Exception(
        'Authentication failed${error != null && error.isNotEmpty ? ': $error' : ''}',
      );
    }

    applyAuthResponse(authResponse);
    await publishPresence(isOnline: true);
  }

  Future<AuthResponse> authenticateWithPassword({
    required String username,
    required String password,
    String clientInfo = 'aegis-dart-client',
    String? twoFactorCode,
    String? recoveryPhrase,
  }) async {
    requireConnected();
    final payload = msgpack.serialize({
      'Username': username,
      'Password': password,
      'ClientInfo': clientInfo,
      ...?twoFactorCode == null
          ? null
          : <String, String>{'TwoFactorCode': twoFactorCode},
      ...?recoveryPhrase == null
          ? null
          : <String, String>{'RecoveryPhrase': recoveryPhrase},
    });
    final msg = Message.withType(MessageType.auth, payload);
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.auth, MessageType.ack},
    );

    final authResponse = AuthResponse.fromBytes(response.payload);
    if (!authResponse.success) {
      final error = authResponse.error;
      throw Exception(
        'Authentication failed${error != null && error.isNotEmpty ? ': $error' : ''}',
      );
    }

    applyAuthResponse(authResponse);
    await publishPresence(isOnline: true);

    return AuthResponse(
      success: authResponse.success,
      userId: authResponse.userId,
      username: authResponse.username,
      sessionToken: authResponse.sessionToken,
      error: authResponse.error,
    );
  }

  Future<RegistrationResponse> register(
    String username,
    String email,
    String password,
    String publicKey,
  ) async {
    requireConnected();

    final request = RegistrationRequest(
      username: username,
      email: email,
      password: password,
      publicKey: publicKey,
    );

    final msg = Message.withType(MessageType.register, request.toBytes());
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.registerResponse},
    );
    return RegistrationResponse.fromBytes(response.payload);
  }
}
