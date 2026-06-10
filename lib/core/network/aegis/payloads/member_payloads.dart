import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/payloads/helpers.dart';

/// Member summary for listings
class MemberSummary {
  MemberSummary({
    required this.userId,
    required this.username,
    required this.role,
    required this.joinedAt,
    this.canSendMessages = true,
    this.canDeleteOthersMessages = false,
    this.canPinMessages = false,
    this.canManageRoles = false,
  });

  factory MemberSummary.fromJson(Map<String, dynamic> json) => MemberSummary(
    userId:
        parseIntValue(json["UserId"], fieldName: "MemberSummary.UserId"),
    username: json["Username"] as String,
    role: json["Role"] as String,
    joinedAt: parseNullableDateTimeValue(json["JoinedAt"]) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    canSendMessages: json["CanSendMessages"] as bool? ?? true,
    canDeleteOthersMessages:
        json["CanDeleteOthersMessages"] as bool? ?? false,
    canPinMessages: json["CanPinMessages"] as bool? ?? false,
    canManageRoles: json["CanManageRoles"] as bool? ?? false,
  );
  final int userId;
  final String username;
  final String role;
  final DateTime joinedAt;
  final bool canSendMessages;
  final bool canDeleteOthersMessages;
  final bool canPinMessages;
  final bool canManageRoles;
}

/// Role update request for channel/group memberships.
class MemberRoleUpdateRequest {
  MemberRoleUpdateRequest({
    required this.scope,
    required this.targetId,
    required this.targetUserId,
    required this.newRole,
  });
  final String scope;
  final int targetId;
  final int targetUserId;
  final int newRole;

  Map<String, dynamic> toJson() => {
    'Scope': scope,
    'TargetId': targetId,
    'TargetUserId': targetUserId,
    'NewRole': newRole,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

class MemberRoleUpdateResponse {
  MemberRoleUpdateResponse({required this.success, this.message});

  factory MemberRoleUpdateResponse.fromJson(Map<String, dynamic> json) =>
      MemberRoleUpdateResponse(
        success: json["Success"] as bool? ?? false,
        message: json["Message"] as String?,
      );

  factory MemberRoleUpdateResponse.fromBytes(List<int> bytes) =>
      MemberRoleUpdateResponse.fromJson(decodePayloadMap(bytes));
  final bool success;
  final String? message;
}

/// Permission update request for channel/group memberships.
class MemberPermissionUpdateRequest {
  MemberPermissionUpdateRequest({
    required this.scope,
    required this.targetId,
    required this.targetUserId,
    this.canSendMessages,
    this.canDeleteOthersMessages,
    this.canEditInfo,
    this.canInviteUsers,
    this.canRemoveUsers,
    this.canPinMessages,
    this.canManageRoles,
  });
  final String scope;
  final int targetId;
  final int targetUserId;
  final bool? canSendMessages;
  final bool? canDeleteOthersMessages;
  final bool? canEditInfo;
  final bool? canInviteUsers;
  final bool? canRemoveUsers;
  final bool? canPinMessages;
  final bool? canManageRoles;

  Map<String, dynamic> toJson() => {
    'Scope': scope,
    'TargetId': targetId,
    'TargetUserId': targetUserId,
    if (canSendMessages != null) 'CanSendMessages': canSendMessages,
    if (canDeleteOthersMessages != null)
      'CanDeleteOthersMessages': canDeleteOthersMessages,
    if (canEditInfo != null) 'CanEditInfo': canEditInfo,
    if (canInviteUsers != null) 'CanInviteUsers': canInviteUsers,
    if (canRemoveUsers != null) 'CanRemoveUsers': canRemoveUsers,
    if (canPinMessages != null) 'CanPinMessages': canPinMessages,
    if (canManageRoles != null) 'CanManageRoles': canManageRoles,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

class MemberPermissionUpdateResponse {
  MemberPermissionUpdateResponse({required this.success, this.message});

  factory MemberPermissionUpdateResponse.fromJson(
    Map<String, dynamic> json,
  ) =>
      MemberPermissionUpdateResponse(
        success: json["Success"] as bool? ?? false,
        message: json["Message"] as String?,
      );

  factory MemberPermissionUpdateResponse.fromBytes(List<int> bytes) =>
      MemberPermissionUpdateResponse.fromJson(decodePayloadMap(bytes));
  final bool success;
  final String? message;
}
