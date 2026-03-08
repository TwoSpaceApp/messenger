import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:two_space_app/core/network/aegis/exceptions.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';
import 'package:two_space_app/core/network/aegis/protocol_constants.dart';
import 'package:two_space_app/core/network/aegis/transport.dart';

/// Main Aegis client class
class AegisClient {
  /// Create new Aegis client
  AegisClient() {
    _transport = AegisTransport();
  }
  late AegisTransport _transport;
  // ignore: unused_field
  String? _authToken;
  bool _isAuthenticated = false;

  /// Stream of incoming messages
  Stream<Message> get messages => _transport.messages;

  /// Stream of disconnect events
  Stream<void> get disconnects => _transport.disconnects;

  /// Check if client is connected to server
  bool get isConnected => _transport.isConnected;

  /// Check if client is authenticated
  bool get isAuthenticated => _isAuthenticated;

  /// Connect to Aegis server
  Future<void> connect(String host, int port, {Duration? timeout}) async {
    await _transport.connect(host, port, timeout: timeout);

    // Send handshake message
    await _sendHandshake();
  }

  /// Authenticate with server
  Future<void> authenticate(String authToken) async {
    if (!_transport.isConnected) {
      throw NotConnectedException();
    }

    final message = Message.withType(MessageType.auth);
    message.payload = utf8.encode(authToken);
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);
    _authToken = authToken;

    // Wait for ACK response (simplified - in real implementation should wait for specific response)
    await messages
        .firstWhere(
          (msg) => msg.type == MessageType.ack,
          orElse: () => throw TimeoutException(
              'Authentication timeout', const Duration(seconds: 10)),
        )
        .timeout(const Duration(seconds: 10));

    _isAuthenticated = true;
  }

  /// Send a text message
  Future<void> sendMessage(String text, {int? toUserId}) async {
    if (!_transport.isConnected) {
      throw NotConnectedException();
    }

    if (!_isAuthenticated) {
      throw Exception('Client is not authenticated');
    }

    // Create message payload: fromId(8) + toId(8) + messageType(1) + reserved(3) + text
    final payload = <int>[];

    // From user ID (placeholder - should be set after authentication)
    payload.addAll(_int64ToBytes(0));

    // To user ID (0 for broadcast)
    payload.addAll(_int64ToBytes(toUserId ?? 0));

    // Message type (0 = text)
    payload.add(0);

    // Reserved bytes
    payload.addAll([0, 0, 0]);

    // Message text
    payload.addAll(utf8.encode(text));

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
    await _transport.disconnect();
    _isAuthenticated = false;
    _authToken = null;
  }

  /// Send initial handshake
  Future<void> _sendHandshake() async {
    final message = Message.withType(MessageType.handshake);

    // Create handshake payload: clientVersion(4) + nonce(12) + publicKey(var)
    final payload = <int>[];

    // Client version (placeholder)
    payload.addAll(_int32ToBytes(1000));

    // Nonce (12 random bytes)
    final nonce = _generateNonce();
    payload.addAll(nonce);

    // Public key (placeholder - should implement real key exchange)
    payload.addAll(utf8.encode('client_public_key_placeholder'));

    message.payload = payload;

    await _transport.sendMessage(message);
  }

  /// Convert int to 8-byte big-endian representation
  List<int> _int64ToBytes(int value) {
    final bytes = ByteData(8);
    bytes.setUint64(0, value);
    return bytes.buffer.asUint8List().toList();
  }

  /// Convert int to 4-byte big-endian representation
  List<int> _int32ToBytes(int value) {
    final bytes = ByteData(4);
    bytes.setUint32(0, value);
    return bytes.buffer.asUint8List().toList();
  }

  /// Generate cryptographically secure random nonce (12 bytes).
  ///
  /// Использует [Random.secure] вместо timestamp — гарантирует
  /// непредсказуемость nonce для каждого handshake.
  List<int> _generateNonce() {
    final random = Random.secure();
    return List<int>.generate(12, (_) => random.nextInt(256));
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

    // Wait for registration response
    final responseMessage = await messages
        .firstWhere(
          (msg) => msg.type == MessageType.registerResponse,
          orElse: () => throw TimeoutException(
              'Registration timeout', const Duration(seconds: 10)),
        )
        .timeout(const Duration(seconds: 10));

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

    // Wait for search response
    final responseMessage = await messages
        .firstWhere(
          (msg) => msg.type == MessageType.userSearchResult,
          orElse: () => throw TimeoutException(
              'Search timeout', const Duration(seconds: 10)),
        )
        .timeout(const Duration(seconds: 10));

    return UserSearchResponse.fromBytes(responseMessage.payload);
  }

  /// Send a message to a channel
  Future<ChannelMessageResponse> sendChannelMessage(
      int channelId, String content,
      {MessageContentType contentType = MessageContentType.text,
      int? replyToMessageId}) async {
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
    );

    final message =
        Message.withType(MessageType.channelMessage, request.toBytes());
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    // Wait for response (simplified - in real implementation should handle different response types)
    final responseMessage = await messages
        .firstWhere(
          (msg) => msg.type == MessageType.channelMessage,
          orElse: () => throw TimeoutException(
              'Channel message timeout', const Duration(seconds: 10)),
        )
        .timeout(const Duration(seconds: 10));

    return ChannelMessageResponse.fromBytes(responseMessage.payload);
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
    final responseMessage = await messages
        .firstWhere(
          (msg) => msg.type == MessageType.channelCreate,
          orElse: () => throw TimeoutException(
              'Channel creation timeout', const Duration(seconds: 10)),
        )
        .timeout(const Duration(seconds: 10));

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
    final responseMessage = await messages
        .firstWhere(
          (msg) => msg.type == MessageType.channelJoin,
          orElse: () => throw TimeoutException(
              'Channel join timeout', const Duration(seconds: 10)),
        )
        .timeout(const Duration(seconds: 10));

    return ChannelJoinResponse.fromBytes(responseMessage.payload);
  }

  /// Send a private message
  Future<PrivateChatMessageResponse> sendPrivateMessage(
      int toUserId, String content,
      {MessageContentType contentType = MessageContentType.text}) async {
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
    );

    final message =
        Message.withType(MessageType.privateChatMessage, request.toBytes());
    message.flags = ProtocolConstants.flagRequiresAck;

    await _transport.sendMessage(message);

    // Wait for response
    final responseMessage = await messages
        .firstWhere(
          (msg) => msg.type == MessageType.privateChatMessage,
          orElse: () => throw TimeoutException(
              'Private message timeout', const Duration(seconds: 10)),
        )
        .timeout(const Duration(seconds: 10));

    return PrivateChatMessageResponse.fromBytes(responseMessage.payload);
  }

  /// Cleanup resources
  void dispose() {
    _transport.dispose();
  }
}
