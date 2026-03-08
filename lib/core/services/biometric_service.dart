import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final _auth = LocalAuthentication();

  static Future<bool> isSupported() async {
    final isAvailable = await _auth.canCheckBiometrics;
    final isDeviceSupported = await _auth.isDeviceSupported();
    return isAvailable || isDeviceSupported;
  }

  static Future<bool> authenticate(String localizedReason) async {
    try {
      if (!await isSupported()) return true;

      return await _auth.authenticate(
        localizedReason: localizedReason,
        persistAcrossBackgrounding: true,
              );
    } catch (e) {
      return false;
    }
  }
}
