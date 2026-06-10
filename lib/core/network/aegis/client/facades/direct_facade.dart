import 'package:two_space_app/core/network/aegis/aegis_client.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';

class AegisDirectFacade {

  AegisDirectFacade.internal(this._client);
  final AegisClient _client;

  Future<PrivateChatMessageResponse> sendMessage(
    int toUserId,
    String content, {
    MessageContentType contentType = MessageContentType.text,
    ParseMode? parseMode,
  }) => _client.sendPrivateMessage(
    toUserId,
    content,
    contentType: contentType,
    parseMode: parseMode,
  );

  Future<PrivateChatHistoryResponse> history(
    int peerUserId, {
    int limit = 100,
    int? beforeMessageId,
  }) => _client.getPrivateHistory(
    peerUserId,
    limit: limit,
    beforeMessageId: beforeMessageId,
  );

  Future<MessageReactResponse> react(int messageId, String emoji) =>
      _client.reactToPrivateMessage(messageId, emoji);

  Future<MessageReactResponse> removeReaction(int messageId, String emoji) =>
      _client.removeReactionFromPrivateMessage(messageId, emoji);

  Future<MessageEditResponse> editMessage(int messageId, String newContent) =>
      _client.editPrivateMessage(messageId, newContent);

  Future<MessageDeleteResponse> deleteMessage(int messageId) =>
      _client.deletePrivateMessage(messageId);
}
