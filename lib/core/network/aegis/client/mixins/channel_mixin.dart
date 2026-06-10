import 'dart:convert';
import 'dart:typed_data';

import 'package:two_space_app/core/network/aegis/client/aegis_client_base.dart';
import 'package:two_space_app/core/network/aegis/client/extensions.dart';
import 'package:two_space_app/core/network/aegis/client/mixins/messaging_mixin.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';

mixin AegisChannelMixin on AegisClientBase, AegisMessagingMixin {

  Future<ChannelMessageResponse> sendChannelMessage(
    int channelId,
    String content, {
    MessageContentType contentType = MessageContentType.text,
    int? replyToMessageId,
    ParseMode? parseMode,
  }) async {
    requireAuthenticated();

    final request = ChannelMessageRequest(
      channelId: channelId,
      content: content,
      contentType: contentType,
      replyToMessageId: replyToMessageId,
      parseMode: parseMode?.value,
    );

    final msg = Message.withType(MessageType.channelMessage, request.toBytes());
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelMessage},
    );
    return ChannelMessageResponse.fromBytes(response.payload);
  }

  Future<ChannelMessageResponse> sendChannelPhoto(
    int channelId,
    Uint8List photoBytes, {
    String? caption,
    String fileName = 'photo.jpg',
    String mimeType = 'image/jpeg',
    int? replyToMessageId,
  }) async {
    final response = await sendMedia(
      chatType: ChatTargetType.channel,
      chatId: channelId,
      mediaBytes: photoBytes,
      mediaKind: MediaKind.photo,
      caption: caption,
      fileName: fileName,
      mimeType: mimeType,
      replyToMessageId: replyToMessageId,
    );
    return response.toChannelLike();
  }

  Future<ChannelMessageResponse> sendChannelFile(
    int channelId,
    Uint8List fileBytes, {
    required String fileName,
    String? caption,
    String mimeType = 'application/octet-stream',
    int? replyToMessageId,
  }) async {
    final response = await sendMedia(
      chatType: ChatTargetType.channel,
      chatId: channelId,
      mediaBytes: fileBytes,
      mediaKind: MediaKind.file,
      caption: caption,
      fileName: fileName,
      mimeType: mimeType,
      replyToMessageId: replyToMessageId,
    );
    return response.toChannelLike();
  }

  Future<ChannelMessageResponse> sendChannelVoice(
    int channelId,
    Uint8List voiceBytes, {
    String? caption,
    String fileName = 'voice.ogg',
    String mimeType = 'audio/ogg',
    int? replyToMessageId,
  }) async {
    final response = await sendMedia(
      chatType: ChatTargetType.channel,
      chatId: channelId,
      mediaBytes: voiceBytes,
      mediaKind: MediaKind.voice,
      caption: caption,
      fileName: fileName,
      mimeType: mimeType,
      replyToMessageId: replyToMessageId,
    );
    return response.toChannelLike();
  }

  Future<ChannelMessageResponse> sendChannelMarkdown(
    int channelId,
    String markdownText, {
    int? replyToMessageId,
  }) {
    return sendChannelMessage(
      channelId,
      markdownText,
      replyToMessageId: replyToMessageId,
      parseMode: ParseMode.markdown,
    );
  }

  Future<ChannelCreateResponse> createChannel(
    String name, {
    String? description,
    ChannelType type = ChannelType.public,
  }) async {
    requireAuthenticated();

    final request = ChannelCreateRequest(
      name: name,
      description: description,
      type: type,
    );

    final msg = Message.withType(MessageType.channelCreate, request.toBytes());
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelCreate},
    );
    return ChannelCreateResponse.fromBytes(response.payload);
  }

  Future<ChannelJoinResponse> joinChannel(int channelId) async {
    requireAuthenticated();

    final request = ChannelJoinRequest(channelId: channelId);
    final msg = Message.withType(MessageType.channelJoin, request.toBytes());
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelJoin},
    );
    return ChannelJoinResponse.fromBytes(response.payload);
  }

  Future<ChannelEditResponse> updateChannel(
    int channelId, {
    String? name,
    String? description,
    String? avatarUrl,
  }) async {
    requireAuthenticated();

    final request = ChannelEditRequest(
      channelId: channelId,
      name: name,
      description: description,
      avatarUrl: avatarUrl,
    );

    final msg = Message.withType(MessageType.channelEdit, request.toBytes());
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelEditResponse},
    );
    return ChannelEditResponse.fromBytes(response.payload);
  }

  Future<ChannelEditResponse> uploadChannelAvatar(
    int channelId,
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    final dataUrl = 'data:$mimeType;base64,${base64Encode(imageBytes)}';
    return updateChannel(channelId, avatarUrl: dataUrl);
  }

  Future<ChannelMembersResponse> getChannelMembers(int channelId) async {
    requireAuthenticated();

    final request = ChannelMembersRequest(channelId: channelId);
    final msg = Message.withType(
      MessageType.channelMembersRequest,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelMembersResponse},
    );
    return ChannelMembersResponse.fromBytes(response.payload);
  }

  Future<ChannelLeaveResponse> leaveChannel(int channelId) async {
    requireAuthenticated();

    final request = ChannelLeaveRequest(channelId: channelId);
    final msg = Message.withType(
      MessageType.channelLeave,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelLeave},
    );
    return ChannelLeaveResponse.fromBytes(response.payload);
  }

  Future<ChannelLinkResponse> updateChannelLinks(
    int channelId, {
    String? publicAlias,
    bool regeneratePrivateInvite = false,
  }) async {
    requireAuthenticated();
    final request = ChannelLinkUpdateRequest(
      channelId: channelId,
      publicAlias: publicAlias,
      regeneratePrivateInvite: regeneratePrivateInvite,
    );
    final msg = Message.withType(
      MessageType.channelLinkUpdate,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelLinkUpdateResponse},
    );
    return ChannelLinkResponse.fromBytes(response.payload);
  }

  Future<ChannelLinkResponse> getChannelLinks(int channelId) async {
    requireAuthenticated();
    final request = ChannelLinkRequest(channelId: channelId);
    final msg = Message.withType(MessageType.channelLinkGet, request.toBytes());
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelLinkGetResponse},
    );
    return ChannelLinkResponse.fromBytes(response.payload);
  }

  Future<ChannelResolveResponse> resolveChannelLink(String linkOrAlias) async {
    requireAuthenticated();
    final request = ChannelResolveRequest(linkOrAlias: linkOrAlias);
    final msg = Message.withType(MessageType.channelResolve, request.toBytes());
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelResolveResponse},
    );
    return ChannelResolveResponse.fromBytes(response.payload);
  }

  Future<ChannelJoinResponse> joinChannelByLink(String linkOrAlias) async {
    requireAuthenticated();
    final request = ChannelResolveRequest(linkOrAlias: linkOrAlias);
    final msg = Message.withType(
      MessageType.channelJoinByLink,
      request.toBytes(),
    );
    final response = await sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelJoinByLinkResponse},
    );
    return ChannelJoinResponse.fromBytes(response.payload);
  }
}
