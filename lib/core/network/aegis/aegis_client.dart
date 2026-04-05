import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/event_dispatcher.dart';
import 'package:two_space_app/core/network/aegis/exceptions.dart';
import 'package:two_space_app/core/network/aegis/handshake_crypto.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';
import 'package:two_space_app/core/network/aegis/official_api_credentials.dart';
import 'package:two_space_app/core/network/aegis/protocol_constants.dart';
import 'package:two_space_app/core/network/aegis/session_crypto.dart';
import 'package:two_space_app/core/network/aegis/transport.dart';

bool _isAppCredentialHandshakeError(Object error) {
  final text = error.toString().toLowerCase();
  return text.contains('app credentials required') ||
      text.contains('invalid app credentials');
}

bool _isOfficialApiCredentials(AegisApiCredentials? credentials) {
  if (credentials == null) {
    return false;
  }

  const official = AegisOfficialApiCredentials.credentials;
  return credentials.appId == official.appId &&
      credentials.appHash == official.appHash;
}

bool _isLocalV2HandshakeUnsupportedError(Object error) {
  return error is UnimplementedError || error is UnsupportedError;
}

extension _ChannelMessageResponseCompat on ChannelMessageResponse {
  MediaSendResponse toMediaSendResponse() => MediaSendResponse(
    success: success,
    messageText: messageText,
  );
}

extension _GroupMessageResponseCompat on GroupMessageSendResponse {
  MediaSendResponse toMediaSendResponse() => MediaSendResponse(
    success: success,
    messageId: messageId,
    messageText: message,
  );
}

extension _PrivateMessageResponseCompat on PrivateChatMessageResponse {
  MediaSendResponse toMediaSendResponse() => MediaSendResponse(
    success: success,
    messageId: messageId,
    messageText: messageText,
  );
}

extension _MediaSendResponseCompat on MediaSendResponse {
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

/// Main Aegis client class
class AegisClient {
  late AegisTransport _transport;
  bool _isAuthenticated = false;
  int? _userId;
  String? _username;
  String? _sessionToken;
  late final AegisEventDispatcher events;
  late final AegisChannelFacade channels;
  late final AegisGroupFacade groups;
  late final AegisDirectFacade direct;
  final AegisApiCredentials? _apiCredentials;

  // Per-client sequence-ID counter so responses can be matched unambiguously.
  int _nextSeqId = 1;

  /// Stream of incoming messages (unsolicited pushes from the server)
  Stream<Message> get messages => _transport.messages;

  /// Typed stream of incoming private message events.
  Stream<PrivateChatMessageEvent> get privateMessageEvents =>
      events.privateMessageEvents;

  /// Typed stream of incoming channel message events.
  Stream<ChannelMessageEvent> get channelMessageEvents =>
      events.channelMessageEvents;

  /// Typed stream of incoming async delivery/read status events.
  Stream<MessageStatusEvent> get messageStatusEvents =>
      events.messageStatusEvents;

  /// Typed stream of incoming group message events.
  Stream<GroupMessageEvent> get groupMessageEvents => events.groupMessageEvents;

  /// Typed stream of incoming group history responses.
  Stream<GroupHistoryResponse> get groupHistoryResponses =>
      events.groupHistoryResponses;

  /// Typed stream of incoming message reaction events.
  Stream<MessageReactionEvent> get messageReactionEvents =>
      events.messageReactionEvents;

  /// Typed stream of incoming message pin events.
  Stream<MessagePinEvent> get messagePinEvents => events.messagePinEvents;

  /// Stream of disconnect events
  Stream<void> get disconnects => _transport.disconnects;

  /// Whether this client is currently connected
  bool get isConnected => _transport.isConnected;

  /// Whether this client has completed authentication
  bool get isAuthenticated => _isAuthenticated;

  /// The authenticated user's ID, available after [login] or [loginWithToken]
  int? get userId => _userId;

  /// The authenticated user's username, available after [login] or [loginWithToken]
  String? get username => _username;

  /// The authenticated session token returned by the server.
  String? get sessionToken => _sessionToken;

  /// The app credentials that will be sent during handshake.
  ///
  /// When null, the client will not include `AppId` / `AppHash` in the
  /// handshake payload.
  AegisApiCredentials? get apiCredentials => _apiCredentials;

  /// Create a new Aegis client.
  ///
  /// By default the first-party official app credentials are attached to the
  /// handshake so the client works against servers with
  /// `RequireAppCredentials=true`.
  AegisClient({
    bool useOfficialApiCredentials = true,
    AegisApiCredentials? apiCredentials,
  }) : _apiCredentials =
           apiCredentials ??
           (useOfficialApiCredentials
               ? AegisOfficialApiCredentials.credentials
               : null) {
    _transport = AegisTransport();
    events = AegisEventDispatcher(_transport.messages);
    channels = AegisChannelFacade._(this);
    groups = AegisGroupFacade._(this);
    direct = AegisDirectFacade._(this);
  }

  /// Create a client that explicitly uses the built-in official credentials.
  AegisClient.official() : this();

  /// Create a client that uses a custom app credential pair.
  AegisClient.withApiCredentials(AegisApiCredentials apiCredentials)
    : this(useOfficialApiCredentials: false, apiCredentials: apiCredentials);

  /// Create a client that does not send app credentials in the handshake.
  ///
  /// This only works against servers that do not enforce app credentials.
  AegisClient.withoutApiCredentials() : this(useOfficialApiCredentials: false);

  // ─── Connection ────────────────────────────────────────────────────────────

  /// Connect to the Aegis server and complete the protocol handshake.
  Future<void> connect(
    String host,
    int port, {
    Duration? timeout,
    String? transportMaskingKey,
    bool useTls = false,
    bool enableMaskingAutoFallback = true,
    bool allowLegacyHandshakeFallback = false,
    String? trustedServerHandshakeSigningPublicKeyBase64,
    bool requireSignedHandshake = false,
  }) async {
    final hasMaskingKey =
        transportMaskingKey != null && transportMaskingKey.trim().isNotEmpty;
    const officialApiCredentials = AegisOfficialApiCredentials.credentials;

    Future<void> connectAndHandshake({
      required bool useMaskedTransport,
      required AegisApiCredentials? handshakeCredentials,
    }) async {
      await _transport.connect(
        host,
        port,
        timeout: timeout,
        transportMaskingKey: useMaskedTransport ? transportMaskingKey : null,
        useTls: useTls,
      );
      await _performHandshake(
        allowLegacyHandshakeFallback: allowLegacyHandshakeFallback,
        apiCredentials: handshakeCredentials,
        trustedServerHandshakeSigningPublicKeyBase64:
            trustedServerHandshakeSigningPublicKeyBase64,
        requireSignedHandshake: requireSignedHandshake,
      );
    }

    Future<bool> tryOfficialCredentialFallback({
      required Object error,
      required bool useMaskedTransport,
      required AegisApiCredentials? attemptedCredentials,
    }) async {
      if (!_isAppCredentialHandshakeError(error) ||
          _isOfficialApiCredentials(attemptedCredentials)) {
        return false;
      }

      await _transport.disconnect();
      await connectAndHandshake(
        useMaskedTransport: useMaskedTransport,
        handshakeCredentials: officialApiCredentials,
      );
      return true;
    }

    if (!hasMaskingKey || !enableMaskingAutoFallback) {
      try {
        await connectAndHandshake(
          useMaskedTransport: hasMaskingKey,
          handshakeCredentials: _apiCredentials,
        );
      } on Object catch (error) {
        final recovered = await tryOfficialCredentialFallback(
          error: error,
          useMaskedTransport: hasMaskingKey,
          attemptedCredentials: _apiCredentials,
        );
        if (!recovered) {
          rethrow;
        }
      }
      return;
    }

    try {
      await connectAndHandshake(
        useMaskedTransport: true,
        handshakeCredentials: _apiCredentials,
      );
    } on Object catch (firstError) {
      final recovered = await tryOfficialCredentialFallback(
        error: firstError,
        useMaskedTransport: true,
        attemptedCredentials: _apiCredentials,
      );
      if (recovered) {
        return;
      }

      await _transport.disconnect();

      // Server explicitly rejected credentials on masked transport.
      // Falling back to plain TCP adds noise (usually timeout) and hides root cause.
      if (firstError.toString().toLowerCase().contains(
        'app credentials required',
      )) {
        rethrow;
      }

      try {
        await connectAndHandshake(
          useMaskedTransport: false,
          handshakeCredentials: _apiCredentials,
        );
      } on Object catch (secondError) {
        final recovered = await tryOfficialCredentialFallback(
          error: secondError,
          useMaskedTransport: false,
          attemptedCredentials: _apiCredentials,
        );
        if (recovered) {
          return;
        }

        throw Exception(
          'Failed connect with masking and fallback. maskedError: $firstError; plainError: $secondError',
        );
      }
    }
  }

  /// Disconnect from the server.
  Future<void> disconnect() async {
    if (_transport.isConnected && _isAuthenticated) {
      await _publishPresence(isOnline: false);
    }

    await _transport.disconnect();
    _isAuthenticated = false;
    _userId = null;
    _username = null;
    _sessionToken = null;
  }

  /// Release all resources.
  void dispose() {
    events.dispose().ignore();
    _transport.dispose();
  }

  // ─── Authentication ─────────────────────────────────────────────────────────

  /// Authenticate with username and password.
  ///
  /// Throws [NotConnectedException] if not connected.
  /// Throws an [Exception] if authentication fails.
  Future<void> login(
    String username,
    String password, {
    String clientInfo = 'aegis-dart-client',
    String? twoFactorCode,
    String? recoveryPhrase,
  }) async {
    _requireConnected();
    final payload = msgpack.serialize({
      'Username': username,
      'Password': password,
      'ClientInfo': clientInfo,
      ...?twoFactorCode == null
          ? null
          : <String, String>{'TwoFactorCode': twoFactorCode},
      ...?recoveryPhrase == null
          ? null
          : <String, String>{'RecoveryPhrase': recoveryPhrase},
    });
    await _doAuthenticate(payload);
  }

  /// Re-authenticate with a previously issued session token.
  Future<void> loginWithToken(String token) async {
    _requireConnected();
    final payload = msgpack.serialize({
      'Token': token,
      'ClientInfo': 'aegis-dart-client',
    });
    await _doAuthenticate(payload);
  }

  /// Low-level authenticate: accepts either a raw JSON string or a token.
  ///
  /// Prefer [login] / [loginWithToken] for clarity.
  Future<void> authenticate(dynamic authPayloadOrToken) async {
    _requireConnected();
    List<int> payload;
    if (authPayloadOrToken is List<int>) {
      payload = authPayloadOrToken;
    } else if (authPayloadOrToken is String &&
        authPayloadOrToken.trim().startsWith('{')) {
      payload = msgpack.serialize(jsonDecode(authPayloadOrToken));
    } else {
      payload = msgpack.serialize({
        'Token': authPayloadOrToken,
        'ClientInfo': 'aegis-dart-client',
      });
    }
    await _doAuthenticate(payload);
  }

  Future<void> _doAuthenticate(List<int> payload) async {
    final msg = Message.withType(MessageType.auth, payload);
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.auth, MessageType.ack},
    );

    final authResponse = AuthResponse.fromBytes(response.payload);
    if (!authResponse.success) {
      final error = authResponse.error;
      throw Exception(
        'Authentication failed${error != null && error.isNotEmpty ? ': $error' : ''}',
      );
    }

    _isAuthenticated = true;
    _userId = authResponse.userId;
    _username = authResponse.username;
    _sessionToken = authResponse.sessionToken;

    await _publishPresence(isOnline: true);
  }

  /// Authenticate with username and password, returning authentication details.
  Future<AuthResponse> authenticateWithPassword({
    required String username,
    required String password,
    String clientInfo = 'aegis-dart-client',
    String? twoFactorCode,
    String? recoveryPhrase,
  }) async {
    _requireConnected();
    final payload = msgpack.serialize({
      'Username': username,
      'Password': password,
      'ClientInfo': clientInfo,
      ...?twoFactorCode == null
          ? null
          : <String, String>{'TwoFactorCode': twoFactorCode},
      ...?recoveryPhrase == null
          ? null
          : <String, String>{'RecoveryPhrase': recoveryPhrase},
    });
    final msg = Message.withType(MessageType.auth, payload);
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.auth, MessageType.ack},
    );

    final authResponse = AuthResponse.fromBytes(response.payload);
    if (!authResponse.success) {
      final error = authResponse.error;
      throw Exception(
        'Authentication failed${error != null && error.isNotEmpty ? ': $error' : ''}',
      );
    }

    _isAuthenticated = true;
    _userId = authResponse.userId;
    _username = authResponse.username;
    _sessionToken = authResponse.sessionToken;

    await _publishPresence(isOnline: true);

    return AuthResponse(
      success: authResponse.success,
      userId: authResponse.userId,
      username: authResponse.username,
      sessionToken: authResponse.sessionToken,
      error: authResponse.error,
    );
  }

  // ─── Registration ───────────────────────────────────────────────────────────

  /// Register a new account on the server.
  Future<RegistrationResponse> register(
    String username,
    String email,
    String password,
    String publicKey,
  ) async {
    _requireConnected();

    final request = RegistrationRequest(
      username: username,
      email: email,
      password: password,
      publicKey: publicKey,
    );

    final msg = Message.withType(MessageType.register, request.toBytes());
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.registerResponse},
    );
    return RegistrationResponse.fromBytes(response.payload);
  }

  // ─── Messaging ──────────────────────────────────────────────────────────────

  /// Send a direct message using the legacy binary-free JSON format (type 3).
  ///
  /// For proper private messaging prefer [sendPrivateMessage].
  Future<void> sendMessage(
    String content, {
    int toUserId = 0,
    ParseMode? parseMode,
  }) async {
    _requireAuthenticated();
    final payloadBytes = utf8.encode(
      jsonEncode({
        'RecipientId': toUserId,
        'Content': content,
        if (parseMode != null) 'ParseMode': parseMode.value,
      }),
    );
    final msg = Message.withType(MessageType.message, payloadBytes);
    msg.sequenceId = _nextSeqId++;
    await _transport.sendMessage(msg);
  }

  /// Send a plain text message to a group.
  Future<MediaSendResponse> sendGroupMessage(
    int groupId,
    String content, {
    MessageContentType contentType = MessageContentType.text,
    int? replyToMessageId,
    ParseMode? parseMode,
  }) async {
    _requireAuthenticated();

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
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.groupMessageResponse},
    );
    return GroupMessageSendResponse.fromBytes(
      response.payload,
    ).toMediaSendResponse();
  }

  /// Send a Markdown-formatted message to a group.
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

  /// Send a private chat message to another user (type 17).
  Future<PrivateChatMessageResponse> sendPrivateMessage(
    int toUserId,
    String content, {
    MessageContentType contentType = MessageContentType.text,
    ParseMode? parseMode,
  }) async {
    _requireAuthenticated();

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
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.privateChatMessage},
    );
    return PrivateChatMessageResponse.fromBytes(response.payload);
  }

  /// Send a photo to a private chat.
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

  /// Send a file to a private chat.
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

  /// Send a voice message to a private chat.
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

  /// Get all chats for the authenticated user.
  Future<ChatListResponse> getChatList() async {
    _requireAuthenticated();

    final request = ChatListRequest();
    final msg = Message.withType(
      MessageType.chatListRequest,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.chatListResponse},
    );
    return ChatListResponse.fromBytes(response.payload);
  }

  /// Get private chat history with a peer.
  Future<PrivateChatHistoryResponse> getPrivateHistory(
    int peerUserId, {
    int limit = 100,
    int? beforeMessageId,
  }) async {
    _requireAuthenticated();

    final request = PrivateChatHistoryRequest(
      peerUserId: peerUserId,
      limit: limit,
      beforeMessageId: beforeMessageId,
    );

    final msg = Message.withType(
      MessageType.privateChatHistoryRequest,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.privateChatHistoryResponse},
    );
    return PrivateChatHistoryResponse.fromBytes(response.payload);
  }

  /// Get channel history.
  Future<ChannelHistoryResponse> getChannelHistory(
    int channelId, {
    int limit = 100,
    int? beforeMessageId,
  }) async {
    _requireAuthenticated();

    final request = ChannelHistoryRequest(
      channelId: channelId,
      limit: limit,
      beforeMessageId: beforeMessageId,
    );

    final msg = Message.withType(
      MessageType.channelHistoryRequest,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelHistoryResponse},
    );
    return ChannelHistoryResponse.fromBytes(response.payload);
  }

  /// Register a callback for private message events.
  StreamSubscription<PrivateChatMessageEvent> onPrivateMessageEvent(
    void Function(PrivateChatMessageEvent event) handler,
  ) {
    return privateMessageEvents.listen(handler);
  }

  /// Register a callback for channel message events.
  StreamSubscription<ChannelMessageEvent> onChannelMessageEvent(
    void Function(ChannelMessageEvent event) handler,
  ) {
    return channelMessageEvents.listen(handler);
  }

  StreamSubscription<MessageStatusEvent> onMessageStatusEvent(
    void Function(MessageStatusEvent event) handler,
  ) {
    return messageStatusEvents.listen(handler);
  }

  StreamSubscription<GroupMessageEvent> onGroupMessageEvent(
    void Function(GroupMessageEvent event) handler,
  ) {
    return groupMessageEvents.listen(handler);
  }

  StreamSubscription<GroupHistoryResponse> onGroupHistoryResponse(
    void Function(GroupHistoryResponse response) handler,
  ) {
    return groupHistoryResponses.listen(handler);
  }

  StreamSubscription<MessageReactionEvent> onMessageReactionEvent(
    void Function(MessageReactionEvent event) handler,
  ) {
    return messageReactionEvents.listen(handler);
  }

  StreamSubscription<MessagePinEvent> onMessagePinEvent(
    void Function(MessagePinEvent event) handler,
  ) {
    return messagePinEvents.listen(handler);
  }

  // ─── Channels ───────────────────────────────────────────────────────────────

  /// Send a message to a channel.
  Future<ChannelMessageResponse> sendChannelMessage(
    int channelId,
    String content, {
    MessageContentType contentType = MessageContentType.text,
    int? replyToMessageId,
    ParseMode? parseMode,
  }) async {
    _requireAuthenticated();

    final request = ChannelMessageRequest(
      channelId: channelId,
      content: content,
      contentType: contentType,
      replyToMessageId: replyToMessageId,
      parseMode: parseMode?.value,
    );

    final msg = Message.withType(MessageType.channelMessage, request.toBytes());
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelMessage},
    );
    return ChannelMessageResponse.fromBytes(response.payload);
  }

  /// Send a photo to a channel.
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

  /// Send a file to a channel.
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

  /// Send a voice message to a channel.
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

  /// Unified media sending for private chats, channels and groups.
  ///
  /// `chatType`:
  /// - [ChatTargetType.private] -> `chatId` is `toUserId`
  /// - [ChatTargetType.channel] -> `chatId` is `channelId`
  /// - [ChatTargetType.group] -> `chatId` is `groupId`
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

  /// Send up to 10 mixed attachments in a single message (images/files/audio/video/etc).
  Future<MediaSendResponse> sendMediaBatch({
    required ChatTargetType chatType,
    required int chatId,
    required List<MediaAttachmentPayload> attachments,
    String? caption,
    ParseMode? parseMode,
    int? replyToMessageId,
    MessageContentType? forcedContentType,
  }) async {
    _requireAuthenticated();

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
        final response = await _sendAndWaitResponse(
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
        final response = await _sendAndWaitResponse(
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
        final response = await _sendAndWaitResponse(
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

  /// Unified file sending helper built on top of [sendMedia].
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

  /// Unified voice message helper built on top of [sendMedia].
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

  /// Convenience helper for Markdown-formatted private text messages.
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

  /// Convenience helper for Markdown-formatted channel text messages.
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

  /// Create a new channel.
  Future<ChannelCreateResponse> createChannel(
    String name, {
    String? description,
    ChannelType type = ChannelType.public,
  }) async {
    _requireAuthenticated();

    final request = ChannelCreateRequest(
      name: name,
      description: description,
      type: type,
    );

    final msg = Message.withType(MessageType.channelCreate, request.toBytes());
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelCreate},
    );
    return ChannelCreateResponse.fromBytes(response.payload);
  }

  /// Join an existing public channel.
  Future<ChannelJoinResponse> joinChannel(int channelId) async {
    _requireAuthenticated();

    final request = ChannelJoinRequest(channelId: channelId);
    final msg = Message.withType(MessageType.channelJoin, request.toBytes());
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelJoin},
    );
    return ChannelJoinResponse.fromBytes(response.payload);
  }

  /// Edit channel properties (name, description, avatar URL).
  Future<ChannelEditResponse> updateChannel(
    int channelId, {
    String? name,
    String? description,
    String? avatarUrl,
  }) async {
    _requireAuthenticated();

    final request = ChannelEditRequest(
      channelId: channelId,
      name: name,
      description: description,
      avatarUrl: avatarUrl,
    );

    final msg = Message.withType(MessageType.channelEdit, request.toBytes());
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelEditResponse},
    );
    return ChannelEditResponse.fromBytes(response.payload);
  }

  /// Upload a channel avatar from raw image bytes.
  ///
  /// The bytes are base64-encoded into a data URL and stored as the avatar.
  /// [mimeType] defaults to `'image/jpeg'`.
  Future<ChannelEditResponse> uploadChannelAvatar(
    int channelId,
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    final dataUrl = 'data:$mimeType;base64,${base64Encode(imageBytes)}';
    return updateChannel(channelId, avatarUrl: dataUrl);
  }

  // ─── Groups (group chats) ─────────────────────────────────────────────────────

  /// Create a new group chat.
  Future<GroupCreateResponse> createGroup(
    String name, {
    String? description,
  }) async {
    _requireAuthenticated();

    final request = GroupCreateRequest(
      name: name,
      description: description,
    );

    final msg = Message.withType(MessageType.groupCreate, request.toBytes());
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.groupCreateResponse},
    );
    return GroupCreateResponse.fromBytes(response.payload);
  }

  /// Edit group chat properties (name, description, avatar URL).
  Future<GroupEditResponse> updateGroup(
    int groupId, {
    String? name,
    String? description,
    String? avatarUrl,
  }) async {
    _requireAuthenticated();

    final request = GroupEditRequest(
      groupId: groupId,
      name: name,
      description: description,
      avatarUrl: avatarUrl,
    );

    final msg = Message.withType(MessageType.groupEdit, request.toBytes());
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.groupEditResponse},
    );
    return GroupEditResponse.fromBytes(response.payload);
  }

  /// Upload a group chat avatar from raw image bytes.
  ///
  /// The bytes are base64-encoded into a data URL and stored as the avatar.
  /// [mimeType] defaults to `'image/jpeg'`.
  Future<GroupEditResponse> uploadGroupAvatar(
    int groupId,
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    final dataUrl = 'data:$mimeType;base64,${base64Encode(imageBytes)}';
    return updateGroup(groupId, avatarUrl: dataUrl);
  }

  // ─── Profile ──────────────────────────────────────────────────────────────────

  /// Get the authenticated user's own profile.
  Future<ProfileGetResponse> getOwnProfile() async {
    _requireAuthenticated();
    final request = ProfileGetRequest();
    final msg = Message.withType(MessageType.profileGet, request.toBytes());
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.profileGetResponse},
    );
    return ProfileGetResponse.fromBytes(response.payload);
  }

  /// Get another user's profile by ID or username.
  Future<ProfileGetResponse> getProfile({int? userId, String? username}) async {
    _requireAuthenticated();
    final request = ProfileGetRequest(userId: userId, username: username);
    final msg = Message.withType(MessageType.profileGet, request.toBytes());
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.profileGetResponse},
    );
    return ProfileGetResponse.fromBytes(response.payload);
  }

  /// Update the authenticated user's profile fields.
  Future<ProfileUpdateResponse> updateProfile({
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? username,
    String? location,
    String? birthDate,
  }) async {
    _requireAuthenticated();

    final request = ProfileUpdateRequest(
      displayName: displayName,
      avatarUrl: avatarUrl,
      bio: bio,
      username: username,
      location: location,
      birthDate: birthDate,
    );

    final msg = Message.withType(MessageType.profileUpdate, request.toBytes());
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.profileUpdateResponse},
    );
    return ProfileUpdateResponse.fromBytes(response.payload);
  }

  /// Upload a user avatar from raw image bytes.
  ///
  /// The bytes are base64-encoded into a data URL and stored as the avatar.
  /// [mimeType] defaults to `'image/jpeg'`.
  Future<ProfileUpdateResponse> uploadUserAvatar(
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    final dataUrl = 'data:$mimeType;base64,${base64Encode(imageBytes)}';
    final result = await addProfileAvatar(dataUrl, makePrimary: true);
    return ProfileUpdateResponse(
      success: result.success,
      message: result.message,
    );
  }

  Future<ProfileAvatarMutationResponse> addProfileAvatar(
    String avatarUrl, {
    bool makePrimary = false,
  }) async {
    _requireAuthenticated();
    final request = ProfileAvatarAddRequest(
      avatarUrl: avatarUrl,
      makePrimary: makePrimary,
    );
    final msg = Message.withType(
      MessageType.profileAvatarAdd,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.profileAvatarAddResponse},
    );
    return ProfileAvatarMutationResponse.fromBytes(response.payload);
  }

  Future<ProfileAvatarListResponse> listProfileAvatars() async {
    _requireAuthenticated();
    final msg = Message.withType(
      MessageType.profileAvatarList,
      msgpack.serialize(<String, Object?>{}),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.profileAvatarListResponse},
    );
    return ProfileAvatarListResponse.fromBytes(response.payload);
  }

  Future<ProfileAvatarMutationResponse> deleteProfileAvatar(
    int avatarId,
  ) async {
    _requireAuthenticated();
    final request = ProfileAvatarDeleteRequest(avatarId: avatarId);
    final msg = Message.withType(
      MessageType.profileAvatarDelete,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.profileAvatarDeleteResponse},
    );
    return ProfileAvatarMutationResponse.fromBytes(response.payload);
  }

  Future<ProfileAvatarMutationResponse> setPrimaryProfileAvatar(
    int avatarId,
  ) async {
    _requireAuthenticated();
    final request = ProfileAvatarSetPrimaryRequest(avatarId: avatarId);
    final msg = Message.withType(
      MessageType.profileAvatarSetPrimary,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.profileAvatarSetPrimaryResponse},
    );
    return ProfileAvatarMutationResponse.fromBytes(response.payload);
  }

  Future<ChannelLinkResponse> updateChannelLinks(
    int channelId, {
    String? publicAlias,
    bool regeneratePrivateInvite = false,
  }) async {
    _requireAuthenticated();
    final request = ChannelLinkUpdateRequest(
      channelId: channelId,
      publicAlias: publicAlias,
      regeneratePrivateInvite: regeneratePrivateInvite,
    );
    final msg = Message.withType(
      MessageType.channelLinkUpdate,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelLinkUpdateResponse},
    );
    return ChannelLinkResponse.fromBytes(response.payload);
  }

  Future<ChannelLinkResponse> getChannelLinks(int channelId) async {
    _requireAuthenticated();
    final request = ChannelLinkRequest(channelId: channelId);
    final msg = Message.withType(MessageType.channelLinkGet, request.toBytes());
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelLinkGetResponse},
    );
    return ChannelLinkResponse.fromBytes(response.payload);
  }

  Future<ChannelResolveResponse> resolveChannelLink(String linkOrAlias) async {
    _requireAuthenticated();
    final request = ChannelResolveRequest(linkOrAlias: linkOrAlias);
    final msg = Message.withType(MessageType.channelResolve, request.toBytes());
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelResolveResponse},
    );
    return ChannelResolveResponse.fromBytes(response.payload);
  }

  Future<ChannelJoinResponse> joinChannelByLink(String linkOrAlias) async {
    _requireAuthenticated();
    final request = ChannelResolveRequest(linkOrAlias: linkOrAlias);
    final msg = Message.withType(
      MessageType.channelJoinByLink,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelJoinByLinkResponse},
    );
    return ChannelJoinResponse.fromBytes(response.payload);
  }

  // ─── User search ─────────────────────────────────────────────────────────────

  /// Search for users by username prefix.
  Future<UserSearchResponse> searchUsers(String query, {int limit = 20}) async {
    _requireAuthenticated();

    final request = UserSearchRequest(query: query, limit: limit);
    final msg = Message.withType(MessageType.userSearch, request.toBytes());
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.userSearchResult},
    );
    return UserSearchResponse.fromBytes(response.payload);
  }

  // ─── Ping ────────────────────────────────────────────────────────────────────

  /// Send a ping to the server (fire-and-forget).
  Future<void> ping() async {
    _requireConnected();
    final msg = Message.withType(MessageType.ping);
    msg.sequenceId = _nextSeqId++;
    await _transport.sendMessage(msg);
  }

  /// Explicitly publish user presence state to the server.
  Future<void> setPresence({required bool isOnline}) async {
    _requireAuthenticated();
    await _publishPresence(isOnline: isOnline);
  }

  // ─── Internal helpers ────────────────────────────────────────────────────────

  /// Assign a sequence ID, subscribe for the matching response, then send.
  ///
  /// Subscribing BEFORE the send prevents a race condition where the server
  /// replies faster than the subscription is established.
  Future<Message> _sendAndWaitResponse(
    Message message, {
    Set<MessageType>? expectedTypes,
    Duration timeout = const Duration(seconds: 10),
    bool allowSeqZeroForExpectedTypes = false,
    bool allowAnySequenceForExpectedTypes = false,
  }) async {
    if (expectedTypes == null || expectedTypes.isEmpty) {
      throw ArgumentError('expectedTypes must not be empty');
    }

    message.sequenceId = _nextSeqId++;
    message.flags |= ProtocolConstants.flagRequiresAck;

    final seqId = message.sequenceId;

    final completer = Completer<Message>();
    late final StreamSubscription<Message> subscription;
    Timer? timeoutTimer;

    subscription = messages.listen((msg) {
      if (msg.type == MessageType.ack && !expectedTypes.contains(MessageType.ack)) {
        return;
      }

      final isMatchingSeq = msg.sequenceId == seqId;
      final isSeqZero = msg.sequenceId == 0;

      if (msg.type == MessageType.error || msg.type == MessageType.nack) {
        // Some server error paths may publish sequence-less errors.
        if ((isMatchingSeq || isSeqZero) && !completer.isCompleted) {
          completer.completeError(
            Exception(_extractProtocolErrorMessage(msg)),
          );
        }
        return;
      }

      if (!isMatchingSeq) {
        final isExpectedType = expectedTypes.contains(msg.type);
        final canUseTypeOnlyMatch =
            isExpectedType &&
            (allowAnySequenceForExpectedTypes ||
                (allowSeqZeroForExpectedTypes && isSeqZero));
        if (!canUseTypeOnlyMatch) {
          return;
        }
      }

      if (!expectedTypes.contains(msg.type)) {
        return;
      }

      if (!completer.isCompleted) {
        completer.complete(msg);
      }
    });

    timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException('No response for seq=$seqId', timeout),
        );
      }
    });

    await _transport.sendMessage(message);

    try {
      return await completer.future;
    } finally {
      timeoutTimer.cancel();
      await subscription.cancel();
    }
  }

  String _extractProtocolErrorMessage(Message message) {
    if (message.payload.isEmpty) {
      return 'Protocol error: ${message.type}';
    }

    try {
      final decoded = msgpack.deserialize(message.payload);
      if (decoded is Map) {
        final normalized = Map<String, dynamic>.from(
          decoded.map((key, value) => MapEntry(key.toString(), value)),
        );
        final messageText =
            normalized['Message'] ??
            normalized['Error'] ??
            normalized['message'] ??
            normalized['error'];
        if (messageText != null) {
          return messageText.toString();
        }
      }
    } on Object catch (_) {
      // Fall through to UTF-8/plain representation.
    }

    try {
      return utf8.decode(message.payload);
    } on Object catch (_) {
      return 'Protocol error: ${message.type}';
    }
  }

  Future<MessageReceiptResponse> _sendReceiptAndWaitResponse(
    MessageType requestType,
    MessageType responseType,
    List<int> messageIds,
    List<int> payload, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final normalizedIds = messageIds.toSet().toList(growable: false)..sort();
    final completer = Completer<MessageReceiptResponse>();
    late final StreamSubscription<Message> subscription;
    Timer? timeoutTimer;

    bool matchesMessageIds(List<int> candidate) {
      if (candidate.length != normalizedIds.length) {
        return false;
      }

      final sortedCandidate = candidate.toSet().toList(growable: false)..sort();
      if (sortedCandidate.length != normalizedIds.length) {
        return false;
      }

      for (var index = 0; index < normalizedIds.length; index++) {
        if (sortedCandidate[index] != normalizedIds[index]) {
          return false;
        }
      }

      return true;
    }

    subscription = messages.listen((msg) {
      if (msg.type != responseType &&
          msg.type != MessageType.error &&
          msg.type != MessageType.nack) {
        return;
      }

      if (msg.type == MessageType.error || msg.type == MessageType.nack) {
        if (!completer.isCompleted) {
          completer.completeError(Exception(_extractProtocolErrorMessage(msg)));
        }
        return;
      }

      try {
        final response = MessageReceiptResponse.fromBytes(msg.payload);
        if (!matchesMessageIds(response.messageIds)) {
          return;
        }

        if (!completer.isCompleted) {
          completer.complete(response);
        }
      } on Object catch (_) {
        // Ignore unrelated payloads.
      }
    });

    timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException('No receipt response for $requestType', timeout),
        );
      }
    });

    final message = Message.withType(requestType, payload)
      ..sequenceId = _nextSeqId++
      ..flags |= ProtocolConstants.flagRequiresAck;
    await _transport.sendMessage(message);

    try {
      return await completer.future;
    } finally {
      timeoutTimer.cancel();
      await subscription.cancel();
    }
  }

  /// Send the initial handshake after connect.
  Future<void> _performHandshake({
    required bool allowLegacyHandshakeFallback,
    required AegisApiCredentials? apiCredentials,
    required bool requireSignedHandshake,
    String? trustedServerHandshakeSigningPublicKeyBase64,
  }) async {
    final AegisHandshakeContext handshake;
    try {
      handshake = await AegisHandshakeContext.create();
    } on Object catch (error) {
      if (!_isLocalV2HandshakeUnsupportedError(error)) {
        rethrow;
      }

      await _performLegacyHandshakeWithPointyCastle(
        apiCredentials: apiCredentials,
        requireSignedHandshake: requireSignedHandshake,
        trustedServerHandshakeSigningPublicKeyBase64:
            trustedServerHandshakeSigningPublicKeyBase64,
      );
      return;
    }

    final bool v2Completed;
    try {
      v2Completed = await _tryPerformV2Handshake(
        handshake: handshake,
        apiCredentials: apiCredentials,
        trustedServerHandshakeSigningPublicKeyBase64:
            trustedServerHandshakeSigningPublicKeyBase64,
        requireSignedHandshake: requireSignedHandshake,
      );
    } on Object catch (error) {
      if (!_isLocalV2HandshakeUnsupportedError(error)) {
        rethrow;
      }

      await _performLegacyHandshake(
        handshake: handshake,
        apiCredentials: apiCredentials,
        trustedServerHandshakeSigningPublicKeyBase64:
            trustedServerHandshakeSigningPublicKeyBase64,
        requireSignedHandshake: requireSignedHandshake,
      );
      return;
    }

    if (v2Completed) {
      return;
    }

    if (!allowLegacyHandshakeFallback) {
      throw Exception(
        'Server did not return a V2 handshake stage. '
        'Use allowLegacyHandshakeFallback=true only for migration.',
      );
    }

    await _performLegacyHandshake(
      handshake: handshake,
      apiCredentials: apiCredentials,
      trustedServerHandshakeSigningPublicKeyBase64:
          trustedServerHandshakeSigningPublicKeyBase64,
      requireSignedHandshake: requireSignedHandshake,
    );
  }

  Future<bool> _tryPerformV2Handshake({
    required AegisHandshakeContext handshake,
    required AegisApiCredentials? apiCredentials,
    required bool requireSignedHandshake,
    String? trustedServerHandshakeSigningPublicKeyBase64,
  }) async {
    final clientNonce = AegisSecureProtocolV2.secureRandomBytes(32);
    final clientHello = <String, Object>{
      'ApiId': apiCredentials?.appId ?? 0,
      'AppHash': apiCredentials?.appHash ?? '',
      'ClientEphemeralPublicKey': handshake.publicKey,
      'ClientNonce': clientNonce,
      'ClientUnixTimeMs': DateTime.now().toUtc().millisecondsSinceEpoch,
      'TransportHint': 'obfs+tls',
    };

    final helloEnvelope = <String, Object>{
      'Stage': 'client_hello_v2',
      'ClientHello': clientHello,
    };
    final helloPayload = msgpack.serialize(helloEnvelope);
    final helloMsg = Message.withType(MessageType.handshake, helloPayload);
    final helloResponse = await _sendAndWaitResponse(
      helloMsg,
      expectedTypes: {MessageType.handshake},
    );

    final decodedHello = msgpack.deserialize(helloResponse.payload);
    if (decodedHello is! Map) {
      throw Exception('Invalid V2 handshake response payload');
    }

    final stage = decodedHello['Stage']?.toString();
    if (stage == null || stage.isEmpty) {
      return false;
    }

    final isSuccess = decodedHello['Success'] == true;
    if (!isSuccess) {
      final error = decodedHello['Message']?.toString() ?? 'Handshake V2 failed';
      throw Exception(error);
    }

    if (stage != 'server_hello_v2') {
      throw Exception('Unexpected V2 handshake stage: $stage');
    }

    final serverHelloMap = decodedHello['ServerHello'];
    if (serverHelloMap is! Map) {
      throw Exception('V2 handshake response is missing ServerHello');
    }

    final serverPublicKey = _readBytesField(
      serverHelloMap,
      'ServerEphemeralPublicKey',
      'ServerHello.ServerEphemeralPublicKey',
    );
    final serverNonce = _readBytesField(
      serverHelloMap,
      'ServerNonce',
      'ServerHello.ServerNonce',
    );
    final cookie = _readBytesField(
      serverHelloMap,
      'Cookie',
      'ServerHello.Cookie',
    );
    final signature = _readOptionalBytesField(serverHelloMap, 'Signature');

    if (requireSignedHandshake) {
      if (trustedServerHandshakeSigningPublicKeyBase64 == null ||
          trustedServerHandshakeSigningPublicKeyBase64.isEmpty) {
        throw Exception('Trusted handshake signing public key is required');
      }

      if (signature == null || signature.isEmpty) {
        throw Exception('Handshake response signature is missing');
      }

      final signatureOk =
          await AegisHandshakeVerifier.verifyServerHandshakeSignature(
            trustedSigningPublicKey: Uint8List.fromList(
              base64Decode(trustedServerHandshakeSigningPublicKeyBase64),
            ),
            serverEphemeralPublicKey: serverPublicKey,
            clientEphemeralPublicKey: handshake.publicKey,
            signature: signature,
          );

      if (!signatureOk) {
        throw Exception('Handshake signature verification failed');
      }
    }

    final transcriptHash = await AegisSecureProtocolV2.sha256(helloPayload);
    final sharedSecret = await handshake.deriveSharedSecret(serverPublicKey);
    final keys = await AegisSecureProtocolV2.deriveSessionKeys(
      sharedSecret: sharedSecret,
      clientNonce: clientNonce,
      serverNonce: serverNonce,
      transcriptHash: transcriptHash,
    );
    final proof = await AegisSecureProtocolV2.computeClientFinishProof(
      ackKey: keys.ackKey,
      transcriptHash: transcriptHash,
    );

    final finishEnvelope = <String, Object>{
      'Stage': 'client_finish_v2',
      'ClientFinish': {
        'Cookie': cookie,
        'Proof': proof,
      },
    };
    final finishPayload = msgpack.serialize(finishEnvelope);
    final finishMsg = Message.withType(MessageType.handshake, finishPayload);
    final finishResponse = await _sendAndWaitResponse(
      finishMsg,
      expectedTypes: {MessageType.handshake},
    );

    final decodedFinish = msgpack.deserialize(finishResponse.payload);
    if (decodedFinish is! Map) {
      throw Exception('Invalid V2 handshake finish response payload');
    }

    final finishStage = decodedFinish['Stage']?.toString();
    final finishSuccess = decodedFinish['Success'] == true;
    if (!finishSuccess) {
      final error =
          decodedFinish['Message']?.toString() ?? 'Handshake V2 finish failed';
      throw Exception(error);
    }

    if (finishStage != 'server_finish_v2') {
      throw Exception('Unexpected V2 handshake finish stage: $finishStage');
    }

    _transport.setSessionKey(keys.clientToServerKey);
    return true;
  }

  Future<void> _performLegacyHandshake({
    required AegisHandshakeContext handshake,
    required AegisApiCredentials? apiCredentials,
    required bool requireSignedHandshake,
    String? trustedServerHandshakeSigningPublicKeyBase64,
  }) async {
    final handshakePayload = <String, Object>{
      'PublicKey': base64Encode(handshake.publicKey),
      'ClientVersion':
          ProtocolConstants.versionMajor * 1000 +
          ProtocolConstants.versionMinor,
    };

    if (apiCredentials != null) {
      handshakePayload['AppId'] = apiCredentials.appId;
      handshakePayload['AppHash'] = apiCredentials.appHash;
    }

    final payload = msgpack.serialize(handshakePayload);

    final msg = Message.withType(MessageType.handshake, payload);
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.handshake},
      allowSeqZeroForExpectedTypes: true,
      allowAnySequenceForExpectedTypes: true,
    );

    final decoded = msgpack.deserialize(response.payload);
    if (decoded is! Map) {
      throw Exception('Invalid handshake response payload');
    }

    final success = decoded['Success'] == true;
    if (!success) {
      final error = decoded['Message']?.toString() ?? 'Handshake failed';
      throw Exception(error);
    }

    final serverPublicKeyBase64 = decoded['ServerPublicKey']?.toString();
    if (serverPublicKeyBase64 == null || serverPublicKeyBase64.isEmpty) {
      throw Exception('Handshake response is missing server public key');
    }

    final signatureBase64 = decoded['Signature']?.toString();
    if (requireSignedHandshake) {
      if (trustedServerHandshakeSigningPublicKeyBase64 == null ||
          trustedServerHandshakeSigningPublicKeyBase64.isEmpty) {
        throw Exception('Trusted handshake signing public key is required');
      }

      if (signatureBase64 == null || signatureBase64.isEmpty) {
        throw Exception('Handshake response signature is missing');
      }

      final signatureOk =
          await AegisHandshakeVerifier.verifyServerHandshakeSignature(
            trustedSigningPublicKey: Uint8List.fromList(
              base64Decode(trustedServerHandshakeSigningPublicKeyBase64),
            ),
            serverEphemeralPublicKey: Uint8List.fromList(
              base64Decode(serverPublicKeyBase64),
            ),
            clientEphemeralPublicKey: handshake.publicKey,
            signature: Uint8List.fromList(base64Decode(signatureBase64)),
          );

      if (!signatureOk) {
        throw Exception('Handshake signature verification failed');
      }
    }

    final sessionKey = await handshake.deriveSessionKey(
      Uint8List.fromList(base64Decode(serverPublicKeyBase64)),
    );
    _transport.setSessionKey(sessionKey);
  }

  Future<void> _performLegacyHandshakeWithPointyCastle({
    required AegisApiCredentials? apiCredentials,
    required bool requireSignedHandshake,
    String? trustedServerHandshakeSigningPublicKeyBase64,
  }) async {
    final handshake = await AegisHandshakeCrypto.createHandshake();
    final handshakePayload = <String, Object>{
      'PublicKey': base64Encode(handshake.publicKeyRaw),
      'ClientVersion':
          ProtocolConstants.versionMajor * 1000 +
          ProtocolConstants.versionMinor,
    };

    if (apiCredentials != null) {
      handshakePayload['AppId'] = apiCredentials.appId;
      handshakePayload['AppHash'] = apiCredentials.appHash;
    }

    final payload = msgpack.serialize(handshakePayload);
    final msg = Message.withType(MessageType.handshake, payload);
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.handshake},
      allowSeqZeroForExpectedTypes: true,
      allowAnySequenceForExpectedTypes: true,
    );

    final decoded = msgpack.deserialize(response.payload);
    if (decoded is! Map) {
      throw Exception('Invalid handshake response payload');
    }

    final success = decoded['Success'] == true;
    if (!success) {
      final error = decoded['Message']?.toString() ?? 'Handshake failed';
      throw Exception(error);
    }

    final serverPublicKeyBase64 = decoded['ServerPublicKey']?.toString();
    if (serverPublicKeyBase64 == null || serverPublicKeyBase64.isEmpty) {
      throw Exception('Handshake response is missing server public key');
    }

    final signatureBase64 = decoded['Signature']?.toString();
    if (requireSignedHandshake) {
      if (trustedServerHandshakeSigningPublicKeyBase64 == null ||
          trustedServerHandshakeSigningPublicKeyBase64.isEmpty) {
        throw Exception('Trusted handshake signing public key is required');
      }

      if (signatureBase64 == null || signatureBase64.isEmpty) {
        throw Exception('Handshake response signature is missing');
      }

      final signatureOk = await AegisHandshakeVerifier.verifyServerHandshakeSignature(
        trustedSigningPublicKey: Uint8List.fromList(
          base64Decode(trustedServerHandshakeSigningPublicKeyBase64),
        ),
        serverEphemeralPublicKey: Uint8List.fromList(
          base64Decode(serverPublicKeyBase64),
        ),
        clientEphemeralPublicKey: handshake.publicKeyRaw,
        signature: Uint8List.fromList(base64Decode(signatureBase64)),
      );

      if (!signatureOk) {
        throw Exception('Handshake signature verification failed');
      }
    }

    final sessionKey = await AegisHandshakeCrypto.deriveSessionKey(
      clientPrivateKey: handshake.privateKey,
      serverPublicKeySpki: base64Decode(serverPublicKeyBase64),
    );
    _transport.setSessionKey(Uint8List.fromList(sessionKey));
  }

  Uint8List _readBytesField(Map source, String key, String fieldName) {
    final value = source[key];
    if (value is Uint8List) {
      return Uint8List.fromList(value);
    }

    if (value is List) {
      return Uint8List.fromList(value.cast<int>());
    }

    throw Exception('Invalid $fieldName in handshake payload');
  }

  Uint8List? _readOptionalBytesField(Map source, String key) {
    if (!source.containsKey(key)) {
      return null;
    }

    final value = source[key];
    if (value == null) {
      return null;
    }

    if (value is Uint8List) {
      return Uint8List.fromList(value);
    }

    if (value is List) {
      return Uint8List.fromList(value.cast<int>());
    }

    return null;
  }

  // ─── Group History and Members (SERVER-002, SERVER-003) ──────────────────

  /// Get group message history.
  Future<GroupHistoryResponse> getGroupHistory(
    int groupId, {
    int limit = 100,
    int? beforeMessageId,
  }) async {
    _requireAuthenticated();

    final request = GroupHistoryRequest(
      groupId: groupId,
      limit: limit,
      beforeMessageId: beforeMessageId,
    );

    final msg = Message.withType(
      MessageType.groupHistoryRequest,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.groupHistoryResponse},
    );
    return GroupHistoryResponse.fromBytes(response.payload);
  }

  /// Get channel members.
  Future<ChannelMembersResponse> getChannelMembers(int channelId) async {
    _requireAuthenticated();

    final request = ChannelMembersRequest(channelId: channelId);
    final msg = Message.withType(
      MessageType.channelMembersRequest,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelMembersResponse},
    );
    return ChannelMembersResponse.fromBytes(response.payload);
  }

  /// Get group members.
  Future<GroupMembersResponse> getGroupMembers(int groupId) async {
    _requireAuthenticated();

    final request = GroupMembersRequest(groupId: groupId);
    final msg = Message.withType(
      MessageType.groupMembersRequest,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.groupMembersResponse},
    );
    return GroupMembersResponse.fromBytes(response.payload);
  }

  // ─── Leave Operations (SERVER-004) ─────────────────────────────────────────

  /// Leave a channel.
  Future<ChannelLeaveResponse> leaveChannel(int channelId) async {
    _requireAuthenticated();

    final request = ChannelLeaveRequest(channelId: channelId);
    final msg = Message.withType(
      MessageType.channelLeave,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.channelLeave},
    );
    return ChannelLeaveResponse.fromBytes(response.payload);
  }

  /// Leave a group.
  Future<GroupLeaveResponse> leaveGroup(int groupId) async {
    _requireAuthenticated();

    final request = GroupLeaveRequest(groupId: groupId);
    final msg = Message.withType(
      MessageType.groupLeave,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.groupLeave},
    );
    return GroupLeaveResponse.fromBytes(response.payload);
  }

  // ─── Message edits and deletes ──────────────────────────────────────────────

  Future<MessageEditResponse> editMessage(
    int messageId,
    String newContent, {
    String scope = 'private',
    int? channelId,
    int? groupId,
  }) async {
    _requireAuthenticated();

    final request = MessageEditRequest(
      messageId: messageId,
      newContent: newContent,
      scope: scope,
      channelId: channelId,
      groupId: groupId,
    );

    final msg = Message.withType(MessageType.messageEdit, request.toBytes());
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.messageEditResponse},
    );
    return MessageEditResponse.fromBytes(response.payload);
  }

  Future<MessageEditResponse> editPrivateMessage(
    int messageId,
    String newContent,
  ) {
    return editMessage(
      messageId,
      newContent,
      scope: ChatScope.privateChat.value,
    );
  }

  Future<MessageEditResponse> editChannelMessage(
    int channelId,
    int messageId,
    String newContent,
  ) {
    return editMessage(
      messageId,
      newContent,
      scope: ChatScope.channel.value,
      channelId: channelId,
    );
  }

  Future<MessageEditResponse> editGroupMessage(
    int groupId,
    int messageId,
    String newContent,
  ) {
    return editMessage(
      messageId,
      newContent,
      scope: ChatScope.group.value,
      groupId: groupId,
    );
  }

  Future<MessageDeleteResponse> deleteMessage(
    int messageId, {
    String scope = 'private',
    int? channelId,
    int? groupId,
  }) async {
    _requireAuthenticated();

    final request = MessageDeleteRequest(
      messageId: messageId,
      scope: scope,
      channelId: channelId,
      groupId: groupId,
    );

    final msg = Message.withType(MessageType.messageDelete, request.toBytes());
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.messageDeleteResponse},
    );
    return MessageDeleteResponse.fromBytes(response.payload);
  }

  Future<MessageDeleteResponse> deletePrivateMessage(int messageId) {
    return deleteMessage(messageId, scope: ChatScope.privateChat.value);
  }

  Future<MessageDeleteResponse> deleteChannelMessage(
    int channelId,
    int messageId,
  ) {
    return deleteMessage(
      messageId,
      scope: ChatScope.channel.value,
      channelId: channelId,
    );
  }

  Future<MessageDeleteResponse> deleteGroupMessage(
    int groupId,
    int messageId,
  ) {
    return deleteMessage(
      messageId,
      scope: ChatScope.group.value,
      groupId: groupId,
    );
  }

  // ─── Membership administration ─────────────────────────────────────────────

  Future<MemberRoleUpdateResponse> updateMemberRole({
    required String scope,
    required int targetId,
    required int targetUserId,
    required int newRole,
  }) async {
    _requireAuthenticated();

    final request = MemberRoleUpdateRequest(
      scope: scope,
      targetId: targetId,
      targetUserId: targetUserId,
      newRole: newRole,
    );

    final msg = Message.withType(
      MessageType.memberRoleUpdate,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.memberRoleUpdateResponse},
    );
    return MemberRoleUpdateResponse.fromBytes(response.payload);
  }

  Future<MemberRoleUpdateResponse> updateChannelMemberRole({
    required int channelId,
    required int targetUserId,
    required MemberRole newRole,
  }) {
    return updateMemberRole(
      scope: RoomScope.channel.value,
      targetId: channelId,
      targetUserId: targetUserId,
      newRole: newRole.value,
    );
  }

  Future<MemberRoleUpdateResponse> updateGroupMemberRole({
    required int groupId,
    required int targetUserId,
    required MemberRole newRole,
  }) {
    return updateMemberRole(
      scope: RoomScope.group.value,
      targetId: groupId,
      targetUserId: targetUserId,
      newRole: newRole.value,
    );
  }

  Future<MemberPermissionUpdateResponse> updateMemberPermissions({
    required String scope,
    required int targetId,
    required int targetUserId,
    bool? canSendMessages,
    bool? canDeleteOthersMessages,
    bool? canEditInfo,
    bool? canInviteUsers,
    bool? canRemoveUsers,
    bool? canPinMessages,
    bool? canManageRoles,
  }) async {
    _requireAuthenticated();

    final request = MemberPermissionUpdateRequest(
      scope: scope,
      targetId: targetId,
      targetUserId: targetUserId,
      canSendMessages: canSendMessages,
      canDeleteOthersMessages: canDeleteOthersMessages,
      canEditInfo: canEditInfo,
      canInviteUsers: canInviteUsers,
      canRemoveUsers: canRemoveUsers,
      canPinMessages: canPinMessages,
      canManageRoles: canManageRoles,
    );

    final msg = Message.withType(
      MessageType.memberPermissionUpdate,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.memberPermissionUpdateResponse},
    );
    return MemberPermissionUpdateResponse.fromBytes(response.payload);
  }

  Future<MemberPermissionUpdateResponse> updateChannelMemberPermissions({
    required int channelId,
    required int targetUserId,
    bool? canSendMessages,
    bool? canDeleteOthersMessages,
    bool? canEditInfo,
    bool? canInviteUsers,
    bool? canRemoveUsers,
    bool? canPinMessages,
    bool? canManageRoles,
  }) {
    return updateMemberPermissions(
      scope: RoomScope.channel.value,
      targetId: channelId,
      targetUserId: targetUserId,
      canSendMessages: canSendMessages,
      canDeleteOthersMessages: canDeleteOthersMessages,
      canEditInfo: canEditInfo,
      canInviteUsers: canInviteUsers,
      canRemoveUsers: canRemoveUsers,
      canPinMessages: canPinMessages,
      canManageRoles: canManageRoles,
    );
  }

  Future<MemberPermissionUpdateResponse> updateGroupMemberPermissions({
    required int groupId,
    required int targetUserId,
    bool? canSendMessages,
    bool? canDeleteOthersMessages,
    bool? canEditInfo,
    bool? canInviteUsers,
    bool? canRemoveUsers,
    bool? canPinMessages,
    bool? canManageRoles,
  }) {
    return updateMemberPermissions(
      scope: RoomScope.group.value,
      targetId: groupId,
      targetUserId: targetUserId,
      canSendMessages: canSendMessages,
      canDeleteOthersMessages: canDeleteOthersMessages,
      canEditInfo: canEditInfo,
      canInviteUsers: canInviteUsers,
      canRemoveUsers: canRemoveUsers,
      canPinMessages: canPinMessages,
      canManageRoles: canManageRoles,
    );
  }

  // ─── Delivery and read receipts ────────────────────────────────────────────

  Future<MessageReceiptResponse> sendDeliveryReceipt(
    List<int> messageIds, {
    DateTime? deliveredAt,
    String? deviceId,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    _requireAuthenticated();

    final request = MessageDeliveryReceiptRequest(
      messageIds: messageIds,
      deliveredAt: deliveredAt ?? DateTime.now().toUtc(),
      deviceId: deviceId,
    );

    return _sendReceiptAndWaitResponse(
      MessageType.messageDeliveryReceipt,
      MessageType.messageDeliveryReceiptResponse,
      messageIds,
      request.toBytes(),
      timeout: timeout,
    );
  }

  Future<MessageReceiptResponse> sendReadReceipt(
    List<int> messageIds, {
    DateTime? readAt,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    _requireAuthenticated();

    final request = MessageReadReceiptRequest(
      messageIds: messageIds,
      readAt: readAt ?? DateTime.now().toUtc(),
    );

    return _sendReceiptAndWaitResponse(
      MessageType.messageReadReceipt,
      MessageType.messageReadReceiptResponse,
      messageIds,
      request.toBytes(),
      timeout: timeout,
    );
  }

  // ─── Reactions and Pins (SERVER-005) ───────────────────────────────────────

  /// Post a reaction to a message.
  ///
  /// [scope] can be "private", "channel", or "group".
  Future<MessageReactResponse> postReaction(
    String scope,
    int messageId,
    String emoji,
  ) async {
    _requireAuthenticated();

    final request = MessageReactRequest(
      scope: scope,
      messageId: messageId,
      emoji: emoji,
    );

    final msg = Message.withType(
      MessageType.messageReact,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.messageReactResponse},
    );
    return MessageReactResponse.fromBytes(response.payload);
  }

  Future<MessageReactResponse> reactToPrivateMessage(
    int messageId,
    String emoji,
  ) {
    return postReaction(ChatScope.privateChat.value, messageId, emoji);
  }

  Future<MessageReactResponse> reactToChannelMessage(
    int messageId,
    String emoji,
  ) {
    return postReaction(ChatScope.channel.value, messageId, emoji);
  }

  Future<MessageReactResponse> reactToGroupMessage(
    int messageId,
    String emoji,
  ) {
    return postReaction(ChatScope.group.value, messageId, emoji);
  }

  /// Remove a reaction from a message.
  ///
  /// [scope] can be "private", "channel", or "group".
  Future<MessageReactResponse> removeReaction(
    String scope,
    int messageId,
    String emoji,
  ) async {
    _requireAuthenticated();

    final request = MessageReactRequest(
      scope: scope,
      messageId: messageId,
      emoji: emoji,
      remove: true,
    );

    final msg = Message.withType(
      MessageType.messageReact,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.messageReactResponse},
    );
    return MessageReactResponse.fromBytes(response.payload);
  }

  Future<MessageReactResponse> removeReactionFromPrivateMessage(
    int messageId,
    String emoji,
  ) {
    return removeReaction(ChatScope.privateChat.value, messageId, emoji);
  }

  Future<MessageReactResponse> removeReactionFromChannelMessage(
    int messageId,
    String emoji,
  ) {
    return removeReaction(ChatScope.channel.value, messageId, emoji);
  }

  Future<MessageReactResponse> removeReactionFromGroupMessage(
    int messageId,
    String emoji,
  ) {
    return removeReaction(ChatScope.group.value, messageId, emoji);
  }

  /// Pin a message in a channel or group.
  ///
  /// [scope] must be "channel" or "group".
  /// [targetId] is the channelId or groupId.
  Future<MessagePinResponse> pinMessage(
    String scope,
    int messageId,
    int targetId,
  ) async {
    _requireAuthenticated();

    final request = MessagePinRequest(
      scope: scope,
      messageId: messageId,
      targetId: targetId,
    );

    final msg = Message.withType(
      MessageType.messagePin,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.messagePinResponse},
    );
    return MessagePinResponse.fromBytes(response.payload);
  }

  Future<MessagePinResponse> pinChannelMessage(
    int channelId,
    int messageId,
  ) {
    return pinMessage(RoomScope.channel.value, messageId, channelId);
  }

  Future<MessagePinResponse> pinGroupMessage(
    int groupId,
    int messageId,
  ) {
    return pinMessage(RoomScope.group.value, messageId, groupId);
  }

  /// Unpin a message in a channel or group.
  ///
  /// [scope] must be "channel" or "group".
  /// [targetId] is the channelId or groupId.
  Future<MessagePinResponse> unpinMessage(
    String scope,
    int messageId,
    int targetId,
  ) async {
    _requireAuthenticated();

    final request = MessagePinRequest(
      scope: scope,
      messageId: messageId,
      targetId: targetId,
      unpin: true,
    );

    final msg = Message.withType(
      MessageType.messagePin,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.messagePinResponse},
    );
    return MessagePinResponse.fromBytes(response.payload);
  }

  Future<MessagePinResponse> unpinChannelMessage(
    int channelId,
    int messageId,
  ) {
    return unpinMessage(RoomScope.channel.value, messageId, channelId);
  }

  Future<MessagePinResponse> unpinGroupMessage(
    int groupId,
    int messageId,
  ) {
    return unpinMessage(RoomScope.group.value, messageId, groupId);
  }

  // ─── Room Settings (SERVER-006) ────────────────────────────────────────────

  /// Get room settings for a channel or group.
  ///
  /// [scope] must be "channel" or "group".
  /// [targetId] is the channelId or groupId.
  Future<RoomSettingsGetResponse> getRoomSettings(
    String scope,
    int targetId,
  ) async {
    _requireAuthenticated();

    final request = RoomSettingsGetRequest(
      scope: scope,
      targetId: targetId,
    );

    final msg = Message.withType(
      MessageType.roomSettingsGet,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.roomSettingsGetResponse},
    );
    return RoomSettingsGetResponse.fromBytes(response.payload);
  }

  Future<RoomSettingsGetResponse> getChannelSettings(int channelId) {
    return getRoomSettings(RoomScope.channel.value, channelId);
  }

  Future<RoomSettingsGetResponse> getGroupSettings(int groupId) {
    return getRoomSettings(RoomScope.group.value, groupId);
  }

  /// Update room settings for a channel or group.
  ///
  /// [scope] must be "channel" or "group".
  /// [targetId] is the channelId or groupId.
  /// [joinRule]: 0=Open, 1=InviteOnly, 2=Approval (optional).
  /// [historyVisibility]: 0=WorldReadable, 1=Joined, 2=Invited (optional).
  Future<RoomSettingsUpdateResponse> updateRoomSettings(
    String scope,
    int targetId, {
    int? joinRule,
    int? historyVisibility,
  }) async {
    _requireAuthenticated();

    final request = RoomSettingsUpdateRequest(
      scope: scope,
      targetId: targetId,
      joinRule: joinRule,
      historyVisibility: historyVisibility,
    );

    final msg = Message.withType(
      MessageType.roomSettingsUpdate,
      request.toBytes(),
    );
    final response = await _sendAndWaitResponse(
      msg,
      expectedTypes: {MessageType.roomSettingsUpdateResponse},
    );
    return RoomSettingsUpdateResponse.fromBytes(response.payload);
  }

  Future<RoomSettingsUpdateResponse> updateChannelSettings(
    int channelId, {
    RoomJoinRule? joinRule,
    RoomHistoryVisibility? historyVisibility,
  }) {
    return updateRoomSettings(
      RoomScope.channel.value,
      channelId,
      joinRule: joinRule?.value,
      historyVisibility: historyVisibility?.value,
    );
  }

  Future<RoomSettingsUpdateResponse> updateGroupSettings(
    int groupId, {
    RoomJoinRule? joinRule,
    RoomHistoryVisibility? historyVisibility,
  }) {
    return updateRoomSettings(
      RoomScope.group.value,
      groupId,
      joinRule: joinRule?.value,
      historyVisibility: historyVisibility?.value,
    );
  }

  Future<void> _publishPresence({required bool isOnline}) async {
    try {
      final request = UserPresenceUpdateRequest(
        isOnline: isOnline,
        clientTimestamp: DateTime.now().toUtc(),
      );
      final msg = Message.withType(MessageType.userPresence, request.toBytes());
      msg.sequenceId = _nextSeqId++;
      await _transport.sendMessage(msg);
    } on Object catch (_) {
      // Presence signal is best-effort and must not block auth/disconnect.
    }
  }

  void _requireConnected() {
    if (!_transport.isConnected) throw NotConnectedException();
  }

  void _requireAuthenticated() {
    _requireConnected();
    if (!_isAuthenticated) throw Exception('Not authenticated');
  }
}

class AegisChannelFacade {
  final AegisClient _client;

  AegisChannelFacade._(this._client);

  Future<ChannelCreateResponse> create(
    String name, {
    String? description,
    ChannelType type = ChannelType.public,
  }) => _client.createChannel(name, description: description, type: type);

  Future<ChannelJoinResponse> join(int channelId) =>
      _client.joinChannel(channelId);

  Future<ChannelJoinResponse> joinByLink(String linkOrAlias) =>
      _client.joinChannelByLink(linkOrAlias);

  Future<ChannelLeaveResponse> leave(int channelId) =>
      _client.leaveChannel(channelId);

  Future<ChannelMessageResponse> sendMessage(
    int channelId,
    String content, {
    MessageContentType contentType = MessageContentType.text,
    int? replyToMessageId,
    ParseMode? parseMode,
  }) => _client.sendChannelMessage(
    channelId,
    content,
    contentType: contentType,
    replyToMessageId: replyToMessageId,
    parseMode: parseMode,
  );

  Future<ChannelHistoryResponse> history(
    int channelId, {
    int limit = 100,
    int? beforeMessageId,
  }) => _client.getChannelHistory(
    channelId,
    limit: limit,
    beforeMessageId: beforeMessageId,
  );

  Future<ChannelMembersResponse> members(int channelId) =>
      _client.getChannelMembers(channelId);

  Future<MessagePinResponse> pinMessage(int channelId, int messageId) =>
      _client.pinChannelMessage(channelId, messageId);

  Future<MessagePinResponse> unpinMessage(int channelId, int messageId) =>
      _client.unpinChannelMessage(channelId, messageId);

  Future<MessageReactResponse> react(int messageId, String emoji) =>
      _client.reactToChannelMessage(messageId, emoji);

  Future<MessageReactResponse> removeReaction(int messageId, String emoji) =>
      _client.removeReactionFromChannelMessage(messageId, emoji);

  Future<MessageEditResponse> editMessage(
    int channelId,
    int messageId,
    String newContent,
  ) => _client.editChannelMessage(channelId, messageId, newContent);

  Future<MessageDeleteResponse> deleteMessage(
    int channelId,
    int messageId,
  ) => _client.deleteChannelMessage(channelId, messageId);

  Future<RoomSettingsGetResponse> getSettings(int channelId) =>
      _client.getChannelSettings(channelId);

  Future<RoomSettingsUpdateResponse> updateSettings(
    int channelId, {
    RoomJoinRule? joinRule,
    RoomHistoryVisibility? historyVisibility,
  }) => _client.updateChannelSettings(
    channelId,
    joinRule: joinRule,
    historyVisibility: historyVisibility,
  );
}

class AegisGroupFacade {
  final AegisClient _client;

  AegisGroupFacade._(this._client);

  Future<GroupCreateResponse> create(
    String name, {
    String? description,
  }) => _client.createGroup(name, description: description);

  Future<GroupLeaveResponse> leave(int groupId) => _client.leaveGroup(groupId);

  Future<MediaSendResponse> sendMessage(
    int groupId,
    String content, {
    MessageContentType contentType = MessageContentType.text,
    int? replyToMessageId,
    ParseMode? parseMode,
  }) => _client.sendGroupMessage(
    groupId,
    content,
    contentType: contentType,
    replyToMessageId: replyToMessageId,
    parseMode: parseMode,
  );

  Future<GroupHistoryResponse> history(
    int groupId, {
    int limit = 100,
    int? beforeMessageId,
  }) => _client.getGroupHistory(
    groupId,
    limit: limit,
    beforeMessageId: beforeMessageId,
  );

  Future<GroupMembersResponse> members(int groupId) =>
      _client.getGroupMembers(groupId);

  Future<MessagePinResponse> pinMessage(int groupId, int messageId) =>
      _client.pinGroupMessage(groupId, messageId);

  Future<MessagePinResponse> unpinMessage(int groupId, int messageId) =>
      _client.unpinGroupMessage(groupId, messageId);

  Future<MessageReactResponse> react(int messageId, String emoji) =>
      _client.reactToGroupMessage(messageId, emoji);

  Future<MessageReactResponse> removeReaction(int messageId, String emoji) =>
      _client.removeReactionFromGroupMessage(messageId, emoji);

  Future<MessageEditResponse> editMessage(
    int groupId,
    int messageId,
    String newContent,
  ) => _client.editGroupMessage(groupId, messageId, newContent);

  Future<MessageDeleteResponse> deleteMessage(
    int groupId,
    int messageId,
  ) => _client.deleteGroupMessage(groupId, messageId);

  Future<RoomSettingsGetResponse> getSettings(int groupId) =>
      _client.getGroupSettings(groupId);

  Future<RoomSettingsUpdateResponse> updateSettings(
    int groupId, {
    RoomJoinRule? joinRule,
    RoomHistoryVisibility? historyVisibility,
  }) => _client.updateGroupSettings(
    groupId,
    joinRule: joinRule,
    historyVisibility: historyVisibility,
  );
}

class AegisDirectFacade {
  final AegisClient _client;

  AegisDirectFacade._(this._client);

  Future<PrivateChatMessageResponse> sendMessage(
    int toUserId,
    String content, {
    MessageContentType contentType = MessageContentType.text,
    ParseMode? parseMode,
  }) => _client.sendPrivateMessage(
    toUserId,
    content,
    contentType: contentType,
    parseMode: parseMode,
  );

  Future<PrivateChatHistoryResponse> history(
    int peerUserId, {
    int limit = 100,
    int? beforeMessageId,
  }) => _client.getPrivateHistory(
    peerUserId,
    limit: limit,
    beforeMessageId: beforeMessageId,
  );

  Future<MessageReactResponse> react(int messageId, String emoji) =>
      _client.reactToPrivateMessage(messageId, emoji);

  Future<MessageReactResponse> removeReaction(int messageId, String emoji) =>
      _client.removeReactionFromPrivateMessage(messageId, emoji);

  Future<MessageEditResponse> editMessage(int messageId, String newContent) =>
      _client.editPrivateMessage(messageId, newContent);

  Future<MessageDeleteResponse> deleteMessage(int messageId) =>
      _client.deletePrivateMessage(messageId);
}
