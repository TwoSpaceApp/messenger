import 'dart:async';

import 'package:two_space_app/core/network/aegis/logger.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';

/// Unified dispatcher that splits raw protocol messages into typed streams.
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
  final StreamController<GroupHistoryResponse> _groupHistoryController =
      StreamController<GroupHistoryResponse>.broadcast();
  final StreamController<GroupMessageEvent> _groupEventController =
      StreamController<GroupMessageEvent>.broadcast();
  final StreamController<MessageReactionEvent> _reactionEventController =
      StreamController<MessageReactionEvent>.broadcast();
  final StreamController<MessagePinEvent> _pinEventController =
      StreamController<MessagePinEvent>.broadcast();
    final StreamController<UserTypingEventPayload> _typingEventController =
      StreamController<UserTypingEventPayload>.broadcast();
    final StreamController<FileTransferResponsePayload> _fileChunkController =
      StreamController<FileTransferResponsePayload>.broadcast();
    final StreamController<SessionTerminatedEventPayload>
      _sessionTerminatedController =
      StreamController<SessionTerminatedEventPayload>.broadcast();
    final StreamController<ReadSyncEventPayload> _readSyncController =
      StreamController<ReadSyncEventPayload>.broadcast();

  // v2.1+ Protocol Event Controllers
  final StreamController<TokenExpired> _tokenExpiredController =
      StreamController<TokenExpired>.broadcast();
  final StreamController<DisconnectReason> _disconnectReasonController =
      StreamController<DisconnectReason>.broadcast();
  final StreamController<SessionConflict> _sessionConflictController =
      StreamController<SessionConflict>.broadcast();
  final StreamController<Pong> _pongController =
      StreamController<Pong>.broadcast();
  final StreamController<ServerOverloaded> _serverOverloadedController =
      StreamController<ServerOverloaded>.broadcast();

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

  StreamSubscription<GroupHistoryResponse> onGroupHistoryResponse(
    void Function(GroupHistoryResponse response) handler,
  ) {
    return groupHistoryResponses.listen(handler);
  }

  Stream<GroupHistoryResponse> get groupHistoryResponses =>
      _groupHistoryController.stream;

  StreamSubscription<GroupMessageEvent> onGroupMessageEvent(
    void Function(GroupMessageEvent event) handler,
  ) {
    return groupMessageEvents.listen(handler);
  }

  Stream<GroupMessageEvent> get groupMessageEvents =>
      _groupEventController.stream;

  StreamSubscription<MessageReactionEvent> onMessageReactionEvent(
    void Function(MessageReactionEvent event) handler,
  ) {
    return messageReactionEvents.listen(handler);
  }

  Stream<MessageReactionEvent> get messageReactionEvents =>
      _reactionEventController.stream;

  StreamSubscription<MessagePinEvent> onMessagePinEvent(
    void Function(MessagePinEvent event) handler,
  ) {
    return messagePinEvents.listen(handler);
  }

  Stream<MessagePinEvent> get messagePinEvents => _pinEventController.stream;
  Stream<UserTypingEventPayload> get typingEvents =>
      _typingEventController.stream;
  Stream<FileTransferResponsePayload> get fileTransferChunks =>
      _fileChunkController.stream;
  Stream<SessionTerminatedEventPayload> get sessionTerminatedEvents =>
      _sessionTerminatedController.stream;
  Stream<ReadSyncEventPayload> get readSyncEvents => _readSyncController.stream;

  StreamSubscription<UserTypingEventPayload> onTypingEvent(
    void Function(UserTypingEventPayload event) handler,
  ) {
    return typingEvents.listen(handler);
  }

  StreamSubscription<FileTransferResponsePayload> onFileTransferChunk(
    void Function(FileTransferResponsePayload event) handler,
  ) {
    return fileTransferChunks.listen(handler);
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

  StreamSubscription<Message> onAck(void Function(Message message) handler) {
    return ackMessages.listen(handler);
  }

  StreamSubscription<Message> onError(void Function(Message message) handler) {
    return errorMessages.listen(handler);
  }

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

  StreamSubscription<PrivateChatHistoryResponse> onPrivateHistoryResponse(
    void Function(PrivateChatHistoryResponse response) handler,
  ) {
    return privateHistoryResponses.listen(handler);
  }

  StreamSubscription<ChannelHistoryResponse> onChannelHistoryResponse(
    void Function(ChannelHistoryResponse response) handler,
  ) {
    return channelHistoryResponses.listen(handler);
  }

  StreamSubscription<ChatListResponse> onChatListResponse(
    void Function(ChatListResponse response) handler,
  ) {
    return chatListResponses.listen(handler);
  }

  // v2.1+ Protocol Getters
  Stream<TokenExpired> get tokenExpiredEvents => _tokenExpiredController.stream;
  Stream<DisconnectReason> get disconnectReasonEvents =>
      _disconnectReasonController.stream;
  Stream<SessionConflict> get sessionConflictEvents =>
      _sessionConflictController.stream;
  Stream<Pong> get pongEvents => _pongController.stream;
  Stream<ServerOverloaded> get serverOverloadedEvents =>
      _serverOverloadedController.stream;

  StreamSubscription<TokenExpired> onTokenExpired(
    void Function(TokenExpired event) handler,
  ) {
    return tokenExpiredEvents.listen(handler);
  }

  StreamSubscription<DisconnectReason> onDisconnectReason(
    void Function(DisconnectReason event) handler,
  ) {
    return disconnectReasonEvents.listen(handler);
  }

  StreamSubscription<SessionConflict> onSessionConflict(
    void Function(SessionConflict event) handler,
  ) {
    return sessionConflictEvents.listen(handler);
  }

  StreamSubscription<Pong> onPong(void Function(Pong event) handler) {
    return pongEvents.listen(handler);
  }

  StreamSubscription<ServerOverloaded> onServerOverloaded(
    void Function(ServerOverloaded event) handler,
  ) {
    return serverOverloadedEvents.listen(handler);
  }

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
    await _groupHistoryController.close();
    await _groupEventController.close();
    await _reactionEventController.close();
    await _pinEventController.close();
    await _typingEventController.close();
    await _fileChunkController.close();
    await _sessionTerminatedController.close();
    await _readSyncController.close();
    // v2.1+ controllers
    await _tokenExpiredController.close();
    await _disconnectReasonController.close();
    await _sessionConflictController.close();
    await _pongController.close();
    await _serverOverloadedController.close();
  }

  void _route(Message message) {
    if (message.type == MessageType.ack) {
      _ackController.add(message);
    } else if (message.type == MessageType.error) {
      _errorController.add(message);
    } else if (message.type == MessageType.privateChatMessageEvent) {
      _tryEmit(
        () => PrivateChatMessageEvent.fromBytes(message.payload),
        _privateEventController,
      );
    } else if (message.type == MessageType.channelMessageEvent) {
      _tryEmit(
        () => ChannelMessageEvent.fromBytes(message.payload),
        _channelEventController,
      );
    } else if (message.type == MessageType.messageStatusEvent) {
      _tryEmit(
        () => MessageStatusEvent.fromBytes(message.payload),
        _messageStatusController,
      );
    } else if (message.type == MessageType.chatListResponse) {
      _tryEmit(
        () => ChatListResponse.fromBytes(message.payload),
        _chatListController,
      );
    } else if (message.type == MessageType.privateChatHistoryResponse) {
      _tryEmit(
        () => PrivateChatHistoryResponse.fromBytes(message.payload),
        _privateHistoryController,
      );
    } else if (message.type == MessageType.channelHistoryResponse) {
      _tryEmit(
        () => ChannelHistoryResponse.fromBytes(message.payload),
        _channelHistoryController,
      );
    } else if (message.type == MessageType.groupHistoryResponse) {
      _tryEmit(
        () => GroupHistoryResponse.fromBytes(message.payload),
        _groupHistoryController,
      );
    } else if (message.type == MessageType.groupMessageEvent) {
      _tryEmit(
        () => GroupMessageEvent.fromBytes(message.payload),
        _groupEventController,
      );
    } else if (message.type == MessageType.messageReactionEvent) {
      _tryEmit(
        () => MessageReactionEvent.fromBytes(message.payload),
        _reactionEventController,
      );
    } else if (message.type == MessageType.messagePinEvent) {
      _tryEmit(
        () => MessagePinEvent.fromBytes(message.payload),
        _pinEventController,
      );
    } else if (message.type == MessageType.userTypingEvent) {
      _tryEmit(
        () => UserTypingEventPayload.fromBytes(message.payload),
        _typingEventController,
      );
    } else if (message.type == MessageType.fileTransferChunk) {
      _tryEmit(
        () => FileTransferResponsePayload.fromBytes(message.payload),
        _fileChunkController,
      );
    } else if (message.type == MessageType.sessionTerminatedEvent) {
      _tryEmit(
        () => SessionTerminatedEventPayload.fromBytes(message.payload),
        _sessionTerminatedController,
      );
    } else if (message.type == MessageType.readSyncEvent) {
      _tryEmit(
        () => ReadSyncEventPayload.fromBytes(message.payload),
        _readSyncController,
      );
    }
    // v2.1+ Protocol handlers
    else if (message.type == MessageType.tokenExpired) {
      _tryEmit(
        () => TokenExpired.fromBytes(message.payload),
        _tokenExpiredController,
      );
    } else if (message.type == MessageType.disconnectReason) {
      _tryEmit(
        () => DisconnectReason.fromBytes(message.payload),
        _disconnectReasonController,
      );
    } else if (message.type == MessageType.sessionConflict) {
      _tryEmit(
        () => SessionConflict.fromBytes(message.payload),
        _sessionConflictController,
      );
    } else if (message.type == MessageType.pong) {
      _tryEmit(
        () => Pong.fromBytes(message.payload),
        _pongController,
      );
    } else if (message.type == MessageType.serverOverloaded) {
      _tryEmit(
        () => ServerOverloaded.fromBytes(message.payload),
        _serverOverloadedController,
      );
    }
  }

  void _tryEmit<T>(T Function() parse, StreamController<T> controller) {
    try {
      controller.add(parse());
    } on Object catch (error) {
      AegisLogger.warning(
        'Dropped protocol payload due to parse error: $error',
      );
    }
  }
}
