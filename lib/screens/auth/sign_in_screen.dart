import 'package:case_codeway/services/biometric_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_controller.dart';

class SignInScreen extends StatelessWidget {
  final UserController _userController = Get.put(UserController());
  final BiometricService _biometricService = BiometricService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Cihaz biyometrik doğrulamayı destekliyor mu kontrol et
                bool canAuthenticate = await _biometricService.canCheckBiometrics();
                if (!canAuthenticate) {
                  Get.snackbar('Error', 'Biometric authentication is not available or not set up on this device.');
                  return;
                }

                // Eğer destekleniyorsa, biyometrik doğrulama başlat
                bool authenticated = await _biometricService.authenticateUser();
                if (authenticated) {
                  _userController.signIn();  // Biyometrik doğrulama başarılıysa
                } else {
                  Get.snackbar('Error', 'Biometric authentication failed. Please ensure biometrics is set up correctly.');
                }
              },
              child: Text('Sign In with Biometrics'),
            ),
            SizedBox(height: 16),

            // Geleneksel e-posta ve şifre ile giriş
            TextField(
              controller: _userController.emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _userController.passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _userController.signIn(),
              child: Text('Sign In with Email and Password'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.toNamed('/signUp'),  // Navigates to Sign Up screen
              child: Text('Don’t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}