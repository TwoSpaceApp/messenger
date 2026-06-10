import 'package:two_space_app/core/network/aegis/client/aegis_client_base.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';

mixin AegisMessageOpsMixin on AegisClientBase {

  Future<MessageEditResponse> editMessage(
    int messageId,
    String newContent, {
    String scope = 'private',
    int? channelId,
    int? groupId,
  }) async {
    requireAuthenticated();

    final request = MessageEditRequest(
      messageId: messageId,
      newContent: newContent,
      scope: scope,
      channelId: channelId,
      groupId: groupId,
    );

    final msg = Message.withType(MessageType.messageEdit, request.toBytes());
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.messageEditResponse},
    );
    return MessageEditResponse.fromBytes(response.payload);
  }

  Future<MessageEditResponse> editPrivateMessage(
    int messageId,
    String newContent,
  ) {
    return editMessage(
      messageId,
      newContent,
      scope: ChatScope.privateChat.value,
    );
  }

  Future<MessageEditResponse> editChannelMessage(
    int channelId,
    int messageId,
    String newContent,
  ) {
    return editMessage(
      messageId,
      newContent,
      scope: ChatScope.channel.value,
      channelId: channelId,
    );
  }

  Future<MessageEditResponse> editGroupMessage(
    int groupId,
    int messageId,
    String newContent,
  ) {
    return editMessage(
      messageId,
      newContent,
      scope: ChatScope.group.value,
      groupId: groupId,
    );
  }

  Future<MessageDeleteResponse> deleteMessage(
    int messageId, {
    String scope = 'private',
    int? channelId,
    int? groupId,
  }) async {
    requireAuthenticated();

    final request = MessageDeleteRequest(
      messageId: messageId,
      scope: scope,
      channelId: channelId,
      groupId: groupId,
    );

    final msg = Message.withType(MessageType.messageDelete, request.toBytes());
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.messageDeleteResponse},
    );
    return MessageDeleteResponse.fromBytes(response.payload);
  }

  Future<MessageDeleteResponse> deletePrivateMessage(int messageId) {
    return deleteMessage(messageId, scope: ChatScope.privateChat.value);
  }

  Future<MessageDeleteResponse> deleteChannelMessage(
    int channelId,
    int messageId,
  ) {
    return deleteMessage(
      messageId,
      scope: ChatScope.channel.value,
      channelId: channelId,
    );
  }

  Future<MessageDeleteResponse> deleteGroupMessage(
    int groupId,
    int messageId,
  ) {
    return deleteMessage(
      messageId,
      scope: ChatScope.group.value,
      groupId: groupId,
    );
  }
}
