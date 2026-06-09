import 'dart:async';

import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';
import 'package:two_space_app/core/network/aegis/transport.dart';

abstract class AegisClientBase {
  AegisTransport get transport;
  int get nextSeqId;
  set nextSeqId(int value);
  void requireConnected();
  void requireAuthenticated();
  Stream<Message> get messages;
  Stream<FileTransferResponsePayload> get fileTransferChunkEvents;

  bool get isAuthenticated;

  void applyAuthResponse(AuthResponse response);

  Future<Message> sendAndWaitResponse(
    Message message, {
    Set<MessageType>? expectedTypes,
    Duration timeout = const Duration(seconds: 10),
    bool allowSeqZeroForExpectedTypes = false,
    bool allowAnySequenceForExpectedTypes = false,
  });

  Future<MessageReceiptResponse> sendReceiptAndWaitResponse(
    MessageType requestType,
    MessageType responseType,
    List<int> messageIds,
    List<int> payload, {
    Duration timeout = const Duration(seconds: 10),
  });

  Future<void> publishPresence({required bool isOnline});
}
