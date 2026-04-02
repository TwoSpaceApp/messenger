import 'dart:typed_data';

import 'package:two_space_app/core/network/aegis/message_encoder.dart'
    show MessageEncoder;

import 'package:two_space_app/core/network/aegis/message_type.dart';
import 'package:two_space_app/core/network/aegis/protocol_constants.dart';

/// Represents a single Aegis protocol frame (header + payload).
///
/// Create a message with [Message.withType] for outgoing frames, or
/// obtain one from [MessageEncoder.decode] for incoming frames.
///
/// See: `src/Aegis.Protocol/Message.cs`
class Message {
  /// Protocol magic — must equal [ProtocolConstants.magic].
  int magic = ProtocolConstants.magic;

  /// Major protocol version. Must match [ProtocolConstants.versionMajor].
  int versionMajor = ProtocolConstants.versionMajor;

  /// Minor protocol version.
  int versionMinor = ProtocolConstants.versionMinor;

  /// Bitmask of [ProtocolConstants] flag* constants.
  int flags = ProtocolConstants.flagNone;

  /// Discriminator that tells the server which handler should process
  /// this frame. See [MessageType].
  MessageType type = MessageType.unknown;

  /// Monotonically increasing ID used to match requests with responses
  /// and detect duplicate/replayed frames.
  int sequenceId = 0;

  /// Length of [payload] in bytes (wire value — may differ from
  /// `payload.length` after decompression).
  int payloadLength = 0;

  /// MessagePack-encoded body. Empty for control frames (ping, ack, …).
  Uint8List payload = Uint8List(0);

  Message();

  /// Create a message with the given [type] and optional [payload].
  Message.withType(this.type, [List<int>? payload])
    : payload = payload != null ? Uint8List.fromList(payload) : Uint8List(0) {
    payloadLength = this.payload.length;
  }

  /// Total frame size on the wire (header + payload + MAC).
  int get totalSize =>
      ProtocolConstants.headerSize + payloadLength + ProtocolConstants.macSize;

  /// Basic validity check against protocol constants.
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
