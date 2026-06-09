import 'package:two_space_app/core/network/aegis/client/aegis_client_base.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';

mixin AegisMembershipMixin on AegisClientBase {

  Future<MemberRoleUpdateResponse> updateMemberRole({
    required String scope,
    required int targetId,
    required int targetUserId,
    required int newRole,
  }) async {
    requireAuthenticated();

    final request = MemberRoleUpdateRequest(
      scope: scope,
      targetId: targetId,
      targetUserId: targetUserId,
      newRole: newRole,
    );

    final msg = Message.withType(
      MessageType.memberRoleUpdate,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.memberRoleUpdateResponse},
    );
    return MemberRoleUpdateResponse.fromBytes(response.payload);
  }

  Future<MemberRoleUpdateResponse> updateChannelMemberRole({
    required int channelId,
    required int targetUserId,
    required MemberRole newRole,
  }) {
    return updateMemberRole(
      scope: RoomScope.channel.value,
      targetId: channelId,
      targetUserId: targetUserId,
      newRole: newRole.value,
    );
  }

  Future<MemberRoleUpdateResponse> updateGroupMemberRole({
    required int groupId,
    required int targetUserId,
    required MemberRole newRole,
  }) {
    return updateMemberRole(
      scope: RoomScope.group.value,
      targetId: groupId,
      targetUserId: targetUserId,
      newRole: newRole.value,
    );
  }

  Future<MemberPermissionUpdateResponse> updateMemberPermissions({
    required String scope,
    required int targetId,
    required int targetUserId,
    bool? canSendMessages,
    bool? canDeleteOthersMessages,
    bool? canEditInfo,
    bool? canInviteUsers,
    bool? canRemoveUsers,
    bool? canPinMessages,
    bool? canManageRoles,
  }) async {
    requireAuthenticated();

    final request = MemberPermissionUpdateRequest(
      scope: scope,
      targetId: targetId,
      targetUserId: targetUserId,
      canSendMessages: canSendMessages,
      canDeleteOthersMessages: canDeleteOthersMessages,
      canEditInfo: canEditInfo,
      canInviteUsers: canInviteUsers,
      canRemoveUsers: canRemoveUsers,
      canPinMessages: canPinMessages,
      canManageRoles: canManageRoles,
    );

    final msg = Message.withType(
      MessageType.memberPermissionUpdate,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.memberPermissionUpdateResponse},
    );
    return MemberPermissionUpdateResponse.fromBytes(response.payload);
  }

  Future<MemberPermissionUpdateResponse> updateChannelMemberPermissions({
    required int channelId,
    required int targetUserId,
    bool? canSendMessages,
    bool? canDeleteOthersMessages,
    bool? canEditInfo,
    bool? canInviteUsers,
    bool? canRemoveUsers,
    bool? canPinMessages,
    bool? canManageRoles,
  }) {
    return updateMemberPermissions(
      scope: RoomScope.channel.value,
      targetId: channelId,
      targetUserId: targetUserId,
      canSendMessages: canSendMessages,
      canDeleteOthersMessages: canDeleteOthersMessages,
      canEditInfo: canEditInfo,
      canInviteUsers: canInviteUsers,
      canRemoveUsers: canRemoveUsers,
      canPinMessages: canPinMessages,
      canManageRoles: canManageRoles,
    );
  }

  Future<MemberPermissionUpdateResponse> updateGroupMemberPermissions({
    required int groupId,
    required int targetUserId,
    bool? canSendMessages,
    bool? canDeleteOthersMessages,
    bool? canEditInfo,
    bool? canInviteUsers,
    bool? canRemoveUsers,
    bool? canPinMessages,
    bool? canManageRoles,
  }) {
    return updateMemberPermissions(
      scope: RoomScope.group.value,
      targetId: groupId,
      targetUserId: targetUserId,
      canSendMessages: canSendMessages,
      canDeleteOthersMessages: canDeleteOthersMessages,
      canEditInfo: canEditInfo,
      canInviteUsers: canInviteUsers,
      canRemoveUsers: canRemoveUsers,
      canPinMessages: canPinMessages,
      canManageRoles: canManageRoles,
    );
  }
}
