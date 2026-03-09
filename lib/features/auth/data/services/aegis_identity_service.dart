import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:two_space_app/core/network/aegis/handshake_crypto.dart';

const _kAegisIdentityPublicKey = 'aegis_identity_public_key';

class AegisIdentityService {
  AegisIdentityService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<String> getOrCreatePublicKey() async {
    final existing = await _storage.read(key: _kAegisIdentityPublicKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final handshake = await AegisHandshakeCrypto.createHandshake();
    final publicKey = base64Encode(handshake.publicKeySpki);
    await _storage.write(key: _kAegisIdentityPublicKey, value: publicKey);
    return publicKey;
  }
}
