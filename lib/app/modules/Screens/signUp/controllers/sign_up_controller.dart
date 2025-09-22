import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class SignUpController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  var isValid = false.obs;
  var isEmailEmpty = true.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var userEmail = ''.obs;

  void validateInput() {
    String input = emailController.text.trim();
    bool isValidEmail =
        RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')
            .hasMatch(input);
    bool isValidPhone = RegExp(r'^\d{10}$').hasMatch(input);

    // Check if the input matches either email or phone format
    isValid.value = isValidEmail || isValidPhone;

    // Track if the email field is empty or not
    isEmailEmpty.value = input.isEmpty;
  }

  // Email Sign up with API
  Future<void> signUpWithEmail() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final email = emailController.text.trim();
      final name = nameController.text.trim();

      if (email.isEmpty) {
        return;
      }

      // Call API to sign up with email
      final response =
          await _authService.signUpWithEmail(email: email, name: name);

      if (response.success) {
        userEmail.value = email;
        Get.snackbar('Success', 'OTP sent to your email');
        Get.toNamed(Routes.OTP_SCREEN, arguments: {'email': email});
      } else {
        errorMessage.value = response.message ?? 'Sign up failed';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Sign up failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Google Sign Up
  Future<void> signUpWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('🚀 Starting Google sign up process...');

      final response = await _authService.googleAuth(
          email: 'kapadiadigesh@gmail.com',
          password: 'digesh1234',
          name: 'Digesh Kapadiya',
          phone: '7600766992');

      if (response.success) {
        Get.snackbar('Success', 'Google sign up successful');
        Get.offAllNamed(Routes.HOME);
      } else {
        errorMessage.value = response.message ?? 'Google sign up failed';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = e.toString(); // Better error messages
      if (e.toString().contains('timeout')) {
        Get.snackbar('Error',
            'Request timeout. Please check your internet connection and try again.');
      } else if (e.toString().contains('network')) {
        Get.snackbar(
            'Error', 'Network error. Please check your internet connection.');
      } else {
        Get.snackbar('Error', 'Google sign up failed: ${e.toString()}');

        print('❌ Google sign up error: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Apple Sign Up
  Future<void> signUpWithApple() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Generate a random nance
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      // Request Apple Sign In
      final credential = await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ], nonce: hashedNonce);

      // Use the credential to sign up with backend
      final response = await _authService.googleAuth(
          email: 'kapadiadigesh@gmail.com',
          password: 'Digesh1234',
          name: '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
              .trim(),
          phone: '7600766992');

      if (response.success) {
        Get.snackbar('Success', 'Apple sign up successful');
        Get.offAllNamed(Routes.HOME);
      } else {
        errorMessage.value = response.message ?? 'Apple sign up failed';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Apple sign up failed: ${e.toString()}');
      print('❌ Apple sign up error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Generate random n0nce for Apple Sign In
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  @override
  void onClose() {
    emailController.dispose(); // Dispose PageController to avoid memory leaks
    nameController.dispose();
    super.onClose();
  }
}
