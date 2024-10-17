import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  // Cihazda biyometrik kimlik doğrulamanın olup olmadığını kontrol eder
  Future<bool> canCheckBiometrics() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported(); // Cihaz destekliyor mu?
      List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics(); // Desteklenen biyometrik türleri
      print("Available biometrics: $availableBiometrics"); // Konsolda desteklenen biyometrikleri göster
      return canCheckBiometrics && isDeviceSupported && availableBiometrics.isNotEmpty;
    } catch (e) {
      print("Error while checking biometrics: $e");
      return false;
    }
  }

  // Biyometrik doğrulama işlemi
  Future<bool> authenticateUser() async {
    bool canAuthenticate = await canCheckBiometrics();

    if (!canAuthenticate) {
      print("Cannot authenticate with biometrics. Make sure it's set up correctly.");
      return false; // Cihaz biyometrik doğrulamayı desteklemiyorsa
    }

    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );
      return authenticated;
    } catch (e) {
      print("Error during biometric authentication: $e");
      return false;
    }
  }
}
