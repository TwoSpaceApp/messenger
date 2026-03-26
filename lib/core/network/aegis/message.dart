import 'dart:typed_data';

import 'package:two_space_app/core/network/aegis/message_type.dart';
import 'package:two_space_app/core/network/aegis/protocol_constants.dart';

class Message {
	int magic = ProtocolConstants.magic;
	int versionMajor = ProtocolConstants.versionMajor;
	int versionMinor = ProtocolConstants.versionMinor;
	int flags = ProtocolConstants.flagNone;
	MessageType type = MessageType.unknown;
	int sequenceId = 0;
	int payloadLength = 0;
	Uint8List payload = Uint8List(0);

	Message();

	Message.withType(this.type, [List<int>? payload])
			: payload = payload != null ? Uint8List.fromList(payload) : Uint8List(0) {
		payloadLength = this.payload.length;
	}

	int get totalSize => ProtocolConstants.headerSize + payloadLength;

	bool get isValid {
		return magic == ProtocolConstants.magic &&
				versionMajor == ProtocolConstants.versionMajor &&
				versionMinor == ProtocolConstants.versionMinor &&
				payloadLength <= ProtocolConstants.maxPayloadSize;
	}

	@override
	String toString() {
		return 'Message('
				'magic: 0x${magic.toRadixString(16)}, '
				'version: $versionMajor.$versionMinor, '
				'type: $type, '
				'sequenceId: $sequenceId, '
				'payloadLength: $payloadLength, '
				'flags: 0x${flags.toRadixString(16)}'
				')';
	}
}
