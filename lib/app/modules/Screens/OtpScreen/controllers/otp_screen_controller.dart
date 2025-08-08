import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vropay_final/Utilities/constants/Colors.dart';

import '../../../../../Utilities/snackbar_helper.dart';

class OTPController extends GetxController {
  var userEmail = ''.obs;
  var userPhone = ''.obs;
  var otpCode = ''.obs;
  var isEmailVerified = false.obs;
  var isPhoneOtp = false.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpFieldController = TextEditingController();

  /// Send OTP to Email
  void sendOtpToEmail() {
    if (emailController.text.isNotEmpty && emailController.text.contains("@")) {
      userEmail.value = emailController.text;
      isPhoneOtp.value = false; // It's email OTP
      setSnackBar("OTP Sent", "OTP has been sent to ${userEmail.value}.", position: SnackPosition.BOTTOM, backgroundColor: KConstColors.snackbarSecondary);
    } else {
      setSnackBar("Error", "Please enter a valid email address",
        position: SnackPosition.BOTTOM, backgroundColor: KConstColors.errorSnackbar,
      );
    }
  }

  /// Send OTP to Phone
  void sendOtpToPhone() {
    if (phoneController.text.isNotEmpty && phoneController.text.length == 10) {
      userPhone.value = phoneController.text;
      isPhoneOtp.value = true;
      Get.snackbar("OTP Sent", "OTP has been sent to ${userPhone.value}.",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.blue, colorText: Colors.white);
    } else {
      Get.snackbar("Error", "Please enter a valid phone number.",
          snackPosition: SnackPosition.BOTTOM, backgroundColor:KConstColors.errorSnackbar, colorText: Colors.white);
    }
  }

  void verifyEmailOtp() {
    if (otpCode.value.trim() == "12345") {
      isEmailVerified.value = true;
      otpFieldController.clear();
      otpCode.value = '';
      Get.snackbar("Success", "Email OTP Verified!",
          snackPosition: SnackPosition.TOP,
          backgroundColor: KConstColors.successSnackbar,
          colorText: Colors.white);

      // Prepare for phone OTP
      isPhoneOtp.value = true;
      otpCode.value = '';
      otpFieldController.clear();
      userPhone.value = phoneController.text;
      Get.toNamed('/phone-verification');
    } else {
      Get.snackbar("Error", "Invalid Email OTP!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: KConstColors.errorSnackbar,
          colorText: KConstColors.colorPrimary);
    }
  }

  void verifyPhoneOtp() {
    if (otpCode.value.trim() == "56789") {
      Get.snackbar("Success", "Phone OTP Verified!",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white);
      Get.offAllNamed('/home');
    } else {
      Get.snackbar("Error", "Invalid Phone OTP!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    }
  }

  /// Resend OTP for Email or Phone
  void resendOtp() {
    if (!isPhoneOtp.value) {
      Get.snackbar("OTP Sent", "A new OTP has been sent to your email.",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.blue, colorText: Colors.white);
    } else {
      Get.snackbar("OTP Sent", "A new OTP has been sent to your phone number.",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.blue, colorText: Colors.white);
    }
  }

  /// Update OTP code when user types
  void updateOtp(String value) {
    otpCode.value = value;
  }
  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    otpFieldController.dispose();
    super.onClose();
  }
}
