import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/payloads/helpers.dart';

class ProfilesBatchRequest {
  ProfilesBatchRequest({required this.profileIds});

  factory ProfilesBatchRequest.fromJson(Map<String, dynamic> json) =>
      ProfilesBatchRequest(
        profileIds: (json["ProfileIds"] as List<dynamic>? ?? [])
            .map((id) => (id as num).toInt())
            .toList(),
      );
  final List<int> profileIds;

  Map<String, dynamic> toJson() => {'ProfileIds': profileIds};
  List<int> toBytes() => msgpack.serialize(toJson());
}

class ProfilesBatchResponse {
  ProfilesBatchResponse({
    required this.success,
    this.profiles = const [],
    this.message,
  });

  factory ProfilesBatchResponse.fromJson(Map<String, dynamic> json) =>
      ProfilesBatchResponse(
        success: json["Success"] as bool? ?? false,
        profiles: (json["Profiles"] as List<dynamic>? ?? [])
            .map((p) => UserProfileItem.fromJson(p as Map<String, dynamic>))
            .toList(),
        message: json["Message"] as String?,
      );

  factory ProfilesBatchResponse.fromBytes(List<int> bytes) =>
      ProfilesBatchResponse.fromJson(decodePayloadMap(bytes));
  final bool success;
  final List<UserProfileItem> profiles;
  final String? message;
}

class UserProfileItem {
  UserProfileItem({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.isOnline = false,
    this.lastSeenAt,
  });

  factory UserProfileItem.fromJson(Map<String, dynamic> json) =>
      UserProfileItem(
        userId: (json["UserId"] as num? ?? 0).toInt(),
        username: json["Username"] as String? ?? "",
        displayName: json["DisplayName"] as String?,
        avatarUrl: json["AvatarUrl"] as String?,
        bio: json["Bio"] as String?,
        isOnline: json["IsOnline"] as bool? ?? false,
        lastSeenAt: parseNullableDateTimeValue(json["LastSeenAt"]),
      );
  final int userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final bool isOnline;
  final DateTime? lastSeenAt;

  Map<String, dynamic> toJson() => {
    'UserId': userId,
    'Username': username,
    if (displayName != null) 'DisplayName': displayName,
    if (avatarUrl != null) 'AvatarUrl': avatarUrl,
    if (bio != null) 'Bio': bio,
    'IsOnline': isOnline,
    if (lastSeenAt != null)
      'LastSeenAt': lastSeenAt!.millisecondsSinceEpoch,
  };
}
