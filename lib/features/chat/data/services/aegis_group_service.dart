import 'package:two_space_app/core/models/group.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';

class AegisGroupService {
  final AegisChatService _chat = AegisChatService();

  Future<GroupRoom> createGroupRoom({
    required String name,
    required GroupVisibility visibility,
    required bool showMessageHistory,
    String? description,
  }) {
    return _chat.createGroupRoom(
      name: name,
      description: description,
      visibility: visibility,
      showMessageHistory: showMessageHistory,
    );
  }

  Future<GroupRoom?> getGroupRoom(String roomId) async {
    await _chat.ensureReady();
    return _chat.getGroupRoom(roomId);
  }

  Future<void> setShowMessageHistory(String roomId, bool value) {
    return _chat.setShowMessageHistory(roomId, value);
  }

  Future<void> setUserRole(String roomId, String userId, GroupRole role) {
    return _chat.setUserRole(roomId, userId, role);
  }

  Future<void> freezeUser(
    String roomId,
    String userId,
    {Duration? duration, String? reason}
  ) {
    final until = duration == null ? null : DateTime.now().add(duration);
    return _chat.freezeUser(roomId, userId, until, reason);
  }

  Future<void> banUser(String roomId, String userId) {
    return _chat.banUser(roomId, userId);
  }

  Future<void> unbanUser(String roomId, String userId) {
    return _chat.unbanUser(roomId, userId);
  }

  Future<void> kickUser(String roomId, String userId) {
    return _chat.kickUser(roomId, userId);
  }

  Future<void> deleteGroup(String roomId) {
    return _chat.deleteGroup(roomId);
  }
}
