import 'dart:isolate';
import 'dart:typed_data';

import 'package:es_compression/brotli.dart';

import 'package:two_space_app/core/network/aegis/buffer_pool.dart';
import 'package:two_space_app/core/network/aegis/crc32.dart';
import 'package:two_space_app/core/network/aegis/errors.dart';
import 'package:two_space_app/core/network/aegis/logger.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';
import 'package:two_space_app/core/network/aegis/protocol_constants.dart';

// Re-export error types so callers that import only this file still see them.
export 'errors.dart'
    show ProtocolDecodeError, ProtocolEncodeError, ProtocolError;

/// Encoder / Decoder for Aegis protocol frames.
///
/// All header fields use **big-endian** byte order, matching the C# server's
/// `MessageEncoder` (which uses `System.Buffers.Binary`).
///
/// ### Frame layout (21-byte header + variable payload)
///
/// | Offset | Size | Field           | Notes                              |
/// |--------|------|-----------------|------------------------------------|
/// |   0    |  4   | Magic           | `0x0AE6C5D7`                       |
/// |   4    |  1   | Version Major   | Currently `1`                      |
/// |   5    |  1   | Version Minor   | Currently `0`                      |
/// |   6    |  1   | Flags           | Bitmask (see [MessageFlag])        |
/// |   7    |  2   | Message Type    | See [MessageType]                  |
/// |   9    |  8   | Sequence ID     | Monotonically increasing per conn  |
/// |  17    |  4   | Payload Length   | 0 … [ProtocolConstants.maxPayloadSize] |
/// |  21    |  N   | Payload         | MessagePack-encoded body           |
///
/// See: `src/Aegis.Protocol/MessageEncoder.cs`
class MessageEncoder {
  /// Shared [BrotliCodec] instance for compression/decompression.
  static final BrotliCodec _brotli = BrotliCodec();

  /// Shared buffer pool used by [encode] to avoid repeated allocations.
  static final BufferPool _pool = BufferPool(maxPoolSize: 64);

  // ── Encoding ─────────────────────────────────────────────────────────

  /// Encode [message] into a binary frame.
  ///
  /// * Payload is Brotli-compressed when its size exceeds
  ///   [ProtocolConstants.compressionThreshold].
  /// * If [bufferPool] is provided, the backing buffer is acquired from it;
  ///   the caller is responsible for returning it via [BufferPool.release].
  ///
  /// Throws [ProtocolEncodeError] if the message fails validation.
  static Uint8List encode(Message message, {BufferPool? bufferPool}) {
    _validateForEncode(message);

    // Brotli-compress when payload exceeds threshold (per server spec).
    Uint8List payload = message.payload;
    int flags = message.flags;
    final isEncrypted = (flags & ProtocolConstants.flagEncrypted) != 0;
    final isCompressed = (flags & ProtocolConstants.flagCompressed) != 0;
    if (!isEncrypted &&
        !isCompressed &&
        payload.length > ProtocolConstants.compressionThreshold) {
      final compressed = _brotli.encode(payload);
      payload = compressed is Uint8List
          ? compressed
          : Uint8List.fromList(compressed);
      flags |= ProtocolConstants.flagCompressed;
    }

    final totalSize = ProtocolConstants.headerSize + payload.length;
    final pool = bufferPool ?? _pool;
    final buffer = pool.acquire(totalSize);

    // ByteData view for zero-copy big-endian writes (no manual bit-shifting).
    final bd = ByteData.view(
      buffer.buffer,
      buffer.offsetInBytes,
      buffer.length,
    );

    bd.setUint32(0, message.magic);
    buffer[4] = message.versionMajor;
    buffer[5] = message.versionMinor;
    buffer[6] = flags;
    bd.setUint16(7, message.type.value);
    bd.setUint64(9, message.sequenceId);
    bd.setUint32(17, payload.length);

    if (payload.isNotEmpty) {
      buffer.setRange(ProtocolConstants.headerSize, totalSize, payload);
    }

    // Return an exact-sized view (pool buffers may be larger).
    return Uint8List.view(buffer.buffer, buffer.offsetInBytes, totalSize);
  }

  /// Encode [message] in a background isolate to avoid blocking the
  /// main event loop on large payloads.
  static Future<Uint8List> encodeAsync(Message message) {
    return Isolate.run(() => encode(message));
  }

  // ── Decoding ─────────────────────────────────────────────────────────

  /// Decode a binary frame into a [Message].
  ///
  /// Validates all header fields and payload length **before** allocating
  /// the payload buffer.  Throws [ProtocolDecodeError] with a hex dump of
  /// the problematic frame on failure.
  static Message decode(Uint8List data) {
    if (data.length < ProtocolConstants.headerSize) {
      throw ProtocolDecodeError(
        'Frame too short: ${data.length} bytes '
        '(minimum ${ProtocolConstants.headerSize})',
        data,
      );
    }

    // Zero-copy ByteData view over the incoming buffer.
    final bd = ByteData.view(data.buffer, data.offsetInBytes, data.length);
    final message = Message();

    // ── Magic ──────────────────────────────────────────────────────
    message.magic = bd.getUint32(0);
    if (message.magic != ProtocolConstants.magic) {
      throw ProtocolDecodeError(
        'Invalid magic: 0x${message.magic.toRadixString(16).padLeft(8, '0')} '
        '(expected 0x${ProtocolConstants.magic.toRadixString(16).padLeft(8, '0')})',
        data,
      );
    }

    // ── Version ────────────────────────────────────────────────────
    message.versionMajor = data[data.offsetInBytes + 4];
    message.versionMinor = data[data.offsetInBytes + 5];
    if (message.versionMajor != ProtocolConstants.versionMajor) {
      throw ProtocolDecodeError(
        'Unsupported protocol version: '
        '${message.versionMajor}.${message.versionMinor} '
        '(expected ${ProtocolConstants.versionMajor}.x)',
        data,
      );
    }

    // ── Flags ──────────────────────────────────────────────────────
    message.flags = data[data.offsetInBytes + 6];
    const knownFlagsMask =
        ProtocolConstants.flagRequiresAck |
        ProtocolConstants.flagIsRetransmit |
        ProtocolConstants.flagCompressed |
        ProtocolConstants.flagEncrypted |
        ProtocolConstants.flagPriority;
    if ((message.flags & ~knownFlagsMask) != 0) {
      AegisLogger.warning(
        'Unknown flags in frame: 0x${message.flags.toRadixString(16)} '
        '(unknown bits: 0x${(message.flags & ~knownFlagsMask).toRadixString(16)})',
      );
    }

    // ── Message type ───────────────────────────────────────────────
    final typeValue = bd.getUint16(7);
    message.type = MessageType.fromValue(typeValue);
    if (message.type == MessageType.unknown && typeValue != 0) {
      AegisLogger.warning('Unknown message type value: $typeValue');
    }

    // ── Sequence ID ────────────────────────────────────────────────
    message.sequenceId = bd.getUint64(9);

    // ── Payload length (validated BEFORE allocation) ───────────────
    final payloadLength = bd.getUint32(17);
    if (payloadLength > ProtocolConstants.maxPayloadSize) {
      throw ProtocolDecodeError(
        'Payload length exceeds maximum: '
        '$payloadLength > ${ProtocolConstants.maxPayloadSize}',
        data,
      );
    }
    message.payloadLength = payloadLength;

    final expectedSize = ProtocolConstants.headerSize + payloadLength;
    if (data.length != expectedSize) {
      throw ProtocolDecodeError(
        'Frame size mismatch: expected $expectedSize bytes, '
        'got ${data.length}',
        data,
      );
    }

    // ── Payload ────────────────────────────────────────────────────
    if (payloadLength > 0) {
      final isEncryptedPayload =
          (message.flags & ProtocolConstants.flagEncrypted) != 0;
      if (!isEncryptedPayload &&
          (message.flags & ProtocolConstants.flagCompressed) != 0) {
        // Compressed — create a view for the decompressor input, then
        // decompress into a new allocation.
        final compressed = Uint8List.view(
          data.buffer,
          data.offsetInBytes + ProtocolConstants.headerSize,
          payloadLength,
        );
        final decompressed = _brotli.decode(compressed);
        message.payload = decompressed is Uint8List
            ? decompressed
            : Uint8List.fromList(decompressed);
        // Clear the compressed flag — the payload is now decompressed.
        message.flags &= ~ProtocolConstants.flagCompressed;
      } else {
        // Uncompressed — zero-copy view over the original buffer.
        message.payload = Uint8List.view(
          data.buffer,
          data.offsetInBytes + ProtocolConstants.headerSize,
          payloadLength,
        );
      }
    }

    return message;
  }

  /// Decode a frame in a background isolate.
  static Future<Message> decodeAsync(Uint8List data) {
    return Isolate.run(() => decode(data));
  }

  // ── CRC-32 header integrity (optional) ───────────────────────────

  /// Compute CRC-32 over the header portion of [data].
  ///
  /// This is an **optional** integrity check — the wire format does not
  /// include a header checksum field.  Use it for local validation or
  /// transport-level integrity layers.
  static int computeHeaderCrc32(Uint8List data) {
    if (data.length < ProtocolConstants.headerSize) {
      throw ProtocolDecodeError(
        'Frame too short for CRC-32 computation',
        data,
      );
    }
    return Crc32.compute(data, 0, ProtocolConstants.headerSize);
  }

  /// Check whether the header CRC-32 of [data] equals [expectedCrc32].
  static bool verifyHeaderCrc32(Uint8List data, int expectedCrc32) {
    return computeHeaderCrc32(data) == expectedCrc32;
  }

  // ── Validation ───────────────────────────────────────────────────

  static void _validateForEncode(Message message) {
    if (message.magic != ProtocolConstants.magic) {
      throw ProtocolEncodeError(
        'Invalid magic: 0x${message.magic.toRadixString(16)}',
      );
    }
    if (message.versionMajor != ProtocolConstants.versionMajor) {
      throw ProtocolEncodeError(
        'Unsupported version: '
        '${message.versionMajor}.${message.versionMinor}',
      );
    }
    if (message.payload.length > ProtocolConstants.maxPayloadSize) {
      throw ProtocolEncodeError(
        'Payload too large: '
        '${message.payload.length} > ${ProtocolConstants.maxPayloadSize}',
      );
    }
  }
}
