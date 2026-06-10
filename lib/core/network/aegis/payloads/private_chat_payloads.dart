import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/payloads/enums.dart';
import 'package:two_space_app/core/network/aegis/payloads/helpers.dart';

/// Private chat message request payload
class PrivateChatMessageRequest {
  PrivateChatMessageRequest({
    required this.toUserId,
    this.content,
    this.contentType = MessageContentType.text,
    this.attachment,
    this.attachments,
    this.parseMode,
  });

  factory PrivateChatMessageRequest.fromJson(Map<String, dynamic> json) =>
      PrivateChatMessageRequest(
        toUserId: json["ToUserId"] as int,
        content: json["Content"] as String?,
        contentType: MessageContentType.fromValue(
          json["ContentType"] as int? ?? 0,
        ),
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
  final int toUserId;
  final String? content;
  final MessageContentType contentType;
  final MediaAttachmentPayload? attachment;
  final List<MediaAttachmentPayload>? attachments;
  final String? parseMode;

  Map<String, dynamic> toJson() => {
    'ToUserId': toUserId,
    'Content': content,
    'ContentType': contentType.value,
    if (attachment != null) 'Attachment': attachment!.toJson(),
    if (attachments != null)
      'Attachments': attachments!.map((item) => item.toJson()).toList(),
    if (parseMode != null) 'ParseMode': parseMode,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Private chat message response payload
class PrivateChatMessageResponse {
  PrivateChatMessageResponse({
    required this.success,
    this.messageId = 0,
    this.messageText,
  });

  factory PrivateChatMessageResponse.fromJson(Map<String, dynamic> json) =>
      PrivateChatMessageResponse(
        success: json["Success"] as bool,
        messageId: json["MessageId"] as int? ?? 0,
        messageText: json["MessageText"] as String?,
      );

  factory PrivateChatMessageResponse.fromBytes(List<int> bytes) {
    return PrivateChatMessageResponse.fromJson(decodePayloadMap(bytes));
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

/// Private chat history request payload
class PrivateChatHistoryRequest {
  PrivateChatHistoryRequest({
    required this.peerUserId,
    this.limit = 100,
    this.beforeMessageId,
  });
  final int peerUserId;
  final int limit;
  final int? beforeMessageId;

  Map<String, dynamic> toJson() => {
    'PeerUserId': peerUserId,
    'Limit': limit,
    if (beforeMessageId != null) 'BeforeMessageId': beforeMessageId,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Private history message item
class PrivateChatHistoryItem {
  PrivateChatHistoryItem({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.content,
    required this.contentType,
    required this.createdAt,
    this.deliveredTo = const <int>[],
    this.readBy = const <int>[],
    this.parseMode,
    this.fromUsername,
    this.username,
  });

  factory PrivateChatHistoryItem.fromJson(Map<String, dynamic> json) {
    final parsed = parseRichTextContent(json["Content"] as String);
    return PrivateChatHistoryItem(
      id: parseIntValue(json["Id"], fieldName: "PrivateChatHistoryItem.Id"),
      fromUserId: parseIntValue(
        json["FromUserId"],
        fieldName: "PrivateChatHistoryItem.FromUserId",
      ),
      toUserId: parseIntValue(
        json["ToUserId"],
        fieldName: "PrivateChatHistoryItem.ToUserId",
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
      username: json["Username"] as String?,
    );
  }
  final int id;
  final int fromUserId;
  final int toUserId;
  final String content;
  final MessageContentType contentType;
  final DateTime createdAt;
  final List<int> deliveredTo;
  final List<int> readBy;
  final String? parseMode;
  final String? fromUsername;
  final String? username;

  ParsedMediaAttachment? get attachment =>
      tryParseMediaAttachment(content, contentType);

  List<ParsedMediaAttachment> get attachments =>
      tryParseMediaAttachments(content, contentType)?.attachments ??
      const <ParsedMediaAttachment>[];
}

/// Private chat history response payload
class PrivateChatHistoryResponse {
  PrivateChatHistoryResponse({
    required this.success,
    required this.peerUserId,
    required this.messages,
    this.message,
  });

  factory PrivateChatHistoryResponse.fromJson(Map<String, dynamic> json) =>
      PrivateChatHistoryResponse(
        success: json["Success"] as bool,
        peerUserId: json["PeerUserId"] as int? ?? 0,
        messages: (json["Messages"] as List<dynamic>? ?? const <dynamic>[])
            .map(
              (item) =>
                  PrivateChatHistoryItem.fromJson(
                    item as Map<String, dynamic>,
                  ),
            )
            .toList(),
        message: json["Message"] as String?,
      );

  factory PrivateChatHistoryResponse.fromBytes(List<int> bytes) {
    return PrivateChatHistoryResponse.fromJson(decodePayloadMap(bytes));
  }
  final bool success;
  final int peerUserId;
  final List<PrivateChatHistoryItem> messages;
  final String? message;
}

/// Incoming private message event payload
class PrivateChatMessageEvent {
  PrivateChatMessageEvent({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.content,
    required this.contentType,
    required this.createdAt,
    this.replyToMessageId,
    this.deliveredTo = const <int>[],
    this.readBy = const <int>[],
    this.parseMode,
    this.fromUsername,
    this.username,
  });

  factory PrivateChatMessageEvent.fromJson(Map<String, dynamic> json) {
    final parsed = parseRichTextContent(json["Content"] as String);
    return PrivateChatMessageEvent(
      id: parseIntValue(
        json["Id"],
        fieldName: "PrivateChatMessageEvent.Id",
      ),
      fromUserId: parseIntValue(
        json["FromUserId"],
        fieldName: "PrivateChatMessageEvent.FromUserId",
      ),
      toUserId: parseIntValue(
        json["ToUserId"],
        fieldName: "PrivateChatMessageEvent.ToUserId",
      ),
      content: parsed.text,
      contentType: MessageContentType.fromValue(
        parseNullableIntValue(json["ContentType"]) ?? 0,
      ),
      createdAt: parseNullableDateTimeValue(json["CreatedAt"]) ??
          DateTime.now().toUtc(),
      replyToMessageId: parseNullableIntValue(json["ReplyToMessageId"]),
      deliveredTo: parseIntList(json["DeliveredTo"]),
      readBy: parseIntList(json["ReadBy"]),
      parseMode: parsed.parseMode,
      fromUsername: json["FromUsername"] as String?,
      username: json["Username"] as String?,
    );
  }

  factory PrivateChatMessageEvent.fromBytes(List<int> bytes) {
    return PrivateChatMessageEvent.fromJson(decodePayloadMap(bytes));
  }
  final int id;
  final int fromUserId;
  final int toUserId;
  final String content;
  final MessageContentType contentType;
  final DateTime createdAt;
  final int? replyToMessageId;
  final List<int> deliveredTo;
  final List<int> readBy;
  final String? parseMode;
  final String? fromUsername;
  final String? username;

  ParsedMediaAttachment? get attachment =>
      tryParseMediaAttachment(content, contentType);

  List<ParsedMediaAttachment> get attachments =>
      tryParseMediaAttachments(content, contentType)?.attachments ??
      const <ParsedMediaAttachment>[];
}

/// Incoming channel message event payload
class ChannelMessageEvent {
  ChannelMessageEvent({
    required this.id,
    required this.channelId,
    required this.fromUserId,
    required this.content,
    required this.contentType,
    required this.createdAt,
    this.replyToMessageId,
    this.deliveredTo = const <int>[],
    this.readBy = const <int>[],
    this.parseMode,
    this.fromUsername,
    this.channelName,
  });

  factory ChannelMessageEvent.fromJson(Map<String, dynamic> json) {
    final parsed = parseRichTextContent(json["Content"] as String);
    return ChannelMessageEvent(
      id: parseIntValue(json["Id"], fieldName: "ChannelMessageEvent.Id"),
      channelId: parseIntValue(
        json["ChannelId"],
        fieldName: "ChannelMessageEvent.ChannelId",
      ),
      fromUserId: parseIntValue(
        json["FromUserId"],
        fieldName: "ChannelMessageEvent.FromUserId",
      ),
      content: parsed.text,
      contentType: MessageContentType.fromValue(
        parseNullableIntValue(json["ContentType"]) ?? 0,
      ),
      createdAt: parseNullableDateTimeValue(json["CreatedAt"]) ??
          DateTime.now().toUtc(),
      replyToMessageId: parseNullableIntValue(json["ReplyToMessageId"]),
      deliveredTo: parseIntList(json["DeliveredTo"]),
      readBy: parseIntList(json["ReadBy"]),
      parseMode: parsed.parseMode,
      fromUsername: json["FromUsername"] as String?,
      channelName: json["ChannelName"] as String?,
    );
  }

  factory ChannelMessageEvent.fromBytes(List<int> bytes) {
    return ChannelMessageEvent.fromJson(decodePayloadMap(bytes));
  }
  final int id;
  final int channelId;
  final int fromUserId;
  final String content;
  final MessageContentType contentType;
  final DateTime createdAt;
  final int? replyToMessageId;
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

/// Message entity (stored/delivered message, not the wire-level frame)
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.content,
    required this.contentType,
    required this.sequenceNumber,
    required this.createdAt,
    this.isDelivered = false,
    this.isRead = false,
    this.parseMode,
    this.deliveredAt,
    this.readAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final parsed = parseRichTextContent(json["Content"] as String);
    return ChatMessage(
      id: parseIntValue(json["Id"], fieldName: "ChatMessage.Id"),
      fromUserId: parseIntValue(
        json["FromUserId"],
        fieldName: "ChatMessage.FromUserId",
      ),
      toUserId: parseIntValue(
        json["ToUserId"],
        fieldName: "ChatMessage.ToUserId",
      ),
      content: parsed.text,
      contentType: MessageContentType.fromValue(
        parseIntValue(
          json["ContentType"],
          fieldName: "ChatMessage.ContentType",
        ),
      ),
      sequenceNumber: parseIntValue(
        json["SequenceNumber"],
        fieldName: "ChatMessage.SequenceNumber",
      ),
      isDelivered: json["IsDelivered"] as bool? ?? false,
      isRead: json["IsRead"] as bool? ?? false,
      parseMode: parsed.parseMode,
      createdAt: parseNullableDateTimeValue(json["CreatedAt"]) ??
          DateTime.now().toUtc(),
      deliveredAt: parseNullableDateTimeValue(json["DeliveredAt"]),
      readAt: parseNullableDateTimeValue(json["ReadAt"]),
    );
  }
  final int id;
  final int fromUserId;
  final int toUserId;
  final String content;
  final MessageContentType contentType;
  final int sequenceNumber;
  final bool isDelivered;
  final bool isRead;
  final String? parseMode;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'FromUserId': fromUserId,
    'ToUserId': toUserId,
    'Content': content,
    'ContentType': contentType.value,
    'SequenceNumber': sequenceNumber,
    'IsDelivered': isDelivered,
    'IsRead': isRead,
    if (parseMode != null) 'ParseMode': parseMode,
    'CreatedAt': createdAt.toIso8601String(),
    if (deliveredAt != null) 'DeliveredAt': deliveredAt!.toIso8601String(),
    if (readAt != null) 'ReadAt': readAt!.toIso8601String(),
  };

  ParsedMediaAttachment? get attachment =>
      tryParseMediaAttachment(content, contentType);

  List<ParsedMediaAttachment> get attachments =>
      tryParseMediaAttachments(content, contentType)?.attachments ??
      const <ParsedMediaAttachment>[];
}

/// Private chat entity
class PrivateChat {
  PrivateChat({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    this.lastActivityAt,
    this.lastMessageId,
    this.isActive = true,
    this.lastMessage,
  });

  factory PrivateChat.fromJson(Map<String, dynamic> json) => PrivateChat(
    id: parseIntValue(json["Id"], fieldName: "PrivateChat.Id"),
    user1Id: parseIntValue(
      json["User1Id"],
      fieldName: "PrivateChat.User1Id",
    ),
    user2Id: parseIntValue(
      json["User2Id"],
      fieldName: "PrivateChat.User2Id",
    ),
    createdAt: parseNullableDateTimeValue(json["CreatedAt"]) ??
        DateTime.now().toUtc(),
    lastActivityAt: parseNullableDateTimeValue(json["LastActivityAt"]),
    lastMessageId: parseNullableIntValue(json["LastMessageId"]),
    isActive: json["IsActive"] as bool? ?? true,
    lastMessage: json["LastMessage"] != null
        ? ChatMessage.fromJson(
            json["LastMessage"] as Map<String, dynamic>)
        : null,
  );
  final int id;
  final int user1Id;
  final int user2Id;
  final DateTime createdAt;
  final DateTime? lastActivityAt;
  final int? lastMessageId;
  final bool isActive;
  final ChatMessage? lastMessage;

  Map<String, dynamic> toJson() => {
    'Id': id,
    'User1Id': user1Id,
    'User2Id': user2Id,
    'CreatedAt': createdAt.toIso8601String(),
    if (lastActivityAt != null)
      'LastActivityAt': lastActivityAt!.toIso8601String(),
    if (lastMessageId != null) 'LastMessageId': lastMessageId,
    'IsActive': isActive,
    if (lastMessage != null) 'LastMessage': lastMessage!.toJson(),
  };
}

/// Chat list request payload
class ChatListRequest {
  Map<String, dynamic> toJson() => <String, dynamic>{};
  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Chat list response item
class ChatListItem {
  ChatListItem({
    required this.chatId,
    required this.type,
    required this.title,
    this.avatarUrl,
    this.presenceStatus,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.peerUserId,
    this.channelId,
  });

  factory ChatListItem.fromJson(Map<String, dynamic> json) => ChatListItem(
    chatId: parseIntValue(json["ChatId"], fieldName: "ChatListItem.ChatId"),
    type: json["Type"] as String,
    title: json["Title"] as String,
    avatarUrl: json["AvatarUrl"] as String?,
    presenceStatus: json["PresenceStatus"] as String?,
    lastMessage: json["LastMessage"] as String?,
    lastMessageAt: parseNullableDateTimeValue(json["LastMessageAt"]),
    unreadCount: parseNullableIntValue(json["UnreadCount"]) ?? 0,
    peerUserId: parseNullableIntValue(json["PeerUserId"]),
    channelId: parseNullableIntValue(json["ChannelId"]),
  );
  final int chatId;
  final String type;
  final String title;
  final String? avatarUrl;
  final String? presenceStatus;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final int? peerUserId;
  final int? channelId;

  int get roomTargetId => peerUserId ?? channelId ?? chatId;
}

/// Chat list response payload
class ChatListResponse {
  ChatListResponse(
      {required this.success, required this.chats, this.message});

  factory ChatListResponse.fromJson(Map<String, dynamic> json) =>
      ChatListResponse(
        success: json["Success"] as bool,
        chats: (json["Chats"] as List<dynamic>? ?? const <dynamic>[])
            .map((item) =>
                ChatListItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        message: json["Message"] as String?,
      );

  factory ChatListResponse.fromBytes(List<int> bytes) {
    final json = decodePayloadMap(bytes);
    return ChatListResponse.fromJson(json);
  }
  final bool success;
  final List<ChatListItem> chats;
  final String? message;
}
