import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:two_space_app/config/environment.dart';

/// Full Matrix Client-Server API implementation for syncing rooms, messages, etc.
class ChatMatrixService {
  static final ChatMatrixService _instance = ChatMatrixService._internal();
  factory ChatMatrixService() => _instance;
  ChatMatrixService._internal();

  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  static const _tokenKey = 'matrix_access_token';
  static const _userIdKey = 'matrix_user_id';
  static const _syncTokenKey = 'matrix_sync_token';

  String? _accessToken;
  String? _userId;
  String? _syncToken;
  Timer? _syncTimer;
  bool _syncing = false;

  String get homeserver {
    final hs = Environment.matrixHomeserverUrl;
    if (hs.isEmpty) return 'https://matrix.org';
    var base = hs.trim();
    if (!base.startsWith('http')) base = 'https://$base';
    return base.replaceAll(RegExp(r'/$'), '');
  }

  /// Initialize service: load tokens from storage
  Future<void> init() async {
    _accessToken = await _secure.read(key: _tokenKey);
    _userId = await _secure.read(key: _userIdKey);
    _syncToken = await _secure.read(key: _syncTokenKey);
  }

  /// Check if we have valid credentials
  bool get isLoggedIn => _accessToken != null && _accessToken!.isNotEmpty;

  /// Get current user ID
  Future<String?> getCurrentUserId() async {
    if (_userId != null) return _userId;
    _userId = await _secure.read(key: _userIdKey);
    return _userId;
  }

  /// Save credentials after login
  Future<void> saveCredentials(String accessToken, String userId, {String? deviceId}) async {
    _accessToken = accessToken;
    _userId = userId;
    await _secure.write(key: _tokenKey, value: accessToken);
    await _secure.write(key: _userIdKey, value: userId);
  }

  /// Clear credentials on logout
  Future<void> clearCredentials() async {
    _accessToken = null;
    _userId = null;
    _syncToken = null;
    await _secure.delete(key: _tokenKey);
    await _secure.delete(key: _userIdKey);
    await _secure.delete(key: _syncTokenKey);
  }

  /// HTTP headers with auth
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  /// Login with password
  Future<Map<String, dynamic>> login(String username, String password) async {
    final uri = Uri.parse('$homeserver/_matrix/client/v3/login');
    
    // Normalize username
    String user = username;
    if (username.contains('@') && !username.startsWith('@')) {
      user = username.split('@').first;
    } else if (username.startsWith('@') && username.contains(':')) {
      user = username.substring(1).split(':').first;
    }

    final body = jsonEncode({
      'type': 'm.login.password',
      'identifier': {'type': 'm.id.user', 'user': user},
      'password': password,
      'initial_device_display_name': 'TwoSpace Mobile',
    });

    final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: body);
    if (res.statusCode != 200) {
      final err = jsonDecode(res.body);
      throw Exception(err['error'] ?? 'Login failed: ${res.statusCode}');
    }

    final js = jsonDecode(res.body) as Map<String, dynamic>;
    final token = js['access_token'] as String?;
    final userId = js['user_id'] as String?;
    final deviceId = js['device_id'] as String?;

    if (token == null || userId == null) {
      throw Exception('Invalid login response');
    }

    await saveCredentials(token, userId, deviceId: deviceId);
    return js;
  }

  /// Get list of joined rooms
  Future<List<String>> getJoinedRooms() async {
    if (_accessToken == null) await init();
    if (_accessToken == null) return [];

    final uri = Uri.parse('$homeserver/_matrix/client/v3/joined_rooms');
    final res = await http.get(uri, headers: _headers);
    
    if (res.statusCode != 200) return [];
    
    final js = jsonDecode(res.body) as Map<String, dynamic>;
    final rooms = js['joined_rooms'] as List? ?? [];
    return rooms.cast<String>();
  }

  /// Get room name and avatar
  Future<Map<String, String?>> getRoomNameAndAvatar(String roomId) async {
    if (_accessToken == null) await init();
    
    String? name;
    String? avatar;

    // Get room state for name
    try {
      final nameUri = Uri.parse('$homeserver/_matrix/client/v3/rooms/${Uri.encodeComponent(roomId)}/state/m.room.name');
      final nameRes = await http.get(nameUri, headers: _headers);
      if (nameRes.statusCode == 200) {
        final js = jsonDecode(nameRes.body);
        name = js['name'] as String?;
      }
    } catch (_) {}

    // Get room avatar
    try {
      final avUri = Uri.parse('$homeserver/_matrix/client/v3/rooms/${Uri.encodeComponent(roomId)}/state/m.room.avatar');
      final avRes = await http.get(avUri, headers: _headers);
      if (avRes.statusCode == 200) {
        final js = jsonDecode(avRes.body);
        final mxc = js['url'] as String?;
        if (mxc != null) {
          avatar = mxcToHttp(mxc);
        }
      }
    } catch (_) {}

    // If no name, try to get from members (DM)
    if (name == null || name.isEmpty) {
      try {
        final membersUri = Uri.parse('$homeserver/_matrix/client/v3/rooms/${Uri.encodeComponent(roomId)}/members');
        final membersRes = await http.get(membersUri, headers: _headers);
        if (membersRes.statusCode == 200) {
          final js = jsonDecode(membersRes.body);
          final chunks = js['chunk'] as List? ?? [];
          for (final m in chunks) {
            final sender = m['sender'] as String?;
            if (sender != null && sender != _userId) {
              final content = m['content'] as Map<String, dynamic>?;
              name = content?['displayname'] as String? ?? sender;
              final memberAvatar = content?['avatar_url'] as String?;
              if (memberAvatar != null && avatar == null) {
                avatar = mxcToHttp(memberAvatar);
              }
              break;
            }
          }
        }
      } catch (_) {}
    }

    return {'name': name ?? roomId, 'avatar': avatar};
  }

  /// Convert mxc:// URL to http(s):// URL
  String mxcToHttp(String mxc) {
    if (!mxc.startsWith('mxc://')) return mxc;
    final parts = mxc.substring(6).split('/');
    if (parts.length < 2) return mxc;
    final server = parts[0];
    final mediaId = parts[1];
    return '$homeserver/_matrix/media/v3/download/$server/$mediaId';
  }

  /// Load messages from a room
  Future<List<MatrixMessage>> loadMessages({required String roomId, int limit = 50}) async {
    if (_accessToken == null) await init();
    if (_accessToken == null) return [];

    final uri = Uri.parse('$homeserver/_matrix/client/v3/rooms/${Uri.encodeComponent(roomId)}/messages?dir=b&limit=$limit');
    final res = await http.get(uri, headers: _headers);

    if (res.statusCode != 200) return [];

    final js = jsonDecode(res.body) as Map<String, dynamic>;
    final chunks = js['chunk'] as List? ?? [];
    
    final messages = <MatrixMessage>[];
    for (final event in chunks) {
      if (event['type'] == 'm.room.message') {
        final content = event['content'] as Map<String, dynamic>?;
        if (content == null) continue;
        
        final msgType = content['msgtype'] as String? ?? 'm.text';
        final body = content['body'] as String? ?? '';
        final url = content['url'] as String?;
        
        messages.add(MatrixMessage(
          id: event['event_id'] as String,
          content: body,
          time: DateTime.fromMillisecondsSinceEpoch(event['origin_server_ts'] as int),
          senderId: event['sender'] as String,
          type: msgType,
          mediaId: url,
        ));
      }
    }
    return messages;
  }

  /// Send a text message
  Future<String?> sendMessage({
    required String roomId,
    required String text,
    String? userId,
    String? type,
    String? mediaFileId,
  }) async {
    if (_accessToken == null) await init();
    if (_accessToken == null) return null;

    final txnId = DateTime.now().millisecondsSinceEpoch.toString();
    final msgType = type ?? 'm.text';
    
    Map<String, dynamic> content;
    if (msgType == 'm.image' && mediaFileId != null) {
      content = {'msgtype': 'm.image', 'body': text.isNotEmpty ? text : 'image', 'url': mediaFileId};
    } else if (msgType == 'm.audio' && mediaFileId != null) {
      content = {'msgtype': 'm.audio', 'body': text.isNotEmpty ? text : 'audio', 'url': mediaFileId};
    } else {
      content = {'msgtype': 'm.text', 'body': text};
    }

    final uri = Uri.parse('$homeserver/_matrix/client/v3/rooms/${Uri.encodeComponent(roomId)}/send/m.room.message/$txnId');
    final res = await http.put(uri, headers: _headers, body: jsonEncode(content));

    if (res.statusCode == 200) {
      final js = jsonDecode(res.body);
      return js['event_id'] as String?;
    }
    return null;
  }

  /// Upload media and return mxc:// URL
  Future<String?> uploadMedia(dynamic bytes, String? contentType, String? fileName) async {
    if (_accessToken == null) await init();
    if (_accessToken == null) return null;

    final uri = Uri.parse('$homeserver/_matrix/media/v3/upload?filename=${Uri.encodeComponent(fileName ?? 'file')}');
    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': contentType ?? 'application/octet-stream',
      },
      body: bytes,
    );

    if (res.statusCode == 200) {
      final js = jsonDecode(res.body);
      return js['content_uri'] as String?;
    }
    return null;
  }

  /// Download media to temp file
  Future<String> downloadMediaToTempFile(String mediaId) async {
    String url;
    if (mediaId.startsWith('mxc://')) {
      url = mxcToHttp(mediaId);
    } else if (mediaId.startsWith('http')) {
      url = mediaId;
    } else {
      return '';
    }

    try {
      final res = await http.get(Uri.parse(url), headers: _headers);
      if (res.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final fileName = mediaId.hashCode.toString();
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(res.bodyBytes);
        return file.path;
      }
    } catch (_) {}
    return '';
  }

  /// Get user info (displayname, avatar)
  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    if (_accessToken == null) await init();

    try {
      final uri = Uri.parse('$homeserver/_matrix/client/v3/profile/${Uri.encodeComponent(userId)}');
      final res = await http.get(uri, headers: _headers);
      if (res.statusCode == 200) {
        final js = jsonDecode(res.body) as Map<String, dynamic>;
        final avatar = js['avatar_url'] as String?;
        return {
          'displayName': js['displayname'] as String? ?? userId,
          'avatarUrl': avatar != null ? mxcToHttp(avatar) : null,
        };
      }
    } catch (_) {}
    return {'displayName': userId, 'avatarUrl': null};
  }

  /// Start background sync
  void startSync([Function(Map<String, dynamic>)? onEvent]) {
    if (_syncing) return;
    _syncing = true;
    _doSync(onEvent);
  }

  Future<void> _doSync([Function(Map<String, dynamic>)? onEvent]) async {
    if (!_syncing) return;
    if (_accessToken == null) await init();
    if (_accessToken == null) return;

    try {
      var uri = '$homeserver/_matrix/client/v3/sync?timeout=30000';
      if (_syncToken != null) {
        uri += '&since=$_syncToken';
      }

      final res = await http.get(Uri.parse(uri), headers: _headers).timeout(const Duration(seconds: 35));
      if (res.statusCode == 200) {
        final js = jsonDecode(res.body) as Map<String, dynamic>;
        _syncToken = js['next_batch'] as String?;
        if (_syncToken != null) {
          await _secure.write(key: _syncTokenKey, value: _syncToken!);
        }
        if (onEvent != null) onEvent(js);
      }
    } catch (_) {}

    // Continue syncing
    if (_syncing) {
      Future.delayed(const Duration(milliseconds: 500), () => _doSync(onEvent));
    }
  }

  void stopSync() {
    _syncing = false;
    _syncTimer?.cancel();
  }

  // ===== Additional stubs for compatibility =====
  Future<void> sendReply(String roomId, String replyToId, {required String body, String? formattedBody}) async {
    await sendMessage(roomId: roomId, text: body);
  }

  Future<void> editMessage(String roomId, String eventId, String text, [String? editEventId]) async {
    // Edit not implemented in this version
  }

  Future<void> redactEvent(String roomId, String eventId) async {
    if (_accessToken == null) return;
    final txnId = DateTime.now().millisecondsSinceEpoch.toString();
    final uri = Uri.parse('$homeserver/_matrix/client/v3/rooms/${Uri.encodeComponent(roomId)}/redact/${Uri.encodeComponent(eventId)}/$txnId');
    await http.put(uri, headers: _headers, body: jsonEncode({}));
  }

  Future<void> sendReaction({required String roomId, required String eventId, required String reaction}) async {
    if (_accessToken == null) return;
    final txnId = DateTime.now().millisecondsSinceEpoch.toString();
    final uri = Uri.parse('$homeserver/_matrix/client/v3/rooms/${Uri.encodeComponent(roomId)}/send/m.reaction/$txnId');
    await http.put(uri, headers: _headers, body: jsonEncode({
      'm.relates_to': {'rel_type': 'm.annotation', 'event_id': eventId, 'key': reaction}
    }));
  }

  Future<Map<String, dynamic>> getReactions(String roomId, String eventId) async => {};
  Future<List<String>> getPinnedEvents(String roomId) async => [];
  Future<void> setPinnedEvents(String roomId, List<String> eventIds) async {}
  Future<void> markRead(String roomId, String eventId) async {}
  Future<void> leaveRoom(String roomId) async {}
  Future<void> setRoomName(String roomId, String name) async {}
  Future<String> setRoomAvatar(String roomId, dynamic bytes, {String? contentType, String? fileName}) async => '';
  
  /// Create a new Matrix room
  Future<String> createRoom({
    String? name, 
    String? topic,
    List<String>? invite,
    bool isPublic = false,
  }) async {
    if (_accessToken == null) await init();
    if (_accessToken == null) throw Exception('Не авторизован');

    final uri = Uri.parse('$homeserver/_matrix/client/v3/createRoom');
    
    final body = <String, dynamic>{
      'preset': isPublic ? 'public_chat' : 'private_chat',
      'visibility': isPublic ? 'public' : 'private',
    };
    
    if (name != null && name.isNotEmpty) {
      body['name'] = name;
    }
    if (topic != null && topic.isNotEmpty) {
      body['topic'] = topic;
    }
    if (invite != null && invite.isNotEmpty) {
      body['invite'] = invite;
    }

    final res = await http.post(uri, headers: _headers, body: jsonEncode(body));
    
    if (res.statusCode != 200) {
      final err = jsonDecode(res.body);
      throw Exception(err['error'] ?? 'Failed to create room: ${res.statusCode}');
    }

    final js = jsonDecode(res.body) as Map<String, dynamic>;
    return js['room_id'] as String;
  }
  
  /// Create a direct chat with a user
  Future<String> createDirectChat(String userId) async {
    if (_accessToken == null) await init();
    if (_accessToken == null) throw Exception('Не авторизован');

    final uri = Uri.parse('$homeserver/_matrix/client/v3/createRoom');
    
    final body = jsonEncode({
      'preset': 'trusted_private_chat',
      'is_direct': true,
      'invite': [userId],
      'initial_state': [
        {
          'type': 'm.room.guest_access',
          'state_key': '',
          'content': {'guest_access': 'can_join'}
        }
      ]
    });

    final res = await http.post(uri, headers: _headers, body: body);
    
    if (res.statusCode != 200) {
      final err = jsonDecode(res.body);
      throw Exception(err['error'] ?? 'Failed to create chat: ${res.statusCode}');
    }

    final js = jsonDecode(res.body) as Map<String, dynamic>;
    final roomId = js['room_id'] as String;
    
    // Mark this room as direct in account data
    try {
      await _setDirectChat(userId, roomId);
    } catch (_) {}
    
    return roomId;
  }
  
  /// Mark room as direct chat in account data
  Future<void> _setDirectChat(String userId, String roomId) async {
    // Get current direct chats
    final getUri = Uri.parse('$homeserver/_matrix/client/v3/user/${Uri.encodeComponent(_userId!)}/account_data/m.direct');
    Map<String, dynamic> directs = {};
    
    try {
      final getRes = await http.get(getUri, headers: _headers);
      if (getRes.statusCode == 200) {
        directs = jsonDecode(getRes.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    
    // Add new direct chat
    final userRooms = (directs[userId] as List?)?.cast<String>() ?? [];
    if (!userRooms.contains(roomId)) {
      userRooms.add(roomId);
      directs[userId] = userRooms;
      
      // Save
      final putUri = Uri.parse('$homeserver/_matrix/client/v3/user/${Uri.encodeComponent(_userId!)}/account_data/m.direct');
      await http.put(putUri, headers: _headers, body: jsonEncode(directs));
    }
  }
  
  Future<List<Map<String, dynamic>>> searchMessages({required String query, String? type}) async => [];
  Future<List<Map<String, dynamic>>> getRoomMembers(String roomId, {bool forceRefresh = false}) async => [];
  Future<void> setJoinRule(String roomId, String rule) async {}
  Future<void> clearRoomCache(String roomId) async {}
  Future<List<double>> getWaveformForMedia(String mediaId, String? localPath, {int samples = 50}) async => [];
}

class MatrixMessage {
  final String id;
  final String content;
  final DateTime time;
  final String senderId;
  final String type;
  final String? mediaId;

  MatrixMessage({
    required this.id,
    required this.content,
    required this.time,
    required this.senderId,
    this.type = 'm.text',
    this.mediaId,
  });
}
