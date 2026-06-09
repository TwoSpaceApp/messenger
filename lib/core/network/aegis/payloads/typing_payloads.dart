import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/payloads/enums.dart';
import 'package:two_space_app/core/network/aegis/payloads/helpers.dart';

class UserTypingRequest {
  const UserTypingRequest({
    required this.scope,
    required this.targetId,
    required this.isTyping,
    this.toUserId,
  });

  factory UserTypingRequest.privateChat({
    required int toUserId,
    required bool isTyping,
  }) =>
      UserTypingRequest(
        scope: ChatScope.privateChat.value,
        targetId: toUserId,
        toUserId: toUserId,
        isTyping: isTyping,
      );

  factory UserTypingRequest.channel({
    required int channelId,
    required bool isTyping,
  }) =>
      UserTypingRequest(
        scope: ChatScope.channel.value,
        targetId: channelId,
        isTyping: isTyping,
      );

  factory UserTypingRequest.group({
    required int groupId,
    required bool isTyping,
  }) =>
      UserTypingRequest(
        scope: ChatScope.group.value,
        targetId: groupId,
        isTyping: isTyping,
      );

  final String scope;
  final int targetId;
  final bool isTyping;
  final int? toUserId;

  Map<String, dynamic> toJson() => {
    'Scope': scope,
    'TargetId': targetId,
    'IsTyping': isTyping,
    if (toUserId != null) 'ToUserId': toUserId,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

class UserTypingEventPayload {
  const UserTypingEventPayload({
    required this.scope,
    required this.targetId,
    required this.userId,
    required this.isTyping,
    required this.timestampUtc,
  });

  factory UserTypingEventPayload.fromJson(Map<String, dynamic> json) {
    return UserTypingEventPayload(
      scope: json["Scope"]?.toString() ?? ChatScope.privateChat.value,
      targetId:
          parseIntValue(json["TargetId"] ?? 0, fieldName: "TargetId"),
      userId: parseIntValue(json["UserId"] ?? 0, fieldName: "UserId"),
      isTyping: parseBoolValue(json["IsTyping"]),
      timestampUtc: parseDateTimeValue(
        json["TimestampUtc"] ?? json["Timestamp"] ?? DateTime.now().toUtc(),
      ),
    );
  }

  factory UserTypingEventPayload.fromBytes(List<int> bytes) {
    return UserTypingEventPayload.fromJson(decodePayloadMap(bytes));
  }

  final String scope;
  final int targetId;
  final int userId;
  final bool isTyping;
  final DateTime timestampUtc;
}
