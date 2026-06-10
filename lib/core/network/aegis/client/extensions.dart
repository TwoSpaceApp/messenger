import 'package:two_space_app/core/network/aegis/message_payloads.dart';

extension ChannelMessageResponseCompat on ChannelMessageResponse {
  MediaSendResponse toMediaSendResponse() => MediaSendResponse(
    success: success,
    messageText: messageText,
  );
}

extension GroupMessageResponseCompat on GroupMessageSendResponse {
  MediaSendResponse toMediaSendResponse() => MediaSendResponse(
    success: success,
    messageId: messageId,
    messageText: message,
  );
}

extension PrivateMessageResponseCompat on PrivateChatMessageResponse {
  MediaSendResponse toMediaSendResponse() => MediaSendResponse(
    success: success,
    messageId: messageId,
    messageText: messageText,
  );
}

extension MediaSendResponseCompat on MediaSendResponse {
  PrivateChatMessageResponse toPrivateLike() => PrivateChatMessageResponse(
    success: success,
    messageId: messageId,
    messageText: messageText,
  );

  ChannelMessageResponse toChannelLike() => ChannelMessageResponse(
    success: success,
    messageId: messageId,
    messageText: messageText,
  );
}
