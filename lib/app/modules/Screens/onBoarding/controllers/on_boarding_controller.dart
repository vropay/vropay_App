import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:vropay_final/app/core/network/api_exception.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';
import 'package:vropay_final/app/core/services/user_service.dart';
import 'package:vropay_final/app/modules/Screens/home/controllers/home_controller.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class OnBoardingController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = Get.find<UserService>();

  // Observable variables
  final RxInt currentPage = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Disposal flag
  bool _isDisposed = false;

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
      // Load gender from user data
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
    Get.offAllNamed(Routes.SUBSCRIPTION, arguments: {'isOnboarding': true});
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  // Validation methods
  void validateInput() {
    isValid.value = true;
    isEmailEmpty.value = false;
  }

  // Gender selection method
  void selectGender(String selectedGender) {
    gender.value = selectedGender;
  }

  // Save user profile data
  Future<void> saveUserProfile() async {
    try {
      isLoading.value = true;
      await _authService.updateUserProfile(
        firstName: firstName.value,
        lastName: lastName.value,
        gender: gender.value,
        profession: profession.value,
        selectedTopics: selectedTopics.toList(),
        difficultyLevel: difficultyLevel.value,
        communityAccess: communityAccess.value,
        notificationsEnabled: notificationsEnabled.value,
      );
    } catch (e) {
      print('Error saving user profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Email Sign Up with API
  Future<void> signUpWithEmail() async {
    // Stay on onboarding screen, just navigate to next page
    goToNextPage();
  }

  // Apple Sign-In with profile completion validation
  Future<void> signUpWithApple() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Generate a random nonce
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      // Request Apple Sign In
      final credential = await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ], nonce: hashedNonce);

      final email = credential.email ?? '';
      final fullName =
          '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim();
      final identityToken = credential.identityToken ?? '';

      final response = await _authService.appleAuth(
        email: email,
        name: fullName,
        identityToken: identityToken,
        userIdentifier: credential.userIdentifier ?? '',
      );

      if (response.success) {
        // Get user profile to check completion status
        await _authService.getUserProfile();
        final user = _authService.currentUser.value;

        // Check if user has completed all required profile details
        bool hasCompleteProfile = user != null &&
            user.firstName != null &&
            user.firstName!.isNotEmpty &&
            user.lastName != null &&
            user.lastName!.isNotEmpty &&
            // Gender is optional (user can prefer not to disclose)
            user.profession != null &&
            user.profession!.isNotEmpty &&
            user.selectedTopics != null &&
            user.selectedTopics!.isNotEmpty &&
            user.difficultyLevel != null &&
            user.difficultyLevel!.isNotEmpty &&
            user.communityAccess != null &&
            user.communityAccess!.isNotEmpty;

        if (!hasCompleteProfile) {
          Get.offAllNamed(Routes.HOME, arguments: {'showUserDetails': true});
        } else {
          Get.offAllNamed(Routes.HOME);
        }
      } else {
        errorMessage.value = response.message ?? 'Apple sign-in failed';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Apple sign-in failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Google Authentication with API
  Future<void> signUpWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('🚀 Starting Google sign-in...');

      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile', 'openid'],
        serverClientId:
            '138350205652-bi63pi8effgi3tepl4t7v9le4vlfgsh4.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      print('📱 Google user: ${googleUser?.email}');

      if (googleUser == null) {
        print('❌ User cancelled Google sign-in');
        return;
      }

      // Get the authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('📱 Got ID token: ${googleAuth.idToken != null}');

      // Check if we have the required token
      if (googleAuth.idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      final response = await _authService.googleAuth(
        email: googleUser.email,
        name: googleUser.displayName ?? '',
        idToken: googleAuth.idToken!,
      );

      if (response.success) {
        final responseData = response.data;
        final isNewUser = responseData?['isNewUser'] ?? false;

        // Get user profile to check completion status
        await _authService.getUserProfile();
        final user = _authService.currentUser.value;

        // Check if user has completed all required profile details
        bool hasCompleteProfile = user != null &&
            user.firstName != null &&
            user.firstName!.isNotEmpty &&
            user.lastName != null &&
            user.lastName!.isNotEmpty &&
            // Gender is optional (user can prefer not to disclose)
            user.profession != null &&
            user.profession!.isNotEmpty &&
            user.selectedTopics != null &&
            user.selectedTopics!.isNotEmpty &&
            user.difficultyLevel != null &&
            user.difficultyLevel!.isNotEmpty &&
            user.communityAccess != null &&
            user.communityAccess!.isNotEmpty;

        if (!hasCompleteProfile) {
          // Incomplete profile - redirect to user details
          Get.offAllNamed(Routes.HOME, arguments: {'showUserDetails': true});
        } else {
          // Complete profile - redirect to home
          Get.offAllNamed(Routes.HOME);
        }
      } else {
        String errorMsg = response.message ?? 'Google sign-in failed';
        if (errorMsg.contains('already registered with manual login')) {
          errorMsg =
              'This email is already registered. Please sign in with your email and password instead.';
        }
        Get.snackbar('Error', errorMsg);
      }
    } catch (e) {
      print('❌ Google sign-in error: $e');
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Google sign-in failed: ${e.toString()}');
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

      // Get gender from HomeController if available
      final homeController = Get.find<HomeController>();
      final selectedGender = homeController.selectedLevel.value.isNotEmpty
          ? homeController.selectedLevel.value
          : gender.value;

      await _userService.completeUserUpdate(
          firstName: firstName.value,
          lastName: lastName.value,
          gender: selectedGender,
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

  @override
  void onClose() {
    if (_isDisposed) return;
    _isDisposed = true;

    try {
      emailController.dispose();
      phoneController.dispose();
      otpFieldController.dispose();
      pageController.dispose();
    } catch (e) {
      print('Controller disposal error: $e');
    }
    super.onClose();
  }

  // Generate random nonce for Apple Sign In
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
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
