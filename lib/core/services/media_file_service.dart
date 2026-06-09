import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

class MediaFileService {
  MediaFileService._();

  static Future<void> open(String sourcePath) async {
    final result = await OpenFilex.open(sourcePath);
    if (result.type == ResultType.done) {
      return;
    }
    final message = result.message.trim();
    throw Exception(message.isEmpty ? 'Unable to open file' : message);
  }

  static Future<void> share(
    String sourcePath, {
    String? subject,
    String? text,
  }) {
    return SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(sourcePath)],
        title: subject,
        text: text,
      ),
    );
  }

  static Future<String?> saveAs(
    String sourcePath, {
    String? suggestedName,
  }) async {
    final sourceFile = File(sourcePath);
    // File IO is intentional in save-as flow
    // ignore: avoid_slow_async_io
    if (!await sourceFile.exists()) {
      throw Exception('File not found');
    }

    final resolvedName = _resolvedFileName(
      sourcePath,
      suggestedName: suggestedName,
    );
    final extension = p.extension(resolvedName).replaceFirst('.', '');
    final typeGroups = extension.isEmpty
        ? null
        : <XTypeGroup>[
            XTypeGroup(
              label: 'file',
              extensions: <String>[extension],
            ),
          ];
    final location = await getSaveLocation(
      suggestedName: resolvedName,
      acceptedTypeGroups: typeGroups ?? const <XTypeGroup>[],
    );
    if (location == null || location.path.isEmpty) {
      return null;
    }

    final targetPath = location.path;
    final sourceAbsolute = p.normalize(sourceFile.absolute.path);
    final targetAbsolute = p.normalize(File(targetPath).absolute.path);
    if (sourceAbsolute == targetAbsolute) {
      return targetPath;
    }

    final targetFile = File(targetPath);
    final parentDir = targetFile.parent;
    // File IO is intentional in save-as flow
    // ignore: avoid_slow_async_io
    if (!await parentDir.exists()) {
      await parentDir.create(recursive: true);
    }
    // File IO is intentional in save-as flow
    // ignore: avoid_slow_async_io
    if (await targetFile.exists()) {
      await targetFile.delete();
    }

    await sourceFile.copy(targetPath);
    return targetPath;
  }

  static String resolvedFileName(
    String sourcePath, {
    String? suggestedName,
  }) => _resolvedFileName(sourcePath, suggestedName: suggestedName);

  static String _resolvedFileName(
    String sourcePath, {
    String? suggestedName,
  }) {
    final candidate = (suggestedName ?? '').trim();
    if (candidate.isNotEmpty) {
      return candidate;
    }

    final sourceName = p.basename(sourcePath).trim();
    if (sourceName.isNotEmpty) {
      return sourceName;
    }

    return 'attachment';
  }
}
