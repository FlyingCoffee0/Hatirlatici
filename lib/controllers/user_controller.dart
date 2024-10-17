import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Function to sign in
  Future<void> signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim()
      );
      Get.snackbar('Success', 'You are successfully signed in');
      // Navigate to TODO list screen after successful login
      Get.offAllNamed('/todoList');
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Function to sign out
  Future<void> signOut() async {
    await _auth.signOut();
    Get.offAllNamed('/signIn');
  }

   Future<void> signUp() async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim()
      );
      Get.snackbar('Success', 'Account created successfully');
      // Navigate to TODO list screen after successful sign-up
      Get.offAllNamed('/todoList');
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }
}



