import 'package:two_space_app/features/chat/data/services/chat_service.dart';
import 'package:two_space_app/features/chat/data/services/chat_backend.dart';

ChatBackend createChatBackend({dynamic client}) {
  return MatrixChatBackend(client: client);
}
