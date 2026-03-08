import 'dart:async';

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
  static final List<String> _logs = [];
  static final StreamController<List<String>> _ctrl = StreamController.broadcast();
  final String _tag;

  DevLogger(this._tag);

  /// Логировать сообщение с определённым уровнем
  static void _log(String msg, LogLevel level) {
    final timestamp = DateTime.now().toIso8601String();
    final line = '[$timestamp] ${level.emoji} $msg';
    _logs.add(line);
    // Сохраняем последние 200 записей
    if (_logs.length > 200) _logs.removeRange(0, _logs.length - 200);
    try {
      _ctrl.add(List<String>.from(_logs));
    } catch (_) {}
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
    try {
      _ctrl.add(List<String>.from(_logs));
    } catch (_) {}
  }

}

