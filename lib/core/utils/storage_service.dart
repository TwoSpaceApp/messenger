import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:two_space_app/core/utils/secure_store.dart';

enum StorageAutoCleanInterval { daily, weekly, monthly }

extension StorageAutoCleanIntervalX on StorageAutoCleanInterval {
  String get storageValue {
    switch (this) {
      case StorageAutoCleanInterval.daily:
        return 'daily';
      case StorageAutoCleanInterval.weekly:
        return 'weekly';
      case StorageAutoCleanInterval.monthly:
        return 'monthly';
    }
  }

  Duration get duration {
    switch (this) {
      case StorageAutoCleanInterval.daily:
        return const Duration(days: 1);
      case StorageAutoCleanInterval.weekly:
        return const Duration(days: 7);
      case StorageAutoCleanInterval.monthly:
        return const Duration(days: 30);
    }
  }

  static StorageAutoCleanInterval fromStorage(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'weekly':
        return StorageAutoCleanInterval.weekly;
      case 'monthly':
        return StorageAutoCleanInterval.monthly;
      case 'daily':
      default:
        return StorageAutoCleanInterval.daily;
    }
  }
}

class StorageAutoCleanSettings {
  const StorageAutoCleanSettings({
    this.enabled = false,
    this.interval = StorageAutoCleanInterval.weekly,
    this.maxBytes = 1024 * 1024 * 1024,
    this.clearPhotos = false,
    this.clearVideos = true,
    this.clearFiles = true,
    this.clearCache = true,
    this.lastRunEpochMs,
  });

  final bool enabled;
  final StorageAutoCleanInterval interval;
  final int maxBytes;
  final bool clearPhotos;
  final bool clearVideos;
  final bool clearFiles;
  final bool clearCache;
  final int? lastRunEpochMs;

  DateTime? get lastRun => lastRunEpochMs == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(lastRunEpochMs!);

  bool get hasAnySelection =>
      clearPhotos || clearVideos || clearFiles || clearCache;

  StorageAutoCleanSettings copyWith({
    bool? enabled,
    StorageAutoCleanInterval? interval,
    int? maxBytes,
    bool? clearPhotos,
    bool? clearVideos,
    bool? clearFiles,
    bool? clearCache,
    int? lastRunEpochMs,
    bool clearLastRun = false,
  }) {
    return StorageAutoCleanSettings(
      enabled: enabled ?? this.enabled,
      interval: interval ?? this.interval,
      maxBytes: maxBytes ?? this.maxBytes,
      clearPhotos: clearPhotos ?? this.clearPhotos,
      clearVideos: clearVideos ?? this.clearVideos,
      clearFiles: clearFiles ?? this.clearFiles,
      clearCache: clearCache ?? this.clearCache,
      lastRunEpochMs: clearLastRun
          ? null
          : lastRunEpochMs ?? this.lastRunEpochMs,
    );
  }
}

class StorageAutoCleanupResult {
  const StorageAutoCleanupResult({
    required this.ran,
    required this.freedBytes,
    required this.reasonThreshold,
  });

  final bool ran;
  final int freedBytes;
  final bool reasonThreshold;
}

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
  static const _autoCleanEnabledKey = 'storage_auto_clean_enabled';
  static const _autoCleanIntervalKey = 'storage_auto_clean_interval';
  static const _autoCleanMaxBytesKey = 'storage_auto_clean_max_bytes';
  static const _autoCleanPhotosKey = 'storage_auto_clean_photos';
  static const _autoCleanVideosKey = 'storage_auto_clean_videos';
  static const _autoCleanFilesKey = 'storage_auto_clean_files';
  static const _autoCleanCacheKey = 'storage_auto_clean_cache';
  static const _autoCleanLastRunKey = 'storage_auto_clean_last_run';
  static const Set<String> _autoCleanKeys = <String>{
    _autoCleanEnabledKey,
    _autoCleanIntervalKey,
    _autoCleanMaxBytesKey,
    _autoCleanPhotosKey,
    _autoCleanVideosKey,
    _autoCleanFilesKey,
    _autoCleanCacheKey,
    _autoCleanLastRunKey,
  };

  Future<StorageSnapshot> collectSnapshot() async {
    var snapshot = await _collectSnapshotRaw();
    final cleanup = await runAutoCleanupIfNeeded(snapshot: snapshot);
    if (cleanup?.ran ?? false) {
      snapshot = await _collectSnapshotRaw();
    }
    return snapshot;
  }

  Future<StorageSnapshot> _collectSnapshotRaw() async {
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

  Future<StorageAutoCleanSettings> loadAutoCleanSettings() async {
    final stored = await SecureStore.readMany(_autoCleanKeys);

    String? valueOf(String key) => stored[key];

    return StorageAutoCleanSettings(
      enabled: valueOf(_autoCleanEnabledKey) == 'true',
      interval: StorageAutoCleanIntervalX.fromStorage(
        valueOf(_autoCleanIntervalKey),
      ),
      maxBytes:
          int.tryParse(valueOf(_autoCleanMaxBytesKey) ?? '') ?? 1024 * 1024 * 1024,
      clearPhotos: valueOf(_autoCleanPhotosKey) == 'true',
      clearVideos: valueOf(_autoCleanVideosKey) != 'false',
      clearFiles: valueOf(_autoCleanFilesKey) != 'false',
      clearCache: valueOf(_autoCleanCacheKey) != 'false',
      lastRunEpochMs: int.tryParse(valueOf(_autoCleanLastRunKey) ?? ''),
    );
  }

  Future<void> saveAutoCleanSettings(StorageAutoCleanSettings settings) async {
    await SecureStore.write(_autoCleanEnabledKey, settings.enabled.toString());
    await SecureStore.write(
      _autoCleanIntervalKey,
      settings.interval.storageValue,
    );
    await SecureStore.write(_autoCleanMaxBytesKey, settings.maxBytes.toString());
    await SecureStore.write(_autoCleanPhotosKey, settings.clearPhotos.toString());
    await SecureStore.write(_autoCleanVideosKey, settings.clearVideos.toString());
    await SecureStore.write(_autoCleanFilesKey, settings.clearFiles.toString());
    await SecureStore.write(_autoCleanCacheKey, settings.clearCache.toString());
    if (settings.lastRunEpochMs == null) {
      await SecureStore.delete(_autoCleanLastRunKey);
    } else {
      await SecureStore.write(
        _autoCleanLastRunKey,
        settings.lastRunEpochMs.toString(),
      );
    }
  }

  Future<StorageAutoCleanupResult?> runAutoCleanupIfNeeded({
    StorageSnapshot? snapshot,
  }) async {
    final settings = await loadAutoCleanSettings();
    if (!settings.enabled || !settings.hasAnySelection) {
      return null;
    }

    final currentSnapshot = snapshot ?? await _collectSnapshotRaw();
    final now = DateTime.now();
    final dueByInterval = settings.lastRun == null ||
        now.difference(settings.lastRun!) >= settings.interval.duration;
    final dueByThreshold = currentSnapshot.totalBytes >= settings.maxBytes;

    if (!dueByInterval && !dueByThreshold) {
      return const StorageAutoCleanupResult(
        ran: false,
        freedBytes: 0,
        reasonThreshold: false,
      );
    }

    final estimatedFreed =
        (settings.clearPhotos ? currentSnapshot.photoBytes : 0) +
            (settings.clearVideos ? currentSnapshot.videoBytes : 0) +
            (settings.clearFiles ? currentSnapshot.fileBytes : 0) +
            (settings.clearCache ? currentSnapshot.cacheBytes : 0);

    if (estimatedFreed <= 0) {
      await saveAutoCleanSettings(
        settings.copyWith(lastRunEpochMs: now.millisecondsSinceEpoch),
      );
      return StorageAutoCleanupResult(
        ran: false,
        freedBytes: 0,
        reasonThreshold: dueByThreshold,
      );
    }

    await clearSelected(
      clearPhotos: settings.clearPhotos,
      clearVideos: settings.clearVideos,
      clearFiles: settings.clearFiles,
      clearCache: settings.clearCache,
    );
    await saveAutoCleanSettings(
      settings.copyWith(lastRunEpochMs: now.millisecondsSinceEpoch),
    );
    return StorageAutoCleanupResult(
      ran: true,
      freedBytes: estimatedFreed,
      reasonThreshold: dueByThreshold,
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
      // Directory IO is intentional in storage service
      // ignore: avoid_slow_async_io
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
      // Directory IO is intentional in storage service
      // ignore: avoid_slow_async_io
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
      // Directory IO is intentional in storage service
      // ignore: avoid_slow_async_io
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
      // Directory IO is intentional in storage service
      // ignore: avoid_slow_async_io
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
      // Directory IO is intentional in storage service
      // ignore: avoid_slow_async_io
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
      // Directory IO is intentional in storage service
      // ignore: avoid_slow_async_io
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
