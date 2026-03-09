import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

class AegisHandshakeResult {
  AegisHandshakeResult({
    required this.privateKey,
    required this.publicKeySpki,
  });

  final ECPrivateKey privateKey;
  final List<int> publicKeySpki;
}

class AegisHandshakeCrypto {
  static const List<int> _p256SpkiPrefix = <int>[
    0x30,
    0x59,
    0x30,
    0x13,
    0x06,
    0x07,
    0x2A,
    0x86,
    0x48,
    0xCE,
    0x3D,
    0x02,
    0x01,
    0x06,
    0x08,
    0x2A,
    0x86,
    0x48,
    0xCE,
    0x3D,
    0x03,
    0x01,
    0x07,
    0x03,
    0x42,
    0x00,
  ];
  static final ECDomainParameters _domain = ECDomainParameters('prime256v1');

  static Future<AegisHandshakeResult> createHandshake() async {
    final generator = ECKeyGenerator()
      ..init(
        ParametersWithRandom(
          ECKeyGeneratorParameters(_domain),
          _secureRandom(),
        ),
      );

    final keyPair = generator.generateKeyPair();
    final privateKey = keyPair.privateKey as ECPrivateKey;
    final publicKey = keyPair.publicKey as ECPublicKey;

    return AegisHandshakeResult(
      privateKey: privateKey,
      publicKeySpki: <int>[
        ..._p256SpkiPrefix,
        ...publicKey.Q!.getEncoded(false),
      ],
    );
  }

  static Future<List<int>> deriveMacKey({
    required ECPrivateKey clientPrivateKey,
    required List<int> serverPublicKeySpki,
  }) async {
    final derivedBytes = _deriveKeys(
      clientPrivateKey: clientPrivateKey,
      serverPublicKeySpki: serverPublicKeySpki,
    );
    return derivedBytes.sublist(32, 64);
  }

  static Future<List<int>> deriveSessionKey({
    required ECPrivateKey clientPrivateKey,
    required List<int> serverPublicKeySpki,
  }) async {
    final derivedBytes = _deriveKeys(
      clientPrivateKey: clientPrivateKey,
      serverPublicKeySpki: serverPublicKeySpki,
    );
    return derivedBytes.sublist(0, 32);
  }

  static List<int> encryptPayload({
    required List<int> plaintext,
    required List<int> sessionKey,
    required List<int> nonce,
  }) {
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(
          KeyParameter(Uint8List.fromList(sessionKey)),
          128,
          Uint8List.fromList(nonce),
          Uint8List(0),
        ),
      );
    return cipher.process(Uint8List.fromList(plaintext));
  }

  static List<int> decryptPayload({
    required List<int> encryptedPayload,
    required List<int> sessionKey,
  }) {
    if (encryptedPayload.length < 12 + 16) {
      throw const FormatException('Encrypted payload is too short');
    }

    final nonce = encryptedPayload.sublist(0, 12);
    final ciphertextWithTag = encryptedPayload.sublist(12);
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false,
        AEADParameters(
          KeyParameter(Uint8List.fromList(sessionKey)),
          128,
          Uint8List.fromList(nonce),
          Uint8List(0),
        ),
      );
    return cipher.process(Uint8List.fromList(ciphertextWithTag));
  }

  static List<int> _deriveKeys({
    required ECPrivateKey clientPrivateKey,
    required List<int> serverPublicKeySpki,
  }) {
    final rawServerKey = _decodeSpki(serverPublicKeySpki);
    final point = _domain.curve.decodePoint(Uint8List.fromList(rawServerKey));
    if (point == null) {
      throw const FormatException('Invalid server public key');
    }

    final agreement = ECDHBasicAgreement()..init(clientPrivateKey);
    final sharedSecret = agreement.calculateAgreement(ECPublicKey(point, _domain));
    final sharedSecretBytes = _bigIntToBytes(sharedSecret, 32);
    final derivedBytes = _hkdfSha256(
      inputKeyMaterial: sharedSecretBytes,
      info: utf8.encode('AegisKeyDerivation'),
      outputLength: 64,
    );
    return derivedBytes;
  }

  static Future<List<int>> computeMac(
    List<int> data,
    List<int> macKey,
  ) async {
    return Hmac(sha256, macKey).convert(data).bytes;
  }

  static FortunaRandom _secureRandom() {
    final seed = Uint8List(32);
    final random = Random.secure();
    for (var i = 0; i < seed.length; i++) {
      seed[i] = random.nextInt(256);
    }
    return FortunaRandom()..seed(KeyParameter(seed));
  }

  static List<int> _decodeSpki(List<int> spkiBytes) {
    if (spkiBytes.length < _p256SpkiPrefix.length + 65) {
      throw const FormatException('Invalid server public key');
    }

    for (var i = 0; i < _p256SpkiPrefix.length; i++) {
      if (spkiBytes[i] != _p256SpkiPrefix[i]) {
        throw const FormatException('Unsupported server public key format');
      }
    }

    return spkiBytes.sublist(_p256SpkiPrefix.length);
  }

  static List<int> _bigIntToBytes(BigInt value, int length) {
    final result = Uint8List(length);
    var current = value;
    for (var i = length - 1; i >= 0; i--) {
      result[i] = (current & BigInt.from(0xff)).toInt();
      current = current >> 8;
    }
    return result;
  }

  static List<int> _hkdfSha256({
    required List<int> inputKeyMaterial,
    required List<int> info,
    required int outputLength,
  }) {
    const hashLength = 32;
    final salt = List<int>.filled(hashLength, 0);
    final prk = Hmac(sha256, salt).convert(inputKeyMaterial).bytes;

    final output = <int>[];
    var previous = <int>[];
    var counter = 1;
    while (output.length < outputLength) {
      final blockInput = <int>[...previous, ...info, counter];
      previous = Hmac(sha256, prk).convert(blockInput).bytes;
      output.addAll(previous);
      counter++;
    }

    return output.sublist(0, outputLength);
  }
}
