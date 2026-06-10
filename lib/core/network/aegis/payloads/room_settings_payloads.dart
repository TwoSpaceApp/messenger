import 'dart:typed_data';

import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/payloads/enums.dart';
import 'package:two_space_app/core/network/aegis/payloads/helpers.dart';

/// Room settings get request
class RoomSettingsGetRequest {
  RoomSettingsGetRequest({required this.scope, required this.targetId});
  final String scope; // "channel" or "group"
  final int targetId;

  Map<String, dynamic> toJson() => {'Scope': scope, 'TargetId': targetId};

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Room settings get response
class RoomSettingsGetResponse {
  RoomSettingsGetResponse({
    required this.success,
    required this.scope,
    required this.targetId,
    this.joinRule = 0,
    this.historyVisibility = 1,
    this.message,
  });

  factory RoomSettingsGetResponse.fromJson(Map<String, dynamic> json) =>
      RoomSettingsGetResponse(
        success: json["Success"] as bool,
        scope: json["Scope"] as String? ?? "",
        targetId: parseNullableIntValue(json["TargetId"]) ?? 0,
        joinRule: parseNullableIntValue(json["JoinRule"]) ?? 0,
        historyVisibility:
            parseNullableIntValue(json["HistoryVisibility"]) ?? 1,
        message: json["Message"] as String?,
      );

  factory RoomSettingsGetResponse.fromBytes(List<int> bytes) {
    final raw = msgpack.deserialize(Uint8List.fromList(bytes));
    return RoomSettingsGetResponse.fromJson(
      normalizeMsgPack(raw) as Map<String, dynamic>,
    );
  }
  final bool success;
  final String scope;
  final int targetId;
  final int joinRule; // 0=Open, 1=InviteOnly, 2=Approval
  final int historyVisibility; // 0=WorldReadable, 1=Joined, 2=Invited
  final String? message;

  RoomScope get roomScope => RoomScope.fromValue(scope);
  RoomJoinRule get joinRuleValue => RoomJoinRule.fromValue(joinRule);
  RoomHistoryVisibility get historyVisibilityValue =>
      RoomHistoryVisibility.fromValue(historyVisibility);
}

/// Room settings update request
class RoomSettingsUpdateRequest {
  RoomSettingsUpdateRequest({
    required this.scope,
    required this.targetId,
    this.joinRule,
    this.historyVisibility,
  });

  factory RoomSettingsUpdateRequest.channel({
    required int channelId,
    RoomJoinRule? joinRule,
    RoomHistoryVisibility? historyVisibility,
  }) =>
      RoomSettingsUpdateRequest(
        scope: RoomScope.channel.value,
        targetId: channelId,
        joinRule: joinRule?.value,
        historyVisibility: historyVisibility?.value,
      );

  factory RoomSettingsUpdateRequest.group({
    required int groupId,
    RoomJoinRule? joinRule,
    RoomHistoryVisibility? historyVisibility,
  }) =>
      RoomSettingsUpdateRequest(
        scope: RoomScope.group.value,
        targetId: groupId,
        joinRule: joinRule?.value,
        historyVisibility: historyVisibility?.value,
      );
  final String scope;
  final int targetId;
  final int? joinRule;
  final int? historyVisibility;

  RoomScope get roomScope => RoomScope.fromValue(scope);
  RoomJoinRule? get joinRuleValue =>
      joinRule == null ? null : RoomJoinRule.fromValue(joinRule!);
  RoomHistoryVisibility? get historyVisibilityValue =>
      historyVisibility == null
          ? null
          : RoomHistoryVisibility.fromValue(historyVisibility!);

  Map<String, dynamic> toJson() => {
    'Scope': scope,
    'TargetId': targetId,
    if (joinRule != null) 'JoinRule': joinRule,
    if (historyVisibility != null) 'HistoryVisibility': historyVisibility,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Room settings update response
class RoomSettingsUpdateResponse {
  RoomSettingsUpdateResponse({required this.success, this.message});

  factory RoomSettingsUpdateResponse.fromJson(Map<String, dynamic> json) =>
      RoomSettingsUpdateResponse(
        success: json["Success"] as bool,
        message: json["Message"] as String?,
      );

  factory RoomSettingsUpdateResponse.fromBytes(List<int> bytes) {
    final raw = msgpack.deserialize(Uint8List.fromList(bytes));
    return RoomSettingsUpdateResponse.fromJson(
      normalizeMsgPack(raw) as Map<String, dynamic>,
    );
  }
  final bool success;
  final String? message;
}
