import 'dart:math';
import 'dart:typed_data';

/// Security utilities for the Aegis protocol layer.
///
/// Provides buffer zeroing, secure random generation, and constant-time
/// comparison — the minimal crypto primitives needed by the transport
/// and encoder without pulling in a full crypto library.
class SecureBufferUtils {
  static final Random _secureRandom = Random.secure();

  /// Zero out [buffer] to prevent sensitive data from lingering in memory.
  ///
  /// Call this after you are done with buffers that contain keys, tokens,
  /// or plaintext message content.
  ///
  /// Note: Dart's GC may have already copied the data elsewhere; this is
  /// a best-effort defense-in-depth measure, not a guarantee.
  static void zeroOut(Uint8List buffer) {
    buffer.fillRange(0, buffer.length, 0);
  }

  /// Generate [length] cryptographically secure random bytes.
  ///
  /// Uses [Random.secure] which is backed by the OS CSPRNG.
  /// Suitable for nonces, IVs, and key material.
  ///
  /// **Never** use sequence IDs or counters as nonces — always use this
  /// method (or equivalent CSPRNG) for cryptographic randomness.
  static Uint8List secureRandomBytes(int length) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _secureRandom.nextInt(256);
    }
    return bytes;
  }

  /// Constant-time comparison of two byte arrays.
  ///
  /// Returns `true` if [a] and [b] are the same length and contain
  /// identical bytes. Runs in time proportional to the length of [a],
  /// regardless of where (or whether) the arrays differ.
  ///
  /// Use this for comparing MACs, hashes, or tokens to prevent
  /// timing side-channel attacks.
  static bool constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}
