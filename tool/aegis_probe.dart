import 'dart:math';

import 'package:two_space_app/core/config/env.dart';
import 'package:two_space_app/core/network/aegis/aegis_client.dart';
import 'package:two_space_app/core/network/aegis/logger.dart';

Future<void> main() async {
  AegisLogger.level = LogLevel.debug;
  const disableMaskingFallback = bool.fromEnvironment(
    'AEGIS_DISABLE_MASKING_FALLBACK',
  );

  final client = AegisClient();
  client.messages.listen((message) {
    print(
      'Incoming: type=${message.type.name} seq=${message.sequenceId} '
      'flags=${message.flags} payload=${message.payloadLength}',
    );
  });
  client.disconnects.listen((_) {
    print('Disconnect event received');
  });

  final suffix = Random().nextInt(1 << 20).toString();
  final username = 'copilot_probe_$suffix';
  final email = '$username@example.com';
  const password = 'ProbePass123!';
  const host = Env.aegisHost;
  final port = int.tryParse(Env.aegisPort) ?? 8888;
  final timeoutSeconds = int.tryParse(Env.aegisConnectTimeoutSeconds) ?? 10;
  final timeout = Duration(seconds: timeoutSeconds);
  final transportMaskingKey = Env.aegisTransportMaskingKey.trim().isEmpty
      ? null
      : Env.aegisTransportMaskingKey.trim();

  print('Connecting to $host:$port');
  if (disableMaskingFallback) {
    await client.connect(
      host,
      port,
      timeout: timeout,
      transportMaskingKey: transportMaskingKey,
      enableMaskingAutoFallback: false,
    );
  } else {
    await client.connect(
      host,
      port,
      timeout: timeout,
      transportMaskingKey: transportMaskingKey,
    );
  }
  print('Handshake completed');

  final registration = await client.register(
    username,
    email,
    password,
    'probe_public_key_placeholder',
  );
  print(
    'Register success=${registration.success} '
    'message=${registration.message} '
    'user=${registration.user?.username}',
  );

  if (!registration.success) {
    await client.disconnect();
    throw Exception(
      registration.message ?? 'Registration failed without server message',
    );
  }

  final auth = await client.authenticateWithPassword(
    username: username,
    password: password,
  );
  print('Auth success=${auth.success} userId=${auth.userId} username=${auth.username}');

  await client.disconnect();
}
