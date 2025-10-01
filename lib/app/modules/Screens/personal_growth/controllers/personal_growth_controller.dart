import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/learn_service.dart';

class PersonalGrowthController extends GetxController {
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
    'ENTREPRENEURSHIP',
    'VISIONARIES',
    'LAW',
    'BOOKS',
    'VOCAB',
    'HEALTH',
    'SPIRITUALITY',
    'QUANTUMLEAP',
    'GEETA GYAN',
    'VEDIC WISE'
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

      print('🚀 PersonalGrowth - SubCategory ID: $subCategoryId');
      print('🚀 PersonalGrowth - SubCategory Name: $subCategoryName');
      print('🚀 PersonalGrowth - Category ID: $categoryId');
      print('🚀 PersonalGrowth - Category Name: $categoryName');
    }

    // Load topics from API
    if (subCategoryId != null && categoryId != null) {
      loadTopicsFromAPI();
    } else if ((categoryName != null && categoryName!.isNotEmpty) &&
        (subCategoryName != null && subCategoryName!.isNotEmpty)) {
      // Resolve IDs from provided names then load topics
      _resolveIdsFromNames();
    }
  }

  // Load topics from API
  Future<void> loadTopicsFromAPI() async {
    try {
      isLoading.value = true;
      print('🚀 PersonalGrowth - Loading topics from API');

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

          print('✅ PersonalGrowth - Topics loaded: ${topics.length}');
        } else {
          // Database is empty - show user-friendly message
          _showNoDataMessage();
          print('📭 PersonalGrowth - No topics available');
        }
      } else {
        print('❌ PersonalGrowth - Failed to load topics: ${response.message}');
        _showNoDataMessage();
      }
    } catch (e) {
      print('❌ PersonalGrowth - Topics error: $e');
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

  // Resolve categoryId and subCategoryId from provided names
  Future<void> _resolveIdsFromNames() async {
    try {
      isLoading.value = true;
      final providedCategoryName = _normalizeName(categoryName ?? '');
      final providedSubCategoryName = _normalizeName(subCategoryName ?? '');

      // 1) Find main category by name
      final mainResp = await _learnService.getMainCategories();
      if (!mainResp.success || mainResp.data == null) {
        _showNoDataMessage();
        return;
      }

      final List<Map<String, dynamic>> mains =
          (mainResp.data!['items'] as List<Map<String, dynamic>>? ??
              <Map<String, dynamic>>[]);

      final main = mains.firstWhere(
        (m) =>
            _normalizeName(m['name']?.toString() ?? '') == providedCategoryName,
        orElse: () => <String, dynamic>{},
      );

      if (main.isEmpty || main['_id'] == null) {
        _showNoDataMessage();
        return;
      }

      categoryId = main['_id'].toString();

      // 2) Find subcategory by name
      final subResp = await _learnService.getSubCategories(categoryId!);
      if (!subResp.success || subResp.data == null) {
        _showNoDataMessage();
        return;
      }

      final List<Map<String, dynamic>> subs =
          (subResp.data!['items'] as List<Map<String, dynamic>>? ??
              <Map<String, dynamic>>[]);

      final sub = subs.firstWhere(
        (s) =>
            _normalizeName(s['name']?.toString() ?? '') ==
            providedSubCategoryName,
        orElse: () => <String, dynamic>{},
      );

      if (sub.isEmpty || sub['_id'] == null) {
        _showNoDataMessage();
        return;
      }

      subCategoryId = sub['_id'].toString();

      // 3) Load topics now that IDs are known
      await loadTopicsFromAPI();
    } catch (e) {
      print('❌ PersonalGrowth - Resolve IDs error: $e');
      _showNoDataMessage();
    } finally {
      isLoading.value = false;
    }
  }

  String _normalizeName(String raw) {
    final lower = raw.toLowerCase().trim();
    return lower
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}
