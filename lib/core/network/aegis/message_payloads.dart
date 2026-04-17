import 'dart:convert';
import 'dart:typed_data';
import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/utils/user_content_sanitizer.dart';

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

/// Target chat type for unified messaging APIs.
enum ChatTargetType { private, channel, group }

/// Scope for message operations and reactions in private chats, channels, or groups.
enum ChatScope {
  privateChat('private'),
  channel('channel'),
  group('group');

  const ChatScope(this.value);
  final String value;

  static ChatScope fromValue(String value) {
    return ChatScope.values.firstWhere(
      (scope) => scope.value == value,
      orElse: () => ChatScope.privateChat,
    );
  }
}

/// Scope for room-level operations that only apply to channels or groups.
enum RoomScope {
  channel('channel'),
  group('group');

  const RoomScope(this.value);
  final String value;

  static RoomScope fromValue(String value) {
    return RoomScope.values.firstWhere(
      (scope) => scope.value == value,
      orElse: () => RoomScope.channel,
    );
  }
}

/// Channel/group member role values used by the server.
enum MemberRole {
  member(0),
  moderator(1),
  admin(2),
  owner(3);

  const MemberRole(this.value);
  final int value;

  static MemberRole fromValue(int value) {
    return MemberRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => MemberRole.member,
    );
  }
}

/// Who may join a room.
enum RoomJoinRule {
  open(0),
  inviteOnly(1),
  approval(2);

  const RoomJoinRule(this.value);
  final int value;

  static RoomJoinRule fromValue(int value) {
    return RoomJoinRule.values.firstWhere(
      (rule) => rule.value == value,
      orElse: () => RoomJoinRule.open,
    );
  }
}

/// Who can see room history.
enum RoomHistoryVisibility {
  worldReadable(0),
  joined(1),
  invited(2);

  const RoomHistoryVisibility(this.value);
  final int value;

  static RoomHistoryVisibility fromValue(int value) {
    return RoomHistoryVisibility.values.firstWhere(
      (visibility) => visibility.value == value,
      orElse: () => RoomHistoryVisibility.joined,
    );
  }
}

/// Media kind for unified media sending.
enum MediaKind { photo, video, gif, file, voice }

/// Text parse mode used for rich formatting.
enum ParseMode {
  markdown('markdown'),
  markdownV2('markdownv2'),
  html('html');

  const ParseMode(this.value);
  final String value;
}

class ParsedRichText {
  final String text;
  final String? parseMode;

  ParsedRichText({required this.text, this.parseMode});
}

ParsedRichText parseRichTextContent(String content) {
  try {
    final decoded = jsonDecode(content);
    if (decoded is Map<String, dynamic>) {
      final kind = (decoded['Kind'] as String?)?.toLowerCase();
      if (kind == 'rich-text' || kind == 'bot-rich-text') {
        final text = decoded['Text'] as String? ?? '';
        final parseMode = decoded['ParseMode'] as String?;
        return ParsedRichText(
          text: UserContentSanitizer.sanitizeRichTextDisplay(
            text,
            parseMode: parseMode,
          ),
          parseMode: (parseMode?.toLowerCase() == ParseMode.html.value)
              ? null
              : parseMode,
        );
      }
    }
  } catch (_) {
    // Content is plain text.
  }

  return ParsedRichText(
    text: UserContentSanitizer.sanitizeRichTextDisplay(content),
  );
}

/// Recursively converts a MessagePack-deserialized structure into
/// the `Map<String, dynamic>` / `List<dynamic>` shape expected by all `fromJson` factories.
dynamic _normalizeMsgPack(dynamic value) {
  if (value is Map) {
    return value.map<String, dynamic>(
      (k, v) => MapEntry(k.toString(), _normalizeMsgPack(v)),
    );
  }
  if (value is List) {
    return value.map(_normalizeMsgPack).toList();
  }
  return value;
}

Map<String, dynamic> _decodePayloadMap(List<int> bytes) {
  final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
  if (data.isEmpty) {
    return <String, dynamic>{};
  }

  final firstByte = data.first;
  if (firstByte == 0x7b || firstByte == 0x5b) {
    return jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
  }

  final raw = msgpack.deserialize(data);
  return Map<String, dynamic>.from(_normalizeMsgPack(raw) as Map);
}

int _parseIntValue(dynamic value, {required String fieldName}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) {
      return parsed;
    }
  }

  throw FormatException('Unsupported int value for $fieldName: $value');
}

int? _parseNullableIntValue(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

bool _parseBoolValue(dynamic value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }
  }
  return fallback;
}

List<int> _parseIntList(dynamic value) {
  if (value is! List) {
    return const <int>[];
  }

  return value
      .map(_parseNullableIntValue)
      .whereType<int>()
      .toList(growable: false);
}

DateTime _parseDateTimeValue(dynamic value) {
  if (value is DateTime) {
    return value.toUtc();
  }
  if (value is String) {
    return DateTime.parse(value).toUtc();
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
  }

  throw FormatException('Unsupported DateTime value: $value');
}

DateTime? _parseNullableDateTimeValue(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'null') {
      return null;
    }
  }

  return _parseDateTimeValue(value);
}

/// Normalized response for unified media sending API.
class MediaSendResponse {
  final bool success;
  final int messageId;
  final String? messageText;

  MediaSendResponse({
    required this.success,
    this.messageId = 0,
    this.messageText,
  });
}

/// Binary attachment payload for media/file messages.
class MediaAttachmentPayload {
  final String fileName;
  final String mimeType;
  final String base64Data;
  final int? sizeBytes;

  MediaAttachmentPayload({
    required this.fileName,
    required this.mimeType,
    required this.base64Data,
    this.sizeBytes,
  });

  Map<String, dynamic> toJson() => {
    'FileName': fileName,
    'MimeType': mimeType,
    'Base64Data': base64Data,
    if (sizeBytes != null) 'SizeBytes': sizeBytes,
  };

  factory MediaAttachmentPayload.fromJson(Map<String, dynamic> json) =>
      MediaAttachmentPayload(
        fileName: json['FileName'] as String,
        mimeType: json['MimeType'] as String,
        base64Data: json['Base64Data'] as String,
        sizeBytes: json['SizeBytes'] as int?,
      );
}

/// Parsed media payload extracted from message content JSON envelope.
class ParsedMediaAttachment {
  final String? text;
  final String fileName;
  final String mimeType;
  final String base64Data;
  final int? sizeBytes;

  ParsedMediaAttachment({
    required this.fileName,
    required this.mimeType,
    required this.base64Data,
    this.text,
    this.sizeBytes,
  });

  List<int> decodeBytes() => base64Decode(base64Data);
}

class ParsedMediaEnvelope {
  final String? text;
  final List<ParsedMediaAttachment> attachments;

  ParsedMediaEnvelope({required this.attachments, this.text});
}

ParsedMediaEnvelope? tryParseMediaAttachments(
  String content,
  MessageContentType contentType,
) {
  if (contentType != MessageContentType.image &&
      contentType != MessageContentType.video &&
      contentType != MessageContentType.file &&
      contentType != MessageContentType.audio) {
    return null;
  }

  try {
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    ParsedMediaAttachment? parseAttachment(dynamic node, String? fallbackText) {
      if (node is! Map<String, dynamic>) {
        return null;
      }

      final fileName = node['FileName'] ?? node['fileName'];
      final mimeType = node['MimeType'] ?? node['mimeType'];
      final base64Data = node['Base64Data'] ?? node['base64Data'];

      if (fileName is! String || mimeType is! String || base64Data is! String) {
        return null;
      }

      final size = node['SizeBytes'] ?? node['sizeBytes'];
      return ParsedMediaAttachment(
        text: (node['Text'] ?? node['text']) as String? ?? fallbackText,
        fileName: fileName,
        mimeType: mimeType,
        base64Data: base64Data,
        sizeBytes: size is int ? size : int.tryParse('${size ?? ''}'),
      );
    }

    final rootText = (decoded['Text'] ?? decoded['text']) as String?;

    final attachmentsNode = decoded['Attachments'] ?? decoded['attachments'];
    if (attachmentsNode is List) {
      final parsed = attachmentsNode
          .map((item) => parseAttachment(item, rootText))
          .whereType<ParsedMediaAttachment>()
          .toList(growable: false);

      if (parsed.isNotEmpty) {
        return ParsedMediaEnvelope(text: rootText, attachments: parsed);
      }
    }

    final single = parseAttachment(decoded, rootText);
    if (single != null) {
      return ParsedMediaEnvelope(text: rootText, attachments: [single]);
    }

    return null;
  } catch (_) {
    return null;
  }
}

ParsedMediaAttachment? tryParseMediaAttachment(
  String content,
  MessageContentType contentType,
) {
  final parsed = tryParseMediaAttachments(content, contentType);
  if (parsed == null || parsed.attachments.isEmpty) {
    return null;
  }

  return parsed.attachments.first;
}

/// Handshake request payload
class HandshakeRequestPayload {
  final String publicKey;
  final int clientVersion;
  final int appId;
  final String appHash;

  HandshakeRequestPayload({
    required this.publicKey,
    required this.clientVersion,
    required this.appId,
    required this.appHash,
  });

  Map<String, dynamic> toJson() => {
    'PublicKey': publicKey,
    'ClientVersion': clientVersion,
    'AppId': appId,
    'AppHash': appHash,
  };

  factory HandshakeRequestPayload.fromJson(Map<String, dynamic> json) =>
      HandshakeRequestPayload(
        publicKey: json['PublicKey'] as String,
        clientVersion: json['ClientVersion'] as int,
        appId: json['AppId'] as int,
        appHash: json['AppHash'] as String,
      );

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Registration request payload
class RegistrationRequest {
  final String username;
  final String email;
  final String password;
  final String publicKey;

  RegistrationRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.publicKey,
  });

  Map<String, dynamic> toJson() => {
    'Username': username,
    'Email': email,
    'Mail': email,
    'Password': password,
    'PublicKey': publicKey,
    'PublicKeyLegacy': publicKey,
  };

  factory RegistrationRequest.fromJson(Map<String, dynamic> json) =>
      RegistrationRequest(
        username: json['Username'] as String,
        email: (json['Email'] ?? json['Mail']) as String,
        password: json['Password'] as String,
        publicKey: (json['PublicKey'] ?? json['PublicKeyLegacy']) as String,
      );

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Registration response payload
class RegistrationResponse {
  final bool success;
  final String? message;
  final RegisteredUserInfo? user;

  RegistrationResponse({required this.success, this.message, this.user});

  Map<String, dynamic> toJson() => {
    'Success': success,
    if (message != null) 'Message': message,
    if (user != null) 'User': user!.toJson(),
  };

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) =>
      RegistrationResponse(
        success: json['Success'] as bool,
        message: json['Message'] as String?,
        user: json['User'] != null
            ? RegisteredUserInfo.fromJson(json['User'] as Map<String, dynamic>)
            : null,
      );

  factory RegistrationResponse.fromBytes(List<int> bytes) {
    return RegistrationResponse.fromJson(_decodePayloadMap(bytes));
  }
}

/// Minimal registered user info returned by the server
class RegisteredUserInfo {
  final int id;
  final String username;

  RegisteredUserInfo({required this.id, required this.username});

  Map<String, dynamic> toJson() => {'Id': id, 'Username': username};

  factory RegisteredUserInfo.fromJson(Map<String, dynamic> json) =>
      RegisteredUserInfo(
        id: _parseIntValue(json['Id'], fieldName: 'RegisteredUserInfo.Id'),
        username: json['Username'] as String,
      );
}

/// Authentication response payload
class AuthResponse {
  final bool success;
  final int? userId;
  final String? username;
  final String? sessionToken;
  final String? error;

  AuthResponse({
    required this.success,
    this.userId,
    this.username,
    this.sessionToken,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'Success': success,
    if (userId != null) 'UserId': userId,
    if (username != null) 'Username': username,
    if (sessionToken != null) 'SessionToken': sessionToken,
    if (error != null) 'Error': error,
  };

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    success: json['Success'] as bool,
    userId: _parseNullableIntValue(json['UserId']),
    username: json['Username'] as String?,
    sessionToken: json['SessionToken'] as String?,
    error: json['Error'] as String?,
  );

  factory AuthResponse.fromBytes(List<int> bytes) {
    return AuthResponse.fromJson(_decodePayloadMap(bytes));
  }
}

/// User search request payload
class UserSearchRequest {
  final String query;
  final int limit;

  UserSearchRequest({required this.query, this.limit = 20});

  Map<String, dynamic> toJson() => {'Query': query, 'Limit': limit};

  factory UserSearchRequest.fromJson(Map<String, dynamic> json) =>
      UserSearchRequest(
        query: json['Query'] as String,
        limit: json['Limit'] as int? ?? 20,
      );

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// User search response payload
class UserSearchResponse {
  final bool success;
  final List<UserSearchResult> users;
  final String? message;

  UserSearchResponse({
    required this.success,
    required this.users,
    this.message,
  });

  Map<String, dynamic> toJson() => {
    'Success': success,
    'Users': users.map((u) => u.toJson()).toList(),
    if (message != null) 'Message': message,
  };

  factory UserSearchResponse.fromJson(Map<String, dynamic> json) =>
      UserSearchResponse(
        success: json['Success'] as bool,
        users: (json['Users'] as List<dynamic>)
            .map((u) => UserSearchResult.fromJson(u as Map<String, dynamic>))
            .toList(),
        message: json['Message'] as String?,
      );

  factory UserSearchResponse.fromBytes(List<int> bytes) {
    return UserSearchResponse.fromJson(_decodePayloadMap(bytes));
  }
}

/// User search result item
class UserSearchResult {
  final int id;
  final String username;
  final String? email;
  final String? presenceStatus;

  UserSearchResult({
    required this.id,
    required this.username,
    this.email,
    this.presenceStatus,
  });

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Username': username,
    if (email != null) 'Email': email,
    if (presenceStatus != null) 'PresenceStatus': presenceStatus,
  };

  factory UserSearchResult.fromJson(Map<String, dynamic> json) =>
      UserSearchResult(
        id: json['Id'] as int,
        username: json['Username'] as String,
        email: json['Email'] as String?,
        presenceStatus: json['PresenceStatus'] as String?,
      );
}

/// User presence update payload.
class UserPresenceUpdateRequest {
  final bool isOnline;
  final DateTime? clientTimestamp;

  UserPresenceUpdateRequest({required this.isOnline, this.clientTimestamp});

  Map<String, dynamic> toJson() => {
    'IsOnline': isOnline,
    if (clientTimestamp != null)
      'ClientTimestamp': clientTimestamp!.toUtc().toIso8601String(),
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// User entity
class User {
  final int id;
  final String username;
  final String email;
  final String publicKey;
  final String? identityKeyFingerprint;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSeenAt;

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

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['Id'] as int,
    username: json['Username'] as String,
    email: json['Email'] as String,
    publicKey: json['PublicKey'] as String,
    identityKeyFingerprint: json['IdentityKeyFingerprint'] as String?,
    isActive: json['IsActive'] as bool,
    createdAt: _parseNullableDateTimeValue(json['CreatedAt']) ?? DateTime.now().toUtc(),
    updatedAt: _parseNullableDateTimeValue(json['UpdatedAt']) ?? DateTime.now().toUtc(),
    lastSeenAt: _parseNullableDateTimeValue(json['LastSeenAt']),
  );
}

/// Channel message request payload
class ChannelMessageRequest {
  final int channelId;
  final String? content;
  final MessageContentType contentType;
  final int? replyToMessageId;
  final MediaAttachmentPayload? attachment;
  final List<MediaAttachmentPayload>? attachments;
  final String? parseMode;

  ChannelMessageRequest({
    required this.channelId,
    this.content,
    this.contentType = MessageContentType.text,
    this.replyToMessageId,
    this.attachment,
    this.attachments,
    this.parseMode,
  });

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

  factory ChannelMessageRequest.fromJson(Map<String, dynamic> json) =>
      ChannelMessageRequest(
        channelId: _parseIntValue(
          json['ChannelId'],
          fieldName: 'ChannelMessageRequest.ChannelId',
        ),
        content: json['Content'] as String?,
        contentType: MessageContentType.fromValue(
          _parseNullableIntValue(json['ContentType']) ?? 0,
        ),
        replyToMessageId: _parseNullableIntValue(json['ReplyToMessageId']),
        attachment: json['Attachment'] != null
            ? MediaAttachmentPayload.fromJson(
                json['Attachment'] as Map<String, dynamic>,
              )
            : null,
        attachments: (json['Attachments'] as List<dynamic>?)
            ?.map(
              (item) =>
                  MediaAttachmentPayload.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        parseMode: json['ParseMode'] as String?,
      );

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Channel message response payload
class ChannelMessageResponse {
  final bool success;
  final int messageId;
  final String? messageText;

  ChannelMessageResponse({
    required this.success,
    this.messageId = 0,
    this.messageText,
  });

  Map<String, dynamic> toJson() => {
    'Success': success,
    'MessageId': messageId,
    if (messageText != null) 'MessageText': messageText,
  };

  factory ChannelMessageResponse.fromJson(Map<String, dynamic> json) =>
      ChannelMessageResponse(
        success: json['Success'] as bool,
        messageId: _parseNullableIntValue(json['MessageId']) ?? 0,
        messageText: json['MessageText'] as String?,
      );

  factory ChannelMessageResponse.fromBytes(List<int> bytes) {
    return ChannelMessageResponse.fromJson(_decodePayloadMap(bytes));
  }
}

/// Channel message entity
class ChannelMessage {
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

  factory ChannelMessage.fromJson(Map<String, dynamic> json) => ChannelMessage(
    id: _parseIntValue(json['Id'], fieldName: 'ChannelMessage.Id'),
    channelId: _parseIntValue(
      json['ChannelId'],
      fieldName: 'ChannelMessage.ChannelId',
    ),
    fromUserId: _parseIntValue(
      json['FromUserId'],
      fieldName: 'ChannelMessage.FromUserId',
    ),
    content: json['Content'] as String,
    contentType: MessageContentType.fromValue(
      _parseIntValue(json['ContentType'], fieldName: 'ChannelMessage.ContentType'),
    ),
    createdAt: _parseNullableDateTimeValue(json['CreatedAt']) ?? DateTime.now().toUtc(),
    editedAt: _parseNullableDateTimeValue(json['EditedAt']),
    isEdited: json['IsEdited'] as bool? ?? false,
    replyToMessageId: _parseNullableIntValue(json['ReplyToMessageId']),
    isPinned: json['IsPinned'] as bool? ?? false,
  );
}

/// Channel create request payload
class ChannelCreateRequest {
  final String name;
  final String? description;
  final ChannelType type;

  ChannelCreateRequest({
    required this.name,
    this.description,
    this.type = ChannelType.public,
  });

  Map<String, dynamic> toJson() => {
    'Name': name,
    if (description != null) 'Description': description,
    'Type': type.value,
  };

  factory ChannelCreateRequest.fromJson(Map<String, dynamic> json) =>
      ChannelCreateRequest(
        name: json['Name'] as String,
        description: json['Description'] as String?,
        type: ChannelType.fromValue(_parseNullableIntValue(json['Type']) ?? 0),
      );

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Channel create response payload
class ChannelCreateResponse {
  final bool success;
  final int channelId;
  final String? message;

  ChannelCreateResponse({
    required this.success,
    this.channelId = 0,
    this.message,
  });

  Map<String, dynamic> toJson() => {
    'Success': success,
    'ChannelId': channelId,
    if (message != null) 'Message': message,
  };

  factory ChannelCreateResponse.fromJson(Map<String, dynamic> json) =>
      ChannelCreateResponse(
        success: json['Success'] as bool,
        channelId: _parseNullableIntValue(json['ChannelId']) ?? 0,
        message: json['Message'] as String?,
      );

  factory ChannelCreateResponse.fromBytes(List<int> bytes) {
    return ChannelCreateResponse.fromJson(_decodePayloadMap(bytes));
  }
}

/// Channel entity
class Channel {
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

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
    id: _parseIntValue(json['Id'], fieldName: 'Channel.Id'),
    name: json['Name'] as String,
    description: json['Description'] as String?,
    type: ChannelType.fromValue(
      _parseIntValue(json['Type'], fieldName: 'Channel.Type'),
    ),
    createdByUserId: _parseIntValue(
      json['CreatedByUserId'],
      fieldName: 'Channel.CreatedByUserId',
    ),
    createdAt: _parseNullableDateTimeValue(json['CreatedAt']) ?? DateTime.now().toUtc(),
    updatedAt: _parseNullableDateTimeValue(json['UpdatedAt']) ?? DateTime.now().toUtc(),
    isActive: json['IsActive'] as bool,
    inviteCode: json['InviteCode'] as String?,
    publicAlias: json['PublicAlias'] as String?,
    memberCount: _parseIntValue(
      json['MemberCount'],
      fieldName: 'Channel.MemberCount',
    ),
  );
}

/// Minimal channel info returned in join/create responses
class ChannelSummary {
  final int id;
  final String name;
  final String? description;
  final ChannelType type;
  final int memberCount;

  ChannelSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.memberCount,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Name': name,
    if (description != null) 'Description': description,
    'Type': type.value,
    'MemberCount': memberCount,
  };

  factory ChannelSummary.fromJson(Map<String, dynamic> json) => ChannelSummary(
    id: _parseIntValue(json['Id'], fieldName: 'ChannelSummary.Id'),
    name: json['Name'] as String,
    description: json['Description'] as String?,
    type: ChannelType.fromValue(_parseNullableIntValue(json['Type']) ?? 0),
    memberCount: _parseNullableIntValue(json['MemberCount']) ?? 0,
  );
}

/// Channel join request payload
class ChannelJoinRequest {
  final int channelId;

  ChannelJoinRequest({required this.channelId});

  Map<String, dynamic> toJson() => {'ChannelId': channelId};

  factory ChannelJoinRequest.fromJson(Map<String, dynamic> json) =>
      ChannelJoinRequest(
        channelId: _parseIntValue(
          json['ChannelId'],
          fieldName: 'ChannelJoinRequest.ChannelId',
        ),
      );

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Channel join response payload
class ChannelJoinResponse {
  final bool success;
  final ChannelSummary? channel;
  final String? message;

  ChannelJoinResponse({required this.success, this.channel, this.message});

  Map<String, dynamic> toJson() => {
    'Success': success,
    if (channel != null) 'Channel': channel!.toJson(),
    if (message != null) 'Message': message,
  };

  factory ChannelJoinResponse.fromJson(Map<String, dynamic> json) =>
      ChannelJoinResponse(
        success: json['Success'] as bool,
        channel: json['Channel'] != null
            ? ChannelSummary.fromJson(json['Channel'] as Map<String, dynamic>)
            : null,
        message: json['Message'] as String?,
      );

  factory ChannelJoinResponse.fromBytes(List<int> bytes) {
    return ChannelJoinResponse.fromJson(_decodePayloadMap(bytes));
  }
}

/// Private chat message request payload
class PrivateChatMessageRequest {
  final int toUserId;
  final String? content;
  final MessageContentType contentType;
  final MediaAttachmentPayload? attachment;
  final List<MediaAttachmentPayload>? attachments;
  final String? parseMode;

  PrivateChatMessageRequest({
    required this.toUserId,
    this.content,
    this.contentType = MessageContentType.text,
    this.attachment,
    this.attachments,
    this.parseMode,
  });

  Map<String, dynamic> toJson() => {
    'ToUserId': toUserId,
    'Content': content,
    'ContentType': contentType.value,
    if (attachment != null) 'Attachment': attachment!.toJson(),
    if (attachments != null)
      'Attachments': attachments!.map((item) => item.toJson()).toList(),
    if (parseMode != null) 'ParseMode': parseMode,
  };

  factory PrivateChatMessageRequest.fromJson(Map<String, dynamic> json) =>
      PrivateChatMessageRequest(
        toUserId: json['ToUserId'] as int,
        content: json['Content'] as String?,
        contentType: MessageContentType.fromValue(
          json['ContentType'] as int? ?? 0,
        ),
        attachment: json['Attachment'] != null
            ? MediaAttachmentPayload.fromJson(
                json['Attachment'] as Map<String, dynamic>,
              )
            : null,
        attachments: (json['Attachments'] as List<dynamic>?)
            ?.map(
              (item) =>
                  MediaAttachmentPayload.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        parseMode: json['ParseMode'] as String?,
      );

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Private chat message response payload
class PrivateChatMessageResponse {
  final bool success;
  final int messageId;
  final String? messageText;

  PrivateChatMessageResponse({
    required this.success,
    this.messageId = 0,
    this.messageText,
  });

  Map<String, dynamic> toJson() => {
    'Success': success,
    'MessageId': messageId,
    if (messageText != null) 'MessageText': messageText,
  };

  factory PrivateChatMessageResponse.fromJson(Map<String, dynamic> json) =>
      PrivateChatMessageResponse(
        success: json['Success'] as bool,
        messageId: json['MessageId'] as int? ?? 0,
        messageText: json['MessageText'] as String?,
      );

  factory PrivateChatMessageResponse.fromBytes(List<int> bytes) {
    return PrivateChatMessageResponse.fromJson(_decodePayloadMap(bytes));
  }
}

/// Chat list request payload
class ChatListRequest {
  Map<String, dynamic> toJson() => <String, dynamic>{};
  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Chat list response item
class ChatListItem {
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
    chatId: _parseIntValue(json['ChatId'], fieldName: 'ChatListItem.ChatId'),
    type: json['Type'] as String,
    title: json['Title'] as String,
    avatarUrl: json['AvatarUrl'] as String?,
    presenceStatus: json['PresenceStatus'] as String?,
    lastMessage: json['LastMessage'] as String?,
    lastMessageAt: _parseNullableDateTimeValue(json['LastMessageAt']),
    unreadCount: _parseNullableIntValue(json['UnreadCount']) ?? 0,
    peerUserId: _parseNullableIntValue(json['PeerUserId']),
    channelId: _parseNullableIntValue(json['ChannelId']),
  );

  int get roomTargetId => peerUserId ?? channelId ?? chatId;
}

/// Chat list response payload
class ChatListResponse {
  final bool success;
  final List<ChatListItem> chats;
  final String? message;

  ChatListResponse({required this.success, required this.chats, this.message});

  factory ChatListResponse.fromJson(Map<String, dynamic> json) =>
      ChatListResponse(
        success: json['Success'] as bool,
        chats: (json['Chats'] as List<dynamic>? ?? const <dynamic>[])
            .map((item) => ChatListItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        message: json['Message'] as String?,
      );

  factory ChatListResponse.fromBytes(List<int> bytes) {
    final json = _decodePayloadMap(bytes);
    return ChatListResponse.fromJson(json);
  }
}

/// Private chat history request payload
class PrivateChatHistoryRequest {
  final int peerUserId;
  final int limit;
  final int? beforeMessageId;

  PrivateChatHistoryRequest({
    required this.peerUserId,
    this.limit = 100,
    this.beforeMessageId,
  });

  Map<String, dynamic> toJson() => {
    'PeerUserId': peerUserId,
    'Limit': limit,
    if (beforeMessageId != null) 'BeforeMessageId': beforeMessageId,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Private history message item
class PrivateChatHistoryItem {
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
    final parsed = parseRichTextContent(json['Content'] as String);
    return PrivateChatHistoryItem(
      id: _parseIntValue(json['Id'], fieldName: 'PrivateChatHistoryItem.Id'),
      fromUserId: _parseIntValue(
        json['FromUserId'],
        fieldName: 'PrivateChatHistoryItem.FromUserId',
      ),
      toUserId: _parseIntValue(
        json['ToUserId'],
        fieldName: 'PrivateChatHistoryItem.ToUserId',
      ),
      content: parsed.text,
      contentType: MessageContentType.fromValue(
        _parseNullableIntValue(json['ContentType']) ?? 0,
      ),
      createdAt: _parseNullableDateTimeValue(json['CreatedAt']) ?? DateTime.now().toUtc(),
      deliveredTo: _parseIntList(json['DeliveredTo']),
      readBy: _parseIntList(json['ReadBy']),
      parseMode: parsed.parseMode,
      fromUsername: json['FromUsername'] as String?,
      username: json['Username'] as String?,
    );
  }

  ParsedMediaAttachment? get attachment =>
      tryParseMediaAttachment(content, contentType);

  List<ParsedMediaAttachment> get attachments =>
      tryParseMediaAttachments(content, contentType)?.attachments ??
      const <ParsedMediaAttachment>[];
}

/// Private chat history response payload
class PrivateChatHistoryResponse {
  final bool success;
  final int peerUserId;
  final List<PrivateChatHistoryItem> messages;
  final String? message;

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
              (item) =>
                  PrivateChatHistoryItem.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        message: json['Message'] as String?,
      );

  factory PrivateChatHistoryResponse.fromBytes(List<int> bytes) {
    return PrivateChatHistoryResponse.fromJson(_decodePayloadMap(bytes));
  }
}

/// Channel history request payload
class ChannelHistoryRequest {
  final int channelId;
  final int limit;
  final int? beforeMessageId;

  ChannelHistoryRequest({
    required this.channelId,
    this.limit = 100,
    this.beforeMessageId,
  });

  Map<String, dynamic> toJson() => {
    'ChannelId': channelId,
    'Limit': limit,
    if (beforeMessageId != null) 'BeforeMessageId': beforeMessageId,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Channel history message item
class ChannelHistoryItem {
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
    final parsed = parseRichTextContent(json['Content'] as String);
    return ChannelHistoryItem(
      id: _parseIntValue(json['Id'], fieldName: 'ChannelHistoryItem.Id'),
      channelId: _parseIntValue(
        json['ChannelId'],
        fieldName: 'ChannelHistoryItem.ChannelId',
      ),
      fromUserId: _parseIntValue(
        json['FromUserId'],
        fieldName: 'ChannelHistoryItem.FromUserId',
      ),
      content: parsed.text,
      contentType: MessageContentType.fromValue(
        _parseNullableIntValue(json['ContentType']) ?? 0,
      ),
      createdAt: _parseNullableDateTimeValue(json['CreatedAt']) ?? DateTime.now().toUtc(),
      deliveredTo: _parseIntList(json['DeliveredTo']),
      readBy: _parseIntList(json['ReadBy']),
      parseMode: parsed.parseMode,
      fromUsername: json['FromUsername'] as String?,
      channelName: json['ChannelName'] as String?,
    );
  }

  ParsedMediaAttachment? get attachment =>
      tryParseMediaAttachment(content, contentType);

  List<ParsedMediaAttachment> get attachments =>
      tryParseMediaAttachments(content, contentType)?.attachments ??
      const <ParsedMediaAttachment>[];
}

/// Channel history response payload
class ChannelHistoryResponse {
  final bool success;
  final int channelId;
  final String? channelName;
  final List<ChannelHistoryItem> messages;
  final String? message;

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
        channelId: _parseNullableIntValue(json['ChannelId']) ?? 0,
        channelName: json['ChannelName'] as String?,
        messages: (json['Messages'] as List<dynamic>? ?? const <dynamic>[])
            .map(
              (item) =>
                  ChannelHistoryItem.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        message: json['Message'] as String?,
      );

  factory ChannelHistoryResponse.fromBytes(List<int> bytes) {
    return ChannelHistoryResponse.fromJson(_decodePayloadMap(bytes));
  }
}

/// Async message status event payload (server -> clients)
class MessageStatusEvent {
  final bool success;
  final List<int> messageIds;
  final int? deliveredTo;
  final int? readBy;
  final DateTime? processedAt;

  MessageStatusEvent({
    required this.success,
    required this.messageIds,
    this.deliveredTo,
    this.readBy,
    this.processedAt,
  });

  factory MessageStatusEvent.fromJson(Map<String, dynamic> json) {
    final processedAtRaw = json['ProcessedAt'];
    return MessageStatusEvent(
      success: json['Success'] as bool? ?? false,
      messageIds: _parseIntList(json['MessageIds']),
      deliveredTo: _parseNullableIntValue(json['DeliveredTo']),
      readBy: _parseNullableIntValue(json['ReadBy']),
      processedAt: _parseNullableDateTimeValue(processedAtRaw),
    );
  }

  factory MessageStatusEvent.fromBytes(List<int> bytes) {
    final json = _decodePayloadMap(bytes);
    return MessageStatusEvent.fromJson(json);
  }

  bool get isDeliveredUpdate => deliveredTo != null;
  bool get isReadUpdate => readBy != null;
}

/// Delivery receipt request payload.
class MessageDeliveryReceiptRequest {
  final List<int> messageIds;
  final DateTime? deliveredAt;
  final String? deviceId;

  MessageDeliveryReceiptRequest({
    required this.messageIds,
    this.deliveredAt,
    this.deviceId,
  });

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
  final List<int> messageIds;
  final DateTime? readAt;

  MessageReadReceiptRequest({required this.messageIds, this.readAt});

  Map<String, dynamic> toJson() => {
    'MessageIds': messageIds,
    if (readAt != null) 'ReadAt': readAt!.toUtc().toIso8601String(),
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Receipt confirmation payload returned by read/delivery receipt handlers.
class MessageReceiptResponse {
  final bool success;
  final List<int> messageIds;
  final DateTime? processedAt;

  MessageReceiptResponse({
    required this.success,
    required this.messageIds,
    this.processedAt,
  });

  factory MessageReceiptResponse.fromJson(Map<String, dynamic> json) =>
      MessageReceiptResponse(
        success: json['Success'] as bool? ?? false,
        messageIds: (json['MessageIds'] as List<dynamic>? ?? const <dynamic>[])
            .map((item) => (item as num).toInt())
            .toList(growable: false),
        processedAt: _parseNullableDateTimeValue(json['ProcessedAt']),
      );

  factory MessageReceiptResponse.fromBytes(List<int> bytes) =>
      MessageReceiptResponse.fromJson(_decodePayloadMap(bytes));
}

/// Incoming private message event payload
class PrivateChatMessageEvent {
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
    final parsed = parseRichTextContent(json['Content'] as String);
    return PrivateChatMessageEvent(
      id: _parseIntValue(json['Id'], fieldName: 'PrivateChatMessageEvent.Id'),
      fromUserId: _parseIntValue(
        json['FromUserId'],
        fieldName: 'PrivateChatMessageEvent.FromUserId',
      ),
      toUserId: _parseIntValue(
        json['ToUserId'],
        fieldName: 'PrivateChatMessageEvent.ToUserId',
      ),
      content: parsed.text,
      contentType: MessageContentType.fromValue(
        _parseNullableIntValue(json['ContentType']) ?? 0,
      ),
      createdAt: _parseNullableDateTimeValue(json['CreatedAt']) ?? DateTime.now().toUtc(),
      replyToMessageId: _parseNullableIntValue(json['ReplyToMessageId']),
      deliveredTo: _parseIntList(json['DeliveredTo']),
      readBy: _parseIntList(json['ReadBy']),
      parseMode: parsed.parseMode,
      fromUsername: json['FromUsername'] as String?,
      username: json['Username'] as String?,
    );
  }

  factory PrivateChatMessageEvent.fromBytes(List<int> bytes) {
    final json = _decodePayloadMap(bytes);
    return PrivateChatMessageEvent.fromJson(json);
  }

  ParsedMediaAttachment? get attachment =>
      tryParseMediaAttachment(content, contentType);

  List<ParsedMediaAttachment> get attachments =>
      tryParseMediaAttachments(content, contentType)?.attachments ??
      const <ParsedMediaAttachment>[];
}

/// Incoming channel message event payload
class ChannelMessageEvent {
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
    final parsed = parseRichTextContent(json['Content'] as String);
    return ChannelMessageEvent(
      id: _parseIntValue(json['Id'], fieldName: 'ChannelMessageEvent.Id'),
      channelId: _parseIntValue(
        json['ChannelId'],
        fieldName: 'ChannelMessageEvent.ChannelId',
      ),
      fromUserId: _parseIntValue(
        json['FromUserId'],
        fieldName: 'ChannelMessageEvent.FromUserId',
      ),
      content: parsed.text,
      contentType: MessageContentType.fromValue(
        _parseNullableIntValue(json['ContentType']) ?? 0,
      ),
      createdAt: _parseNullableDateTimeValue(json['CreatedAt']) ?? DateTime.now().toUtc(),
      replyToMessageId: _parseNullableIntValue(json['ReplyToMessageId']),
      deliveredTo: _parseIntList(json['DeliveredTo']),
      readBy: _parseIntList(json['ReadBy']),
      parseMode: parsed.parseMode,
      fromUsername: json['FromUsername'] as String?,
      channelName: json['ChannelName'] as String?,
    );
  }

  factory ChannelMessageEvent.fromBytes(List<int> bytes) {
    final json = _decodePayloadMap(bytes);
    return ChannelMessageEvent.fromJson(json);
  }

  ParsedMediaAttachment? get attachment =>
      tryParseMediaAttachment(content, contentType);

  List<ParsedMediaAttachment> get attachments =>
      tryParseMediaAttachments(content, contentType)?.attachments ??
      const <ParsedMediaAttachment>[];
}

/// Message entity (stored/delivered message, not the wire-level frame)
class ChatMessage {
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

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final parsed = parseRichTextContent(json['Content'] as String);
    return ChatMessage(
      id: _parseIntValue(json['Id'], fieldName: 'ChatMessage.Id'),
      fromUserId: _parseIntValue(
        json['FromUserId'],
        fieldName: 'ChatMessage.FromUserId',
      ),
      toUserId: _parseIntValue(
        json['ToUserId'],
        fieldName: 'ChatMessage.ToUserId',
      ),
      content: parsed.text,
      contentType: MessageContentType.fromValue(
        _parseIntValue(json['ContentType'], fieldName: 'ChatMessage.ContentType'),
      ),
      sequenceNumber: _parseIntValue(
        json['SequenceNumber'],
        fieldName: 'ChatMessage.SequenceNumber',
      ),
      isDelivered: json['IsDelivered'] as bool? ?? false,
      isRead: json['IsRead'] as bool? ?? false,
      parseMode: parsed.parseMode,
      createdAt: _parseNullableDateTimeValue(json['CreatedAt']) ?? DateTime.now().toUtc(),
      deliveredAt: _parseNullableDateTimeValue(json['DeliveredAt']),
      readAt: _parseNullableDateTimeValue(json['ReadAt']),
    );
  }

  ParsedMediaAttachment? get attachment =>
      tryParseMediaAttachment(content, contentType);

  List<ParsedMediaAttachment> get attachments =>
      tryParseMediaAttachments(content, contentType)?.attachments ??
      const <ParsedMediaAttachment>[];
}

/// Private chat entity
class PrivateChat {
  final int id;
  final int user1Id;
  final int user2Id;
  final DateTime createdAt;
  final DateTime? lastActivityAt;
  final int? lastMessageId;
  final bool isActive;
  final ChatMessage? lastMessage;

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

  factory PrivateChat.fromJson(Map<String, dynamic> json) => PrivateChat(
    id: _parseIntValue(json['Id'], fieldName: 'PrivateChat.Id'),
    user1Id: _parseIntValue(json['User1Id'], fieldName: 'PrivateChat.User1Id'),
    user2Id: _parseIntValue(json['User2Id'], fieldName: 'PrivateChat.User2Id'),
    createdAt: _parseNullableDateTimeValue(json['CreatedAt']) ?? DateTime.now().toUtc(),
    lastActivityAt: _parseNullableDateTimeValue(json['LastActivityAt']),
    lastMessageId: _parseNullableIntValue(json['LastMessageId']),
    isActive: json['IsActive'] as bool? ?? true,
    lastMessage: json['LastMessage'] != null
        ? ChatMessage.fromJson(json['LastMessage'] as Map<String, dynamic>)
        : null,
  );
}

// ─── Profile payloads ────────────────────────────────────────────────────────

/// Profile data returned by the server
class ProfileData {
  final int id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final List<ProfileAvatarData> avatars;
  final String? presenceStatus;
  final String? bio;
  final String? location;
  final String? birthDate;
  final String? email;
  final DateTime? createdAt;
  final DateTime? lastSeenAt;

  ProfileData({
    required this.id,
    required this.username,
    this.createdAt,
    this.displayName,
    this.avatarUrl,
    this.avatars = const <ProfileAvatarData>[],
    this.presenceStatus,
    this.bio,
    this.location,
    this.birthDate,
    this.email,
    this.lastSeenAt,
  });

  Map<String, dynamic> toJson() => {
    'Id': id,
    'Username': username,
    if (displayName != null) 'DisplayName': displayName,
    if (avatarUrl != null) 'AvatarUrl': avatarUrl,
    'Avatars': avatars.map((item) => item.toJson()).toList(),
    if (presenceStatus != null) 'PresenceStatus': presenceStatus,
    if (bio != null) 'Bio': bio,
    if (location != null) 'Location': location,
    if (birthDate != null) 'BirthDate': birthDate,
    if (email != null) 'Email': email,
    if (createdAt != null) 'CreatedAt': createdAt!.toIso8601String(),
    if (lastSeenAt != null) 'LastSeenAt': lastSeenAt!.toIso8601String(),
  };

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
    id: _parseIntValue(json['Id'], fieldName: 'ProfileData.Id'),
    username: json['Username'] as String,
    displayName: json['DisplayName'] as String?,
    avatarUrl: json['AvatarUrl'] as String?,
    avatars: (json['Avatars'] as List<dynamic>? ?? const <dynamic>[])
        .map((item) => ProfileAvatarData.fromJson(item as Map<String, dynamic>))
        .toList(),
    presenceStatus: json['PresenceStatus'] as String?,
    bio: json['Bio'] as String?,
    location: json['Location'] as String?,
    birthDate: json['BirthDate']?.toString(),
    email: json['Email'] as String?,
    createdAt: _parseNullableDateTimeValue(json['CreatedAt']),
    lastSeenAt: _parseNullableDateTimeValue(json['LastSeenAt']),
  );
}

class ProfileAvatarData {
  final int id;
  final String avatarUrl;
  final bool isPrimary;
  final DateTime createdAt;

  ProfileAvatarData({
    required this.id,
    required this.avatarUrl,
    required this.isPrimary,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'Id': id,
    'AvatarUrl': avatarUrl,
    'IsPrimary': isPrimary,
    'CreatedAt': createdAt.toIso8601String(),
  };

  factory ProfileAvatarData.fromJson(Map<String, dynamic> json) =>
      ProfileAvatarData(
        id: json['Id'] as int,
        avatarUrl: json['AvatarUrl'] as String,
        isPrimary: json['IsPrimary'] as bool? ?? false,
        createdAt: _parseNullableDateTimeValue(json['CreatedAt']) ?? DateTime.now().toUtc(),
      );
}

class ProfileAvatarAddRequest {
  final String avatarUrl;
  final bool makePrimary;

  ProfileAvatarAddRequest({required this.avatarUrl, this.makePrimary = false});

  Map<String, dynamic> toJson() => {
    'AvatarUrl': avatarUrl,
    'MakePrimary': makePrimary,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

class ProfileAvatarDeleteRequest {
  final int avatarId;

  ProfileAvatarDeleteRequest({required this.avatarId});

  Map<String, dynamic> toJson() => {'AvatarId': avatarId};

  List<int> toBytes() => msgpack.serialize(toJson());
}

class ProfileAvatarSetPrimaryRequest {
  final int avatarId;

  ProfileAvatarSetPrimaryRequest({required this.avatarId});

  Map<String, dynamic> toJson() => {'AvatarId': avatarId};

  List<int> toBytes() => msgpack.serialize(toJson());
}

class ProfileAvatarMutationResponse {
  final bool success;
  final String? message;
  final ProfileAvatarData? avatar;

  ProfileAvatarMutationResponse({
    required this.success,
    this.message,
    this.avatar,
  });

  factory ProfileAvatarMutationResponse.fromJson(Map<String, dynamic> json) =>
      ProfileAvatarMutationResponse(
        success: json['Success'] as bool,
        message: json['Message'] as String?,
        avatar: json['Avatar'] != null
            ? ProfileAvatarData.fromJson(json['Avatar'] as Map<String, dynamic>)
            : null,
      );

  factory ProfileAvatarMutationResponse.fromBytes(List<int> bytes) {
    return ProfileAvatarMutationResponse.fromJson(_decodePayloadMap(bytes));
  }
}

class ProfileAvatarListResponse {
  final bool success;
  final List<ProfileAvatarData> avatars;
  final String? message;

  ProfileAvatarListResponse({
    required this.success,
    required this.avatars,
    this.message,
  });

  factory ProfileAvatarListResponse.fromJson(Map<String, dynamic> json) =>
      ProfileAvatarListResponse(
        success: json['Success'] as bool,
        avatars: (json['Avatars'] as List<dynamic>? ?? const <dynamic>[])
            .map(
              (item) =>
                  ProfileAvatarData.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        message: json['Message'] as String?,
      );

  factory ProfileAvatarListResponse.fromBytes(List<int> bytes) {
    return ProfileAvatarListResponse.fromJson(_decodePayloadMap(bytes));
  }
}

class ChannelLinkUpdateRequest {
  final int channelId;
  final String? publicAlias;
  final bool regeneratePrivateInvite;

  ChannelLinkUpdateRequest({
    required this.channelId,
    this.publicAlias,
    this.regeneratePrivateInvite = false,
  });

  Map<String, dynamic> toJson() => {
    'ChannelId': channelId,
    if (publicAlias != null) 'PublicAlias': publicAlias,
    'RegeneratePrivateInvite': regeneratePrivateInvite,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

class ChannelLinkRequest {
  final int channelId;

  ChannelLinkRequest({required this.channelId});

  Map<String, dynamic> toJson() => {'ChannelId': channelId};

  List<int> toBytes() => msgpack.serialize(toJson());
}

class ChannelResolveRequest {
  final String linkOrAlias;

  ChannelResolveRequest({required this.linkOrAlias});

  Map<String, dynamic> toJson() => {'LinkOrAlias': linkOrAlias};

  List<int> toBytes() => msgpack.serialize(toJson());
}

class ChannelLinkInfo {
  final int channelId;
  final String? publicAlias;
  final String? publicLink;
  final String privateInviteLink;

  ChannelLinkInfo({
    required this.channelId,
    required this.privateInviteLink,
    this.publicAlias,
    this.publicLink,
  });

  factory ChannelLinkInfo.fromJson(Map<String, dynamic> json) =>
      ChannelLinkInfo(
        channelId: json['ChannelId'] as int,
        publicAlias: json['PublicAlias'] as String?,
        publicLink: json['PublicLink'] as String?,
        privateInviteLink: json['PrivateInviteLink'] as String,
      );
}

class ChannelLinkResponse {
  final bool success;
  final ChannelLinkInfo? link;
  final String? message;

  ChannelLinkResponse({required this.success, this.link, this.message});

  factory ChannelLinkResponse.fromJson(Map<String, dynamic> json) =>
      ChannelLinkResponse(
        success: json['Success'] as bool,
        link: json['Link'] != null
            ? ChannelLinkInfo.fromJson(json['Link'] as Map<String, dynamic>)
            : null,
        message: json['Message'] as String?,
      );

  factory ChannelLinkResponse.fromBytes(List<int> bytes) {
    return ChannelLinkResponse.fromJson(_decodePayloadMap(bytes));
  }
}

class ChannelResolveResponse {
  final bool success;
  final ChannelSummary? channel;
  final String? message;

  ChannelResolveResponse({required this.success, this.channel, this.message});

  factory ChannelResolveResponse.fromJson(Map<String, dynamic> json) =>
      ChannelResolveResponse(
        success: json['Success'] as bool,
        channel: json['Channel'] != null
            ? ChannelSummary.fromJson(json['Channel'] as Map<String, dynamic>)
            : null,
        message: json['Message'] as String?,
      );

  factory ChannelResolveResponse.fromBytes(List<int> bytes) {
    return ChannelResolveResponse.fromJson(_decodePayloadMap(bytes));
  }
}

/// Request to update the authenticated user's profile
class ProfileUpdateRequest {
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final String? username;
  final String? location;
  final String? birthDate;

  ProfileUpdateRequest({
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.username,
    this.location,
    this.birthDate,
  });

  Map<String, dynamic> toJson() => {
    if (displayName != null) 'DisplayName': displayName,
    if (avatarUrl != null) 'AvatarUrl': avatarUrl,
    if (bio != null) 'Bio': bio,
    if (username != null) 'Username': username,
    if (location != null) 'Location': location,
    if (birthDate != null) 'BirthDate': birthDate,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Response to a profile update
class ProfileUpdateResponse {
  final bool success;
  final String? message;
  final ProfileData? profile;

  ProfileUpdateResponse({required this.success, this.message, this.profile});

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) =>
      ProfileUpdateResponse(
        success: json['Success'] as bool,
        message: json['Message'] as String?,
        profile: json['Profile'] != null
            ? ProfileData.fromJson(json['Profile'] as Map<String, dynamic>)
            : null,
      );

  factory ProfileUpdateResponse.fromBytes(List<int> bytes) {
    return ProfileUpdateResponse.fromJson(_decodePayloadMap(bytes));
  }
}

/// Request to get a user's profile
class ProfileGetRequest {
  final int? userId;
  final String? username;

  ProfileGetRequest({this.userId, this.username});

  Map<String, dynamic> toJson() => {
    if (userId != null) 'UserId': userId,
    if (username != null) 'Username': username,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Response to a profile get request
class ProfileGetResponse {
  final bool success;
  final ProfileData? profile;
  final String? message;

  ProfileGetResponse({required this.success, this.profile, this.message});

  factory ProfileGetResponse.fromJson(Map<String, dynamic> json) =>
      ProfileGetResponse(
        success: json['Success'] as bool,
        profile: json['Profile'] != null
            ? ProfileData.fromJson(json['Profile'] as Map<String, dynamic>)
            : null,
        message: json['Message'] as String?,
      );

  factory ProfileGetResponse.fromBytes(List<int> bytes) {
    return ProfileGetResponse.fromJson(_decodePayloadMap(bytes));
  }
}

// ─── Channel edit payloads ────────────────────────────────────────────────────

/// Request to edit a channel (name, description, avatar)
class ChannelEditRequest {
  final int channelId;
  final String? name;
  final String? description;
  final String? avatarUrl;

  ChannelEditRequest({
    required this.channelId,
    this.name,
    this.description,
    this.avatarUrl,
  });

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
  final bool success;
  final String? message;

  ChannelEditResponse({required this.success, this.message});

  factory ChannelEditResponse.fromJson(Map<String, dynamic> json) =>
      ChannelEditResponse(
        success: json['Success'] as bool,
        message: json['Message'] as String?,
      );

  factory ChannelEditResponse.fromBytes(List<int> bytes) {
    return ChannelEditResponse.fromJson(_decodePayloadMap(bytes));
  }
}

// ─── Group edit payloads ──────────────────────────────────────────────────────

/// Request to edit a group chat (name, description, avatar)
class GroupEditRequest {
  final int groupId;
  final String? name;
  final String? description;
  final String? avatarUrl;

  GroupEditRequest({
    required this.groupId,
    this.name,
    this.description,
    this.avatarUrl,
  });

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
  final bool success;
  final String? message;

  GroupEditResponse({required this.success, this.message});

  factory GroupEditResponse.fromJson(Map<String, dynamic> json) =>
      GroupEditResponse(
        success: json['Success'] as bool,
        message: json['Message'] as String?,
      );

  factory GroupEditResponse.fromBytes(List<int> bytes) {
    return GroupEditResponse.fromJson(_decodePayloadMap(bytes));
  }
}

// ─── Group messaging payloads ────────────────────────────────────────────────

/// Request to send a group message.
class GroupMessageSendRequest {
  final int groupId;
  final String? content;
  final MessageContentType contentType;
  final int? replyToMessageId;
  final MediaAttachmentPayload? attachment;
  final List<MediaAttachmentPayload>? attachments;
  final String? parseMode;

  GroupMessageSendRequest({
    required this.groupId,
    this.content,
    this.contentType = MessageContentType.text,
    this.replyToMessageId,
    this.attachment,
    this.attachments,
    this.parseMode,
  });

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
  final bool success;
  final int messageId;
  final String? message;

  GroupMessageSendResponse({
    required this.success,
    this.messageId = 0,
    this.message,
  });

  factory GroupMessageSendResponse.fromJson(Map<String, dynamic> json) =>
      GroupMessageSendResponse(
        success: json['Success'] as bool,
        messageId: json['MessageId'] as int? ?? 0,
        message: json['Message'] as String?,
      );

  factory GroupMessageSendResponse.fromBytes(List<int> bytes) {
    return GroupMessageSendResponse.fromJson(_decodePayloadMap(bytes));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SERVER-002: Group history
// ═══════════════════════════════════════════════════════════════════════════

/// Group history request
class GroupHistoryRequest {
  final int groupId;
  final int limit;
  final int? beforeMessageId;

  GroupHistoryRequest({
    required this.groupId,
    this.limit = 100,
    this.beforeMessageId,
  });

  Map<String, dynamic> toJson() => {
    'GroupId': groupId,
    'Limit': limit,
    if (beforeMessageId != null) 'BeforeMessageId': beforeMessageId,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Group history message item
class GroupHistoryItem {
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
    final parsed = parseRichTextContent(json['Content'] as String);
    return GroupHistoryItem(
      id: _parseIntValue(json['Id'], fieldName: 'GroupHistoryItem.Id'),
      groupId: _parseIntValue(
        json['GroupId'],
        fieldName: 'GroupHistoryItem.GroupId',
      ),
      fromUserId: _parseIntValue(
        json['FromUserId'],
        fieldName: 'GroupHistoryItem.FromUserId',
      ),
      content: parsed.text,
      contentType: MessageContentType.fromValue(
        _parseNullableIntValue(json['ContentType']) ?? 0,
      ),
      createdAt: _parseNullableDateTimeValue(json['CreatedAt']) ?? DateTime.now().toUtc(),
      deliveredTo: _parseIntList(json['DeliveredTo']),
      readBy: _parseIntList(json['ReadBy']),
      isPinned: json['IsPinned'] as bool? ?? false,
      parseMode: parsed.parseMode,
      fromUsername: json['FromUsername'] as String?,
      groupName: json['GroupName'] as String?,
    );
  }

  ParsedMediaAttachment? get attachment =>
      tryParseMediaAttachment(content, contentType);

  List<ParsedMediaAttachment> get attachments =>
      tryParseMediaAttachments(content, contentType)?.attachments ??
      const <ParsedMediaAttachment>[];
}

/// Group history response
class GroupHistoryResponse {
  final bool success;
  final int groupId;
  final String? groupName;
  final List<GroupHistoryItem> messages;
  final String? message;

  GroupHistoryResponse({
    required this.success,
    required this.groupId,
    required this.messages,
    this.groupName,
    this.message,
  });

  factory GroupHistoryResponse.fromJson(Map<String, dynamic> json) =>
      GroupHistoryResponse(
        success: json['Success'] as bool,
        groupId: _parseNullableIntValue(json['GroupId']) ?? 0,
        groupName: json['GroupName'] as String?,
        messages: (json['Messages'] as List<dynamic>? ?? const <dynamic>[])
            .map(
              (item) => GroupHistoryItem.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        message: json['Message'] as String?,
      );

  factory GroupHistoryResponse.fromBytes(List<int> bytes) {
    return GroupHistoryResponse.fromJson(_decodePayloadMap(bytes));
  }
}

/// Group message event (server -> client push)
class GroupMessageEvent {
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
    final parsed = parseRichTextContent(json['Content'] as String);
    return GroupMessageEvent(
      id: _parseIntValue(json['Id'], fieldName: 'GroupMessageEvent.Id'),
      groupId: _parseIntValue(
        json['GroupId'],
        fieldName: 'GroupMessageEvent.GroupId',
      ),
      fromUserId: _parseIntValue(
        json['FromUserId'],
        fieldName: 'GroupMessageEvent.FromUserId',
      ),
      content: parsed.text,
      contentType: MessageContentType.fromValue(
        _parseNullableIntValue(json['ContentType']) ?? 0,
      ),
      createdAt: _parseNullableDateTimeValue(json['CreatedAt']) ?? DateTime.now().toUtc(),
      deliveredTo: _parseIntList(json['DeliveredTo']),
      readBy: _parseIntList(json['ReadBy']),
      fromUsername: json['FromUsername'] as String?,
      groupName: json['GroupName'] as String?,
      parseMode: parsed.parseMode,
    );
  }

  factory GroupMessageEvent.fromBytes(List<int> bytes) {
    return GroupMessageEvent.fromJson(_decodePayloadMap(bytes));
  }

  ParsedMediaAttachment? get attachment =>
      tryParseMediaAttachment(content, contentType);

  List<ParsedMediaAttachment> get attachments =>
      tryParseMediaAttachments(content, contentType)?.attachments ??
      const <ParsedMediaAttachment>[];
}

// ═══════════════════════════════════════════════════════════════════════════
// SERVER-003: Member listing
// ═══════════════════════════════════════════════════════════════════════════

/// Member summary for listings
class MemberSummary {
  final int userId;
  final String username;
  final String role;
  final DateTime joinedAt;
  final bool canSendMessages;
  final bool canDeleteOthersMessages;
  final bool canPinMessages;
  final bool canManageRoles;

  MemberSummary({
    required this.userId,
    required this.username,
    required this.role,
    required this.joinedAt,
    this.canSendMessages = true,
    this.canDeleteOthersMessages = false,
    this.canPinMessages = false,
    this.canManageRoles = false,
  });

  factory MemberSummary.fromJson(Map<String, dynamic> json) => MemberSummary(
    userId: _parseIntValue(json['UserId'], fieldName: 'MemberSummary.UserId'),
    username: json['Username'] as String,
    role: json['Role'] as String,
    joinedAt:
        _parseNullableDateTimeValue(json['JoinedAt']) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    canSendMessages: json['CanSendMessages'] as bool? ?? true,
    canDeleteOthersMessages: json['CanDeleteOthersMessages'] as bool? ?? false,
    canPinMessages: json['CanPinMessages'] as bool? ?? false,
    canManageRoles: json['CanManageRoles'] as bool? ?? false,
  );
}

/// Channel members request
class ChannelMembersRequest {
  final int channelId;

  ChannelMembersRequest({required this.channelId});

  Map<String, dynamic> toJson() => {'ChannelId': channelId};
  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Channel members response
class ChannelMembersResponse {
  final bool success;
  final int channelId;
  final List<MemberSummary> members;
  final String? message;

  ChannelMembersResponse({
    required this.success,
    required this.channelId,
    required this.members,
    this.message,
  });

  factory ChannelMembersResponse.fromJson(Map<String, dynamic> json) =>
      ChannelMembersResponse(
        success: json['Success'] as bool,
        channelId: _parseNullableIntValue(json['ChannelId']) ?? 0,
        members: (json['Members'] as List<dynamic>? ?? const <dynamic>[])
            .map((item) => MemberSummary.fromJson(item as Map<String, dynamic>))
            .toList(),
        message: json['Message'] as String?,
      );

  factory ChannelMembersResponse.fromBytes(List<int> bytes) {
    return ChannelMembersResponse.fromJson(_decodePayloadMap(bytes));
  }
}

/// Group members request
class GroupMembersRequest {
  final int groupId;

  GroupMembersRequest({required this.groupId});

  Map<String, dynamic> toJson() => {'GroupId': groupId};
  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Group members response
class GroupMembersResponse {
  final bool success;
  final int groupId;
  final List<MemberSummary> members;
  final String? message;

  GroupMembersResponse({
    required this.success,
    required this.groupId,
    required this.members,
    this.message,
  });

  factory GroupMembersResponse.fromJson(Map<String, dynamic> json) =>
      GroupMembersResponse(
        success: json['Success'] as bool,
        groupId: _parseNullableIntValue(json['GroupId']) ?? 0,
        members: (json['Members'] as List<dynamic>? ?? const <dynamic>[])
            .map((item) => MemberSummary.fromJson(item as Map<String, dynamic>))
            .toList(),
        message: json['Message'] as String?,
      );

  factory GroupMembersResponse.fromBytes(List<int> bytes) {
    return GroupMembersResponse.fromJson(_decodePayloadMap(bytes));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SERVER-004: Leave operations
// ═══════════════════════════════════════════════════════════════════════════

/// Channel leave request
class ChannelLeaveRequest {
  final int channelId;

  ChannelLeaveRequest({required this.channelId});

  Map<String, dynamic> toJson() => {'ChannelId': channelId};
  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Channel leave response
class ChannelLeaveResponse {
  final bool success;
  final String? message;

  ChannelLeaveResponse({required this.success, this.message});

  factory ChannelLeaveResponse.fromJson(Map<String, dynamic> json) =>
      ChannelLeaveResponse(
        success: json['Success'] as bool,
        message: json['Message'] as String?,
      );

  factory ChannelLeaveResponse.fromBytes(List<int> bytes) {
    final raw = msgpack.deserialize(Uint8List.fromList(bytes));
    return ChannelLeaveResponse.fromJson(
      _normalizeMsgPack(raw) as Map<String, dynamic>,
    );
  }
}

/// Group leave request
class GroupLeaveRequest {
  final int groupId;

  GroupLeaveRequest({required this.groupId});

  Map<String, dynamic> toJson() => {'GroupId': groupId};
  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Group leave response
class GroupLeaveResponse {
  final bool success;
  final String? message;

  GroupLeaveResponse({required this.success, this.message});

  factory GroupLeaveResponse.fromJson(Map<String, dynamic> json) =>
      GroupLeaveResponse(
        success: json['Success'] as bool,
        message: json['Message'] as String?,
      );

  factory GroupLeaveResponse.fromBytes(List<int> bytes) {
    final raw = msgpack.deserialize(Uint8List.fromList(bytes));
    return GroupLeaveResponse.fromJson(
      _normalizeMsgPack(raw) as Map<String, dynamic>,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SERVER-005: Reactions
// ═══════════════════════════════════════════════════════════════════════════

/// Reaction count summary
class ReactionCount {
  final String emoji;
  final int count;
  final bool byMe;

  ReactionCount({required this.emoji, required this.count, required this.byMe});

  factory ReactionCount.fromJson(Map<String, dynamic> json) => ReactionCount(
    emoji: json['Emoji'] as String,
    count: _parseIntValue(json['Count'], fieldName: 'ReactionCount.Count'),
    byMe: json['ByMe'] as bool? ?? false,
  );
}

/// Message reaction request
class MessageReactRequest {
  final String scope; // "private", "channel", "group"
  final int messageId;
  final String emoji;
  final bool remove;

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
  }) => MessageReactRequest(
    scope: ChatScope.privateChat.value,
    messageId: messageId,
    emoji: emoji,
    remove: remove,
  );

  factory MessageReactRequest.channel({
    required int messageId,
    required String emoji,
    bool remove = false,
  }) => MessageReactRequest(
    scope: ChatScope.channel.value,
    messageId: messageId,
    emoji: emoji,
    remove: remove,
  );

  factory MessageReactRequest.group({
    required int messageId,
    required String emoji,
    bool remove = false,
  }) => MessageReactRequest(
    scope: ChatScope.group.value,
    messageId: messageId,
    emoji: emoji,
    remove: remove,
  );

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
  final bool success;
  final String? message;
  final List<ReactionCount> reactions;

  MessageReactResponse({
    required this.success,
    required this.reactions,
    this.message,
  });

  factory MessageReactResponse.fromJson(Map<String, dynamic> json) =>
      MessageReactResponse(
        success: json['Success'] as bool,
        message: json['Message'] as String?,
        reactions: (json['Reactions'] as List<dynamic>? ?? const <dynamic>[])
            .map((item) => ReactionCount.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  factory MessageReactResponse.fromBytes(List<int> bytes) {
    final raw = msgpack.deserialize(Uint8List.fromList(bytes));
    return MessageReactResponse.fromJson(
      _normalizeMsgPack(raw) as Map<String, dynamic>,
    );
  }
}

/// Message reaction event (server -> client push)
class MessageReactionEvent {
  final String scope;
  final int messageId;
  final int userId;
  final String emoji;
  final bool removed;
  final List<ReactionCount> reactions;

  MessageReactionEvent({
    required this.scope,
    required this.messageId,
    required this.userId,
    required this.emoji,
    required this.removed,
    required this.reactions,
  });

  ChatScope get chatScope => ChatScope.fromValue(scope);

  factory MessageReactionEvent.fromJson(Map<String, dynamic> json) =>
      MessageReactionEvent(
        scope: json['Scope'] as String,
        messageId: _parseIntValue(
          json['MessageId'],
          fieldName: 'MessageReactionEvent.MessageId',
        ),
        userId: _parseIntValue(
          json['UserId'],
          fieldName: 'MessageReactionEvent.UserId',
        ),
        emoji: json['Emoji'] as String,
        removed: json['Removed'] as bool? ?? false,
        reactions: (json['Reactions'] as List<dynamic>? ?? const <dynamic>[])
            .map((item) => ReactionCount.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

  factory MessageReactionEvent.fromBytes(List<int> bytes) {
    return MessageReactionEvent.fromJson(_decodePayloadMap(bytes));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SERVER-005: Pins
// ═══════════════════════════════════════════════════════════════════════════

/// Message pin request
class MessagePinRequest {
  final String scope; // "channel" or "group"
  final int messageId;
  final int targetId; // channelId or groupId
  final bool unpin;

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
  }) => MessagePinRequest(
    scope: RoomScope.channel.value,
    messageId: messageId,
    targetId: channelId,
    unpin: unpin,
  );

  factory MessagePinRequest.group({
    required int groupId,
    required int messageId,
    bool unpin = false,
  }) => MessagePinRequest(
    scope: RoomScope.group.value,
    messageId: messageId,
    targetId: groupId,
    unpin: unpin,
  );

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
  final bool success;
  final String? message;

  MessagePinResponse({required this.success, this.message});

  factory MessagePinResponse.fromJson(Map<String, dynamic> json) =>
      MessagePinResponse(
        success: json['Success'] as bool,
        message: json['Message'] as String?,
      );

  factory MessagePinResponse.fromBytes(List<int> bytes) {
    final raw = msgpack.deserialize(Uint8List.fromList(bytes));
    return MessagePinResponse.fromJson(
      _normalizeMsgPack(raw) as Map<String, dynamic>,
    );
  }
}

/// Message pin event (server -> client push)
class MessagePinEvent {
  final String scope;
  final int messageId;
  final int targetId;
  final bool pinned;
  final int actorUserId;

  MessagePinEvent({
    required this.scope,
    required this.messageId,
    required this.targetId,
    required this.pinned,
    required this.actorUserId,
  });

  RoomScope get roomScope => RoomScope.fromValue(scope);

  factory MessagePinEvent.fromJson(Map<String, dynamic> json) =>
      MessagePinEvent(
        scope: json['Scope'] as String,
        messageId: _parseIntValue(
          json['MessageId'],
          fieldName: 'MessagePinEvent.MessageId',
        ),
        targetId: _parseIntValue(
          json['TargetId'],
          fieldName: 'MessagePinEvent.TargetId',
        ),
        pinned: json['Pinned'] as bool? ?? false,
        actorUserId: _parseIntValue(
          json['ActorUserId'],
          fieldName: 'MessagePinEvent.ActorUserId',
        ),
      );

  factory MessagePinEvent.fromBytes(List<int> bytes) {
    final raw = msgpack.deserialize(Uint8List.fromList(bytes));
    return MessagePinEvent.fromJson(
      _normalizeMsgPack(raw) as Map<String, dynamic>,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SERVER-006: Room settings
// ═══════════════════════════════════════════════════════════════════════════

/// Room settings get request
class RoomSettingsGetRequest {
  final String scope; // "channel" or "group"
  final int targetId;

  RoomSettingsGetRequest({required this.scope, required this.targetId});

  Map<String, dynamic> toJson() => {'Scope': scope, 'TargetId': targetId};

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Room settings get response
class RoomSettingsGetResponse {
  final bool success;
  final String scope;
  final int targetId;
  final int joinRule; // 0=Open, 1=InviteOnly, 2=Approval
  final int historyVisibility; // 0=WorldReadable, 1=Joined, 2=Invited
  final String? message;

  RoomSettingsGetResponse({
    required this.success,
    required this.scope,
    required this.targetId,
    this.joinRule = 0,
    this.historyVisibility = 1,
    this.message,
  });

  RoomScope get roomScope => RoomScope.fromValue(scope);
  RoomJoinRule get joinRuleValue => RoomJoinRule.fromValue(joinRule);
  RoomHistoryVisibility get historyVisibilityValue =>
      RoomHistoryVisibility.fromValue(historyVisibility);

  factory RoomSettingsGetResponse.fromJson(Map<String, dynamic> json) =>
      RoomSettingsGetResponse(
        success: json['Success'] as bool,
        scope: json['Scope'] as String? ?? '',
        targetId: _parseNullableIntValue(json['TargetId']) ?? 0,
        joinRule: _parseNullableIntValue(json['JoinRule']) ?? 0,
        historyVisibility:
            _parseNullableIntValue(json['HistoryVisibility']) ?? 1,
        message: json['Message'] as String?,
      );

  factory RoomSettingsGetResponse.fromBytes(List<int> bytes) {
    final raw = msgpack.deserialize(Uint8List.fromList(bytes));
    return RoomSettingsGetResponse.fromJson(
      _normalizeMsgPack(raw) as Map<String, dynamic>,
    );
  }
}

/// Room settings update request
class RoomSettingsUpdateRequest {
  final String scope;
  final int targetId;
  final int? joinRule;
  final int? historyVisibility;

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
  }) => RoomSettingsUpdateRequest(
    scope: RoomScope.channel.value,
    targetId: channelId,
    joinRule: joinRule?.value,
    historyVisibility: historyVisibility?.value,
  );

  factory RoomSettingsUpdateRequest.group({
    required int groupId,
    RoomJoinRule? joinRule,
    RoomHistoryVisibility? historyVisibility,
  }) => RoomSettingsUpdateRequest(
    scope: RoomScope.group.value,
    targetId: groupId,
    joinRule: joinRule?.value,
    historyVisibility: historyVisibility?.value,
  );

  RoomScope get roomScope => RoomScope.fromValue(scope);
  RoomJoinRule? get joinRuleValue =>
      joinRule == null ? null : RoomJoinRule.fromValue(joinRule!);
  RoomHistoryVisibility? get historyVisibilityValue => historyVisibility == null
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
  final bool success;
  final String? message;

  RoomSettingsUpdateResponse({required this.success, this.message});

  factory RoomSettingsUpdateResponse.fromJson(Map<String, dynamic> json) =>
      RoomSettingsUpdateResponse(
        success: json['Success'] as bool,
        message: json['Message'] as String?,
      );

  factory RoomSettingsUpdateResponse.fromBytes(List<int> bytes) {
    final raw = msgpack.deserialize(Uint8List.fromList(bytes));
    return RoomSettingsUpdateResponse.fromJson(
      _normalizeMsgPack(raw) as Map<String, dynamic>,
    );
  }
}

class SessionListRequest {
  const SessionListRequest();

  Map<String, dynamic> toJson() => const <String, dynamic>{};

  List<int> toBytes() => msgpack.serialize(toJson());
}

class UserTypingRequest {
  const UserTypingRequest({
    required this.scope,
    required this.targetId,
    required this.isTyping,
    this.toUserId,
  });

  final String scope;
  final int targetId;
  final bool isTyping;
  final int? toUserId;

  factory UserTypingRequest.privateChat({
    required int toUserId,
    required bool isTyping,
  }) => UserTypingRequest(
    scope: ChatScope.privateChat.value,
    targetId: toUserId,
    toUserId: toUserId,
    isTyping: isTyping,
  );

  factory UserTypingRequest.channel({
    required int channelId,
    required bool isTyping,
  }) => UserTypingRequest(
    scope: ChatScope.channel.value,
    targetId: channelId,
    isTyping: isTyping,
  );

  factory UserTypingRequest.group({
    required int groupId,
    required bool isTyping,
  }) => UserTypingRequest(
    scope: ChatScope.group.value,
    targetId: groupId,
    isTyping: isTyping,
  );

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

  final String scope;
  final int targetId;
  final int userId;
  final bool isTyping;
  final DateTime timestampUtc;

  factory UserTypingEventPayload.fromJson(Map<String, dynamic> json) {
    return UserTypingEventPayload(
      scope: json['Scope']?.toString() ?? ChatScope.privateChat.value,
      targetId: _parseIntValue(json['TargetId'] ?? 0, fieldName: 'TargetId'),
      userId: _parseIntValue(json['UserId'] ?? 0, fieldName: 'UserId'),
      isTyping: _parseBoolValue(json['IsTyping']),
      timestampUtc: _parseDateTimeValue(
        json['TimestampUtc'] ?? json['Timestamp'] ?? DateTime.now().toUtc(),
      ),
    );
  }

  factory UserTypingEventPayload.fromBytes(List<int> bytes) {
    return UserTypingEventPayload.fromJson(_decodePayloadMap(bytes));
  }
}

class FileTransferRequest {
  const FileTransferRequest({
    required this.action,
    this.transferId,
    this.fileId,
    this.fileName,
    this.mimeType,
    this.totalSize,
    this.totalChunks,
    this.chunkIndex,
    this.chunkDataBase64,
    this.allowedUserIds,
  });

  final String action;
  final String? transferId;
  final String? fileId;
  final String? fileName;
  final String? mimeType;
  final int? totalSize;
  final int? totalChunks;
  final int? chunkIndex;
  final String? chunkDataBase64;
  final List<int>? allowedUserIds;

  Map<String, dynamic> toJson() => {
    'Action': action,
    if (transferId != null) 'TransferId': transferId,
    if (fileId != null) 'FileId': fileId,
    if (fileName != null) 'FileName': fileName,
    if (mimeType != null) 'MimeType': mimeType,
    if (totalSize != null) 'TotalSize': totalSize,
    if (totalChunks != null) 'TotalChunks': totalChunks,
    if (chunkIndex != null) 'ChunkIndex': chunkIndex,
    if (chunkDataBase64 != null) 'ChunkDataBase64': chunkDataBase64,
    if (allowedUserIds != null) 'AllowedUserIds': allowedUserIds,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

class FileTransferResponsePayload {
  const FileTransferResponsePayload({
    required this.success,
    this.message,
    this.transferId,
    this.fileId,
    this.chunkIndex,
    this.totalChunks,
    this.chunkDataBase64,
    this.fileName,
    this.mimeType,
    this.totalSize,
  });

  final bool success;
  final String? message;
  final String? transferId;
  final String? fileId;
  final int? chunkIndex;
  final int? totalChunks;
  final String? chunkDataBase64;
  final String? fileName;
  final String? mimeType;
  final int? totalSize;

  factory FileTransferResponsePayload.fromJson(Map<String, dynamic> json) {
    return FileTransferResponsePayload(
      success: _parseBoolValue(json['Success']),
      message: json['Message']?.toString(),
      transferId: json['TransferId']?.toString(),
      fileId: json['FileId']?.toString(),
      chunkIndex: _parseNullableIntValue(json['ChunkIndex']),
      totalChunks: _parseNullableIntValue(json['TotalChunks']),
      chunkDataBase64: json['ChunkDataBase64']?.toString(),
      fileName: json['FileName']?.toString(),
      mimeType: json['MimeType']?.toString(),
      totalSize: _parseNullableIntValue(json['TotalSize']),
    );
  }

  factory FileTransferResponsePayload.fromBytes(List<int> bytes) {
    return FileTransferResponsePayload.fromJson(_decodePayloadMap(bytes));
  }
}

class SessionTerminatedEventPayload {
  const SessionTerminatedEventPayload({
    required this.reason,
    required this.revokedByConnectionId,
  });

  final String reason;
  final int revokedByConnectionId;

  factory SessionTerminatedEventPayload.fromJson(Map<String, dynamic> json) {
    return SessionTerminatedEventPayload(
      reason: json['Reason']?.toString() ?? '',
      revokedByConnectionId: _parseIntValue(
        json['RevokedByConnectionId'] ?? 0,
        fieldName: 'RevokedByConnectionId',
      ),
    );
  }

  factory SessionTerminatedEventPayload.fromBytes(List<int> bytes) {
    return SessionTerminatedEventPayload.fromJson(_decodePayloadMap(bytes));
  }
}

class ReadSyncEventPayload {
  const ReadSyncEventPayload({
    required this.messageIds,
    required this.readAt,
  });

  final List<int> messageIds;
  final DateTime readAt;

  factory ReadSyncEventPayload.fromJson(Map<String, dynamic> json) {
    return ReadSyncEventPayload(
      messageIds: _parseIntList(json['MessageIds']),
      readAt: _parseNullableDateTimeValue(json['ReadAt']) ?? DateTime.now().toUtc(),
    );
  }

  factory ReadSyncEventPayload.fromBytes(List<int> bytes) {
    return ReadSyncEventPayload.fromJson(_decodePayloadMap(bytes));
  }
}

class ActiveSessionInfo {
  const ActiveSessionInfo({
    required this.sessionId,
    required this.clientInfo,
    required this.isCurrent,
    required this.isOnline,
    this.deviceName,
    this.platform,
    this.appVersion,
    this.ipAddress,
    this.userAgent,
    this.createdAt,
    this.lastActivityAt,
  });

  final String sessionId;
  final String clientInfo;
  final bool isCurrent;
  final bool isOnline;
  final String? deviceName;
  final String? platform;
  final String? appVersion;
  final String? ipAddress;
  final String? userAgent;
  final DateTime? createdAt;
  final DateTime? lastActivityAt;

  String? get title {
    final candidates = <String?>[
      clientInfo,
      deviceName,
      platform,
      userAgent,
      sessionId,
    ];
    for (final candidate in candidates) {
      final trimmed = candidate?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return null;
  }

  factory ActiveSessionInfo.fromJson(Map<String, dynamic> json) {
    String? readString(List<String> keys) {
      for (final key in keys) {
        final value = json[key]?.toString().trim();
        if (value != null && value.isNotEmpty && value.toLowerCase() != 'null') {
          return value;
        }
      }
      return null;
    }

    DateTime? readDateTime(List<String> keys) {
      for (final key in keys) {
        final parsed = _parseNullableDateTimeValue(json[key]);
        if (parsed != null) {
          return parsed;
        }
      }
      return null;
    }

    return ActiveSessionInfo(
      sessionId:
          readString(const <String>[
            'SessionId',
            'Id',
            'SessionTokenId',
            'DeviceId',
          ]) ??
          '',
      clientInfo: readString(const <String>['ClientInfo']) ?? '',
      isCurrent: _parseBoolValue(
        json['IsCurrent'] ?? json['Current'] ?? json['IsThisDevice'],
      ),
      isOnline: _parseBoolValue(json['IsOnline']),
      deviceName: readString(const <String>[
        'DeviceName',
        'Device',
        'DeviceTitle',
        'ClientInfo',
      ]),
      platform: readString(const <String>[
        'Platform',
        'OsName',
        'OS',
        'System',
      ]),
      appVersion: readString(const <String>[
        'AppVersion',
        'Version',
        'ClientVersion',
      ]),
      ipAddress: readString(const <String>[
        'IpAddress',
        'IPAddress',
        'Ip',
        'RemoteIp',
      ]),
      userAgent: readString(const <String>[
        'UserAgent',
        'Client',
        'ClientName',
      ]),
      createdAt: readDateTime(const <String>[
        'CreatedAtUtc',
        'CreatedAt',
        'IssuedAt',
      ]),
      lastActivityAt: readDateTime(const <String>[
        'LastActivityAtUtc',
        'LastActivityAt',
        'LastSeenAt',
        'LastSeen',
      ]),
    );
  }
}

class SessionListResponse {
  const SessionListResponse({
    required this.success,
    required this.sessions,
    this.message,
  });

  final bool success;
  final List<ActiveSessionInfo> sessions;
  final String? message;

  factory SessionListResponse.fromJson(Map<String, dynamic> json) {
    final rawSessions = json['Sessions'] ?? json['ActiveSessions'] ?? json['Items'];
    final sessions = rawSessions is List
        ? rawSessions
              .map((item) {
                if (item is Map<String, dynamic>) {
                  return ActiveSessionInfo.fromJson(item);
                }
                if (item is Map) {
                  return ActiveSessionInfo.fromJson(
                    item.map<String, dynamic>(
                      (key, value) => MapEntry(key.toString(), value),
                    ),
                  );
                }
                return null;
              })
              .whereType<ActiveSessionInfo>()
              .where((item) => item.sessionId.isNotEmpty)
              .toList(growable: false)
        : const <ActiveSessionInfo>[];

    return SessionListResponse(
      success:
          json['Success'] == null || _parseBoolValue(json['Success']),
      sessions: sessions,
      message: json['Error']?.toString() ?? json['Message']?.toString(),
    );
  }

  factory SessionListResponse.fromBytes(List<int> bytes) {
    return SessionListResponse.fromJson(_decodePayloadMap(bytes));
  }
}

class SessionRevokeRequest {
  const SessionRevokeRequest({required this.sessionId});

  final int sessionId;

  Map<String, dynamic> toJson() => {'SessionId': sessionId};

  List<int> toBytes() => msgpack.serialize(toJson());
}

class SessionRevokeResponse {
  const SessionRevokeResponse({
    required this.success,
    this.sessionId,
    this.revokedCurrentSession = false,
    this.message,
  });

  final bool success;
  final String? sessionId;
  final bool revokedCurrentSession;
  final String? message;

  factory SessionRevokeResponse.fromJson(Map<String, dynamic> json) {
    return SessionRevokeResponse(
      success:
          json['Success'] == null || _parseBoolValue(json['Success']),
      sessionId: json['SessionId']?.toString() ?? json['Id']?.toString(),
      revokedCurrentSession: _parseBoolValue(
        json['RevokedCurrentSession'] ?? json['CurrentSessionRevoked'],
      ),
      message: json['Error']?.toString() ?? json['Message']?.toString(),
    );
  }

  factory SessionRevokeResponse.fromBytes(List<int> bytes) {
    return SessionRevokeResponse.fromJson(_decodePayloadMap(bytes));
  }
}

/// Group create request payload.
class GroupCreateRequest {
  final String name;
  final String? description;

  GroupCreateRequest({required this.name, this.description});

  Map<String, dynamic> toJson() => {
    'Name': name,
    if (description != null) 'Description': description,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

/// Group create response payload.
class GroupCreateResponse {
  final bool success;
  final int groupId;
  final String? message;

  GroupCreateResponse({required this.success, this.groupId = 0, this.message});

  factory GroupCreateResponse.fromJson(Map<String, dynamic> json) =>
      GroupCreateResponse(
        success: json['Success'] as bool? ?? false,
        groupId: (json['GroupId'] as num?)?.toInt() ?? 0,
        message: json['Message'] as String?,
      );

  factory GroupCreateResponse.fromBytes(List<int> bytes) =>
      GroupCreateResponse.fromJson(_decodePayloadMap(bytes));
}

/// Message edit request payload.
class MessageEditRequest {
  final int messageId;
  final String newContent;
  final String scope;
  final int? channelId;
  final int? groupId;

  MessageEditRequest({
    required this.messageId,
    required this.newContent,
    this.scope = 'private',
    this.channelId,
    this.groupId,
  });

  factory MessageEditRequest.privateChat({
    required int messageId,
    required String newContent,
  }) => MessageEditRequest(
    messageId: messageId,
    newContent: newContent,
    scope: ChatScope.privateChat.value,
  );

  factory MessageEditRequest.channel({
    required int channelId,
    required int messageId,
    required String newContent,
  }) => MessageEditRequest(
    messageId: messageId,
    newContent: newContent,
    scope: ChatScope.channel.value,
    channelId: channelId,
  );

  factory MessageEditRequest.group({
    required int groupId,
    required int messageId,
    required String newContent,
  }) => MessageEditRequest(
    messageId: messageId,
    newContent: newContent,
    scope: ChatScope.group.value,
    groupId: groupId,
  );

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
  final bool success;
  final String? message;
  final int messageId;

  MessageEditResponse({
    required this.success,
    this.message,
    this.messageId = 0,
  });

  factory MessageEditResponse.fromJson(Map<String, dynamic> json) =>
      MessageEditResponse(
        success: json['Success'] as bool? ?? false,
        message: json['Message'] as String?,
        messageId: (json['MessageId'] as num?)?.toInt() ?? 0,
      );

  factory MessageEditResponse.fromBytes(List<int> bytes) =>
      MessageEditResponse.fromJson(_decodePayloadMap(bytes));
}

/// Message delete request payload.
class MessageDeleteRequest {
  final int messageId;
  final String scope;
  final int? channelId;
  final int? groupId;

  MessageDeleteRequest({
    required this.messageId,
    this.scope = 'private',
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
  }) => MessageDeleteRequest(
    messageId: messageId,
    scope: ChatScope.channel.value,
    channelId: channelId,
  );

  factory MessageDeleteRequest.group({
    required int groupId,
    required int messageId,
  }) => MessageDeleteRequest(
    messageId: messageId,
    scope: ChatScope.group.value,
    groupId: groupId,
  );

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
  final bool success;
  final String? message;
  final int messageId;

  MessageDeleteResponse({
    required this.success,
    this.message,
    this.messageId = 0,
  });

  factory MessageDeleteResponse.fromJson(Map<String, dynamic> json) =>
      MessageDeleteResponse(
        success: json['Success'] as bool? ?? false,
        message: json['Message'] as String?,
        messageId: (json['MessageId'] as num?)?.toInt() ?? 0,
      );

  factory MessageDeleteResponse.fromBytes(List<int> bytes) =>
      MessageDeleteResponse.fromJson(_decodePayloadMap(bytes));
}

/// Role update request for channel/group memberships.
class MemberRoleUpdateRequest {
  final String scope;
  final int targetId;
  final int targetUserId;
  final int newRole;

  MemberRoleUpdateRequest({
    required this.scope,
    required this.targetId,
    required this.targetUserId,
    required this.newRole,
  });

  Map<String, dynamic> toJson() => {
    'Scope': scope,
    'TargetId': targetId,
    'TargetUserId': targetUserId,
    'NewRole': newRole,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

class MemberRoleUpdateResponse {
  final bool success;
  final String? message;

  MemberRoleUpdateResponse({required this.success, this.message});

  factory MemberRoleUpdateResponse.fromJson(Map<String, dynamic> json) =>
      MemberRoleUpdateResponse(
        success: json['Success'] as bool? ?? false,
        message: json['Message'] as String?,
      );

  factory MemberRoleUpdateResponse.fromBytes(List<int> bytes) =>
      MemberRoleUpdateResponse.fromJson(_decodePayloadMap(bytes));
}

/// Permission update request for channel/group memberships.
class MemberPermissionUpdateRequest {
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

  List<int> toBytes() => msgpack.serialize(toJson());
}

class MemberPermissionUpdateResponse {
  final bool success;
  final String? message;

  MemberPermissionUpdateResponse({required this.success, this.message});

  factory MemberPermissionUpdateResponse.fromJson(Map<String, dynamic> json) =>
      MemberPermissionUpdateResponse(
        success: json['Success'] as bool? ?? false,
        message: json['Message'] as String?,
      );

  factory MemberPermissionUpdateResponse.fromBytes(List<int> bytes) =>
      MemberPermissionUpdateResponse.fromJson(_decodePayloadMap(bytes));
}
