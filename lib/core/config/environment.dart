import 'package:flutter/foundation.dart';
import 'package:two_space_app/core/config/env.dart';

class Environment {
  Environment._();

  static Future<void> load() async {
    // No-op for Envied
  }

  static String get aegisHost => Env.aegisHost;
  static int get aegisPort => int.tryParse(Env.aegisPort) ?? 8888;
  static Duration get aegisConnectTimeout =>
      Duration(seconds: int.tryParse(Env.aegisConnectTimeoutSeconds) ?? 10);
  static String? get aegisTransportMaskingKey {
    final value = Env.aegisTransportMaskingKey.trim();
    return value.isEmpty ? null : value;
  }

  static String get sentryDsn => Env.sentryDsn;
  static String get appEnv => Env.appEnv;
  static bool get enableDevTools => Env.enableDevTools == 'true';

  static void printLoadedVariables() {
    if (!kDebugMode) return;
    print('===== Environment Variables =====');
    print('AEGIS_HOST: $aegisHost');
    print('AEGIS_PORT: $aegisPort');
    print('AEGIS_TRANSPORT_MASKING_KEY: ${aegisTransportMaskingKey == null ? '(empty)' : '(set)'}');
    print('APP_ENV: $appEnv');
    print('ENABLE_DEV_TOOLS: $enableDevTools');
  }
}
