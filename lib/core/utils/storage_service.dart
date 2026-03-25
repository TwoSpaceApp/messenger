import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageSnapshot {
  const StorageSnapshot({
    required this.appDataBytes,
    required this.photoBytes,
    required this.videoBytes,
    required this.fileBytes,
    required this.cacheBytes,
  });

  final int appDataBytes;
  final int photoBytes;
  final int videoBytes;
  final int fileBytes;
  final int cacheBytes;

  int get mediaBytes => photoBytes + videoBytes;

  int get totalBytes =>
      appDataBytes + photoBytes + videoBytes + fileBytes + cacheBytes;
  int get clearableBytes => photoBytes + videoBytes + fileBytes + cacheBytes;
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
    final photoBytes = await _matchingFileBytesRecursive(
      mediaDir,
      (file) => _isImageFile(file.path),
    );
    final videoBytes = await _matchingFileBytesRecursive(
      mediaDir,
      (file) => _isVideoFile(file.path),
    );
    final otherMediaBytes = await _matchingFileBytesRecursive(
      mediaDir,
      (file) => !_isImageFile(file.path) && !_isVideoFile(file.path),
    );
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
      photoBytes: photoBytes,
      videoBytes: videoBytes,
      fileBytes: exportedFilesBytes + otherMediaBytes,
      cacheBytes: tempBytes,
    );
  }

  Future<void> clearSelected({
    required bool clearPhotos,
    required bool clearVideos,
    required bool clearFiles,
    required bool clearCache,
  }) async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final tempDir = await getTemporaryDirectory();
    final mediaDir = Directory(p.join(documentsDir.path, 'aegis_media'));

    if (clearPhotos && clearVideos) {
      await _deleteDirectoryContents(mediaDir);
    } else {
      if (clearPhotos) {
        await _deleteMatchingFilesRecursive(
          mediaDir,
          (file) => _isImageFile(file.path),
        );
      }
      if (clearVideos) {
        await _deleteMatchingFilesRecursive(
          mediaDir,
          (file) => _isVideoFile(file.path),
        );
      }
    }

    if (clearFiles) {
      await _deleteMatchingFiles(
        documentsDir,
        (file) => _isExportedFile(file.path),
      );
      await _deleteMatchingFilesRecursive(
        mediaDir,
        (file) => !_isImageFile(file.path) && !_isVideoFile(file.path),
      );
    }

    if (clearCache) {
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

  Future<int> _matchingFileBytesRecursive(
    Directory directory,
    bool Function(File file) predicate,
  ) async {
    try {
      if (!await directory.exists()) return 0;

      var total = 0;
      await for (final entity
          in directory.list(recursive: true, followLinks: false)) {
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

  Future<void> _deleteMatchingFilesRecursive(
    Directory directory,
    bool Function(File file) predicate,
  ) async {
    try {
      if (!await directory.exists()) return;

      await for (final entity
          in directory.list(recursive: true, followLinks: false)) {
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

  bool _isImageFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.heic');
  }

  bool _isVideoFile(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.avi');
  }
}
