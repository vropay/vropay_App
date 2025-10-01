import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/core/api/api_constant.dart';
import 'package:vropay_final/app/core/services/learn_service.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class LearnScreenController extends GetxController {
  final LearnService _learn = Get.find<LearnService>();

  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> mainCategories =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> subCategories =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> topics = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> entries = <Map<String, dynamic>>[].obs;

  // Current selection tracking
  final RxString selectedMainCategoryId = ''.obs;
  final RxString selectedSubCategoryId = ''.obs;
  final RxString selectedTopicId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('🚀 LearnScreenController - Initializing...');

    loadMainCategories();
  }

  Future<void> loadMainCategories() async {
    try {
      isLoading.value = true;
      print('🚀 LearnScreenController - Loading main categories...');

      final resp = await _learn.getMainCategories();
      print('✅ LearnScreenController - Response received: ${resp.success}');
      print('📊 LearnScreenController - Response data: ${resp.data}');

      if (resp.success && resp.data != null) {
        final items = (resp.data!['items'] as List<Map<String, dynamic>>);
        print('📋 LearnScreenController - Items count: ${items.length}');

        mainCategories.assignAll(items);
        print('✅ LearnScreenController - Categories loaded successfully');
      } else {
        print(
            '❌ LearnScreenController - Response not successful: ${resp.message}');
        Get.snackbar('Error', 'Failed to load categories: ${resp.message}');
      }
    } catch (e) {
      print('❌ LearnScreenController - Exception: $e');

      Get.snackbar('Error', 'Failed to load categories: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // NEW METHOD: Navigate to appropriate screen based on category
  void onCategoryTap(Map<String, dynamic> category) {
    final categoryId = category['_id']?.toString();
    final categoryName = category['name']?.toString().toLowerCase() ?? '';

    print(
        '🚀 LearnScreenController - Category tapped: $categoryName (ID: $categoryId)');

    if (categoryId == null) {
      Get.snackbar('Error', 'Invalid category data');
      return;
    }

    // Show loading snackbar
    Get.snackbar(
      'Loading...',
      'Loading ${category['name']} content...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF006DF4),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );

    // Navigate based on category name
    if (categoryName.contains('knowledge')) {
      _navigateToKnowledgeCenter(category);
    } else if (categoryName.contains('community')) {
      _navigateToCommunityForum(category);
    } else {
      // Default to knowledge center for unknown categories
      _navigateToKnowledgeCenter(category);
    }
  }

  void _navigateToKnowledgeCenter(Map<String, dynamic> category) {
    print('🚀 LearnScreenController - Navigating to Knowledge Center');
    Get.toNamed(
      Routes.KNOWLEDGE_CENTER_SCREEN,
      arguments: {
        'categoryId': category['_id'],
        'categoryName': category['name'],
        'categoryData': category,
      },
    );
  }

  void _navigateToCommunityForum(Map<String, dynamic> category) {
    print('🚀 LearnScreenController - Navigating to Community Forum');
    Get.toNamed(
      Routes.COMMUNITY_FORUM,
      arguments: {
        'categoryId': category['_id'],
        'categoryName': category['name'],
        'categoryData': category,
      },
    );
  }

  Future<void> loadSubCategories(String mainId) async {
    try {
      isLoading.value = true;
      print('🚀 LearnScreenController - Loading subcategories for: $mainId');

      final resp = await _learn.getSubCategories(mainId);
      if (resp.success && resp.data != null) {
        subCategories
            .assignAll((resp.data!['items'] as List<Map<String, dynamic>>));
        print(
            '✅ LearnScreenController - Subcategories loaded: ${subCategories.length}');

        // Show subcategories in a dialog or navigate to detail screen
        _showSubCategoriesDialog();
      } else {
        print(
            '❌ LearnScreenController - Subcategories failed: ${resp.message}');
        Get.snackbar('Error', 'Failed to load sub-categories: ${resp.message}');
      }
    } catch (e) {
      print('❌ LearnScreenController - Subcategories exception: $e');

      Get.snackbar('Error', 'Failed to load sub-categories: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTopics(String mainId, String subId) async {
    try {
      isLoading.value = true;
      selectedSubCategoryId.value = subId;
      print('🚀 LearnScreenController - Loading topics for: $mainId/$subId');

      final resp = await _learn.getTopics(mainId, subId);
      if (resp.success && resp.data != null) {
        topics.assignAll((resp.data!['items'] as List<Map<String, dynamic>>));
        print('✅ LearnScreenController - Topics loaded: ${topics.length}');

        // Show topics in a dialog or navigate to detail screen
        _showTopicsDialog();
      } else {
        print('❌ LearnScreenController - Topics failed: ${resp.message}');
        Get.snackbar('Error', 'Failed to load topics: ${resp.message}');
      }
    } catch (e) {
      print('❌ LearnScreenController - Topics exception: $e');

      Get.snackbar('Error', 'Failed to load topics: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadEntries(String mainId, String subId, String topicId) async {
    try {
      isLoading.value = true;
      selectedTopicId.value = topicId;
      print(
          '🚀 LearnScreenController - Loading entries for: $mainId/$subId/$topicId');

      final resp = await _learn.getEntries(mainId, subId, topicId);
      if (resp.success && resp.data != null) {
        entries.assignAll((resp.data!['items'] as List<Map<String, dynamic>>));
        print('✅ LearnScreenController - Entries loaded: ${entries.length}');

        // Show entries in a dialog or navigate to detail screen
        _showEntriesDialog();
      } else {
        print('❌ LearnScreenController - Entries failed: ${resp.message}');
        Get.snackbar('Error', 'Failed to load entries: ${resp.message}');
      }
    } catch (e) {
      print('❌ LearnScreenController - Entries exception: $e');
      Get.snackbar('Error', 'Failed to load entries: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Show subcategories in a dialog
  void _showSubCategoriesDialog() {
    if (subCategories.isEmpty) {
      Get.snackbar('Info', 'No subcategories available');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Text('Select Subcategory'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: subCategories.length,
            itemBuilder: (context, index) {
              final subcategory = subCategories[index];
              return ListTile(
                title: Text(subcategory['name']?.toString() ?? 'Unknown'),
                onTap: () {
                  Get.back();
                  loadTopics(selectedMainCategoryId.value,
                      subcategory['_id'].toString());
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Show topics in a dialog
  void _showTopicsDialog() {
    if (topics.isEmpty) {
      Get.snackbar('Info', 'No topics available');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Text('Select Topic'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return ListTile(
                title: Text(topic['name']?.toString() ?? 'Unknown'),
                onTap: () {
                  Get.back();
                  loadEntries(
                    selectedMainCategoryId.value,
                    selectedSubCategoryId.value,
                    topic['_id'].toString(),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Show entries in a dialog
  void _showEntriesDialog() {
    if (entries.isEmpty) {
      Get.snackbar('Info', 'No entries available');
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Text('Content Entries'),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                child: ListTile(
                  title: Text(entry['title']?.toString() ?? 'Untitled'),
                  subtitle: Text(entry['body']?.toString() ?? 'No content'),
                  onTap: () {
                    Get.back();
                    _showEntryDetail(entry);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  // Show detailed entry content
  void _showEntryDetail(Map<String, dynamic> entry) {
    Get.dialog(
      AlertDialog(
        title: Text(entry['title']?.toString() ?? 'Content'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (entry['image'] != null)
                Image.network(
                  '${ApiConstants.baseUrl}/uploads/${entry['image']}',
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: Icon(Icons.image_not_supported),
                    );
                  },
                ),
              SizedBox(height: 16),
              Text(
                entry['body']?.toString() ?? 'No content available',
                style: TextStyle(fontSize: 16),
              ),
              if (entry['footer'] != null) ...[
                SizedBox(height: 16),
                Text(
                  entry['footer'].toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
