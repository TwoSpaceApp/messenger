import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    await dotenv.load();
  }

  static String _get(String name, {String fallback = ''}) {
    return dotenv.env[name] ?? fallback;
  }

  /// Matrix configuration
  static bool get useMatrix => _get('USE_MATRIX', fallback: 'true') == 'true';
  static String get matrixHomeserver => _get('MATRIX_HOMESERVER', fallback: 'https://matrix.org');
  static String get matrixHomeserverUrl => _get('MATRIX_SERVER_URL', fallback: _get('MATRIX_HOMESERVER', fallback: 'https://matrix.org'));
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
