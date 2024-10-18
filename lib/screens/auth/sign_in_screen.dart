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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign in with email',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Enter your email and password',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 30),
                
                // Email TextField
                TextField(
                  controller: _userController.emailController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                
                // Password TextField
                TextField(
                  controller: _userController.passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 30),
                
                // Sign In Button
                ElevatedButton(
                  onPressed: () => _userController.signIn(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8A56AC), // Soft purple color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 18),
                    minimumSize: Size(double.infinity, 50), // Full-width button
                  ),
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                
                // Biometric Sign In Button
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300], // Daha küçük ve gri bir buton
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    minimumSize: Size(double.infinity, 40), // Full-width buton, daha küçük
                  ),
                  child: Text(
                    'Sign In with Biometrics',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Sign Up text link
                Center(
                  child: GestureDetector(
                    onTap: () => Get.toNamed('/signUp'),  // Navigates to Sign Up screen
                    child: Text(
                      'Don’t have an account? Sign Up',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
