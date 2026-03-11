class Chat {
  Chat({
    required this.id,
    required this.name,
    required this.members,
    this.avatarUrl,
    this.lastMessage = '',
    this.roomType,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.presenceStatus,
    this.lastSeenAt,
  });

  factory Chat.fromMap(Map<String, dynamic> m) {
    return Chat(
      id: (m['\u0024id'] ??
                  m['id'] ??
                  m['roomId'] ??
                  m['room_id'] ??
                  m['roomId'])
              ?.toString() ??
          '',
      name:
          (m['name'] ?? m['displayName'] ?? m['roomName'] ?? '')?.toString() ??
              '',
      avatarUrl: (m['avatarUrl'] ?? m['avatar'] ?? m['avatar_url'])?.toString(),
      members:
          (m['members'] is List) ? List<String>.from(m['members']) : <String>[],
      lastMessage:
          (m['lastMessage'] ?? m['last_message'] ?? '')?.toString() ?? '',
      roomType: (m['roomType'] ?? m['type'] ?? m['room_type'])?.toString(),
      lastMessageTime: (() {
        final s = m['lastMessageTime'] ??
            m['last_message_time'] ??
            m['createdAt'] ??
            m['created_at'] ??
            m['ts'];
        if (s == null) return null;
        try {
          if (s is int) return DateTime.fromMillisecondsSinceEpoch(s);
          if (s is String) return DateTime.tryParse(s);
        } catch (_) {}
        return null;
      })(),
      unreadCount: (m['unreadCount'] ?? m['unread_count'] ?? 0) as int,
      isOnline: m['isOnline'] == true,
      presenceStatus: (m['presenceStatus'] ?? m['presence_status'])?.toString(),
      lastSeenAt: (() {
        final raw = m['lastSeenAt'] ?? m['last_seen_at'];
        if (raw is String) return DateTime.tryParse(raw);
        return null;
      })(),
    );
  }
  final String id;
  final String name;
  final String? avatarUrl;
  final List<String> members;
  final String lastMessage;
  final String? roomType;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final String? presenceStatus;
  final DateTime? lastSeenAt;

  Map<String, dynamic> toMap() => {
        '\u0024id': id,
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'members': members,
        'lastMessage': lastMessage,
        'roomType': roomType,
        'lastMessageTime': lastMessageTime?.toIso8601String(),
        'unreadCount': unreadCount,
        'isOnline': isOnline,
        'presenceStatus': presenceStatus,
        'lastSeenAt': lastSeenAt?.toIso8601String(),
      };
}
