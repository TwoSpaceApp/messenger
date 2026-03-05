import 'package:two_space_app/services/aegis/message_type.dart';
import 'package:two_space_app/services/aegis/protocol_constants.dart';

/// Represents an Aegis protocol message
class Message {
  /// Magic number for protocol identification
  int magic = ProtocolConstants.magic;
  
  /// Protocol version major
  int versionMajor = ProtocolConstants.versionMajor;
  
  /// Protocol version minor
  int versionMinor = ProtocolConstants.versionMinor;
  
  /// Message flags
  int flags = ProtocolConstants.flagNone;
  
  /// Message type
  MessageType type = MessageType.unknown;
  
  /// Sequence ID for ordering
  int sequenceId = 0;
  
  /// Payload length
  int payloadLength = 0;
  
  /// Message payload data
  List<int> payload = [];
  
  /// Message authentication code
  List<int> mac = List.filled(ProtocolConstants.macSize, 0);

  /// Create empty message
  Message();

  /// Create message with specific type and payload
  Message.withType(this.type, [List<int>? payload]) 
      : payload = payload ?? [] {
    payloadLength = this.payload.length;
  }

  /// Calculate total message size in bytes
  int get totalSize => 
      ProtocolConstants.headerSize + payloadLength + ProtocolConstants.macSize;

  /// Validate message structure
  bool get isValid {
    return magic == ProtocolConstants.magic &&
           versionMajor == ProtocolConstants.versionMajor &&
           versionMinor == ProtocolConstants.versionMinor &&
           payloadLength <= ProtocolConstants.maxPayloadSize &&
           mac.length == ProtocolConstants.macSize;
  }

  @override
  String toString() {
    return 'Message('
        'magic: 0x${magic.toRadixString(16)}, '
        'version: $versionMajor.$versionMinor, '
        'type: $type, '
        'sequenceId: $sequenceId, '
        'payloadLength: $payloadLength, '
        'flags: $flags'
        ')';
  }
}
