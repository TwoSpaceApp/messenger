import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_encoder.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';
import 'package:two_space_app/core/network/aegis/protocol_constants.dart';

void main() {
  group('MessageEncoder', () {
    test('encodes and decodes a round-trip message', () {
      final message = Message.withType(
        MessageType.privateChatMessage,
        Uint8List.fromList(<int>[1, 2, 3, 4]),
      )
        ..sequenceId = 42
        ..flags = ProtocolConstants.flagRequiresAck;

      final encoded = MessageEncoder.encode(message);
      final decoded = MessageEncoder.decode(encoded);

      expect(decoded.type, MessageType.privateChatMessage);
      expect(decoded.sequenceId, 42);
      expect(decoded.flags, ProtocolConstants.flagRequiresAck);
      expect(decoded.payload, <int>[1, 2, 3, 4]);
      expect(decoded.mac.length, ProtocolConstants.macSize);
    });

    test('throws on invalid magic', () {
      final message = Message.withType(MessageType.ping, <int>[9, 9]);
      final encoded = MessageEncoder.encode(message);
      encoded[0] = 0;

      expect(
        () => MessageEncoder.decode(encoded),
        throwsA(isA<ProtocolError>()),
      );
    });

    test('throws on incomplete frame', () {
      final message = Message.withType(MessageType.ack, <int>[7, 8, 9]);
      final encoded = MessageEncoder.encode(message);
      final truncated = encoded.sublist(0, encoded.length - 1);

      expect(
        () => MessageEncoder.decode(Uint8List.fromList(truncated)),
        throwsA(isA<ProtocolError>()),
      );
    });
  });
}
