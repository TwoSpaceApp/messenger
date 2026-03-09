import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageSnapshot {
  const StorageSnapshot({
    required this.appDataBytes,
    required this.mediaBytes,
    required this.fileBytes,
  });

  final int appDataBytes;
  final int mediaBytes;
  final int fileBytes;

  int get totalBytes => appDataBytes + mediaBytes + fileBytes;
  int get clearableBytes => mediaBytes + fileBytes;
}

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  Future<StorageSnapshot> collectSnapshot() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final tempDir = await getTemporaryDirectory();
    final supportDir = await _getSupportDirectorySafe();

    final documentsBytes = await _directorySize(documentsDir);
    final mediaDir = Directory(p.join(documentsDir.path, 'aegis_media'));
    final mediaBytes = await _directorySize(mediaDir);
    final exportedFilesBytes = await _matchingFileBytes(
      documentsDir,
      (file) => _isExportedFile(file.path),
    );
    final tempBytes = await _directorySize(tempDir);
    final supportBytes =
        supportDir == null ? 0 : await _directorySize(supportDir);

    final appDataBytes =
        (documentsBytes - mediaBytes - exportedFilesBytes)
                .clamp(0, documentsBytes) +
            supportBytes;

    return StorageSnapshot(
      appDataBytes: appDataBytes,
      mediaBytes: mediaBytes,
      fileBytes: exportedFilesBytes + tempBytes,
    );
  }

  Future<void> clearSelected({
    required bool clearMedia,
    required bool clearFiles,
  }) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final tempDir = await getTemporaryDirectory();

    if (clearMedia) {
      final mediaDir = Directory(p.join(documentsDir.path, 'aegis_media'));
      await _deleteDirectoryContents(mediaDir);
    }

    if (clearFiles) {
      await _deleteMatchingFiles(
        documentsDir,
        (file) => _isExportedFile(file.path),
      );
      await _deleteDirectoryContents(tempDir);
    }
  }

  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var value = bytes.toDouble();
    var unitIndex = 0;

    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }

    final fractionDigits = value >= 100 ? 0 : value >= 10 ? 1 : 2;
    return '${value.toStringAsFixed(fractionDigits)} ${units[unitIndex]}';
  }

  Future<Directory?> _getSupportDirectorySafe() async {
    try {
      return getApplicationSupportDirectory();
    } catch (_) {
      return null;
    }
  }

  Future<int> _directorySize(Directory directory) async {
    try {
      if (!await directory.exists()) return 0;

      var total = 0;
      await for (final entity
          in directory.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          total += await _fileSize(entity);
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _matchingFileBytes(
    Directory directory,
    bool Function(File file) predicate,
  ) async {
    try {
      if (!await directory.exists()) return 0;

      var total = 0;
      await for (final entity in directory.list(followLinks: false)) {
        if (entity is File && predicate(entity)) {
          total += await _fileSize(entity);
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _deleteMatchingFiles(
    Directory directory,
    bool Function(File file) predicate,
  ) async {
    try {
      if (!await directory.exists()) return;

      await for (final entity in directory.list(followLinks: false)) {
        if (entity is File && predicate(entity)) {
          try {
            await entity.delete();
          } catch (_) {}
        }
      }
    } catch (_) {}
  }

  Future<void> _deleteDirectoryContents(Directory directory) async {
    try {
      if (!await directory.exists()) return;
      await for (final entity in directory.list(followLinks: false)) {
        try {
          await entity.delete(recursive: true);
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<int> _fileSize(File file) async {
    try {
      return await file.length();
    } catch (_) {
      return 0;
    }
  }

  bool _isExportedFile(String path) {
    final name = p.basename(path);
    return name.startsWith('chat_') ||
        name.startsWith('twospace_backup_') ||
        name.startsWith('two_space_debug_');
  }
}
