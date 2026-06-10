import 'dart:typed_data';

import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/payloads/enums.dart';
import 'package:two_space_app/core/network/aegis/payloads/helpers.dart';

/// Reaction count summary
class ReactionCount {
  ReactionCount(
      {required this.emoji, required this.count, required this.byMe});

  factory ReactionCount.fromJson(Map<String, dynamic> json) => ReactionCount(
    emoji: json["Emoji"] as String,
    count: parseIntValue(json["Count"], fieldName: "ReactionCount.Count"),
    byMe: json["ByMe"] as bool? ?? false,
  );
  final String emoji;
  final int count;
  final bool byMe;
}

/// Message reaction request
class MessageReactRequest {
  MessageReactRequest({
    required this.scope,
    required this.messageId,
    required this.emoji,
    this.remove = false,
  });

  factory MessageReactRequest.privateChat({
    required int messageId,
    required String emoji,
    bool remove = false,
  }) =>
      MessageReactRequest(
        scope: ChatScope.privateChat.value,
        messageId: messageId,
        emoji: emoji,
        remove: remove,
      );

  factory MessageReactRequest.channel({
    required int messageId,
    required String emoji,
    bool remove = false,
  }) =>
      MessageReactRequest(
        scope: ChatScope.channel.value,
        messageId: messageId,
        emoji: emoji,
        remove: remove,
      );

  factory MessageReactRequest.group({
    required int messageId,
    required String emoji,
    bool remove = false,
  }) =>
      MessageReactRequest(
        scope: ChatScope.group.value,
        messageId: messageId,
        emoji: emoji,
        remove: remove,
      );
  final String scope; // "private", "channel", "group"
  final int messageId;
  final String emoji;
  final bool remove;

  ChatScope get chatScope => ChatScope.fromValue(scope);

  Map<String, dynamic> toJson() => {
    'Scope': scope,
    'MessageId': messageId,
    'Emoji': emoji,
    'Remove': remove,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Message reaction response
class MessageReactResponse {
  MessageReactResponse({
    required this.success,
    required this.reactions,
    this.message,
  });

  factory MessageReactResponse.fromJson(Map<String, dynamic> json) =>
      MessageReactResponse(
        success: json["Success"] as bool,
        message: json["Message"] as String?,
        reactions: (json["Reactions"] as List<dynamic>? ?? const <dynamic>[])
            .map((item) =>
                ReactionCount.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  factory MessageReactResponse.fromBytes(List<int> bytes) {
    final raw = msgpack.deserialize(Uint8List.fromList(bytes));
    return MessageReactResponse.fromJson(
      normalizeMsgPack(raw) as Map<String, dynamic>,
    );
  }
  final bool success;
  final String? message;
  final List<ReactionCount> reactions;
}

/// Message reaction event (server -> client push)
class MessageReactionEvent {
  MessageReactionEvent({
    required this.scope,
    required this.messageId,
    required this.userId,
    required this.emoji,
    required this.removed,
    required this.reactions,
  });

  factory MessageReactionEvent.fromJson(Map<String, dynamic> json) =>
      MessageReactionEvent(
        scope: json["Scope"] as String,
        messageId: parseIntValue(
          json["MessageId"],
          fieldName: "MessageReactionEvent.MessageId",
        ),
        userId: parseIntValue(
          json["UserId"],
          fieldName: "MessageReactionEvent.UserId",
        ),
        emoji: json["Emoji"] as String,
        removed: json["Removed"] as bool? ?? false,
        reactions: (json["Reactions"] as List<dynamic>? ?? const <dynamic>[])
            .map((item) =>
                ReactionCount.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  factory MessageReactionEvent.fromBytes(List<int> bytes) {
    return MessageReactionEvent.fromJson(decodePayloadMap(bytes));
  }
  final String scope;
  final int messageId;
  final int userId;
  final String emoji;
  final bool removed;
  final List<ReactionCount> reactions;

  ChatScope get chatScope => ChatScope.fromValue(scope);
}

/// Message pin request
class MessagePinRequest {
  MessagePinRequest({
    required this.scope,
    required this.messageId,
    required this.targetId,
    this.unpin = false,
  });

  factory MessagePinRequest.channel({
    required int channelId,
    required int messageId,
    bool unpin = false,
  }) =>
      MessagePinRequest(
        scope: RoomScope.channel.value,
        messageId: messageId,
        targetId: channelId,
        unpin: unpin,
      );

  factory MessagePinRequest.group({
    required int groupId,
    required int messageId,
    bool unpin = false,
  }) =>
      MessagePinRequest(
        scope: RoomScope.group.value,
        messageId: messageId,
        targetId: groupId,
        unpin: unpin,
      );
  final String scope; // "channel" or "group"
  final int messageId;
  final int targetId; // channelId or groupId
  final bool unpin;

  RoomScope get roomScope => RoomScope.fromValue(scope);

  Map<String, dynamic> toJson() => {
    'Scope': scope,
    'MessageId': messageId,
    'TargetId': targetId,
    'Unpin': unpin,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Message pin response
class MessagePinResponse {
  MessagePinResponse({required this.success, this.message});

  factory MessagePinResponse.fromJson(Map<String, dynamic> json) =>
      MessagePinResponse(
        success: json["Success"] as bool,
        message: json["Message"] as String?,
      );

  factory MessagePinResponse.fromBytes(List<int> bytes) {
    final raw = msgpack.deserialize(Uint8List.fromList(bytes));
    return MessagePinResponse.fromJson(
      normalizeMsgPack(raw) as Map<String, dynamic>,
    );
  }
  final bool success;
  final String? message;
}

/// Message pin event (server -> client push)
class MessagePinEvent {
  MessagePinEvent({
    required this.scope,
    required this.messageId,
    required this.targetId,
    required this.pinned,
    required this.actorUserId,
  });

  factory MessagePinEvent.fromJson(Map<String, dynamic> json) =>
      MessagePinEvent(
        scope: json["Scope"] as String,
        messageId: parseIntValue(
          json["MessageId"],
          fieldName: "MessagePinEvent.MessageId",
        ),
        targetId: parseIntValue(
          json["TargetId"],
          fieldName: "MessagePinEvent.TargetId",
        ),
        pinned: json["Pinned"] as bool? ?? false,
        actorUserId: parseIntValue(
          json["ActorUserId"],
          fieldName: "MessagePinEvent.ActorUserId",
        ),
      );

  factory MessagePinEvent.fromBytes(List<int> bytes) {
    final raw = msgpack.deserialize(Uint8List.fromList(bytes));
    return MessagePinEvent.fromJson(
      normalizeMsgPack(raw) as Map<String, dynamic>,
    );
  }
  final String scope;
  final int messageId;
  final int targetId;
  final bool pinned;
  final int actorUserId;

  RoomScope get roomScope => RoomScope.fromValue(scope);
}
