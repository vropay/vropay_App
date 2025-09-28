import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/core/models/user_model.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';
// import 'package:vropay_final/app/core/services/user_service.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  // Keep reference only if needed elsewhere
  // final UserService _userService = Get.find<UserService>();

  // Text controllers
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController professionController = TextEditingController();

  // Observable variables
  var isLoading = false.obs;
  var user = Rxn<UserModel>();
  // Edit modes expected by view
  final RxBool isGeneralEditMode = false.obs;
  final RxBool isPreferencesEditMode = false.obs;
  var selectedGender = 'Male'.obs;
  // Backend list of topics and UI label for topics
  var selectedTopicsList = <String>[].obs;
  var selectedTopics = ''.obs;
  var difficultyLevel = 'Beginner'.obs;
  var communityAccess = 'Public'.obs;
  var notificationsEnabled = true.obs;
  var interests = <String>[].obs;
  var interestObjects = <Map<String, dynamic>>[].obs;
  var selectedInterests = <String>[].obs;

  // Options expected by view
  final List<String> genderOptions = [
    'Male',
    'Female',
    'Don\'t want to disclose'
  ];
  final List<String> categoryOptions = [
    'Business owner',
    'Student',
    'Working Professional',
  ];
  final List<String> topicsOptions = ['Selected', 'All', 'None'];
  final List<String> difficultyOptions = [
    'Beginner',
    'Intermediate',
    'Advance'
  ];
  final List<String> communityOptions = ['In', 'Out'];
  final List<String> notificationOptions = ['Allowed', 'Blocked'];

  // Selected values expected by view
  var selectedCategory = 'Business owner'.obs;
  var selectedDifficulty = 'Beginner'.obs;
  var selectedCommunity = 'In'.obs; // maps to communityAccess
  var selectedNotifications = 'Allowed'.obs; // maps to notificationsEnabled
  var selectedProfession = 'Business owner'.obs; // for profession dropdown

  @override
  void onInit() {
    super.onInit();
    print('🚀 ProfileController - onInit called');
    // First try to get current user from AuthService
    final currentUser = _authService.currentUser.value;
    if (currentUser != null) {
      print(
          '🔍 ProfileController - Found current user in AuthService: ${currentUser.firstName}');
      user.value = currentUser;
      _populateControllers(currentUser);
    }

    ever(selectedGender, (String g) {
      if (user.value != null) {
        user.update((u) {
          u?.gender = g;
        });
      }
    });

    // Force load fresh data from API
    loadUserData();
  }

  @override
  void onReady() {
    super.onReady();
    // Ensure data is loaded when view is ready
    if (user.value == null) {
      loadUserData();
    }
  }

  void _populateControllers(UserModel userData) {
    firstNameController.text = userData.firstName ?? '';
    lastNameController.text = userData.lastName ?? '';
    emailController.text = userData.email ?? '';
    mobileController.text = userData.mobile ?? '';
    professionController.text = userData.profession ?? '';
    selectedGender.value = userData.gender ?? 'Male';

    // Update profession/category selections
    selectedProfession.value = userData.profession ?? 'Business owner';
    selectedCategory.value = userData.profession ?? 'Business owner';

    print('🔍 ProfileController - Controllers populated:');
    print('  - FirstName: ${userData.firstName}');
    print('  - LastName: ${userData.lastName}');
    print('  - Email: ${userData.email}');
    print('  - Mobile: ${userData.mobile}');
    print('  - Gender: ${userData.gender}');
    print('  - Profession: ${userData.profession}');
  }

  // Load user data from backend
  Future<void> loadUserData() async {
    try {
      final response = await _authService.getInterests();

      if (response['interests'] is List) {
        final interestsList = response['interests'] as List;
        final interestName = <String>[];
        final interestObjs = <Map<String, dynamic>>[];

        for (final interest in interestsList) {
          if (interest is Map<String, dynamic> && interest['name'] != null) {
            interestName.add(interest['name'].toString());
            interestObjs.add(interest);
          }
        }

        interests.value = interestName;
        interestObjects.value = interestObjs;

        // Match user's selected interest ObjectIds with interest names
        final userInterestIds = user.value?.selectedTopics ?? [];
        final selectedNames = <String>[];

        for (final interestId in userInterestIds) {
          final matchingInterest = interestObjs.firstWhere(
            (obj) => obj['_id'] == interestId,
            orElse: () => <String, dynamic>{},
          );
          if (matchingInterest.isNotEmpty && matchingInterest['name'] != null) {
            selectedNames.add(matchingInterest['name'].toString());
          }
        }

        selectedInterests.value = selectedNames;
        selectedTopicsList.value = selectedNames;
        selectedTopics.value = selectedNames.join(', ');

        print('Interests loaded: ${interestName.length} items');
        print('User selected topics: $selectedNames');
      }
    } catch (e) {
      print("Error loading interests: $e");
    }
  }

  // Update user profile
  Future<void> updateProfile() async {
    try {
      isLoading.value = true;
      await _authService.updateUserProfile(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        mobile: mobileController.text,
        profession: professionController.text,
        gender: selectedGender.value,
        selectedTopics: selectedTopicsList.toList(),
        difficultyLevel: selectedDifficulty.value,
        communityAccess: selectedCommunity.value == 'In' ? 'Public' : 'Private',
        notificationsEnabled: selectedNotifications.value == 'Allowed',
      );

      // Refresh user data after successful update
      final response = await _authService.getUserProfile();
      final updatedUser = response.data;
      if (updatedUser != null) {
        user.value = updatedUser;
        // Update text controllers with fresh data
        firstNameController.text = updatedUser.firstName ?? '';
        lastNameController.text = updatedUser.lastName ?? '';
        emailController.text = updatedUser.email;
        mobileController.text = updatedUser.mobile ?? '';
        professionController.text = updatedUser.profession ?? '';
        selectedGender.value = updatedUser.gender ?? 'Male';
      }

      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load interest
  Future<void> loadInterests() async {
    try {
      final response = await _authService.getInterests();

      if (response['interests'] is List) {
        final interestsList = response['interests'] as List;
        final interestName = <String>[];
        final interestObjs = <Map<String, dynamic>>[];

        for (final interest in interestsList) {
          if (interest is Map<String, dynamic> && interest['name'] != null) {
            interestName.add(interest['name'].toString());
            interestObjs.add(interest);
          }
        }

        interests.value = interestName;
        interestObjects.value = interestObjs;

        // only set selected interests if it's empty
        if (selectedInterests.isEmpty) {
          selectedInterests.value = selectedTopicsList.toList();
        }

        print('Interests loaded: ${interestName.length} items');
        print('User selected topics: ${selectedTopicsList.toList()}');
      }
    } catch (e) {
      print("Error loading interests: $e");
    }
  }

  // show interest dialog
  void showInterestsSelection() {
    loadInterests();
  }

  // Toggle interest selection
  void toggleInterest(String interestName) {
    if (selectedInterests.contains(interestName)) {
      selectedInterests.remove(interestName);
    } else {
      selectedInterests.add(interestName);
    }
  }

  // save selected interests
  Future<void> saveSelectedInterests() async {
    try {
      // Get object IDs for selected interests
      final selectedIds = <String>[];
      for (final selectedName in selectedInterests) {
        final interestObj = interestObjects.firstWhere(
          (obj) => obj['name'] == selectedName,
          orElse: () => <String, dynamic>{},
        );
        if (interestObj.isNotEmpty && interestObj['_id'] != null) {
          selectedIds.add(interestObj['_id'].toString());
        }
      }
      await _authService.saveSelectedInterests(interestIds: selectedIds);

      // Force immediate UI update
      selectedTopicsList.value = selectedInterests.toList();
      selectedTopics.value = selectedInterests.join(', ');

      // Trigger UI refresh
      selectedTopicsList.refresh();
      selectedTopics.refresh();
    } catch (e) {
      print('Error saving interests: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.logout();
      Get.offAllNamed(Routes.ON_BOARDING);
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: $e');
    }
  }

  // Update gender
  void updateGender(String gender) {
    print('🔄 Updating gender to: $gender');
    selectedGender.value = gender;
    if (user.value != null) {
      user.update((u) {
        u?.gender = gender;
      });
    }
    print('✅ Gender updated to: ${selectedGender.value}');
  }

  // Update topics
  void updateTopics(List<String> topics) {
    selectedTopicsList.value = topics;
    selectedTopics.value = topics.join(', ');
  }

  // Update difficulty level
  void updateDifficultyLevel(String level) {
    difficultyLevel.value = level;
    selectedDifficulty.value = level;
  }

  // Update community access
  void updateCommunityAccess(String access) {
    communityAccess.value = access == 'In' ? 'Public' : 'Private';
    selectedCommunity.value = access;
  }

  // Update notifications
  void updateNotifications(bool enabled) {
    notificationsEnabled.value = enabled;
    selectedNotifications.value = enabled ? 'Allowed' : 'Blocked';
  }

  // Update profession
  void updateProfession(String profession) {
    selectedProfession.value = profession;
    selectedCategory.value = profession;
    professionController.text = profession;
  }

  // Expected by view edit buttons
  Future<void> saveGeneralProfile() async {
    try {
      isLoading.value = true;
      print('🚀 ProfileController - Saving general profile data...');

      // Validate required fields
      if (firstNameController.text.trim().isEmpty) {
        Get.snackbar('Error', 'First name is required');
        return;
      }

      if (lastNameController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Last name is required');
        return;
      }

      // Check if email has changed
      final newEmail = emailController.text.trim();
      final currentEmail = user.value?.email ?? '';

      if (newEmail != currentEmail && newEmail.isNotEmpty) {
        // Email changed - send OTP for verification
        print(
            '📧 Email changed from $currentEmail to $newEmail - sending OTP...');

        try {
          // Try to send OTP to new email using signup endpoint
          await _authService.signUpWithEmail(
              email: newEmail,
              name: '${firstNameController.text} ${lastNameController.text}');

          // Navigate to OTP screen with email change context
          Get.toNamed('/otp-screen', arguments: {
            'email': newEmail,
            'isEmailChange': true,
            'profileData': {
              'firstName': firstNameController.text.trim(),
              'lastName': lastNameController.text.trim(),
              'mobile': mobileController.text.trim(),
              'profession': selectedCategory.value,
              'gender': selectedGender.value,
            }
          });
          return;
        } catch (e) {
          // If email already exists, still proceed to OTP (for email change)
          if (e.toString().contains('already registered') ||
              e.toString().contains('Email already')) {
            Get.snackbar('Info', 'Sending OTP to verify email change...',
                backgroundColor: Colors.blue.withOpacity(0.8),
                colorText: Colors.white);

            // Navigate to OTP screen anyway for email change verification
            Get.toNamed('/otp-screen', arguments: {
              'email': newEmail,
              'isEmailChange': true,
              'profileData': {
                'firstName': firstNameController.text.trim(),
                'lastName': lastNameController.text.trim(),
                'mobile': mobileController.text.trim(),
                'profession': selectedCategory.value,
                'gender': selectedGender.value,
              }
            });
            return;
          }

          Get.snackbar('Error', 'Failed to send OTP: ${e.toString()}',
              backgroundColor: Colors.red.withOpacity(0.8),
              colorText: Colors.white);
          return;
        }
      }

      // No email change - proceed with normal profile update
      await _updateProfileData();
    } catch (e) {
      print('❌ ProfileController - Error saving general profile: $e');
      Get.snackbar('Error', 'Failed to update profile: ${e.toString()}',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to update profile data
  Future<void> _updateProfileData() async {
    // Update local user data immediately for instant UI update
    final currentUser = user.value;
    if (currentUser != null) {
      user.value = UserModel(
        id: currentUser.id,
        email: currentUser.email,
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        mobile: mobileController.text.trim(),
        profession: selectedCategory.value,
        gender: selectedGender.value,
        profileImage: currentUser.profileImage,
        selectedTopics: currentUser.selectedTopics,
        difficultyLevel: currentUser.difficultyLevel,
        communityAccess: currentUser.communityAccess,
        notificationsEnabled: currentUser.notificationsEnabled,
        isOnboardingCompleted: currentUser.isOnboardingCompleted,
        createdAt: currentUser.createdAt,
        updatedAt: currentUser.updatedAt,
      );
      user.refresh(); // Force UI update
    }

    // Update profile with current form data in background
    await _authService.updateUserProfile(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      mobile: mobileController.text.trim(),
      profession: selectedCategory.value,
      gender: selectedGender.value,
    );

    Get.snackbar('Success', 'Profile updated successfully',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white);

    // Force complete screen refresh to prevent null errors
    isLoading.value = true;
    await Future.delayed(Duration(milliseconds: 100));
    await loadUserData();
    isLoading.value = false;

    print('✅ ProfileController - General profile saved successfully');
  }

  // Method to handle email change after OTP verification
  Future<void> updateEmailAfterVerification(
      String newEmail, Map<String, dynamic> profileData) async {
    try {
      isLoading.value = true;

      // Update profile with new email and other data
      await _authService.updateUserProfile(
        firstName: profileData['firstName'],
        lastName: profileData['lastName'],
        mobile: profileData['mobile'],
        profession: profileData['profession'],
        gender: profileData['gender'],
      );

      // Update local user data with new email
      final currentUser = user.value;
      if (currentUser != null) {
        user.value = UserModel(
          id: currentUser.id,
          email: newEmail,
          firstName: profileData['firstName'],
          lastName: profileData['lastName'],
          mobile: profileData['mobile'],
          profession: profileData['profession'],
          gender: profileData['gender'],
          profileImage: currentUser.profileImage,
          selectedTopics: currentUser.selectedTopics,
          difficultyLevel: currentUser.difficultyLevel,
          communityAccess: currentUser.communityAccess,
          notificationsEnabled: currentUser.notificationsEnabled,
          isOnboardingCompleted: currentUser.isOnboardingCompleted,
          createdAt: currentUser.createdAt,
          updatedAt: currentUser.updatedAt,
        );
        user.refresh();
      }

      // Update controllers
      emailController.text = newEmail;
      firstNameController.text = profileData['firstName'];
      lastNameController.text = profileData['lastName'];
      mobileController.text = profileData['mobile'];
      selectedGender.value = profileData['gender'];
      selectedCategory.value = profileData['profession'];

      Get.snackbar('Success', 'Email and profile updated successfully',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update email: ${e.toString()}',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> savePreferences() async {
    try {
      isLoading.value = true;
      print('🚀 ProfileController - Saving preferences...');

      // Force database save - no local fallback
      await _authService.updateUserPreferences(
        difficultyLevel: selectedDifficulty.value,
        communityAccess: selectedCommunity.value == 'In' ? 'Public' : 'Private',
        notificationsEnabled: selectedNotifications.value == 'Allowed',
      );

      // Reload fresh data from database
      await loadUserData();

      Get.snackbar('Success', 'Preferences updated successfully',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white);

      print('✅ ProfileController - Preferences saved successfully');
    } catch (e) {
      print('❌ ProfileController - Error saving preferences: $e');
      Get.snackbar('Error', 'Failed to update preferences: ${e.toString()}',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void toggleEditMode() {
    isGeneralEditMode.value = !isGeneralEditMode.value;
  }

  // Test method to directly call profile API
  Future<void> testProfileAPI() async {
    try {
      print('🧪 Testing profile API directly...');
      print('🔗 API URL: http://localhost:3000/api/profile');

      final response = await _authService.getUserProfile();
      print('✅ Profile API test successful!');
      print('📦 Response data: ${response.data?.toJson()}');
    } catch (e) {
      print('❌ Profile API test failed: $e');
    }
  }
}
