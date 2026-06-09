import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/payloads/helpers.dart';

class FileTransferRequest {
  const FileTransferRequest({
    required this.action,
    this.transferId,
    this.fileId,
    this.fileName,
    this.mimeType,
    this.totalSize,
    this.totalChunks,
    this.chunkIndex,
    this.chunkDataBase64,
    this.allowedUserIds,
  });

  final String action;
  final String? transferId;
  final String? fileId;
  final String? fileName;
  final String? mimeType;
  final int? totalSize;
  final int? totalChunks;
  final int? chunkIndex;
  final String? chunkDataBase64;
  final List<int>? allowedUserIds;

  Map<String, dynamic> toJson() => {
    'Action': action,
    if (transferId != null) 'TransferId': transferId,
    if (fileId != null) 'FileId': fileId,
    if (fileName != null) 'FileName': fileName,
    if (mimeType != null) 'MimeType': mimeType,
    if (totalSize != null) 'TotalSize': totalSize,
    if (totalChunks != null) 'TotalChunks': totalChunks,
    if (chunkIndex != null) 'ChunkIndex': chunkIndex,
    if (chunkDataBase64 != null) 'ChunkDataBase64': chunkDataBase64,
    if (allowedUserIds != null) 'AllowedUserIds': allowedUserIds,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

class FileTransferResponsePayload {
  const FileTransferResponsePayload({
    required this.success,
    this.message,
    this.transferId,
    this.fileId,
    this.chunkIndex,
    this.totalChunks,
    this.chunkDataBase64,
    this.fileName,
    this.mimeType,
    this.totalSize,
  });

  factory FileTransferResponsePayload.fromJson(Map<String, dynamic> json) {
    return FileTransferResponsePayload(
      success: parseBoolValue(json["Success"]),
      message: json["Message"]?.toString(),
      transferId: json["TransferId"]?.toString(),
      fileId: json["FileId"]?.toString(),
      chunkIndex: parseNullableIntValue(json["ChunkIndex"]),
      totalChunks: parseNullableIntValue(json["TotalChunks"]),
      chunkDataBase64: json["ChunkDataBase64"]?.toString(),
      fileName: json["FileName"]?.toString(),
      mimeType: json["MimeType"]?.toString(),
      totalSize: parseNullableIntValue(json["TotalSize"]),
    );
  }

  factory FileTransferResponsePayload.fromBytes(List<int> bytes) {
    return FileTransferResponsePayload.fromJson(decodePayloadMap(bytes));
  }

  final bool success;
  final String? message;
  final String? transferId;
  final String? fileId;
  final int? chunkIndex;
  final int? totalChunks;
  final String? chunkDataBase64;
  final String? fileName;
  final String? mimeType;
  final int? totalSize;
}
