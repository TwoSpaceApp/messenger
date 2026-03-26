import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:two_space_app/core/network/aegis/exceptions.dart';
import 'package:two_space_app/core/network/aegis/logger.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_encoder.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';
import 'package:two_space_app/core/network/aegis/protocol_constants.dart';
import 'package:two_space_app/core/network/aegis/ring_buffer.dart';

class AegisTransport {
	late Socket _socket;
	bool _isConnected = false;
	int _nextSequenceId = 1;
	final RingBuffer _pendingBuffer = RingBuffer();
	Uint8List _transportMaskingKey = Uint8List(0);
	int _inboundMaskOffset = 0;
	int _outboundMaskOffset = 0;
	StreamSubscription<Uint8List>? _socketSubscription;
	Timer? _healthCheckTimer;
	final int _maxBufferSize;
	bool _isPaused = false;

	final StreamController<Message> _messageController =
			StreamController<Message>.broadcast();
	final StreamController<void> _disconnectController =
			StreamController<void>.broadcast();

	AegisTransport({int maxBufferSize = 4 * 1024 * 1024})
			: _maxBufferSize = maxBufferSize;

	Stream<Message> get messages => _messageController.stream;
	Stream<void> get disconnects => _disconnectController.stream;
	bool get isConnected => _isConnected;

	Future<void> connect(
		String host,
		int port, {
		Duration? timeout,
		String? transportMaskingKey,
		Duration? healthCheckInterval,
	}) async {
		if (_isConnected) {
			throw ConnectionException('Already connected to server');
		}

		try {
			final connectTimeout = timeout ?? const Duration(seconds: 10);
			_socket = await Socket.connect(host, port, timeout: connectTimeout)
					.timeout(connectTimeout);
			_isConnected = true;
			_nextSequenceId = 1;
			_pendingBuffer.clear();
			_inboundMaskOffset = 0;
			_outboundMaskOffset = 0;
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
			message.payloadLength = message.payload.length;
			final encoded = MessageEncoder.encode(message);
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

		if (!_isPaused && _pendingBuffer.length > _maxBufferSize) {
			_socketSubscription?.pause();
			_isPaused = true;
		}

		_extractFrames();

		if (_isPaused && _pendingBuffer.length < _maxBufferSize ~/ 2) {
			_socketSubscription?.resume();
			_isPaused = false;
		}
	}

	void _extractFrames() {
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
				final message = MessageEncoder.decode(frame);
				if (!_messageController.isClosed) {
					_messageController.add(message);
				}
			} catch (error) {
				AegisLogger.error('Error decoding message', error);
			}
		}
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
