import 'package:two_space_app/core/network/aegis/client/aegis_client_base.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';

mixin AegisTypingMixin on AegisClientBase {

  Future<void> sendTyping({
    required String scope,
    required int targetId,
    required bool isTyping,
    int? toUserId,
  }) async {
    requireAuthenticated();

    final request = UserTypingRequest(
      scope: scope,
      targetId: targetId,
      isTyping: isTyping,
      toUserId: toUserId,
    );
    final msg = Message.withType(MessageType.userTyping, request.toBytes());
    msg.sequenceId = nextSeqId++;
    await transport.sendMessage(msg);
  }

  Future<void> sendPrivateTyping(
    int toUserId, {
    required bool isTyping,
  }) {
    return sendTyping(
      scope: ChatScope.privateChat.value,
      targetId: toUserId,
      toUserId: toUserId,
      isTyping: isTyping,
    );
  }

  Future<void> sendChannelTyping(
    int channelId, {
    required bool isTyping,
  }) {
    return sendTyping(
      scope: ChatScope.channel.value,
      targetId: channelId,
      isTyping: isTyping,
    );
  }

  Future<void> sendGroupTyping(
    int groupId, {
    required bool isTyping,
  }) {
    return sendTyping(
      scope: ChatScope.group.value,
      targetId: groupId,
      isTyping: isTyping,
    );
  }
}
