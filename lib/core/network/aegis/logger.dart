/// Simple logger for Aegis client
class AegisLogger {
  static bool _enabled = true;
  static LogLevel _level = LogLevel.info;

  /// Enable or disable logging
  static set enabled(bool value) => _enabled = value;

  /// Set minimum log level
  static set level(LogLevel value) => _level = value;

  /// Get current log level
  static LogLevel get level => _level;

  /// Log debug message
  static void debug(String message) {
    if (_enabled && _level.index <= LogLevel.debug.index) {
      print('[DEBUG] Aegis: $message');
    }
  }

  /// Log info message
  static void info(String message) {
    if (_enabled && _level.index <= LogLevel.info.index) {
      print('[INFO] Aegis: $message');
    }
  }

  /// Log warning message
  static void warning(String message) {
    if (_enabled && _level.index <= LogLevel.warning.index) {
      print('[WARNING] Aegis: $message');
    }
  }

  /// Log error message
  static void error(String message, [Object? error]) {
    if (_enabled && _level.index <= LogLevel.error.index) {
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
