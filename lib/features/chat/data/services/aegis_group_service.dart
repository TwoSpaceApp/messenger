import 'package:two_space_app/core/models/group.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';

class AegisGroupService {
  final AegisChatService _chat = AegisChatService();

  Future<GroupRoom> createGroupRoom({
    required String name,
    required GroupVisibility visibility,
    required bool showMessageHistory,
    String? description,
    List<int>? avatarBytes,
    String? avatarFileName,
  }) {
    return _chat.createGroupRoom(
      name: name,
      description: description,
      visibility: visibility,
      showMessageHistory: showMessageHistory,
      avatarBytes: avatarBytes,
      avatarFileName: avatarFileName,
    );
  }

  Future<GroupRoom?> getGroupRoom(String roomId) async {
    await _chat.ensureReady();
    return _chat.loadGroupRoom(roomId);
  }

  Future<void> setShowMessageHistory(String roomId, bool value) {
    return _chat.setShowMessageHistory(roomId, value);
  }

  Future<Map<String, dynamic>> getRoomSettingsState(String roomId) {
    return _chat.getRoomSettingsState(roomId);
  }

  Future<void> setJoinRuleValue(String roomId, int joinRule) {
    return _chat.setJoinRuleValue(roomId, joinRule);
  }

  Future<void> setHistoryVisibility(String roomId, int historyVisibility) {
    return _chat.setHistoryVisibility(roomId, historyVisibility);
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
