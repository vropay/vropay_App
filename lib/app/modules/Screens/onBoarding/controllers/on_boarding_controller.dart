import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:vropay_final/app/core/models/api_response.dart';
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
  final RxBool _isDisposed = false.obs;

  // Public getter for disposal state
  bool get isDisposed => _isDisposed.value;

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
  final RxBool isSignInFlow = false.obs;
  final RxBool showPhoneVerification = false.obs;
  final RxString userPhone = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString otpCode = ''.obs;
  var resendTimer = 0.obs;
  var canResendOtp = true.obs;
  Timer? _resendTimer;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _initializeResendTimer();
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

  void _initializeResendTimer() {
    canResendOtp.value = false;
    resendTimer.value = 60;

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
    print('🔍 Setting isSignInFlow to TRUE');

    isSignInFlow.value = true; // Set sign-in flow to true
    showPhoneVerification.value = true;
    print('🔍 isSignInFlow after setting: ${isSignInFlow.value}');

    goToNextPage();
  }

  void goBackToSignUp() {
    showPhoneVerification.value = false;
    isSignInFlow.value = false; // Ensure sign-up flow
    phoneController.clear();
  }

  void goToSignup() {
    Get.offAllNamed(Routes.SUBSCRIPTION, arguments: {'isOnboarding': true});
  }

  void onPageChanged(int index) {
    if (!_isDisposed.value) {
      currentPage.value = index;
    }
  }

  // Validation methods
  void validateInput() {
    if (!_isDisposed.value) {
      isValid.value = true;
      isEmailEmpty.value = false;
    }
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
    try {
      isLoading.value = true;
      final email = emailController.text.trim();

      if (email.isEmpty || !GetUtils.isEmail(email)) {
        Get.snackbar('Error', 'Please enter a valid email address');
        return;
      }

      userEmail.value = email;
      isPhoneOtp.value = false; // This is email OTP
      isSignInFlow.value = false; // This is sign-up flow

      // Call the API
      final response = await _authService.signUpWithEmail(email: email);

      if (response.success) {
        Get.snackbar('Success', 'OTP sent to your email');
        goToNextPage(); // Go to email OTP screen
      } else {
        Get.snackbar('Error', response.message ?? 'Failed to send OTP');
      }
    } catch (e) {
      Get.snackbar(
          'Error', 'Your Email is already exists try to login with number');
    } finally {
      isLoading.value = false;
    }
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
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

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

        // Mark first time as false since user is authenticated
        final storage = GetStorage();
        storage.write('isFirstTime', false);

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
        scopes: ['email', 'profile'],
        serverClientId:
            '785813482327-37jbltj9j5ejaflul09gdg9hr3pn2iv9.apps.googleusercontent.com',
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
        print('✅ Google auth successful');

        // Verify token was saved
        final savedToken = _authService.authToken.value;
        print(
          '🔍 Token after Google auth: ${savedToken.isNotEmpty ? 'EXISTS' : 'MISSING'}',
        );

        final responseData = response.data;
        final isNewUser = responseData?['isNewUser'] ?? false;

        // Get user profile to check if phone number exists
        await _authService.getUserProfile();
        final user = _authService.currentUser.value;

        if (isNewUser || user?.mobile == null || user!.mobile!.isEmpty) {
          // New user - redirect to phone verification (skip email verification)
          showPhoneVerification.value = true;
          currentPage.value = 1; // Go to phone verification screen
          pageController.animateToPage(
            1,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          // Existing user - check profile completion
          await _authService.getUserProfile();
          final user = _authService.currentUser.value;

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

          // Mark first time as false since user is authenticated
          final storage = GetStorage();
          storage.write('isFirstTime', false);

          if (!hasCompleteProfile) {
            Get.offAllNamed(Routes.HOME, arguments: {'showUserDetails': true});
          } else {
            Get.offAllNamed(Routes.HOME);
          }
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
      Get.snackbar('Error', 'Google sign-in failed: $e}');
    } finally {
      isLoading.value = false;
    }
  }

  // Send OTP to phone using API
  Future<void> sendOtpToPhone() async {
    try {
      isLoading.value = true;
      final phone = phoneController.text.trim();

      if (phone.length == 10 && RegExp(r'^[0-9]+$').hasMatch(phone)) {
        // Format phone number with country code
        final formattedPhone = '+91$phone';
        userPhone.value = formattedPhone;
        isPhoneOtp.value = true; // This is phone OTP
        print('DEBUG: isSignInFlow: ${isSignInFlow.value}');
      } else {
        Get.snackbar(
          "Error",
          "Invalid phone number",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE74C3C),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar('Error', "Failed to send OTP: ${e.toString()}");
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

      if (isPhoneOtp.value) {
        if (isSignInFlow.value) {
          // Call the separate sign in verification method
          await verifySignInOtp();
          return; // exit early to avoid executing the rest
        } else {
          // Verify phone OTP - after this go to user details
          final response = await _authService.verifyPhoneNumber(otp: otp);

          if (response.success) {
            Get.snackbar('Success', 'Phone number verified successfully');
            // Mark first time as false since user is authenticated
            final storage = GetStorage();
            storage.write('isFirstTime', false);

            // Navigate to learn screen to collect user data
            Get.offAllNamed(Routes.HOME, arguments: {'showUserDetails': true});
          } else {
            Get.snackbar(
              'Error',
              response.message ?? 'Phone verification failed',
            );
          }
        }
      } else {
        // Verify email OTP - after this go to phone verification
        final response = await _authService.verifyOtp(
          email: userEmail.value,
          otp: otp,
        );

        if (response.success) {
          Get.snackbar('Success', 'Email verified successfully');
          // Show phone verification screen
          showPhoneVerification.value = true;
          currentPage.value =
              1; // Go back to signup page but show phone verification
          pageController.animateToPage(
            1,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          Get.snackbar(
            'Error',
            response.message ?? 'Email verification failed',
          );
        }
      }
    } catch (e) {
      errorMessage.value = _getErrorMessage(e);
      Get.snackbar('Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  void resendOtp() async {
    if (_isDisposed.value) return;
    try {
      if (!isPhoneOtp.value) {
        // Resend email OTP - use dedicated API instead of signUpWithEmail
        final email = emailController.text.trim();

        if (email.isEmpty || !GetUtils.isEmail(email)) {
          Get.snackbar('Error', 'Please enter a valid email address');
          return;
        }

        final response = await _authService.resendSignUpEmailOtp(email: email);

        if (response.success) {
          Get.snackbar(
            "OTP Sent",
            "Verification code sent to your email",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF172B75),
            colorText: Colors.white,
          );

          // Restart timer but DON'T navigate
          _initializeResendTimer();
        } else {
          Get.snackbar(
            "Error",
            response.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE74C3C),
            colorText: Colors.white,
          );
        }
      } else {
        // For phone OTP resend, use dedicated API instead of original methods
        final phone = phoneController.text.trim();

        if (phone.length == 10 && RegExp(r'^[0-9]+$').hasMatch(phone)) {
          final formattedPhone = '+91$phone';

          ApiResponse<Map<String, dynamic>> response;

          if (isSignInFlow.value) {
            // Use dedicated resend sign-in OTP API
            response = await _authService.resendSignInOtp(
              phoneNumber: formattedPhone,
            );
          } else {
            // Use dedicated resend sign-up OTP API (when available)
            // For now, use the original method
            await sendSignupPhoneOtp();
            return; // Exit early to avoid the navigation below
          }

          if (response.success) {
            Get.snackbar(
              "OTP Sent",
              "Verification code sent to your phone number",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFF172B75),
              colorText: Colors.white,
            );

            // Restart timer but DON'T navigate
            _initializeResendTimer();
          } else {
            Get.snackbar(
              "Error",
              response.message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFFE74C3C),
              colorText: Colors.white,
            );
          }
        } else {
          Get.snackbar(
            "Error",
            "Invalid phone number",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE74C3C),
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      if (!_isDisposed.value) {
        Get.snackbar('Error', 'Failed to resend OTP: ${e.toString()}');
      }
    }
  }

  void updateOtp(String value) {
    if (!_isDisposed.value) {
      otpCode.value = value;
    }
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
        profession: profession.value,
      );

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
        difficultyLevel: difficultyLevel.value,
      );

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
        communityAccess: communityAccess.value,
      );

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
        notificationsEnabled: notificationsEnabled.value,
      );

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
        notificationsEnabled: notificationsEnabled.value,
      );

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

  // Generate random nonce for Apple Sign In
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
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

  // Phone Sign-IN(for existing users)
  Future<void> sendSignupPhoneOtp() async {
    try {
      isLoading.value = true;
      final phone = phoneController.text.trim();

      if (phone.length == 10 && RegExp(r'^[0-9]+$').hasMatch(phone)) {
        // formate phone number with country code
        final formattedPhone = '+91$phone';
        userPhone.value = formattedPhone;
        isPhoneOtp.value = true;
        isSignInFlow.value = false;

        final response = await _authService.requestPhoneVerification(
          phoneNumber: formattedPhone,
        );

        if (response.success) {
          Get.snackbar(
            "OTP Sent ",
            "Verification code sent to your phone number",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF172B75),
            colorText: Colors.white,
          );

          // Start the resend Timer
          _initializeResendTimer();
          // FIXED: Navigate to OTP screen instead of calling goToNextPage()
          // which would redirect to subscription screen
          Get.toNamed(
            Routes.OTP_SCREEN,
            arguments: {
              'phone': formattedPhone,
              'isPhoneOtp': true,
              'isSignInFlow': false,
            },
          );
        } else {
          Get.snackbar(
            "Error",
            response.message ?? "Failed to send OTP",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFE74C3C),
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          "Error",
          "Invalid phone number",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE74C3C),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to send OTP: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // Send OTP to phone for SIGNIN
  Future<void> sendSigninPhoneOtp() async {
    try {
      isLoading.value = true;
      final phone = phoneController.text.trim();

      if (phone.length == 10 && RegExp(r'^[0-9]+$').hasMatch(phone)) {
        // Try multiple phone formats
        final phoneFormats = ['+91$phone', phone, '91$phone'];
        isPhoneOtp.value = true;
        isSignInFlow.value = true;

        // Debug: Check current user's phone number if logged in
        final currentUser = _authService.currentUser.value;
        if (currentUser != null) {
          print('🔍 Current user phone in storage: ${currentUser.mobile}');
          print('🔍 All user data: ${currentUser.toJson()}');
        } else {
          print('🔍 No current user found in storage');
        }

        ApiResponse<Map<String, dynamic>>? response;
        String? workingFormat;

        for (String format in phoneFormats) {
          print('🔍 Attempting sign-in with phone: $format');
          try {
            response = await _authService.signInWithPhone(phoneNumber: format);
            if (response.success) {
              workingFormat = format;
              userPhone.value = format;
              break;
            }
          } catch (e) {
            continue;
          }
        }

        response ??=
            await _authService.signInWithPhone(phoneNumber: phoneFormats.first);

        if (response != null && response.success) {
          print('✅ Sign-in successful with format: $workingFormat');
          Get.snackbar(
            "OTP Sent",
            "Verification code sent to your phone number",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF172B75),
            colorText: Colors.white,
          );

          // Start the resend Timer
          _initializeResendTimer();
          // Navigate to OTP screen
          Get.toNamed(
            Routes.OTP_SCREEN,
            arguments: {
              'phone': userPhone.value,
              'isPhoneOtp': true,
              'isSignInFlow': true,
            },
          );
        } else {
          String errorMsg = response.message ?? "Failed to send OTP";
          print('🔍 Sign-in error: $errorMsg');

          // Check if it's a user not found error
          if (errorMsg.toLowerCase().contains("not found") ||
              errorMsg.toLowerCase().contains("not registered") ||
              errorMsg.toLowerCase().contains("user not found") ||
              errorMsg.toLowerCase().contains("does not exist")) {
            Get.snackbar(
              "Phone Login Not Available",
              "This phone number was added to a Google/Email account. Please sign in with Google or Email instead.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFFE74C3C),
              colorText: Colors.white,
              duration: Duration(seconds: 4),
            );
          } else {
            Get.snackbar(
              "Error",
              errorMsg,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: const Color(0xFFE74C3C),
              colorText: Colors.white,
            );
          }
        }
      } else {
        Get.snackbar(
          "Error",
          "Please enter a valid 10-digit phone number",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE74C3C),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('🔍 Sign-in exception: $e');
      Get.snackbar("Error", "Failed to send OTP: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // Update the existing verifyOtp method to handle sign in
  Future<void> verifySignInOtp() async {
    try {
      isLoading.value = true;
      final otp = otpCode.value;

      if (otp.length != 5) {
        Get.snackbar('Error ', 'Please enter a valid 5-digit OTP');
        ;
        return;
      }
      final response = await _authService.verifyPhoneSignInOtp(
        phoneNumber: userPhone.value,
        otp: otp,
      );

      if (response.success) {
        print('🔍 Sign-in response data: ${response.data}');

        // Debug: Check what getUserProfile returns
        final currentUser = _authService.currentUser.value;
        print('🔍 Current user after getUserProfile: ${currentUser?.toJson()}');

        // Fetch user profile data after successful sign in
        // await _authService.getUserProfile();
        _loadUserData();

        // Mark first time as false since user is authenticated
        final storage = GetStorage();
        storage.write('isFirstTime', false);

        Get.offAllNamed(Routes.HOME);
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      Get.snackbar('Error ', 'Sign in failed : ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // formatter timer text
  String getFormatterTimer() {
    final minutes = resendTimer.value ~/ 60;
    final seconds = resendTimer.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    if (_isDisposed.value) return;
    _isDisposed.value = true;

    try {
      if (emailController.hasListeners) emailController.dispose();
      if (phoneController.hasListeners) phoneController.dispose();
      if (otpFieldController.hasListeners) otpFieldController.dispose();
      pageController.dispose();
    } catch (e) {
      print('Controller disposal error: $e');
    }
    super.onClose();
  }
}
