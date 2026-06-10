import 'dart:typed_data';

import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/payloads/enums.dart';
import 'package:two_space_app/core/network/aegis/payloads/helpers.dart';
import 'package:two_space_app/core/network/aegis/payloads/member_payloads.dart';

/// Channel message request payload
class ChannelMessageRequest {
  ChannelMessageRequest({
    required this.channelId,
    this.content,
    this.contentType = MessageContentType.text,
    this.replyToMessageId,
    this.attachment,
    this.attachments,
    this.parseMode,
  });

  factory ChannelMessageRequest.fromJson(Map<String, dynamic> json) =>
      ChannelMessageRequest(
        channelId: parseIntValue(
          json["ChannelId"],
          fieldName: "ChannelMessageRequest.ChannelId",
        ),
        content: json["Content"] as String?,
        contentType: MessageContentType.fromValue(
          parseNullableIntValue(json["ContentType"]) ?? 0,
        ),
        replyToMessageId: parseNullableIntValue(json["ReplyToMessageId"]),
        attachment: json["Attachment"] != null
            ? MediaAttachmentPayload.fromJson(
                json["Attachment"] as Map<String, dynamic>,
              )
            : null,
        attachments: (json["Attachments"] as List<dynamic>?)
            ?.map(
              (item) =>
                  MediaAttachmentPayload.fromJson(
                    item as Map<String, dynamic>,
                  ),
            )
            .toList(),
        parseMode: json["ParseMode"] as String?,
      );
  final int channelId;
  final String? content;
  final MessageContentType contentType;
  final int? replyToMessageId;
  final MediaAttachmentPayload? attachment;
  final List<MediaAttachmentPayload>? attachments;
  final String? parseMode;

  Map<String, dynamic> toJson() => {
    'ChannelId': channelId,
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

/// Channel message response payload
class ChannelMessageResponse {
  ChannelMessageResponse({
    required this.success,
    this.messageId = 0,
    this.messageText,
  });

  factory ChannelMessageResponse.fromJson(Map<String, dynamic> json) =>
      ChannelMessageResponse(
        success: json["Success"] as bool,
        messageId: parseNullableIntValue(json["MessageId"]) ?? 0,
        messageText: json["MessageText"] as String?,
      );

  factory ChannelMessageResponse.fromBytes(List<int> bytes) {
    return ChannelMessageResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final int messageId;
  final String? messageText;

  Map<String, dynamic> toJson() => {
    'Success': success,
    'MessageId': messageId,
    if (messageText != null) 'MessageText': messageText,
  };
}

/// Channel message entity
class ChannelMessage {
  ChannelMessage({
    required this.id,
    required this.channelId,
    required this.fromUserId,
    required this.content,
    required this.contentType,
    required this.createdAt,
    this.editedAt,
    this.isEdited = false,
    this.replyToMessageId,
    this.isPinned = false,
  });

  factory ChannelMessage.fromJson(Map<String, dynamic> json) => ChannelMessage(
    id: parseIntValue(json["Id"], fieldName: "ChannelMessage.Id"),
    channelId: parseIntValue(
      json["ChannelId"],
      fieldName: "ChannelMessage.ChannelId",
    ),
    fromUserId: parseIntValue(
      json["FromUserId"],
      fieldName: "ChannelMessage.FromUserId",
    ),
    content: json["Content"] as String,
    contentType: MessageContentType.fromValue(
      parseIntValue(
        json["ContentType"],
        fieldName: "ChannelMessage.ContentType",
      ),
    ),
    createdAt: parseNullableDateTimeValue(json["CreatedAt"]) ??
        DateTime.now().toUtc(),
    editedAt: parseNullableDateTimeValue(json["EditedAt"]),
    isEdited: json["IsEdited"] as bool? ?? false,
    replyToMessageId: parseNullableIntValue(json["ReplyToMessageId"]),
    isPinned: json["IsPinned"] as bool? ?? false,
  );
  final int id;
  final int channelId;
  final int fromUserId;
  final String content;
  final MessageContentType contentType;
  final DateTime createdAt;
  final DateTime? editedAt;
  final bool isEdited;
  final int? replyToMessageId;
  final bool isPinned;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'ChannelId': channelId,
    'FromUserId': fromUserId,
    'Content': content,
    'ContentType': contentType.value,
    'CreatedAt': createdAt.toIso8601String(),
    if (editedAt != null) 'EditedAt': editedAt!.toIso8601String(),
    'IsEdited': isEdited,
    if (replyToMessageId != null) 'ReplyToMessageId': replyToMessageId,
    'IsPinned': isPinned,
  };
}

/// Channel create request payload
class ChannelCreateRequest {
  ChannelCreateRequest({
    required this.name,
    this.description,
    this.type = ChannelType.public,
  });

  factory ChannelCreateRequest.fromJson(Map<String, dynamic> json) =>
      ChannelCreateRequest(
        name: json["Name"] as String,
        description: json["Description"] as String?,
        type: ChannelType.fromValue(
          parseNullableIntValue(json["Type"]) ?? 0,
        ),
      );
  final String name;
  final String? description;
  final ChannelType type;

  Map<String, dynamic> toJson() => {
    'Name': name,
    if (description != null) 'Description': description,
    'Type': type.value,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Channel create response payload
class ChannelCreateResponse {
  ChannelCreateResponse({
    required this.success,
    this.channelId = 0,
    this.message,
  });

  factory ChannelCreateResponse.fromJson(Map<String, dynamic> json) =>
      ChannelCreateResponse(
        success: json["Success"] as bool,
        channelId: parseNullableIntValue(json["ChannelId"]) ?? 0,
        message: json["Message"] as String?,
      );

  factory ChannelCreateResponse.fromBytes(List<int> bytes) {
    return ChannelCreateResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final int channelId;
  final String? message;

  Map<String, dynamic> toJson() => {
    'Success': success,
    'ChannelId': channelId,
    if (message != null) 'Message': message,
  };
}

/// Channel entity
class Channel {
  Channel({
    required this.id,
    required this.name,
    required this.type,
    required this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.memberCount,
    this.description,
    this.inviteCode,
    this.publicAlias,
  });

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
    id: parseIntValue(json["Id"], fieldName: "Channel.Id"),
    name: json["Name"] as String,
    description: json["Description"] as String?,
    type: ChannelType.fromValue(
      parseIntValue(json["Type"], fieldName: "Channel.Type"),
    ),
    createdByUserId: parseIntValue(
      json["CreatedByUserId"],
      fieldName: "Channel.CreatedByUserId",
    ),
    createdAt: parseNullableDateTimeValue(json["CreatedAt"]) ??
        DateTime.now().toUtc(),
    updatedAt: parseNullableDateTimeValue(json["UpdatedAt"]) ??
        DateTime.now().toUtc(),
    isActive: json["IsActive"] as bool,
    inviteCode: json["InviteCode"] as String?,
    publicAlias: json["PublicAlias"] as String?,
    memberCount: parseIntValue(
      json["MemberCount"],
      fieldName: "Channel.MemberCount",
    ),
  );
  final int id;
  final String name;
  final String? description;
  final ChannelType type;
  final int createdByUserId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? inviteCode;
  final String? publicAlias;
  final int memberCount;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Name': name,
    if (description != null) 'Description': description,
    'Type': type.value,
    'CreatedByUserId': createdByUserId,
    'CreatedAt': createdAt.toIso8601String(),
    'UpdatedAt': updatedAt.toIso8601String(),
    'IsActive': isActive,
    if (inviteCode != null) 'InviteCode': inviteCode,
    if (publicAlias != null) 'PublicAlias': publicAlias,
    'MemberCount': memberCount,
  };
}

/// Minimal channel info returned in join/create responses
class ChannelSummary {
  ChannelSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.memberCount,
    this.description,
  });

  factory ChannelSummary.fromJson(Map<String, dynamic> json) => ChannelSummary(
    id: parseIntValue(json["Id"], fieldName: "ChannelSummary.Id"),
    name: json["Name"] as String,
    description: json["Description"] as String?,
    type: ChannelType.fromValue(parseNullableIntValue(json["Type"]) ?? 0),
    memberCount: parseNullableIntValue(json["MemberCount"]) ?? 0,
  );
  final int id;
  final String name;
  final String? description;
  final ChannelType type;
  final int memberCount;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Name': name,
    if (description != null) 'Description': description,
    'Type': type.value,
    'MemberCount': memberCount,
  };
}

/// Channel join request payload
class ChannelJoinRequest {
  ChannelJoinRequest({required this.channelId});

  factory ChannelJoinRequest.fromJson(Map<String, dynamic> json) =>
      ChannelJoinRequest(
        channelId: parseIntValue(
          json["ChannelId"],
          fieldName: "ChannelJoinRequest.ChannelId",
        ),
      );
  final int channelId;

  Map<String, dynamic> toJson() => {'ChannelId': channelId};

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Channel join response payload
class ChannelJoinResponse {
  ChannelJoinResponse({required this.success, this.channel, this.message});

  factory ChannelJoinResponse.fromJson(Map<String, dynamic> json) =>
      ChannelJoinResponse(
        success: json["Success"] as bool,
        channel: json["Channel"] != null
            ? ChannelSummary.fromJson(
                json["Channel"] as Map<String, dynamic>)
            : null,
        message: json["Message"] as String?,
      );

  factory ChannelJoinResponse.fromBytes(List<int> bytes) {
    return ChannelJoinResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final ChannelSummary? channel;
  final String? message;

  Map<String, dynamic> toJson() => {
    'Success': success,
    if (channel != null) 'Channel': channel!.toJson(),
    if (message != null) 'Message': message,
  };
}

/// Channel history request payload
class ChannelHistoryRequest {
  ChannelHistoryRequest({
    required this.channelId,
    this.limit = 100,
    this.beforeMessageId,
  });
  final int channelId;
  final int limit;
  final int? beforeMessageId;

  Map<String, dynamic> toJson() => {
    'ChannelId': channelId,
    'Limit': limit,
    if (beforeMessageId != null) 'BeforeMessageId': beforeMessageId,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Channel history message item
class ChannelHistoryItem {
  ChannelHistoryItem({
    required this.id,
    required this.channelId,
    required this.fromUserId,
    required this.content,
    required this.contentType,
    required this.createdAt,
    this.deliveredTo = const <int>[],
    this.readBy = const <int>[],
    this.parseMode,
    this.fromUsername,
    this.channelName,
  });

  factory ChannelHistoryItem.fromJson(Map<String, dynamic> json) {
    final parsed = parseRichTextContent(json["Content"] as String);
    return ChannelHistoryItem(
      id: parseIntValue(json["Id"], fieldName: "ChannelHistoryItem.Id"),
      channelId: parseIntValue(
        json["ChannelId"],
        fieldName: "ChannelHistoryItem.ChannelId",
      ),
      fromUserId: parseIntValue(
        json["FromUserId"],
        fieldName: "ChannelHistoryItem.FromUserId",
      ),
      content: parsed.text,
      contentType: MessageContentType.fromValue(
        parseNullableIntValue(json["ContentType"]) ?? 0,
      ),
      createdAt: parseNullableDateTimeValue(json["CreatedAt"]) ??
          DateTime.now().toUtc(),
      deliveredTo: parseIntList(json["DeliveredTo"]),
      readBy: parseIntList(json["ReadBy"]),
      parseMode: parsed.parseMode,
      fromUsername: json["FromUsername"] as String?,
      channelName: json["ChannelName"] as String?,
    );
  }
  final int id;
  final int channelId;
  final int fromUserId;
  final String content;
  final MessageContentType contentType;
  final DateTime createdAt;
  final List<int> deliveredTo;
  final List<int> readBy;
  final String? parseMode;
  final String? fromUsername;
  final String? channelName;

  ParsedMediaAttachment? get attachment =>
      tryParseMediaAttachment(content, contentType);

  List<ParsedMediaAttachment> get attachments =>
      tryParseMediaAttachments(content, contentType)?.attachments ??
      const <ParsedMediaAttachment>[];
}

/// Channel history response payload
class ChannelHistoryResponse {
  ChannelHistoryResponse({
    required this.success,
    required this.channelId,
    required this.messages,
    this.channelName,
    this.message,
  });

  factory ChannelHistoryResponse.fromJson(Map<String, dynamic> json) =>
      ChannelHistoryResponse(
        success: json["Success"] as bool,
        channelId: parseNullableIntValue(json["ChannelId"]) ?? 0,
        channelName: json["ChannelName"] as String?,
        messages: (json["Messages"] as List<dynamic>? ?? const <dynamic>[])
            .map(
              (item) =>
                  ChannelHistoryItem.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        message: json["Message"] as String?,
      );

  factory ChannelHistoryResponse.fromBytes(List<int> bytes) {
    return ChannelHistoryResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final int channelId;
  final String? channelName;
  final List<ChannelHistoryItem> messages;
  final String? message;
}

/// Channel edit request payload
class ChannelEditRequest {
  ChannelEditRequest({
    required this.channelId,
    this.name,
    this.description,
    this.avatarUrl,
  });
  final int channelId;
  final String? name;
  final String? description;
  final String? avatarUrl;

  Map<String, dynamic> toJson() => {
    'ChannelId': channelId,
    if (name != null) 'Name': name,
    if (description != null) 'Description': description,
    if (avatarUrl != null) 'AvatarUrl': avatarUrl,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Response to a channel edit request
class ChannelEditResponse {
  ChannelEditResponse({required this.success, this.message});

  factory ChannelEditResponse.fromJson(Map<String, dynamic> json) =>
      ChannelEditResponse(
        success: json["Success"] as bool,
        message: json["Message"] as String?,
      );

  factory ChannelEditResponse.fromBytes(List<int> bytes) {
    return ChannelEditResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final String? message;
}

/// Channel members request
class ChannelMembersRequest {
  ChannelMembersRequest({required this.channelId});
  final int channelId;

  Map<String, dynamic> toJson() => {'ChannelId': channelId};
  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Channel members response
class ChannelMembersResponse {
  ChannelMembersResponse({
    required this.success,
    required this.channelId,
    required this.members,
    this.message,
  });

  factory ChannelMembersResponse.fromJson(Map<String, dynamic> json) =>
      ChannelMembersResponse(
        success: json["Success"] as bool,
        channelId: parseNullableIntValue(json["ChannelId"]) ?? 0,
        members: (json["Members"] as List<dynamic>? ?? const <dynamic>[])
            .map((item) => MemberSummary.fromJson(
                item as Map<String, dynamic>))
            .toList(),
        message: json["Message"] as String?,
      );

  factory ChannelMembersResponse.fromBytes(List<int> bytes) {
    return ChannelMembersResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final int channelId;
  final List<MemberSummary> members;
  final String? message;
}

/// Channel leave request
class ChannelLeaveRequest {
  ChannelLeaveRequest({required this.channelId});
  final int channelId;

  Map<String, dynamic> toJson() => {'ChannelId': channelId};
  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Channel leave response
class ChannelLeaveResponse {
  ChannelLeaveResponse({required this.success, this.message});

  factory ChannelLeaveResponse.fromJson(Map<String, dynamic> json) =>
      ChannelLeaveResponse(
        success: json["Success"] as bool,
        message: json["Message"] as String?,
      );

  factory ChannelLeaveResponse.fromBytes(List<int> bytes) {
    final raw = msgpack.deserialize(Uint8List.fromList(bytes));
    return ChannelLeaveResponse.fromJson(
      normalizeMsgPack(raw) as Map<String, dynamic>,
    );
  }
  final bool success;
  final String? message;
}

/// Request to update channel public alias or regenerate invite link
class ChannelLinkUpdateRequest {
  ChannelLinkUpdateRequest({
    required this.channelId,
    this.publicAlias,
    this.regeneratePrivateInvite = false,
  });
  final int channelId;
  final String? publicAlias;
  final bool regeneratePrivateInvite;

  Map<String, dynamic> toJson() => {
    'ChannelId': channelId,
    if (publicAlias != null) 'PublicAlias': publicAlias,
    'RegeneratePrivateInvite': regeneratePrivateInvite,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Request to get channel link info
class ChannelLinkRequest {
  ChannelLinkRequest({required this.channelId});
  final int channelId;

  Map<String, dynamic> toJson() => {'ChannelId': channelId};

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Request to resolve a channel by link or alias
class ChannelResolveRequest {
  ChannelResolveRequest({required this.linkOrAlias});
  final String linkOrAlias;

  Map<String, dynamic> toJson() => {'LinkOrAlias': linkOrAlias};

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Channel link info
class ChannelLinkInfo {
  ChannelLinkInfo({
    required this.channelId,
    required this.privateInviteLink,
    this.publicAlias,
    this.publicLink,
  });

  factory ChannelLinkInfo.fromJson(Map<String, dynamic> json) =>
      ChannelLinkInfo(
        channelId: json["ChannelId"] as int,
        publicAlias: json["PublicAlias"] as String?,
        publicLink: json["PublicLink"] as String?,
        privateInviteLink: json["PrivateInviteLink"] as String,
      );
  final int channelId;
  final String? publicAlias;
  final String? publicLink;
  final String privateInviteLink;
}

/// Channel link response
class ChannelLinkResponse {
  ChannelLinkResponse({required this.success, this.link, this.message});

  factory ChannelLinkResponse.fromJson(Map<String, dynamic> json) =>
      ChannelLinkResponse(
        success: json["Success"] as bool,
        link: json["Link"] != null
            ? ChannelLinkInfo.fromJson(
                json["Link"] as Map<String, dynamic>)
            : null,
        message: json["Message"] as String?,
      );

  factory ChannelLinkResponse.fromBytes(List<int> bytes) {
    return ChannelLinkResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final ChannelLinkInfo? link;
  final String? message;
}

/// Channel resolve response
class ChannelResolveResponse {
  ChannelResolveResponse({required this.success, this.channel, this.message});

  factory ChannelResolveResponse.fromJson(Map<String, dynamic> json) =>
      ChannelResolveResponse(
        success: json["Success"] as bool,
        channel: json["Channel"] != null
            ? ChannelSummary.fromJson(
                json["Channel"] as Map<String, dynamic>)
            : null,
        message: json["Message"] as String?,
      );

  factory ChannelResolveResponse.fromBytes(List<int> bytes) {
    return ChannelResolveResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final ChannelSummary? channel;
  final String? message;
}
