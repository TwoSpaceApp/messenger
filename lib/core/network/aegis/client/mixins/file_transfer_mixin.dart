import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:two_space_app/core/network/aegis/client/aegis_client_base.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';

mixin AegisFileTransferMixin on AegisClientBase {

  Future<FileTransferResponsePayload> initializeFileUpload({
    required String fileName,
    required int totalSize,
    required int totalChunks,
    String mimeType = 'application/octet-stream',
    List<int>? allowedUserIds,
  }) async {
    requireAuthenticated();

    final request = FileTransferRequest(
      action: 'init',
      fileName: fileName,
      mimeType: mimeType,
      totalSize: totalSize,
      totalChunks: totalChunks,
      allowedUserIds: allowedUserIds,
    );
    final response = await sendAndWaitResponse(
      Message.withType(MessageType.fileTransfer, request.toBytes()),
      expectedTypes: {MessageType.fileTransferResponse},
    );
    return FileTransferResponsePayload.fromBytes(response.payload);
  }

  Future<FileTransferResponsePayload> uploadFileChunk({
    required String transferId,
    required int chunkIndex,
    required String chunkDataBase64,
  }) async {
    requireAuthenticated();

    final request = FileTransferRequest(
      action: 'chunk',
      transferId: transferId,
      chunkIndex: chunkIndex,
      chunkDataBase64: chunkDataBase64,
    );
    final response = await sendAndWaitResponse(
      Message.withType(MessageType.fileTransfer, request.toBytes()),
      expectedTypes: {MessageType.fileTransferResponse},
    );
    return FileTransferResponsePayload.fromBytes(response.payload);
  }

  Future<FileTransferResponsePayload> completeFileUpload(
    String transferId,
  ) async {
    requireAuthenticated();

    final request = FileTransferRequest(
      action: 'complete',
      transferId: transferId,
    );
    final response = await sendAndWaitResponse(
      Message.withType(MessageType.fileTransfer, request.toBytes()),
      expectedTypes: {MessageType.fileTransferResponse},
    );
    return FileTransferResponsePayload.fromBytes(response.payload);
  }

  Future<FileTransferResponsePayload> startFileDownload(String fileId) async {
    requireAuthenticated();

    final request = FileTransferRequest(action: 'download', fileId: fileId);
    final response = await sendAndWaitResponse(
      Message.withType(MessageType.fileTransfer, request.toBytes()),
      expectedTypes: {MessageType.fileTransferResponse},
      timeout: const Duration(seconds: 20),
    );
    return FileTransferResponsePayload.fromBytes(response.payload);
  }

  Future<Uint8List> downloadFileBytes(
    String fileId, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    requireAuthenticated();

    final chunks = <int, String>{};
    final completer = Completer<Uint8List>();
    int? totalChunks;
    Timer? timeoutTimer;

    void resetTimer() {
      timeoutTimer?.cancel();
      timeoutTimer = Timer(timeout, () {
        if (!completer.isCompleted) {
          completer.completeError(
            TimeoutException('Timed out while downloading file $fileId', timeout),
          );
        }
      });
    }

    late final StreamSubscription<FileTransferResponsePayload> subscription;
    subscription = fileTransferChunkEvents.listen((event) {
      if (!event.success || event.fileId != fileId) {
        return;
      }
      if (event.chunkIndex == null || event.chunkDataBase64 == null) {
        return;
      }

      totalChunks = event.totalChunks ?? totalChunks;
      chunks[event.chunkIndex!] = event.chunkDataBase64!;
      resetTimer();

      final expectedChunks = totalChunks;
      if (expectedChunks == null || chunks.length < expectedChunks) {
        return;
      }

      final bytesBuilder = BytesBuilder(copy: false);
      for (var index = 0; index < expectedChunks; index++) {
        final encoded = chunks[index];
        if (encoded == null) {
          return;
        }
        bytesBuilder.add(base64Decode(encoded));
      }
      if (!completer.isCompleted) {
        completer.complete(bytesBuilder.takeBytes());
      }
    });

    resetTimer();
    final response = await startFileDownload(fileId);
    if (!response.success) {
      await subscription.cancel();
      timeoutTimer?.cancel();
      throw Exception(response.message ?? 'File download failed');
    }

    totalChunks = response.totalChunks;
    if ((totalChunks ?? 0) <= 0) {
      await subscription.cancel();
      timeoutTimer?.cancel();
      return Uint8List(0);
    }

    try {
      final bytes = await completer.future;
      final expectedSize = response.totalSize;
      if (expectedSize != null && bytes.length > expectedSize) {
        return Uint8List.sublistView(
          bytes,
          0,
          math.min(bytes.length, expectedSize),
        );
      }
      return bytes;
    } finally {
      timeoutTimer?.cancel();
      await subscription.cancel();
    }
  }
}
