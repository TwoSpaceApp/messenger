import 'dart:typed_data';

import 'package:es_compression/brotli.dart';

import 'package:two_space_app/core/network/aegis/logger.dart';

class AegisSafeBrotli {
  static BrotliCodec? _codec;
  static Object? _loadError;
  static bool _warned = false;

  static bool get isAvailable {
    if (_codec != null) {
      return true;
    }
    if (_loadError != null) {
      return false;
    }
    try {
      _codec = BrotliCodec();
      return true;
    } on Object catch (error) {
      _loadError = error;
      _warnUnavailable(error);
      return false;
    }
  }

  static Uint8List? tryEncode(List<int> input) {
    if (!isAvailable) {
      return null;
    }
    try {
      final encoded = _codec!.encode(input);
      return encoded is Uint8List ? encoded : Uint8List.fromList(encoded);
    } on Object catch (error) {
      _loadError = error;
      _codec = null;
      _warnUnavailable(error);
      return null;
    }
  }

  static Uint8List decode(List<int> input) {
    if (!isAvailable) {
      throw StateError('');
    }
    try {
      final decoded = _codec!.decode(input);
      return decoded is Uint8List ? decoded : Uint8List.fromList(decoded);
    } on Object catch (error) {
      _loadError = error;
      _codec = null;
      _warnUnavailable(error);
      rethrow;
    }
  }

  static void _warnUnavailable(Object error) {
    if (_warned) {
      return;
    }
    _warned = true;
    AegisLogger.warning(error.toString());
  }
}
