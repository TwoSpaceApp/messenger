import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/payloads/helpers.dart';

class SessionListRequest {
  const SessionListRequest();

  Map<String, dynamic> toJson() => const <String, dynamic>{};

  List<int> toBytes() => msgpack.serialize(toJson());
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

  factory ActiveSessionInfo.fromJson(Map<String, dynamic> json) {
    String? readString(List<String> keys) {
      for (final key in keys) {
        final value = json[key]?.toString().trim();
        if (value != null &&
            value.isNotEmpty &&
            value.toLowerCase() != "null") {
          return value;
        }
      }
      return null;
    }

    DateTime? readDateTime(List<String> keys) {
      for (final key in keys) {
        final parsed = parseNullableDateTimeValue(json[key]);
        if (parsed != null) {
          return parsed;
        }
      }
      return null;
    }

    return ActiveSessionInfo(
      sessionId:
          readString(const <String>[
            "SessionId",
            "Id",
            "SessionTokenId",
            "DeviceId",
          ]) ??
          "",
      clientInfo: readString(const <String>["ClientInfo"]) ?? "",
      isCurrent: parseBoolValue(
        json["IsCurrent"] ??
            json["Current"] ??
            json["IsThisDevice"],
      ),
      isOnline: parseBoolValue(json["IsOnline"]),
      deviceName: readString(const <String>[
        "DeviceName",
        "Device",
        "DeviceTitle",
        "ClientInfo",
      ]),
      platform: readString(const <String>[
        "Platform",
        "OsName",
        "OS",
        "System",
      ]),
      appVersion: readString(const <String>[
        "AppVersion",
        "Version",
        "ClientVersion",
      ]),
      ipAddress: readString(const <String>[
        "IpAddress",
        "IPAddress",
        "Ip",
        "RemoteIp",
      ]),
      userAgent: readString(const <String>[
        "UserAgent",
        "Client",
        "ClientName",
      ]),
      createdAt: readDateTime(const <String>[
        "CreatedAtUtc",
        "CreatedAt",
        "IssuedAt",
      ]),
      lastActivityAt: readDateTime(const <String>[
        "LastActivityAtUtc",
        "LastActivityAt",
        "LastSeenAt",
        "LastSeen",
      ]),
    );
  }

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
}

class SessionListResponse {
  const SessionListResponse({
    required this.success,
    required this.sessions,
    this.message,
  });

  factory SessionListResponse.fromJson(Map<String, dynamic> json) {
    final rawSessions =
        json["Sessions"] ?? json["ActiveSessions"] ?? json["Items"];
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
          json["Success"] == null || parseBoolValue(json["Success"]),
      sessions: sessions,
      message: json["Error"]?.toString() ?? json["Message"]?.toString(),
    );
  }

  factory SessionListResponse.fromBytes(List<int> bytes) {
    return SessionListResponse.fromJson(decodePayloadMap(bytes));
  }

  final bool success;
  final List<ActiveSessionInfo> sessions;
  final String? message;
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

  factory SessionRevokeResponse.fromJson(Map<String, dynamic> json) {
    return SessionRevokeResponse(
      success:
          json["Success"] == null || parseBoolValue(json["Success"]),
      sessionId: json["SessionId"]?.toString() ?? json["Id"]?.toString(),
      revokedCurrentSession: parseBoolValue(
        json["RevokedCurrentSession"] ?? json["CurrentSessionRevoked"],
      ),
      message: json["Error"]?.toString() ?? json["Message"]?.toString(),
    );
  }

  factory SessionRevokeResponse.fromBytes(List<int> bytes) {
    return SessionRevokeResponse.fromJson(decodePayloadMap(bytes));
  }

  final bool success;
  final String? sessionId;
  final bool revokedCurrentSession;
  final String? message;
}

class SessionTerminatedEventPayload {
  const SessionTerminatedEventPayload({
    required this.reason,
    required this.revokedByConnectionId,
  });

  factory SessionTerminatedEventPayload.fromJson(
    Map<String, dynamic> json,
  ) {
    return SessionTerminatedEventPayload(
      reason: json["Reason"]?.toString() ?? "",
      revokedByConnectionId: parseIntValue(
        json["RevokedByConnectionId"] ?? 0,
        fieldName: "RevokedByConnectionId",
      ),
    );
  }

  factory SessionTerminatedEventPayload.fromBytes(List<int> bytes) {
    return SessionTerminatedEventPayload.fromJson(decodePayloadMap(bytes));
  }

  final String reason;
  final int revokedByConnectionId;
}

class ReadSyncEventPayload {
  const ReadSyncEventPayload({
    required this.messageIds,
    required this.readAt,
  });

  factory ReadSyncEventPayload.fromJson(Map<String, dynamic> json) {
    return ReadSyncEventPayload(
      messageIds: parseIntList(json["MessageIds"]),
      readAt: parseNullableDateTimeValue(json["ReadAt"]) ??
          DateTime.now().toUtc(),
    );
  }

  factory ReadSyncEventPayload.fromBytes(List<int> bytes) {
    return ReadSyncEventPayload.fromJson(decodePayloadMap(bytes));
  }

  final List<int> messageIds;
  final DateTime readAt;
}
