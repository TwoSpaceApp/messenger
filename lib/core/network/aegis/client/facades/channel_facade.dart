import 'package:two_space_app/core/network/aegis/aegis_client.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';

class AegisChannelFacade {

  AegisChannelFacade.internal(this._client);
  final AegisClient _client;

  Future<ChannelCreateResponse> create(
    String name, {
    String? description,
    ChannelType type = ChannelType.public,
  }) => _client.createChannel(name, description: description, type: type);

  Future<ChannelJoinResponse> join(int channelId) =>
      _client.joinChannel(channelId);

  Future<ChannelJoinResponse> joinByLink(String linkOrAlias) =>
      _client.joinChannelByLink(linkOrAlias);

  Future<ChannelLeaveResponse> leave(int channelId) =>
      _client.leaveChannel(channelId);

  Future<ChannelMessageResponse> sendMessage(
    int channelId,
    String content, {
    MessageContentType contentType = MessageContentType.text,
    int? replyToMessageId,
    ParseMode? parseMode,
  }) => _client.sendChannelMessage(
    channelId,
    content,
    contentType: contentType,
    replyToMessageId: replyToMessageId,
    parseMode: parseMode,
  );

  Future<ChannelHistoryResponse> history(
    int channelId, {
    int limit = 100,
    int? beforeMessageId,
  }) => _client.getChannelHistory(
    channelId,
    limit: limit,
    beforeMessageId: beforeMessageId,
  );

  Future<ChannelMembersResponse> members(int channelId) =>
      _client.getChannelMembers(channelId);

  Future<MessagePinResponse> pinMessage(int channelId, int messageId) =>
      _client.pinChannelMessage(channelId, messageId);

  Future<MessagePinResponse> unpinMessage(int channelId, int messageId) =>
      _client.unpinChannelMessage(channelId, messageId);

  Future<MessageReactResponse> react(int messageId, String emoji) =>
      _client.reactToChannelMessage(messageId, emoji);

  Future<MessageReactResponse> removeReaction(int messageId, String emoji) =>
      _client.removeReactionFromChannelMessage(messageId, emoji);

  Future<MessageEditResponse> editMessage(
    int channelId,
    int messageId,
    String newContent,
  ) => _client.editChannelMessage(channelId, messageId, newContent);

  Future<MessageDeleteResponse> deleteMessage(
    int channelId,
    int messageId,
  ) => _client.deleteChannelMessage(channelId, messageId);

  Future<RoomSettingsGetResponse> getSettings(int channelId) =>
      _client.getChannelSettings(channelId);

  Future<RoomSettingsUpdateResponse> updateSettings(
    int channelId, {
    RoomJoinRule? joinRule,
    RoomHistoryVisibility? historyVisibility,
  }) => _client.updateChannelSettings(
    channelId,
    joinRule: joinRule,
    historyVisibility: historyVisibility,
  );
}
