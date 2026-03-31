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
import 'package:two_space_app/core/network/aegis/session_crypto.dart';

class AegisTransport {
  static final BrotliCodec _brotli = BrotliCodec();

  late Socket _socket;
  bool _isConnected = false;
  int _nextSequenceId = 1;
  final RingBuffer _pendingBuffer = RingBuffer();
  Uint8List _transportMaskingKey = Uint8List(0);
  AegisSessionCrypto? _sessionCrypto;
  int _inboundMaskOffset = 0;
  int _outboundMaskOffset = 0;
  StreamSubscription<Uint8List>? _socketSubscription;
  Timer? _healthCheckTimer;
  final int _maxBufferSize;
  bool _isPaused = false;
  bool _isExtractingFrames = false;

  final StreamController<Message> _messageController =
      StreamController<Message>.broadcast();
  final StreamController<void> _disconnectController =
      StreamController<void>.broadcast();

  AegisTransport({int maxBufferSize = 4 * 1024 * 1024})
      : _maxBufferSize = maxBufferSize;

  Stream<Message> get messages => _messageController.stream;
  Stream<void> get disconnects => _disconnectController.stream;
  bool get isConnected => _isConnected;
  bool get hasSessionKey => _sessionCrypto != null;

  void setSessionKey(List<int> sessionKey) {
    _sessionCrypto?.dispose();
    _sessionCrypto = AegisSessionCrypto(Uint8List.fromList(sessionKey));
  }

  void clearSessionKey() {
    _sessionCrypto?.dispose();
    _sessionCrypto = null;
  }

  Future<void> connect(
    String host,
    int port, {
    Duration? timeout,
    String? transportMaskingKey,
    bool useTls = false,
    Duration? healthCheckInterval,
  }) async {
    if (_isConnected) {
      throw ConnectionException('Already connected to server');
    }

    try {
      final connectTimeout = timeout ?? const Duration(seconds: 10);
      _socket = useTls
          ? await SecureSocket.connect(
              host,
              port,
              timeout: connectTimeout,
            ).timeout(connectTimeout)
          : await Socket.connect(host, port, timeout: connectTimeout)
              .timeout(connectTimeout);
      _isConnected = true;
      _nextSequenceId = 1;
      _pendingBuffer.clear();
      _inboundMaskOffset = 0;
      _outboundMaskOffset = 0;
      _sessionCrypto?.dispose();
      _sessionCrypto = null;
      _isPaused = false;
      _transportMaskingKey =
          transportMaskingKey != null && transportMaskingKey.trim().isNotEmpty
              ? Uint8List.fromList(utf8.encode(transportMaskingKey))
              : Uint8List(0);

      _listenForMessages();
      if (healthCheckInterval != null) {
        _startHealthCheck(healthCheckInterval);
      }
    } catch (error) {
      _isConnected = false;
      throw ConnectionException('Failed to connect to $host:$port', error);
    }
  }

  Future<void> disconnect() async {
    if (!_isConnected) {
      return;
    }

    _isConnected = false;
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
    try {
      await _socketSubscription?.cancel();
      _socketSubscription = null;
      await _socket.close();
    } catch (_) {}

    _pendingBuffer.clear();
    _transportMaskingKey = Uint8List(0);
    _sessionCrypto?.dispose();
    _sessionCrypto = null;
    _inboundMaskOffset = 0;
    _outboundMaskOffset = 0;
    if (!_disconnectController.isClosed) {
      _disconnectController.add(null);
    }
  }

  Future<void> sendMessage(Message message) async {
    if (!_isConnected) {
      throw NotConnectedException();
    }

    try {
      if (message.sequenceId == 0) {
        message.sequenceId = _nextSequenceId++;
      }
      final encoded = await _prepareOutboundFrame(message);
      final outgoing = _applyOutboundMask(encoded);
      _socket.add(outgoing);
      await _socket.flush();
    } catch (error) {
      _isConnected = false;
      if (!_disconnectController.isClosed) {
        _disconnectController.add(null);
      }
      throw ConnectionException('Failed to send message', error);
    }
  }

  void _listenForMessages() {
    _socketSubscription = _socket.listen(
      _handleIncomingData,
      onError: (Object error) {
        AegisLogger.error('Socket error', error);
        _handleDisconnectSignal();
      },
      onDone: _handleDisconnectSignal,
    );
  }

  void _handleIncomingData(Uint8List data) {
    if (data.isEmpty) {
      return;
    }
    _pendingBuffer.write(_applyInboundMask(data));
    _updateBackpressure();
    unawaited(_extractFrames());
  }

  Future<void> _extractFrames() async {
    if (_isExtractingFrames) {
      return;
    }

    _isExtractingFrames = true;
    try {
      while (_pendingBuffer.length >= ProtocolConstants.headerSize) {
        final payloadLengthView =
            _pendingBuffer.peekBytes(ProtocolConstants.payloadLengthOffset, 4);
        final payloadLength = ByteData.view(
          payloadLengthView.buffer,
          payloadLengthView.offsetInBytes,
          4,
        ).getUint32(0);

        if (payloadLength > ProtocolConstants.maxPayloadSize) {
          _pendingBuffer.clear();
          _handleDisconnectSignal();
          return;
        }

        final frameSize = ProtocolConstants.headerSize + payloadLength;
        if (_pendingBuffer.length < frameSize) {
          return;
        }

        final frame = _pendingBuffer.take(frameSize);
        try {
          final message = await _finalizeInboundFrame(frame);
          if (!_messageController.isClosed) {
            _messageController.add(message);
          }
        } catch (error) {
          AegisLogger.error('Error decoding message', error);
        }
      }
    } finally {
      _isExtractingFrames = false;
      _updateBackpressure();
      if (_pendingBuffer.length >= ProtocolConstants.headerSize) {
        unawaited(_extractFrames());
      }
    }
  }

  void _updateBackpressure() {
    if (!_isPaused && _pendingBuffer.length > _maxBufferSize) {
      _socketSubscription?.pause();
      _isPaused = true;
      return;
    }

    if (_isPaused && _pendingBuffer.length < _maxBufferSize ~/ 2) {
      _socketSubscription?.resume();
      _isPaused = false;
    }
  }

  Future<Uint8List> _prepareOutboundFrame(Message message) async {
    final prepared = Message()
      ..magic = message.magic
      ..versionMajor = message.versionMajor
      ..versionMinor = message.versionMinor
      ..type = message.type
      ..sequenceId = message.sequenceId
      ..flags = message.flags
      ..payload = Uint8List.fromList(message.payload)
      ..payloadLength = message.payload.length;

    if (_sessionCrypto == null || prepared.type == MessageType.handshake) {
      return MessageEncoder.encode(prepared);
    }

    var payload = Uint8List.fromList(prepared.payload);
    var flags = prepared.flags;

    if (payload.length > ProtocolConstants.compressionThreshold) {
      try {
        final compressed = _brotli.encode(payload);
        final compressedBytes = compressed is Uint8List
            ? compressed
            : Uint8List.fromList(compressed);
        if (compressedBytes.length < payload.length) {
          payload = compressedBytes;
          flags |= ProtocolConstants.flagCompressed;
        }
      } catch (_) {}
    }

    prepared.flags = flags;
    prepared.payload = payload;
    prepared.payloadLength = payload.length;
    final encryptedMessage = await _sessionCrypto!.encryptMessage(prepared);
    return MessageEncoder.encode(encryptedMessage);
  }

  Future<Message> _finalizeInboundFrame(Uint8List frame) async {
    final message = MessageEncoder.decode(frame);
    if ((message.flags & ProtocolConstants.flagEncrypted) != 0) {
      if (_sessionCrypto == null) {
        throw const FormatException(
            'Encrypted payload received before handshake');
      }
      await _sessionCrypto!.decryptMessage(
        message,
        frame.sublist(0, ProtocolConstants.headerSize),
      );
    }

    if ((message.flags & ProtocolConstants.flagCompressed) != 0) {
      final decompressed = _brotli.decode(message.payload);
      message.payload = decompressed is Uint8List
          ? decompressed
          : Uint8List.fromList(decompressed);
      message.payloadLength = message.payload.length;
      message.flags &= ~ProtocolConstants.flagCompressed;
    }

    return message;
  }

  void _startHealthCheck(Duration interval) {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(interval, (_) {
      if (!_isConnected) {
        _healthCheckTimer?.cancel();
        return;
      }
      sendMessage(Message.withType(MessageType.ping)).catchError((_) {
        _handleDisconnectSignal();
      });
    });
  }

  Uint8List _applyInboundMask(Uint8List data) {
    if (_transportMaskingKey.isEmpty) {
      return data;
    }
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
    if (_transportMaskingKey.isEmpty) {
      return data;
    }
    final masked = Uint8List(data.length);
    final keyLen = _transportMaskingKey.length;
    for (var i = 0; i < data.length; i++) {
      masked[i] =
          data[i] ^ _transportMaskingKey[(_outboundMaskOffset + i) % keyLen];
    }
    _outboundMaskOffset += data.length;
    return masked;
  }

  void _handleDisconnectSignal() {
    _isConnected = false;
    if (!_disconnectController.isClosed) {
      _disconnectController.add(null);
    }
  }

  void dispose() {
    _healthCheckTimer?.cancel();
    if (_isConnected) {
      disconnect().ignore();
    }
    if (!_messageController.isClosed) {
      _messageController.close();
    }
    if (!_disconnectController.isClosed) {
      _disconnectController.close();
    }
  }
}
