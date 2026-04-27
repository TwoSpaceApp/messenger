// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;

/// Protocol v2.1+ Message Payloads (Types 98-106)

// ─── Type 98: Pong (Response to Ping with latency) ───────────────────────

class Pong {
  final int latencyMs;

  Pong({required this.latencyMs});

  factory Pong.fromJson(Map<String, dynamic> json) => Pong(
    latencyMs: (json['LatencyMs'] as num? ?? 0).toInt(),
  );

  factory Pong.fromBytes(List<int> bytes) {
    final json = _decodePayloadMap(bytes);
    return Pong.fromJson(json);
  }

  Map<String, dynamic> toJson() => {'LatencyMs': latencyMs};
  List<int> toBytes() => msgpack.serialize(toJson());
}

// ─── Type 99: KeepAliveExponential ────────────────────────────────────────

class KeepAliveExponential {
  final int lastSeqReceived;
  final int backoffLevel;

  KeepAliveExponential({
    required this.lastSeqReceived,
    this.backoffLevel = 0,
  });

  factory KeepAliveExponential.fromJson(Map<String, dynamic> json) =>
      KeepAliveExponential(
        lastSeqReceived: (json['LastSeqReceived'] as num? ?? 0).toInt(),
        backoffLevel: (json['BackoffLevel'] as num? ?? 0).toInt(),
      );

  Map<String, dynamic> toJson() => {
    'LastSeqReceived': lastSeqReceived,
    'BackoffLevel': backoffLevel,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

class KeepAliveExponentialResponse {
  final bool success;

  KeepAliveExponentialResponse({required this.success});

  factory KeepAliveExponentialResponse.fromJson(Map<String, dynamic> json) =>
      KeepAliveExponentialResponse(
        success: json['Success'] as bool? ?? false,
      );

  factory KeepAliveExponentialResponse.fromBytes(List<int> bytes) =>
      KeepAliveExponentialResponse.fromJson(_decodePayloadMap(bytes));
}

// ─── Type 100: TokenExpired ───────────────────────────────────────────────

class TokenExpired {
  final DateTime expiresAt;
  final String? refreshToken;

  TokenExpired({
    required this.expiresAt,
    this.refreshToken,
  });

  factory TokenExpired.fromJson(Map<String, dynamic> json) => TokenExpired(
    expiresAt: _parseDateTime(json['ExpiresAtMs'], defaultValue: DateTime.now()),
    refreshToken: json['RefreshToken'] as String?,
  );

  factory TokenExpired.fromBytes(List<int> bytes) =>
      TokenExpired.fromJson(_decodePayloadMap(bytes));

  Map<String, dynamic> toJson() => {
    'ExpiresAtMs': expiresAt.millisecondsSinceEpoch,
    if (refreshToken != null) 'RefreshToken': refreshToken,
  };
}

// ─── Type 101: DisconnectReason ───────────────────────────────────────────

class DisconnectReason {
  final String reason;
  final int? retryAfterMs;
  final String? alternateServerUrl;

  DisconnectReason({
    required this.reason,
    this.retryAfterMs,
    this.alternateServerUrl,
  });

  factory DisconnectReason.fromJson(Map<String, dynamic> json) =>
      DisconnectReason(
        reason: json['Reason'] as String? ?? 'unknown',
        retryAfterMs: (json['RetryAfterMs'] as num?)?.toInt(),
        alternateServerUrl: json['AlternateServerUrl'] as String?,
      );

  factory DisconnectReason.fromBytes(List<int> bytes) =>
      DisconnectReason.fromJson(_decodePayloadMap(bytes));

  Map<String, dynamic> toJson() => {
    'Reason': reason,
    if (retryAfterMs != null) 'RetryAfterMs': retryAfterMs,
    if (alternateServerUrl != null) 'AlternateServerUrl': alternateServerUrl,
  };
}

// ─── Type 102: SessionConflict ────────────────────────────────────────────

class SessionConflict {
  final String newSessionId;
  final DeviceInfo newDeviceInfo;
  final String action; // "disconnect_old", "disconnect_new", "allow_concurrent"

  SessionConflict({
    required this.newSessionId,
    required this.newDeviceInfo,
    this.action = 'disconnect_old',
  });

  factory SessionConflict.fromJson(Map<String, dynamic> json) {
    final deviceData = json['NewDeviceInfo'] as Map<String, dynamic>? ?? {};
    return SessionConflict(
      newSessionId: json['NewSessionId'] as String? ?? '',
      newDeviceInfo: DeviceInfo.fromJson(deviceData),
      action: json['Action'] as String? ?? 'disconnect_old',
    );
  }

  factory SessionConflict.fromBytes(List<int> bytes) =>
      SessionConflict.fromJson(_decodePayloadMap(bytes));

  Map<String, dynamic> toJson() => {
    'NewSessionId': newSessionId,
    'NewDeviceInfo': newDeviceInfo.toJson(),
    'Action': action,
  };
}

class DeviceInfo {
  final String? os;
  final String? version;
  final String? deviceName;

  DeviceInfo({
    this.os,
    this.version,
    this.deviceName,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
    os: json['Os'] as String?,
    version: json['Version'] as String?,
    deviceName: json['DeviceName'] as String?,
  );

  Map<String, dynamic> toJson() => {
    if (os != null) 'Os': os,
    if (version != null) 'Version': version,
    if (deviceName != null) 'DeviceName': deviceName,
  };
}

// ─── Type 103: ProfilesBatch ──────────────────────────────────────────────

class ProfilesBatchRequest {
  final List<int> profileIds;

  ProfilesBatchRequest({required this.profileIds});

  factory ProfilesBatchRequest.fromJson(Map<String, dynamic> json) =>
      ProfilesBatchRequest(
        profileIds: (json['ProfileIds'] as List<dynamic>? ?? [])
            .map((id) => (id as num).toInt())
            .toList(),
      );

  Map<String, dynamic> toJson() => {'ProfileIds': profileIds};
  List<int> toBytes() => msgpack.serialize(toJson());
}

class ProfilesBatchResponse {
  final bool success;
  final List<UserProfileItem> profiles;
  final String? message;

  ProfilesBatchResponse({
    required this.success,
    this.profiles = const [],
    this.message,
  });

  factory ProfilesBatchResponse.fromJson(Map<String, dynamic> json) =>
      ProfilesBatchResponse(
        success: json['Success'] as bool? ?? false,
        profiles: (json['Profiles'] as List<dynamic>? ?? [])
            .map((p) => UserProfileItem.fromJson(p as Map<String, dynamic>))
            .toList(),
        message: json['Message'] as String?,
      );

  factory ProfilesBatchResponse.fromBytes(List<int> bytes) =>
      ProfilesBatchResponse.fromJson(_decodePayloadMap(bytes));
}

class UserProfileItem {
  final int userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final bool isOnline;
  final DateTime? lastSeenAt;

  UserProfileItem({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.isOnline = false,
    this.lastSeenAt,
  });

  factory UserProfileItem.fromJson(Map<String, dynamic> json) =>
      UserProfileItem(
        userId: (json['UserId'] as num? ?? 0).toInt(),
        username: json['Username'] as String? ?? '',
        displayName: json['DisplayName'] as String?,
        avatarUrl: json['AvatarUrl'] as String?,
        bio: json['Bio'] as String?,
        isOnline: json['IsOnline'] as bool? ?? false,
        lastSeenAt: _parseNullableDateTime(json['LastSeenAt']),
      );

  Map<String, dynamic> toJson() => {
    'UserId': userId,
    'Username': username,
    if (displayName != null) 'DisplayName': displayName,
    if (avatarUrl != null) 'AvatarUrl': avatarUrl,
    if (bio != null) 'Bio': bio,
    'IsOnline': isOnline,
    if (lastSeenAt != null)
      'LastSeenAt': lastSeenAt!.millisecondsSinceEpoch,
  };
}

// ─── Type 104: ChatListStream ──────────────────────────────────────────────

class ChatListStreamRequest {
  final int chunkSize;
  final String? compressionMethod;

  ChatListStreamRequest({
    this.chunkSize = 100,
    this.compressionMethod,
  });

  factory ChatListStreamRequest.fromJson(Map<String, dynamic> json) =>
      ChatListStreamRequest(
        chunkSize: (json['ChunkSize'] as num? ?? 100).toInt(),
        compressionMethod: json['CompressionMethod'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'ChunkSize': chunkSize,
    if (compressionMethod != null) 'CompressionMethod': compressionMethod,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

// ─── Type 105: ChatListChunk ──────────────────────────────────────────────

class ChatListChunk {
  final bool success;
  final int chunkIndex;
  final int totalChunks;
  final List<ChatListItem> chunkData;
  final String? message;

  ChatListChunk({
    required this.success,
    required this.chunkIndex,
    required this.totalChunks,
    this.chunkData = const [],
    this.message,
  });

  factory ChatListChunk.fromJson(Map<String, dynamic> json) => ChatListChunk(
    success: json['Success'] as bool? ?? false,
    chunkIndex: (json['ChunkIndex'] as num? ?? 0).toInt(),
    totalChunks: (json['TotalChunks'] as num? ?? 0).toInt(),
    chunkData: (json['ChunkData'] as List<dynamic>? ?? [])
        .map((item) => ChatListItem.fromJson(item as Map<String, dynamic>))
        .toList(),
    message: json['Message'] as String?,
  );

  factory ChatListChunk.fromBytes(List<int> bytes) =>
      ChatListChunk.fromJson(_decodePayloadMap(bytes));
}

// ChatListItem - reused from existing message_payloads.dart
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
    chatId: (json['ChatId'] as num? ?? 0).toInt(),
    type: json['Type'] as String? ?? '',
    title: json['Title'] as String? ?? '',
    avatarUrl: json['AvatarUrl'] as String?,
    presenceStatus: json['PresenceStatus'] as String?,
    lastMessage: json['LastMessage'] as String?,
    lastMessageAt: _parseNullableDateTime(json['LastMessageAt']),
    unreadCount: (json['UnreadCount'] as num? ?? 0).toInt(),
    peerUserId: (json['PeerUserId'] as num?)?.toInt(),
    channelId: (json['ChannelId'] as num?)?.toInt(),
  );

  int get roomTargetId => peerUserId ?? channelId ?? chatId;
}

// ─── Type 106: ServerOverloaded ────────────────────────────────────────────

class ServerOverloaded {
  final String reason;
  final int suggestedBackoffMs;
  final int retryAfterMs;
  final String recommendedAction; // "wait", "switch_server", "reduce_features"

  ServerOverloaded({
    required this.reason,
    this.suggestedBackoffMs = 60000,
    this.retryAfterMs = 120000,
    this.recommendedAction = 'wait',
  });

  factory ServerOverloaded.fromJson(Map<String, dynamic> json) =>
      ServerOverloaded(
        reason: json['Reason'] as String? ?? 'server_overloaded',
        suggestedBackoffMs: (json['SuggestedBackoffMs'] as num? ?? 60000).toInt(),
        retryAfterMs: (json['RetryAfterMs'] as num? ?? 120000).toInt(),
        recommendedAction: json['RecommendedAction'] as String? ?? 'wait',
      );

  factory ServerOverloaded.fromBytes(List<int> bytes) =>
      ServerOverloaded.fromJson(_decodePayloadMap(bytes));

  Map<String, dynamic> toJson() => {
    'Reason': reason,
    'SuggestedBackoffMs': suggestedBackoffMs,
    'RetryAfterMs': retryAfterMs,
    'RecommendedAction': recommendedAction,
  };
}

// ─── Helper Functions ──────────────────────────────────────────────────────

Map<String, dynamic> _decodePayloadMap(List<int> bytes) {
  try {
    final decoded = msgpack.deserialize(Uint8List.fromList(bytes));
    if (decoded is Map) {
      return Map<String, dynamic>.from(
        decoded.map((k, v) => MapEntry(k.toString(), v)),
      );
    }
    return {};
  } catch (e) {
    return {};
  }
}

DateTime _parseDateTime(dynamic value, {required DateTime defaultValue}) {
  if (value == null) return defaultValue;
  if (value is DateTime) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return defaultValue;
    }
  }
  return defaultValue;
}

DateTime? _parseNullableDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }
  if (value is String) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
  return null;
}
