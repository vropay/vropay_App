import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  TextEditingController emailController = TextEditingController();
  var isValid = false.obs;
  var generatedOTP = ''.obs;
  var isEmailEmpty = true.obs; // Track if the email field is empty


  void validateInput() {
    String input = emailController.text.trim();
    bool isValidEmail = RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$').hasMatch(input);
    bool isValidPhone = RegExp(r'^\d{10}$').hasMatch(input);

    // Check if the input matches either email or phone format
    isValid.value = isValidEmail || isValidPhone;

    // Track if the email field is empty or not
    isEmailEmpty.value = input.isEmpty;
  }

  void generateOTP() {
    generatedOTP.value = "12345"; // Hardcoded OTP
  }

  @override
  void onClose() {
    emailController.dispose(); // Dispose PageController to avoid memory leaks
    super.onClose();
  }
}
