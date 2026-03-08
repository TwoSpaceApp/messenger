import 'dart:typed_data';

import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';
import 'package:two_space_app/core/network/aegis/protocol_constants.dart';

/// Exception thrown for protocol-related errors
class ProtocolError implements Exception {
  ProtocolError(this.message);
  final String message;

  @override
  String toString() => 'ProtocolError: $message';
}

/// Encoder/Decoder for Aegis protocol messages
class MessageEncoder {
  /// Encode a message to byte buffer
  static Uint8List encode(Message message) {
    if (!message.isValid) {
      throw ProtocolError('Invalid message structure');
    }

    final buffer = Uint8List(message.totalSize);
    var offset = 0;

    // Write magic (4 bytes, big-endian)
    _writeUint32BigEndian(buffer, offset, message.magic);
    offset += 4;

    // Write version and flags
    buffer[offset++] = message.versionMajor;
    buffer[offset++] = message.versionMinor;
    buffer[offset++] = message.flags;

    // Write message type (2 bytes, big-endian)
    _writeUint16BigEndian(buffer, offset, message.type.value);
    offset += 2;

    // Write sequence ID (8 bytes, big-endian)
    _writeUint64BigEndian(buffer, offset, message.sequenceId);
    offset += 8;

    // Write payload length (4 bytes, big-endian)
    _writeUint32BigEndian(buffer, offset, message.payloadLength);
    offset += 4;

    // Write payload if present
    if (message.payloadLength > 0) {
      buffer.setRange(offset, offset + message.payloadLength, message.payload);
      offset += message.payloadLength;
    }

    // Write MAC (32 bytes)
    buffer.setRange(offset, offset + ProtocolConstants.macSize, message.mac);

    return buffer;
  }

  /// Decode a message from byte buffer
  static Message decode(Uint8List data) {
    if (data.length < ProtocolConstants.headerSize) {
      throw ProtocolError('Message too short: ${data.length}');
    }

    var offset = 0;
    final message = Message();

    // Read magic (4 bytes, big-endian)
    message.magic = _readUint32BigEndian(data, offset);
    offset += 4;

    if (message.magic != ProtocolConstants.magic) {
      throw ProtocolError(
          'Invalid magic: 0x${message.magic.toRadixString(16)}');
    }

    // Read version and flags
    message.versionMajor = data[offset++];
    message.versionMinor = data[offset++];
    message.flags = data[offset++];

    // Read message type (2 bytes, big-endian)
    final typeValue = _readUint16BigEndian(data, offset);
    message.type = MessageType.fromValue(typeValue);
    offset += 2;

    // Read sequence ID (8 bytes, big-endian)
    message.sequenceId = _readUint64BigEndian(data, offset);
    offset += 8;

    // Read payload length (4 bytes, big-endian)
    message.payloadLength = _readUint32BigEndian(data, offset);
    offset += 4;

    if (message.payloadLength > ProtocolConstants.maxPayloadSize) {
      throw ProtocolError('Payload too large: ${message.payloadLength}');
    }

    final expectedSize = ProtocolConstants.headerSize +
        message.payloadLength +
        ProtocolConstants.macSize;

    if (data.length < expectedSize) {
      throw ProtocolError(
          'Incomplete message: expected $expectedSize, got ${data.length}');
    }

    // Read payload if present
    if (message.payloadLength > 0) {
      message.payload = data.sublist(offset, offset + message.payloadLength);
      offset += message.payloadLength;
    }

    // Read MAC (32 bytes).
    // TODO(security): MAC читается, но не верифицируется на клиенте.
    //   Для проверки HMAC-SHA256 требуется общий секретный ключ, который
    //   устанавливается в процессе handshake (будущая реализация X3DH).
    //   До реализации E2E-шифрования клиент доверяет интегритету сервера.
    message.mac = data.sublist(offset, offset + ProtocolConstants.macSize);

    return message;
  }

  // Helper methods for big-endian operations
  static void _writeUint32BigEndian(Uint8List buffer, int offset, int value) {
    buffer[offset] = (value >> 24) & 0xFF;
    buffer[offset + 1] = (value >> 16) & 0xFF;
    buffer[offset + 2] = (value >> 8) & 0xFF;
    buffer[offset + 3] = value & 0xFF;
  }

  static void _writeUint16BigEndian(Uint8List buffer, int offset, int value) {
    buffer[offset] = (value >> 8) & 0xFF;
    buffer[offset + 1] = value & 0xFF;
  }

  static void _writeUint64BigEndian(Uint8List buffer, int offset, int value) {
    buffer[offset] = (value >> 56) & 0xFF;
    buffer[offset + 1] = (value >> 48) & 0xFF;
    buffer[offset + 2] = (value >> 40) & 0xFF;
    buffer[offset + 3] = (value >> 32) & 0xFF;
    buffer[offset + 4] = (value >> 24) & 0xFF;
    buffer[offset + 5] = (value >> 16) & 0xFF;
    buffer[offset + 6] = (value >> 8) & 0xFF;
    buffer[offset + 7] = value & 0xFF;
  }

  static int _readUint32BigEndian(Uint8List buffer, int offset) {
    return (buffer[offset] << 24) |
        (buffer[offset + 1] << 16) |
        (buffer[offset + 2] << 8) |
        buffer[offset + 3];
  }

  static int _readUint16BigEndian(Uint8List buffer, int offset) {
    return (buffer[offset] << 8) | buffer[offset + 1];
  }

  static int _readUint64BigEndian(Uint8List buffer, int offset) {
    return (buffer[offset] << 56) |
        (buffer[offset + 1] << 48) |
        (buffer[offset + 2] << 40) |
        (buffer[offset + 3] << 32) |
        (buffer[offset + 4] << 24) |
        (buffer[offset + 5] << 16) |
        (buffer[offset + 6] << 8) |
        buffer[offset + 7];
  }
}
