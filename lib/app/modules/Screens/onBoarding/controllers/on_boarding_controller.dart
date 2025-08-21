import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Utilities/constants/Colors.dart';
import 'package:vropay_final/Utilities/snackbar_helper.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class OnBoardingController extends GetxController {
  var currentPage = 0.obs;
  final PageController pageController = PageController();
  TextEditingController emailController = TextEditingController();
  var isValid = false.obs;
  var generatedOTP = ''.obs;
  var isEmailEmpty = true.obs; // Track if the email field is empty
  final TextEditingController phoneController = TextEditingController();
  var isValidPhone = false.obs;
  var userPhone = ''.obs;
  var userEmail = ''.obs;
  var userPhone1 = ''.obs;
  var otpCode = ''.obs;
  var isEmailVerified = false.obs;
  var isPhoneOtp = false.obs;
  var showPhoneVerification = false.obs;

  final TextEditingController emailController1 = TextEditingController();
  final TextEditingController phoneController1 = TextEditingController();
  final TextEditingController otpFieldController = TextEditingController();

  void goToNextPage() {
    if (currentPage.value < 3) {
      currentPage.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      goToSignup();
    }
  }

  void goToSignup() {
    // Clear controllers before navigation to prevent disposal issues
    clearControllers();
    Get.toNamed(Routes.SIGN_UP);
  }

  void goToSignIn() {
    // Navigate to home screen for now since sign-in view doesn't exist yet
    Get.toNamed(Routes.PHONE_VERIFICATION);
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

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

  void generateOTP() {
    generatedOTP.value = "12345"; // Hardcoded OTP
  }

  void sendOtpToPhone() {
    final phone = phoneController.text.trim();
    if (phone.length == 10 && RegExp(r'^[0-9]+$').hasMatch(phone)) {
      userPhone.value = phone;
      isPhoneOtp.value = true;
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

  /// Send OTP to Email
  void sendOtpToEmail() {
    if (emailController.text.isNotEmpty && emailController.text.contains("@")) {
      userEmail.value = emailController.text;
      isPhoneOtp.value = false; // It's email OTP
      setSnackBar("OTP Sent", "OTP has been sent to ${userEmail.value}.",
          position: SnackPosition.BOTTOM,
          backgroundColor: KConstColors.snackbarSecondary);
    } else {
      setSnackBar(
        "Error",
        "Please enter a valid email address",
        position: SnackPosition.BOTTOM,
        backgroundColor: KConstColors.errorSnackbar,
      );
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
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white);
    } else {
      Get.snackbar("OTP Sent", "A new OTP has been sent to your phone number.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white);
    }
  }

  /// Update OTP code when user types
  void updateOtp(String value) {
    otpCode.value = value;
  }

  // Add this method to safely clear controllers
  void clearControllers() {
    try {
      otpFieldController.clear();
      emailController.clear();
      phoneController.clear();
      emailController1.clear();
      phoneController1.clear();
    } catch (e) {
      print('Error clearing controllers: $e');
    }
  }

  @override
  void onClose() {
    // Clear controllers first, then dispose
    clearControllers();

    // Dispose controllers safely
    try {
      emailController.dispose();
      pageController.dispose();
      phoneController.dispose();
      emailController1.dispose();
      phoneController1.dispose();
      otpFieldController.dispose();
    } catch (e) {
      print('Controller disposal error: $e');
    }
    super.onClose();
  }
}
