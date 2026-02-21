import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dotenv_filesystem_loader.dart';

/// Environment configuration manager
///
/// Provides strongly-typed access to environment variables from a `.env` file.
/// This class ensures that all required variables are available and provides
/// sensible fallbacks where appropriate.
///
/// Example `.env` file:
/// ```
/// # Appwrite
/// APPWRITE_ENDPOINT='https://yourendpoint.io/v1'
/// APPWRITE_PROJECT_ID='your_project_id'
///
/// # Matrix
/// USE_MATRIX='true'
/// MATRIX_HOMESERVER='https://matrix.org'
///
/// # Sentry
/// SENTRY_DSN='your_sentry_dsn'
///
/// # Dev tools
/// ENABLE_DEV_TOOLS='true'
/// ```
class Environment {
  Environment._();

  static Future<void> load() async {
    // Load defaults from bundled .env.example first.
    // Then try optional .env (asset) and optional .env from filesystem (desktop).
    try {
      await dotenv.load(
        fileName: '.env.example',
        isOptional: true,
        mergeWith: const {},
      );
    } catch (_) {
      // Best-effort: app should still start.
    }

    // Optional bundled .env (some local setups may include it as an asset).
    try {
      final current = Map<String, String>.from(dotenv.env);
      await dotenv.load(
        fileName: '.env',
        isOptional: true,
        mergeWith: current,
      );
    } catch (_) {
      // Best-effort.
    }

    // Optional filesystem .env for desktop/dev (overrides asset values).
    try {
      final fileInput = await readDotenvFromFilesystem();
      if (fileInput != null && fileInput.trim().isNotEmpty) {
        dotenv.env.addAll(_parseDotenv(fileInput));
      }
    } catch (_) {
      // Best-effort.
    }
  }

  static Map<String, String> _parseDotenv(String content) {
    final out = <String, String>{};
    final lines = content.split(RegExp(r'\r?\n'));
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('#')) continue;

      final idx = line.indexOf('=');
      if (idx <= 0) continue;
      final key = line.substring(0, idx).trim();
      var value = line.substring(idx + 1).trim();

      if (value.length >= 2) {
        final q = value[0];
        if ((q == '"' || q == "'") && value.endsWith(q)) {
          value = value.substring(1, value.length - 1);
        }
      }

      if (key.isNotEmpty) out[key] = value;
    }
    return out;
  }

  static String _get(String name, {String fallback = ''}) {
    return dotenv.env[name] ?? fallback;
  }

  static String _getFirst(List<String> names, {String fallback = ''}) {
    for (final name in names) {
      final v = dotenv.env[name];
      if (v != null && v.isNotEmpty) return v;
    }
    return fallback;
  }

  /// Matrix configuration
  static bool get useMatrix =>
      _getFirst(['MATRIX_ENABLE', 'USE_MATRIX'], fallback: 'true') == 'true';

  static String get matrixHomeserver => _getFirst(
        ['MATRIX_HOMESERVER', 'MATRIX_SERVER_URL', 'MATRIX_HOMESERVER_URL'],
        fallback: 'https://matrix.org',
      );

  static String get matrixHomeserverUrl => _getFirst(
        ['MATRIX_HOMESERVER_URL', 'MATRIX_SERVER_URL', 'MATRIX_HOMESERVER'],
        fallback: 'https://matrix.org',
      );

  static String get matrixServerName => _get('MATRIX_SERVER_NAME');
  static String get matrixEmailTokenEndpoint => _get('MATRIX_EMAIL_TOKEN_ENDPOINT');
  static String get matrixAccessToken => _get('MATRIX_ACCESS_TOKEN');
  static String get matrixTotpSetupEndpoint => _get('MATRIX_TOTP_SETUP_ENDPOINT');
  static String get matrixTotpVerifyEndpoint => _get('MATRIX_TOTP_VERIFY_ENDPOINT');
  static String get matrixStorageMediaBucketId => _get('MATRIX_STORAGE_MEDIA_BUCKET_ID');

  /// Appwrite configuration (legacy/backup)
  static String get appwriteProjectId => _get('APPWRITE_PROJECT_ID');
  static String get appwriteDatabaseId => _get('APPWRITE_DATABASE_ID');
  static String get appwriteCollectionsSegment => _get('APPWRITE_COLLECTIONS_SEGMENT');
  static String get appwriteDocumentsSegment => _get('APPWRITE_DOCUMENTS_SEGMENT');
  static String get appwriteMessagesCollectionId => _get('APPWRITE_MESSAGES_COLLECTION_ID');

  /// Sentry configuration
  static String get sentryDsn => _get('SENTRY_DSN');

  /// Environment
  static String get appEnv => _get('APP_ENV', fallback: 'development');

  /// Feature flags
  static bool get enableDevTools => _get('ENABLE_DEV_TOOLS', fallback: 'false') == 'true';

  /// Print all loaded environment variables for debugging
  static void printLoadedVariables() {
    if (!kDebugMode) return;
    
    print('===== Environment Variables =====');
    print('USE_MATRIX: $useMatrix');
    print('MATRIX_HOMESERVER: $matrixHomeserver');
    print('MATRIX_SERVER_URL: $matrixHomeserverUrl');
    print('APP_ENV: $appEnv');
    print('SENTRY_DSN: ${sentryDsn.isEmpty ? "(not set)" : "(configured)"}');
    print('ENABLE_DEV_TOOLS: $enableDevTools');
    print('===============================');
  }
}
