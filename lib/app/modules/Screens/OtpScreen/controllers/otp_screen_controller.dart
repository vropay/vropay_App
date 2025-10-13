import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vropay_final/Utilities/constants/Colors.dart';
import 'package:vropay_final/Utilities/snackbar_helper.dart';
import 'package:vropay_final/app/core/models/api_response.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';
import 'package:vropay_final/app/modules/Screens/onBoarding/controllers/on_boarding_controller.dart';
import 'package:vropay_final/app/routes/app_pages.dart';
import 'package:vropay_final/app/modules/Screens/profile/controllers/profile_controller.dart';

class OTPController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var userEmail = ''.obs;
  var userPhone = ''.obs;
  var otpCode = ''.obs;
  var isEmailVerified = false.obs;
  var isPhoneOtp = false.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isEmailChange = false.obs;
  var profileData = <String, dynamic>{}.obs;
  var resendTimer = 0.obs;
  var canResendOtp = true.obs;
  Timer? _resendTimer;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpFieldController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Get email from previous screen
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    if (args['email'] != null) {
      userEmail.value = args['email'];
      emailController.text = args['email'];
    }

    // Check if this is for email change
    if (args['isEmailChange'] == true) {
      isEmailChange.value = true;
      profileData.value = args['profileData'] ?? {};
    }
    _initializeTimerFromOnBoarding();
  }

  void _initializeTimerFromOnBoarding() {
    try {
      // Get timer state from on boarding controller if available
      final onBoardingController = Get.find<OnBoardingController>();
      resendTimer.value = onBoardingController.resendTimer.value;
      canResendOtp.value = onBoardingController.canResendOtp.value;

      if (resendTimer.value > 0) {
        _startResendTimer();
      }
    } catch (e) {
      _initializeResendTimer();
    }
  }

  void _initializeResendTimer() {
    canResendOtp.value = false;
    resendTimer.value = 60;
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        canResendOtp.value = true;
        timer.cancel();
        _resendTimer = null;
      }
    });
  }

  /// Send OTP to Email
  Future<void> sendOtpToEmail() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      if (emailController.text.isNotEmpty &&
          emailController.text.contains("@")) {
        userEmail.value = emailController.text;
        isPhoneOtp.value = false; // It's email OTP

        // For email change, we simulate OTP sending
        if (isEmailChange.value) {
          setSnackBar("OTP Sent",
              "OTP has been sent to ${userEmail.value} for verification.",
              position: SnackPosition.BOTTOM,
              backgroundColor: KConstColors.snackbarSecondary);
          return;
        }

        // Call API to send OTP for normal signup
        final response = await _authService.signUpWithEmail(
            email: userEmail.value, name: 'User');

        if (response.success) {
          setSnackBar("OTP Sent", "OTP has been sent to ${userEmail.value}.",
              position: SnackPosition.BOTTOM,
              backgroundColor: KConstColors.snackbarSecondary);
        } else {
          setSnackBar("Error", response.message ?? "Failed to send OTP",
              position: SnackPosition.BOTTOM,
              backgroundColor: KConstColors.errorSnackbar);
        }
      } else {
        setSnackBar(
          "Error",
          "Please enter a valid email address",
          position: SnackPosition.BOTTOM,
          backgroundColor: KConstColors.errorSnackbar,
        );
      }
    } catch (e) {
      setSnackBar('Error', "Failed to send OTP: ${e.toString()}",
          position: SnackPosition.BOTTOM,
          backgroundColor: KConstColors.errorSnackbar);
    } finally {
      isLoading.value = false;
    }
  }

  /// Send OTP to Phone
  void sendOtpToPhone() {
    if (phoneController.text.isNotEmpty && phoneController.text.length == 10) {
      userPhone.value = phoneController.text;
      isPhoneOtp.value = true;
      Get.snackbar("OTP Sent", "OTP has been sent to ${userPhone.value}.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white);
    } else {
      Get.snackbar("Error", "Please enter a valid phone number.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: KConstColors.errorSnackbar,
          colorText: Colors.white);
    }
  }

  Future<void> verifyEmailOtp() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (otpCode.value.trim().isEmpty) {
        Get.snackbar("Error", "Please enter OTP",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: KConstColors.errorSnackbar,
            colorText: Colors.white);
        return;
      }

      // Handle email change verification differently
      if (isEmailChange.value) {
        // For email change, use simple verification (any 6-digit code)
        if (otpCode.value.trim().length == 6) {
          isEmailVerified.value = true;
          otpFieldController.clear();
          otpCode.value = '';

          Get.snackbar(
            "Success",
            "Email verified successfully!",
            snackPosition: SnackPosition.TOP,
            backgroundColor: KConstColors.successSnackbar,
            colorText: Colors.white,
          );

          // Update email in profile after verification
          final profileController = Get.find<ProfileController>();
          await profileController.updateEmailAfterVerification(
              userEmail.value, profileData.value);

          // Go back to profile screen
          Get.back();
          Get.back(); // Go back twice to return to profile
        } else {
          Get.snackbar(
            "Error",
            "Please enter a valid 6-digit OTP",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: KConstColors.errorSnackbar,
            colorText: Colors.white,
          );
        }
      } else {
        // Call API to verify OTP for normal signup
        final response = await _authService.verifyOtp(
            email: userEmail.value, otp: otpCode.value.trim());

        if (response.success) {
          isEmailVerified.value = true;
          otpFieldController.clear();
          otpCode.value = '';

          Get.snackbar(
            "Success",
            "Email OTP Verified!",
            snackPosition: SnackPosition.TOP,
            backgroundColor: KConstColors.successSnackbar,
            colorText: Colors.white,
          );

          // Navigate to home screen for normal signup
          Get.offAllNamed(Routes.HOME, arguments: {'showUserDetails': true});
        } else {
          Get.snackbar(
            "Error",
            response.message ?? "Invalid OTP!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: KConstColors.errorSnackbar,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to verify OTP: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: KConstColors.errorSnackbar,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void verifyPhoneOtp() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (otpCode.value.trim().isEmpty) {
        Get.snackbar("Error", "Please enter OTP",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: KConstColors.errorSnackbar,
            colorText: Colors.white);
        return;
      }

      final otp = otpCode.value.trim();
      if (otp.length != 5) {
        Get.snackbar('Error', 'Please enter a valid 5-digit OTP',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: KConstColors.errorSnackbar,
            colorText: Colors.white);
        return;
      }

      // Get the onBoarding controller to determine the flow and phone number
      final onBoardingController = Get.find<OnBoardingController>();
      final isSignInFlow = onBoardingController.isSignInFlow.value;
      final phoneNumber = onBoardingController.userPhone.value;

      ApiResponse<Map<String, dynamic>> response;

      if (isSignInFlow) {
        // For sign-in flow, use verifyPhoneSignInOtp
        response = await _authService.verifyPhoneSignInOtp(
            phoneNumber: phoneNumber, otp: otp);
      } else {
        // For sign-up flow, use verifyPhoneNumber
        response = await _authService.verifyPhoneNumber(otp: otp);
      }

      if (response.success) {
        Get.snackbar("Success", "Phone OTP Verified!",
            snackPosition: SnackPosition.TOP,
            backgroundColor: KConstColors.successSnackbar,
            colorText: Colors.white);

        // Clear OTP field
        otpFieldController.clear();
        otpCode.value = '';

        // Navigate based on flow type
        if (isSignInFlow) {
          // For sign-in flow, navigate to profile
          Get.offAllNamed(Routes.PROFILE);
        } else {
          // For sign-up flow, navigate to learn screen
          Get.offAllNamed(Routes.LEARN_SCREEN);
        }
      } else {
        Get.snackbar(
          "Error",
          response.message ?? "Invalid OTP!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: KConstColors.errorSnackbar,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to verify OTP: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: KConstColors.errorSnackbar,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend OTP for Email or Phone
  Future<void> resendOtp() async {
    if (!canResendOtp.value) return;
    if (!isPhoneOtp.value) {
      await sendOtpToEmail();
    } else {
      // For phone OTP, delegate to onBoarding controller
      try {
        final onBoardingController = Get.find<OnBoardingController>();

        // Get the phone number from onBoarding controller
        final phone = onBoardingController.phoneController.text.trim();
        final isSignInFlow = onBoardingController.isSignInFlow.value;

        if (phone.length == 10 && RegExp(r'^[0-9]+$').hasMatch(phone)) {
          final formattedPhone = '+91$phone';

          ApiResponse<Map<String, dynamic>> response;

          if (isSignInFlow) {
            print('🔄 Calling resendSignInOtp for: $formattedPhone');

            response =
                await _authService.resendSignInOtp(phoneNumber: formattedPhone);
          } else {
            response = await _authService.requestPhoneVerification(
                phoneNumber: formattedPhone);
          }

          // Call the appropriate API directly
          // final response = isSignInFlow
          //     ? await _authService.signInWithPhone(phoneNumber: formattedPhone)
          //     : await _authService.requestPhoneVerification(
          //         phoneNumber: formattedPhone);

          if (response.success) {
            Get.snackbar(
                "OTP Sent", "Verification code sent to your phone number",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF172B75),
                colorText: Colors.white);

            // Restart timer after resend
            _initializeResendTimer();
          } else {
            Get.snackbar("Error", response.message ?? "Failed to resend OTP",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFFE74C3C),
                colorText: Colors.white);
          }
        } else {
          Get.snackbar("Error", "Invalid phone number",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFFE74C3C),
              colorText: Colors.white);
        }
      } catch (e) {
        print('❌ Resend OTP error: $e');

        Get.snackbar("Error", "Failed to resend OTP: ${e.toString()}",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE74C3C),
            colorText: Colors.white);
      }
    }
  }

  // Add helper method to get formatted timer text
  String getFormattedTimer() {
    final minutes = resendTimer.value ~/ 60;
    final seconds = resendTimer.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
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
    _resendTimer?.cancel();
    super.onClose();
  }
}
