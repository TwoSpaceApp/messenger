import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/payloads/helpers.dart';

/// Handshake request payload
class HandshakeRequestPayload {
  HandshakeRequestPayload({
    required this.publicKey,
    required this.clientVersion,
    required this.appId,
    required this.appHash,
  });

  factory HandshakeRequestPayload.fromJson(Map<String, dynamic> json) =>
      HandshakeRequestPayload(
        publicKey: json["PublicKey"] as String,
        clientVersion: json["ClientVersion"] as int,
        appId: json["AppId"] as int,
        appHash: json["AppHash"] as String,
      );
  final String publicKey;
  final int clientVersion;
  final int appId;
  final String appHash;

  Map<String, dynamic> toJson() => {
    'PublicKey': publicKey,
    'ClientVersion': clientVersion,
    'AppId': appId,
    'AppHash': appHash,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Registration request payload
class RegistrationRequest {
  RegistrationRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.publicKey,
  });

  factory RegistrationRequest.fromJson(Map<String, dynamic> json) =>
      RegistrationRequest(
        username: json["Username"] as String,
        email: (json["Email"] ?? json["Mail"]) as String,
        password: json["Password"] as String,
        publicKey: (json["PublicKey"] ?? json["PublicKeyLegacy"]) as String,
      );
  final String username;
  final String email;
  final String password;
  final String publicKey;

  Map<String, dynamic> toJson() => {
    'Username': username,
    'Email': email,
    'Mail': email,
    'Password': password,
    'PublicKey': publicKey,
    'PublicKeyLegacy': publicKey,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Registration response payload
class RegistrationResponse {
  RegistrationResponse({required this.success, this.message, this.user});

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) =>
      RegistrationResponse(
        success: json["Success"] as bool,
        message: json["Message"] as String?,
        user: json["User"] != null
            ? RegisteredUserInfo.fromJson(json["User"] as Map<String, dynamic>)
            : null,
      );

  factory RegistrationResponse.fromBytes(List<int> bytes) {
    return RegistrationResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final String? message;
  final RegisteredUserInfo? user;

  Map<String, dynamic> toJson() => {
    'Success': success,
    if (message != null) 'Message': message,
    if (user != null) 'User': user!.toJson(),
  };
}

/// Minimal registered user info returned by the server
class RegisteredUserInfo {
  RegisteredUserInfo({required this.id, required this.username});

  factory RegisteredUserInfo.fromJson(Map<String, dynamic> json) =>
      RegisteredUserInfo(
        id: parseIntValue(json["Id"], fieldName: "RegisteredUserInfo.Id"),
        username: json["Username"] as String,
      );
  final int id;
  final String username;

  Map<String, dynamic> toJson() => {'Id': id, 'Username': username};
}

/// Authentication response payload
class AuthResponse {
  AuthResponse({
    required this.success,
    this.userId,
    this.username,
    this.sessionToken,
    this.error,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    success: json["Success"] as bool,
    userId: parseNullableIntValue(json["UserId"]),
    username: json["Username"] as String?,
    sessionToken: json["SessionToken"] as String?,
    error: json["Error"] as String?,
  );

  factory AuthResponse.fromBytes(List<int> bytes) {
    return AuthResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final int? userId;
  final String? username;
  final String? sessionToken;
  final String? error;

  Map<String, dynamic> toJson() => {
    'Success': success,
    if (userId != null) 'UserId': userId,
    if (username != null) 'Username': username,
    if (sessionToken != null) 'SessionToken': sessionToken,
    if (error != null) 'Error': error,
  };
}
