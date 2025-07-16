import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhoneVerificationController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  var isValid = false.obs;
  var userPhone = ''.obs;

  void sendOtpToPhone() {
    final phone = phoneController.text.trim();
    if (phone.length == 10 && RegExp(r'^[0-9]+$').hasMatch(phone)) {
      userPhone.value = phone;
      Get.snackbar("OTP Sent", "OTP has been sent to $phone",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF172B75),
          colorText: Colors.white);
    } else {
      Get.snackbar("Error", "Invalid phone number",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE74C3C),
          colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
