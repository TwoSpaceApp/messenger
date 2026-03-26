import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;

import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';

class AegisEventDispatcher {
	AegisEventDispatcher(Stream<Message> source) {
		_subscription = source.listen(_route);
	}

	late final StreamSubscription<Message> _subscription;

	final StreamController<Message> _ackController =
			StreamController<Message>.broadcast();
	final StreamController<Message> _errorController =
			StreamController<Message>.broadcast();
	final StreamController<PrivateChatMessageEvent> _privateEventController =
			StreamController<PrivateChatMessageEvent>.broadcast();
	final StreamController<ChannelMessageEvent> _channelEventController =
			StreamController<ChannelMessageEvent>.broadcast();
	final StreamController<MessageStatusEvent> _messageStatusController =
			StreamController<MessageStatusEvent>.broadcast();
	final StreamController<ChatListResponse> _chatListController =
			StreamController<ChatListResponse>.broadcast();
	final StreamController<PrivateChatHistoryResponse> _privateHistoryController =
			StreamController<PrivateChatHistoryResponse>.broadcast();
	final StreamController<ChannelHistoryResponse> _channelHistoryController =
			StreamController<ChannelHistoryResponse>.broadcast();

	Stream<Message> get ackMessages => _ackController.stream;
	Stream<Message> get errorMessages => _errorController.stream;
	Stream<PrivateChatMessageEvent> get privateMessageEvents =>
			_privateEventController.stream;
	Stream<ChannelMessageEvent> get channelMessageEvents =>
			_channelEventController.stream;
	Stream<MessageStatusEvent> get messageStatusEvents =>
			_messageStatusController.stream;
	Stream<ChatListResponse> get chatListResponses => _chatListController.stream;
	Stream<PrivateChatHistoryResponse> get privateHistoryResponses =>
			_privateHistoryController.stream;
	Stream<ChannelHistoryResponse> get channelHistoryResponses =>
			_channelHistoryController.stream;

	Future<void> dispose() async {
		await _subscription.cancel();
		await _ackController.close();
		await _errorController.close();
		await _privateEventController.close();
		await _channelEventController.close();
		await _messageStatusController.close();
		await _chatListController.close();
		await _privateHistoryController.close();
		await _channelHistoryController.close();
	}

	void _route(Message message) {
		if (message.type == MessageType.ack) {
			_ackController.add(message);
			return;
		}

		if (message.type == MessageType.error) {
			_errorController.add(message);
			return;
		}

		if (message.type == MessageType.privateChatMessageEvent) {
			_tryEmit(
				() => PrivateChatMessageEvent.fromJson(_decodeMap(message.payload)),
				_privateEventController,
			);
			return;
		}

		if (message.type == MessageType.channelMessageEvent) {
			_tryEmit(
				() => ChannelMessageEvent.fromJson(_decodeMap(message.payload)),
				_channelEventController,
			);
			return;
		}

		if (message.type == MessageType.messageStatusEvent) {
			_tryEmit(
				() => MessageStatusEvent.fromJson(_decodeMap(message.payload)),
				_messageStatusController,
			);
			return;
		}

		if (message.type == MessageType.chatListResponse) {
			_tryEmit(
				() => ChatListResponse.fromJson(_decodeMap(message.payload)),
				_chatListController,
			);
			return;
		}

		if (message.type == MessageType.privateChatHistoryResponse) {
			_tryEmit(
				() => PrivateChatHistoryResponse.fromJson(_decodeMap(message.payload)),
				_privateHistoryController,
			);
			return;
		}

		if (message.type == MessageType.channelHistoryResponse) {
			_tryEmit(
				() => ChannelHistoryResponse.fromJson(_decodeMap(message.payload)),
				_channelHistoryController,
			);
		}
	}

	void _tryEmit<T>(T Function() parse, StreamController<T> controller) {
		try {
			controller.add(parse());
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
}
