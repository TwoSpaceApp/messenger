import 'dart:typed_data';

class ProtocolError implements Exception {
  ProtocolError(this.message, [this.frameData]);

  final String message;
  final Uint8List? frameData;

  @override
  String toString() => 'ProtocolError: $message';
}

class ProtocolDecodeError extends ProtocolError {
  ProtocolDecodeError(super.message, [super.frameData]);
}

class ProtocolEncodeError extends ProtocolError {
  ProtocolEncodeError(super.message, [super.frameData]);
}
