import 'dart:async';

import 'package:two_space_app/core/services/dev_sensitive_data_policy.dart';

/// Уровни логирования
enum LogLevel {
  debug('🔵'),
  info('ℹ️'),
  warning('⚠️'),
  error('🔴');

  final String emoji;
  const LogLevel(this.emoji);
}

/// Журнал для разработчиков с поддержкой уровней логирования
class DevLogger {
  static const int _maxEntries = 400;
  static const int _maxLineLength = 12000;
  DevLogger(this._tag);
  static final List<String> _logs = [];
  static final StreamController<List<String>> _ctrl =
      StreamController.broadcast();
  final String _tag;

  /// Логировать сообщение с определённым уровнем
  static void _log(String msg, LogLevel level) {
    final timestamp = DateTime.now().toIso8601String();
    final safeMessage = DebugDataSanitizer.sanitizeText(msg);
    final truncatedMessage = safeMessage.length <= _maxLineLength
        ? safeMessage
        : '${safeMessage.substring(0, _maxLineLength)}… [truncated ${safeMessage.length - _maxLineLength} chars]';
    final line = '[$timestamp] ${level.emoji} $truncatedMessage';
    _logs.add(line);
    if (_logs.length > _maxEntries) {
      _logs.removeRange(0, _logs.length - _maxEntries);
    }
    if (_ctrl.hasListener) {
      _ctrl.add(DevLogger.all);
    }
  }

  /// Логировать отладочное сообщение
  void debug(String msg) => _log('[$_tag] $msg', LogLevel.debug);

  /// Логировать информационное сообщение
  void info(String msg) => _log('[$_tag] $msg', LogLevel.info);

  /// Логировать предупреждение
  void warning(String msg) => _log('[$_tag] $msg', LogLevel.warning);

  /// Логировать ошибку
  void error(String msg) => _log('[$_tag] $msg', LogLevel.error);

  /// Логировать исключение
  void exception(String msg, Object exception, StackTrace? stackTrace) {
    error('$msg: $exception');
    if (stackTrace != null) {
      error('StackTrace: $stackTrace');
    }
  }

  /// Получить поток логов
  static Stream<List<String>> get stream => _ctrl.stream;

  /// Получить все логи в обратном порядке
  static List<String> get all => List<String>.from(_logs.reversed);

  /// Очистить логи
  static void clear() {
    _logs.clear();
    if (_ctrl.hasListener) {
      _ctrl.add(DevLogger.all);
    }
  }
}
