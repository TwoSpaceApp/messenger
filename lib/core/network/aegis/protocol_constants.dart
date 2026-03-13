/// Constants for the Aegis Messenger Protocol
class ProtocolConstants {
  // Magic number for protocol identification
  static const int magic = 0xAE6C5D7;

  // Protocol version
  static const int versionMajor = 1;
  static const int versionMinor = 0;

  // Header sizes
  static const int headerSize = 4 + 1 + 1 + 1 + 2 + 8 + 4; // 20 bytes
  static const int macSize = 32; // SHA256 HMAC
  static const int maxMessageSize = 24 * 1024 * 1024; // 24MB
  static const int maxPayloadSize = maxMessageSize - headerSize - macSize;

  // Message type constants
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
  static const int typeProfileUpdate = 22;
  static const int typeProfileUpdateResponse = 23;
  static const int typeProfileGet = 24;
  static const int typeProfileGetResponse = 25;
  static const int typeMessageEdit = 26;
  static const int typeMessageEditResponse = 27;
  static const int typeMessageDelete = 28;
  static const int typeMessageDeleteResponse = 29;
  static const int typeChannelEdit = 30;
  static const int typeChannelEditResponse = 31;
  static const int typeGroupEdit = 32;
  static const int typeGroupEditResponse = 33;
  static const int typeMemberRoleUpdate = 34;
  static const int typeMemberRoleUpdateResponse = 35;
  static const int typeMemberPermissionUpdate = 36;
  static const int typeMemberPermissionUpdateResponse = 37;
  static const int typeGroupMessageSend = 38;
  static const int typeGroupMessageResponse = 39;
  static const int typeGroupCreateResponse = 40;
  static const int typeChatListRequest = 41;
  static const int typeChatListResponse = 42;
  static const int typePrivateChatHistoryRequest = 43;
  static const int typePrivateChatHistoryResponse = 44;
  static const int typeChannelHistoryRequest = 45;
  static const int typeChannelHistoryResponse = 46;
  static const int typePrivateChatMessageEvent = 47;
  static const int typeChannelMessageEvent = 48;
  static const int typeProfileAvatarAdd = 49;
  static const int typeProfileAvatarAddResponse = 50;
  static const int typeProfileAvatarList = 51;
  static const int typeProfileAvatarListResponse = 52;
  static const int typeProfileAvatarDelete = 53;
  static const int typeProfileAvatarDeleteResponse = 54;
  static const int typeProfileAvatarSetPrimary = 55;
  static const int typeProfileAvatarSetPrimaryResponse = 56;
  static const int typeChannelLinkUpdate = 57;
  static const int typeChannelLinkUpdateResponse = 58;
  static const int typeChannelLinkGet = 59;
  static const int typeChannelLinkGetResponse = 60;
  static const int typeChannelResolve = 61;
  static const int typeChannelResolveResponse = 62;
  static const int typeChannelJoinByLink = 63;
  static const int typeChannelJoinByLinkResponse = 64;

  // Message flags
  static const int flagNone = 0x00;
  static const int flagRequiresAck = 0x01;
  static const int flagIsRetransmit = 0x02;
  static const int flagCompressed = 0x04;
  static const int flagEncrypted = 0x08;
  static const int flagPriority = 0x10;

  // Acknowledgment status codes
  static const int ackOk = 0;
  static const int ackError = 1;
  static const int ackRetry = 2;
  static const int ackNotImplemented = 3;
}
