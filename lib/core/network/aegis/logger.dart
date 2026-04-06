import 'dart:convert';
import 'dart:typed_data';

import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/services/dev_sensitive_data_policy.dart';
import 'package:two_space_app/core/services/dev_logger.dart' as dev;

/// Simple logger for Aegis client
class AegisLogger {
  static bool _enabled = true;
  static LogLevel _level = LogLevel.debug;
  static final dev.DevLogger _devLogger = dev.DevLogger('Aegis');

  /// Enable or disable logging
  static set enabled(bool value) => _enabled = value;

  /// Set minimum log level
  static set level(LogLevel value) => _level = value;

  /// Get current log level
  static LogLevel get level => _level;

  /// Log debug message
  static void debug(String message) {
    _emit(LogLevel.debug, message);
  }

  /// Log info message
  static void info(String message) {
    _emit(LogLevel.info, message);
  }

  /// Log warning message
  static void warning(String message) {
    _emit(LogLevel.warning, message);
  }

  /// Log error message
  static void error(String message, [Object? error]) {
    _emit(LogLevel.error, message, error);
  }

  static void traceFrame(
    String stage,
    Message message, {
    required String direction,
    Object? payload,
    Object? error,
  }) {
    final summary = describeMessage(
      message,
      stage: stage,
      direction: direction,
      payload: payload,
    );
    final encoded = jsonEncode(summary);
    if (error != null) {
      debug('$encoded error=$error');
      return;
    }
    debug(encoded);
  }

  static Map<String, dynamic> describeMessage(
    Message message, {
    String? stage,
    String? direction,
    Object? payload,
  }) {
    return <String, dynamic>{
      ...?(stage == null ? null : <String, dynamic>{'stage': stage}),
      ...?(direction == null
          ? null
          : <String, dynamic>{'direction': direction}),
      'type': message.type.name,
      'sequenceId': message.sequenceId,
      'flagsHex': '0x${message.flags.toRadixString(16)}',
      'payloadLength': message.payloadLength,
      'payload': _safePayloadPreview(payload ?? message.payload),
    };
  }

  static Object? decodePayload(List<int> payload, {int maxBytes = 16384}) {
    if (payload.isEmpty) {
      return null;
    }

    if (payload.length > maxBytes) {
      return <String, dynamic>{
        'truncated': true,
        'bytes': payload.length,
        'preview': _safePayloadPreview(payload.sublist(0, maxBytes)),
      };
    }

    return _safePayloadPreview(payload);
  }

  static void _emit(LogLevel level, String message, [Object? error]) {
    if (!_enabled || _level.index > level.index) {
      return;
    }

    final label = level.name.toUpperCase();
    final safeMessage = DebugDataSanitizer.sanitizeText(message);
    print('[$label] Aegis: $safeMessage');

    switch (level) {
      case LogLevel.debug:
        _devLogger.debug(safeMessage);
      case LogLevel.info:
        _devLogger.info(safeMessage);
      case LogLevel.warning:
        _devLogger.warning(safeMessage);
      case LogLevel.error:
        _devLogger.error(safeMessage);
    }

    if (error != null) {
      final safeError = DebugDataSanitizer.sanitizeText(error.toString());
      print('[ERROR] Aegis: $safeError');
      _devLogger.error(safeError);
    }
  }

  static Object? _safePayloadPreview(Object? payload) {
    if (payload == null) {
      return null;
    }
    if (payload is! List<int>) {
      return payload;
    }
    if (payload.isEmpty) {
      return null;
    }

    final bytes = payload is Uint8List ? payload : Uint8List.fromList(payload);
    try {
      final firstByte = bytes.first;
      if (firstByte == 0x7b || firstByte == 0x5b) {
        return jsonDecode(utf8.decode(bytes));
      }

      final decoded = msgpack.deserialize(bytes);
      return _normalize(decoded);
    } on Object catch (_) {
      return <String, dynamic>{
        'binary': true,
        'bytes': bytes.length,
        'base64': base64Encode(bytes),
      };
    }
  }

  static Object? _normalize(Object? value) {
    if (value is Map) {
      return value.map<String, Object?>((key, item) {
        return MapEntry(key.toString(), _normalize(item));
      });
    }
    if (value is List) {
      return value.map(_normalize).toList(growable: false);
    }
    return value;
  }
}

/// Log levels
enum LogLevel {
  debug,
  info,
  warning,
  error,
}
