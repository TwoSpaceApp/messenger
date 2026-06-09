import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/client/aegis_client_base.dart';
import 'package:two_space_app/core/network/aegis/client/facades/channel_facade.dart';
import 'package:two_space_app/core/network/aegis/client/facades/direct_facade.dart';
import 'package:two_space_app/core/network/aegis/client/facades/group_facade.dart';
import 'package:two_space_app/core/network/aegis/client/mixins/authentication_mixin.dart';
import 'package:two_space_app/core/network/aegis/client/mixins/channel_mixin.dart';
import 'package:two_space_app/core/network/aegis/client/mixins/file_transfer_mixin.dart';
import 'package:two_space_app/core/network/aegis/client/mixins/group_mixin.dart';
import 'package:two_space_app/core/network/aegis/client/mixins/membership_mixin.dart';
import 'package:two_space_app/core/network/aegis/client/mixins/message_ops_mixin.dart';
import 'package:two_space_app/core/network/aegis/client/mixins/messaging_mixin.dart';
import 'package:two_space_app/core/network/aegis/client/mixins/profile_mixin.dart';
import 'package:two_space_app/core/network/aegis/client/mixins/reaction_pin_mixin.dart';
import 'package:two_space_app/core/network/aegis/client/mixins/receipt_mixin.dart';
import 'package:two_space_app/core/network/aegis/client/mixins/room_settings_mixin.dart';
import 'package:two_space_app/core/network/aegis/client/mixins/session_mixin.dart';
import 'package:two_space_app/core/network/aegis/client/mixins/typing_mixin.dart';
import 'package:two_space_app/core/network/aegis/event_dispatcher.dart';
import 'package:two_space_app/core/network/aegis/exceptions.dart';
import 'package:two_space_app/core/network/aegis/handshake_crypto.dart';
import 'package:two_space_app/core/network/aegis/logger.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';
import 'package:two_space_app/core/network/aegis/official_api_credentials.dart';
import 'package:two_space_app/core/network/aegis/protocol_constants.dart';
import 'package:two_space_app/core/network/aegis/session_crypto.dart';
import 'package:two_space_app/core/network/aegis/transport.dart';
import 'package:two_space_app/core/services/dev_network_logger.dart';

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

class AegisClient extends AegisClientBase with
    AegisAuthenticationMixin,
    AegisMessagingMixin,
    AegisChannelMixin,
    AegisGroupMixin,
    AegisProfileMixin,
    AegisReactionPinMixin,
    AegisMessageOpsMixin,
    AegisMembershipMixin,
    AegisReceiptMixin,
    AegisRoomSettingsMixin,
    AegisTypingMixin,
    AegisFileTransferMixin,
    AegisSessionMixin {

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
    channels = AegisChannelFacade.internal(this);
    groups = AegisGroupFacade.internal(this);
    direct = AegisDirectFacade.internal(this);
  }

  AegisClient.official() : this();

  AegisClient.withApiCredentials(AegisApiCredentials apiCredentials)
    : this(useOfficialApiCredentials: false, apiCredentials: apiCredentials);

  AegisClient.withoutApiCredentials() : this(useOfficialApiCredentials: false);

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
  int _nextSeqId = 1;

  @override
  Stream<Message> get messages => _transport.messages;

  Stream<PrivateChatMessageEvent> get privateMessageEvents =>
      events.privateMessageEvents;

  Stream<ChannelMessageEvent> get channelMessageEvents =>
      events.channelMessageEvents;

  Stream<MessageStatusEvent> get messageStatusEvents =>
      events.messageStatusEvents;

  Stream<GroupMessageEvent> get groupMessageEvents => events.groupMessageEvents;

  Stream<GroupHistoryResponse> get groupHistoryResponses =>
      events.groupHistoryResponses;

  Stream<MessageReactionEvent> get messageReactionEvents =>
      events.messageReactionEvents;

  Stream<MessagePinEvent> get messagePinEvents => events.messagePinEvents;

  Stream<UserTypingEventPayload> get typingEvents => events.typingEvents;

  @override
  Stream<FileTransferResponsePayload> get fileTransferChunkEvents =>
    events.fileTransferChunks;

  Stream<SessionTerminatedEventPayload> get sessionTerminatedEvents =>
    events.sessionTerminatedEvents;

  Stream<ReadSyncEventPayload> get readSyncEvents => events.readSyncEvents;

  Stream<void> get disconnects => _transport.disconnects;

  bool get isConnected => _transport.isConnected;

  @override
  bool get isAuthenticated => _isAuthenticated;

  int? get userId => _userId;

  String? get username => _username;

  String? get sessionToken => _sessionToken;

  AegisApiCredentials? get apiCredentials => _apiCredentials;

  StreamSubscription<PrivateChatMessageEvent> onPrivateMessageEvent(
    void Function(PrivateChatMessageEvent event) handler,
  ) {
    return privateMessageEvents.listen(handler);
  }

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

  StreamSubscription<UserTypingEventPayload> onTypingEvent(
    void Function(UserTypingEventPayload event) handler,
  ) {
    return typingEvents.listen(handler);
  }

  StreamSubscription<FileTransferResponsePayload> onFileTransferChunk(
    void Function(FileTransferResponsePayload event) handler,
  ) {
    return fileTransferChunkEvents.listen(handler);
  }

  StreamSubscription<SessionTerminatedEventPayload> onSessionTerminated(
    void Function(SessionTerminatedEventPayload event) handler,
  ) {
    return sessionTerminatedEvents.listen(handler);
  }

  StreamSubscription<ReadSyncEventPayload> onReadSyncEvent(
    void Function(ReadSyncEventPayload event) handler,
  ) {
    return readSyncEvents.listen(handler);
  }

  // ─── Connection ────────────────────────────────────────────────────────────

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

  Future<void> disconnect() async {
    if (_transport.isConnected && _isAuthenticated) {
      await publishPresence(isOnline: false);
    }

    await _transport.disconnect();
    _isAuthenticated = false;
    _userId = null;
    _username = null;
    _sessionToken = null;
  }

  void dispose() {
    events.dispose().ignore();
    _transport.dispose();
  }

  // ─── Ping / Presence ────────────────────────────────────────────────────────

  Future<void> ping() async {
    requireConnected();
    final msg = Message.withType(MessageType.ping);
    msg.sequenceId = nextSeqId++;
    await _transport.sendMessage(msg);
  }

  Future<void> setPresence({required bool isOnline}) async {
    requireAuthenticated();
    await publishPresence(isOnline: isOnline);
  }

  // ─── Internal helpers ────────────────────────────────────────────────────────

  @override
  AegisTransport get transport => _transport;

  @override
  int get nextSeqId => _nextSeqId;

  @override
  set nextSeqId(int value) {
    _nextSeqId = value;
  }

  @override
  void requireConnected() {
    if (!_transport.isConnected) throw NotConnectedException();
  }

  @override
  void requireAuthenticated() {
    requireConnected();
    if (!_isAuthenticated) throw Exception('auth.not_authenticated');
  }

  @override
  Future<Message> sendAndWaitResponse(
    Message message, {
    Set<MessageType>? expectedTypes,
    Duration timeout = const Duration(seconds: 10),
    bool allowSeqZeroForExpectedTypes = false,
    bool allowAnySequenceForExpectedTypes = false,
  }) async {
    if (expectedTypes == null || expectedTypes.isEmpty) {
      throw ArgumentError('expectedTypes must not be empty');
    }
    if (allowAnySequenceForExpectedTypes) {
      final isHandshakeOnly =
          expectedTypes.length == 1 &&
          expectedTypes.contains(MessageType.handshake);
      if (!isHandshakeOnly) {
        throw ArgumentError(
          'allowAnySequenceForExpectedTypes is only allowed for handshake',
        );
      }
    }

    message.sequenceId = _nextSeqId++;
    message.flags |= ProtocolConstants.flagRequiresAck;

    final seqId = message.sequenceId;
    final stopwatch = Stopwatch()..start();

    final completer = Completer<Message>();
    late final StreamSubscription<Message> subscription;
    Timer? timeoutTimer;
    Message? matchedResponse;
    Object? roundTripError;

    subscription = messages.listen((msg) {
      if (msg.type == MessageType.ack && !expectedTypes.contains(MessageType.ack)) {
        return;
      }

      final isMatchingSeq = msg.sequenceId == seqId;
      final isSeqZero = msg.sequenceId == 0;

      if (msg.type == MessageType.error || msg.type == MessageType.nack) {
        final canAcceptSeqZeroError = allowSeqZeroForExpectedTypes && isSeqZero;
        if (!isMatchingSeq && !canAcceptSeqZeroError) {
          return;
        }
        if (!completer.isCompleted) {
          completer.completeError(Exception(_extractProtocolErrorMessage(msg)));
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
        matchedResponse = msg;
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

    try {
      await _transport.sendMessage(message);
      matchedResponse = await completer.future;
      return matchedResponse!;
    } on Object catch (error) {
      roundTripError = error;
      rethrow;
    } finally {
      stopwatch.stop();
      timeoutTimer.cancel();
      _logProtocolRoundTrip(
        request: message,
        expectedTypes: expectedTypes,
        response: matchedResponse,
        latencyMs: stopwatch.elapsedMilliseconds,
        error: roundTripError,
        allowSeqZeroForExpectedTypes: allowSeqZeroForExpectedTypes,
        allowAnySequenceForExpectedTypes: allowAnySequenceForExpectedTypes,
      );
      await subscription.cancel();
    }
  }

  void _logProtocolRoundTrip({
    required Message request,
    required Set<MessageType> expectedTypes,
    required int latencyMs,
    required bool allowSeqZeroForExpectedTypes,
    required bool allowAnySequenceForExpectedTypes,
    Message? response,
    Object? error,
  }) {
    final requestType = request.type.name;
    DevNetworkLogger.instance.logRequest(
      method: requestType.toUpperCase(),
      url: 'aegis://protocol/$requestType',
      statusCode: error == null ? 200 : _mapProtocolErrorStatus(error),
      latencyMs: latencyMs,
      requestHeaders: <String, dynamic>{
        'sequenceId': request.sequenceId,
        'flagsHex': '0x${request.flags.toRadixString(16)}',
        'payloadLength': request.payloadLength,
        'expectedTypes': expectedTypes.map((item) => item.name).toList(),
        'allowSeqZeroForExpectedTypes': allowSeqZeroForExpectedTypes,
        'allowAnySequenceForExpectedTypes': allowAnySequenceForExpectedTypes,
        'authenticated': _isAuthenticated,
      },
      responseHeaders: response == null
          ? const <String, dynamic>{}
          : <String, dynamic>{
              'type': response.type.name,
              'sequenceId': response.sequenceId,
              'flagsHex': '0x${response.flags.toRadixString(16)}',
              'payloadLength': response.payloadLength,
            },
      requestBody: AegisLogger.decodePayload(request.payload),
      responseBody: response == null
          ? null
          : AegisLogger.decodePayload(response.payload),
      errorMessage: error?.toString(),
    );
  }

  int _mapProtocolErrorStatus(Object? error) {
    if (error is TimeoutException) {
      return 504;
    }

    final text = error?.toString().toLowerCase() ?? '';
    if (text.contains('not authenticated') || text.contains('unauthorized')) {
      return 401;
    }
    if (text.contains('invalid') || text.contains('failed')) {
      return 400;
    }
    return 500;
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
    }

    try {
      return utf8.decode(message.payload);
    } on Object catch (_) {
      return 'Protocol error: ${message.type}';
    }
  }

  @override
  Future<MessageReceiptResponse> sendReceiptAndWaitResponse(
    MessageType requestType,
    MessageType responseType,
    List<int> messageIds,
    List<int> payload, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final normalizedIds = messageIds.toSet().toList(growable: false)..sort();
    final message = Message.withType(requestType, payload)
      ..sequenceId = _nextSeqId++
      ..flags |= ProtocolConstants.flagRequiresAck;
    final requestSeqId = message.sequenceId;
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
        final isMatchingErrorSeq =
            msg.sequenceId == requestSeqId || msg.sequenceId == 0;
        if (!isMatchingErrorSeq) {
          return;
        }
        if (!completer.isCompleted) {
          completer.completeError(Exception(_extractProtocolErrorMessage(msg)));
        }
        return;
      }

      if (msg.sequenceId != requestSeqId) {
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
      }
    });

    timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException('No receipt response for $requestType', timeout),
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
    final helloResponse = await sendAndWaitResponse(
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
    final finishResponse = await sendAndWaitResponse(
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
    final response = await sendAndWaitResponse(
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
    final response = await sendAndWaitResponse(
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

  @override
  void applyAuthResponse(AuthResponse response) {
    _isAuthenticated = true;
    _userId = response.userId;
    _username = response.username;
    _sessionToken = response.sessionToken;
  }

  @override
  Future<void> publishPresence({required bool isOnline}) async {
    try {
      final request = UserPresenceUpdateRequest(
        isOnline: isOnline,
        clientTimestamp: DateTime.now().toUtc(),
      );
      final msg = Message.withType(MessageType.userPresence, request.toBytes());
      msg.sequenceId = _nextSeqId++;
      await _transport.sendMessage(msg);
    } on Object catch (_) {
    }
  }
}
