import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'package:two_space_app/core/network/aegis/message.dart';
import 'package:two_space_app/core/network/aegis/protocol_constants.dart';

class AegisSessionCrypto {
  static final AesGcm _aesGcm = AesGcm.with256bits();

  AegisSessionCrypto(Uint8List sessionKey)
      : _sessionKey = Uint8List.fromList(sessionKey) {
    if (_sessionKey.length != 32) {
      throw ArgumentError('Session key must be 32 bytes');
    }
  }

  final Uint8List _sessionKey;

  Future<Message> encryptMessage(Message message) async {
    final nonce = _randomNonce();
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

  Uint8List _buildHeaderBytes(Message message) {
    final header = Uint8List(ProtocolConstants.headerSize);
    final data = ByteData.view(header.buffer);
    data.setUint32(0, message.magic);
    header[4] = message.versionMajor;
    header[5] = message.versionMinor;
    header[6] = message.flags;
    data.setUint16(7, message.type.value);
    data.setUint64(9, message.sequenceId);
    data.setUint32(17, message.payloadLength);
    return header;
  }

  Uint8List _randomNonce() => Uint8List.fromList(_aesGcm.newNonce());

  void dispose() {}
}
