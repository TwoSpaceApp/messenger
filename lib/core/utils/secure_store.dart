import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStore {
  static const _storage = FlutterSecureStorage();
  static final Map<String, String?> _cache = <String, String?>{};
  static bool _allKeysCached = false;

  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
    _cache[key] = value;
  }

  static Future<String?> read(String key) async {
    if (_cache.containsKey(key)) {
      return _cache[key];
    }
    final value = await _storage.read(key: key);
    _cache[key] = value;
    return value;
  }

  static Future<Map<String, String>> readMany(Iterable<String> keys) async {
    final uniqueKeys = keys.toSet();
    final missingKeys = uniqueKeys.where((key) => !_cache.containsKey(key)).toList(growable: false);

    if (missingKeys.isNotEmpty) {
      final values = await Future.wait(
        missingKeys.map((key) async => MapEntry(key, await _storage.read(key: key))),
      );
      for (final entry in values) {
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

    final values = await _storage.readAll();
    _cache
      ..clear()
      ..addAll(values);
    _allKeysCached = true;
    return values;
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
    _cache.remove(key);
  }

  static void clearMemoryCache() {
    _cache.clear();
    _allKeysCached = false;
  }
}
