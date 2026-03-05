import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:two_space_app/services/aegis/message.dart';
import 'package:two_space_app/services/aegis/message_encoder.dart';
import 'package:two_space_app/services/aegis/protocol_constants.dart';
import 'package:two_space_app/services/aegis/exceptions.dart';
import 'package:two_space_app/services/aegis/logger.dart';

/// TCP transport layer for Aegis client communication
class AegisTransport {
  late Socket _socket;
  bool _isConnected = false;
  int _nextSequenceId = 1;

  /// Буфер входящих байт. TCP является потоковым протоколом — одно
  /// событие `data` может содержать неполное сообщение, несколько сообщений
  /// или часть следующего. Буфер решает эту проблему.
  final List<int> _incomingBuffer = [];

  final StreamController<Message> _messageController = StreamController<Message>.broadcast();
  final StreamController<void> _disconnectController = StreamController<void>.broadcast();
  
  /// Stream of incoming messages
  Stream<Message> get messages => _messageController.stream;
  
  /// Stream of disconnect events
  Stream<void> get disconnects => _disconnectController.stream;
  
  /// Check if client is connected to server
  bool get isConnected => _isConnected;

  /// Connect to Aegis server
  Future<void> connect(String host, int port, {Duration? timeout}) async {
    if (_isConnected) {
      throw ConnectionException('Already connected to server');
    }

    AegisLogger.info('Connecting to $host:$port');
    
    try {
      // TODO(security): соединение устанавливается по plain TCP без TLS.
      //   Для продакшна необходимо использовать [SecureSocket.connect] или
      //   настроить TLS-терминацию на прокси (nginx/HAProxy).
      //   Без TLS трафик (включая токены аутентификации) виден в сети.
      _socket = await Socket.connect(host, port, timeout: timeout ?? const Duration(seconds: 10))
          .timeout(timeout ?? const Duration(seconds: 10));
      
      _isConnected = true;
      _nextSequenceId = 1;
      
      AegisLogger.info('Connected to $host:$port');
      
      // Start listening for incoming data
      _listenForMessages();
      
    } catch (e) {
      _isConnected = false;
      AegisLogger.error('Failed to connect to $host:$port', e);
      throw ConnectionException('Failed to connect to $host:$port', e);
    }
  }

  /// Disconnect from server
  Future<void> disconnect() async {
    if (!_isConnected) return;

    _isConnected = false;
    _incomingBuffer.clear();
    AegisLogger.info('Disconnecting from server');

    try {
      await _socket.close();
    } catch (e) {
      // Ignore errors during disconnect
    }

    _disconnectController.add(null);
  }

  /// Send a message to the server
  Future<void> sendMessage(Message message) async {
    if (!_isConnected) {
      throw NotConnectedException();
    }

    AegisLogger.debug('Sending message: ${message.type} (seq: ${message.sequenceId})');

    try {
      // Set sequence ID if not set
      if (message.sequenceId == 0) {
        message.sequenceId = _getNextSequenceId();
      }

      // Encode and send message
      final data = MessageEncoder.encode(message);
      _socket.add(data);
      await _socket.flush();
      
      AegisLogger.debug('Message sent successfully');
      
    } catch (e) {
      _isConnected = false;
      _disconnectController.add(null);
      AegisLogger.error('Failed to send message', e);
      throw ConnectionException('Failed to send message', e);
    }
  }

  /// Get next sequence ID
  int _getNextSequenceId() => _nextSequenceId++;

  /// Listen for incoming messages
  void _listenForMessages() {
    _socket.listen(
      (Uint8List data) {
        _handleIncomingData(data);
      },
      onError: (error) {
        _isConnected = false;
        _disconnectController.add(null);
      },
      onDone: () {
        _isConnected = false;
        _disconnectController.add(null);
      },
    );
  }

  /// Handle incoming data: accumulate in buffer and emit complete frames.
  void _handleIncomingData(Uint8List data) {
    _incomingBuffer.addAll(data);
    _processBuffer();
  }

  /// Pull complete protocol frames out of [_incomingBuffer].
  ///
  /// TCP может доставлять данные частями или склеивать несколько сообщений
  /// в одном `data`-событии. Этот метод гарантирует, что в стрим попадают
  /// только полностью принятые, целые фреймы.
  void _processBuffer() {
    while (true) {
      // Нужен хотя бы полный заголовок, чтобы знать размер сообщения.
      if (_incomingBuffer.length < ProtocolConstants.headerSize) return;

      // payloadLength — big-endian uint32 по смещению 16 в заголовке.
      final payloadLength =
          (_incomingBuffer[16] << 24) |
          (_incomingBuffer[17] << 16) |
          (_incomingBuffer[18] <<  8) |
           _incomingBuffer[19];

      // Защита от DoS: слишком большой payload разрывает соединение.
      if (payloadLength > ProtocolConstants.maxPayloadSize) {
        AegisLogger.error(
          'Превышен максимальный размер payload '
          '($payloadLength байт) — очищаем буфер и закрываем соединение.',
          null,
        );
        _incomingBuffer.clear();
        _isConnected = false;
        _disconnectController.add(null);
        return;
      }

      final totalSize =
          ProtocolConstants.headerSize + payloadLength + ProtocolConstants.macSize;

      // Ждём, пока придут все байты фрейма.
      if (_incomingBuffer.length < totalSize) return;

      // Извлекаем ровно один фрейм и удаляем его из буфера.
      try {
        final frame = Uint8List.fromList(_incomingBuffer.sublist(0, totalSize));
        _incomingBuffer.removeRange(0, totalSize);
        final message = MessageEncoder.decode(frame);
        AegisLogger.debug('Received message: type=${message.type.value} seq=${message.sequenceId}');
        _messageController.add(message);
      } catch (e) {
        // После ошибки парсинга буфер рассинхронизирован — нельзя
        // продолжать безопасно; закрываем соединение.
        AegisLogger.error('Не удалось распарсить фрейм — буфер очищен', e);
        _incomingBuffer.clear();
        _isConnected = false;
        _disconnectController.add(null);
        return;
      }
    }
  }

  /// Cleanup resources
  void dispose() {
    if (_isConnected) {
      disconnect();
    }
    _incomingBuffer.clear();
    _messageController.close();
    _disconnectController.close();
  }
}
