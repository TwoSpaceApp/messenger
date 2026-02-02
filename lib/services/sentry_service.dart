import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/environment.dart';

/// A centralized service for interacting with Sentry.
///
/// This service abstracts the Sentry SDK initialization, user context management,
/// and event capturing (exceptions, messages, breadcrumbs). It ensures that Sentry
/// is only active when a DSN is provided in the environment.
///
/// ## Usage
///
/// ```dart
/// // Initialize Sentry at app startup
/// await SentryService.initialize();
///
/// // Capture an exception
/// try {
///   // ... some operation that might fail
/// } catch (e, stackTrace) {
///   SentryService.captureException(e, stackTrace: stackTrace);
/// }
///
/// // Set user context
/// SentryService.setUser(userId: '@user:matrix.org', email: 'user@example.com');
class SentryService {
  static bool _initialized = false;

  /// Initialize the Sentry SDK.
  ///
  /// This method should be called once at application startup. It configures
  /// Sentry with the DSN from the environment and sets the release version.
  static Future<void> initialize() async {
    if (_initialized || Environment.sentryDsn.isEmpty) {
      return;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      await SentryFlutter.init(
        (options) {
          options.dsn = Environment.sentryDsn;
          options.tracesSampleRate = 1.0;
          options.release = '${packageInfo.version}+${packageInfo.buildNumber}';
          options.environment = Environment.appEnv;
          
          // Performance monitoring for slow and frozen frames
          options.autoAppStart = true;
          options.enableAutoPerformanceTracing = true;
        },
      );
      
      _initialized = true;
      
      if (kDebugMode) {
        print('Sentry initialized successfully.');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Failed to initialize Sentry: $e\n$stackTrace');
      }
    }
    
    _initialized = true;
  }

  /// Set the user context for Sentry.
  ///
  /// This information is associated with all subsequent events and helps
  /// in debugging and filtering.
  ///
  /// [userId] - A unique identifier for the user.
  /// [email] - The user's email address.
  /// [username] - The user's display name.
  /// [extras] - A map of additional custom data.
  static void setUser({
    String? userId,
    String? email,
    String? username,
    Map<String, dynamic>? extras,
  }) {
    if (!_initialized) return;

    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: userId,
        email: email,
        username: username,
        extras: extras,
      ));
    });
  }

  /// Clear the user context.
  ///
  /// This is typically called on logout.
  static void clearUser() {
    if (!_initialized) return;
    Sentry.configureScope((scope) => scope.setUser(null));
  }

  /// Capture an exception and send it to Sentry.
  ///
  /// [exception] - The error or exception object.
  /// [stackTrace] - The associated stack trace.
  /// [hint] - An optional hint, often used to provide context.
  static Future<void> captureException(
    dynamic exception, {
    StackTrace? stackTrace,
    dynamic hint,
  }) async {
    if (!_initialized) return;

    try {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        hint: hint,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Failed to capture exception in Sentry: $e');
      }
    }
  }

  /// Capture a message and send it to Sentry.
  ///
  /// [message] - The message to be sent.
  /// [level] - Severity level (info, warning, error, fatal)
  static Future<void> captureMessage(
    String message, {
    SentryLevel? level,
    Map<String, dynamic>? extra,
  }) async {
    if (!_initialized) return;

    try {
      await Sentry.captureMessage(
        message,
        level: level,
        withScope: (scope) {
          if (extra != null) {
            extra.forEach((key, value) => scope.setExtra(key, value));
          }
        },
      );
      
      if (kDebugMode) {
        print('Sentry message captured: $message');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to capture message in Sentry: $e');
      }
    }
  }

  /// Add a breadcrumb to the current scope.
  ///
  /// Breadcrumbs are a trail of events that happened prior to an issue.
  ///
  /// [message] - The breadcrumb message.
  /// [category] - A category for the breadcrumb (e.g., 'auth', 'ui.click').
  /// [data] - Additional data to associate with the breadcrumb.
  static void addBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
    SentryLevel? level,
  }) {
    if (!_initialized) return;

    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      category: category,
      data: data,
      level: level,
      timestamp: DateTime.now(),
    ));
  }

  static ISentrySpan? startTransaction(String name, String operation) {
    if (!_initialized) return null;
    return Sentry.startTransaction(name, operation);
  }
}
