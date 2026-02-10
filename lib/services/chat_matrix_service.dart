import 'dart:async';
import 'dart:io';
import 'package:two_space_app/services/watch_service.dart'; // Import WatchService

class ChatMatrixService {
  final WatchService _watchService = WatchService();
  String get homeserver => 'matrix.org';

  Future<List<String>> getJoinedRooms() async {
    return [];
  }

  Future<Map<String, String?>> getRoomNameAndAvatar(String roomId) async {
    return {
      'name': 'Room $roomId',
      'avatar': null,
    };
  }

  Future<void> sendMessage(String roomId, String text, {String? type, String? mediaFileId}) async {
    // Stub
  }

  Future<void> sendReply(String roomId, String replyToId, String text, {String? formattedText}) async {
    // Stub
  }

  Future<void> editMessage(String roomId, String eventId, String text, {String? editEventId}) async {
    // Stub
  }

  Future<void> redactEvent(String roomId, String eventId) async {
    // Stub
  }

  Future<void> sendReaction({required String roomId, required String eventId, required String reaction}) async {
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

  Future<List<dynamic>> loadMessages({required String roomId, int limit = 50}) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> searchMessages({required String query, String? type}) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> getRoomMembers(String roomId, {bool forceRefresh = false}) async {
    return [];
  }

  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    // In a real app, this would make an API call to the Matrix homeserver
    // to get the user's profile information.
    // For now, we'll return some dummy data.
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'displayname': userId.split(':')[0].substring(1),
      'avatar_url': null, // Replace with a real avatar URL if available
      'about': 'This is a dummy bio for the user.',
      'spotify': 'spotify_username',
      'x': 'twitter_handle',
      'github': 'github_username',
      // Add other social media keys here
    };
  }

  Future<void> setUserInfo(String userId, Map<String, dynamic> data) async {
    // In a real app, this would make an API call to the Matrix homeserver
    // to update the user's profile information.
    print('Setting user info for $userId: $data');
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<List<String>> getPinnedEvents(String roomId) async {
    return [];
  }

  Future<void> setPinnedEvents(String roomId, List<String> eventIds) async {
    // Stub
  }

  Future<String?> uploadMedia(dynamic bytes, String contentType, String fileName) async {
    return null;
  }

  Future<String> downloadMediaToTempFile(String mediaId) async {
    return '';
  }

  Future<List<double>> getWaveformForMedia(String mediaId, String? localPath, {int samples = 50}) async {
    return [];
  }

  Future<void> startSync([Function(Map<String, dynamic>)? onEvent]) async {
    // Stub: In a real app, this would listen for new events from the homeserver.
    // For now, we'll simulate a new message event.
    Timer.periodic(const Duration(seconds: 15), (timer) {
      final event = {
        'type': 'm.room.message',
        'sender': '@bob:matrix.org',
        'content': {
          'msgtype': 'm.text',
          'body': 'Hello from Bob! This is a simulated message.',
        },
      };
      onEvent?.call({'rooms': {'join': {'!example1:matrix.org': {'timeline': {'events': [event]}}}}});
      _watchService.sendNewMessageNotification('Bob', 'Hello from Bob!');
    });
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

  // --- Call Methods ---

  Future<void> sendCallInvite(String roomId, String callId) async {
    print('Sending m.call.invite to $roomId (callId: $callId)');
    // In a real implementation, this would send a state event to the room.
  }

  Future<void> sendCallAnswer(String roomId, String callId) async {
    print('Sending m.call.answer to $roomId (callId: $callId)');
    // In a real implementation, this would send a state event to the room.
  }

  Future<void> sendCallHangup(String roomId, String callId) async {
    print('Sending m.call.hangup to $roomId (callId: $callId)');
    // In a real implementation, this would send a state event to the room.
  }

  Future<void> sendSdpOffer(String roomId, String callId, String sdp) async {
    print('Sending SDP Offer to $roomId (callId: $callId)');
    // This would send a custom event like 'm.call.sdp_offer'
  }

  Future<void> sendSdpAnswer(String roomId, String callId, String sdp) async {
    print('Sending SDP Answer to $roomId (callId: $callId)');
    // This would send a custom event like 'm.call.sdp_answer'
  }

  Future<void> sendIceCandidate(String roomId, String callId, Map<String, dynamic> candidate) async {
    print('Sending ICE Candidate to $roomId (callId: $callId)');
    // This would send a custom event like 'm.call.ice_candidate'
  }
}
