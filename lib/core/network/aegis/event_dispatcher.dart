import 'dart:async';

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
  Stream<ChatListResponse> get chatListResponses => _chatListController.stream;
  Stream<PrivateChatHistoryResponse> get privateHistoryResponses =>
      _privateHistoryController.stream;
  Stream<ChannelHistoryResponse> get channelHistoryResponses =>
      _channelHistoryController.stream;

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

  Future<void> dispose() async {
    await _subscription.cancel();
    await _ackController.close();
    await _errorController.close();
    await _privateEventController.close();
    await _channelEventController.close();
    await _chatListController.close();
    await _privateHistoryController.close();
    await _channelHistoryController.close();
  }

  void _route(Message message) {
    switch (message.type) {
      case MessageType.ack:
        _ackController.add(message);
      case MessageType.error:
        _errorController.add(message);
      case MessageType.privateChatMessageEvent:
        _tryEmit(
          () => PrivateChatMessageEvent.fromBytes(message.payload),
          _privateEventController,
        );
      case MessageType.channelMessageEvent:
        _tryEmit(
          () => ChannelMessageEvent.fromBytes(message.payload),
          _channelEventController,
        );
      case MessageType.chatListResponse:
        _tryEmit(
          () => ChatListResponse.fromBytes(message.payload),
          _chatListController,
        );
      case MessageType.privateChatHistoryResponse:
        _tryEmit(
          () => PrivateChatHistoryResponse.fromBytes(message.payload),
          _privateHistoryController,
        );
      case MessageType.channelHistoryResponse:
        _tryEmit(
          () => ChannelHistoryResponse.fromBytes(message.payload),
          _channelHistoryController,
        );
      case MessageType.unknown:
      case MessageType.auth:
      case MessageType.ping:
      case MessageType.message:
      case MessageType.handshake:
      case MessageType.nack:
      case MessageType.retransmitRequest:
      case MessageType.userPresence:
      case MessageType.groupMessage:
      case MessageType.groupCreate:
      case MessageType.groupLeave:
      case MessageType.channelMessage:
      case MessageType.channelCreate:
      case MessageType.channelJoin:
      case MessageType.channelLeave:
      case MessageType.privateChatMessage:
      case MessageType.userSearch:
      case MessageType.userSearchResult:
      case MessageType.register:
      case MessageType.registerResponse:
      case MessageType.profileUpdate:
      case MessageType.profileUpdateResponse:
      case MessageType.profileGet:
      case MessageType.profileGetResponse:
      case MessageType.messageEdit:
      case MessageType.messageEditResponse:
      case MessageType.messageDelete:
      case MessageType.messageDeleteResponse:
      case MessageType.channelEdit:
      case MessageType.channelEditResponse:
      case MessageType.groupEdit:
      case MessageType.groupEditResponse:
      case MessageType.memberRoleUpdate:
      case MessageType.memberRoleUpdateResponse:
      case MessageType.memberPermissionUpdate:
      case MessageType.memberPermissionUpdateResponse:
      case MessageType.groupMessageSend:
      case MessageType.groupMessageResponse:
      case MessageType.groupCreateResponse:
      case MessageType.chatListRequest:
      case MessageType.privateChatHistoryRequest:
      case MessageType.channelHistoryRequest:
      case MessageType.profileAvatarAdd:
      case MessageType.profileAvatarAddResponse:
      case MessageType.profileAvatarList:
      case MessageType.profileAvatarListResponse:
      case MessageType.profileAvatarDelete:
      case MessageType.profileAvatarDeleteResponse:
      case MessageType.profileAvatarSetPrimary:
      case MessageType.profileAvatarSetPrimaryResponse:
      case MessageType.channelLinkUpdate:
      case MessageType.channelLinkUpdateResponse:
      case MessageType.channelLinkGet:
      case MessageType.channelLinkGetResponse:
      case MessageType.channelResolve:
      case MessageType.channelResolveResponse:
      case MessageType.channelJoinByLink:
      case MessageType.channelJoinByLinkResponse:
        break;
    }
  }

  void _tryEmit<T>(T Function() parse, StreamController<T> controller) {
    try {
      controller.add(parse());
    } catch (_) {
      // Ignore payload parse errors so dispatcher never breaks message flow.
    }
  }
}
