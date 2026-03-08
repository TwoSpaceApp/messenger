import 'package:flutter/foundation.dart';
import 'package:two_space_app/core/config/env.dart';

class Environment {
  Environment._();

  static Future<void> load() async {
    // No-op for Envied
  }

  static bool get useMatrix => Env.matrixEnable == 'true';
  static String get matrixHomeserverUrl => Env.matrixHomeserverUrl;
  static String get matrixServerName => Env.matrixServerName;
  static String get matrixAccessToken => Env.matrixAccessToken;
  static String get matrixHomeserver => Env.matrixHomeserverUrl;
  static String get matrixEmailTokenEndpoint => '';
  static String get matrixTotpSetupEndpoint => '';
  static String get matrixTotpVerifyEndpoint => '';
  static String get matrixStorageMediaBucketId => '';

  static String get aegisHost => Env.aegisHost;
  static int get aegisPort => int.tryParse(Env.aegisPort) ?? 8888;
  static Duration get aegisConnectTimeout =>
      Duration(seconds: int.tryParse(Env.aegisConnectTimeoutSeconds) ?? 10);

  static String get appwriteProjectId => '';
  static String get appwriteDatabaseId => '';
  static String get appwriteCollectionsSegment => '';
  static String get appwriteDocumentsSegment => '';
  static String get appwriteMessagesCollectionId => '';

  static String get sentryDsn => Env.sentryDsn;
  static String get appEnv => Env.appEnv;
  static bool get enableDevTools => Env.enableDevTools == 'true';

  static void printLoadedVariables() {
    if (!kDebugMode) return;
    print('===== Environment Variables =====');
    print('USE_MATRIX: $useMatrix');
  }
}
