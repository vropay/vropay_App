import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/community_service.dart';

class PersonalGrowthCommunityController extends GetxController {
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
          '❌ PersonalGrowthCommunity - CommunityService not found, creating it');
      _communityService = Get.put(CommunityService(), permanent: true);
    }

    // Get category data from navigation arguments
    final args = Get.arguments;
    if (args != null) {
      categoryId = args['categoryId']?.toString();
      categoryName = args['categoryName']?.toString();
      mainCategoryId = args['mainCategoryId']?.toString();
      subCategoryId = args['subCategoryId']?.toString();

      print('🚀 PersonalGrowthCommunity - Category ID: $categoryId');
      print('🚀 PersonalGrowthCommunity - Category Name: $categoryName');
      print('🚀 PersonalGrowthCommunity - Main Category ID: $mainCategoryId');
      print('🚀 PersonalGrowthCommunity - Sub Category ID: $subCategoryId');
    }

    // Load topics from API
    loadTopicsFromAPI();
  }

  // Load topics from API
  Future<void> loadTopicsFromAPI() async {
    try {
      isLoading.value = true;
      print('🚀 PersonalGrowthCommunity - Loading topics from API');

      if (mainCategoryId == null || subCategoryId == null) {
        print(
            '❌ PersonalGrowthCommunity - Main category ID and subcategory ID are required');
        return;
      }

      // Call the topics endpoint directly
      final response =
          await _communityService.getTopics(mainCategoryId!, subCategoryId!);

      if (response.success && response.data != null) {
        final topics = response.data as List<Map<String, dynamic>>? ?? [];

        print('🔍 PersonalGrowthCommunity - Raw topics: ${topics.length}');

        if (topics.isNotEmpty) {
          this.topics.assignAll(topics);
          print(
              '✅ PersonalGrowthCommunity - Topics loaded: ${this.topics.length}');
        } else {
          print('📭 PersonalGrowthCommunity - No topics available');
        }
      } else {
        print(
            '❌ PersonalGrowthCommunity - Failed to load topics: ${response.message}');
      }
    } catch (e) {
      print('❌ PersonalGrowthCommunity - Topics error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Go back to the previous screen
  void goBack() {
    Get.back();
  }
}
