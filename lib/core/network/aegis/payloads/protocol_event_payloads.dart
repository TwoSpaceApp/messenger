import 'package:two_space_app/core/network/aegis/payloads/helpers.dart';

class TokenExpired {
  TokenExpired({
    required this.expiresAt,
    this.refreshToken,
  });

  factory TokenExpired.fromJson(Map<String, dynamic> json) => TokenExpired(
    expiresAt: parseDateTimeValue(json["ExpiresAtMs"]),
    refreshToken: json["RefreshToken"] as String?,
  );

  factory TokenExpired.fromBytes(List<int> bytes) =>
      TokenExpired.fromJson(decodePayloadMap(bytes));
  final DateTime expiresAt;
  final String? refreshToken;

  Map<String, dynamic> toJson() => {
    'ExpiresAtMs': expiresAt.millisecondsSinceEpoch,
    if (refreshToken != null) 'RefreshToken': refreshToken,
  };
}

class DisconnectReason {
  DisconnectReason({
    required this.reason,
    this.retryAfterMs,
    this.alternateServerUrl,
  });

  factory DisconnectReason.fromJson(Map<String, dynamic> json) =>
      DisconnectReason(
        reason: json["Reason"] as String? ?? "unknown",
        retryAfterMs: (json["RetryAfterMs"] as num?)?.toInt(),
        alternateServerUrl: json["AlternateServerUrl"] as String?,
      );

  factory DisconnectReason.fromBytes(List<int> bytes) =>
      DisconnectReason.fromJson(decodePayloadMap(bytes));
  final String reason;
  final int? retryAfterMs;
  final String? alternateServerUrl;

  Map<String, dynamic> toJson() => {
    'Reason': reason,
    if (retryAfterMs != null) 'RetryAfterMs': retryAfterMs,
    if (alternateServerUrl != null) 'AlternateServerUrl': alternateServerUrl,
  };
}

class SessionConflict {
  SessionConflict({
    required this.newSessionId,
    required this.newDeviceInfo,
    this.action = "disconnect_old",
  });

  factory SessionConflict.fromJson(Map<String, dynamic> json) {
    final deviceData = json["NewDeviceInfo"] as Map<String, dynamic>? ?? {};
    return SessionConflict(
      newSessionId: json["NewSessionId"] as String? ?? "",
      newDeviceInfo: DeviceInfo.fromJson(deviceData),
      action: json["Action"] as String? ?? "disconnect_old",
    );
  }

  factory SessionConflict.fromBytes(List<int> bytes) =>
      SessionConflict.fromJson(decodePayloadMap(bytes));
  final String newSessionId;
  final DeviceInfo newDeviceInfo;
  final String action;

  Map<String, dynamic> toJson() => {
    'NewSessionId': newSessionId,
    'NewDeviceInfo': newDeviceInfo.toJson(),
    'Action': action,
  };
}

class DeviceInfo {
  DeviceInfo({
    this.os,
    this.version,
    this.deviceName,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) => DeviceInfo(
    os: json["Os"] as String?,
    version: json["Version"] as String?,
    deviceName: json["DeviceName"] as String?,
  );
  final String? os;
  final String? version;
  final String? deviceName;

  Map<String, dynamic> toJson() => {
    if (os != null) 'Os': os,
    if (version != null) 'Version': version,
    if (deviceName != null) 'DeviceName': deviceName,
  };
}

class ServerOverloaded {
  ServerOverloaded({
    required this.reason,
    this.suggestedBackoffMs = 60000,
    this.retryAfterMs = 120000,
    this.recommendedAction = "wait",
  });

  factory ServerOverloaded.fromJson(Map<String, dynamic> json) =>
      ServerOverloaded(
        reason: json["Reason"] as String? ?? "server_overloaded",
        suggestedBackoffMs: (json["SuggestedBackoffMs"] as num? ?? 60000).toInt(),
        retryAfterMs: (json["RetryAfterMs"] as num? ?? 120000).toInt(),
        recommendedAction: json["RecommendedAction"] as String? ?? "wait",
      );

  factory ServerOverloaded.fromBytes(List<int> bytes) =>
      ServerOverloaded.fromJson(decodePayloadMap(bytes));
  final String reason;
  final int suggestedBackoffMs;
  final int retryAfterMs;
  final String recommendedAction;

  Map<String, dynamic> toJson() => {
    'Reason': reason,
    'SuggestedBackoffMs': suggestedBackoffMs,
    'RetryAfterMs': retryAfterMs,
    'RecommendedAction': recommendedAction,
  };
}
