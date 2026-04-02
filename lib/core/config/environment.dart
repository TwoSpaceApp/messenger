import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:two_space_app/core/config/env.dart';

class Environment {
  Environment._();

  static String? _cachedAegisHost;
  static int? _cachedAegisPort;
  static Duration? _cachedAegisConnectTimeout;
  static String? _cachedAegisTransportMaskingKey;
  static bool? _cachedAegisUseTls;
  static int? _cachedAegisAppId;
  static String? _cachedAegisAppHash;
  static String? _cachedSentryDsn;
  static String? _cachedAppEnv;
  static bool? _cachedEnableDevTools;
  static final Map<String, String> _runtimeOverrides = <String, String>{};

  static Future<void> load() async {
    // Envied values are compile-time constants. In local/dev runs the .env
    // file can change without regenerating env.g.dart, so we apply best-effort
    // runtime overrides from .env when available.
    if (kIsWeb) return;
    try {
      final file = File('.env');
      if (!await file.exists()) return;

      final lines = await file.readAsLines();
      _runtimeOverrides.clear();
      for (final rawLine in lines) {
        final line = rawLine.trim();
        if (line.isEmpty || line.startsWith('#')) continue;
        final sep = line.indexOf('=');
        if (sep <= 0) continue;
        final key = line.substring(0, sep).trim();
        final value = line.substring(sep + 1).trim();
        _runtimeOverrides[key] = value;
      }

      _cachedAegisHost = null;
      _cachedAegisPort = null;
      _cachedAegisConnectTimeout = null;
      _cachedAegisTransportMaskingKey = null;
      _cachedAegisUseTls = null;
      _cachedAegisAppId = null;
      _cachedAegisAppHash = null;
      _cachedSentryDsn = null;
      _cachedAppEnv = null;
      _cachedEnableDevTools = null;
    } catch (_) {
      // Fall back to generated Envied values if runtime file access fails.
    }
  }

  static String _string(String key, String fallback) {
    final override = _runtimeOverrides[key];
    return override ?? fallback;
  }

  static String get aegisHost =>
      _cachedAegisHost ??= _string('AEGIS_HOST', Env.aegisHost);
  static int get aegisPort => _cachedAegisPort ??=
      int.tryParse(_string('AEGIS_PORT', Env.aegisPort)) ?? 8888;
  static Duration get aegisConnectTimeout =>
      _cachedAegisConnectTimeout ??= Duration(
        seconds:
            int.tryParse(
              _string(
                'AEGIS_CONNECT_TIMEOUT_SECONDS',
                Env.aegisConnectTimeoutSeconds,
              ),
            ) ??
            10,
      );
  static String? get aegisTransportMaskingKey {
    final value = _cachedAegisTransportMaskingKey ??= _string(
      'AEGIS_TRANSPORT_MASKING_KEY',
      Env.aegisTransportMaskingKey,
    ).trim();
    if (value.isEmpty) return null;
    if (_looksLikeHandshakeSigningPublicKey(value)) {
      return null;
    }
    return value;
  }

  static bool get aegisUseTls => _cachedAegisUseTls ??=
      _string('AEGIS_USE_TLS', Env.aegisUseTls) == 'true';

  static int? get aegisAppId {
    final raw = _string('AEGIS_APP_ID', Env.aegisAppId).trim();
    if (raw.isEmpty) {
      _cachedAegisAppId = null;
      return null;
    }

    _cachedAegisAppId ??= int.tryParse(raw);
    return _cachedAegisAppId;
  }

  static String? get aegisAppHash {
    final value = _cachedAegisAppHash ??= _string(
      'AEGIS_APP_HASH',
      Env.aegisAppHash,
    ).trim();
    return value.isEmpty ? null : value;
  }

  static String get sentryDsn =>
      _cachedSentryDsn ??= _string('SENTRY_DSN', Env.sentryDsn);
  static String get appEnv => _cachedAppEnv ??= _string('APP_ENV', Env.appEnv);
  static bool get enableDevTools => _cachedEnableDevTools ??=
      _string('ENABLE_DEV_TOOLS', Env.enableDevTools) == 'true';

  static bool _looksLikeHandshakeSigningPublicKey(String value) {
    try {
      final decoded = base64Decode(value);
      return decoded.length == 65 && decoded.first == 0x04;
    } catch (_) {
      return false;
    }
  }

  static void printLoadedVariables() {
    if (!kDebugMode) return;
    print('===== Environment Variables =====');
    print('AEGIS_HOST: $aegisHost');
    print('AEGIS_PORT: $aegisPort');
    print(
      'AEGIS_TRANSPORT_MASKING_KEY: ${aegisTransportMaskingKey == null ? '(empty)' : '(set)'}',
    );
    print('AEGIS_USE_TLS: $aegisUseTls');
    print('AEGIS_APP_ID: ${aegisAppId ?? '(default)'}');
    print('AEGIS_APP_HASH: ${aegisAppHash == null ? '(default)' : '(set)'}');
    print('APP_ENV: $appEnv');
    print('ENABLE_DEV_TOOLS: $enableDevTools');
  }
}
