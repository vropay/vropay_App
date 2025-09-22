import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/core/network/api_exception.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';
import 'package:vropay_final/app/core/services/user_service.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class OnBoardingController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = Get.find<UserService>();

  // Observable variables
  final RxInt currentPage = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  //User data
  final RxString firstName = ''.obs;
  final RxString lastName = ''.obs;
  final RxString gender = ''.obs;
  final RxString profession = ''.obs;
  final RxList<String> selectedTopics = <String>[].obs;
  final RxString difficultyLevel = ''.obs;
  final RxString communityAccess = ''.obs;
  final RxBool notificationsEnabled = true.obs;

  // UI Controllers and state
  final PageController pageController = PageController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpFieldController = TextEditingController();

  // UI State
  final RxBool isValid = false.obs;
  final RxBool isEmailEmpty = true.obs;
  final RxBool isValidPhone = false.obs;
  final RxBool isPhoneOtp = false.obs;
  final RxBool showPhoneVerification = false.obs;
  final RxString userPhone = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString otpCode = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  // Load existing user data
  void _loadUserData() {
    final user = _authService.currentUser.value;
    if (user != null) {
      firstName.value = user.firstName ?? '';
      lastName.value = user.lastName ?? '';
      gender.value = user.gender ?? '';
      profession.value = user.profession ?? '';
      selectedTopics.value = user.selectedTopics ?? [];
      difficultyLevel.value = user.difficultyLevel ?? '';
      communityAccess.value = user.communityAccess ?? '';
      notificationsEnabled.value = user.notificationsEnabled ?? true;
    }
  }

  // Navigation methods
  void goToNextPage() {
    if (currentPage.value < 2) {
      currentPage.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      goToSignup();
    }
  }

  void goToSignIn() {
    showPhoneVerification.value = true;
  }

  void goToSignup() {
    Get.offAllNamed(Routes.PROFILE);
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  // Validation methods
  void validateInput() {
    isValid.value = true;
    isEmailEmpty.value = false;
  }

  // Email Sign Up with API
  Future<void> signUpWithEmail() async {
    Get.toNamed(Routes.SIGN_UP);
  }

  // Google Authentication with API
  Future<void> signUpWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Call Google Auth API
      final response = await _authService.googleAuth(
        email: 'user@gmail.com',
        password: 'google_password',
        name: 'Google User',
        phone: '1234567890',
      );

      if (response.success) {
        Get.snackbar('Success', 'Google authentication successful');
        // Navigate to home or profile
        Get.offAllNamed(Routes.PROFILE);
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      errorMessage.value = _getErrorMessage(e);
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // OTP methods
  Future<void> sendOtpToPhone() async {
    try {
      isLoading.value = true;
      final phone = phoneController.text.trim();

      if (phone.length == 10 && RegExp(r'^[0-9]+$').hasMatch(phone)) {
        userPhone.value = phone;
        isPhoneOtp.value = true;

        // Here you would call your phone OTP API
        // For now, just show success message
        Get.snackbar("OTP Sent", "OTP has been sent to $phone",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF172B75),
            colorText: Colors.white);

        goToNextPage();
      } else {
        Get.snackbar("Error", "Invalid phone number",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE74C3C),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', "Failed to send OTP");
    } finally {
      isLoading.value = false;
    }
  }

  // Verify OTP with API
  Future<void> verifyOtp() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final otp = otpCode.value;
      if (otp.length != 5) {
        Get.snackbar('Error', 'Please enter a valid 5-digit OTP');
        return;
      }

      String emailOrPhone =
          isPhoneOtp.value ? userPhone.value : userEmail.value;

      // Call API to verify OTP
      final response = await _authService.verifyOtp(
        email: isPhoneOtp.value ? '' : emailOrPhone,
        otp: otp,
      );

      if (response.success) {
        Get.snackbar('Success', 'OTP verified successfully');

        // Navigate to home or profile
        Get.offAllNamed(Routes.PROFILE);
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      errorMessage.value = _getErrorMessage(e);
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void resendOtp() async {
    try {
      if (!isPhoneOtp.value) {
        // Resend email OTP
        await signUpWithEmail();
      } else {
        // Resend phone OTP
        await sendOtpToPhone();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to resend OTP');
    }
  }

  void updateOtp(String value) {
    otpCode.value = value;
  }

  // Update current page
  void updateCurrentPage(int page) {
    currentPage.value = page;
  }

  // Update user profile (first screen)
  Future<void> updateUserProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _userService.updateUserProfile(
          firstName: firstName.value,
          lastName: lastName.value,
          gender: gender.value,
          profession: profession.value);

      // Update local user data
      await _authService.getUserProfile();

      Get.snackbar('success', 'Profile updated successfully');
    } catch (e) {
      errorMessage.value = _getErrorMessage(e);
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Update user interests (second screen)
  Future<void> updateUserInterests() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _userService.updateUserInterests(selectedTopics: selectedTopics);

      // Update local user data
      await _authService.getUserProfile();

      Get.snackbar('Success', 'Interests updated successfully');
    } catch (e) {
      errorMessage.value = _getErrorMessage(e);
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Update difficulty level
  Future<void> updateDifficultyLevel() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _userService.updateDifficultyLevel(
          difficultyLevel: difficultyLevel.value);

      // Update local user data
      await _authService.getUserProfile();

      Get.snackbar('Success', "Difficulty level updated successfully");
    } catch (e) {
      errorMessage.value = _getErrorMessage(e);
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Update community access
  Future<void> updateCommunityAccess() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _userService.updateCommunityAccess(
          communityAccess: communityAccess.value);

      // Update local user data
      await _authService.getUserProfile();

      Get.snackbar('Success', 'Community access updated successfully');
    } catch (e) {
      errorMessage.value = _getErrorMessage(e);
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Update notification preferences
  Future<void> updateNotificationPreferences() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _userService.updateNotificationPreferences(
          notificationsEnabled: notificationsEnabled.value);

      Get.snackbar('Success', 'Notification preferences updated successfully');
    } catch (e) {
      errorMessage.value = _getErrorMessage(e);
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Complete onboarding
  Future<void> completeOnboarding() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _userService.completeUserUpdate(
          firstName: firstName.value,
          lastName: lastName.value,
          gender: gender.value,
          profession: profession.value,
          mobile: '', // Add mobile field if needed
          selectedTopics: selectedTopics,
          difficultyLevel: difficultyLevel.value,
          communityAccess: communityAccess.value,
          notificationsEnabled: notificationsEnabled.value);

      // Update local user data
      await _authService.getUserProfile();

      Get.snackbar('Success', 'Onboarding completed successfully');

      // Navigate to home screen
      Get.offAllNamed(Routes.PROFILE);
    } catch (e) {
      errorMessage.value = _getErrorMessage(e);
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  // Helper methods
  void updateFirstName(String value) => firstName.value = value;
  void updateLastName(String value) => lastName.value = value;
  void updateGender(String value) => gender.value = value;
  void updateProfession(String value) => profession.value = value;
  void updateSelectedTopics(List<String> topics) =>
      selectedTopics.value = topics;
  void updateDifficultyLevelValue(String value) =>
      difficultyLevel.value = value;
  void updateCommunityAccessValue(String value) =>
      communityAccess.value = value;
  void updateNotificationEnabled(bool value) =>
      notificationsEnabled.value = value;

  // Clean up controllers
  void clearControllers() {
    try {
      otpFieldController.clear();
      emailController.clear();
      phoneController.clear();
    } catch (e) {
      print('Error clearing controllers: $e');
    }
  }

  @override
  void onClose() {
    clearControllers();
    try {
      emailController.dispose();
      pageController.dispose();
      phoneController.dispose();
      otpFieldController.dispose();
    } catch (e) {
      print('Controller disposal error: $e');
    }
    super.onClose();
  }

  String _getErrorMessage(dynamic error) {
    if (error is NoInternetException) {
      return 'No internet connection. Please check your network.';
    } else if (error is TimeoutException) {
      return 'Request timeout. Please try again';
    } else if (error is ServerException) {
      return 'Server error. Please try again later.';
    } else if (error is NetworkException) {
      return 'Network error. Please check your connection.';
    } else {
      return 'Something went wrong. Please try again';
    }
  }
}
