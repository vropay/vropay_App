import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  var _isProcessing = false;

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
    if (_isProcessing) return; // Prevent multiple calls

    try {
      _isProcessing = true;
      isLoading.value = true;
      errorMessage.value = '';

      final email = emailController.text.trim();
      final name = nameController.text.trim();

      if (email.isEmpty) {
        return;
      }

      // Call API to sign up with email
      final response = await _authService
          .signUpWithEmail(email: email, name: name)
          .timeout(Duration(seconds: 30));

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
      _isProcessing = false;
    }
  }

  // Redirect to onboarding for Google sign-in
  Future<void> signUpWithGoogle() async {
    Get.offAllNamed(Routes.ON_BOARDING);
  }

  // Redirect to onboarding for Apple sign-in
  Future<void> signUpWithApple() async {
    Get.offAllNamed(Routes.ON_BOARDING);
  }

  @override
  void onClose() {
    try {
      if (!_isProcessing && !Get.isRegistered<SignUpController>()) {
        emailController
            .dispose(); // Dispose PageController to avoid memory leaks
        nameController.dispose();
      }
    } catch (e) {
      print('SignUp controller disposal error: $e');
    }
    super.onClose();
  }
}
