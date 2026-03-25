import 'dart:async';

import 'package:drift/drift.dart';
import 'package:two_space_app/features/chat/data/local/aegis_chat_database.dart';

// Offline message model
class OfflineMessage {
  OfflineMessage({
    required this.chatId,
    required this.content,
    required this.type,
    required this.createdAt,
    this.id,
    this.sent = false,
    this.errorMessage,
  });

  factory OfflineMessage.fromMap(Map<String, dynamic> map) => OfflineMessage(
        chatId: map['chatId'] as String,
        content: map['content'] as String,
        type: map['type'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        sent: map['sent'] as bool? ?? false,
        errorMessage: map['errorMessage'] as String?,
      );
  final int? id;
  final String chatId;
  final String content;
  final String type; // 'm.text', 'm.image', etc
  final DateTime createdAt;
  final bool sent;
  final String? errorMessage;

  Map<String, dynamic> toMap() => {
        'chatId': chatId,
        'content': content,
        'type': type,
        'createdAt': createdAt.toIso8601String(),
        'sent': sent,
        'errorMessage': errorMessage,
      };
}

class OfflineQueueService {
  factory OfflineQueueService() => _instance;

  OfflineQueueService._internal();
  static final OfflineQueueService _instance = OfflineQueueService._internal();
  final AegisChatDatabase _database = AegisChatDatabase();

  static Future<void> initialize() async {
    await _instance._database.customSelect('SELECT 1').get();
  }

  Future<void> queueMessage(OfflineMessage message) async {
    await _database.into(_database.aegisOfflineQueue).insert(
          AegisOfflineQueueCompanion.insert(
            chatId: message.chatId,
            content: message.content,
            type: message.type,
            createdAtEpochMs: message.createdAt.millisecondsSinceEpoch,
            sent: Value(message.sent),
            errorMessage: Value(message.errorMessage),
          ),
        );
  }

  Future<List<OfflineMessage>> getQueuedMessages() async {
    final rows = await (_database.select(_database.aegisOfflineQueue)
          ..orderBy([
            (table) => OrderingTerm.asc(table.createdAtEpochMs),
          ]))
        .get();
    return rows.map(_messageFromRow).toList(growable: false);
  }

  Future<List<OfflineMessage>> getQueuedMessagesForChat(String chatId) async {
    final rows = await (_database.select(_database.aegisOfflineQueue)
          ..where((table) => table.chatId.equals(chatId))
          ..orderBy([
            (table) => OrderingTerm.asc(table.createdAtEpochMs),
          ]))
        .get();
    return rows.map(_messageFromRow).toList(growable: false);
  }

  Future<void> markAsSent(int recordId) async {
    await (_database.update(_database.aegisOfflineQueue)
          ..where((table) => table.id.equals(recordId)))
        .write(
          const AegisOfflineQueueCompanion(
            sent: Value(true),
            errorMessage: Value(null),
          ),
        );
  }

  Future<void> removeMessage(int recordId) async {
    await (_database.delete(_database.aegisOfflineQueue)
          ..where((table) => table.id.equals(recordId)))
        .go();
  }

  Future<void> clearSentMessages() async {
    await (_database.delete(_database.aegisOfflineQueue)
          ..where((table) => table.sent.equals(true)))
        .go();
  }

  OfflineMessage _messageFromRow(AegisOfflineQueueData row) {
    return OfflineMessage(
      id: row.id,
      chatId: row.chatId,
      content: row.content,
      type: row.type,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAtEpochMs),
      sent: row.sent,
      errorMessage: row.errorMessage,
    );
  }
}
