import 'dart:typed_data';

import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/payloads/enums.dart';
import 'package:two_space_app/core/network/aegis/payloads/helpers.dart';
import 'package:two_space_app/core/network/aegis/payloads/member_payloads.dart';

/// Group message send request
class GroupMessageSendRequest {
  GroupMessageSendRequest({
    required this.groupId,
    this.content,
    this.contentType = MessageContentType.text,
    this.replyToMessageId,
    this.attachment,
    this.attachments,
    this.parseMode,
  });
  final int groupId;
  final String? content;
  final MessageContentType contentType;
  final int? replyToMessageId;
  final MediaAttachmentPayload? attachment;
  final List<MediaAttachmentPayload>? attachments;
  final String? parseMode;

  Map<String, dynamic> toJson() => {
    'GroupId': groupId,
    'Content': content,
    'ContentType': contentType.value,
    if (replyToMessageId != null) 'ReplyToMessageId': replyToMessageId,
    if (attachment != null) 'Attachment': attachment!.toJson(),
    if (attachments != null)
      'Attachments': attachments!.map((item) => item.toJson()).toList(),
    if (parseMode != null) 'ParseMode': parseMode,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Response for group message send.
class GroupMessageSendResponse {
  GroupMessageSendResponse({
    required this.success,
    this.messageId = 0,
    this.message,
  });

  factory GroupMessageSendResponse.fromJson(Map<String, dynamic> json) =>
      GroupMessageSendResponse(
        success: json["Success"] as bool,
        messageId: json["MessageId"] as int? ?? 0,
        message: json["Message"] as String?,
      );

  factory GroupMessageSendResponse.fromBytes(List<int> bytes) {
    return GroupMessageSendResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final int messageId;
  final String? message;
}

/// Group history request
class GroupHistoryRequest {
  GroupHistoryRequest({
    required this.groupId,
    this.limit = 100,
    this.beforeMessageId,
  });
  final int groupId;
  final int limit;
  final int? beforeMessageId;

  Map<String, dynamic> toJson() => {
    'GroupId': groupId,
    'Limit': limit,
    if (beforeMessageId != null) 'BeforeMessageId': beforeMessageId,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Group history message item
class GroupHistoryItem {
  GroupHistoryItem({
    required this.id,
    required this.groupId,
    required this.fromUserId,
    required this.content,
    required this.contentType,
    required this.createdAt,
    this.deliveredTo = const <int>[],
    this.readBy = const <int>[],
    this.isPinned = false,
    this.parseMode,
    this.fromUsername,
    this.groupName,
  });

  factory GroupHistoryItem.fromJson(Map<String, dynamic> json) {
    final parsed = parseRichTextContent(json["Content"] as String);
    return GroupHistoryItem(
      id: parseIntValue(json["Id"], fieldName: "GroupHistoryItem.Id"),
      groupId: parseIntValue(
        json["GroupId"],
        fieldName: "GroupHistoryItem.GroupId",
      ),
      fromUserId: parseIntValue(
        json["FromUserId"],
        fieldName: "GroupHistoryItem.FromUserId",
      ),
      content: parsed.text,
      contentType: MessageContentType.fromValue(
        parseNullableIntValue(json["ContentType"]) ?? 0,
      ),
      createdAt: parseNullableDateTimeValue(json["CreatedAt"]) ??
          DateTime.now().toUtc(),
      deliveredTo: parseIntList(json["DeliveredTo"]),
      readBy: parseIntList(json["ReadBy"]),
      isPinned: json["IsPinned"] as bool? ?? false,
      parseMode: parsed.parseMode,
      fromUsername: json["FromUsername"] as String?,
      groupName: json["GroupName"] as String?,
    );
  }
  final int id;
  final int groupId;
  final int fromUserId;
  final String content;
  final MessageContentType contentType;
  final DateTime createdAt;
  final List<int> deliveredTo;
  final List<int> readBy;
  final bool isPinned;
  final String? parseMode;
  final String? fromUsername;
  final String? groupName;

  ParsedMediaAttachment? get attachment =>
      tryParseMediaAttachment(content, contentType);

  List<ParsedMediaAttachment> get attachments =>
      tryParseMediaAttachments(content, contentType)?.attachments ??
      const <ParsedMediaAttachment>[];
}

/// Group history response
class GroupHistoryResponse {
  GroupHistoryResponse({
    required this.success,
    required this.groupId,
    required this.messages,
    this.groupName,
    this.message,
  });

  factory GroupHistoryResponse.fromJson(Map<String, dynamic> json) =>
      GroupHistoryResponse(
        success: json["Success"] as bool,
        groupId: parseNullableIntValue(json["GroupId"]) ?? 0,
        groupName: json["GroupName"] as String?,
        messages: (json["Messages"] as List<dynamic>? ?? const <dynamic>[])
            .map(
              (item) => GroupHistoryItem.fromJson(
                  item as Map<String, dynamic>),
            )
            .toList(),
        message: json["Message"] as String?,
      );

  factory GroupHistoryResponse.fromBytes(List<int> bytes) {
    return GroupHistoryResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final int groupId;
  final String? groupName;
  final List<GroupHistoryItem> messages;
  final String? message;
}

/// Group message event (server -> client push)
class GroupMessageEvent {
  GroupMessageEvent({
    required this.id,
    required this.groupId,
    required this.fromUserId,
    required this.content,
    required this.contentType,
    required this.createdAt,
    this.deliveredTo = const <int>[],
    this.readBy = const <int>[],
    this.fromUsername,
    this.groupName,
    this.parseMode,
  });

  factory GroupMessageEvent.fromJson(Map<String, dynamic> json) {
    final parsed = parseRichTextContent(json["Content"] as String);
    return GroupMessageEvent(
      id: parseIntValue(json["Id"], fieldName: "GroupMessageEvent.Id"),
      groupId: parseIntValue(
        json["GroupId"],
        fieldName: "GroupMessageEvent.GroupId",
      ),
      fromUserId: parseIntValue(
        json["FromUserId"],
        fieldName: "GroupMessageEvent.FromUserId",
      ),
      content: parsed.text,
      contentType: MessageContentType.fromValue(
        parseNullableIntValue(json["ContentType"]) ?? 0,
      ),
      createdAt: parseNullableDateTimeValue(json["CreatedAt"]) ??
          DateTime.now().toUtc(),
      deliveredTo: parseIntList(json["DeliveredTo"]),
      readBy: parseIntList(json["ReadBy"]),
      fromUsername: json["FromUsername"] as String?,
      groupName: json["GroupName"] as String?,
      parseMode: parsed.parseMode,
    );
  }

  factory GroupMessageEvent.fromBytes(List<int> bytes) {
    return GroupMessageEvent.fromJson(decodePayloadMap(bytes));
  }
  final int id;
  final int groupId;
  final int fromUserId;
  final String content;
  final MessageContentType contentType;
  final DateTime createdAt;
  final List<int> deliveredTo;
  final List<int> readBy;
  final String? fromUsername;
  final String? groupName;
  final String? parseMode;

  ParsedMediaAttachment? get attachment =>
      tryParseMediaAttachment(content, contentType);

  List<ParsedMediaAttachment> get attachments =>
      tryParseMediaAttachments(content, contentType)?.attachments ??
      const <ParsedMediaAttachment>[];
}

/// Group create request payload.
class GroupCreateRequest {
  GroupCreateRequest({required this.name, this.description});
  final String name;
  final String? description;

  Map<String, dynamic> toJson() => {
    'Name': name,
    if (description != null) 'Description': description,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Group create response payload.
class GroupCreateResponse {
  GroupCreateResponse(
      {required this.success, this.groupId = 0, this.message});

  factory GroupCreateResponse.fromJson(Map<String, dynamic> json) =>
      GroupCreateResponse(
        success: json["Success"] as bool? ?? false,
        groupId: (json["GroupId"] as num?)?.toInt() ?? 0,
        message: json["Message"] as String?,
      );

  factory GroupCreateResponse.fromBytes(List<int> bytes) =>
      GroupCreateResponse.fromJson(decodePayloadMap(bytes));
  final bool success;
  final int groupId;
  final String? message;
}

/// Request to edit a group chat (name, description, avatar)
class GroupEditRequest {
  GroupEditRequest({
    required this.groupId,
    this.name,
    this.description,
    this.avatarUrl,
  });
  final int groupId;
  final String? name;
  final String? description;
  final String? avatarUrl;

  Map<String, dynamic> toJson() => {
    'GroupId': groupId,
    if (name != null) 'Name': name,
    if (description != null) 'Description': description,
    if (avatarUrl != null) 'AvatarUrl': avatarUrl,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Response to a group edit request
class GroupEditResponse {
  GroupEditResponse({required this.success, this.message});

  factory GroupEditResponse.fromJson(Map<String, dynamic> json) =>
      GroupEditResponse(
        success: json["Success"] as bool,
        message: json["Message"] as String?,
      );

  factory GroupEditResponse.fromBytes(List<int> bytes) {
    return GroupEditResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final String? message;
}

/// Group members request
class GroupMembersRequest {
  GroupMembersRequest({required this.groupId});
  final int groupId;

  Map<String, dynamic> toJson() => {'GroupId': groupId};
  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Group members response
class GroupMembersResponse {
  GroupMembersResponse({
    required this.success,
    required this.groupId,
    required this.members,
    this.message,
  });

  factory GroupMembersResponse.fromJson(Map<String, dynamic> json) =>
      GroupMembersResponse(
        success: json["Success"] as bool,
        groupId: parseNullableIntValue(json["GroupId"]) ?? 0,
        members: (json["Members"] as List<dynamic>? ?? const <dynamic>[])
            .map((item) =>
                MemberSummary.fromJson(item as Map<String, dynamic>))
            .toList(),
        message: json["Message"] as String?,
      );

  factory GroupMembersResponse.fromBytes(List<int> bytes) {
    return GroupMembersResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final int groupId;
  final List<MemberSummary> members;
  final String? message;
}

/// Group leave request
class GroupLeaveRequest {
  GroupLeaveRequest({required this.groupId});
  final int groupId;

  Map<String, dynamic> toJson() => {'GroupId': groupId};
  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Group leave response
class GroupLeaveResponse {
  GroupLeaveResponse({required this.success, this.message});

  factory GroupLeaveResponse.fromJson(Map<String, dynamic> json) =>
      GroupLeaveResponse(
        success: json["Success"] as bool,
        message: json["Message"] as String?,
      );

  factory GroupLeaveResponse.fromBytes(List<int> bytes) {
    final raw = msgpack.deserialize(Uint8List.fromList(bytes));
    return GroupLeaveResponse.fromJson(
      normalizeMsgPack(raw) as Map<String, dynamic>,
    );
  }
  final bool success;
  final String? message;
}
