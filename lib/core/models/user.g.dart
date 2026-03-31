// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  prefs: json['prefs'] as Map<String, dynamic>? ?? const {},
  avatarUrl: json['avatarUrl'] as String?,
  avatarFileId: json['avatarFileId'] as String?,
  description: json['description'] as String?,
  phone: json['phone'] as String?,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'prefs': instance.prefs,
  'avatarUrl': instance.avatarUrl,
  'avatarFileId': instance.avatarFileId,
  'description': instance.description,
  'phone': instance.phone,
};
