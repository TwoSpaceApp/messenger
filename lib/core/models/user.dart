import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
    @Default({}) Map<String, dynamic> prefs,
    String? avatarUrl,
    String? avatarFileId,
    String? description,
    String? phone,
  }) = _User;
  const User._();

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Backwards-compatible alias to keep existing API unbroken
  factory User.fromMap(Map<String, dynamic> map) {
    final prefs = (map['prefs'] is Map)
        ? Map<String, dynamic>.from(map['prefs'])
        : <String, dynamic>{};
    final idStr = (map[r'$id'] ?? map['id'])?.toString() ?? '';
    final nameStr =
        (map['name'] as String?) ?? (prefs['displayName'] as String?) ?? idStr;
    final emailStr = (map['email'] as String?) ?? '';

    return User(
      id: idStr,
      name: nameStr,
      email: emailStr,
      prefs: prefs,
      avatarUrl: prefs['avatarUrl'] as String?,
      avatarFileId: prefs['avatarFileId']?.toString(),
      description: prefs['description'] as String?,
      phone: prefs['phone'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      r'$id': id,
      'name': name,
      'email': email,
      'prefs': {
        ...prefs,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (avatarFileId != null) 'avatarFileId': avatarFileId,
        if (description != null) 'description': description,
        if (phone != null) 'phone': phone,
      },
    };
  }

  String get displayName {
    if (name.isNotEmpty) return name;
    if (prefs.containsKey('nickname') &&
        ((prefs['nickname'] as String?)?.isNotEmpty ?? false))
      return '@${prefs['nickname']}';
    if (email.isNotEmpty) return email;
    return id;
  }
}
