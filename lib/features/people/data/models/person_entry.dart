import 'package:flutter/foundation.dart';

@immutable
class PersonEntry {
  const PersonEntry({
    required this.id,
    required this.displayName,
    this.username,
    this.avatarUrl,
    this.photoBytes,
    this.phones = const <String>[],
    this.remoteUserId,
    this.isTwoSpaceUser = false,
    this.isDeviceContact = false,
    this.isFavorite = false,
    this.isOnline = false,
    this.presenceStatus,
    this.lastSeenAt,
    this.lastInteractionAt,
    this.note,
  });

  factory PersonEntry.fromJson(Map<String, dynamic> json) {
    return PersonEntry(
      id: json["id"]?.toString() ?? "",
      displayName: json["displayName"]?.toString() ?? "",
      username: json["username"]?.toString(),
      avatarUrl: json["avatarUrl"]?.toString(),
      phones: (json["phones"] as List<dynamic>? ?? const <dynamic>[])
          .map((value) => value.toString())
          .toList(),
      remoteUserId: json["remoteUserId"]?.toString(),
      isTwoSpaceUser: json["isTwoSpaceUser"] == true,
      isDeviceContact: json["isDeviceContact"] == true,
      isFavorite: json["isFavorite"] == true,
      isOnline: json["isOnline"] == true,
      presenceStatus: json["presenceStatus"]?.toString(),
      lastSeenAt: _dateTimeFromJson(json["lastSeenAt"]),
      lastInteractionAt: _dateTimeFromJson(json["lastInteractionAt"]),
      note: json["note"]?.toString(),
    );
  }

  final String id;
  final String displayName;
  final String? username;
  final String? avatarUrl;
  final Uint8List? photoBytes;
  final List<String> phones;
  final String? remoteUserId;
  final bool isTwoSpaceUser;
  final bool isDeviceContact;
  final bool isFavorite;
  final bool isOnline;
  final String? presenceStatus;
  final DateTime? lastSeenAt;
  final DateTime? lastInteractionAt;
  final String? note;

  bool get isInvitable => isDeviceContact && !isTwoSpaceUser;
  String get stableRemoteId => remoteUserId ?? id;

  PersonEntry copyWith({
    String? id,
    String? displayName,
    String? username,
    String? avatarUrl,
    Uint8List? photoBytes,
    List<String>? phones,
    String? remoteUserId,
    bool? isTwoSpaceUser,
    bool? isDeviceContact,
    bool? isFavorite,
    bool? isOnline,
    String? presenceStatus,
    DateTime? lastSeenAt,
    DateTime? lastInteractionAt,
    String? note,
    bool clearPhotoBytes = false,
  }) {
    return PersonEntry(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      photoBytes: clearPhotoBytes ? null : (photoBytes ?? this.photoBytes),
      phones: phones ?? this.phones,
      remoteUserId: remoteUserId ?? this.remoteUserId,
      isTwoSpaceUser: isTwoSpaceUser ?? this.isTwoSpaceUser,
      isDeviceContact: isDeviceContact ?? this.isDeviceContact,
      isFavorite: isFavorite ?? this.isFavorite,
      isOnline: isOnline ?? this.isOnline,
      presenceStatus: presenceStatus ?? this.presenceStatus,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'displayName': displayName,
      'username': username,
      'avatarUrl': avatarUrl,
      'phones': phones,
      'remoteUserId': remoteUserId,
      'isTwoSpaceUser': isTwoSpaceUser,
      'isDeviceContact': isDeviceContact,
      'isFavorite': isFavorite,
      'isOnline': isOnline,
      'presenceStatus': presenceStatus,
      'lastSeenAt': lastSeenAt?.toIso8601String(),
      'lastInteractionAt': lastInteractionAt?.toIso8601String(),
      'note': note,
    };
  }

  static DateTime? _dateTimeFromJson(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
