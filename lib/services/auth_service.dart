import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> isDeviceSupported() async => await _localAuth.isDeviceSupported();
  static Future<bool> canCheckBiometrics() async => await _localAuth.canCheckBiometrics;
  static Future<List<BiometricType>> getAvailableBiometrics() async => await _localAuth.getAvailableBiometrics();

  static Future<bool> authenticateWithBiometrics({required String localizedReason}) async {
    try {
      final bool isAvailable = await canCheckBiometrics();
      if (!isAvailable) return false;
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(useErrorDialogs: true, stickyAuth: true, sensitiveTransaction: true, biometricOnly: false),
      );
    } on PlatformException catch (e) {
      print('Biometric error: $e');
      return false;
    }
  }

  static Future<void> stopAuthentication() async => await _localAuth.stopAuthentication();
}
