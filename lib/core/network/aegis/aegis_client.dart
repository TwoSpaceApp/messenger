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
import 'package:two_space_app/core/network/aegis/protocol_constants.dart';
import 'package:two_space_app/core/network/aegis/transport.dart';

String _encodeMediaAttachmentBase64(Uint8List mediaBytes) =>
    base64Encode(mediaBytes);

class AegisClient {
  static const int maxMediaUploadBytes = 15 * 1024 * 1024;
  static const int _mediaPayloadSafetyBytes = 2048;

  AegisClient() {
    _transport = AegisTransport();
    events = AegisEventDispatcher(_transport.messages);
    _transportDisconnectSub = _transport.disconnects.listen((_) {
      _isAuthenticated = false;
      _authenticatedUserId = null;
      _authenticatedUsername = null;
    });
  }

  late AegisTransport _transport;
  late final AegisEventDispatcher events;
  StreamSubscription<void>? _transportDisconnectSub;
  bool _isAuthenticated = false;
  int? _authenticatedUserId;
  String? _authenticatedUsername;
  int _nextSeqId = 1;

  Stream<Message> get messages => _transport.messages;
  Stream<PrivateChatMessageEvent> get privateMessageEvents =>
      events.privateMessageEvents;
  Stream<ChannelMessageEvent> get channelMessageEvents =>
      events.channelMessageEvents;
  Stream<MessageStatusEvent> get messageStatusEvents =>
      events.messageStatusEvents;
  Stream<void> get disconnects => _transport.disconnects;

  bool get isConnected => _transport.isConnected;
  bool get isAuthenticated => _isAuthenticated;
  int? get userId => _authenticatedUserId;
  String? get username => _authenticatedUsername;
  int? get authenticatedUserId => _authenticatedUserId;
  String? get authenticatedUsername => _authenticatedUsername;

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
      await _sendHandshake();
      return;
    }

    try {
      await _transport.connect(
        host,
        port,
        timeout: timeout,
        transportMaskingKey: transportMaskingKey,
      );
      await _sendHandshake();
    } catch (firstError) {
      await _transport.disconnect();
      try {
        await _transport.connect(host, port, timeout: timeout);
        await _sendHandshake();
      } catch (secondError) {
        throw Exception(
          'Failed connect with masking and fallback. maskedError: '
          '$firstError; plainError: $secondError',
        );
      }
    }
  }

  Future<void> disconnect() async {
    if (_transport.isConnected && _isAuthenticated) {
      await _publishPresence(isOnline: false);
    }
    await _transport.disconnect();
    _isAuthenticated = false;
    _authenticatedUserId = null;
    _authenticatedUsername = null;
  }

  Future<AuthResponsePayload> authenticate(String authToken) {
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
    _ensureConnected();
    final response = await _authenticateRaw(
      token: authToken,
    );
    _setAuthenticated(response);
    await _publishPresence(isOnline: true);
    return response;
  }

  Future<AuthResponsePayload> authenticateWithPassword({
    required String username,
    required String password,
    String clientInfo = 'two_space_app_flutter',
  }) async {
    _ensureConnected();
    final response = await _authenticateRaw(
      username: username,
      password: password,
      clientInfo: clientInfo,
    );
    _setAuthenticated(response);
    await _publishPresence(isOnline: true);
    return response;
  }

  Future<RegistrationResponse> register(
    String username,
    String email,
    String password,
    String publicKey,
  ) async {
    _ensureConnected();
    final response = await _sendRequest(
      messageType: MessageType.register,
      payload: {
        'Username': username,
        'Email': email,
        'Password': password,
        'PublicKey': publicKey,
      },
      expectedTypes: const {MessageType.registerResponse},
    );
    return RegistrationResponse.fromJson(_decodeMap(response.payload));
  }

  Future<UserSearchResponse> searchUsers(String query, {int limit = 20}) async {
    _ensureAuthenticated();
    final response = await _sendRequest(
      messageType: MessageType.userSearch,
      payload: UserSearchRequest(query: query, limit: limit).toJson(),
      expectedTypes: const {MessageType.userSearchResult},
    );
    return UserSearchResponse.fromJson(_decodeMap(response.payload));
  }

  Future<PrivateChatMessageResponse> sendPrivateMessage(
    int toUserId,
    String content, {
    MessageContentType contentType = MessageContentType.text,
    ParseMode? parseMode,
  }) async {
    _ensureAuthenticated();
    final response = await _sendRequest(
      messageType: MessageType.privateChatMessage,
      payload: {
        'ToUserId': toUserId,
        'Content': content,
        'ContentType': contentType.value,
        if (parseMode != null) 'ParseMode': parseMode.value,
      },
      expectedTypes: const {MessageType.privateChatMessage, MessageType.ack},
    );
    return PrivateChatMessageResponse.fromJson(_decodeMap(response.payload));
  }

  Future<ChannelMessageResponse> sendChannelMessage(
    int channelId,
    String content, {
    MessageContentType contentType = MessageContentType.text,
    int? replyToMessageId,
    ParseMode? parseMode,
    MediaAttachmentPayload? attachment,
  }) async {
    _ensureAuthenticated();
    final response = await _sendRequest(
      messageType: MessageType.channelMessage,
      payload: {
        'ChannelId': channelId,
        'Content': content,
        'ContentType': contentType.value,
        if (replyToMessageId != null) 'ReplyToMessageId': replyToMessageId,
        if (parseMode != null) 'ParseMode': parseMode.value,
        if (attachment != null) 'Attachment': attachment.toJson(),
      },
      expectedTypes: const {MessageType.channelMessage, MessageType.ack},
    );
    return ChannelMessageResponse.fromJson(_decodeMap(response.payload));
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
    void Function(double progress)? onProgress,
  }) async {
    _ensureAuthenticated();
    if (mediaBytes.isEmpty) {
      throw ArgumentError('mediaBytes must not be empty');
    }
    if (mediaBytes.length + _mediaPayloadSafetyBytes > maxMediaUploadBytes) {
      throw ArgumentError('media payload exceeds client limit');
    }

    final resolvedFileName = fileName ?? _defaultFileNameFor(mediaKind);
    final resolvedMimeType = mimeType ?? _defaultMimeTypeFor(mediaKind);
    final attachment = MediaAttachmentPayload(
      fileName: resolvedFileName,
      mimeType: resolvedMimeType,
      base64Data: _encodeMediaAttachmentBase64(mediaBytes),
      sizeBytes: mediaBytes.length,
    );
    onProgress?.call(0.6);

    final payload = <String, dynamic>{
      if (caption != null) 'Content': caption,
      'ContentType': _contentTypeForMedia(mediaKind).value,
      'Attachment': attachment.toJson(),
      'Attachments': [attachment.toJson()],
      if (parseMode != null) 'ParseMode': parseMode.value,
      if (replyToMessageId != null) 'ReplyToMessageId': replyToMessageId,
    };

    late Message response;
    switch (chatType) {
      case ChatTargetType.private:
        response = await _sendRequest(
          messageType: MessageType.privateChatMessage,
          payload: {
            'ToUserId': chatId,
            ...payload,
          },
          expectedTypes: const {
            MessageType.privateChatMessage,
            MessageType.ack
          },
        );
        final parsed =
            PrivateChatMessageResponse.fromJson(_decodeMap(response.payload));
        onProgress?.call(0.92);
        return MediaSendResponse(
          success: parsed.success,
          messageId: parsed.messageId ?? 0,
          messageText: parsed.messageText,
        );
      case ChatTargetType.channel:
        response = await _sendRequest(
          messageType: MessageType.channelMessage,
          payload: {
            'ChannelId': chatId,
            ...payload,
          },
          expectedTypes: const {MessageType.channelMessage, MessageType.ack},
        );
        final parsed =
            ChannelMessageResponse.fromJson(_decodeMap(response.payload));
        onProgress?.call(0.92);
        return MediaSendResponse(
          success: parsed.success,
          messageId: parsed.messageId ?? 0,
          messageText: parsed.messageText,
        );
      case ChatTargetType.group:
        response = await _sendRequest(
          messageType: MessageType.groupMessageSend,
          payload: {
            'GroupId': chatId,
            ...payload,
          },
          expectedTypes: const {
            MessageType.groupMessageResponse,
            MessageType.ack
          },
        );
        final parsed =
            GroupMessageSendResponse.fromJson(_decodeMap(response.payload));
        onProgress?.call(0.92);
        return MediaSendResponse(
          success: parsed.success,
          messageId: parsed.messageId ?? 0,
          messageText: parsed.message,
        );
    }
  }

  Future<MessageEditResponse> editMessage({
    required int messageId,
    required String newContent,
    String scope = 'private',
    int? channelId,
    int? groupId,
  }) async {
    _ensureAuthenticated();
    final response = await _sendRequest(
      messageType: MessageType.messageEdit,
      payload: {
        'MessageId': messageId,
        'NewContent': newContent,
        'Scope': scope,
        if (channelId != null) 'ChannelId': channelId,
        if (groupId != null) 'GroupId': groupId,
      },
      expectedTypes: const {MessageType.messageEditResponse},
    );
    return MessageEditResponse.fromJson(_decodeMap(response.payload));
  }

  Future<MessageDeleteResponse> deleteMessage({
    required int messageId,
    String scope = 'private',
    int? channelId,
    int? groupId,
  }) async {
    _ensureAuthenticated();
    final response = await _sendRequest(
      messageType: MessageType.messageDelete,
      payload: {
        'MessageId': messageId,
        'Scope': scope,
        if (channelId != null) 'ChannelId': channelId,
        if (groupId != null) 'GroupId': groupId,
      },
      expectedTypes: const {MessageType.messageDeleteResponse},
    );
    return MessageDeleteResponse.fromJson(_decodeMap(response.payload));
  }

  Future<ChannelCreateResponse> createChannel(
    String name, {
    String? description,
    ChannelType type = ChannelType.public,
  }) async {
    _ensureAuthenticated();
    final response = await _sendRequest(
      messageType: MessageType.channelCreate,
      payload: ChannelCreateRequest(
        name: name,
        description: description,
        type: type,
      ).toJson(),
      expectedTypes: const {MessageType.channelCreate, MessageType.ack},
    );
    return ChannelCreateResponse.fromJson(_decodeMap(response.payload));
  }

  Future<ChannelEditResponse> editChannel({
    required int channelId,
    String? name,
    String? description,
    String? avatarUrl,
  }) async {
    _ensureAuthenticated();
    final response = await _sendRequest(
      messageType: MessageType.channelEdit,
      payload: {
        'ChannelId': channelId,
        if (name != null) 'Name': name,
        if (description != null) 'Description': description,
        if (avatarUrl != null) 'AvatarUrl': avatarUrl,
      },
      expectedTypes: const {MessageType.channelEditResponse, MessageType.ack},
    );
    return ChannelEditResponse.fromJson(_decodeMap(response.payload));
  }

  Future<ChannelEditResponse> uploadChannelAvatar(
    int channelId,
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    final dataUrl = 'data:$mimeType;base64,${base64Encode(imageBytes)}';
    return editChannel(channelId: channelId, avatarUrl: dataUrl);
  }

  Future<ProfileGetResponse> getOwnProfile() async {
    _ensureAuthenticated();
    final response = await _sendRequest(
      messageType: MessageType.profileGet,
      payload: const <String, dynamic>{},
      expectedTypes: const {MessageType.profileGetResponse},
    );
    return ProfileGetResponse.fromJson(_decodeMap(response.payload));
  }

  Future<ProfileGetResponse> getProfile({int? userId, String? username}) async {
    _ensureAuthenticated();
    final response = await _sendRequest(
      messageType: MessageType.profileGet,
      payload: {
        if (userId != null) 'UserId': userId,
        if (username != null) 'Username': username,
      },
      expectedTypes: const {MessageType.profileGetResponse},
    );
    return ProfileGetResponse.fromJson(_decodeMap(response.payload));
  }

  Future<ProfileUpdateResponse> updateProfile({
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? username,
  }) async {
    _ensureAuthenticated();
    final response = await _sendRequest(
      messageType: MessageType.profileUpdate,
      payload: {
        if (displayName != null) 'DisplayName': displayName,
        if (avatarUrl != null) 'AvatarUrl': avatarUrl,
        if (bio != null) 'Bio': bio,
        if (username != null) 'Username': username,
      },
      expectedTypes: const {MessageType.profileUpdateResponse},
    );
    return ProfileUpdateResponse.fromJson(_decodeMap(response.payload));
  }

  Future<ProfileUpdateResponse> uploadUserAvatar(
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    final dataUrl = 'data:$mimeType;base64,${base64Encode(imageBytes)}';
    final avatarResponse = await _sendRequest(
      messageType: MessageType.profileAvatarAdd,
      payload: {
        'AvatarUrl': dataUrl,
        'MakePrimary': true,
      },
      expectedTypes: const {MessageType.profileAvatarAddResponse},
    );
    final result = ProfileAvatarMutationResponse.fromJson(
      _decodeMap(avatarResponse.payload),
    );
    return ProfileUpdateResponse(
      success: result.success,
      message: result.message,
    );
  }

  Future<ChannelLinkResponse> updateChannelLinks(
    int channelId, {
    String? publicAlias,
    bool regeneratePrivateInvite = false,
  }) async {
    _ensureAuthenticated();
    final response = await _sendRequest(
      messageType: MessageType.channelLinkUpdate,
      payload: {
        'ChannelId': channelId,
        if (publicAlias != null) 'PublicAlias': publicAlias,
        'RegeneratePrivateInvite': regeneratePrivateInvite,
      },
      expectedTypes: const {MessageType.channelLinkUpdateResponse},
    );
    return ChannelLinkResponse.fromJson(_decodeMap(response.payload));
  }

  Future<ChannelLinkResponse> getChannelLinks(int channelId) async {
    _ensureAuthenticated();
    final response = await _sendRequest(
      messageType: MessageType.channelLinkGet,
      payload: {'ChannelId': channelId},
      expectedTypes: const {MessageType.channelLinkGetResponse},
    );
    return ChannelLinkResponse.fromJson(_decodeMap(response.payload));
  }

  Future<ChannelResolveResponse> resolveChannelLink(String linkOrAlias) async {
    _ensureAuthenticated();
    final response = await _sendRequest(
      messageType: MessageType.channelResolve,
      payload: {'LinkOrAlias': linkOrAlias},
      expectedTypes: const {MessageType.channelResolveResponse},
    );
    return ChannelResolveResponse.fromJson(_decodeMap(response.payload));
  }

  Future<ChannelJoinResponse> joinChannelByLink(String linkOrAlias) async {
    _ensureAuthenticated();
    final response = await _sendRequest(
      messageType: MessageType.channelJoinByLink,
      payload: {'LinkOrAlias': linkOrAlias},
      expectedTypes: const {MessageType.channelJoinByLinkResponse},
    );
    return ChannelJoinResponse.fromJson(_decodeMap(response.payload));
  }

  Future<MemberRoleUpdateResponse> updateMemberRole({
    required String scope,
    required int targetId,
    required int targetUserId,
    required int newRole,
  }) async {
    _ensureAuthenticated();
    final response = await _sendRequest(
      messageType: MessageType.memberRoleUpdate,
      payload: {
        'Scope': scope,
        'TargetId': targetId,
        'TargetUserId': targetUserId,
        'NewRole': newRole,
      },
      expectedTypes: const {MessageType.memberRoleUpdateResponse},
    );
    return MemberRoleUpdateResponse.fromJson(_decodeMap(response.payload));
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
    final response = await _sendRequest(
      messageType: MessageType.memberPermissionUpdate,
      payload: {
        'Scope': scope,
        'TargetId': targetId,
        'TargetUserId': targetUserId,
        if (canSendMessages != null) 'CanSendMessages': canSendMessages,
        if (canDeleteOthersMessages != null)
          'CanDeleteOthersMessages': canDeleteOthersMessages,
        if (canEditInfo != null) 'CanEditInfo': canEditInfo,
        if (canInviteUsers != null) 'CanInviteUsers': canInviteUsers,
        if (canRemoveUsers != null) 'CanRemoveUsers': canRemoveUsers,
        if (canPinMessages != null) 'CanPinMessages': canPinMessages,
        if (canManageRoles != null) 'CanManageRoles': canManageRoles,
      },
      expectedTypes: const {MessageType.memberPermissionUpdateResponse},
    );
    return MemberPermissionUpdateResponse.fromJson(
        _decodeMap(response.payload));
  }

  Future<ChatListResponse> getChatList() async {
    _ensureAuthenticated();
    final response = await _sendRequest(
      messageType: MessageType.chatListRequest,
      payload: const <String, dynamic>{},
      expectedTypes: const {MessageType.chatListResponse},
    );
    return ChatListResponse.fromJson(_decodeMap(response.payload));
  }

  Future<PrivateChatHistoryResponse> getPrivateHistory(
    int peerUserId, {
    int limit = 100,
    int? beforeMessageId,
  }) async {
    _ensureAuthenticated();
    final response = await _sendRequest(
      messageType: MessageType.privateChatHistoryRequest,
      payload: {
        'PeerUserId': peerUserId,
        'Limit': limit,
        if (beforeMessageId != null) 'BeforeMessageId': beforeMessageId,
      },
      expectedTypes: const {MessageType.privateChatHistoryResponse},
    );
    return PrivateChatHistoryResponse.fromJson(_decodeMap(response.payload));
  }

  Future<ChannelHistoryResponse> getChannelHistory(
    int channelId, {
    int limit = 100,
    int? beforeMessageId,
  }) async {
    _ensureAuthenticated();
    final response = await _sendRequest(
      messageType: MessageType.channelHistoryRequest,
      payload: {
        'ChannelId': channelId,
        'Limit': limit,
        if (beforeMessageId != null) 'BeforeMessageId': beforeMessageId,
      },
      expectedTypes: const {MessageType.channelHistoryResponse},
    );
    return ChannelHistoryResponse.fromJson(_decodeMap(response.payload));
  }

  Future<void> sendDeliveryReceipt(
    List<int> messageIds, {
    DateTime? deliveredAt,
    String? deviceId,
  }) async {
    _ensureAuthenticated();
    final ids =
        messageIds.where((id) => id > 0).toSet().toList(growable: false);
    if (ids.isEmpty) {
      return;
    }
    await _sendRequest(
      messageType: MessageType.messageDeliveryReceipt,
      payload: {
        'MessageIds': ids,
        'DeliveredAt':
            (deliveredAt ?? DateTime.now().toUtc()).toIso8601String(),
        if (deviceId != null && deviceId.isNotEmpty) 'DeviceId': deviceId,
      },
      expectedTypes: const {
        MessageType.messageDeliveryReceiptResponse,
        MessageType.ack,
      },
    );
  }

  Future<void> sendReadReceipt(
    List<int> messageIds, {
    DateTime? readAt,
  }) async {
    _ensureAuthenticated();
    final ids =
        messageIds.where((id) => id > 0).toSet().toList(growable: false);
    if (ids.isEmpty) {
      return;
    }
    await _sendRequest(
      messageType: MessageType.messageReadReceipt,
      payload: {
        'MessageIds': ids,
        'ReadAt': (readAt ?? DateTime.now().toUtc()).toIso8601String(),
      },
      expectedTypes: const {
        MessageType.messageReadReceiptResponse,
        MessageType.ack,
      },
    );
  }

  Future<void> ping() async {
    _ensureConnected();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final message =
        Message.withType(MessageType.ping, _int64ToBytes(timestamp));
    message.sequenceId = _nextSeqId++;
    await _transport.sendMessage(message);
  }

  Future<void> setPresence({required bool isOnline}) async {
    _ensureAuthenticated();
    await _publishPresence(isOnline: isOnline);
  }

  Future<void> _sendHandshake() async {
    final handshake = await AegisHandshakeCrypto.createHandshake();
    final sequenceId = _nextSeqId++;
    final responseFuture = messages.firstWhere((candidate) {
      return candidate.sequenceId == sequenceId &&
          candidate.type == MessageType.handshake;
    }).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException(
          'No handshake response for seq=$sequenceId',
          const Duration(seconds: 10),
        );
      },
    );

    final message = Message.withType(
      MessageType.handshake,
      msgpack.serialize({
        'PublicKey': base64Encode(handshake.publicKeySpki),
        'ClientVersion': ProtocolConstants.versionMajor * 1000 +
            ProtocolConstants.versionMinor,
      }),
    )..sequenceId = sequenceId;
    await _transport.sendMessage(message);

    final response = await responseFuture;
    final handshakeResponse = HandshakeResponsePayload.fromJson(
      _decodeMap(response.payload),
    );
    if (!handshakeResponse.success ||
        (handshakeResponse.serverPublicKey?.isEmpty ?? true)) {
      throw Exception(
        (handshakeResponse.message?.isNotEmpty ?? false)
            ? handshakeResponse.message
            : 'Handshake failed',
      );
    }

    final sessionKey = await AegisHandshakeCrypto.deriveSessionKey(
      clientPrivateKey: handshake.privateKey,
      serverPublicKeySpki: base64Decode(handshakeResponse.serverPublicKey!),
    );
    _transport.setSessionKey(sessionKey);
  }

  void _setAuthenticated(AuthResponsePayload response) {
    if (!response.success) {
      throw Exception(
          response.error.isNotEmpty ? response.error : 'Authentication failed');
    }
    _isAuthenticated = true;
    _authenticatedUserId = response.userId > 0 ? response.userId : null;
    _authenticatedUsername =
        response.username.isNotEmpty ? response.username : null;
  }

  Future<AuthResponsePayload> _authenticateRaw({
    String? username,
    String? password,
    String? token,
    String clientInfo = 'two_space_app_flutter',
  }) async {
    final response = await _sendRequest(
      messageType: MessageType.auth,
      payload: {
        if (username != null) 'Username': username,
        if (password != null) 'Password': password,
        if (token != null) 'Token': token,
        'ClientInfo': clientInfo,
      },
      expectedTypes: const {MessageType.auth, MessageType.ack},
    );
    final authResponse =
        AuthResponsePayload.fromJson(_decodeMap(response.payload));
    if (!authResponse.success) {
      throw Exception(
        authResponse.error.isNotEmpty
            ? authResponse.error
            : 'Authentication failed',
      );
    }
    return authResponse;
  }

  Future<Message> _sendRequest({
    required MessageType messageType,
    required Map<String, dynamic> payload,
    required Set<MessageType> expectedTypes,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final message = Message.withType(messageType, msgpack.serialize(payload));
    message.sequenceId = _nextSeqId++;
    message.flags |= ProtocolConstants.flagRequiresAck;
    final sequenceId = message.sequenceId;

    final future = messages.firstWhere((candidate) {
      return candidate.sequenceId == sequenceId;
    }).timeout(timeout, onTimeout: () {
      throw TimeoutException('No response for seq=$sequenceId', timeout);
    });

    await _transport.sendMessage(message);
    final response = await future;
    if (response.type == MessageType.error) {
      throw Exception(_extractServerError(response));
    }
    if (!expectedTypes.contains(response.type)) {
      throw Exception(
        'Unexpected response type ${response.type} for $messageType',
      );
    }
    return response;
  }

  Future<void> _publishPresence({required bool isOnline}) async {
    try {
      final payload = {
        'IsOnline': isOnline,
        'ClientTimestamp': DateTime.now().toUtc().toIso8601String(),
      };
      final message = Message.withType(
        MessageType.userPresence,
        msgpack.serialize(payload),
      )..sequenceId = _nextSeqId++;
      await _transport.sendMessage(message);
    } catch (_) {}
  }

  Map<String, dynamic> _decodeMap(Uint8List payload) {
    if (payload.isEmpty) {
      return const <String, dynamic>{};
    }
    try {
      final decoded = msgpack.deserialize(payload);
      return _normalize(decoded) as Map<String, dynamic>;
    } catch (_) {
      final decoded = jsonDecode(utf8.decode(payload));
      return _normalize(decoded) as Map<String, dynamic>;
    }
  }

  dynamic _normalize(dynamic value) {
    if (value is Map) {
      return value.map<String, dynamic>(
        (key, item) => MapEntry(key.toString(), _normalize(item)),
      );
    }
    if (value is List) {
      return value.map(_normalize).toList(growable: false);
    }
    return value;
  }

  String _extractServerError(Message message) {
    final map = _decodeMap(message.payload);
    final candidate = map['Error'] ?? map['Message'] ?? map['MessageText'];
    return candidate is String && candidate.isNotEmpty
        ? candidate
        : 'Server returned ${message.type}';
  }

  void _ensureConnected() {
    if (!_transport.isConnected) {
      throw NotConnectedException();
    }
  }

  void _ensureAuthenticated() {
    _ensureConnected();
    if (!_isAuthenticated) {
      throw Exception('Client is not authenticated');
    }
  }

  List<int> _int64ToBytes(int value) {
    final bytes = ByteData(8)..setUint64(0, value);
    return bytes.buffer.asUint8List().toList();
  }

  String _defaultFileNameFor(MediaKind kind) {
    return switch (kind) {
      MediaKind.photo => 'photo.jpg',
      MediaKind.video => 'video.mp4',
      MediaKind.gif => 'animation.gif',
      MediaKind.file => 'file.bin',
      MediaKind.voice => 'voice.ogg',
    };
  }

  String _defaultMimeTypeFor(MediaKind kind) {
    return switch (kind) {
      MediaKind.photo => 'image/jpeg',
      MediaKind.video => 'video/mp4',
      MediaKind.gif => 'image/gif',
      MediaKind.file => 'application/octet-stream',
      MediaKind.voice => 'audio/ogg',
    };
  }

  MessageContentType _contentTypeForMedia(MediaKind kind) {
    return switch (kind) {
      MediaKind.photo => MessageContentType.image,
      MediaKind.video => MessageContentType.video,
      MediaKind.gif => MessageContentType.image,
      MediaKind.file => MessageContentType.file,
      MediaKind.voice => MessageContentType.audio,
    };
  }

  void dispose() {
    events.dispose().ignore();
    _transportDisconnectSub?.cancel().ignore();
    _transport.dispose();
  }
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
      userId: (json['UserId'] as num?)?.toInt() ?? 0,
      username: json['Username'] as String? ?? '',
      sessionToken: json['SessionToken'] as String? ?? '',
      error: (json['Error'] ?? json['Message']) as String? ?? '',
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
