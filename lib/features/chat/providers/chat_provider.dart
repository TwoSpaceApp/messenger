import 'package:riverpod/riverpod.dart';
import 'package:riverpod/src/providers/future_provider.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';

final Provider<AegisChatService> chatService = Provider(
  (ref) => AegisChatService(),
);

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
      } on Object catch (_) {
        return null;
      }
    }),
  );

  return results.whereType<Chat>().toList();
});

// Get specific chat by ID
final FutureProviderFamily<Chat?, String> chatByIdProvider =
    FutureProvider.family<Chat?, String>((
      ref,
      chatId,
    ) async {
      final service = ref.watch(chatService);
      try {
        final meta = await service.getRoomNameAndAvatar(chatId);
        return Chat(
          id: chatId,
          name: meta['name'] ?? chatId,
          avatarUrl: meta['avatar'],
          members: [],
        );
      } on Object catch (_) {
        return null;
      }
    });

// Messages for a specific chat
final FutureProviderFamily<List<dynamic>, String> chatMessagesProvider =
    FutureProvider.family<List<dynamic>, String>((
      ref,
      chatId,
    ) async {
      final service = ref.watch(chatService);
      return service.loadMessages(roomId: chatId);
    });

// Room members provider
final FutureProviderFamily<List<Map<String, dynamic>>, String>
roomMembersProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (
    ref,
    roomId,
  ) async {
    final service = ref.watch(chatService);
    return service.getRoomMembers(roomId);
  },
);

// Chat notifier for handling message sending and chat actions
class ChatNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> sendMessage(String roomId, String message) async {
    final service = ref.watch(chatService);
    try {
      await service.sendMessage(roomId: roomId, text: message);
      // Invalidate cache to refresh messages
      ref.invalidate(chatMessagesProvider(roomId));
    } on Object catch (e) {
      print('Error sending message: $e');
    }
  }
}

final chatNotifierProvider = NotifierProvider<ChatNotifier, void>(
  ChatNotifier.new,
);

// Alias for backward compatibility with screen imports
final FutureProvider<List<Chat>> chatListProvider = joinedChatsProvider;
final FutureProviderFamily<Chat?, String> getChatProvider = chatByIdProvider;
