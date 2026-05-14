import 'dart:typed_data';

/// A simple buffer pool that recycles [Uint8List] allocations to reduce
/// GC pressure during high-throughput encode/decode operations.
///
/// Buffers returned via [release] are zeroed before being added to the pool
/// (defense-in-depth against leaking sensitive payload data).
///
/// Usage:
/// ```dart
/// final pool = BufferPool();
/// final buf = pool.acquire(256);
/// // ... use buf ...
/// pool.release(buf);
/// ```
class BufferPool {

  /// Create a pool that retains at most [maxPoolSize] buffers.
  BufferPool({int maxPoolSize = 32}) : _maxPoolSize = maxPoolSize;
  final int _maxPoolSize;
  final List<Uint8List> _pool = [];

  /// Acquire a buffer of at least [minSize] bytes.
  ///
  /// Returns a pooled buffer if one of sufficient size is available,
  /// otherwise allocates a new buffer rounded up to the next power of 2.
  Uint8List acquire(int minSize) {
    // Search for the smallest buffer that fits
    var bestIdx = -1;
    var bestLen = 0x7FFFFFFF; // max int
    for (var i = _pool.length - 1; i >= 0; i--) {
      final len = _pool[i].length;
      if (len >= minSize && len < bestLen) {
        bestIdx = i;
        bestLen = len;
      }
    }
    if (bestIdx >= 0) {
      return _pool.removeAt(bestIdx);
    }

    // Allocate new buffer, rounded up to next power of 2 for better reuse
    final size = minSize > 0 ? _nextPowerOf2(minSize) : minSize;
    return Uint8List(size);
  }

  /// Release a buffer back to the pool.
  ///
  /// The buffer is zeroed before pooling for security.
  /// If the pool is full, the buffer is discarded (and will be GC'd).
  void release(Uint8List buffer) {
    if (_pool.length < _maxPoolSize) {
      buffer.fillRange(0, buffer.length, 0);
      _pool.add(buffer);
    }
  }

  /// Clear all pooled buffers, zeroing each before discard.
  void clear() {
    for (final buf in _pool) {
      buf.fillRange(0, buf.length, 0);
    }
    _pool.clear();
  }

  /// Number of buffers currently in the pool.
  int get pooledCount => _pool.length;

  static int _nextPowerOf2(int v) {
    v--;
    v |= v >> 1;
    v |= v >> 2;
    v |= v >> 4;
    v |= v >> 8;
    v |= v >> 16;
    v++;
    return v;
  }
}
