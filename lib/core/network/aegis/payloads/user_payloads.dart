import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/payloads/helpers.dart';

/// User search request payload
class UserSearchRequest {
  UserSearchRequest({required this.query, this.limit = 20});

  factory UserSearchRequest.fromJson(Map<String, dynamic> json) =>
      UserSearchRequest(
        query: json["Query"] as String,
        limit: json["Limit"] as int? ?? 20,
      );
  final String query;
  final int limit;

  Map<String, dynamic> toJson() => {'Query': query, 'Limit': limit};

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// User search response payload
class UserSearchResponse {
  UserSearchResponse({
    required this.success,
    required this.users,
    this.message,
  });

  factory UserSearchResponse.fromJson(Map<String, dynamic> json) =>
      UserSearchResponse(
        success: json["Success"] as bool,
        users: (json["Users"] as List<dynamic>)
            .map((u) => UserSearchResult.fromJson(u as Map<String, dynamic>))
            .toList(),
        message: json["Message"] as String?,
      );

  factory UserSearchResponse.fromBytes(List<int> bytes) {
    return UserSearchResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final List<UserSearchResult> users;
  final String? message;

  Map<String, dynamic> toJson() => {
    'Success': success,
    'Users': users.map((u) => u.toJson()).toList(),
    if (message != null) 'Message': message,
  };
}

/// User search result item
class UserSearchResult {
  UserSearchResult({
    required this.id,
    required this.username,
    this.email,
    this.presenceStatus,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) =>
      UserSearchResult(
        id: json["Id"] as int,
        username: json["Username"] as String,
        email: json["Email"] as String?,
        presenceStatus: json["PresenceStatus"] as String?,
      );
  final int id;
  final String username;
  final String? email;
  final String? presenceStatus;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Username': username,
    if (email != null) 'Email': email,
    if (presenceStatus != null) 'PresenceStatus': presenceStatus,
  };
}

/// User presence update payload.
class UserPresenceUpdateRequest {
  UserPresenceUpdateRequest({required this.isOnline, this.clientTimestamp});
  final bool isOnline;
  final DateTime? clientTimestamp;

  Map<String, dynamic> toJson() => {
    'IsOnline': isOnline,
    if (clientTimestamp != null)
      'ClientTimestamp': clientTimestamp!.toUtc().toIso8601String(),
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// User entity
class User {
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.publicKey,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.identityKeyFingerprint,
    this.lastSeenAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["Id"] as int,
    username: json["Username"] as String,
    email: json["Email"] as String,
    publicKey: json["PublicKey"] as String,
    identityKeyFingerprint: json["IdentityKeyFingerprint"] as String?,
    isActive: json["IsActive"] as bool,
    createdAt:
        parseNullableDateTimeValue(json["CreatedAt"]) ?? DateTime.now().toUtc(),
    updatedAt:
        parseNullableDateTimeValue(json["UpdatedAt"]) ?? DateTime.now().toUtc(),
    lastSeenAt: parseNullableDateTimeValue(json["LastSeenAt"]),
  );
  final int id;
  final String username;
  final String email;
  final String publicKey;
  final String? identityKeyFingerprint;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSeenAt;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Username': username,
    'Email': email,
    'PublicKey': publicKey,
    if (identityKeyFingerprint != null)
      'IdentityKeyFingerprint': identityKeyFingerprint,
    'IsActive': isActive,
    'CreatedAt': createdAt.toIso8601String(),
    'UpdatedAt': updatedAt.toIso8601String(),
    if (lastSeenAt != null) 'LastSeenAt': lastSeenAt!.toIso8601String(),
  };
}
