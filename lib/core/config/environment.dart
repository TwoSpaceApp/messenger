import 'package:flutter/foundation.dart';
import 'package:two_space_app/core/config/env.dart';

class Environment {
  Environment._();

  static String? _cachedAegisHost;
  static int? _cachedAegisPort;
  static Duration? _cachedAegisConnectTimeout;
  static String? _cachedAegisTransportMaskingKey;
  static bool? _cachedAegisUseTls;
  static String? _cachedSentryDsn;
  static String? _cachedAppEnv;
  static bool? _cachedEnableDevTools;

  static Future<void> load() async {
    // No-op for Envied
  }

  static String get aegisHost => _cachedAegisHost ??= Env.aegisHost;
  static int get aegisPort =>
      _cachedAegisPort ??= int.tryParse(Env.aegisPort) ?? 8888;
  static Duration get aegisConnectTimeout =>
      _cachedAegisConnectTimeout ??=
          Duration(seconds: int.tryParse(Env.aegisConnectTimeoutSeconds) ?? 10);
  static String? get aegisTransportMaskingKey {
    final value = _cachedAegisTransportMaskingKey ??=
        Env.aegisTransportMaskingKey.trim();
    return value.isEmpty ? null : value;
  }
  static bool get aegisUseTls =>
      _cachedAegisUseTls ??= Env.aegisUseTls == 'true';

  static String get sentryDsn => _cachedSentryDsn ??= Env.sentryDsn;
  static String get appEnv => _cachedAppEnv ??= Env.appEnv;
  static bool get enableDevTools =>
      _cachedEnableDevTools ??= Env.enableDevTools == 'true';

  static void printLoadedVariables() {
    if (!kDebugMode) return;
    print('===== Environment Variables =====');
    print('AEGIS_HOST: $aegisHost');
    print('AEGIS_PORT: $aegisPort');
    print('AEGIS_TRANSPORT_MASKING_KEY: ${aegisTransportMaskingKey == null ? '(empty)' : '(set)'}');
    print('AEGIS_USE_TLS: $aegisUseTls');
    print('APP_ENV: $appEnv');
    print('ENABLE_DEV_TOOLS: $enableDevTools');
  }
}
