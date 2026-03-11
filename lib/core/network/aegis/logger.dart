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

  /// Log debug message
  static void debug(String message) {
    if (_enabled && _level.index <= LogLevel.debug.index) {
      _devLogger.debug(message);
      print('[DEBUG] Aegis: $message');
    }
  }

  /// Log info message
  static void info(String message) {
    if (_enabled && _level.index <= LogLevel.info.index) {
      _devLogger.info(message);
      print('[INFO] Aegis: $message');
    }
  }

  /// Log warning message
  static void warning(String message) {
    if (_enabled && _level.index <= LogLevel.warning.index) {
      _devLogger.warning(message);
      print('[WARNING] Aegis: $message');
    }
  }

  /// Log error message
  static void error(String message, [Object? error]) {
    if (_enabled && _level.index <= LogLevel.error.index) {
      _devLogger.error(error == null ? message : '$message: $error');
      print('[ERROR] Aegis: $message');
      if (error != null) {
        print('[ERROR] Aegis: $error');
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
