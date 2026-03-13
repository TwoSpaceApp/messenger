import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:two_space_app/core/network/aegis/event_dispatcher.dart';
import 'package:two_space_app/core/network/aegis/exceptions.dart';
import 'package:two_space_app/core/network/aegis/handshake_crypto.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';
import 'package:two_space_app/core/network/aegis/protocol_constants.dart';
import 'package:two_space_app/core/network/aegis/transport.dart';

/// Main Aegis client class
class AegisClient {
  static const int maxMediaUploadBytes = 15 * 1024 * 1024;
  static const int _mediaPayloadSafetyBytes = 2048;

  /// Create new Aegis client
  AegisClient() {
    _transport = AegisTransport();
    events = AegisEventDispatcher(_messageController.stream);
    _transport.messages.listen((message) {
      final waiter = _pendingResponseWaiters[message.sequenceId];
      if (waiter != null &&
          message.type == MessageType.error &&
          !waiter.completer.isCompleted) {
        _pendingResponseWaiters.remove(message.sequenceId);
        waiter.completer.completeError(
          Exception(_extractServerError(message)),
        );
      } else if (waiter != null &&
          waiter.acceptedTypes.contains(message.type) &&
          !waiter.completer.isCompleted) {
        _pendingResponseWaiters.remove(message.sequenceId);
        waiter.completer.complete(message);
      } else {
        _pendingMessages.add(message);
      }
      _messageController.add(message);
    });
    _transport.disconnects.listen((_) {
      _isAuthenticated = false;
      _authenticatedUserId = null;
      _authenticatedUsername = null;
      _failPendingWaiters(
        ConnectionException('Disconnected before response was received'),
      );
    });
  }
  late AegisTransport _transport;
  late final AegisEventDispatcher events;
  // ignore: unused_field
  String? _authToken;
  bool _isAuthenticated = false;
  int? _authenticatedUserId;
  String? _authenticatedUsername;
  final List<Message> _pendingMessages = <Message>[];
    final Map<int, _PendingResponseWaiter> _pendingResponseWaiters =
      <int, _PendingResponseWaiter>{};
  final StreamController<Message> _messageController =
      StreamController<Message>.broadcast();

  /// Stream of incoming messages
  Stream<Message> get messages => _messageController.stream;

    Stream<PrivateChatMessageEvent> get privateMessageEvents =>
      events.privateMessageEvents;

    Stream<ChannelMessageEvent> get channelMessageEvents =>
      events.channelMessageEvents;

  /// Stream of disconnect events
  Stream<void> get disconnects => _transport.disconnects;

  /// Check if client is connected to server
  bool get isConnected => _transport.isConnected;

  /// Check if client is authenticated
  bool get isAuthenticated => _isAuthenticated;
  int? get userId => _authenticatedUserId;
  String? get username => _authenticatedUsername;
  int? get authenticatedUserId => _authenticatedUserId;
  String? get authenticatedUsername => _authenticatedUsername;

  /// Connect to Aegis server
  Future<void> connect(
    String host,
    int port, {
    Duration? timeout,
    String? transportMaskingKey,
    bool enableMaskingAutoFallback = true,
  }) async {
    final hasMaskingKey =
        transportMaskingKey != null && transportMaskingKey.trim().isNotEmpty;

    if (!hasMaskingKey || !enableMaskingAutoFallback) {
      await _transport.connect(
        host,
        port,
        timeout: timeout,
        transportMaskingKey: transportMaskingKey,
      );
      await _performHandshake();
      return;
    }

    try {
      await _transport.connect(
        host,
        port,
        timeout: timeout,
        transportMaskingKey: transportMaskingKey,
      );
      await _performHandshake();
    } catch (firstError) {
      await _transport.disconnect();
      try {
        await _transport.connect(host, port, timeout: timeout);
        await _performHandshake();
      } catch (secondError) {
        throw Exception(
          'Failed connect with masking and fallback. maskedError: '
          '$firstError; plainError: $secondError',
        );
      }
    }
  }

  /// Authenticate with server
  Future<AuthResponsePayload> authenticate(String authToken) async {
    return authenticateWithToken(authToken);
  }

  Future<void> login(
    String username,
    String password, {
    String clientInfo = 'aegis-dart-client',
  }) async {
    await authenticateWithPassword(
      username: username,
      password: password,
      clientInfo: clientInfo,
    );
  }

  Future<void> loginWithToken(String token) async {
    await authenticateWithToken(token);
  }

  Future<AuthResponsePayload> authenticateWithToken(String authToken) async {
    if (!_transport.isConnected) {
      throw NotConnectedException();
    }

    final response = await _authenticateRaw(token: authToken);
    _authToken = response.sessionToken.isNotEmpty ? response.sessionToken : authToken;
    _setAuthenticated(response);
    await _publishPresence(isOnline: true);
    return response;
  }

  Future<AuthResponsePayload> authenticateWithPassword({
    required String username,
    required String password,
    String clientInfo = 'two_space_app_flutter',
  }) async {
    if (!_transport.isConnected) {
      throw NotConnectedException();
    }

    final response = await _authenticateRaw(
      username: username,
      password: password,
      clientInfo: clientInfo,
    );
    _authToken = response.sessionToken.isNotEmpty
        ? response.sessionToken
        : '$username:$password';
    _setAuthenticated(response);
    await _publishPresence(isOnline: true);
    return response;
  }

  /// Send a text message
  Future<void> sendMessage(String text, {int? toUserId}) async {
    if (!_transport.isConnected) {
      throw NotConnectedException();
    }

    if (!_isAuthenticated) {
      throw Exception('Client is not authenticated');
    }

    final payload = utf8.encode(
      jsonEncode({
        'RecipientId': toUserId ?? 0,
        'Content': text,
      }),
    );

    final message = Message.withType(MessageType.message, payload);
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);
  }

  /// Send ping message
  Future<void> ping() async {
    if (!_transport.isConnected) {
      throw NotConnectedException();
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final message =
        Message.withType(MessageType.ping, _int64ToBytes(timestamp));

    await _transport.sendMessage(message);
  }

  /// Disconnect from server
  Future<void> disconnect() async {
    if (_transport.isConnected && _isAuthenticated) {
      await _publishPresence(isOnline: false);
    }
    await _transport.disconnect();
    _isAuthenticated = false;
    _authToken = null;
    _authenticatedUserId = null;
    _authenticatedUsername = null;
  }

  Future<void> setPresence({required bool isOnline}) async {
    _ensureAuthenticated();
    await _publishPresence(isOnline: isOnline);
  }

  Future<void> _performHandshake() async {
    final handshake = await AegisHandshakeCrypto.createHandshake();
    final payload = utf8.encode(
      jsonEncode({
        'PublicKey': base64Encode(handshake.publicKeySpki),
        'ClientVersion': 1000,
      }),
    );
    final message = Message.withType(MessageType.handshake, payload);
    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.handshake],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Handshake timeout',
    );

    final decoded = jsonDecode(utf8.decode(responseMessage.payload));
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid handshake response');
    }

    final response = HandshakeResponsePayload.fromJson(decoded);
    if (!response.success || response.serverPublicKey == null) {
      throw Exception(response.message ?? 'Handshake failed');
    }

    final macKey = await AegisHandshakeCrypto.deriveMacKey(
      clientPrivateKey: handshake.privateKey,
      serverPublicKeySpki: base64Decode(response.serverPublicKey!),
    );
    final sessionKey = await AegisHandshakeCrypto.deriveSessionKey(
      clientPrivateKey: handshake.privateKey,
      serverPublicKeySpki: base64Decode(response.serverPublicKey!),
    );
    _transport.setMacKey(macKey);
    _transport.setSessionKey(sessionKey);
  }

  /// Convert int to 8-byte big-endian representation
  List<int> _int64ToBytes(int value) {
    final bytes = ByteData(8);
    bytes.setUint64(0, value);
    return bytes.buffer.asUint8List().toList();
  }

  /// Register a new user
  Future<RegistrationResponse> register(
      String username, String email, String password, String publicKey) async {
    if (!_transport.isConnected) {
      throw NotConnectedException();
    }

    final request = RegistrationRequest(
      username: username,
      email: email,
      password: password,
      publicKey: publicKey,
    );

    final message = Message.withType(MessageType.register, request.toBytes());
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.registerResponse],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Registration timeout',
    );

    return RegistrationResponse.fromBytes(responseMessage.payload);
  }

  /// Search for users by username
  Future<UserSearchResponse> searchUsers(String query, {int limit = 20}) async {
    if (!_transport.isConnected) {
      throw NotConnectedException();
    }

    if (!_isAuthenticated) {
      throw Exception('Client is not authenticated');
    }

    final request = UserSearchRequest(query: query, limit: limit);
    final message = Message.withType(MessageType.userSearch, request.toBytes());
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.userSearchResult],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Search timeout',
    );

    return UserSearchResponse.fromBytes(responseMessage.payload);
  }

  /// Send a message to a channel
  Future<ChannelMessageResponse> sendChannelMessage(
      int channelId, String content,
      {MessageContentType contentType = MessageContentType.text,
      int? replyToMessageId,
      ParseMode? parseMode,
      MediaAttachmentPayload? attachment}) async {
    if (!_transport.isConnected) {
      throw NotConnectedException();
    }

    if (!_isAuthenticated) {
      throw Exception('Client is not authenticated');
    }

    final request = ChannelMessageRequest(
      channelId: channelId,
      content: content,
      contentType: contentType,
      replyToMessageId: replyToMessageId,
      parseMode: parseMode?.value,
      attachment: attachment,
    );

    final message =
        Message.withType(MessageType.channelMessage, request.toBytes());
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.ack, MessageType.channelMessage],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Channel message timeout',
    );

    return ChannelMessageResponse.fromBytes(responseMessage.payload);
  }

  Future<GroupMessageSendResponse> sendGroupMessage(
    int groupId,
    String content, {
    MessageContentType contentType = MessageContentType.text,
    int? replyToMessageId,
    ParseMode? parseMode,
    MediaAttachmentPayload? attachment,
  }) async {
    _ensureAuthenticated();

    final request = GroupMessageSendRequest(
      groupId: groupId,
      content: content,
      contentType: contentType,
      replyToMessageId: replyToMessageId,
      parseMode: parseMode?.value,
      attachment: attachment,
    );
    final message = Message.withType(
      MessageType.groupMessageSend,
      request.toBytes(),
    );
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.groupMessageResponse],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Group message timeout',
    );

    return GroupMessageSendResponse.fromBytes(responseMessage.payload);
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
    return ChannelMessageResponse(
      success: response.success,
      messageId: response.messageId,
      messageText: response.messageText,
    );
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
    return ChannelMessageResponse(
      success: response.success,
      messageId: response.messageId,
      messageText: response.messageText,
    );
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
    return ChannelMessageResponse(
      success: response.success,
      messageId: response.messageId,
      messageText: response.messageText,
    );
  }

  /// Create a new channel
  Future<ChannelCreateResponse> createChannel(String name,
      {String? description, ChannelType type = ChannelType.public}) async {
    if (!_transport.isConnected) {
      throw NotConnectedException();
    }

    if (!_isAuthenticated) {
      throw Exception('Client is not authenticated');
    }

    final request = ChannelCreateRequest(
      name: name,
      description: description,
      type: type,
    );

    final message =
        Message.withType(MessageType.channelCreate, request.toBytes());
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    // Wait for response
    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.ack, MessageType.channelCreate],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Channel creation timeout',
    );

    return ChannelCreateResponse.fromBytes(responseMessage.payload);
  }

  /// Join a channel
  Future<ChannelJoinResponse> joinChannel(int channelId) async {
    if (!_transport.isConnected) {
      throw NotConnectedException();
    }

    if (!_isAuthenticated) {
      throw Exception('Client is not authenticated');
    }

    final request = ChannelJoinRequest(channelId: channelId);
    final message =
        Message.withType(MessageType.channelJoin, request.toBytes());
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    // Wait for response
    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.ack, MessageType.channelJoin],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Channel join timeout',
    );

    return ChannelJoinResponse.fromBytes(responseMessage.payload);
  }

  /// Send a private message
  Future<PrivateChatMessageResponse> sendPrivateMessage(
      int toUserId, String content,
      {
      MessageContentType contentType = MessageContentType.text,
      ParseMode? parseMode,
      MediaAttachmentPayload? attachment,
    }) async {
    if (!_transport.isConnected) {
      throw NotConnectedException();
    }

    if (!_isAuthenticated) {
      throw Exception('Client is not authenticated');
    }

    final request = PrivateChatMessageRequest(
      toUserId: toUserId,
      content: content,
      contentType: contentType,
      parseMode: parseMode?.value,
      attachment: attachment,
    );

    final message =
        Message.withType(MessageType.privateChatMessage, request.toBytes());
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    // Wait for response
    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.ack, MessageType.privateChatMessage],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Private message timeout',
    );

    return PrivateChatMessageResponse.fromBytes(responseMessage.payload);
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
    _ensureAuthenticated();

    if (mediaBytes.isEmpty) {
      throw Exception('Media file is empty');
    }
    if (mediaBytes.length > maxMediaUploadBytes) {
      throw Exception(
        'Media file too large: ${mediaBytes.length} bytes. '
        'Maximum allowed: $maxMediaUploadBytes bytes (15MB).',
      );
    }

    final estimatedBase64Length = ((mediaBytes.length + 2) ~/ 3) * 4;
    final estimatedPayloadLength = estimatedBase64Length + _mediaPayloadSafetyBytes;
    if (estimatedPayloadLength > ProtocolConstants.maxPayloadSize) {
      throw Exception(
        'Media payload exceeds protocol limit '
        '(${ProtocolConstants.maxPayloadSize} bytes).',
      );
    }

    final resolvedFileName = fileName ??
        switch (mediaKind) {
          MediaKind.photo => 'photo.jpg',
          MediaKind.video => 'video.mp4',
          MediaKind.gif => 'animation.gif',
          MediaKind.file => 'file.bin',
          MediaKind.voice => 'voice.ogg',
        };
    final resolvedMime = mimeType ??
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

    switch (chatType) {
      case ChatTargetType.private:
        final response = await sendPrivateMessage(
          chatId,
          caption ?? '',
          contentType: contentType,
          parseMode: parseMode,
          attachment: attachment,
        );
        return MediaSendResponse(
          success: response.success,
          messageId: response.messageId ?? 0,
          messageText: response.messageText,
        );
      case ChatTargetType.channel:
        final response = await sendChannelMessage(
          chatId,
          caption ?? '',
          contentType: contentType,
          replyToMessageId: replyToMessageId,
          parseMode: parseMode,
          attachment: attachment,
        );
        return MediaSendResponse(
          success: response.success,
          messageId: response.messageId ?? 0,
          messageText: response.messageText,
        );
      case ChatTargetType.group:
        final response = await sendGroupMessage(
          chatId,
          caption ?? '',
          contentType: contentType,
          replyToMessageId: replyToMessageId,
          parseMode: parseMode,
          attachment: attachment,
        );
        return MediaSendResponse(
          success: response.success,
          messageId: response.messageId ?? 0,
          messageText: response.message,
        );
    }
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
    return PrivateChatMessageResponse(
      success: response.success,
      messageId: response.messageId,
      messageText: response.messageText,
    );
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
    return PrivateChatMessageResponse(
      success: response.success,
      messageId: response.messageId,
      messageText: response.messageText,
    );
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
    return PrivateChatMessageResponse(
      success: response.success,
      messageId: response.messageId,
      messageText: response.messageText,
    );
  }

  Future<ProfileGetResponsePayload> getProfile({
    int? userId,
    String? username,
  }) async {
    final payload = <String, dynamic>{
      if (userId != null) 'UserId': userId,
      if (username != null && username.isNotEmpty) 'Username': username,
    };

    final response = await _sendJsonRequest(
      requestType: MessageType.profileGet,
      acceptedTypes: const [MessageType.profileGetResponse],
      payload: payload,
      timeout: const Duration(seconds: 10),
      errorMessage: 'Profile fetch timeout',
    );

    return ProfileGetResponsePayload.fromJson(response);
  }

  Future<ProfileGetResponsePayload> getOwnProfile() async {
    return getProfile();
  }

  Future<ProfileUpdateResponsePayload> updateProfile({
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? username,
  }) async {
    final response = await _sendJsonRequest(
      requestType: MessageType.profileUpdate,
      acceptedTypes: const [MessageType.profileUpdateResponse],
      payload: {
        if (displayName != null) 'DisplayName': displayName,
        if (avatarUrl != null) 'AvatarUrl': avatarUrl,
        if (bio != null) 'Bio': bio,
        if (username != null) 'Username': username,
      },
      timeout: const Duration(seconds: 10),
      errorMessage: 'Profile update timeout',
    );

    return ProfileUpdateResponsePayload.fromJson(response);
  }

  Future<ProfileUpdateResponsePayload> uploadUserAvatar(
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    final dataUrl = 'data:$mimeType;base64,${base64Encode(imageBytes)}';
    final result = await addProfileAvatar(dataUrl, makePrimary: true);
    if (!result.success) {
      return ProfileUpdateResponsePayload(
        success: false,
        message: result.message,
      );
    }
    final refreshed = await getProfile();
    return ProfileUpdateResponsePayload(
      success: refreshed.success,
      message: refreshed.message,
      profile: refreshed.profile,
    );
  }

  Future<ProfileAvatarMutationResponse> addProfileAvatar(
    String avatarUrl, {
    bool makePrimary = false,
  }) async {
    _ensureAuthenticated();
    final request = ProfileAvatarAddRequest(
      avatarUrl: avatarUrl,
      makePrimary: makePrimary,
    );
    final message = Message.withType(
      MessageType.profileAvatarAdd,
      request.toBytes(),
    );
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.profileAvatarAddResponse],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Profile avatar add timeout',
    );

    return ProfileAvatarMutationResponse.fromBytes(responseMessage.payload);
  }

  Future<ProfileAvatarListResponse> listProfileAvatars() async {
    _ensureAuthenticated();
    final message = Message.withType(
      MessageType.profileAvatarList,
      utf8.encode('{}'),
    );
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.profileAvatarListResponse],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Profile avatar list timeout',
    );

    return ProfileAvatarListResponse.fromBytes(responseMessage.payload);
  }

  Future<ProfileAvatarMutationResponse> deleteProfileAvatar(int avatarId) async {
    _ensureAuthenticated();
    final request = ProfileAvatarDeleteRequest(avatarId: avatarId);
    final message = Message.withType(
      MessageType.profileAvatarDelete,
      request.toBytes(),
    );
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.profileAvatarDeleteResponse],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Profile avatar delete timeout',
    );

    return ProfileAvatarMutationResponse.fromBytes(responseMessage.payload);
  }

  Future<ProfileAvatarMutationResponse> setPrimaryProfileAvatar(int avatarId) async {
    _ensureAuthenticated();
    final request = ProfileAvatarSetPrimaryRequest(avatarId: avatarId);
    final message = Message.withType(
      MessageType.profileAvatarSetPrimary,
      request.toBytes(),
    );
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.profileAvatarSetPrimaryResponse],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Profile avatar set primary timeout',
    );

    return ProfileAvatarMutationResponse.fromBytes(responseMessage.payload);
  }

  Future<ChannelLinkResponse> updateChannelLinks(
    int channelId, {
    String? publicAlias,
    bool regeneratePrivateInvite = false,
  }) async {
    _ensureAuthenticated();
    final request = ChannelLinkUpdateRequest(
      channelId: channelId,
      publicAlias: publicAlias,
      regeneratePrivateInvite: regeneratePrivateInvite,
    );
    final message = Message.withType(
      MessageType.channelLinkUpdate,
      request.toBytes(),
    );
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.channelLinkUpdateResponse],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Channel link update timeout',
    );

    return ChannelLinkResponse.fromBytes(responseMessage.payload);
  }

  Future<ChannelLinkResponse> getChannelLinks(int channelId) async {
    _ensureAuthenticated();
    final request = ChannelLinkRequest(channelId: channelId);
    final message = Message.withType(
      MessageType.channelLinkGet,
      request.toBytes(),
    );
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.channelLinkGetResponse],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Channel link get timeout',
    );

    return ChannelLinkResponse.fromBytes(responseMessage.payload);
  }

  Future<ChannelResolveResponse> resolveChannelLink(String linkOrAlias) async {
    _ensureAuthenticated();
    final request = ChannelResolveRequest(linkOrAlias: linkOrAlias);
    final message = Message.withType(
      MessageType.channelResolve,
      request.toBytes(),
    );
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.channelResolveResponse],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Channel resolve timeout',
    );

    return ChannelResolveResponse.fromBytes(responseMessage.payload);
  }

  Future<ChannelJoinResponse> joinChannelByLink(String linkOrAlias) async {
    _ensureAuthenticated();
    final request = ChannelResolveRequest(linkOrAlias: linkOrAlias);
    final message = Message.withType(
      MessageType.channelJoinByLink,
      request.toBytes(),
    );
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.channelJoinByLinkResponse],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Channel join by link timeout',
    );

    return ChannelJoinResponse.fromBytes(responseMessage.payload);
  }

  Future<ChatListResponse> getChatList() async {
    _ensureAuthenticated();

    final request = ChatListRequest();
    final message = Message.withType(MessageType.chatListRequest, request.toBytes());
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.chatListResponse],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Chat list timeout',
    );

    return ChatListResponse.fromBytes(responseMessage.payload);
  }

  Future<PrivateChatHistoryResponse> getPrivateHistory(
    int peerUserId, {
    int limit = 50,
    int? beforeMessageId,
  }) async {
    _ensureAuthenticated();

    final request = PrivateChatHistoryRequest(
      peerUserId: peerUserId,
      limit: limit,
      beforeMessageId: beforeMessageId,
    );
    final message = Message.withType(
      MessageType.privateChatHistoryRequest,
      request.toBytes(),
    );
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.privateChatHistoryResponse],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Private history timeout',
    );

    return PrivateChatHistoryResponse.fromBytes(responseMessage.payload);
  }

  Future<ChannelHistoryResponse> getChannelHistory(
    int channelId, {
    int limit = 50,
    int? beforeMessageId,
  }) async {
    _ensureAuthenticated();

    final request = ChannelHistoryRequest(
      channelId: channelId,
      limit: limit,
      beforeMessageId: beforeMessageId,
    );
    final message = Message.withType(
      MessageType.channelHistoryRequest,
      request.toBytes(),
    );
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.channelHistoryResponse],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Channel history timeout',
    );

    return ChannelHistoryResponse.fromBytes(responseMessage.payload);
  }

  Future<ChannelEditResponsePayload> editChannel({
    required int channelId,
    String? name,
    String? description,
    String? avatarUrl,
  }) async {
    final response = await _sendJsonRequest(
      requestType: MessageType.channelEdit,
      acceptedTypes: const [MessageType.channelEditResponse],
      payload: {
        'ChannelId': channelId,
        if (name != null) 'Name': name,
        if (description != null) 'Description': description,
        if (avatarUrl != null) 'AvatarUrl': avatarUrl,
      },
      timeout: const Duration(seconds: 10),
      errorMessage: 'Channel edit timeout',
    );

    return ChannelEditResponsePayload.fromJson(response);
  }

  Future<ChannelEditResponsePayload> updateChannel(
    int channelId, {
    String? name,
    String? description,
    String? avatarUrl,
  }) {
    return editChannel(
      channelId: channelId,
      name: name,
      description: description,
      avatarUrl: avatarUrl,
    );
  }

  Future<ChannelEditResponsePayload> uploadChannelAvatar(
    int channelId,
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) {
    final dataUrl = 'data:$mimeType;base64,${base64Encode(imageBytes)}';
    return updateChannel(channelId, avatarUrl: dataUrl);
  }

  Future<GroupEditResponse> updateGroup(
    int groupId, {
    String? name,
    String? description,
    String? avatarUrl,
  }) async {
    _ensureAuthenticated();

    final request = GroupEditRequest(
      groupId: groupId,
      name: name,
      description: description,
      avatarUrl: avatarUrl,
    );
    final message = Message.withType(MessageType.groupEdit, request.toBytes());
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.groupEditResponse],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Group edit timeout',
    );

    return GroupEditResponse.fromBytes(responseMessage.payload);
  }

  Future<GroupEditResponse> uploadGroupAvatar(
    int groupId,
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) {
    final dataUrl = 'data:$mimeType;base64,${base64Encode(imageBytes)}';
    return updateGroup(groupId, avatarUrl: dataUrl);
  }

  Future<MessageEditResponse> editMessage({
    required int messageId,
    required String newContent,
    String scope = 'private',
    int? channelId,
    int? groupId,
  }) async {
    _ensureAuthenticated();

    final request = MessageEditRequest(
      messageId: messageId,
      newContent: newContent,
      scope: scope,
      channelId: channelId,
      groupId: groupId,
    );
    final message = Message.withType(MessageType.messageEdit, request.toBytes());
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.messageEditResponse],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Message edit timeout',
    );

    return MessageEditResponse.fromBytes(responseMessage.payload);
  }

  Future<MessageDeleteResponse> deleteMessage({
    required int messageId,
    String scope = 'private',
    int? channelId,
    int? groupId,
  }) async {
    _ensureAuthenticated();

    final request = MessageDeleteRequest(
      messageId: messageId,
      scope: scope,
      channelId: channelId,
      groupId: groupId,
    );
    final message = Message.withType(MessageType.messageDelete, request.toBytes());
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.messageDeleteResponse],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Message delete timeout',
    );

    return MessageDeleteResponse.fromBytes(responseMessage.payload);
  }

  Future<MemberRoleUpdateResponse> updateMemberRole({
    required String scope,
    required int targetId,
    required int targetUserId,
    required int newRole,
  }) async {
    _ensureAuthenticated();

    final request = MemberRoleUpdateRequest(
      scope: scope,
      targetId: targetId,
      targetUserId: targetUserId,
      newRole: newRole,
    );
    final message = Message.withType(
      MessageType.memberRoleUpdate,
      request.toBytes(),
    );
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.memberRoleUpdateResponse],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Role update timeout',
    );

    return MemberRoleUpdateResponse.fromBytes(responseMessage.payload);
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
    _ensureAuthenticated();

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
    final message = Message.withType(
      MessageType.memberPermissionUpdate,
      request.toBytes(),
    );
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: const [MessageType.memberPermissionUpdateResponse],
      timeout: const Duration(seconds: 10),
      errorMessage: 'Permission update timeout',
    );

    return MemberPermissionUpdateResponse.fromBytes(responseMessage.payload);
  }

  void _setAuthenticated(AuthResponsePayload response) {
    _isAuthenticated = response.success;
    _authenticatedUserId = response.userId;
    _authenticatedUsername = response.username;
  }

  void _ensureAuthenticated() {
    if (!_transport.isConnected) {
      throw NotConnectedException();
    }
    if (!_isAuthenticated) {
      throw Exception('Client is not authenticated');
    }
  }

  Future<AuthResponsePayload> _authenticateRaw({
    String? username,
    String? password,
    String? token,
    String clientInfo = 'two_space_app_flutter',
  }) async {
    final response = await _sendJsonRequest(
      requestType: MessageType.auth,
      acceptedTypes: const [MessageType.ack],
      payload: {
        'Username': username ?? '',
        'Password': password ?? '',
        'Token': token ?? '',
        'ClientInfo': clientInfo,
      },
      timeout: const Duration(seconds: 10),
      errorMessage: 'Authentication timeout',
    );

    final authResponse = AuthResponsePayload.fromJson(response);
    if (!authResponse.success) {
      throw Exception(authResponse.error.isNotEmpty
          ? authResponse.error
          : 'Authentication failed');
    }
    return authResponse;
  }

  Future<Map<String, dynamic>> _sendJsonRequest({
    required MessageType requestType,
    required List<MessageType> acceptedTypes,
    required Map<String, dynamic> payload,
    required Duration timeout,
    required String errorMessage,
  }) async {
    final message = Message.withType(requestType, utf8.encode(jsonEncode(payload)));
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);
    final responseMessage = await _waitForResponse(
      sequenceId: message.sequenceId,
      acceptedTypes: acceptedTypes,
      timeout: timeout,
      errorMessage: errorMessage,
    );

    final decoded = jsonDecode(utf8.decode(responseMessage.payload));
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw Exception('Invalid response payload');
  }

  Future<Message> _waitForResponse({
    required int sequenceId,
    required List<MessageType> acceptedTypes,
    required Duration timeout,
    required String errorMessage,
  }) async {
    _throwPendingError(sequenceId);

    final pending = _takePendingMatch(sequenceId, acceptedTypes);
    if (pending != null) {
      return pending;
    }

    final completer = Completer<Message>();
    _pendingResponseWaiters[sequenceId] = _PendingResponseWaiter(
      acceptedTypes: acceptedTypes.toSet(),
      completer: completer,
    );

    try {
      _throwPendingError(sequenceId);

      final pendingAfterSubscribe = _takePendingMatch(sequenceId, acceptedTypes);
      if (pendingAfterSubscribe != null) {
        _pendingResponseWaiters.remove(sequenceId);
        return pendingAfterSubscribe;
      }

      final response = await completer.future.timeout(
        timeout,
        onTimeout: () => throw TimeoutException(errorMessage, timeout),
      );
      _removePending(response);
      return response;
    } finally {
      final waiter = _pendingResponseWaiters[sequenceId];
      if (waiter != null && identical(waiter.completer, completer)) {
        _pendingResponseWaiters.remove(sequenceId);
      }
    }
  }

  Message? _takePendingMatch(int sequenceId, List<MessageType> acceptedTypes) {
    final index = _pendingMessages.indexWhere(
      (msg) =>
          msg.sequenceId == sequenceId && acceptedTypes.contains(msg.type),
    );
    if (index < 0) return null;
    return _pendingMessages.removeAt(index);
  }

  void _removePending(Message message) {
    _pendingMessages.remove(message);
  }

  void _throwPendingError(int sequenceId) {
    final index = _pendingMessages.indexWhere(
      (msg) => msg.sequenceId == sequenceId && msg.type == MessageType.error,
    );
    if (index < 0) {
      return;
    }

    final errorMessage = _extractServerError(_pendingMessages.removeAt(index));
    throw Exception(errorMessage);
  }

  String _extractServerError(Message message) {
    if (message.payload.isEmpty) {
      return 'Server returned an error';
    }

    try {
      final decoded = jsonDecode(utf8.decode(message.payload));
      if (decoded is Map<String, dynamic>) {
        final candidates = <Object?>[
          decoded['Error'],
          decoded['error'],
          decoded['Message'],
          decoded['message'],
        ];
        for (final candidate in candidates) {
          if (candidate is String && candidate.trim().isNotEmpty) {
            return candidate;
          }
        }
      }
    } catch (_) {
    }

    final text = utf8.decode(message.payload, allowMalformed: true).trim();
    return text.isNotEmpty ? text : 'Server returned an error';
  }

  void _failPendingWaiters(Object error) {
    for (final waiter in _pendingResponseWaiters.values) {
      if (!waiter.completer.isCompleted) {
        waiter.completer.completeError(error);
      }
    }
    _pendingResponseWaiters.clear();
  }

  /// Cleanup resources
  void dispose() {
    events.dispose().ignore();
    _failPendingWaiters(
      StateError('AegisClient disposed before response was received'),
    );
    _messageController.close();
    _transport.dispose();
  }
}

class _PendingResponseWaiter {
  _PendingResponseWaiter({
    required this.acceptedTypes,
    required this.completer,
  });

  final Set<MessageType> acceptedTypes;
  final Completer<Message> completer;
}

class AuthResponsePayload {
  AuthResponsePayload({
    required this.success,
    required this.userId,
    required this.username,
    required this.sessionToken,
    required this.error,
  });

  factory AuthResponsePayload.fromJson(Map<String, dynamic> json) {
    return AuthResponsePayload(
      success: json['Success'] as bool? ?? false,
      userId: json['UserId'] as int? ?? 0,
      username: json['Username'] as String? ?? '',
      sessionToken: json['SessionToken'] as String? ?? '',
      error: json['Error'] as String? ?? '',
    );
  }

  final bool success;
  final int userId;
  final String username;
  final String sessionToken;
  final String error;
}

class HandshakeResponsePayload {
  HandshakeResponsePayload({
    required this.success,
    this.serverPublicKey,
    this.message,
  });

  factory HandshakeResponsePayload.fromJson(Map<String, dynamic> json) {
    return HandshakeResponsePayload(
      success: json['Success'] as bool? ?? false,
      serverPublicKey: json['ServerPublicKey'] as String?,
      message: json['Message'] as String?,
    );
  }

  final bool success;
  final String? serverPublicKey;
  final String? message;
}

class ProfilePayload {
  ProfilePayload({
    required this.id,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.avatars = const <ProfileAvatarData>[],
    this.presenceStatus,
    this.bio,
    this.email,
    this.createdAt,
    this.lastSeenAt,
  });

  factory ProfilePayload.fromJson(Map<String, dynamic> json) {
    return ProfilePayload(
      id: json['Id'] as int? ?? 0,
      username: json['Username'] as String? ?? '',
      displayName: json['DisplayName'] as String?,
      avatarUrl: json['AvatarUrl'] as String?,
        avatars: (json['Avatars'] as List<dynamic>? ?? const <dynamic>[])
          .map((item) => ProfileAvatarData.fromJson(item as Map<String, dynamic>))
          .toList(),
        presenceStatus: json['PresenceStatus'] as String?,
      bio: json['Bio'] as String?,
      email: json['Email'] as String?,
      createdAt: DateTime.tryParse(json['CreatedAt'] as String? ?? ''),
      lastSeenAt: DateTime.tryParse(json['LastSeenAt'] as String? ?? ''),
    );
  }

  final int id;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final List<ProfileAvatarData> avatars;
  final String? presenceStatus;
  final String? bio;
  final String? email;
  final DateTime? createdAt;
  final DateTime? lastSeenAt;
}

class ProfileGetResponsePayload {
  ProfileGetResponsePayload({
    required this.success,
    this.profile,
    this.message,
  });

  factory ProfileGetResponsePayload.fromJson(Map<String, dynamic> json) {
    return ProfileGetResponsePayload(
      success: json['Success'] as bool? ?? false,
      profile: json['Profile'] is Map<String, dynamic>
          ? ProfilePayload.fromJson(json['Profile'] as Map<String, dynamic>)
          : null,
      message: json['Message'] as String?,
    );
  }

  final bool success;
  final ProfilePayload? profile;
  final String? message;
}

class ProfileUpdateResponsePayload extends ProfileGetResponsePayload {
  ProfileUpdateResponsePayload({
    required super.success,
    super.profile,
    super.message,
  });

  factory ProfileUpdateResponsePayload.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponsePayload(
      success: json['Success'] as bool? ?? false,
      profile: json['Profile'] is Map<String, dynamic>
          ? ProfilePayload.fromJson(json['Profile'] as Map<String, dynamic>)
          : null,
      message: json['Message'] as String?,
    );
  }
}

extension on AegisClient {
  Future<void> _publishPresence({required bool isOnline}) async {
    if (!_transport.isConnected || !_isAuthenticated) {
      return;
    }
    try {
      final request = UserPresenceUpdateRequest(
        isOnline: isOnline,
        clientTimestamp: DateTime.now(),
      );
      final message = Message.withType(MessageType.userPresence, request.toBytes());
      await _transport.sendMessage(message);
    } catch (_) {
      // Presence updates are best-effort and must not break auth or disconnect.
    }
  }
}

class ChannelEditResponsePayload {
  ChannelEditResponsePayload({
    required this.success,
    this.message,
  });

  factory ChannelEditResponsePayload.fromJson(Map<String, dynamic> json) {
    return ChannelEditResponsePayload(
      success: json['Success'] as bool? ?? false,
      message: json['Message'] as String?,
    );
  }

  final bool success;
  final String? message;
}
