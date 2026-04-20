import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';
import 'package:pointycastle/ecc/api.dart' show ECPrivateKey;

import 'package:two_space_app/core/network/aegis/handshake_crypto.dart';
import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/protocol_constants.dart';
import 'package:two_space_app/core/network/aegis/security_utils.dart';
import 'package:two_space_app/core/network/aegis/typed_data_compat.dart';

class AegisHandshakeContext {
  final ECPrivateKey _privateKey;
  final Uint8List publicKey;

  AegisHandshakeContext._(this._privateKey, this.publicKey);

  static Future<AegisHandshakeContext> create() async {
    final handshake = await AegisHandshakeCrypto.createHandshake();
    return AegisHandshakeContext._(
      handshake.privateKey,
      Uint8List.fromList(handshake.publicKeyRaw),
    );
  }

  Future<Uint8List> deriveSharedSecret(Uint8List remotePublicKeyBytes) async {
    final sharedSecret = AegisHandshakeCrypto.deriveSharedSecret(
      clientPrivateKey: _privateKey,
      serverPublicKeySpki: remotePublicKeyBytes,
    );
    return Uint8List.fromList(sharedSecret);
  }

  Future<Uint8List> deriveSessionKey(Uint8List remotePublicKeyBytes) async {
    final sessionKey = await AegisHandshakeCrypto.deriveSessionKey(
      clientPrivateKey: _privateKey,
      serverPublicKeySpki: remotePublicKeyBytes,
    );
    return Uint8List.fromList(sessionKey);
  }
}

class AegisHandshakeVerifier {
  static final Ecdsa _ecdsa = Ecdsa.p256(Sha256());

  static Future<bool> verifyServerHandshakeSignature({
    required Uint8List trustedSigningPublicKey,
    required Uint8List serverEphemeralPublicKey,
    required Uint8List clientEphemeralPublicKey,
    required Uint8List signature,
  }) async {
    if (trustedSigningPublicKey.length != 65 ||
        trustedSigningPublicKey[0] != 0x04) {
      return false;
    }

    final transcript = _buildTranscript(
      serverEphemeralPublicKey,
      clientEphemeralPublicKey,
    );

    final publicKey = EcPublicKey(
      x: trustedSigningPublicKey.sublist(1, 33),
      y: trustedSigningPublicKey.sublist(33, 65),
      type: KeyPairType.p256,
    );

    return _ecdsa.verify(
      transcript,
      signature: Signature(signature, publicKey: publicKey),
    );
  }

  static Uint8List _buildTranscript(
    Uint8List serverPublicKey,
    Uint8List clientPublicKey,
  ) {
    const marker = 'AEGIS-HANDSHAKE-V1';
    final markerBytes = Uint8List.fromList(ascii.encode(marker));
    final output = BytesBuilder(copy: false)
      ..add(markerBytes)
      ..add(_int32(serverPublicKey.length))
      ..add(serverPublicKey)
      ..add(_int32(clientPublicKey.length))
      ..add(clientPublicKey);
    return output.toBytes();
  }

  static Uint8List _int32(int value) {
    final bytes = ByteData(4)..setInt32(0, value, Endian.little);
    return bytes.buffer.asUint8List();
  }
}

class AegisV2SessionKeys {
  final Uint8List clientToServerKey;
  final Uint8List serverToClientKey;
  final Uint8List ackKey;

  const AegisV2SessionKeys({
    required this.clientToServerKey,
    required this.serverToClientKey,
    required this.ackKey,
  });
}

class AegisSecureProtocolV2 {
  static Uint8List secureRandomBytes(int length) {
    return SecureBufferUtils.secureRandomBytes(length);
  }

  static Future<Uint8List> sha256(Uint8List payload) async {
    return Uint8List.fromList(crypto.sha256.convert(payload).bytes);
  }

  static Future<AegisV2SessionKeys> deriveSessionKeys({
    required Uint8List sharedSecret,
    required Uint8List clientNonce,
    required Uint8List serverNonce,
    required Uint8List transcriptHash,
  }) async {
    final salt = Uint8List(clientNonce.length + serverNonce.length)
      ..setRange(0, clientNonce.length, clientNonce)
      ..setRange(
        clientNonce.length,
        clientNonce.length + serverNonce.length,
        serverNonce,
      );

    final handshakeSecret = await _deriveHkdf(
      keyMaterial: sharedSecret,
      salt: salt,
      info: Uint8List.fromList(utf8.encode('aegis-v2/hs')),
    );

    final clientToServer = await _deriveHkdf(
      keyMaterial: handshakeSecret,
      salt: Uint8List(0),
      info: Uint8List(transcriptHash.length + 1)
        ..setRange(0, transcriptHash.length, transcriptHash)
        ..[transcriptHash.length] = 0x01,
    );

    final serverToClient = await _deriveHkdf(
      keyMaterial: handshakeSecret,
      salt: Uint8List(0),
      info: Uint8List(transcriptHash.length + 1)
        ..setRange(0, transcriptHash.length, transcriptHash)
        ..[transcriptHash.length] = 0x02,
    );

    final ackKey = await _deriveHkdf(
      keyMaterial: handshakeSecret,
      salt: Uint8List(0),
      info: Uint8List(transcriptHash.length + 1)
        ..setRange(0, transcriptHash.length, transcriptHash)
        ..[transcriptHash.length] = 0x03,
    );

    return AegisV2SessionKeys(
      clientToServerKey: clientToServer,
      serverToClientKey: serverToClient,
      ackKey: ackKey,
    );
  }

  static Future<Uint8List> computeClientFinishProof({
    required Uint8List ackKey,
    required Uint8List transcriptHash,
  }) async {
    final material = Uint8List(transcriptHash.length + 6)
      ..setRange(0, transcriptHash.length, transcriptHash)
      ..setRange(
        transcriptHash.length,
        transcriptHash.length + 6,
        ascii.encode('finish'),
      );
    return Uint8List.fromList(
      crypto.Hmac(crypto.sha256, ackKey).convert(material).bytes,
    );
  }

  static Future<Uint8List> _deriveHkdf({
    required Uint8List keyMaterial,
    required Uint8List salt,
    required Uint8List info,
  }) async {
    const hashLength = 32;
    final effectiveSalt = salt.isEmpty ? Uint8List(hashLength) : salt;
    final prk = crypto.Hmac(
      crypto.sha256,
      effectiveSalt,
    ).convert(keyMaterial).bytes;

    final output = <int>[];
    var previous = List<int>.filled(hashLength, 0);
    var counter = 1;
    while (output.length < hashLength) {
      final blockInput = <int>[...previous, ...info, counter];
      previous = crypto.Hmac(crypto.sha256, prk).convert(blockInput).bytes;
      output.addAll(previous);
      counter++;
    }

    return Uint8List.fromList(output.sublist(0, hashLength));
  }
}

class AegisSessionCrypto {
  static final AesGcm _aesGcm = AesGcm.with256bits();

  final Uint8List _sessionKey;

  AegisSessionCrypto(Uint8List sessionKey)
    : _sessionKey = Uint8List.fromList(sessionKey) {
    if (_sessionKey.length != 32) {
      throw ArgumentError('Session key must be 32 bytes');
    }
  }

  Future<Message> encryptMessage(Message message) async {
    final nonce = SecureBufferUtils.secureRandomBytes(12);
    final encryptedPayloadLength = nonce.length + message.payload.length + 16;
    final wireMessage = Message()
      ..magic = message.magic
      ..versionMajor = message.versionMajor
      ..versionMinor = message.versionMinor
      ..flags = message.flags | ProtocolConstants.flagEncrypted
      ..type = message.type
      ..sequenceId = message.sequenceId
      ..payloadLength = encryptedPayloadLength
      ..payload = Uint8List(encryptedPayloadLength);

    final aad = _buildHeaderBytes(wireMessage);
    final secretBox = await _aesGcm.encrypt(
      message.payload,
      secretKey: SecretKey(_sessionKey),
      nonce: nonce,
      aad: aad,
    );

    wireMessage.payload.setRange(0, nonce.length, nonce);
    wireMessage.payload.setRange(
      nonce.length,
      nonce.length + secretBox.cipherText.length,
      secretBox.cipherText,
    );
    wireMessage.payload.setRange(
      nonce.length + secretBox.cipherText.length,
      wireMessage.payload.length,
      secretBox.mac.bytes,
    );

    SecureBufferUtils.zeroOut(nonce);
    return wireMessage;
  }

  Future<void> decryptMessage(Message message, Uint8List headerBytes) async {
    if ((message.flags & ProtocolConstants.flagEncrypted) == 0) {
      return;
    }

    final payload = message.payload;
    if (payload.length < 28) {
      throw StateError('Encrypted payload too short');
    }

    final nonce = payload.sublist(0, 12);
    final cipherAndTag = payload.sublist(12);
    final cipherTextLength = cipherAndTag.length - 16;
    if (cipherTextLength < 0) {
      throw StateError('Encrypted payload tag is missing');
    }

    final secretBox = SecretBox(
      cipherAndTag.sublist(0, cipherTextLength),
      nonce: nonce,
      mac: Mac(cipherAndTag.sublist(cipherTextLength)),
    );

    final plaintext = await _aesGcm.decrypt(
      secretBox,
      secretKey: SecretKey(_sessionKey),
      aad: headerBytes,
    );

    message.payload = Uint8List.fromList(plaintext);
    message.payloadLength = message.payload.length;
    message.flags &= ~ProtocolConstants.flagEncrypted;
  }

  void dispose() {
    SecureBufferUtils.zeroOut(_sessionKey);
  }

  Uint8List _buildHeaderBytes(Message message) {
    final header = Uint8List(ProtocolConstants.headerSize);
    final bd = ByteData.view(header.buffer);
    bd.setUint32(0, message.magic);
    header[4] = message.versionMajor;
    header[5] = message.versionMinor;
    header[6] = message.flags;
    bd.setUint16(7, message.type.value);
    bd.setUint64Compat(9, message.sequenceId);
    bd.setUint32(17, message.payloadLength);
    return header;
  }
}
