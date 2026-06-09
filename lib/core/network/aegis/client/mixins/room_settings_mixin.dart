import 'package:two_space_app/core/network/aegis/client/aegis_client_base.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';

mixin AegisRoomSettingsMixin on AegisClientBase {

  Future<RoomSettingsGetResponse> getRoomSettings(
    String scope,
    int targetId,
  ) async {
    requireAuthenticated();

    final request = RoomSettingsGetRequest(
      scope: scope,
      targetId: targetId,
    );

    final msg = Message.withType(
      MessageType.roomSettingsGet,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.roomSettingsGetResponse},
    );
    return RoomSettingsGetResponse.fromBytes(response.payload);
  }

  Future<RoomSettingsGetResponse> getChannelSettings(int channelId) {
    return getRoomSettings(RoomScope.channel.value, channelId);
  }

  Future<RoomSettingsGetResponse> getGroupSettings(int groupId) {
    return getRoomSettings(RoomScope.group.value, groupId);
  }

  Future<RoomSettingsUpdateResponse> updateRoomSettings(
    String scope,
    int targetId, {
    int? joinRule,
    int? historyVisibility,
  }) async {
    requireAuthenticated();

    final request = RoomSettingsUpdateRequest(
      scope: scope,
      targetId: targetId,
      joinRule: joinRule,
      historyVisibility: historyVisibility,
    );

    final msg = Message.withType(
      MessageType.roomSettingsUpdate,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.roomSettingsUpdateResponse},
    );
    return RoomSettingsUpdateResponse.fromBytes(response.payload);
  }

  Future<RoomSettingsUpdateResponse> updateChannelSettings(
    int channelId, {
    RoomJoinRule? joinRule,
    RoomHistoryVisibility? historyVisibility,
  }) {
    return updateRoomSettings(
      RoomScope.channel.value,
      channelId,
      joinRule: joinRule?.value,
      historyVisibility: historyVisibility?.value,
    );
  }

  Future<RoomSettingsUpdateResponse> updateGroupSettings(
    int groupId, {
    RoomJoinRule? joinRule,
    RoomHistoryVisibility? historyVisibility,
  }) {
    return updateRoomSettings(
      RoomScope.group.value,
      groupId,
      joinRule: joinRule?.value,
      historyVisibility: historyVisibility?.value,
    );
  }
}
