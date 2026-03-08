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
        email: json['Email'] as String,
        publicKey: json['PublicKey'] as String,
        identityKeyFingerprint: json['IdentityKeyFingerprint'] as String?,
        isActive: json['IsActive'] as bool,
        createdAt: DateTime.parse(json['CreatedAt'] as String),
        updatedAt: DateTime.parse(json['UpdatedAt'] as String),
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
    this.message,
    this.messageText,
  });

  factory ChannelMessageResponse.fromJson(Map<String, dynamic> json) =>
      ChannelMessageResponse(
        success: json['Success'] as bool,
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
  final ChannelMessage? message;
  final String? messageText;

  Map<String, dynamic> toJson() => {
        'Success': success,
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
    this.message,
  });

  factory ChannelCreateResponse.fromJson(Map<String, dynamic> json) =>
      ChannelCreateResponse(
        success: json['Success'] as bool,
        channel: json['Channel'] != null
            ? Channel.fromJson(json['Channel'] as Map<String, dynamic>)
            : null,
        message: json['Message'] as String?,
      );

  factory ChannelCreateResponse.fromBytes(List<int> bytes) {
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return ChannelCreateResponse.fromJson(json);
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
    this.message,
    this.privateChat,
    this.messageText,
  });

  factory PrivateChatMessageResponse.fromJson(Map<String, dynamic> json) =>
      PrivateChatMessageResponse(
        success: json['Success'] as bool,
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
  final AegisChatMessage? message;
  final PrivateChat? privateChat;
  final String? messageText;

  Map<String, dynamic> toJson() => {
        'Success': success,
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
