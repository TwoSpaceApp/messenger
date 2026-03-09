import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';
import 'package:two_space_app/features/chat/data/services/chat_backend.dart';

export 'package:two_space_app/core/models/chat.dart';

/// Aegis-backed chat backend used by profile and navigation flows.
class AegisChatBackend implements ChatBackend {
  AegisChatBackend({this.client});
  final dynamic client;
  final AegisChatService _chat = AegisChatService();

  @override
  Future<List<Chat>> loadChats() async {
    return _chat.getChats();
  }

  @override
  Future<Map<String, dynamic>> getOrCreateFavoritesChat(String userId) async {
    return {
      'id': 'favorites:$userId',
      'name': 'Избранное',
      'members': [userId]
    };
  }

  @override
  Future<Map<String, dynamic>> getOrCreateDirectChat(String otherUserId) async {
    final chat = await _chat.getOrCreateDirectChat(otherUserId);
    return chat.toMap();
  }
}
