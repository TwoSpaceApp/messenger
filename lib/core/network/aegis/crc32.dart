import 'dart:typed_data';

/// IEEE 802.3 CRC-32 implementation for lightweight header integrity checks.
///
/// This is an optional validation layer — the Aegis wire format does not
/// include a CRC field. Use [compute] to calculate a checksum over header
/// bytes for local integrity verification.
///
/// The lookup table is generated lazily on first use to avoid startup cost.
class Crc32 {
  static final Uint32List _table = _generateTable();

  /// Compute CRC-32 over [data] from [offset] to [offset + length].
  ///
  /// ```dart
  /// final crc = Crc32.compute(frameBytes, 0, ProtocolConstants.headerSize);
  /// ```
  static int compute(Uint8List data, [int offset = 0, int? length]) {
    final end = offset + (length ?? data.length - offset);
    if (offset < 0 || end > data.length) {
      throw RangeError(
        'Range [$offset, $end) out of bounds [0, ${data.length})',
      );
    }

    var crc = 0xFFFFFFFF;
    for (var i = offset; i < end; i++) {
      final index = (crc ^ data[i]) & 0xFF;
      crc = _table[index] ^ (crc >>> 8);
    }
    return crc ^ 0xFFFFFFFF;
  }

  /// Generate the standard IEEE CRC-32 lookup table (polynomial 0xEDB88320).
  static Uint32List _generateTable() {
    const polynomial = 0xEDB88320;
    final table = Uint32List(256);
    for (var i = 0; i < 256; i++) {
      var crc = i;
      for (var j = 0; j < 8; j++) {
        if ((crc & 1) != 0) {
          crc = (crc >>> 1) ^ polynomial;
        } else {
          crc = crc >>> 1;
        }
      }
      table[i] = crc;
    }
    return table;
  }
}
