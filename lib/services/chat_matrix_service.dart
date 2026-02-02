import 'dart:async';
import 'dart:io';

class ChatMatrixService {
  String get homeserver => 'matrix.org';

  Future<List<String>> getJoinedRooms() async {
    return [
      '!stub1:matrix.org',
      '!stub2:matrix.org',
    ];
  }

  Future<Map<String, String?>> getRoomNameAndAvatar(String roomId) async {
    if (roomId == '!stub1:matrix.org') {
      return {'name': 'General (Offline)', 'avatar': null};
    }
    if (roomId == '!stub2:matrix.org') {
      return {'name': 'Random (Offline)', 'avatar': null};
    }
    return {
      'name': 'Room $roomId',
      'avatar': null,
    };
  }

  Future<void> sendMessage(String roomId, String userId, String text, {String? type, String? mediaFileId}) async {
    // Stub
  }

  Future<void> sendReply(String roomId, String replyToId, String text, [String? formattedText]) async {
    // Stub
  }

  Future<void> editMessage(String roomId, String eventId, String text, [String? editEventId]) async {
    // Stub
  }

  Future<void> redactEvent(String roomId, String eventId) async {
    // Stub
  }

  Future<void> sendReaction(String roomId, String eventId, String reaction) async {
    // Stub
  }

  Future<Map<String, dynamic>> getReactions(String roomId, String eventId) async {
    return {};
  }

  Stream<dynamic> getRoomEvents(String roomId) {
    return const Stream.empty();
  }

  Future<List<dynamic>> getRoomMessages(String roomId, {int limit = 50}) async {
    return [];
  }

  Future<List<dynamic>> loadMessages(String roomId, {int limit = 50}) async {
    return [
       MockMessage(id: '1', content: 'This is a stub message', time: DateTime.now().subtract(const Duration(minutes: 5)), senderId: '@stub:matrix.org'),
       MockMessage(id: '2', content: 'Offline mode is active', time: DateTime.now(), senderId: '@system:matrix.org'),
    ];
  }

  Future<List<Map<String, dynamic>>> searchMessages(String query, {String? type, required String query}) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> getRoomMembers(String roomId, {bool forceRefresh = false}) async {
    return [];
  }

  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    return {};
  }

  Future<List<String>> getPinnedEvents(String roomId) async {
    return [];
  }

  Future<void> setPinnedEvents(String roomId, List<String> eventIds) async {
    // Stub
  }

  Future<String?> uploadMedia(dynamic bytes, {String? contentType, String? fileName}) async {
    return null;
  }

  Future<String> downloadMediaToTempFile(String mediaId) async {
    return '';
  }

  Future<List<double>> getWaveformForMedia({required String mediaId, String? localPath, int samples = 50}) async {
    return [];
  }

  Future<void> startSync([Function(Map<String, dynamic>)? onEvent]) async {
    // Stub
  }

  Future<void> stopSync() async {
    // Stub
  }

  Future<void> setJoinRule(String roomId, String rule) async {
    // Stub
  }

  Future<void> clearRoomCache(String roomId) async {
    // Stub
  }

  Future<void> markRead(String roomId, String eventId) async {
    // Stub
  }

  Future<void> leaveRoom(String roomId) async {
    // Stub
  }

  Future<void> setRoomName(String roomId, String name) async {
    // Stub
  }

  Future<String> setRoomAvatar(String roomId, dynamic bytes, {String? contentType, String? fileName}) async {
    return '';
  }

  Future<String> createRoom({String? name, List<String>? invite}) async {
    return 'new_room_id';
  }
}

class MockMessage {
  final String id;
  final String content;
  final DateTime time;
  final String senderId;
  final String type;
  final String? mediaId;

  MockMessage({required this.id, required this.content, required this.time, required this.senderId, this.type = 'm.text', this.mediaId});
}
