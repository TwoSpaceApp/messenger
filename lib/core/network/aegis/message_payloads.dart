import 'dart:convert';

/// Message content types
enum MessageContentType {
  text(0),
  image(1),
  video(2),
  audio(3),
  file(4),
  location(5);

  const MessageContentType(this.value);
  final int value;

  static MessageContentType fromValue(int value) {
    return MessageContentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MessageContentType.text,
    );
  }
}

/// Channel types
enum ChannelType {
  public(0),
  private(1),
  group(2);

  const ChannelType(this.value);
  final int value;

  static ChannelType fromValue(int value) {
    return ChannelType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ChannelType.public,
    );
  }
}

/// Registration request payload
class RegistrationRequest {
  RegistrationRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.publicKey,
  });

  factory RegistrationRequest.fromJson(Map<String, dynamic> json) =>
      RegistrationRequest(
        username: json['Username'] as String,
        email: json['Email'] as String,
        password: json['Password'] as String,
        publicKey: json['PublicKey'] as String,
      );
  final String username;
  final String email;
  final String password;
  final String publicKey;

  Map<String, dynamic> toJson() => {
        'Username': username,
        'Email': email,
        'Password': password,
        'PublicKey': publicKey,
      };

  List<int> toBytes() => utf8.encode(jsonEncode(toJson()));
}

/// Registration response payload
class RegistrationResponse {
  RegistrationResponse({
    required this.success,
    this.message,
    this.user,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) =>
      RegistrationResponse(
        success: json['Success'] as bool,
        message: json['Message'] as String?,
        user: json['User'] != null
            ? User.fromJson(json['User'] as Map<String, dynamic>)
            : null,
      );

  factory RegistrationResponse.fromBytes(List<int> bytes) {
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return RegistrationResponse.fromJson(json);
  }
  final bool success;
  final String? message;
  final User? user;

  Map<String, dynamic> toJson() => {
        'Success': success,
        if (message != null) 'Message': message,
        if (user != null) 'User': user!.toJson(),
      };
}

/// User search request payload
class UserSearchRequest {
  UserSearchRequest({
    required this.query,
    this.limit = 20,
  });

  factory UserSearchRequest.fromJson(Map<String, dynamic> json) =>
      UserSearchRequest(
        query: json['Query'] as String,
        limit: json['Limit'] as int? ?? 20,
      );
  final String query;
  final int limit;

  Map<String, dynamic> toJson() => {
        'Query': query,
        'Limit': limit,
      };

  List<int> toBytes() => utf8.encode(jsonEncode(toJson()));
}

/// User search response payload
class UserSearchResponse {
  UserSearchResponse({
    required this.success,
    required this.users,
    this.message,
  });

  factory UserSearchResponse.fromJson(Map<String, dynamic> json) =>
      UserSearchResponse(
        success: json['Success'] as bool,
        users: (json['Users'] as List<dynamic>)
            .map((u) => UserSearchResult.fromJson(u as Map<String, dynamic>))
            .toList(),
        message: json['Message'] as String?,
      );

  factory UserSearchResponse.fromBytes(List<int> bytes) {
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return UserSearchResponse.fromJson(json);
  }
  final bool success;
  final List<UserSearchResult> users;
  final String? message;

  Map<String, dynamic> toJson() => {
        'Success': success,
        'Users': users.map((u) => u.toJson()).toList(),
        if (message != null) 'Message': message,
      };
}

/// User search result item
class UserSearchResult {
  UserSearchResult({
    required this.id,
    required this.username,
    this.email,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) =>
      UserSearchResult(
        id: json['Id'] as int,
        username: json['Username'] as String,
        email: json['Email'] as String?,
      );
  final int id;
  final String username;
  final String? email;

  Map<String, dynamic> toJson() => {
        'Id': id,
        'Username': username,
        if (email != null) 'Email': email,
      };
}

/// User entity
class User {
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.publicKey,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.identityKeyFingerprint,
    this.lastSeenAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['Id'] as int,
        username: json['Username'] as String,
        email: json['Email'] as String? ?? '',
        publicKey: json['PublicKey'] as String? ?? '',
        identityKeyFingerprint: json['IdentityKeyFingerprint'] as String?,
        isActive: json['IsActive'] as bool? ?? true,
        createdAt: DateTime.tryParse(json['CreatedAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt: DateTime.tryParse(json['UpdatedAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        lastSeenAt: json['LastSeenAt'] != null
            ? DateTime.parse(json['LastSeenAt'] as String)
            : null,
      );
  final int id;
  final String username;
  final String email;
  final String publicKey;
  final String? identityKeyFingerprint;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSeenAt;

  Map<String, dynamic> toJson() => {
        'Id': id,
        'Username': username,
        'Email': email,
        'PublicKey': publicKey,
        if (identityKeyFingerprint != null)
          'IdentityKeyFingerprint': identityKeyFingerprint,
        'IsActive': isActive,
        'CreatedAt': createdAt.toIso8601String(),
        'UpdatedAt': updatedAt.toIso8601String(),
        if (lastSeenAt != null) 'LastSeenAt': lastSeenAt!.toIso8601String(),
      };
}

/// Channel message request payload
class ChannelMessageRequest {
  ChannelMessageRequest({
    required this.channelId,
    required this.content,
    this.contentType = MessageContentType.text,
    this.replyToMessageId,
  });

  factory ChannelMessageRequest.fromJson(Map<String, dynamic> json) =>
      ChannelMessageRequest(
        channelId: json['ChannelId'] as int,
        content: json['Content'] as String,
        contentType:
            MessageContentType.fromValue(json['ContentType'] as int? ?? 0),
        replyToMessageId: json['ReplyToMessageId'] as int?,
      );
  final int channelId;
  final String content;
  final MessageContentType contentType;
  final int? replyToMessageId;

  Map<String, dynamic> toJson() => {
        'ChannelId': channelId,
        'Content': content,
        'ContentType': contentType.value,
        if (replyToMessageId != null) 'ReplyToMessageId': replyToMessageId,
      };

  List<int> toBytes() => utf8.encode(jsonEncode(toJson()));
}

/// Channel message response payload
class ChannelMessageResponse {
  ChannelMessageResponse({
    required this.success,
    this.messageId,
    this.message,
    this.messageText,
  });

  factory ChannelMessageResponse.fromJson(Map<String, dynamic> json) =>
      ChannelMessageResponse(
        success: json['Success'] as bool,
        messageId: json['MessageId'] as int?,
        message: json['Message'] != null
            ? ChannelMessage.fromJson(json['Message'] as Map<String, dynamic>)
            : null,
        messageText: json['MessageText'] as String?,
      );

  factory ChannelMessageResponse.fromBytes(List<int> bytes) {
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return ChannelMessageResponse.fromJson(json);
  }
  final bool success;
    final int? messageId;
  final ChannelMessage? message;
  final String? messageText;

  Map<String, dynamic> toJson() => {
        'Success': success,
      if (messageId != null) 'MessageId': messageId,
        if (message != null) 'Message': message!.toJson(),
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
        id: json['Id'] as int,
        channelId: json['ChannelId'] as int,
        fromUserId: json['FromUserId'] as int,
        content: json['Content'] as String,
        contentType: MessageContentType.fromValue(json['ContentType'] as int),
        createdAt: DateTime.parse(json['CreatedAt'] as String),
        editedAt: json['EditedAt'] != null
            ? DateTime.parse(json['EditedAt'] as String)
            : null,
        isEdited: json['IsEdited'] as bool? ?? false,
        replyToMessageId: json['ReplyToMessageId'] as int?,
        isPinned: json['IsPinned'] as bool? ?? false,
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
        name: json['Name'] as String,
        description: json['Description'] as String?,
        type: ChannelType.fromValue(json['Type'] as int? ?? 0),
      );
  final String name;
  final String? description;
  final ChannelType type;

  Map<String, dynamic> toJson() => {
        'Name': name,
        if (description != null) 'Description': description,
        'Type': type.value,
      };

  List<int> toBytes() => utf8.encode(jsonEncode(toJson()));
}

/// Channel create response payload
class ChannelCreateResponse {
  ChannelCreateResponse({
    required this.success,
    this.channel,
    this.channelId,
    this.message,
  });

  factory ChannelCreateResponse.fromJson(Map<String, dynamic> json) =>
      ChannelCreateResponse(
        success: json['Success'] as bool,
        channel: json['Channel'] != null
            ? Channel.fromJson(json['Channel'] as Map<String, dynamic>)
            : null,
        channelId: json['ChannelId'] as int?,
        message: json['Message'] as String?,
      );

  factory ChannelCreateResponse.fromBytes(List<int> bytes) {
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return ChannelCreateResponse.fromJson(json);
  }
  final bool success;
  final Channel? channel;
    final int? channelId;
  final String? message;

  Map<String, dynamic> toJson() => {
        'Success': success,
        if (channel != null) 'Channel': channel!.toJson(),
      if (channelId != null) 'ChannelId': channelId,
        if (message != null) 'Message': message,
      };
}

class ChatListRequest {
  Map<String, dynamic> toJson() => <String, dynamic>{};

  List<int> toBytes() => utf8.encode(jsonEncode(toJson()));
}

class ChatListItem {
  ChatListItem({
    required this.chatId,
    required this.type,
    required this.title,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.peerUserId,
    this.channelId,
  });

  factory ChatListItem.fromJson(Map<String, dynamic> json) => ChatListItem(
        chatId: json['ChatId'] as int,
        type: json['Type'] as String,
        title: json['Title'] as String,
        avatarUrl: json['AvatarUrl'] as String?,
        lastMessage: json['LastMessage'] as String?,
        lastMessageAt: json['LastMessageAt'] != null
            ? DateTime.parse(json['LastMessageAt'] as String)
            : null,
        unreadCount: json['UnreadCount'] as int? ?? 0,
        peerUserId: json['PeerUserId'] as int?,
        channelId: json['ChannelId'] as int?,
      );

  final int chatId;
  final String type;
  final String title;
  final String? avatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final int? peerUserId;
  final int? channelId;
}

class ChatListResponse {
  ChatListResponse({
    required this.success,
    required this.chats,
    this.message,
  });

  factory ChatListResponse.fromJson(Map<String, dynamic> json) =>
      ChatListResponse(
        success: json['Success'] as bool,
        chats: (json['Chats'] as List<dynamic>? ?? const <dynamic>[])
            .map((item) => ChatListItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        message: json['Message'] as String?,
      );

  factory ChatListResponse.fromBytes(List<int> bytes) {
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return ChatListResponse.fromJson(json);
  }

  final bool success;
  final List<ChatListItem> chats;
  final String? message;
}

class PrivateChatHistoryRequest {
  PrivateChatHistoryRequest({
    required this.peerUserId,
    this.limit = 50,
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

  List<int> toBytes() => utf8.encode(jsonEncode(toJson()));
}

class PrivateChatHistoryItem {
  PrivateChatHistoryItem({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.content,
    required this.contentType,
    required this.createdAt,
    this.fromUsername,
    this.username,
  });

  factory PrivateChatHistoryItem.fromJson(Map<String, dynamic> json) =>
      PrivateChatHistoryItem(
        id: json['Id'] as int,
        fromUserId: json['FromUserId'] as int,
        toUserId: json['ToUserId'] as int,
        content: json['Content'] as String,
        contentType:
            MessageContentType.fromValue(json['ContentType'] as int? ?? 0),
        createdAt: DateTime.parse(json['CreatedAt'] as String),
        fromUsername: json['FromUsername'] as String?,
        username: json['Username'] as String?,
      );

  final int id;
  final int fromUserId;
  final int toUserId;
  final String content;
  final MessageContentType contentType;
  final DateTime createdAt;
  final String? fromUsername;
  final String? username;
}

class PrivateChatHistoryResponse {
  PrivateChatHistoryResponse({
    required this.success,
    required this.peerUserId,
    required this.messages,
    this.message,
  });

  factory PrivateChatHistoryResponse.fromJson(Map<String, dynamic> json) =>
      PrivateChatHistoryResponse(
        success: json['Success'] as bool,
        peerUserId: json['PeerUserId'] as int? ?? 0,
        messages: (json['Messages'] as List<dynamic>? ?? const <dynamic>[])
            .map(
              (item) => PrivateChatHistoryItem.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(),
        message: json['Message'] as String?,
      );

  factory PrivateChatHistoryResponse.fromBytes(List<int> bytes) {
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return PrivateChatHistoryResponse.fromJson(json);
  }

  final bool success;
  final int peerUserId;
  final List<PrivateChatHistoryItem> messages;
  final String? message;
}

class ChannelHistoryRequest {
  ChannelHistoryRequest({
    required this.channelId,
    this.limit = 50,
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

  List<int> toBytes() => utf8.encode(jsonEncode(toJson()));
}

class ChannelHistoryItem {
  ChannelHistoryItem({
    required this.id,
    required this.channelId,
    required this.fromUserId,
    required this.content,
    required this.contentType,
    required this.createdAt,
    this.fromUsername,
    this.channelName,
  });

  factory ChannelHistoryItem.fromJson(Map<String, dynamic> json) =>
      ChannelHistoryItem(
        id: json['Id'] as int,
        channelId: json['ChannelId'] as int,
        fromUserId: json['FromUserId'] as int,
        content: json['Content'] as String,
        contentType:
            MessageContentType.fromValue(json['ContentType'] as int? ?? 0),
        createdAt: DateTime.parse(json['CreatedAt'] as String),
        fromUsername: json['FromUsername'] as String?,
        channelName: json['ChannelName'] as String?,
      );

  final int id;
  final int channelId;
  final int fromUserId;
  final String content;
  final MessageContentType contentType;
  final DateTime createdAt;
  final String? fromUsername;
  final String? channelName;
}

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
        success: json['Success'] as bool,
        channelId: json['ChannelId'] as int? ?? 0,
        channelName: json['ChannelName'] as String?,
        messages: (json['Messages'] as List<dynamic>? ?? const <dynamic>[])
            .map(
              (item) => ChannelHistoryItem.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(),
        message: json['Message'] as String?,
      );

  factory ChannelHistoryResponse.fromBytes(List<int> bytes) {
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return ChannelHistoryResponse.fromJson(json);
  }

  final bool success;
  final int channelId;
  final String? channelName;
  final List<ChannelHistoryItem> messages;
  final String? message;
}

class PrivateChatMessageEvent {
  PrivateChatMessageEvent({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.content,
    required this.contentType,
    required this.createdAt,
    this.fromUsername,
    this.username,
  });

  factory PrivateChatMessageEvent.fromJson(Map<String, dynamic> json) =>
      PrivateChatMessageEvent(
        id: json['Id'] as int,
        fromUserId: json['FromUserId'] as int,
        toUserId: json['ToUserId'] as int,
        content: json['Content'] as String,
        contentType:
            MessageContentType.fromValue(json['ContentType'] as int? ?? 0),
        createdAt: DateTime.parse(json['CreatedAt'] as String),
        fromUsername: json['FromUsername'] as String?,
        username: json['Username'] as String?,
      );

  factory PrivateChatMessageEvent.fromBytes(List<int> bytes) {
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return PrivateChatMessageEvent.fromJson(json);
  }

  final int id;
  final int fromUserId;
  final int toUserId;
  final String content;
  final MessageContentType contentType;
  final DateTime createdAt;
  final String? fromUsername;
  final String? username;
}

class ChannelMessageEvent {
  ChannelMessageEvent({
    required this.id,
    required this.channelId,
    required this.fromUserId,
    required this.content,
    required this.contentType,
    required this.createdAt,
    this.fromUsername,
    this.channelName,
  });

  factory ChannelMessageEvent.fromJson(Map<String, dynamic> json) =>
      ChannelMessageEvent(
        id: json['Id'] as int,
        channelId: json['ChannelId'] as int,
        fromUserId: json['FromUserId'] as int,
        content: json['Content'] as String,
        contentType:
            MessageContentType.fromValue(json['ContentType'] as int? ?? 0),
        createdAt: DateTime.parse(json['CreatedAt'] as String),
        fromUsername: json['FromUsername'] as String?,
        channelName: json['ChannelName'] as String?,
      );

  factory ChannelMessageEvent.fromBytes(List<int> bytes) {
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return ChannelMessageEvent.fromJson(json);
  }

  final int id;
  final int channelId;
  final int fromUserId;
  final String content;
  final MessageContentType contentType;
  final DateTime createdAt;
  final String? fromUsername;
  final String? channelName;
}

class MessageEditRequest {
  MessageEditRequest({
    required this.messageId,
    required this.newContent,
    this.scope = 'private',
    this.channelId,
    this.groupId,
  });

  final int messageId;
  final String newContent;
  final String scope;
  final int? channelId;
  final int? groupId;

  Map<String, dynamic> toJson() => {
        'MessageId': messageId,
        'NewContent': newContent,
        'Scope': scope,
        if (channelId != null) 'ChannelId': channelId,
        if (groupId != null) 'GroupId': groupId,
      };

  List<int> toBytes() => utf8.encode(jsonEncode(toJson()));
}

class MessageEditResponse {
  MessageEditResponse({
    required this.success,
    this.message,
    this.messageId = 0,
  });

  factory MessageEditResponse.fromJson(Map<String, dynamic> json) =>
      MessageEditResponse(
        success: json['Success'] as bool,
        message: json['Message'] as String?,
        messageId: json['MessageId'] as int? ?? 0,
      );

  factory MessageEditResponse.fromBytes(List<int> bytes) {
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return MessageEditResponse.fromJson(json);
  }

  final bool success;
  final String? message;
  final int messageId;
}

class MessageDeleteRequest {
  MessageDeleteRequest({
    required this.messageId,
    this.scope = 'private',
    this.channelId,
    this.groupId,
  });

  final int messageId;
  final String scope;
  final int? channelId;
  final int? groupId;

  Map<String, dynamic> toJson() => {
        'MessageId': messageId,
        'Scope': scope,
        if (channelId != null) 'ChannelId': channelId,
        if (groupId != null) 'GroupId': groupId,
      };

  List<int> toBytes() => utf8.encode(jsonEncode(toJson()));
}

class MessageDeleteResponse {
  MessageDeleteResponse({
    required this.success,
    this.message,
    this.messageId = 0,
  });

  factory MessageDeleteResponse.fromJson(Map<String, dynamic> json) =>
      MessageDeleteResponse(
        success: json['Success'] as bool,
        message: json['Message'] as String?,
        messageId: json['MessageId'] as int? ?? 0,
      );

  factory MessageDeleteResponse.fromBytes(List<int> bytes) {
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return MessageDeleteResponse.fromJson(json);
  }

  final bool success;
  final String? message;
  final int messageId;
}

class MemberRoleUpdateRequest {
  MemberRoleUpdateRequest({
    required this.scope,
    required this.targetId,
    required this.targetUserId,
    required this.newRole,
  });

  final String scope;
  final int targetId;
  final int targetUserId;
  final int newRole;

  Map<String, dynamic> toJson() => {
        'Scope': scope,
        'TargetId': targetId,
        'TargetUserId': targetUserId,
        'NewRole': newRole,
      };

  List<int> toBytes() => utf8.encode(jsonEncode(toJson()));
}

class MemberRoleUpdateResponse {
  MemberRoleUpdateResponse({
    required this.success,
    this.message,
  });

  factory MemberRoleUpdateResponse.fromJson(Map<String, dynamic> json) =>
      MemberRoleUpdateResponse(
        success: json['Success'] as bool,
        message: json['Message'] as String?,
      );

  factory MemberRoleUpdateResponse.fromBytes(List<int> bytes) {
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return MemberRoleUpdateResponse.fromJson(json);
  }

  final bool success;
  final String? message;
}

class MemberPermissionUpdateRequest {
  MemberPermissionUpdateRequest({
    required this.scope,
    required this.targetId,
    required this.targetUserId,
    this.canSendMessages,
    this.canDeleteOthersMessages,
    this.canEditInfo,
    this.canInviteUsers,
    this.canRemoveUsers,
    this.canPinMessages,
    this.canManageRoles,
  });

  final String scope;
  final int targetId;
  final int targetUserId;
  final bool? canSendMessages;
  final bool? canDeleteOthersMessages;
  final bool? canEditInfo;
  final bool? canInviteUsers;
  final bool? canRemoveUsers;
  final bool? canPinMessages;
  final bool? canManageRoles;

  Map<String, dynamic> toJson() => {
        'Scope': scope,
        'TargetId': targetId,
        'TargetUserId': targetUserId,
        if (canSendMessages != null) 'CanSendMessages': canSendMessages,
        if (canDeleteOthersMessages != null)
          'CanDeleteOthersMessages': canDeleteOthersMessages,
        if (canEditInfo != null) 'CanEditInfo': canEditInfo,
        if (canInviteUsers != null) 'CanInviteUsers': canInviteUsers,
        if (canRemoveUsers != null) 'CanRemoveUsers': canRemoveUsers,
        if (canPinMessages != null) 'CanPinMessages': canPinMessages,
        if (canManageRoles != null) 'CanManageRoles': canManageRoles,
      };

  List<int> toBytes() => utf8.encode(jsonEncode(toJson()));
}

class MemberPermissionUpdateResponse {
  MemberPermissionUpdateResponse({
    required this.success,
    this.message,
  });

  factory MemberPermissionUpdateResponse.fromJson(Map<String, dynamic> json) =>
      MemberPermissionUpdateResponse(
        success: json['Success'] as bool,
        message: json['Message'] as String?,
      );

  factory MemberPermissionUpdateResponse.fromBytes(List<int> bytes) {
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return MemberPermissionUpdateResponse.fromJson(json);
  }

  final bool success;
  final String? message;
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
  });

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
        id: json['Id'] as int,
        name: json['Name'] as String,
        description: json['Description'] as String?,
        type: ChannelType.fromValue(json['Type'] as int),
        createdByUserId: json['CreatedByUserId'] as int,
        createdAt: DateTime.parse(json['CreatedAt'] as String),
        updatedAt: DateTime.parse(json['UpdatedAt'] as String),
        isActive: json['IsActive'] as bool,
        inviteCode: json['InviteCode'] as String?,
        memberCount: json['MemberCount'] as int,
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
        'MemberCount': memberCount,
      };
}

/// Channel join request payload
class ChannelJoinRequest {
  ChannelJoinRequest({
    required this.channelId,
  });

  factory ChannelJoinRequest.fromJson(Map<String, dynamic> json) =>
      ChannelJoinRequest(
        channelId: json['ChannelId'] as int,
      );
  final int channelId;

  Map<String, dynamic> toJson() => {
        'ChannelId': channelId,
      };

  List<int> toBytes() => utf8.encode(jsonEncode(toJson()));
}

/// Channel join response payload
class ChannelJoinResponse {
  ChannelJoinResponse({
    required this.success,
    this.channel,
    this.message,
  });

  factory ChannelJoinResponse.fromJson(Map<String, dynamic> json) =>
      ChannelJoinResponse(
        success: json['Success'] as bool,
        channel: json['Channel'] != null
            ? Channel.fromJson(json['Channel'] as Map<String, dynamic>)
            : null,
        message: json['Message'] as String?,
      );

  factory ChannelJoinResponse.fromBytes(List<int> bytes) {
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return ChannelJoinResponse.fromJson(json);
  }
  final bool success;
  final Channel? channel;
  final String? message;

  Map<String, dynamic> toJson() => {
        'Success': success,
        if (channel != null) 'Channel': channel!.toJson(),
        if (message != null) 'Message': message,
      };
}

/// Private chat message request payload
class PrivateChatMessageRequest {
  PrivateChatMessageRequest({
    required this.toUserId,
    required this.content,
    this.contentType = MessageContentType.text,
  });

  factory PrivateChatMessageRequest.fromJson(Map<String, dynamic> json) =>
      PrivateChatMessageRequest(
        toUserId: json['ToUserId'] as int,
        content: json['Content'] as String,
        contentType:
            MessageContentType.fromValue(json['ContentType'] as int? ?? 0),
      );
  final int toUserId;
  final String content;
  final MessageContentType contentType;

  Map<String, dynamic> toJson() => {
        'ToUserId': toUserId,
        'Content': content,
        'ContentType': contentType.value,
      };

  List<int> toBytes() => utf8.encode(jsonEncode(toJson()));
}

/// Private chat message response payload
class PrivateChatMessageResponse {
  PrivateChatMessageResponse({
    required this.success,
    this.messageId,
    this.message,
    this.privateChat,
    this.messageText,
  });

  factory PrivateChatMessageResponse.fromJson(Map<String, dynamic> json) =>
      PrivateChatMessageResponse(
        success: json['Success'] as bool,
        messageId: json['MessageId'] as int?,
        message: json['Message'] != null
            ? AegisChatMessage.fromJson(json['Message'] as Map<String, dynamic>)
            : null,
        privateChat: json['PrivateChat'] != null
            ? PrivateChat.fromJson(json['PrivateChat'] as Map<String, dynamic>)
            : null,
        messageText: json['MessageText'] as String?,
      );

  factory PrivateChatMessageResponse.fromBytes(List<int> bytes) {
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return PrivateChatMessageResponse.fromJson(json);
  }
  final bool success;
    final int? messageId;
  final AegisChatMessage? message;
  final PrivateChat? privateChat;
  final String? messageText;

  Map<String, dynamic> toJson() => {
        'Success': success,
      if (messageId != null) 'MessageId': messageId,
        if (message != null) 'Message': message!.toJson(),
        if (privateChat != null) 'PrivateChat': privateChat!.toJson(),
        if (messageText != null) 'MessageText': messageText,
      };
}

/// Message entity (private chat)
class AegisChatMessage {
  AegisChatMessage({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.content,
    required this.contentType,
    required this.sequenceNumber,
    required this.createdAt,
    this.isDelivered = false,
    this.isRead = false,
    this.deliveredAt,
    this.readAt,
  });

  factory AegisChatMessage.fromJson(Map<String, dynamic> json) =>
      AegisChatMessage(
        id: json['Id'] as int,
        fromUserId: json['FromUserId'] as int,
        toUserId: json['ToUserId'] as int,
        content: json['Content'] as String,
        contentType: MessageContentType.fromValue(json['ContentType'] as int),
        sequenceNumber: json['SequenceNumber'] as int,
        isDelivered: json['IsDelivered'] as bool? ?? false,
        isRead: json['IsRead'] as bool? ?? false,
        createdAt: DateTime.parse(json['CreatedAt'] as String),
        deliveredAt: json['DeliveredAt'] != null
            ? DateTime.parse(json['DeliveredAt'] as String)
            : null,
        readAt: json['ReadAt'] != null
            ? DateTime.parse(json['ReadAt'] as String)
            : null,
      );
  final int id;
  final int fromUserId;
  final int toUserId;
  final String content;
  final MessageContentType contentType;
  final int sequenceNumber;
  final bool isDelivered;
  final bool isRead;
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
        'CreatedAt': createdAt.toIso8601String(),
        if (deliveredAt != null) 'DeliveredAt': deliveredAt!.toIso8601String(),
        if (readAt != null) 'ReadAt': readAt!.toIso8601String(),
      };
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
        id: json['Id'] as int,
        user1Id: json['User1Id'] as int,
        user2Id: json['User2Id'] as int,
        createdAt: DateTime.parse(json['CreatedAt'] as String),
        lastActivityAt: json['LastActivityAt'] != null
            ? DateTime.parse(json['LastActivityAt'] as String)
            : null,
        lastMessageId: json['LastMessageId'] as int?,
        isActive: json['IsActive'] as bool? ?? true,
        lastMessage: json['LastMessage'] != null
            ? AegisChatMessage.fromJson(
                json['LastMessage'] as Map<String, dynamic>)
            : null,
      );
  final int id;
  final int user1Id;
  final int user2Id;
  final DateTime createdAt;
  final DateTime? lastActivityAt;
  final int? lastMessageId;
  final bool isActive;
  final AegisChatMessage? lastMessage;

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
