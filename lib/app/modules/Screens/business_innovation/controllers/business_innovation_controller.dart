import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/learn_service.dart';

class BusinessInnovationController extends GetxController {
  final LearnService _learnService = Get.find<LearnService>();

  // Observable variables
  final RxList<Map<String, dynamic>> topics = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  // Navigation arguments
  String? subCategoryId;
  String? subCategoryName;
  String? categoryId;
  String? categoryName;

  // Legacy categories for fallback (will be replaced by API data)
  final categories = [
    'STARTUP',
    'INVESTING',
    'FINANCE',
    'STOCKS',
    'TECH',
    'AI TOOLS',
    'HUSTLE',
  ].obs;

  @override
  void onInit() {
    super.onInit();

    // Get arguments from navigation
    final args = Get.arguments;
    if (args != null) {
      subCategoryId = args['subCategoryId']?.toString();
      subCategoryName = args['subCategoryName']?.toString();
      categoryId = args['categoryId']?.toString();
      categoryName = args['categoryName']?.toString();

      print('🚀 BusinessInnovation - SubCategory ID: $subCategoryId');
      print('🚀 BusinessInnovation - SubCategory Name: $subCategoryName');
    }

    // Load topics from API
    if (subCategoryId != null && categoryId != null) {
      loadTopicsFromAPI();
    }
  }

  // Load topics from API
  Future<void> loadTopicsFromAPI() async {
    try {
      isLoading.value = true;
      print('🚀 BusinessInnovation - Loading topics from API');

      final response =
          await _learnService.getTopics(categoryId!, subCategoryId!);

      if (response.success && response.data != null) {
        final items = response.data!['items'] as List<Map<String, dynamic>>;

        if (items.isNotEmpty) {
          topics.assignAll(items);

          // Update categories list with API data (for UI compatibility)
          final topicNames = items
              .map(
                  (topic) => topic['name']?.toString().toUpperCase() ?? 'TOPIC')
              .toList();
          categories.assignAll(topicNames);

          print('✅ BusinessInnovation - Topics loaded: ${topics.length}');
        } else {
          // Database is empty - show user-friendly message
          _showNoDataMessage();
          print('📭 BusinessInnovation - No topics available');
        }
      } else {
        print(
            '❌ BusinessInnovation - Failed to load topics: ${response.message}');
        _showNoDataMessage();
      }
    } catch (e) {
      print('❌ BusinessInnovation - Topics error: $e');
      Get.snackbar('Error', 'Failed to load topics: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Show user-friendly message when no data is available
  void _showNoDataMessage() {
    categories.assignAll(['Currently we have not this type of data']);

    Get.snackbar(
      'No Content Available',
      'We are working on adding more content for this category. Please check back later.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: Duration(seconds: 4),
    );
  }

  // Go back to the previous screen
  void goBack() {
    Get.back();
  }
}
