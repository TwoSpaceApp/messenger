import 'package:local_auth/local_auth.dart';
import 'package:two_space_app/core/utils/secure_store.dart';

class BiometricAuthService {
  factory BiometricAuthService() => _instance;

  BiometricAuthService._internal();
  static final BiometricAuthService _instance =
      BiometricAuthService._internal();
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if device supports biometric authentication
  Future<bool> canAuthenticate() async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheckBiometrics || isDeviceSupported;
    } on Object catch (_) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on Object catch (_) {
      return [];
    }
  }

  /// Authenticate with system device security.
  Future<bool> authenticate({String? localizedReason}) async {
    try {
      return await _auth.authenticate(
        localizedReason:
            localizedReason ?? 'Authenticate to continue in TwoSpace',
        persistAcrossBackgrounding: true,
      );
    } on Object catch (_) {
      return false;
    }
  }

  /// Set PIN code
  Future<void> setPinCode(String pin) async {
    await SecureStore.write('app_pin', pin);
  }

  /// Verify PIN code
  Future<bool> verifyPinCode(String pin) async {
    final storedPin = await SecureStore.read('app_pin');
    return storedPin == pin;
  }

  /// Check if PIN is set
  Future<bool> isPinSet() async {
    final pin = await SecureStore.read('app_pin');
    return pin != null && pin.isNotEmpty;
  }

  /// Clear PIN code
  Future<void> clearPinCode() async {
    await SecureStore.delete('app_pin');
  }

  /// Enable/disable biometric authentication for app access
  Future<void> setBiometricEnabled(bool enabled) async {
    await SecureStore.write('biometric_enabled', enabled.toString());
  }

  /// Check if biometric is enabled
  Future<bool> isBiometricEnabled() async {
    final value = await SecureStore.read('biometric_enabled');
    return value == 'true';
  }
}
