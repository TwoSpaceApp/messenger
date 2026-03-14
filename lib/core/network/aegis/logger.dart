import 'package:flutter/foundation.dart';
import 'package:two_space_app/core/services/dev_logger.dart';

/// Simple logger for Aegis client
class AegisLogger {
  static bool _enabled = true;
  static LogLevel _level = LogLevel.info;
  static final DevLogger _devLogger = DevLogger('Aegis');

  /// Enable or disable logging
  static set enabled(bool value) => _enabled = value;

  /// Set minimum log level
  static set level(LogLevel value) => _level = value;

  static void _debugPrintIfNeeded(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }

  /// Log debug message
  static void debug(String message) {
    if (_enabled && _level.index <= LogLevel.debug.index) {
      _devLogger.debug(message);
      _debugPrintIfNeeded('[DEBUG] Aegis: $message');
    }
  }

  /// Log info message
  static void info(String message) {
    if (_enabled && _level.index <= LogLevel.info.index) {
      _devLogger.info(message);
      _debugPrintIfNeeded('[INFO] Aegis: $message');
    }
  }

  /// Log warning message
  static void warning(String message) {
    if (_enabled && _level.index <= LogLevel.warning.index) {
      _devLogger.warning(message);
      _debugPrintIfNeeded('[WARNING] Aegis: $message');
    }
  }

  /// Log error message
  static void error(String message, [Object? error]) {
    if (_enabled && _level.index <= LogLevel.error.index) {
      _devLogger.error(error == null ? message : '$message: $error');
      _debugPrintIfNeeded('[ERROR] Aegis: $message');
      if (error != null) {
        _debugPrintIfNeeded('[ERROR] Aegis: $error');
      }
    }
  }
}

/// Log levels
enum LogLevel {
  debug,
  info,
  warning,
  error,
}
