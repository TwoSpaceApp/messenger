import 'dart:ffi';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:two_space_app/features/chat/data/local/aegis_chat_database.dart';
import 'package:two_space_app/features/chat/data/local/aegis_chat_local_store.dart';

void main() {
  setUpAll(() {
    if (Platform.isLinux) {
      open.overrideFor(
        OperatingSystem.linux,
        () => DynamicLibrary.open('/lib/x86_64-linux-gnu/libsqlite3.so.0'),
      );
    }
  });

  group("AegisChatLocalStore", () {
    test("persists delivery and read status fields for room messages", () async {
      final database = AegisChatDatabase.forExecutor(NativeDatabase.memory());
      final store = AegisChatLocalStore(database: database);
      final deliveredAt = DateTime.utc(2026, 3, 31, 12);
      final readAt = DateTime.utc(2026, 3, 31, 12, 5);

      await store.saveChanges(
        conversationsJson: const [],
        profilesJsonByUserId: const {},
        upsertMessagesJsonByRoomId: {
          "room-1": [
            {
              "id": "message-1",
              "senderId": "42",
              "content": "hello",
              "time": DateTime.utc(2026, 3, 31, 11, 59).toIso8601String(),
              "type": "m.text",
              "mediaId": null,
              "replyToMessageId": 7,
              "isDelivered": true,
              "isRead": true,
              "deliveredAt": deliveredAt.toIso8601String(),
              "readAt": readAt.toIso8601String(),
            },
          ],
        },
        deletedMessageIdsByRoomId: const {},
        deletedRoomIds: const {},
        writeConversations: false,
        writeProfiles: false,
      );

      final messages = await store.loadRoomMessagesJson("room-1");

      expect(messages, hasLength(1));
      expect(messages.first["isDelivered"], isTrue);
      expect(messages.first["isRead"], isTrue);
      expect(messages.first["replyToMessageId"], 7);
      expect(messages.first["deliveredAt"], deliveredAt.toIso8601String());
      expect(messages.first["readAt"], readAt.toIso8601String());

      await store.close();
    });
  });
}
