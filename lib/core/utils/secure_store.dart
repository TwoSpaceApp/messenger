import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class AppSecureStorage {
  static const AndroidOptions _androidOptions = AndroidOptions(
    sharedPreferencesName: 'two_space_secure_storage',
    preferencesKeyPrefix: 'two_space_',
  );

  static const IOSOptions _iosOptions = IOSOptions(
    accountName: 'two_space_secure_storage',
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  static const MacOsOptions _macOsOptions = MacOsOptions(
    accountName: 'two_space_secure_storage',
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  static const FlutterSecureStorage instance = FlutterSecureStorage(
    aOptions: _androidOptions,
    iOptions: _iosOptions,
    mOptions: _macOsOptions,
  );
}

class SecureStore {
  static const FlutterSecureStorage _storage = AppSecureStorage.instance;
  static final Map<String, String?> _cache = <String, String?>{};
  static bool _allKeysCached = false;
  static bool _preferFallback = false;
  static Future<File>? _fallbackFileFuture;
  static const List<String> _sensitiveKeyMarkers = <String>[
    'token',
    'password',
    'secret',
    'credential',
    'session',
    'auth',
  ];

  static bool _isSensitiveKey(String key) {
    final normalized = key.trim().toLowerCase();
    return _sensitiveKeyMarkers.any(normalized.contains);
  }

  static bool _shouldFallbackFor(Object error) {
    if (kIsWeb) {
      return false;
    }

    if (error is PlatformException || error is MissingPluginException) {
      return true;
    }

    final text = error.toString().toLowerCase();
    return text.contains('libsecret') ||
        text.contains('keyring') ||
        text.contains('org.freedesktop.secrets') ||
        text.contains('failed to unblock') ||
        text.contains('secret service');
  }

  static Future<T> _runWithFallback<T>(
    Future<T> Function() primary,
    Future<T> Function() fallback,
    String? key,
  ) async {
    if (_preferFallback) {
      if (key != null && _isSensitiveKey(key)) {
        return primary();
      }
      return fallback();
    }

    try {
      return await primary();
    } on Object catch (error) {
      if (!_shouldFallbackFor(error)) {
        rethrow;
      }
      if (key != null && _isSensitiveKey(key)) {
        rethrow;
      }
      _preferFallback = true;
      return fallback();
    }
  }

  static Future<File> _getFallbackFile() {
    final existing = _fallbackFileFuture;
    if (existing != null) {
      return existing;
    }

    final future = () async {
      final baseDir = await getApplicationSupportDirectory();
      final dir = Directory('${baseDir.path}/secure_store');
      // File IO is intentional in storage fallback
      // ignore: avoid_slow_async_io
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final file = File('${dir.path}/fallback_store.json');
      // File IO is intentional in storage fallback
      // ignore: avoid_slow_async_io
      if (!await file.exists()) {
        await file.writeAsString('{}', flush: true);
      }
      return file;
    }();

    _fallbackFileFuture = future;
    return future;
  }

  static Future<Map<String, String>> _readFallbackMap() async {
    final file = await _getFallbackFile();
    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return <String, String>{};
      }
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        return <String, String>{};
      }
      return decoded.map<String, String>(
        (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
      );
    } on Object {
      return <String, String>{};
    }
  }

  static Future<void> _writeFallbackMap(Map<String, String> values) async {
    final file = await _getFallbackFile();
    await file.writeAsString(jsonEncode(values), flush: true);
  }

  static Future<void> write(String key, String value) async {
    await _runWithFallback<void>(
      () => _storage.write(key: key, value: value),
      () async {
        final values = await _readFallbackMap();
        values[key] = value;
        await _writeFallbackMap(values);
      },
      key,
    );
    _cache[key] = value;
  }

  static Future<String?> read(String key) async {
    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    final value = await _runWithFallback<String?>(
      () => _storage.read(key: key),
      () async {
        final values = await _readFallbackMap();
        return values[key];
      },
      key,
    );
    _cache[key] = value;
    return value;
  }

  static Future<Map<String, String>> readMany(Iterable<String> keys) async {
    final uniqueKeys = keys.toSet();
    final missingKeys = uniqueKeys
        .where((key) => !_cache.containsKey(key))
        .toList(growable: false);

    if (missingKeys.isNotEmpty) {
      final hasSensitiveKey = missingKeys.any(_isSensitiveKey);
      final values = await _runWithFallback<Map<String, String?>>(
        () async {
          final all = await _storage.readAll();
          _allKeysCached = true;
          return <String, String?>{
            for (final key in missingKeys) key: all[key],
          };
        },
        () async {
          final all = await _readFallbackMap();
          _allKeysCached = true;
          return <String, String?>{
            for (final key in missingKeys) key: all[key],
          };
        },
        hasSensitiveKey ? missingKeys.join(',') : null,
      );
      for (final entry in values.entries) {
        _cache[entry.key] = entry.value;
      }
    }

    return <String, String>{
      for (final key in uniqueKeys)
        if (_cache[key]?.isNotEmpty ?? false) key: _cache[key]!,
    };
  }

  static Future<Map<String, String>> readAll() async {
    if (_allKeysCached) {
      return <String, String>{
        for (final entry in _cache.entries)
          if (entry.value != null) entry.key: entry.value!,
      };
    }

    final values = await _runWithFallback<Map<String, String>>(
      () => _storage.readAll(),
      _readFallbackMap,
      null,
    );
    _cache
      ..clear()
      ..addAll(values);
    _allKeysCached = true;
    return values;
  }

  static Future<void> delete(String key) async {
    await _runWithFallback<void>(
      () => _storage.delete(key: key),
      () async {
        final values = await _readFallbackMap();
        values.remove(key);
        await _writeFallbackMap(values);
      },
      key,
    );
    _cache.remove(key);
  }

  static Future<void> deleteAll() async {
    await _runWithFallback<void>(
      _storage.deleteAll,
      () => _writeFallbackMap(<String, String>{}),
      null,
    );
    clearMemoryCache();
  }

  static void clearMemoryCache() {
    _cache.clear();
    _allKeysCached = false;
  }
}
