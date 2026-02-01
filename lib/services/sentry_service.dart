import 'package:flutter/foundation.dart';

/// Stub Sentry service when sentry_flutter is disabled
/// 
/// This is a no-op implementation used when sentry_flutter is not available
class SentryService {
  static bool _initialized = false;

  /// Initialize Sentry (no-op)
  static Future<void> init() async {
    if (_initialized) return;
    
    if (kDebugMode) {
      debugPrint('⚠️ Sentry disabled - using stub implementation');
    }
    
    _initialized = true;
  }

  /// Capture an exception (no-op)
  static Future<void> captureException(
    dynamic exception, {
    StackTrace? stackTrace,
    dynamic hint,
  }) async {
    if (kDebugMode) {
      debugPrint('Exception: $exception');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Capture a message (no-op)
  static Future<void> captureMessage(
    String message, {
    dynamic level,
    Map<String, dynamic>? extra,
  }) async {
    if (kDebugMode) {
      debugPrint('Message: $message');
    }
  }

  /// Add breadcrumb (no-op)
  static void addBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
    dynamic level,
  }) {
    if (kDebugMode) {
      debugPrint('Breadcrumb: $message');
    }
  }

  /// Set user context (no-op)
  static Future<void> setUser({
    String? userId,
    String? email,
    String? username,
    Map<String, dynamic>? extras,
  }) async {
    // No-op
  }

  /// Clear user context (no-op)
  static Future<void> clearUser() async {
    // No-op
  }

  /// Set custom tag (no-op)
  static Future<void> setTag(String key, String value) async {
    // No-op
  }

  /// Set custom context (no-op)
  static Future<void> setContext(String key, Map<String, dynamic> context) async {
    // No-op
  }

  /// Start transaction (returns null)
  static dynamic startTransaction(
    String operation, {
    String? description,
  }) {
    return null;
  }
}
