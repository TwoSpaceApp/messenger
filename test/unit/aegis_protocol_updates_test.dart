import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:two_space_app/core/network/aegis/event_dispatcher.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_payloads.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';

void main() {
  group('Aegis protocol helpers', () {
    test('parseRichTextContent extracts rich-text envelope', () {
      final parsed = parseRichTextContent(jsonEncode({
        'Kind': 'rich-text',
        'Text': 'hello',
        'ParseMode': 'markdown',
      }));

      expect(parsed.text, 'hello');
      expect(parsed.parseMode, 'markdown');
    });

    test('tryParseMediaAttachment extracts attachment payload', () {
      final parsed = tryParseMediaAttachment(
        jsonEncode({
          'FileName': 'voice.ogg',
          'MimeType': 'audio/ogg',
          'Base64Data': base64Encode(utf8.encode('abc')),
          'SizeBytes': 3,
          'Text': 'voice note',
        }),
        MessageContentType.audio,
      );

      expect(parsed, isNotNull);
      expect(parsed!.fileName, 'voice.ogg');
      expect(parsed.mimeType, 'audio/ogg');
      expect(parsed.text, 'voice note');
      expect(parsed.decodeBytes(), utf8.encode('abc'));
    });

    test('group edit payload preserves avatar updates', () {
      final request = GroupEditRequest(
        groupId: 42,
        avatarUrl: 'data:image/png;base64,AAAA',
        description: 'Updated avatar',
      );

      expect(request.toJson(), {
        'GroupId': 42,
        'Description': 'Updated avatar',
        'AvatarUrl': 'data:image/png;base64,AAAA',
      });

      final response = GroupEditResponse.fromJson({
        'Success': true,
        'Message': 'Group updated',
      });

      expect(response.success, isTrue);
      expect(response.message, 'Group updated');
    });

    test('handshake payload includes official app credentials', () {
      final request = HandshakeRequestPayload(
        publicKey: 'base64-public-key',
        clientVersion: 1000,
        appId: 2041001,
        appHash:
            '8f4c1db0e7c2456d9ab31f4e6d8c9a0137f2c4b56d8e1a903bc7d52e6f194a3c',
      );

      expect(request.toJson(), {
        'PublicKey': 'base64-public-key',
        'ClientVersion': 1000,
        'AppId': 2041001,
        'AppHash':
            '8f4c1db0e7c2456d9ab31f4e6d8c9a0137f2c4b56d8e1a903bc7d52e6f194a3c',
      });
    });
  });

  group('AegisEventDispatcher', () {
    test('routes private chat events into typed stream', () async {
      final controller = StreamController<Message>.broadcast();
      final dispatcher = AegisEventDispatcher(controller.stream);

      final eventFuture = dispatcher.privateMessageEvents.first;

      controller.add(
        Message.withType(
          MessageType.privateChatMessageEvent,
          msgpack.serialize({
            'Id': 11,
            'FromUserId': 7,
            'ToUserId': 9,
            'Content': 'hello',
            'ContentType': 0,
            'CreatedAt': DateTime.utc(2026, 3, 12).toIso8601String(),
            'FromUsername': 'alice',
            'ReplyToMessageId': 10,
            'DeliveredTo': [9],
            'ReadBy': [9],
          }),
        )..sequenceId = 55,
      );

      final event = await eventFuture;
      expect(event.id, 11);
      expect(event.fromUserId, 7);
      expect(event.toUserId, 9);
      expect(event.content, 'hello');
      expect(event.fromUsername, 'alice');
      expect(event.replyToMessageId, 10);
      expect(event.deliveredTo, [9]);
      expect(event.readBy, [9]);

      await dispatcher.dispose();
      await controller.close();
    });

    test('routes message status events into typed stream', () async {
      final controller = StreamController<Message>.broadcast();
      final dispatcher = AegisEventDispatcher(controller.stream);

      final eventFuture = dispatcher.messageStatusEvents.first;

      controller.add(
        Message.withType(
          MessageType.messageStatusEvent,
          msgpack.serialize({
            'Success': true,
            'MessageIds': [101, 102],
            'ReadBy': 42,
            'ProcessedAt': DateTime.utc(2026, 3, 12, 9).toIso8601String(),
          }),
        )..sequenceId = 88,
      );

      final event = await eventFuture;
      expect(event.success, isTrue);
      expect(event.messageIds, [101, 102]);
      expect(event.readBy, 42);
      expect(event.isReadUpdate, isTrue);
      expect(event.isDeliveredUpdate, isFalse);

      await dispatcher.dispose();
      await controller.close();
    });

    test('routes error messages without breaking typed streams', () async {
      final controller = StreamController<Message>.broadcast();
      final dispatcher = AegisEventDispatcher(controller.stream);

      final errorFuture = dispatcher.errorMessages.first;

      controller.add(
        Message.withType(MessageType.error, utf8.encode('server error'))
          ..sequenceId = 77,
      );

      final message = await errorFuture;
      expect(message.type, MessageType.error);
      expect(utf8.decode(message.payload), 'server error');

      await dispatcher.dispose();
      await controller.close();
    });
  });
}
