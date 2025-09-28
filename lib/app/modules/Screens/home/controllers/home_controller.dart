import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:vropay_final/app/core/models/user_model.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';
import 'package:vropay_final/app/core/services/forum_service.dart';
import 'package:vropay_final/app/core/services/knowledge_service.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final KnowledgeService _knowledgeService = Get.find<KnowledgeService>();
  final ForumService _forumService = Get.find<ForumService>();

  // Observable variables
  var isLoading = false.obs;
  var user = Rxn<UserModel>();
  var featuredTopics = <Map<String, dynamic>>[].obs;
  var recentTopics = <Map<String, dynamic>>[].obs;
  var communityPosts = <Map<String, dynamic>>[].obs;
  var selectedTopics = <String>[].obs;
  var difficultyLevel = 'Beginner'.obs;
  var communityAccess = 'Public'.obs;
  var notificationsEnabled = true.obs;
  var currentIndex = 0.obs;
  var showUserDetailsForm = false.obs;
  var currentStep = 0
      .obs; // 0: userDetails, 1: interests, 2: difficulty, 3: community, 4: notifications, 5: subscription

  // Fields required by onboarding widgets
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  var selectedRole = ''.obs; // profession
  var selectedLevel = ''.obs; // used by widgets for gender/difficulty selection
  var selectedCommunityAccess =
      ''.obs; // UI label (Join & Interact / Just Scroll)
  var interests = <String>[].obs; // list of selectable interests
  var interestObjects =
      <Map<String, dynamic>>[].obs; // full interest objects with IDs

  var selectedInterests = <String>[].obs; // selected interests for UI

  @override
  void onInit() {
    super.onInit();

    // Check if user needs to fill details
    final args = Get.arguments as Map<String, dynamic>?;
    if (args?['showUserDetails'] == true) {
      showUserDetailsForm.value = true;
    }

    loadUserData();
    loadFeaturedTopics();
    loadRecentTopics();
    loadCommunityPosts();
    _hydrateInterests();
  }

  // Toggle interest selection for profile/interests dialog
  void toggleInterest(String topic) {
    if (selectedInterests.contains(topic)) {
      selectedInterests.remove(topic);
    } else {
      selectedInterests.add(topic);
    }
  }

  // Load user data from backend
  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final response = await _authService.getUserProfile();
      final userData = response.data;
      if (userData != null) {
        user.value = userData;
        selectedTopics.value = userData.selectedTopics ?? [];
        difficultyLevel.value = userData.difficultyLevel ?? 'Beginner';
        communityAccess.value = userData.communityAccess ?? 'Public';
        notificationsEnabled.value = userData.notificationsEnabled ?? true;
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load featured topics from backend
  Future<void> loadFeaturedTopics() async {
    try {
      final topics = await _knowledgeService.getFeaturedTopics();
      featuredTopics.value = topics;
    } catch (e) {
      print('Error loading featured topics: $e');
    }
  }

  // Load recent topics from backend
  Future<void> loadRecentTopics() async {
    try {
      final topics = await _knowledgeService.getRecentTopics();
      recentTopics.value = topics;
    } catch (e) {
      print('Error loading recent topics: $e');
    }
  }

  // Load community posts from backend
  Future<void> loadCommunityPosts() async {
    try {
      final posts = await _forumService.getCommunityPosts();
      communityPosts.value = posts;
    } catch (e) {
      print('Error loading community posts: $e');
    }
  }

  // Update user preferences
  Future<void> updateUserPreferences() async {
    try {
      isLoading.value = true;
      await _authService.updateUserPreferences(
        selectedTopics: selectedTopics.toList(),
        difficultyLevel: difficultyLevel.value,
        communityAccess: communityAccess.value,
        notificationsEnabled: notificationsEnabled.value,
      );
      Get.snackbar('Success', 'Preferences updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update preferences: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to topic details
  void navigateToTopic(String topicId) {
    Get.toNamed(Routes.KNOWLEDGE_CENTER_SCREEN,
        arguments: {'topicId': topicId});
  }

  // Navigate to community post
  void navigateToCommunityPost(String postId) {
    Get.toNamed(Routes.COMMUNITY_FORUM, arguments: {'postId': postId});
  }

  // Refresh all data
  Future<void> refreshData() async {
    await Future.wait([
      loadUserData(),
      loadFeaturedTopics(),
      loadRecentTopics(),
      loadCommunityPosts(),
    ]);
  }

  // ---------------- Onboarding widget helpers ----------------
  void selectLevel(String level) {
    selectedLevel.value = level;
    // If this reflects difficulty selection, map to difficultyLevel
    if (level == 'Beginner' || level == 'Moderate' || level == 'Advance') {
      difficultyLevel.value = level;
    }
    // If this reflects gender selection, update the user's gender
    if (level == 'Female' ||
        level == 'Male' ||
        level == 'Prefer not to disclose' ||
        level.contains("don't want")) {
      // Update the current user's gender in the user object
      if (user.value != null) {
        user.value!.gender = level;
      }
    }
  }

  bool isUserDetailValid() {
    return firstNameController.text.trim().isNotEmpty &&
        lastNameController.text.trim().isNotEmpty &&
        selectedRole.value.trim().isNotEmpty;
  }

  Future<void> updateUserProfile() async {
    try {
      isLoading.value = true;
      // Use selectedLevel as gender if it matches gender labels; fallback to Male
      final String gender = (selectedLevel.value == 'Male' ||
              selectedLevel.value == 'Female' ||
              selectedLevel.value == 'Prefer not to disclose' ||
              selectedLevel.value.contains("don't want"))
          ? selectedLevel.value
          : 'Male';

      print('🔍 updateUserProfile - selectedLevel: ${selectedLevel.value}');
      print('🔍 updateUserProfile - final gender: $gender');

      await _authService.updateUserProfile(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        gender: gender,
        profession: selectedRole.value.trim(),
        mobile: null,
        selectedTopics: selectedTopics.toList(),
        difficultyLevel: difficultyLevel.value,
        communityAccess: communityAccess.value,
        notificationsEnabled: notificationsEnabled.value,
      );

      Get.snackbar('Success', 'Profile updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateCommunityAccess(String option) {
    selectedCommunityAccess.value = option;
    communityAccess.value = option.contains('Join') ? 'Public' : 'Private';
  }

  void _hydrateInterests() async {
    await loadInterests();
  }

  Future<void> loadInterests() async {
    try {
      final response = await _authService.getInterests();

      if (response['interests'] is List) {
        final interestsList = response['interests'] as List;
        final interestNames = <String>[];
        final interestObjs = <Map<String, dynamic>>[];

        for (final interest in interestsList) {
          if (interest is Map<String, dynamic> && interest['name'] != null) {
            interestNames.add(interest['name'].toString());
            interestObjs.add(interest);
          }
        }

        interests.value = interestNames;
        interestObjects.value = interestObjs;
        print('Interests loaded: ${interestNames.length} items');
      }
    } catch (e) {
      print("Error loading interests: $e");
    }
  }

  bool hasSelectedInterests() => selectedInterests.isNotEmpty;

  // Save selected interests to backend
  Future<void> saveSelectedInterests() async {
    try {
      isLoading.value = true;

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

      print('Selected interest IDs: $selectedIds');

      await _authService.saveSelectedInterests(
        interestIds: selectedIds,
      );
      Get.snackbar('Success', 'Interests saved successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to save interests: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Save selected difficulty to backend
  Future<void> saveSelectedDifficulty() async {
    try {
      isLoading.value = true;
      await _authService.saveDifficultyLevel(
          difficultyLevel: difficultyLevel.value);
      print("Done");
    } catch (e) {
      print('Error in diffculty save from home controller: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool hasSelectedDifficulty() => difficultyLevel.value.isNotEmpty;

  // Save selected community access to backend
  Future<void> saveSelectedCommunityAccess() async {
    try {
      isLoading.value = true;

      String accessType =
          selectedCommunityAccess.value.toLowerCase().contains('join')
              ? 'In'
              : 'Out';

      await _authService.saveCommunityAccess(accessType: accessType);
    } catch (e) {
      print('Error in community access save from home controller: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool hasSelectedCommunityAccess() => selectedCommunityAccess.value.isNotEmpty;

  // Save selected notification preference to backend
  Future<void> saveNotificationPreference() async {
    try {
      isLoading.value = true;
      String notificationStatus =
          notificationsEnabled.value ? 'Allowed' : 'Not allowed';

      await _authService.saveNotificationPreference(
          notificationStatus: notificationStatus);
    } catch (e) {
      Get.snackbar('error', 'Failed to save $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool hasSelectedNotificationPreference() => true;

  // Navigate to next step in onboarding flow
  void nextStep() async {
    if (currentStep.value < 5) {
      // Save user details when moving from user details screen (step 0)
      if (currentStep.value == 0) {
        print('🔍 Step 0 - Selected gender: ${selectedLevel.value}');
        // Update user profile with current form data including gender
        await updateUserProfile();
      }

      // Save interests when moving from interests screen (step 1)
      if (currentStep.value == 1 && hasSelectedInterests()) {
        await saveSelectedInterests();
      }

      // Save difficulty when moving from difficulty screen
      if (currentStep.value == 2 && hasSelectedInterests()) {
        await saveSelectedDifficulty();
      }

      // Save community access when moving from community screen
      if (currentStep.value == 3 && hasSelectedCommunityAccess()) {
        await saveSelectedCommunityAccess();
      }

      // Save notification preference when moving from notification screen
      if (currentStep.value == 4) {
        await saveNotificationPreference();
        // Navigate to subscription screen after notifications
        Get.offAllNamed(Routes.SUBSCRIPTION, arguments: {'isOnboarding': true});
        return;
      }

      currentStep.value++;
      if (currentStep.value == 1) {
        loadInterests();
      }
    } else {
      // Final step - send all data to backend and go to dashboard
      completeOnboarding();
    }
  }

  // Complete onboarding and send all data to backend
  Future<void> completeOnboarding() async {
    await updateUserProfile();
    Get.offAllNamed(Routes.DASHBOARD);
  }

  @override
  void onClose() {
    if (!Get.isRegistered<HomeController>()) {
      firstNameController.dispose();
      lastNameController.dispose();
    }
    super.onClose();
  }
}
