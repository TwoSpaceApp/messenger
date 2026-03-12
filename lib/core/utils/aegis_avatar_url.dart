import 'package:two_space_app/core/config/environment.dart';

String? normalizeAegisAvatarUrl(String? rawUrl) {
  final value = rawUrl?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }

  if (value.startsWith('data:') ||
      value.startsWith('http://') ||
      value.startsWith('https://') ||
      value.startsWith('file://')) {
    return value;
  }

  if (value.startsWith('/data/media/avatars/')) {
    final fileName = Uri.encodeComponent(value.split('/').last);
    return Uri(
      scheme: 'http',
      host: Environment.aegisHost,
      port: 5000,
      path: '/media/avatars/$fileName',
    ).toString();
  }

  if (value.startsWith('/media/avatars/')) {
    return Uri(
      scheme: 'http',
      host: Environment.aegisHost,
      port: 5000,
      path: value,
    ).toString();
  }

  return value;
}

bool isLocalAvatarFilePath(String? rawUrl) {
  final value = rawUrl?.trim();
  if (value == null || value.isEmpty) {
    return false;
  }

  if (!value.startsWith('/')) {
    return false;
  }

  return !value.startsWith('/media/avatars/') &&
      !value.startsWith('/data/media/avatars/');
}
