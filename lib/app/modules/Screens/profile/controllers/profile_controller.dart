import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';
import 'package:vropay_final/app/core/services/user_service.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = Get.find<UserService>();

  // Form Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Observable Variables
  final RxString selectedGender = ''.obs;
  final RxString selectedProfession = ''.obs;
  final RxList<String> selectedTopics = <String>[].obs;
  final RxString selectedDifficultyLevel = ''.obs;
  final RxString selectedCommunityAccess = ''.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxBool isLoading = false.obs;

  // Options Lists
  final List<String> genderOptions = ['male', 'female', 'other'];
  final List<String> professionOptions = [
    'student',
    'working Professional',
    'business owner',
    'freelancer',
    'retired'
  ];

  final List<String> topicOptions = [
    'technology',
    'startups',
    'books',
    'podcast',
    'finance',
    'health',
    'travel',
    'food'
  ];

  final List<String> difficultyLevels = [
    'beginner',
    'intermediate',
    'advanced'
  ];
  final List<String> communityAccessOptions = [
    'read_only',
    'join_interact',
    'moderate'
  ];

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _authService.currentUser.value;
    if (user != null) {
      firstNameController.text = user.firstName ?? '';
      lastNameController.text = user.lastName ?? '';
      mobileController.text = user.mobile ?? '';
      selectedGender.value = user.gender ?? '';
      selectedProfession.value = user.profession ?? '';
      selectedTopics.value = user.selectedTopics ?? [];
      selectedDifficultyLevel.value = user.difficultyLevel ?? '';
      selectedCommunityAccess.value = user.communityAccess ?? '';
      notificationsEnabled.value = user.notificationsEnabled ?? true;
    }
  }

  // Update user profile
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;

      if (firstNameController.text.trim().isEmpty ||
          lastNameController.text.trim().isEmpty ||
          selectedGender.value.isEmpty ||
          selectedProfession.value.isEmpty) {
        Get.snackbar('Error', 'Please fill all required fields');
        return;
      }

      final response = await _authService.updateUserProfile(
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          gender: selectedGender.value,
          profession: selectedProfession.value,
          mobile: mobileController.text.trim().isNotEmpty
              ? mobileController.text.trim()
              : null,
          selectedTopics: selectedTopics.isNotEmpty ? selectedTopics : null,
          difficultyLevel: selectedDifficultyLevel.value.isNotEmpty
              ? selectedDifficultyLevel.value
              : null,
          communityAccess: selectedCommunityAccess.value.isNotEmpty
              ? selectedCommunityAccess.value
              : null,
          notificationsEnabled: notificationsEnabled.value);

      if (response.success) {
        Get.snackbar('Success', 'Profile updated successfully!');
        Get.back();
      } else {
        Get.snackbar('Error', response.message ?? 'Failed to update profile');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: ${e.toString()}');
      print('❌ Update profile error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update user preferences
  Future<void> updatePreferences() async {
    try {
      isLoading.value = true;

      final response = await _authService.updateUserPreferences(
        selectedTopics: selectedTopics.isNotEmpty ? selectedTopics : null,
        difficultyLevel: selectedDifficultyLevel.value.isNotEmpty
            ? selectedDifficultyLevel.value
            : null,
        communityAccess: selectedCommunityAccess.value.isNotEmpty
            ? selectedCommunityAccess.value
            : null,
        notificationsEnalbled: notificationsEnabled.value,
      );

      if (response.success) {
        Get.snackbar('Success', 'Preferences updated successfully!');
      } else {
        Get.snackbar(
            'Error', response.message ?? 'Failed to update preferences');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update preferences: ${e.toString()}');
      print('❌ Update preferences error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle topic selection
  void toggleTopic(String topic) {
    if (selectedTopics.contains(topic)) {
      selectedTopics.remove(topic);
    } else {
      selectedTopics.add(topic);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      Get.offAllNamed(Routes.SIGN_UP);
      Get.snackbar('Success', 'Logged out successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to logout: ${e.toString()}');
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    mobileController.dispose();
    super.onClose();
  }
}
