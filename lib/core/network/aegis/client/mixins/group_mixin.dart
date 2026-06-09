import 'dart:convert';
import 'dart:typed_data';

import 'package:two_space_app/core/network/aegis/client/aegis_client_base.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';

mixin AegisGroupMixin on AegisClientBase {

  Future<GroupCreateResponse> createGroup(
    String name, {
    String? description,
  }) async {
    requireAuthenticated();

    final request = GroupCreateRequest(
      name: name,
      description: description,
    );

    final msg = Message.withType(MessageType.groupCreate, request.toBytes());
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.groupCreateResponse},
    );
    return GroupCreateResponse.fromBytes(response.payload);
  }

  Future<GroupEditResponse> updateGroup(
    int groupId, {
    String? name,
    String? description,
    String? avatarUrl,
  }) async {
    requireAuthenticated();

    final request = GroupEditRequest(
      groupId: groupId,
      name: name,
      description: description,
      avatarUrl: avatarUrl,
    );

    final msg = Message.withType(MessageType.groupEdit, request.toBytes());
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.groupEditResponse},
    );
    return GroupEditResponse.fromBytes(response.payload);
  }

  Future<GroupEditResponse> uploadGroupAvatar(
    int groupId,
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    final dataUrl = 'data:$mimeType;base64,${base64Encode(imageBytes)}';
    return updateGroup(groupId, avatarUrl: dataUrl);
  }

  Future<GroupMembersResponse> getGroupMembers(int groupId) async {
    requireAuthenticated();

    final request = GroupMembersRequest(groupId: groupId);
    final msg = Message.withType(
      MessageType.groupMembersRequest,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.groupMembersResponse},
    );
    return GroupMembersResponse.fromBytes(response.payload);
  }

  Future<GroupLeaveResponse> leaveGroup(int groupId) async {
    requireAuthenticated();

    final request = GroupLeaveRequest(groupId: groupId);
    final msg = Message.withType(
      MessageType.groupLeave,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.groupLeave},
    );
    return GroupLeaveResponse.fromBytes(response.payload);
  }
}
