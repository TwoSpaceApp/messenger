import 'package:two_space_app/core/network/aegis/aegis_client.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';

class AegisGroupFacade {

  AegisGroupFacade.internal(this._client);
  final AegisClient _client;

  Future<GroupCreateResponse> create(
    String name, {
    String? description,
  }) => _client.createGroup(name, description: description);

  Future<GroupLeaveResponse> leave(int groupId) => _client.leaveGroup(groupId);

  Future<MediaSendResponse> sendMessage(
    int groupId,
    String content, {
    MessageContentType contentType = MessageContentType.text,
    int? replyToMessageId,
    ParseMode? parseMode,
  }) => _client.sendGroupMessage(
    groupId,
    content,
    contentType: contentType,
    replyToMessageId: replyToMessageId,
    parseMode: parseMode,
  );

  Future<GroupHistoryResponse> history(
    int groupId, {
    int limit = 100,
    int? beforeMessageId,
  }) => _client.getGroupHistory(
    groupId,
    limit: limit,
    beforeMessageId: beforeMessageId,
  );

  Future<GroupMembersResponse> members(int groupId) =>
      _client.getGroupMembers(groupId);

  Future<MessagePinResponse> pinMessage(int groupId, int messageId) =>
      _client.pinGroupMessage(groupId, messageId);

  Future<MessagePinResponse> unpinMessage(int groupId, int messageId) =>
      _client.unpinGroupMessage(groupId, messageId);

  Future<MessageReactResponse> react(int messageId, String emoji) =>
      _client.reactToGroupMessage(messageId, emoji);

  Future<MessageReactResponse> removeReaction(int messageId, String emoji) =>
      _client.removeReactionFromGroupMessage(messageId, emoji);

  Future<MessageEditResponse> editMessage(
    int groupId,
    int messageId,
    String newContent,
  ) => _client.editGroupMessage(groupId, messageId, newContent);

  Future<MessageDeleteResponse> deleteMessage(
    int groupId,
    int messageId,
  ) => _client.deleteGroupMessage(groupId, messageId);

  Future<RoomSettingsGetResponse> getSettings(int groupId) =>
      _client.getGroupSettings(groupId);

  Future<RoomSettingsUpdateResponse> updateSettings(
    int groupId, {
    RoomJoinRule? joinRule,
    RoomHistoryVisibility? historyVisibility,
  }) => _client.updateGroupSettings(
    groupId,
    joinRule: joinRule,
    historyVisibility: historyVisibility,
  );
}
