import 'dart:convert';

import 'package:two_space_app/core/network/aegis/handshake_crypto.dart';
import 'package:two_space_app/core/utils/secure_store.dart';

const _kAegisIdentityPublicKey = 'aegis_identity_public_key';

class AegisIdentityService {
  AegisIdentityService();

  Future<String> getOrCreatePublicKey() async {
    final existing = await SecureStore.read(_kAegisIdentityPublicKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final handshake = await AegisHandshakeCrypto.createHandshake();
    final publicKey = base64Encode(handshake.publicKeySpki);
    await SecureStore.write(_kAegisIdentityPublicKey, publicKey);
    return publicKey;
  }
}
