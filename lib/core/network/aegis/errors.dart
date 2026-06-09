import 'dart:typed_data';

/// Base class for all Aegis protocol errors.
///
/// Both [ProtocolDecodeError] and [ProtocolEncodeError] extend this type,
/// so existing `catch (ProtocolError)` blocks continue to work.
///
/// See: src/Aegis.Protocol/MessageEncoder.cs — server-side error paths.
class ProtocolError implements Exception {

  ProtocolError(this.message, [this.frameData]);
  /// Human-readable description of the error.
  final String message;

  /// Raw frame bytes that caused the error, if available.
  ///
  /// Used by [hexDump] to produce a diagnostic hex dump.
  final Uint8List? frameData;

  /// Hex dump of [frameData] for diagnostic logging.
  ///
  /// Displays up to maxBytes bytes in a traditional hex-dump layout
  /// with offsets and hex values.
  String get hexDump =>
      frameData != null ? _toHexDump(frameData!) : '<no frame data>';

  @override
  String toString() => 'ProtocolError: $message';

  /// Produce a multi-line hex dump of [data].
  static String _toHexDump(Uint8List data, {int maxBytes = 128}) {
    final sb = StringBuffer();
    final limit = data.length > maxBytes ? maxBytes : data.length;
    for (var i = 0; i < limit; i += 16) {
      sb.write('  ${i.toRadixString(16).padLeft(4, '0')}  ');
      final end = (i + 16 < limit) ? i + 16 : limit;
      for (var j = i; j < end; j++) {
        sb.write('${data[j].toRadixString(16).padLeft(2, '0')} ');
      }
      sb.writeln();
    }
    if (data.length > maxBytes) {
      sb.writeln('  ... (${data.length - maxBytes} more bytes)');
    }
    return sb.toString();
  }
}

/// Thrown when decoding a frame fails due to invalid or malformed data.
///
/// Includes a hex dump of the problematic frame for diagnostics.
class ProtocolDecodeError extends ProtocolError {
  ProtocolDecodeError(super.message, [super.frameData]);

  @override
  String toString() {
    final dump = frameData != null ? '\n$hexDump' : '';
    return 'ProtocolDecodeError: $message$dump';
  }
}

/// Thrown when encoding a message fails due to invalid parameters.
class ProtocolEncodeError extends ProtocolError {
  ProtocolEncodeError(super.message, [super.frameData]);

  @override
  String toString() => 'ProtocolEncodeError: $message';
}
