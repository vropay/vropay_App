import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/community_service.dart';

class BusinessInnovationCommunityController extends GetxController {
  final isLoading = false.obs;
  final selectedCategory = ''.obs;
  final articles = <Map<String, dynamic>>[].obs;

  // API-loaded topics instead of static categories
  final topics = <Map<String, dynamic>>[].obs;

  // Community service for API calls
  late final CommunityService _communityService;

  // Category data from navigation
  String? categoryId;
  String? categoryName;
  String? mainCategoryId;
  String? subCategoryId;

  @override
  void onInit() {
    super.onInit();

    // Initialize CommunityService
    try {
      _communityService = Get.find<CommunityService>();
    } catch (e) {
      print(
          '❌ BusinessInnovationCommunity - CommunityService not found, creating it');
      _communityService = Get.put(CommunityService(), permanent: true);
    }

    // Get category data from navigation arguments
    final args = Get.arguments;
    if (args != null) {
      categoryId = args['categoryId']?.toString();
      categoryName = args['categoryName']?.toString();
      mainCategoryId = args['mainCategoryId']?.toString();
      subCategoryId = args['subCategoryId']?.toString();

      print('🚀 BusinessInnovationCommunity - Category ID: $categoryId');
      print('🚀 BusinessInnovationCommunity - Category Name: $categoryName');
      print(
          '🚀 BusinessInnovationCommunity - Main Category ID: $mainCategoryId');
      print('🚀 BusinessInnovationCommunity - Sub Category ID: $subCategoryId');
    }

    // Load topics from API
    loadTopicsFromAPI();
  }

  // Load topics from API
  Future<void> loadTopicsFromAPI() async {
    try {
      isLoading.value = true;
      print('🚀 BusinessInnovationCommunity - Loading topics from API');

      if (mainCategoryId == null || subCategoryId == null) {
        print(
            '❌ BusinessInnovationCommunity - Main category ID and subcategory ID are required');
        return;
      }

      // Call the topics endpoint directly
      final response =
          await _communityService.getTopics(mainCategoryId!, subCategoryId!);

      if (response.success && response.data != null) {
        final topics = response.data as List<Map<String, dynamic>>? ?? [];

        print('🔍 BusinessInnovationCommunity - Raw topics: ${topics.length}');

        if (topics.isNotEmpty) {
          this.topics.assignAll(topics);
          print(
              '✅ BusinessInnovationCommunity - Topics loaded: ${this.topics.length}');
        } else {
          print('📭 BusinessInnovationCommunity - No topics available');
        }
      } else {
        print(
            '❌ BusinessInnovationCommunity - Failed to load topics: ${response.message}');
      }
    } catch (e) {
      print('❌ BusinessInnovationCommunity - Topics error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Go back to the previous screen
  void goBack() {
    Get.back();
  }
}
