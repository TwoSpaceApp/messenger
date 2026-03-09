import 'package:two_space_app/features/chat/data/services/chat_backend.dart';
import 'package:two_space_app/features/chat/data/services/chat_service.dart';

ChatBackend createChatBackend({dynamic client}) {
  return AegisChatBackend(client: client);
}
