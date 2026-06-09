import 'package:two_space_app/core/network/aegis/client/aegis_client_base.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';

mixin AegisReceiptMixin on AegisClientBase {

  Future<MessageReceiptResponse> sendDeliveryReceipt(
    List<int> messageIds, {
    DateTime? deliveredAt,
    String? deviceId,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    requireAuthenticated();

    final request = MessageDeliveryReceiptRequest(
      messageIds: messageIds,
      deliveredAt: deliveredAt ?? DateTime.now().toUtc(),
      deviceId: deviceId,
    );

    return sendReceiptAndWaitResponse(
      MessageType.messageDeliveryReceipt,
      MessageType.messageDeliveryReceiptResponse,
      messageIds,
      request.toBytes(),
      timeout: timeout,
    );
  }

  Future<MessageReceiptResponse> sendReadReceipt(
    List<int> messageIds, {
    DateTime? readAt,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    requireAuthenticated();

    final request = MessageReadReceiptRequest(
      messageIds: messageIds,
      readAt: readAt ?? DateTime.now().toUtc(),
    );

    return sendReceiptAndWaitResponse(
      MessageType.messageReadReceipt,
      MessageType.messageReadReceiptResponse,
      messageIds,
      request.toBytes(),
      timeout: timeout,
    );
  }
}
