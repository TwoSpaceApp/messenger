import 'package:two_space_app/core/network/aegis/client/aegis_client_base.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';

mixin AegisReactionPinMixin on AegisClientBase {

  Future<MessageReactResponse> postReaction(
    String scope,
    int messageId,
    String emoji,
  ) async {
    requireAuthenticated();

    final request = MessageReactRequest(
      scope: scope,
      messageId: messageId,
      emoji: emoji,
    );

    final msg = Message.withType(
      MessageType.messageReact,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.messageReactResponse},
    );
    return MessageReactResponse.fromBytes(response.payload);
  }

  Future<MessageReactResponse> reactToPrivateMessage(
    int messageId,
    String emoji,
  ) {
    return postReaction(ChatScope.privateChat.value, messageId, emoji);
  }

  Future<MessageReactResponse> reactToChannelMessage(
    int messageId,
    String emoji,
  ) {
    return postReaction(ChatScope.channel.value, messageId, emoji);
  }

  Future<MessageReactResponse> reactToGroupMessage(
    int messageId,
    String emoji,
  ) {
    return postReaction(ChatScope.group.value, messageId, emoji);
  }

  Future<MessageReactResponse> removeReaction(
    String scope,
    int messageId,
    String emoji,
  ) async {
    requireAuthenticated();

    final request = MessageReactRequest(
      scope: scope,
      messageId: messageId,
      emoji: emoji,
      remove: true,
    );

    final msg = Message.withType(
      MessageType.messageReact,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.messageReactResponse},
    );
    return MessageReactResponse.fromBytes(response.payload);
  }

  Future<MessageReactResponse> removeReactionFromPrivateMessage(
    int messageId,
    String emoji,
  ) {
    return removeReaction(ChatScope.privateChat.value, messageId, emoji);
  }

  Future<MessageReactResponse> removeReactionFromChannelMessage(
    int messageId,
    String emoji,
  ) {
    return removeReaction(ChatScope.channel.value, messageId, emoji);
  }

  Future<MessageReactResponse> removeReactionFromGroupMessage(
    int messageId,
    String emoji,
  ) {
    return removeReaction(ChatScope.group.value, messageId, emoji);
  }

  Future<MessagePinResponse> pinMessage(
    String scope,
    int messageId,
    int targetId,
  ) async {
    requireAuthenticated();

    final request = MessagePinRequest(
      scope: scope,
      messageId: messageId,
      targetId: targetId,
    );

    final msg = Message.withType(
      MessageType.messagePin,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.messagePinResponse},
    );
    return MessagePinResponse.fromBytes(response.payload);
  }

  Future<MessagePinResponse> pinChannelMessage(
    int channelId,
    int messageId,
  ) {
    return pinMessage(RoomScope.channel.value, messageId, channelId);
  }

  Future<MessagePinResponse> pinGroupMessage(
    int groupId,
    int messageId,
  ) {
    return pinMessage(RoomScope.group.value, messageId, groupId);
  }

  Future<MessagePinResponse> unpinMessage(
    String scope,
    int messageId,
    int targetId,
  ) async {
    requireAuthenticated();

    final request = MessagePinRequest(
      scope: scope,
      messageId: messageId,
      targetId: targetId,
      unpin: true,
    );

    final msg = Message.withType(
      MessageType.messagePin,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.messagePinResponse},
    );
    return MessagePinResponse.fromBytes(response.payload);
  }

  Future<MessagePinResponse> unpinChannelMessage(
    int channelId,
    int messageId,
  ) {
    return unpinMessage(RoomScope.channel.value, messageId, channelId);
  }

  Future<MessagePinResponse> unpinGroupMessage(
    int groupId,
    int messageId,
  ) {
    return unpinMessage(RoomScope.group.value, messageId, groupId);
  }
}
