import 'dart:typed_data';

import 'package:two_space_app/core/network/aegis/transport.dart'
    show AegisTransport;

/// A growable ring buffer optimized for network I/O framing.
///
/// Supports efficient append-at-end and consume-from-front without
/// copying on every operation. The buffer compacts automatically when the
/// read head passes the midpoint, amortising copy cost to O(1) per byte.
///
/// Used by [AegisTransport] to accumulate TCP chunks and extract complete
/// protocol frames without per-chunk allocations.
class RingBuffer {

  /// Create a ring buffer with [initialCapacity] bytes.
  RingBuffer({int initialCapacity = 8192})
    : _buffer = Uint8List(initialCapacity);
  Uint8List _buffer;
  int _readPos = 0;
  int _writePos = 0;

  /// Number of readable (unconsumed) bytes.
  int get length => _writePos - _readPos;

  /// Total buffer capacity.
  int get capacity => _buffer.length;

  /// Whether the buffer contains no readable bytes.
  bool get isEmpty => _readPos == _writePos;

  /// Append [data] to the write end of the buffer.
  ///
  /// Grows the internal buffer if necessary.
  void write(Uint8List data) {
    if (data.isEmpty) return;
    _ensureCapacity(data.length);
    _buffer.setRange(_writePos, _writePos + data.length, data);
    _writePos += data.length;
  }

  /// Read a single byte at [offset] from the read position, without consuming.
  int peek(int offset) {
    if (offset < 0 || offset >= length) {
      throw RangeError('Offset $offset out of range [0, $length)');
    }
    return _buffer[_readPos + offset];
  }

  /// Get a zero-copy view of [count] bytes starting at [offset] from the
  /// read position.
  ///
  /// **Important**: The returned view shares memory with the internal buffer
  /// and is only valid until the next [write], [consume], [take], or [clear]
  /// call. Copy the data if you need it to persist.
  Uint8List peekBytes(int offset, int count) {
    if (offset < 0 || offset + count > length) {
      throw RangeError(
        'Range [$offset, ${offset + count}) out of bounds [0, $length)',
      );
    }
    return Uint8List.view(
      _buffer.buffer,
      _buffer.offsetInBytes + _readPos + offset,
      count,
    );
  }

  /// Consume (discard) [count] bytes from the front of the buffer.
  void consume(int count) {
    if (count < 0 || count > length) {
      throw RangeError('Cannot consume $count bytes, only $length available');
    }
    _readPos += count;
    _compactIfNeeded();
  }

  /// Copy [count] bytes from the front and consume them.
  ///
  /// Returns a freshly allocated [Uint8List] that is safe to retain.
  Uint8List take(int count) {
    if (count < 0 || count > length) {
      throw RangeError('Cannot take $count bytes, only $length available');
    }
    final data = Uint8List(count);
    data.setRange(0, count, _buffer, _readPos);
    _readPos += count;
    _compactIfNeeded();
    return data;
  }

  /// Discard all data and reset pointers.
  void clear() {
    _readPos = 0;
    _writePos = 0;
  }

  // ── Internal ────────────────────────────────────────────────────────

  void _ensureCapacity(int additional) {
    final required = _writePos + additional;
    if (required <= _buffer.length) return;

    // Try compacting first — may free enough head space
    if (_readPos > 0) {
      _compact();
      if (_writePos + additional <= _buffer.length) return;
    }

    // Grow: double capacity until it fits
    var newCapacity = _buffer.length;
    while (newCapacity < _writePos + additional) {
      newCapacity *= 2;
    }
    final newBuffer = Uint8List(newCapacity);
    final readable = length;
    if (readable > 0) {
      newBuffer.setRange(0, readable, _buffer, _readPos);
    }
    _writePos = readable;
    _readPos = 0;
    _buffer = newBuffer;
  }

  void _compactIfNeeded() {
    // Compact when read position passes half the buffer or all data consumed
    if (_readPos > _buffer.length ~/ 2 || (_readPos > 0 && isEmpty)) {
      _compact();
    }
  }

  void _compact() {
    if (_readPos == 0) return;
    final readable = length;
    if (readable > 0) {
      // Use buffer.setRange which handles overlapping copies correctly
      _buffer.setRange(0, readable, _buffer, _readPos);
    }
    _writePos = readable;
    _readPos = 0;
  }
}
