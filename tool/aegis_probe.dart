import 'dart:math';

import 'package:two_space_app/core/network/aegis/aegis_client.dart';

Future<void> main() async {
  final client = AegisClient();
  final suffix = Random().nextInt(1 << 20).toString();
  final username = 'copilot_probe_$suffix';
  final email = '$username@example.com';
  const password = 'ProbePass123!';
  const host = '95.215.56.43';
  const port = 8888;

  print('Connecting to $host:$port');
  await client.connect(host, port, timeout: const Duration(seconds: 10));
  print('Handshake completed');

  final registration = await client.register(
    username,
    email,
    password,
    'probe_public_key_placeholder',
  );
  print('Register success=${registration.success} user=${registration.user?.username}');

  final auth = await client.authenticateWithPassword(
    username: username,
    password: password,
  );
  print('Auth success=${auth.success} userId=${auth.userId} username=${auth.username}');

  await client.disconnect();
}
