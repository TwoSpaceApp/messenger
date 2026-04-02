import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:es_compression/brotli.dart';

import 'package:two_space_app/core/network/aegis/exceptions.dart';
import 'package:two_space_app/core/network/aegis/logger.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_encoder.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';
import 'package:two_space_app/core/network/aegis/protocol_constants.dart';
import 'package:two_space_app/core/network/aegis/ring_buffer.dart';
import 'package:two_space_app/core/network/aegis/security_utils.dart';
import 'package:two_space_app/core/network/aegis/session_crypto.dart';

/// TCP transport layer for Aegis client communication.
///
/// Handles socket lifecycle, frame extraction from the TCP byte stream,
/// optional XOR transport masking, backpressure, and periodic health checks.
///
/// See: `src/Aegis.Transport/TcpServer.cs` (server counterpart).
class AegisTransport {
  static final BrotliCodec _brotli = BrotliCodec();

  late Socket _socket;
  bool _isConnected = false;
  int _nextSequenceId = 1;
  Future<void> _receivePipeline = Future<void>.value();

  /// Ring buffer for accumulating TCP chunks and extracting complete frames.
  /// Replaces the old `Uint8List _pendingBytes` pattern, avoiding O(n)
  /// copies on every chunk arrival.
  final RingBuffer _pendingBuffer = RingBuffer();

  Uint8List _transportMaskingKey = Uint8List(0);
  int _inboundMaskOffset = 0;
  int _outboundMaskOffset = 0;

  StreamSubscription<Uint8List>? _socketSubscription;
  Timer? _healthCheckTimer;
  AegisSessionCrypto? _sessionCrypto;

  /// Maximum bytes buffered before pausing the socket (backpressure).
  final int _maxBufferSize;

  /// Whether reading has been paused due to backpressure.
  bool _isPaused = false;

  final StreamController<Message> _messageController =
      StreamController<Message>.broadcast();
  final StreamController<void> _disconnectController =
      StreamController<void>.broadcast();

  /// Stream of incoming decoded messages.
  Stream<Message> get messages => _messageController.stream;

  /// Stream of disconnect events.
  Stream<void> get disconnects => _disconnectController.stream;

  /// Whether the transport is connected.
  bool get isConnected => _isConnected;

  /// Create a transport with optional [maxBufferSize] for backpressure.
  AegisTransport({int maxBufferSize = 4 * 1024 * 1024})
    : _maxBufferSize = maxBufferSize;

  // ── Connection ──────────────────────────────────────────────────────

  /// Connect to the Aegis server at [host]:[port].
  ///
  /// * [timeout] — TCP connect timeout.
  /// * [transportMaskingKey] — optional XOR masking key for the transport.
  /// * [healthCheckInterval] — if provided, a periodic ping is sent
  ///   at this interval; a failure triggers a disconnect.
  Future<void> connect(
    String host,
    int port, {
    Duration? timeout,
    String? transportMaskingKey,
    Duration? healthCheckInterval,
    bool useTls = false,
  }) async {
    if (_isConnected) {
      throw ConnectionException('Already connected to server');
    }

    AegisLogger.info('Connecting to $host:$port');

    try {
      final connectTimeout = timeout ?? const Duration(seconds: 10);
      if (useTls) {
        _socket = await SecureSocket.connect(
          host,
          port,
          timeout: connectTimeout,
        ).timeout(connectTimeout);
      } else {
        _socket = await Socket.connect(
          host,
          port,
          timeout: connectTimeout,
        ).timeout(connectTimeout);
      }

      _isConnected = true;
      _nextSequenceId = 1;
      _pendingBuffer.clear();
      _inboundMaskOffset = 0;
      _outboundMaskOffset = 0;
      _isPaused = false;
      _sessionCrypto?.dispose();
      _sessionCrypto = null;

      if (transportMaskingKey != null &&
          transportMaskingKey.trim().isNotEmpty) {
        _transportMaskingKey = Uint8List.fromList(
          utf8.encode(transportMaskingKey),
        );
      } else {
        _transportMaskingKey = Uint8List(0);
      }

      AegisLogger.info('Connected to $host:$port');

      _listenForMessages();

      if (healthCheckInterval != null) {
        _startHealthCheck(healthCheckInterval);
      }
    } on Object catch (e) {
      _isConnected = false;
      AegisLogger.error('Failed to connect to $host:$port', e);
      throw ConnectionException('Failed to connect to $host:$port', e);
    }
  }

  /// Disconnect from the server.
  Future<void> disconnect() async {
    if (!_isConnected) return;

    _isConnected = false;
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    AegisLogger.info('Disconnecting from server');

    try {
      await _socketSubscription?.cancel();
      _socketSubscription = null;
      await _socket.close();
    } on Object catch (_) {
      // Best-effort close — ignore errors.
    }

    // Zero out masking key for security.
    if (_transportMaskingKey.isNotEmpty) {
      SecureBufferUtils.zeroOut(_transportMaskingKey);
    }

    _sessionCrypto?.dispose();
    _sessionCrypto = null;

    if (!_disconnectController.isClosed) _disconnectController.add(null);
  }

  void setSessionKey(Uint8List sessionKey) {
    _sessionCrypto?.dispose();
    _sessionCrypto = AegisSessionCrypto(sessionKey);
  }

  // ── Sending ─────────────────────────────────────────────────────────

  /// Send [message] to the server.
  ///
  /// Assigns a sequence ID automatically if `message.sequenceId == 0`.
  Future<void> sendMessage(Message message) async {
    if (!_isConnected) {
      throw NotConnectedException();
    }

    AegisLogger.debug(
      'Sending message: ${message.type} (seq: ${message.sequenceId})',
    );

    try {
      if (message.sequenceId == 0) {
        message.sequenceId = _getNextSequenceId();
      }

      final wireMessage = await _prepareOutboundMessage(message);
      final data = MessageEncoder.encode(wireMessage);
      final outgoing = _applyOutboundMask(data);
      _socket.add(outgoing);
      await _socket.flush();

      AegisLogger.debug('Message sent successfully');
    } on Object catch (e) {
      _isConnected = false;
      if (!_disconnectController.isClosed) _disconnectController.add(null);
      AegisLogger.error('Failed to send message', e);
      throw ConnectionException('Failed to send message', e);
    }
  }

  int _getNextSequenceId() => _nextSequenceId++;

  // ── Receiving ───────────────────────────────────────────────────────

  void _listenForMessages() {
    _socketSubscription = _socket.listen(
      (data) {
        _receivePipeline = _receivePipeline.then(
          (_) => _handleIncomingData(data),
        );
      },
      onError: (error) {
        AegisLogger.error('Socket error', error);
        _isConnected = false;
        if (!_disconnectController.isClosed) _disconnectController.add(null);
      },
      onDone: () {
        _isConnected = false;
        if (!_disconnectController.isClosed) _disconnectController.add(null);
      },
    );
  }

  /// Accumulate [data] into the ring buffer and extract complete frames.
  Future<void> _handleIncomingData(Uint8List data) async {
    if (data.isEmpty) return;

    final incoming = _applyInboundMask(data);
    _pendingBuffer.write(incoming);

    // ── Backpressure: pause socket if buffer grows too large ──────
    if (!_isPaused && _pendingBuffer.length > _maxBufferSize) {
      _socketSubscription?.pause();
      _isPaused = true;
      AegisLogger.warning(
        'Backpressure: pausing socket read '
        '(buffer ${_pendingBuffer.length} bytes)',
      );
    }

    await _extractFrames();

    // ── Resume socket once buffer drains below half-mark ─────────
    if (_isPaused && _pendingBuffer.length < _maxBufferSize ~/ 2) {
      _socketSubscription?.resume();
      _isPaused = false;
      AegisLogger.debug('Backpressure: resumed socket read');
    }
  }

  /// Parse and dispatch all complete frames currently in the ring buffer.
  Future<void> _extractFrames() async {
    while (_pendingBuffer.length >= ProtocolConstants.headerSize) {
      // Read the 4-byte payload length at header offset 17 via a
      // zero-copy view into the ring buffer.
      final plView = _pendingBuffer.peekBytes(
        ProtocolConstants.payloadLengthOffset,
        4,
      );
      final payloadLength = ByteData.view(
        plView.buffer,
        plView.offsetInBytes,
        4,
      ).getUint32(0);

      // Validate before allocating.
      if (payloadLength > ProtocolConstants.maxPayloadSize) {
        AegisLogger.error(
          'Error parsing message',
          'Invalid payload length: $payloadLength',
        );
        _pendingBuffer.clear();
        return;
      }

      final frameSize =
          ProtocolConstants.headerSize +
          payloadLength +
          ProtocolConstants.macSize;

      if (_pendingBuffer.length < frameSize) {
        break; // Incomplete frame — wait for more data.
      }

      // Extract a full frame (copy) and decode it.
      final frame = _pendingBuffer.take(frameSize);
      try {
        final message = MessageEncoder.decode(frame);
        await _unwrapInboundMessage(frame, message);
        AegisLogger.debug(
          'Received message: ${message.type} (seq: ${message.sequenceId})',
        );
        if (!_messageController.isClosed) {
          _messageController.add(message);
        }
      } on Object catch (e) {
        AegisLogger.error('Error parsing message', e);
        // Skip this frame and continue parsing the rest.
      }
    }
  }

  // ── Health checks ───────────────────────────────────────────────────

  /// Start periodic ping health checks.
  void _startHealthCheck(Duration interval) {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(interval, (_) {
      if (!_isConnected) {
        _healthCheckTimer?.cancel();
        return;
      }
      unawaited(_sendPing());
    });
  }

  Future<void> _sendPing() async {
    try {
      final pingMsg = Message.withType(MessageType.ping);
      await sendMessage(pingMsg);
    } on Object catch (_) {
      AegisLogger.warning('Health check ping failed — disconnecting');
      _isConnected = false;
      if (!_disconnectController.isClosed) _disconnectController.add(null);
    }
  }

  // ── Transport masking ───────────────────────────────────────────────

  Uint8List _applyInboundMask(Uint8List data) {
    if (_transportMaskingKey.isEmpty) return data;

    final masked = Uint8List(data.length);
    final keyLen = _transportMaskingKey.length;
    for (var i = 0; i < data.length; i++) {
      masked[i] =
          data[i] ^ _transportMaskingKey[(_inboundMaskOffset + i) % keyLen];
    }
    _inboundMaskOffset += data.length;
    return masked;
  }

  Uint8List _applyOutboundMask(Uint8List data) {
    if (_transportMaskingKey.isEmpty) return data;

    final masked = Uint8List(data.length);
    final keyLen = _transportMaskingKey.length;
    for (var i = 0; i < data.length; i++) {
      masked[i] =
          data[i] ^ _transportMaskingKey[(_outboundMaskOffset + i) % keyLen];
    }
    _outboundMaskOffset += data.length;
    return masked;
  }

  // ── Cleanup ─────────────────────────────────────────────────────────

  /// Release all resources held by the transport.
  void dispose() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    if (_isConnected) {
      disconnect().ignore();
    }
    if (!_messageController.isClosed) _messageController.close();
    if (!_disconnectController.isClosed) _disconnectController.close();
  }

  Future<Message> _prepareOutboundMessage(Message message) async {
    final sessionCrypto = _sessionCrypto;
    if (sessionCrypto == null || message.type == MessageType.handshake) {
      return message;
    }

    var preparedMessage = message;
    final alreadyCompressed =
        (preparedMessage.flags & ProtocolConstants.flagCompressed) != 0;
    if (!alreadyCompressed &&
        preparedMessage.payload.length >
            ProtocolConstants.compressionThreshold) {
      final compressed = _brotli.encode(preparedMessage.payload);
      final compressedBytes = compressed is Uint8List
          ? compressed
          : Uint8List.fromList(compressed);

      if (compressedBytes.length < preparedMessage.payload.length) {
        preparedMessage = Message()
          ..magic = preparedMessage.magic
          ..versionMajor = preparedMessage.versionMajor
          ..versionMinor = preparedMessage.versionMinor
          ..flags = preparedMessage.flags | ProtocolConstants.flagCompressed
          ..type = preparedMessage.type
          ..sequenceId = preparedMessage.sequenceId
          ..payload = compressedBytes
          ..payloadLength = compressedBytes.length;
      }
    }

    return sessionCrypto.encryptMessage(preparedMessage);
  }

  Future<void> _unwrapInboundMessage(Uint8List frame, Message message) async {
    final sessionCrypto = _sessionCrypto;
    if ((message.flags & ProtocolConstants.flagEncrypted) != 0) {
      if (sessionCrypto == null) {
        throw StateError('Encrypted message received before session key setup');
      }

      final headerBytes = Uint8List.sublistView(
        frame,
        0,
        ProtocolConstants.headerSize,
      );
      await sessionCrypto.decryptMessage(message, headerBytes);
    }

    if ((message.flags & ProtocolConstants.flagCompressed) != 0) {
      final decompressed = _brotli.decode(message.payload);
      message.payload = decompressed is Uint8List
          ? decompressed
          : Uint8List.fromList(decompressed);
      message.payloadLength = message.payload.length;
      message.flags &= ~ProtocolConstants.flagCompressed;
    }
  }
}
