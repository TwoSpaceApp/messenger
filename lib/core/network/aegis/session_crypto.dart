import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/protocol_constants.dart';
import 'package:two_space_app/core/network/aegis/security_utils.dart';

class AegisHandshakeContext {
  static final Ecdh _ecdh = Ecdh.p256(length: 32);
  static final Hkdf _hkdf = Hkdf(
    hmac: Hmac.sha256(),
    outputLength: 32,
  );

  final KeyPair _keyPair;
  final Uint8List publicKey;

  AegisHandshakeContext._(this._keyPair, this.publicKey);

  static Future<AegisHandshakeContext> create() async {
    final keyPair = await _ecdh.newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    final rawPublicKey = Uint8List(65)
      ..[0] = 0x04
      ..setRange(1, 33, publicKey.x)
      ..setRange(33, 65, publicKey.y);
    return AegisHandshakeContext._(
      keyPair,
      rawPublicKey,
    );
  }

  Future<Uint8List> deriveSessionKey(Uint8List remotePublicKeyBytes) async {
    final sharedSecret = await _ecdh.sharedSecretKey(
      keyPair: _keyPair,
      remotePublicKey: EcPublicKey(
        x: remotePublicKeyBytes.sublist(1, 33),
        y: remotePublicKeyBytes.sublist(33, 65),
        type: KeyPairType.p256,
      ),
    );

    final sessionKey = await _hkdf.deriveKey(
      secretKey: sharedSecret,
      info: utf8.encode('AegisKeyDerivation'),
    );

    return Uint8List.fromList(await sessionKey.extractBytes());
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
    bd.setUint64(9, message.sequenceId);
    bd.setUint32(17, message.payloadLength);
    return header;
  }
}
