import 'dart:typed_data';

import 'package:es_compression/brotli.dart';

import 'package:two_space_app/core/network/aegis/errors.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';
import 'package:two_space_app/core/network/aegis/protocol_constants.dart';

export 'errors.dart';

class MessageEncoder {
	static final BrotliCodec _brotli = BrotliCodec();

	static Uint8List encode(Message message) {
		if (!message.isValid) {
			throw ProtocolEncodeError('Invalid message structure');
		}

		var payload = message.payload;
		var flags = message.flags;
		if (payload.length > ProtocolConstants.compressionThreshold) {
			try {
				final compressed = _brotli.encode(payload);
				payload = compressed is Uint8List
						? compressed
						: Uint8List.fromList(compressed);
				flags |= ProtocolConstants.flagCompressed;
			} catch (_) {
				// Some desktop/test environments do not ship the native Brotli
				// library expected by es_compression. Fall back to an uncompressed
				// frame instead of failing the entire send path.
			}
		}

		final totalSize = ProtocolConstants.headerSize + payload.length;
		final buffer = Uint8List(totalSize);
		final byteData = ByteData.view(buffer.buffer);

		byteData.setUint32(0, message.magic);
		buffer[4] = message.versionMajor;
		buffer[5] = message.versionMinor;
		buffer[6] = flags;
		byteData.setUint16(7, message.type.value);
		byteData.setUint64(9, message.sequenceId);
		byteData.setUint32(17, payload.length);
		if (payload.isNotEmpty) {
			buffer.setRange(ProtocolConstants.headerSize, totalSize, payload);
		}
		return buffer;
	}

	static Message decode(Uint8List data) {
		if (data.length < ProtocolConstants.headerSize) {
			throw ProtocolDecodeError('Frame too short: ${data.length}', data);
		}

		final byteData = ByteData.view(data.buffer, data.offsetInBytes, data.length);
		final message = Message();
		message.magic = byteData.getUint32(0);
		if (message.magic != ProtocolConstants.magic) {
			throw ProtocolDecodeError('Invalid magic', data);
		}

		message.versionMajor = data[data.offsetInBytes + 4];
		message.versionMinor = data[data.offsetInBytes + 5];
		message.flags = data[data.offsetInBytes + 6];
		final typeValue = byteData.getUint16(7);
		message.type = MessageType.fromValue(typeValue);
		message.sequenceId = byteData.getUint64(9);
		message.payloadLength = byteData.getUint32(17);

		if (message.payloadLength > ProtocolConstants.maxPayloadSize) {
			throw ProtocolDecodeError('Payload too large: ${message.payloadLength}', data);
		}

		final expectedSize = ProtocolConstants.headerSize + message.payloadLength;
		if (data.length != expectedSize) {
			throw ProtocolDecodeError(
				'Frame size mismatch: expected $expectedSize, got ${data.length}',
				data,
			);
		}

		if (message.payloadLength == 0) {
			return message;
		}

		final payloadView = Uint8List.view(
			data.buffer,
			data.offsetInBytes + ProtocolConstants.headerSize,
			message.payloadLength,
		);

		if ((message.flags & ProtocolConstants.flagCompressed) != 0) {
			final decompressed = _brotli.decode(payloadView);
			message.payload = decompressed is Uint8List
					? decompressed
					: Uint8List.fromList(decompressed);
			message.flags &= ~ProtocolConstants.flagCompressed;
			message.payloadLength = message.payload.length;
			return message;
		}

		message.payload = payloadView;
		return message;
	}
}
