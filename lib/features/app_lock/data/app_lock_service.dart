import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps the device's fingerprint / Face ID / PIN prompt and remembers
/// whether the user turned the app lock on.
class AppLockService {
  static const String enabledKey = 'app_lock_enabled';

  final LocalAuthentication _localAuth;
  final SharedPreferences _prefs;

  AppLockService(this._localAuth, this._prefs);

  bool get isEnabled => _prefs.getBool(enabledKey) ?? false;

  Future<void> setEnabled(bool value) => _prefs.setBool(enabledKey, value);

  /// True when the phone has a fingerprint, face or screen-lock PIN set up.
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Shows the system prompt. Biometrics are tried first and the phone's own
  /// PIN, pattern or passcode is always offered as a fallback.
  Future<bool> authenticate(String reason) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      // Cancelled, locked out, or no UI available: stay locked.
      return false;
    }
  }
}
