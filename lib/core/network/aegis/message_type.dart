/// Message types for the Aegis Protocol.
///
/// Each value corresponds to the `MessageType` enum in the C# server
/// (`src/Aegis.Protocol/MessageType.cs`). The 2-byte type field in the
/// frame header is encoded big-endian at offset 7.
enum MessageType {
  unknown(0),
  auth(1),
  ping(2),
  message(3),
  ack(4),
  error(5),
  handshake(6),
  nack(7),
  retransmitRequest(8),
  userPresence(9),
  groupMessage(10),
  groupCreate(11),
  groupLeave(12),
  channelMessage(13),
  channelCreate(14),
  channelJoin(15),
  channelLeave(16),
  privateChatMessage(17),
  userSearch(18),
  userSearchResult(19),
  register(20),
  registerResponse(21),

  // Profile management
  profileUpdate(22),
  profileUpdateResponse(23),
  profileGet(24),
  profileGetResponse(25),

  // Message edit/delete
  messageEdit(26),
  messageEditResponse(27),
  messageDelete(28),
  messageDeleteResponse(29),

  // Channel/Group editing
  channelEdit(30),
  channelEditResponse(31),
  groupEdit(32),
  groupEditResponse(33),

  // Admin/permissions management
  memberRoleUpdate(34),
  memberRoleUpdateResponse(35),
  memberPermissionUpdate(36),
  memberPermissionUpdateResponse(37),

  // Group messaging
  groupMessageSend(38),
  groupMessageResponse(39),
  groupCreateResponse(40),

  // Chat bootstrap APIs and server-side events
  chatListRequest(41),
  chatListResponse(42),
  privateChatHistoryRequest(43),
  privateChatHistoryResponse(44),
  channelHistoryRequest(45),
  channelHistoryResponse(46),
  privateChatMessageEvent(47),
  channelMessageEvent(48),

  // Profile avatars
  profileAvatarAdd(49),
  profileAvatarAddResponse(50),
  profileAvatarList(51),
  profileAvatarListResponse(52),
  profileAvatarDelete(53),
  profileAvatarDeleteResponse(54),
  profileAvatarSetPrimary(55),
  profileAvatarSetPrimaryResponse(56),

  // Channel links
  channelLinkUpdate(57),
  channelLinkUpdateResponse(58),
  channelLinkGet(59),
  channelLinkGetResponse(60),
  channelResolve(61),
  channelResolveResponse(62),
  channelJoinByLink(63),
  channelJoinByLinkResponse(64),

  // Message delivery/read receipts
  messageReadReceipt(65),
  messageReadReceiptResponse(66),
  messageDeliveryReceipt(67),
  messageDeliveryReceiptResponse(68),

  // Async status event (server -> clients)
  messageStatusEvent(69),

  // SERVER-002: Group history
  groupHistoryRequest(70),
  groupHistoryResponse(71),
  groupMessageEvent(72),

  // SERVER-003: Member listing
  channelMembersRequest(73),
  channelMembersResponse(74),
  groupMembersRequest(75),
  groupMembersResponse(76),

  // SERVER-005: Reactions and pins
  messageReact(77),
  messageReactResponse(78),
  messageReactionEvent(79),
  messagePin(80),
  messagePinResponse(81),
  messagePinEvent(82),

  // SERVER-006: Room settings
  roomSettingsGet(83),
  roomSettingsGetResponse(84),
  roomSettingsUpdate(85),
  roomSettingsUpdateResponse(86),

  // SERVER-007: Typing, file transfer, and session management
  userTyping(87),
  userTypingEvent(88),
  fileTransfer(89),
  fileTransferResponse(90),
  fileTransferChunk(91),
  sessionListRequest(92),
  sessionListResponse(93),
  sessionRevokeRequest(94),
  sessionRevokeResponse(95),
  sessionTerminatedEvent(96),
  readSyncEvent(97),

  // v2.1+ Protocol improvements
  pong(98),
  keepAliveExponential(99),
  tokenExpired(100),
  disconnectReason(101),
  sessionConflict(102),
  profilesBatch(103),
  chatListStream(104),
  chatListChunk(105),
  serverOverloaded(106);

  const MessageType(this.value);
  final int value;

  static MessageType fromValue(int value) {
    return MessageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MessageType.unknown,
    );
  }
}

/// Bitmask flags for the single-byte `Flags` header field (offset 6).
///
/// See: `MessageFlags` in `src/Aegis.Protocol/MessageType.cs`.
enum MessageFlag {
  /// Sender expects an ACK response for this frame.
  requiresAck(0x01),

  /// This frame is a retransmission of a previously-sent frame.
  isRetransmit(0x02),

  /// Payload is Brotli-compressed.
  compressed(0x04),

  /// Payload is encrypted (AES-GCM after key exchange).
  encrypted(0x08),

  /// High-priority frame — may skip normal queue ordering.
  priority(0x10);

  const MessageFlag(this.value);
  final int value;
}

/// Server ACK status codes carried in ACK/NACK payloads.
///
/// See: `AckStatus` in `src/Aegis.Protocol/MessageType.cs`.
enum AckStatus {
  ok(0),
  error(1),
  retry(2),
  notImplemented(3);

  const AckStatus(this.value);
  final int value;

  static AckStatus fromValue(int value) {
    return AckStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AckStatus.error,
    );
  }
}
