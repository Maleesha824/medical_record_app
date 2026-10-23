import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final LocalAuthentication auth = LocalAuthentication();
  static const key = 'biometric_lock';

  static Future<bool> enabled() async => (await SharedPreferences.getInstance()).getBool(key) ?? false;
  static Future<void> setEnabled(bool value) async => (await SharedPreferences.getInstance()).setBool(key, value);
  static Future<bool> authenticate() async {
    try {
      if (!await auth.isDeviceSupported()) return false;
      return await auth.authenticate(localizedReason: 'Unlock your private medical records', persistAcrossBackgrounding: true);
    } catch (_) { return false; }
  }
}
