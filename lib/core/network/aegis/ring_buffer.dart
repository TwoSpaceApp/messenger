import 'dart:typed_data';

class RingBuffer {
  Uint8List _buffer;
  int _readPos = 0;
  int _writePos = 0;

  RingBuffer({int initialCapacity = 8192})
      : _buffer = Uint8List(initialCapacity);

  int get length => _writePos - _readPos;
  bool get isEmpty => _readPos == _writePos;

  void write(Uint8List data) {
    if (data.isEmpty) return;
    _ensureCapacity(data.length);
    _buffer.setRange(_writePos, _writePos + data.length, data);
    _writePos += data.length;
  }

  Uint8List peekBytes(int offset, int count) {
    if (offset < 0 || offset + count > length) {
      throw RangeError('Range [$offset, ${offset + count}) out of bounds [0, $length)');
    }
    return Uint8List.view(
      _buffer.buffer,
      _buffer.offsetInBytes + _readPos + offset,
      count,
    );
  }

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

  void clear() {
    _readPos = 0;
    _writePos = 0;
  }

  void _ensureCapacity(int additional) {
    final required = _writePos + additional;
    if (required <= _buffer.length) {
      return;
    }
    if (_readPos > 0) {
      _compact();
      if (_writePos + additional <= _buffer.length) {
        return;
      }
    }
    var newCapacity = _buffer.length;
    while (newCapacity < _writePos + additional) {
      newCapacity *= 2;
    }
    final next = Uint8List(newCapacity);
    final readable = length;
    if (readable > 0) {
      next.setRange(0, readable, _buffer, _readPos);
    }
    _buffer = next;
    _readPos = 0;
    _writePos = readable;
  }

  void _compactIfNeeded() {
    if (_readPos > _buffer.length ~/ 2 || (_readPos > 0 && isEmpty)) {
      _compact();
    }
  }

  void _compact() {
    if (_readPos == 0) {
      return;
    }
    final readable = length;
    if (readable > 0) {
      _buffer.setRange(0, readable, _buffer, _readPos);
    }
    _readPos = 0;
    _writePos = readable;
  }
}
