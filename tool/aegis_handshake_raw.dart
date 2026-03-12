import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:two_space_app/core/config/env.dart';
import 'package:two_space_app/core/network/aegis/handshake_crypto.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/message_encoder.dart';
import 'package:two_space_app/core/network/aegis/message_type.dart';

Future<void> main() async {
  await _probeJsonHandshake();
  await _probeLegacyHandshake();
}

Future<void> _probeJsonHandshake() async {
  final socket = await Socket.connect(
    Env.aegisHost,
    int.tryParse(Env.aegisPort) ?? 8888,
    timeout: Duration(seconds: int.tryParse(Env.aegisConnectTimeoutSeconds) ?? 10),
  );
  final handshake = await AegisHandshakeCrypto.createHandshake();
  final payload = utf8.encode(jsonEncode({
    'PublicKey': base64Encode(handshake.publicKeySpki),
    'ClientVersion': 1000,
  }));
  await _sendAndWait(
    socket: socket,
    payload: payload,
    label: 'json',
  );
}

Future<void> _probeLegacyHandshake() async {
  final socket = await Socket.connect(
    Env.aegisHost,
    int.tryParse(Env.aegisPort) ?? 8888,
    timeout: Duration(seconds: int.tryParse(Env.aegisConnectTimeoutSeconds) ?? 10),
  );
  final handshake = await AegisHandshakeCrypto.createHandshake();
  final bytes = BytesBuilder()
    ..add(_uint32be(1000))
    ..add(List<int>.filled(12, 0))
    ..add(handshake.publicKeySpki);
  await _sendAndWait(
    socket: socket,
    payload: bytes.toBytes(),
    label: 'legacy',
  );
}

Future<void> _sendAndWait({
  required Socket socket,
  required List<int> payload,
  required String label,
}) async {
  final message = Message.withType(MessageType.handshake, payload)
    ..sequenceId = 1;
  final bytes = MessageEncoder.encode(message);
  final maskingKey = Env.aegisTransportMaskingKey.trim();
  final outgoing = maskingKey.isEmpty
      ? bytes
      : _applyMask(bytes, utf8.encode(maskingKey));
  final incomingMaskKey = maskingKey.isEmpty ? null : utf8.encode(maskingKey);

  print('[$label] sending ${outgoing.length} bytes');
  final completer = Completer<void>();
  var inboundOffset = 0;
  socket.listen(
    (data) {
      final visible = incomingMaskKey == null
          ? data
          : _applyMaskWithOffset(data, incomingMaskKey, inboundOffset);
      inboundOffset += data.length;
      print('[$label] received ${data.length} bytes');
      print(visible);
      if (!completer.isCompleted) completer.complete();
    },
    onDone: () {
      print('[$label] socket closed by server');
      if (!completer.isCompleted) completer.complete();
    },
    onError: (e) {
      print('[$label] socket error: $e');
      if (!completer.isCompleted) completer.complete();
    },
  );
  socket.add(outgoing);
  await socket.flush();
  await completer.future.timeout(const Duration(seconds: 5), onTimeout: () {
    print('[$label] no response in 5s');
  });
  await socket.close();
}

Uint8List _uint32be(int value) {
  final data = ByteData(4)..setUint32(0, value);
  return data.buffer.asUint8List();
}

Uint8List _applyMask(List<int> data, List<int> key) {
  return _applyMaskWithOffset(Uint8List.fromList(data), key, 0);
}

Uint8List _applyMaskWithOffset(List<int> data, List<int> key, int offset) {
  final masked = Uint8List.fromList(data);
  for (var index = 0; index < masked.length; index++) {
    final keyIndex = (offset + index) % key.length;
    masked[index] = masked[index] ^ key[keyIndex];
  }
  return masked;
}
