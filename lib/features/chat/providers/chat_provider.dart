import 'package:riverpod/riverpod.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';

final chatService = Provider((ref) => AegisChatService());

// Get all joined rooms/chats
final joinedChatsProvider = FutureProvider<List<Chat>>((ref) async {
  final service = ref.watch(chatService);
  final roomIds = await service.getJoinedRooms();

  // Fetch all room metadata in parallel instead of sequentially.
  final results = await Future.wait(
    roomIds.map((id) async {
      try {
        final meta = await service.getRoomNameAndAvatar(id);
        return Chat(
          id: id,
          name: meta['name'] ?? id,
          avatarUrl: meta['avatar'],
          members: [],
        );
      } catch (e) {
        return null;
      }
    }),
  );

  return results.whereType<Chat>().toList();
});

// Get specific chat by ID
final chatByIdProvider =
    FutureProvider.family<Chat?, String>((ref, chatId) async {
  final service = ref.watch(chatService);
  try {
    final meta = await service.getRoomNameAndAvatar(chatId);
    return Chat(
      id: chatId,
      name: meta['name'] ?? chatId,
      avatarUrl: meta['avatar'],
      members: [],
    );
  } catch (e) {
    return null;
  }
});

// Messages for a specific chat
final chatMessagesProvider =
    FutureProvider.family<List<dynamic>, String>((ref, chatId) async {
  final service = ref.watch(chatService);
  return service.loadMessages(roomId: chatId);
});

// Room members provider
final roomMembersProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, roomId) async {
  final service = ref.watch(chatService);
  return service.getRoomMembers(roomId);
});
