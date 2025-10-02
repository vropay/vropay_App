import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/community_service.dart';

class WorldAndCultureCommunityController extends GetxController {
  final isLoading = false.obs;
  final selectedCategory = ''.obs;
  final articles = <Map<String, dynamic>>[].obs;

  // API - loaded topics instead of static categories
  final topics = <Map<String, dynamic>>[].obs;

  // Community service for API calls
  late final CommunityService _communityService;

  // Category data from navigation
  String? categoryId;
  String? categoryName;

  @override
  void onInit() {
    super.onInit();

    // Initialize community service
    try {
      _communityService = Get.find<CommunityService>();
    } catch (e) {
      print(
          '❌ WorldAndCultureCommunity - CommunityService not found, creating it');
      _communityService = Get.put(CommunityService(), permanent: true);
    }

    // Get category data from navigation arguments
    final args = Get.arguments;
    if (args != null) {
      categoryId = args['categoryId']?.toString();
      categoryName = args['categoryName']?.toString();

      print('🚀 WorldAndCultureCommunity - Category ID: $categoryId');
      print('🚀 WorldAndCultureCommunity - Category Name: $categoryName');
    }

    loadTopicsFromAPI();
  }

  // Load topics from API
  Future<void> loadTopicsFromAPI() async {
    try {
      isLoading.value = true;
      print('🚀 WorldAndCultureCommunity - Loading topics from API');

      if (categoryId == null) {
        print('❌ WorldAndCultureCommunity - Category ID is required');
        return;
      }

      // Get the main category ID and subcategory ID from arguments
      final args = Get.arguments;
      final mainCategoryId = args?['mainCategoryId']?.toString();
      final subCategoryId = args?['subCategoryId']?.toString();

      if (mainCategoryId == null || subCategoryId == null) {
        print(
            '❌ WorldAndCultureCommunity - Main category ID and subcategory ID are required');
        return;
      }

      // Call the topics endpoint directly
      final response =
          await _communityService.getTopics(mainCategoryId, subCategoryId);

      if (response.success && response.data != null) {
        final topics = response.data as List<Map<String, dynamic>>? ?? [];

        print('🔍 WorldAndCultureCommunity - Raw topics: ${topics.length}');

        if (topics.isNotEmpty) {
          this.topics.assignAll(topics);
          print(
              '✅ WorldAndCultureCommunity - Topics loaded: ${this.topics.length}');
        } else {
          print('📭 WorldAndCultureCommunity - No topics available');
        }
      } else {
        print(
            '❌ WorldAndCultureCommunity - Failed to load topics: ${response.message}');
      }
    } catch (e) {
      print('❌ WorldAndCultureCommunity - Topics error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Go back to the previous screen
  void goBack() {
    Get.back();
  }
}
