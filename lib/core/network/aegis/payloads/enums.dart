/// Message content types
enum MessageContentType {
  text(0),
  image(1),
  video(2),
  audio(3),
  file(4),
  location(5);

  const MessageContentType(this.value);
  final int value;

  static MessageContentType fromValue(int value) {
    return MessageContentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MessageContentType.text,
    );
  }
}

/// Channel types
enum ChannelType {
  public(0),
  private(1),
  group(2);

  const ChannelType(this.value);
  final int value;

  static ChannelType fromValue(int value) {
    return ChannelType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ChannelType.public,
    );
  }
}

/// Target chat type for unified messaging APIs.
enum ChatTargetType { private, channel, group }

/// Scope for message operations and reactions in private chats, channels, or groups.
enum ChatScope {
  privateChat('private'),
  channel('channel'),
  group('group');

  const ChatScope(this.value);
  final String value;

  static ChatScope fromValue(String value) {
    return ChatScope.values.firstWhere(
      (scope) => scope.value == value,
      orElse: () => ChatScope.privateChat,
    );
  }
}

/// Scope for room-level operations that only apply to channels or groups.
enum RoomScope {
  channel('channel'),
  group('group');

  const RoomScope(this.value);
  final String value;

  static RoomScope fromValue(String value) {
    return RoomScope.values.firstWhere(
      (scope) => scope.value == value,
      orElse: () => RoomScope.channel,
    );
  }
}

/// Channel/group member role values used by the server.
enum MemberRole {
  member(0),
  moderator(1),
  admin(2),
  owner(3);

  const MemberRole(this.value);
  final int value;

  static MemberRole fromValue(int value) {
    return MemberRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => MemberRole.member,
    );
  }
}

/// Who may join a room.
enum RoomJoinRule {
  open(0),
  inviteOnly(1),
  approval(2);

  const RoomJoinRule(this.value);
  final int value;

  static RoomJoinRule fromValue(int value) {
    return RoomJoinRule.values.firstWhere(
      (rule) => rule.value == value,
      orElse: () => RoomJoinRule.open,
    );
  }
}

/// Who can see room history.
enum RoomHistoryVisibility {
  worldReadable(0),
  joined(1),
  invited(2);

  const RoomHistoryVisibility(this.value);
  final int value;

  static RoomHistoryVisibility fromValue(int value) {
    return RoomHistoryVisibility.values.firstWhere(
      (visibility) => visibility.value == value,
      orElse: () => RoomHistoryVisibility.joined,
    );
  }
}

/// Media kind for unified media sending.
enum MediaKind { photo, video, gif, file, voice }

/// Text parse mode used for rich formatting.
enum ParseMode {
  markdown('markdown'),
  markdownV2('markdownv2'),
  html('html');

  const ParseMode(this.value);
  final String value;
}
