import 'package:riverpod/riverpod.dart';
import 'package:riverpod/misc.dart';
import 'package:two_space_app/core/models/chat.dart';
import 'package:two_space_app/features/chat/data/services/aegis_chat_service.dart';

const _roomMetadataBatchSize = 6;

Future<List<T>> _mapInBatches<S, T>(
  Iterable<S> items,
  Future<T> Function(S item) mapper,
) async {
  final source = items.toList(growable: false);
  final results = <T>[];
  for (var index = 0; index < source.length; index += _roomMetadataBatchSize) {
    final end = index + _roomMetadataBatchSize < source.length
        ? index + _roomMetadataBatchSize
        : source.length;
    final batch = source.sublist(index, end);
    results.addAll(await Future.wait(batch.map(mapper)));
  }
  return results;
}

final Provider<AegisChatService> chatService = Provider(
  (ref) => AegisChatService(),
);

final joinedChatsProvider = FutureProvider<List<Chat>>((ref) async {
  final service = ref.watch(chatService);
  final roomIds = await service.getJoinedRooms();

  final results = await _mapInBatches<String, Chat?>(
    roomIds,
    (id) async {
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
    },
  );

  return results.whereType<Chat>().toList();
});

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

final FutureProviderFamily<List<dynamic>, String> chatMessagesProvider =
    FutureProvider.family<List<dynamic>, String>((
      ref,
      chatId,
    ) async {
      final service = ref.watch(chatService);
      return service.loadMessages(roomId: chatId);
    });

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

class ChatNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> sendMessage(String roomId, String message) async {
    final service = ref.watch(chatService);
    await service.sendMessage(roomId: roomId, text: message);
    ref.invalidate(chatMessagesProvider(roomId));
    ref.invalidate(chatByIdProvider(roomId));
    ref.invalidate(joinedChatsProvider);
  }
}

final chatNotifierProvider = NotifierProvider<ChatNotifier, void>(
  ChatNotifier.new,
);

final FutureProvider<List<Chat>> chatListProvider = joinedChatsProvider;
final FutureProviderFamily<Chat?, String> getChatProvider = chatByIdProvider;
