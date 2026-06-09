import 'dart:convert';
import 'dart:typed_data';

import 'package:two_space_app/core/network/aegis/client/aegis_client_base.dart';
import 'package:two_space_app/core/network/aegis/client/extensions.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';

mixin AegisMessagingMixin on AegisClientBase {

  Future<void> sendMessage(
    String content, {
    int toUserId = 0,
    ParseMode? parseMode,
  }) async {
    requireAuthenticated();
    final payloadBytes = utf8.encode(
      jsonEncode({
        'RecipientId': toUserId,
        'Content': content,
        if (parseMode != null) 'ParseMode': parseMode.value,
      }),
    );
    final msg = Message.withType(MessageType.message, payloadBytes);
    msg.sequenceId = nextSeqId++;
    await transport.sendMessage(msg);
  }

  Future<MediaSendResponse> sendGroupMessage(
    int groupId,
    String content, {
    MessageContentType contentType = MessageContentType.text,
    int? replyToMessageId,
    ParseMode? parseMode,
  }) async {
    requireAuthenticated();

    final request = GroupMessageSendRequest(
      groupId: groupId,
      content: content,
      contentType: contentType,
      replyToMessageId: replyToMessageId,
      parseMode: parseMode?.value,
    );

    final msg = Message.withType(
      MessageType.groupMessageSend,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.groupMessageResponse},
    );
    return GroupMessageSendResponse.fromBytes(
      response.payload,
    ).toMediaSendResponse();
  }

  Future<MediaSendResponse> sendGroupMarkdown(
    int groupId,
    String markdownText, {
    int? replyToMessageId,
  }) {
    return sendGroupMessage(
      groupId,
      markdownText,
      replyToMessageId: replyToMessageId,
      parseMode: ParseMode.markdown,
    );
  }

  Future<PrivateChatMessageResponse> sendPrivateMessage(
    int toUserId,
    String content, {
    MessageContentType contentType = MessageContentType.text,
    ParseMode? parseMode,
  }) async {
    requireAuthenticated();

    final request = PrivateChatMessageRequest(
      toUserId: toUserId,
      content: content,
      contentType: contentType,
      parseMode: parseMode?.value,
    );

    final msg = Message.withType(
      MessageType.privateChatMessage,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.privateChatMessage},
    );
    return PrivateChatMessageResponse.fromBytes(response.payload);
  }

  Future<PrivateChatMessageResponse> sendPrivatePhoto(
    int toUserId,
    Uint8List photoBytes, {
    String? caption,
    String fileName = 'photo.jpg',
    String mimeType = 'image/jpeg',
  }) async {
    final response = await sendMedia(
      chatType: ChatTargetType.private,
      chatId: toUserId,
      mediaBytes: photoBytes,
      mediaKind: MediaKind.photo,
      caption: caption,
      fileName: fileName,
      mimeType: mimeType,
    );
    return response.toPrivateLike();
  }

  Future<PrivateChatMessageResponse> sendPrivateFile(
    int toUserId,
    Uint8List fileBytes, {
    required String fileName,
    String? caption,
    String mimeType = 'application/octet-stream',
  }) async {
    final response = await sendMedia(
      chatType: ChatTargetType.private,
      chatId: toUserId,
      mediaBytes: fileBytes,
      mediaKind: MediaKind.file,
      caption: caption,
      fileName: fileName,
      mimeType: mimeType,
    );
    return response.toPrivateLike();
  }

  Future<PrivateChatMessageResponse> sendPrivateVoice(
    int toUserId,
    Uint8List voiceBytes, {
    String? caption,
    String fileName = 'voice.ogg',
    String mimeType = 'audio/ogg',
  }) async {
    final response = await sendMedia(
      chatType: ChatTargetType.private,
      chatId: toUserId,
      mediaBytes: voiceBytes,
      mediaKind: MediaKind.voice,
      caption: caption,
      fileName: fileName,
      mimeType: mimeType,
    );
    return response.toPrivateLike();
  }

  Future<ChatListResponse> getChatList() async {
    requireAuthenticated();

    final request = ChatListRequest();
    final msg = Message.withType(
      MessageType.chatListRequest,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.chatListResponse},
    );
    return ChatListResponse.fromBytes(response.payload);
  }

  Future<PrivateChatHistoryResponse> getPrivateHistory(
    int peerUserId, {
    int limit = 100,
    int? beforeMessageId,
  }) async {
    requireAuthenticated();

    final request = PrivateChatHistoryRequest(
      peerUserId: peerUserId,
      limit: limit,
      beforeMessageId: beforeMessageId,
    );

    final msg = Message.withType(
      MessageType.privateChatHistoryRequest,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.privateChatHistoryResponse},
    );
    return PrivateChatHistoryResponse.fromBytes(response.payload);
  }

  Future<ChannelHistoryResponse> getChannelHistory(
    int channelId, {
    int limit = 100,
    int? beforeMessageId,
  }) async {
    requireAuthenticated();

    final request = ChannelHistoryRequest(
      channelId: channelId,
      limit: limit,
      beforeMessageId: beforeMessageId,
    );

    final msg = Message.withType(
      MessageType.channelHistoryRequest,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelHistoryResponse},
    );
    return ChannelHistoryResponse.fromBytes(response.payload);
  }

  Future<GroupHistoryResponse> getGroupHistory(
    int groupId, {
    int limit = 100,
    int? beforeMessageId,
  }) async {
    requireAuthenticated();

    final request = GroupHistoryRequest(
      groupId: groupId,
      limit: limit,
      beforeMessageId: beforeMessageId,
    );

    final msg = Message.withType(
      MessageType.groupHistoryRequest,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.groupHistoryResponse},
    );
    return GroupHistoryResponse.fromBytes(response.payload);
  }

  Future<MediaSendResponse> sendMedia({
    required ChatTargetType chatType,
    required int chatId,
    required Uint8List mediaBytes,
    required MediaKind mediaKind,
    String? caption,
    ParseMode? parseMode,
    String? fileName,
    String? mimeType,
    int? replyToMessageId,
  }) async {
    final resolvedFileName =
        fileName ??
        switch (mediaKind) {
          MediaKind.photo => 'photo.jpg',
          MediaKind.video => 'video.mp4',
          MediaKind.gif => 'animation.gif',
          MediaKind.file => 'file.bin',
          MediaKind.voice => 'voice.ogg',
        };
    final resolvedMime =
        mimeType ??
        switch (mediaKind) {
          MediaKind.photo => 'image/jpeg',
          MediaKind.video => 'video/mp4',
          MediaKind.gif => 'image/gif',
          MediaKind.file => 'application/octet-stream',
          MediaKind.voice => 'audio/ogg',
        };
    final contentType = switch (mediaKind) {
      MediaKind.photo => MessageContentType.image,
      MediaKind.video => MessageContentType.video,
      MediaKind.gif => MessageContentType.image,
      MediaKind.file => MessageContentType.file,
      MediaKind.voice => MessageContentType.audio,
    };

    final attachment = MediaAttachmentPayload(
      fileName: resolvedFileName,
      mimeType: resolvedMime,
      base64Data: base64Encode(mediaBytes),
      sizeBytes: mediaBytes.length,
    );

    return sendMediaBatch(
      chatType: chatType,
      chatId: chatId,
      attachments: [attachment],
      caption: caption,
      parseMode: parseMode,
      replyToMessageId: replyToMessageId,
      forcedContentType: contentType,
    );
  }

  Future<MediaSendResponse> sendMediaBatch({
    required ChatTargetType chatType,
    required int chatId,
    required List<MediaAttachmentPayload> attachments,
    String? caption,
    ParseMode? parseMode,
    int? replyToMessageId,
    MessageContentType? forcedContentType,
  }) async {
    requireAuthenticated();

    if (attachments.isEmpty) {
      throw ArgumentError('attachments must not be empty');
    }

    if (attachments.length > 10) {
      throw ArgumentError('A maximum of 10 attachments is allowed per message');
    }

    final contentType =
        forcedContentType ?? _resolveBatchContentType(attachments);

    switch (chatType) {
      case ChatTargetType.private:
        final request = PrivateChatMessageRequest(
          toUserId: chatId,
          content: caption,
          contentType: contentType,
          attachment: attachments.first,
          attachments: attachments,
          parseMode: parseMode?.value,
        );
        final msg = Message.withType(
          MessageType.privateChatMessage,
          request.toBytes(),
        );
        final response = await sendAndWaitResponse(
          msg,
          expectedTypes: {MessageType.privateChatMessage},
        );
        return PrivateChatMessageResponse.fromBytes(
          response.payload,
        ).toMediaSendResponse();

      case ChatTargetType.channel:
        final request = ChannelMessageRequest(
          channelId: chatId,
          content: caption,
          contentType: contentType,
          replyToMessageId: replyToMessageId,
          attachment: attachments.first,
          attachments: attachments,
          parseMode: parseMode?.value,
        );
        final msg = Message.withType(
          MessageType.channelMessage,
          request.toBytes(),
        );
        final response = await sendAndWaitResponse(
          msg,
          expectedTypes: {MessageType.channelMessage},
        );
        return ChannelMessageResponse.fromBytes(
          response.payload,
        ).toMediaSendResponse();

      case ChatTargetType.group:
        final request = GroupMessageSendRequest(
          groupId: chatId,
          content: caption,
          contentType: contentType,
          replyToMessageId: replyToMessageId,
          attachment: attachments.first,
          attachments: attachments,
          parseMode: parseMode?.value,
        );
        final msg = Message.withType(
          MessageType.groupMessageSend,
          request.toBytes(),
        );
        final response = await sendAndWaitResponse(
          msg,
          expectedTypes: {MessageType.groupMessageResponse},
        );
        return GroupMessageSendResponse.fromBytes(
          response.payload,
        ).toMediaSendResponse();
    }
  }

  MessageContentType _resolveBatchContentType(
    List<MediaAttachmentPayload> attachments,
  ) {
    final mimes = attachments
        .map((item) => item.mimeType.toLowerCase())
        .toList(growable: false);

    if (mimes.every((mime) => mime.startsWith('image/'))) {
      return MessageContentType.image;
    }

    if (mimes.every((mime) => mime.startsWith('video/'))) {
      return MessageContentType.video;
    }

    if (mimes.every((mime) => mime.startsWith('audio/'))) {
      return MessageContentType.audio;
    }

    return MessageContentType.file;
  }

  Future<MediaSendResponse> sendFile({
    required ChatTargetType chatType,
    required int chatId,
    required Uint8List fileBytes,
    required String fileName,
    String mimeType = 'application/octet-stream',
    String? caption,
    ParseMode? parseMode,
    int? replyToMessageId,
  }) {
    return sendMedia(
      chatType: chatType,
      chatId: chatId,
      mediaBytes: fileBytes,
      mediaKind: MediaKind.file,
      fileName: fileName,
      mimeType: mimeType,
      caption: caption,
      parseMode: parseMode,
      replyToMessageId: replyToMessageId,
    );
  }

  Future<MediaSendResponse> sendVoiceMessage({
    required ChatTargetType chatType,
    required int chatId,
    required Uint8List voiceBytes,
    String fileName = 'voice.ogg',
    String mimeType = 'audio/ogg',
    String? caption,
    ParseMode? parseMode,
    int? replyToMessageId,
  }) {
    return sendMedia(
      chatType: chatType,
      chatId: chatId,
      mediaBytes: voiceBytes,
      mediaKind: MediaKind.voice,
      fileName: fileName,
      mimeType: mimeType,
      caption: caption,
      parseMode: parseMode,
      replyToMessageId: replyToMessageId,
    );
  }

  Future<PrivateChatMessageResponse> sendPrivateMarkdown(
    int toUserId,
    String markdownText,
  ) {
    return sendPrivateMessage(
      toUserId,
      markdownText,
      parseMode: ParseMode.markdown,
    );
  }
}
