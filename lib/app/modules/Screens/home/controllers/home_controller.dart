import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';
import 'package:vropay_final/app/core/services/forum_service.dart';
import 'package:vropay_final/app/core/services/knowledge_service.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class HomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final KnowledgeService _knowledgeService = Get.find<KnowledgeService>();
  final ForumService _forumService = Get.find<ForumService>();

  // Observable variables
  final RxList<dynamic> featuredTopics = <dynamic>[].obs;
  final RxList<dynamic> recentContents = <dynamic>[].obs;
  final RxList<dynamic> forumCategories = <dynamic>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  // Load all home data
  Future<void> loadHomeData() async {
    try {
      isLoading.value = true;

      // load multipple data sources in parallel
      await Future.wait([
        loadFeaturedTopics(),
        loadRecentContents(),
        loadForumCategories(),
      ]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load home data: ${e.toString()}');
      print('❌ Load home data error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load featured topics
  Future<void> loadFeaturedTopics() async {
    try {
      final response = await _knowledgeService.getKnowledgeCenter();

      if (response.success && response.data != null) {
        featuredTopics.value = response.data!['topics']?.take(3).toList() ?? [];
        print('✅ Loaded ${featuredTopics.length} featured topics');
      }
    } catch (e) {
      print('❌ Load featured topics error: $e');
    }
  }

// Load recent contents
  Future<void> loadRecentContents() async {
    try {
      recentContents.value = [];
      print(' Loading recent contents');
    } catch (e) {
      print('❌ Load recent contents error: $e');
    }
  }

  // Load forum categories
  Future<void> loadForumCategories() async {
    try {
      final response = await _forumService.getForumCategories();

      if (response.success && response.data != null) {
        forumCategories.value =
            response.data!['categories']?.take(3).toList() ?? [];
        print('✅ Loaded ${forumCategories.length} forum categories');
      }
    } catch (e) {
      print('❌ Load forum categories error: $e');
    }
  }

  // Navigate to knowledge center
  void navigateToKnowledgeCenter() {
    Get.toNamed(Routes.KNOWLEDGE_CENTER_SCREEN);
  }

  // Navigate to community forum
  void navigateToCommunityForum() {
    Get.toNamed(Routes.COMMUNITY_FORUM);
  }

  // Navigate to profile
  void navigateToProfile() {
    Get.toNamed(Routes.PROFILE);
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadHomeData();
  }
}
