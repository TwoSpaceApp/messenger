// Compatibility layer for 64-bit integer operations in dart2js.
// 
// dart2js does not support Uint64/Int64 operations on ByteData (setUint64, getUint64).
// This extension provides compatible implementations using two Uint32 operations,
// since 64 bits = 2 × 32 bits (big-endian).

import 'dart:typed_data';

extension Uint64CompatByteData on ByteData {
  /// Set a 64-bit unsigned integer at [byteOffset] in big-endian format.
  /// 
  /// Replaces [setUint64] which is not supported in dart2js.
  /// Splits the value into two 32-bit parts.
  void setUint64Compat(int byteOffset, int value) {
    // Split 64-bit value into high and low 32-bit parts
    // value = (high << 32) | low
    final high = (value >> 32) & 0xFFFFFFFF;
    final low = value & 0xFFFFFFFF;
    
    // Write high part at offset, low part at offset + 4
    setUint32(byteOffset, high);
    setUint32(byteOffset + 4, low);
  }

  /// Get a 64-bit unsigned integer at [byteOffset] in big-endian format.
  /// 
  /// Replaces [getUint64] which is not supported in dart2js.
  /// Combines two 32-bit parts into a 64-bit value.
  int getUint64Compat(int byteOffset) {
    // Read high and low parts
    final high = getUint32(byteOffset);
    final low = getUint32(byteOffset + 4);
    
    // Combine: high becomes upper 32 bits, low becomes lower 32 bits
    // In Dart, integers are arbitrary precision, so this works fine
    return (high << 32) | low;
  }
}
