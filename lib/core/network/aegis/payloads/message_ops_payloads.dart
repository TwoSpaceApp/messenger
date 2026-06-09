import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/payloads/enums.dart';
import 'package:two_space_app/core/network/aegis/payloads/helpers.dart';

/// Async message status event payload (server -> clients)
class MessageStatusEvent {
  MessageStatusEvent({
    required this.success,
    required this.messageIds,
    this.deliveredTo,
    this.readBy,
    this.processedAt,
  });

  factory MessageStatusEvent.fromJson(Map<String, dynamic> json) {
    final processedAtRaw = json["ProcessedAt"];
    return MessageStatusEvent(
      success: json["Success"] as bool? ?? false,
      messageIds: parseIntList(json["MessageIds"]),
      deliveredTo: parseNullableIntValue(json["DeliveredTo"]),
      readBy: parseNullableIntValue(json["ReadBy"]),
      processedAt: parseNullableDateTimeValue(processedAtRaw),
    );
  }

  factory MessageStatusEvent.fromBytes(List<int> bytes) {
    final json = decodePayloadMap(bytes);
    return MessageStatusEvent.fromJson(json);
  }
  final bool success;
  final List<int> messageIds;
  final int? deliveredTo;
  final int? readBy;
  final DateTime? processedAt;

  bool get isDeliveredUpdate => deliveredTo != null;
  bool get isReadUpdate => readBy != null;
}

/// Delivery receipt request payload.
class MessageDeliveryReceiptRequest {
  MessageDeliveryReceiptRequest({
    required this.messageIds,
    this.deliveredAt,
    this.deviceId,
  });
  final List<int> messageIds;
  final DateTime? deliveredAt;
  final String? deviceId;

  Map<String, dynamic> toJson() => {
    'MessageIds': messageIds,
    if (deliveredAt != null)
      'DeliveredAt': deliveredAt!.toUtc().toIso8601String(),
    if (deviceId != null) 'DeviceId': deviceId,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Read receipt request payload.
class MessageReadReceiptRequest {
  MessageReadReceiptRequest({required this.messageIds, this.readAt});
  final List<int> messageIds;
  final DateTime? readAt;

  Map<String, dynamic> toJson() => {
    'MessageIds': messageIds,
    if (readAt != null) 'ReadAt': readAt!.toUtc().toIso8601String(),
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Receipt confirmation payload returned by read/delivery receipt handlers.
class MessageReceiptResponse {
  MessageReceiptResponse({
    required this.success,
    required this.messageIds,
    this.processedAt,
  });

  factory MessageReceiptResponse.fromJson(Map<String, dynamic> json) =>
      MessageReceiptResponse(
        success: json["Success"] as bool? ?? false,
        messageIds: (json["MessageIds"] as List<dynamic>? ??
                const <dynamic>[])
            .map((item) => (item as num).toInt())
            .toList(growable: false),
        processedAt: parseNullableDateTimeValue(json["ProcessedAt"]),
      );

  factory MessageReceiptResponse.fromBytes(List<int> bytes) =>
      MessageReceiptResponse.fromJson(decodePayloadMap(bytes));
  final bool success;
  final List<int> messageIds;
  final DateTime? processedAt;
}

/// Message edit request payload.
class MessageEditRequest {
  MessageEditRequest({
    required this.messageId,
    required this.newContent,
    this.scope = "private",
    this.channelId,
    this.groupId,
  });

  factory MessageEditRequest.privateChat({
    required int messageId,
    required String newContent,
  }) =>
      MessageEditRequest(
        messageId: messageId,
        newContent: newContent,
        scope: ChatScope.privateChat.value,
      );

  factory MessageEditRequest.channel({
    required int channelId,
    required int messageId,
    required String newContent,
  }) =>
      MessageEditRequest(
        messageId: messageId,
        newContent: newContent,
        scope: ChatScope.channel.value,
        channelId: channelId,
      );

  factory MessageEditRequest.group({
    required int groupId,
    required int messageId,
    required String newContent,
  }) =>
      MessageEditRequest(
        messageId: messageId,
        newContent: newContent,
        scope: ChatScope.group.value,
        groupId: groupId,
      );
  final int messageId;
  final String newContent;
  final String scope;
  final int? channelId;
  final int? groupId;

  ChatScope get chatScope => ChatScope.fromValue(scope);

  Map<String, dynamic> toJson() => {
    'MessageId': messageId,
    'NewContent': newContent,
    'Scope': scope,
    if (channelId != null) 'ChannelId': channelId,
    if (groupId != null) 'GroupId': groupId,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

class MessageEditResponse {
  MessageEditResponse({
    required this.success,
    this.message,
    this.messageId = 0,
  });

  factory MessageEditResponse.fromJson(Map<String, dynamic> json) =>
      MessageEditResponse(
        success: json["Success"] as bool? ?? false,
        message: json["Message"] as String?,
        messageId: (json["MessageId"] as num?)?.toInt() ?? 0,
      );

  factory MessageEditResponse.fromBytes(List<int> bytes) =>
      MessageEditResponse.fromJson(decodePayloadMap(bytes));
  final bool success;
  final String? message;
  final int messageId;
}

/// Message delete request payload.
class MessageDeleteRequest {
  MessageDeleteRequest({
    required this.messageId,
    this.scope = "private",
    this.channelId,
    this.groupId,
  });

  factory MessageDeleteRequest.privateChat({required int messageId}) =>
      MessageDeleteRequest(
        messageId: messageId,
        scope: ChatScope.privateChat.value,
      );

  factory MessageDeleteRequest.channel({
    required int channelId,
    required int messageId,
  }) =>
      MessageDeleteRequest(
        messageId: messageId,
        scope: ChatScope.channel.value,
        channelId: channelId,
      );

  factory MessageDeleteRequest.group({
    required int groupId,
    required int messageId,
  }) =>
      MessageDeleteRequest(
        messageId: messageId,
        scope: ChatScope.group.value,
        groupId: groupId,
      );
  final int messageId;
  final String scope;
  final int? channelId;
  final int? groupId;

  ChatScope get chatScope => ChatScope.fromValue(scope);

  Map<String, dynamic> toJson() => {
    'MessageId': messageId,
    'Scope': scope,
    if (channelId != null) 'ChannelId': channelId,
    if (groupId != null) 'GroupId': groupId,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

class MessageDeleteResponse {
  MessageDeleteResponse({
    required this.success,
    this.message,
    this.messageId = 0,
  });

  factory MessageDeleteResponse.fromJson(Map<String, dynamic> json) =>
      MessageDeleteResponse(
        success: json["Success"] as bool? ?? false,
        message: json["Message"] as String?,
        messageId: (json["MessageId"] as num?)?.toInt() ?? 0,
      );

  factory MessageDeleteResponse.fromBytes(List<int> bytes) =>
      MessageDeleteResponse.fromJson(decodePayloadMap(bytes));
  final bool success;
  final String? message;
  final int messageId;
}
