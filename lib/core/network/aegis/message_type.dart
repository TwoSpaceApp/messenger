/// Message types for the Aegis Protocol
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
  profileUpdate(22),
  profileUpdateResponse(23),
  profileGet(24),
  profileGetResponse(25),
  messageEdit(26),
  messageEditResponse(27),
  messageDelete(28),
  messageDeleteResponse(29),
  channelEdit(30),
  channelEditResponse(31),
  groupEdit(32),
  groupEditResponse(33),
  memberRoleUpdate(34),
  memberRoleUpdateResponse(35),
  memberPermissionUpdate(36),
  memberPermissionUpdateResponse(37),
  groupMessageSend(38),
  groupMessageResponse(39),
  groupCreateResponse(40);

  const MessageType(this.value);
  final int value;

  static MessageType fromValue(int value) {
    return MessageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MessageType.unknown,
    );
  }
}

/// Message flags for protocol features
enum MessageFlag {
  requiresAck(0x01),
  isRetransmit(0x02),
  compressed(0x04),
  encrypted(0x08),
  priority(0x10);

  const MessageFlag(this.value);
  final int value;
}

/// Acknowledgment status codes
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
