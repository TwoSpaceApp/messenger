import 'dart:math';

import 'package:two_space_app/core/config/env.dart';
import 'package:two_space_app/core/network/aegis/aegis_client.dart';
import 'package:two_space_app/core/network/aegis/logger.dart';

Future<AegisClient> _connectClient() async {
  final client = AegisClient();
  final port = int.tryParse(Env.aegisPort) ?? 8888;
  final timeoutSeconds = int.tryParse(Env.aegisConnectTimeoutSeconds) ?? 10;
  final maskingKey = Env.aegisTransportMaskingKey.trim().isEmpty
      ? null
      : Env.aegisTransportMaskingKey.trim();

  await client.connect(
    Env.aegisHost,
    port,
    timeout: Duration(seconds: timeoutSeconds),
    transportMaskingKey: maskingKey,
  );
  return client;
}

Future<(int, String)> _registerUser(
  AegisClient client, {
  required String username,
  required String email,
  required String password,
}) async {
  final registration = await client.register(
    username,
    email,
    password,
    'probe_public_key_placeholder',
  );
  if (!registration.success || registration.user == null) {
    throw Exception('Registration failed for $username: ${registration.message}');
  }
  return (registration.user!.id, registration.user!.username);
}

Future<void> main() async {
  AegisLogger.level = LogLevel.info;
  final suffix = Random().nextInt(1 << 20).toString();
  final senderName = 'probe_sender_$suffix';
  final receiverName = 'probe_receiver_$suffix';
  const password = 'ProbePass123!';

  final registrar = await _connectClient();
  try {
    final (senderId, senderUsername) = await _registerUser(
      registrar,
      username: senderName,
      email: '$senderName@example.com',
      password: password,
    );
    final (receiverId, receiverUsername) = await _registerUser(
      registrar,
      username: receiverName,
      email: '$receiverName@example.com',
      password: password,
    );

    print('REGISTERED sender=$senderId:$senderUsername receiver=$receiverId:$receiverUsername');

    final sender = await _connectClient();
    try {
      final auth = await sender.authenticateWithPassword(
        username: senderName,
        password: password,
      );
      print('AUTH sender success=${auth.success} userId=${auth.userId} token=${auth.sessionToken?.isNotEmpty == true}');

      final ownProfile = await sender.getOwnProfile();
      print('OWN PROFILE success=${ownProfile.success} displayName=${ownProfile.profile?.displayName} username=${ownProfile.profile?.username}');

      final receiverProfile = await sender.getProfile(userId: receiverId);
      print('TARGET PROFILE success=${receiverProfile.success} displayName=${receiverProfile.profile?.displayName} username=${receiverProfile.profile?.username}');

      try {
        final direct = await sender.sendPrivateMessage(receiverId, 'probe direct message');
        print('DIRECT SEND success=${direct.success} messageId=${direct.messageId} text=${direct.messageText}');
        if (!direct.success) {
          await sender.sendMessage(
            'probe legacy direct message',
            toUserId: receiverId,
          );
          await Future<void>.delayed(const Duration(milliseconds: 350));
          final legacyHistory = await sender.getPrivateHistory(receiverId, limit: 5);
          print(
            'DIRECT LEGACY historySuccess=${legacyHistory.success} count=${legacyHistory.messages.length} '
            'last=${legacyHistory.messages.isEmpty ? null : legacyHistory.messages.first.content}',
          );
        }
      } catch (error) {
        print('DIRECT SEND ERROR $error');
        try {
          await sender.sendMessage(
            'probe legacy direct message',
            toUserId: receiverId,
          );
          await Future<void>.delayed(const Duration(milliseconds: 350));
          final legacyHistory = await sender.getPrivateHistory(receiverId, limit: 5);
          print(
            'DIRECT LEGACY historySuccess=${legacyHistory.success} count=${legacyHistory.messages.length} '
            'last=${legacyHistory.messages.isEmpty ? null : legacyHistory.messages.first.content}',
          );
        } catch (legacyError) {
          print('DIRECT LEGACY ERROR $legacyError');
        }
      }

      final group = await sender.createGroup('probe-group-$suffix', description: 'probe');
      print('GROUP CREATE success=${group.success} groupId=${group.groupId} message=${group.message}');
      if (group.success && group.groupId > 0) {
        try {
          final groupMembers = await sender.getGroupMembers(group.groupId);
          print('GROUP MEMBERS success=${groupMembers.success} count=${groupMembers.members.length}');
        } catch (error) {
          print('GROUP MEMBERS ERROR $error');
        }
        try {
          final groupSettings = await sender.getGroupSettings(group.groupId);
          print('GROUP SETTINGS success=${groupSettings.success} joinRule=${groupSettings.joinRule} history=${groupSettings.historyVisibility}');
        } catch (error) {
          print('GROUP SETTINGS ERROR $error');
        }
        try {
          final groupMessage = await sender.sendGroupMessage(group.groupId, 'probe group message');
          print('GROUP SEND success=${groupMessage.success} messageId=${groupMessage.messageId} text=${groupMessage.messageText}');
        } catch (error) {
          print('GROUP SEND ERROR $error');
        }
      }

      final channel = await sender.createChannel(
        'probe-channel-$suffix',
        description: 'probe',
      );
      print('CHANNEL CREATE success=${channel.success} channelId=${channel.channelId} message=${channel.message}');
      if (channel.success && channel.channelId > 0) {
        try {
          final channelSettings = await sender.getChannelSettings(channel.channelId);
          print('CHANNEL SETTINGS success=${channelSettings.success} joinRule=${channelSettings.joinRule} history=${channelSettings.historyVisibility}');
        } catch (error) {
          print('CHANNEL SETTINGS ERROR $error');
        }
        try {
          final channelMessage = await sender.sendChannelMessage(channel.channelId, 'probe channel message');
          print('CHANNEL SEND success=${channelMessage.success} messageId=${channelMessage.messageId} text=${channelMessage.messageText}');
        } catch (error) {
          print('CHANNEL SEND ERROR $error');
        }
      }

      final chatList = await sender.getChatList();
      print('CHAT LIST success=${chatList.success} count=${chatList.chats.length}');
      for (final chat in chatList.chats) {
        print('CHAT type=${chat.type} title=${chat.title} peer=${chat.peerUserId} channel=${chat.channelId} chatId=${chat.chatId}');
      }
    } finally {
      await sender.disconnect();
    }
  } finally {
    await registrar.disconnect();
  }
}
