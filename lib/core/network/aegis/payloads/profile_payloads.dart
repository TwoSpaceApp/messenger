import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/payloads/helpers.dart';

/// Profile data returned by the server
class ProfileData {
  ProfileData({
    required this.id,
    required this.username,
    this.createdAt,
    this.displayName,
    this.avatarUrl,
    this.avatars = const <ProfileAvatarData>[],
    this.presenceStatus,
    this.bio,
    this.location,
    this.birthDate,
    this.email,
    this.lastSeenAt,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
    id: parseIntValue(json["Id"], fieldName: "ProfileData.Id"),
    username: json["Username"] as String,
    displayName: json["DisplayName"] as String?,
    avatarUrl: json["AvatarUrl"] as String?,
    avatars: (json["Avatars"] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => ProfileAvatarData.fromJson(item as Map<String, dynamic>))
        .toList(),
    presenceStatus: json["PresenceStatus"] as String?,
    bio: json["Bio"] as String?,
    location: json["Location"] as String?,
    birthDate: json["BirthDate"]?.toString(),
    email: json["Email"] as String?,
    createdAt: parseNullableDateTimeValue(json["CreatedAt"]),
    lastSeenAt: parseNullableDateTimeValue(json["LastSeenAt"]),
  );
  final int id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final List<ProfileAvatarData> avatars;
  final String? presenceStatus;
  final String? bio;
  final String? location;
  final String? birthDate;
  final String? email;
  final DateTime? createdAt;
  final DateTime? lastSeenAt;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Username': username,
    if (displayName != null) 'DisplayName': displayName,
    if (avatarUrl != null) 'AvatarUrl': avatarUrl,
    'Avatars': avatars.map((item) => item.toJson()).toList(),
    if (presenceStatus != null) 'PresenceStatus': presenceStatus,
    if (bio != null) 'Bio': bio,
    if (location != null) 'Location': location,
    if (birthDate != null) 'BirthDate': birthDate,
    if (email != null) 'Email': email,
    if (createdAt != null) 'CreatedAt': createdAt!.toIso8601String(),
    if (lastSeenAt != null) 'LastSeenAt': lastSeenAt!.toIso8601String(),
  };
}

class ProfileAvatarData {
  ProfileAvatarData({
    required this.id,
    required this.avatarUrl,
    required this.isPrimary,
    required this.createdAt,
  });

  factory ProfileAvatarData.fromJson(Map<String, dynamic> json) =>
      ProfileAvatarData(
        id: json["Id"] as int,
        avatarUrl: json["AvatarUrl"] as String,
        isPrimary: json["IsPrimary"] as bool? ?? false,
        createdAt: parseNullableDateTimeValue(json["CreatedAt"]) ??
            DateTime.now().toUtc(),
      );
  final int id;
  final String avatarUrl;
  final bool isPrimary;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'AvatarUrl': avatarUrl,
    'IsPrimary': isPrimary,
    'CreatedAt': createdAt.toIso8601String(),
  };
}

class ProfileAvatarAddRequest {
  ProfileAvatarAddRequest(
      {required this.avatarUrl, this.makePrimary = false});
  final String avatarUrl;
  final bool makePrimary;

  Map<String, dynamic> toJson() => {
    'AvatarUrl': avatarUrl,
    'MakePrimary': makePrimary,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

class ProfileAvatarDeleteRequest {
  ProfileAvatarDeleteRequest({required this.avatarId});
  final int avatarId;

  Map<String, dynamic> toJson() => {'AvatarId': avatarId};

  List<int> toBytes() => msgpack.serialize(toJson());
}

class ProfileAvatarSetPrimaryRequest {
  ProfileAvatarSetPrimaryRequest({required this.avatarId});
  final int avatarId;

  Map<String, dynamic> toJson() => {'AvatarId': avatarId};

  List<int> toBytes() => msgpack.serialize(toJson());
}

class ProfileAvatarMutationResponse {
  ProfileAvatarMutationResponse({
    required this.success,
    this.message,
    this.avatar,
  });

  factory ProfileAvatarMutationResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      ProfileAvatarMutationResponse(
        success: json["Success"] as bool,
        message: json["Message"] as String?,
        avatar: json["Avatar"] != null
            ? ProfileAvatarData.fromJson(
                json["Avatar"] as Map<String, dynamic>)
            : null,
      );

  factory ProfileAvatarMutationResponse.fromBytes(List<int> bytes) {
    return ProfileAvatarMutationResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final String? message;
  final ProfileAvatarData? avatar;
}

class ProfileAvatarListResponse {
  ProfileAvatarListResponse({
    required this.success,
    required this.avatars,
    this.message,
  });

  factory ProfileAvatarListResponse.fromJson(Map<String, dynamic> json) =>
      ProfileAvatarListResponse(
        success: json["Success"] as bool,
        avatars: (json["Avatars"] as List<dynamic>? ?? const <dynamic>[])
            .map(
              (item) =>
                  ProfileAvatarData.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        message: json["Message"] as String?,
      );

  factory ProfileAvatarListResponse.fromBytes(List<int> bytes) {
    return ProfileAvatarListResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final List<ProfileAvatarData> avatars;
  final String? message;
}

/// Request to update the authenticated user's profile
class ProfileUpdateRequest {
  ProfileUpdateRequest({
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.username,
    this.location,
    this.birthDate,
  });
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String? username;
  final String? location;
  final String? birthDate;

  Map<String, dynamic> toJson() => {
    if (displayName != null) 'DisplayName': displayName,
    if (avatarUrl != null) 'AvatarUrl': avatarUrl,
    if (bio != null) 'Bio': bio,
    if (username != null) 'Username': username,
    if (location != null) 'Location': location,
    if (birthDate != null) 'BirthDate': birthDate,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Response to a profile update
class ProfileUpdateResponse {
  ProfileUpdateResponse({required this.success, this.message, this.profile});

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) =>
      ProfileUpdateResponse(
        success: json["Success"] as bool,
        message: json["Message"] as String?,
        profile: json["Profile"] != null
            ? ProfileData.fromJson(json["Profile"] as Map<String, dynamic>)
            : null,
      );

  factory ProfileUpdateResponse.fromBytes(List<int> bytes) {
    return ProfileUpdateResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final String? message;
  final ProfileData? profile;
}

/// Request to get a user's profile
class ProfileGetRequest {
  ProfileGetRequest({this.userId, this.username});
  final int? userId;
  final String? username;

  Map<String, dynamic> toJson() => {
    if (userId != null) 'UserId': userId,
    if (username != null) 'Username': username,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Response to a profile get request
class ProfileGetResponse {
  ProfileGetResponse({required this.success, this.profile, this.message});

  factory ProfileGetResponse.fromJson(Map<String, dynamic> json) =>
      ProfileGetResponse(
        success: json["Success"] as bool,
        profile: json["Profile"] != null
            ? ProfileData.fromJson(json["Profile"] as Map<String, dynamic>)
            : null,
        message: json["Message"] as String?,
      );

  factory ProfileGetResponse.fromBytes(List<int> bytes) {
    return ProfileGetResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final ProfileData? profile;
  final String? message;
}
