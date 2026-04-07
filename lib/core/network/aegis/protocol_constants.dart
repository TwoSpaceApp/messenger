/// Wire-format constants for the Aegis Messenger Protocol.
///
/// All values match the C# server's `ProtocolConstants` class in
/// `src/Aegis.Protocol/ProtocolConstants.cs`.
///
/// Header layout (21 bytes, all multi-byte fields big-endian):
///
/// | Offset | Size | Field            |
/// |--------|------|------------------|
/// |   0    |  4   | Magic            |
/// |   4    |  1   | Version Major    |
/// |   5    |  1   | Version Minor    |
/// |   6    |  1   | Flags            |
/// |   7    |  2   | Message Type     |
/// |   9    |  8   | Sequence ID      |
/// |  17    |  4   | Payload Length    |
class ProtocolConstants {
  ProtocolConstants._();

  // ── Identification ───────────────────────────────────────────────

  /// Protocol magic number — first four bytes of every frame.
  ///
  /// Server ref: `ProtocolConstants.Magic = 0xAE6C5D7`
  static const int magic = 0xAE6C5D7;

  // ── Version ──────────────────────────────────────────────────────

  /// Current major version. Frames with a different major version are rejected.
  ///
  /// Server ref: `ProtocolConstants.VersionMajor = 1`
  static const int versionMajor = 1;

  /// Current minor version. Minor mismatches produce a warning, not a reject.
  ///
  /// Server ref: `ProtocolConstants.VersionMinor = 0`
  static const int versionMinor = 0;

  // ── Sizes ────────────────────────────────────────────────────────

  /// Header size in bytes: uint32 + 3×byte + uint16 + uint64 + uint32 = 21.
  ///
  /// Server ref: `ProtocolConstants.HeaderSize`
  static const int headerSize = 4 + 1 + 1 + 1 + 2 + 8 + 4; // 21 bytes

  /// MAC / authentication-tag size appended after the payload.
  ///
  /// Currently **0** — AES-GCM tags are embedded inside the ciphertext
  /// rather than appended as a separate frame-level HMAC.
  ///
  /// Server ref: `ProtocolConstants.MacSize = 0`
  static const int macSize = 0;

  /// Maximum total frame size (header + payload + mac).
  ///
  /// Server ref: `ProtocolConstants.MaxMessageSize = 1 MB`
  static const int maxMessageSize = 1024 * 1024; // 1 MB

  /// Maximum payload size (maxMessageSize − headerSize).
  ///
  /// Server ref: `ProtocolConstants.MaxPayloadSize`
  static const int maxPayloadSize = maxMessageSize - headerSize;

  /// Payload byte threshold above which Brotli compression is applied.
  ///
  /// Server ref: `ProtocolConstants.CompressionThreshold = 512`
  static const int compressionThreshold = 512;

  // ── Payload-length field offset (convenience) ────────────────────

  /// Byte offset of the 4-byte payload-length field within the header.
  static const int payloadLengthOffset = 17;

  // ── Message type constants ───────────────────────────────────────
  // Mirrors `MessageType` enum values for use in switch-free code paths.

  static const int typeUnknown = 0;
  static const int typeAuth = 1;
  static const int typePing = 2;
  static const int typeMessage = 3;
  static const int typeAck = 4;
  static const int typeError = 5;
  static const int typeHandshake = 6;
  static const int typeNack = 7;
  static const int typeRetransmitRequest = 8;
  static const int typeUserPresence = 9;
  static const int typeGroupMessage = 10;
  static const int typeGroupCreate = 11;
  static const int typeGroupLeave = 12;
  static const int typeChannelMessage = 13;
  static const int typeChannelCreate = 14;
  static const int typeChannelJoin = 15;
  static const int typeChannelLeave = 16;
  static const int typePrivateChatMessage = 17;
  static const int typeUserSearch = 18;
  static const int typeUserSearchResult = 19;
  static const int typeRegister = 20;
  static const int typeRegisterResponse = 21;
  static const int typeUserTyping = 87;
  static const int typeUserTypingEvent = 88;
  static const int typeFileTransfer = 89;
  static const int typeFileTransferResponse = 90;
  static const int typeFileTransferChunk = 91;
  static const int typeSessionListRequest = 92;
  static const int typeSessionListResponse = 93;
  static const int typeSessionRevokeRequest = 94;
  static const int typeSessionRevokeResponse = 95;
  static const int typeSessionTerminatedEvent = 96;
  static const int typeReadSyncEvent = 97;

  // ── Message flags ────────────────────────────────────────────────
  // Bitmask values for the single-byte `Flags` header field.
  // Server ref: `MessageFlags` enum in `MessageType.cs`.

  /// No flags set.
  static const int flagNone = 0x00;

  /// Sender expects an ACK for this frame.
  static const int flagRequiresAck = 0x01;

  /// This frame is a retransmission of a previously-sent frame.
  static const int flagIsRetransmit = 0x02;

  /// Payload is Brotli-compressed.
  static const int flagCompressed = 0x04;

  /// Payload is encrypted (AES-GCM after session key exchange).
  static const int flagEncrypted = 0x08;

  /// High-priority frame — may skip normal queue ordering.
  static const int flagPriority = 0x10;

  // ── Acknowledgment status codes ──────────────────────────────────

  static const int ackOk = 0;
  static const int ackError = 1;
  static const int ackRetry = 2;
  static const int ackNotImplemented = 3;
}
