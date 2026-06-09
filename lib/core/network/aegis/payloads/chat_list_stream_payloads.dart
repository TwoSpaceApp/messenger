import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/payloads/helpers.dart';
import 'package:two_space_app/core/network/aegis/payloads/private_chat_payloads.dart';

class ChatListStreamRequest {
  ChatListStreamRequest({
    this.chunkSize = 100,
    this.compressionMethod,
  });

  factory ChatListStreamRequest.fromJson(Map<String, dynamic> json) =>
      ChatListStreamRequest(
        chunkSize: (json["ChunkSize"] as num? ?? 100).toInt(),
        compressionMethod: json["CompressionMethod"] as String?,
      );
  final int chunkSize;
  final String? compressionMethod;

  Map<String, dynamic> toJson() => {
    'ChunkSize': chunkSize,
    if (compressionMethod != null) 'CompressionMethod': compressionMethod,
  };

  List<int> toBytes() => msgpack.serialize(toJson());
}

class ChatListChunk {
  ChatListChunk({
    required this.success,
    required this.chunkIndex,
    required this.totalChunks,
    this.chunkData = const [],
    this.message,
  });

  factory ChatListChunk.fromJson(Map<String, dynamic> json) => ChatListChunk(
    success: json["Success"] as bool? ?? false,
    chunkIndex: (json["ChunkIndex"] as num? ?? 0).toInt(),
    totalChunks: (json["TotalChunks"] as num? ?? 0).toInt(),
    chunkData: (json["ChunkData"] as List<dynamic>? ?? [])
        .map((item) => ChatListItem.fromJson(item as Map<String, dynamic>))
        .toList(),
    message: json["Message"] as String?,
  );

  factory ChatListChunk.fromBytes(List<int> bytes) =>
      ChatListChunk.fromJson(decodePayloadMap(bytes));
  final bool success;
  final int chunkIndex;
  final int totalChunks;
  final List<ChatListItem> chunkData;
  final String? message;
}
