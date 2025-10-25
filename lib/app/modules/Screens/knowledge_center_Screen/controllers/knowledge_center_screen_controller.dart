import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/knowledge_service.dart';
import 'package:vropay_final/app/core/services/learn_service.dart';
import 'package:vropay_final/app/routes/app_pages.dart';
import 'package:vropay_final/app/modules/Screens/news/views/news_detail_screen.dart';

class KnowledgeCenterScreenController extends GetxController {
  final KnowledgeService _knowledgeService = Get.find<KnowledgeService>();
  final LearnService _learnService = Get.find<LearnService>();

  // Observable variables
  final RxList<dynamic> topics = <dynamic>[].obs;
  final RxList<dynamic> subtopics = <dynamic>[].obs;
  final RxList<dynamic> contents = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedTopicId = ''.obs;
  final RxString selectedSubtopicId = ''.obs;

  // Learn API data
  final RxList<Map<String, dynamic>> subCategories =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> learnTopics = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> entries = <Map<String, dynamic>>[].obs;
  final RxString selectedMainCategoryId = ''.obs;
  final RxString selectedSubCategoryId = ''.obs;
  final RxString selectedLearnTopicId = ''.obs;

  // Continue reading data
  final RxMap<String, dynamic> continueReadingData = <String, dynamic>{}.obs;

  // Observable variables for content management
  final RxList<Map<String, dynamic>> contentDetails =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> relatedContent =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> searchResults =
      <Map<String, dynamic>>[].obs;

  final RxString currentContentId = ''.obs;
  final RxBool isContentLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  final RxString currentSearchQuery = ''.obs;

  // TextField controller for search
  final TextEditingController searchTextController = TextEditingController();

  // Category data from navigation
  String? categoryId;
  String? categoryName;
  Map<String, dynamic>? categoryData;

  Timer? _searchDebounce;

  // Debounced search method
  void searchTopicsDebounced(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(Duration(milliseconds: 500), () {
      searchTopics(query);
    });
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchTextController.dispose();
    super.onClose();
  }

  final count = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // Get category data from navigation arguments
    final args = Get.arguments;
    if (args != null) {
      categoryId = args['categoryId']?.toString();
      categoryName = args['categoryName']?.toString();
      categoryData = args['categoryData'] as Map<String, dynamic>?;

      print('🚀 KnowledgeCenter - Category ID: $categoryId');
      print('🚀 KnowledgeCenter - Category Name: $categoryName');
    }

    // Load data based on category
    if (categoryId != null) {
      loadLearnData();
    } else {
      loadKnowledgeCenter();
    }

    // Load continue reading data
    loadContinueReading();
  }

  // Load continue reading data - last read topic
  Future<void> loadContinueReading() async {
    try {
      print('🚀 KnowledgeCenter - Loading continue reading data');

      final response = await _learnService.getContinueReading();

      if (response.success &&
          response.data != null &&
          response.data!.isNotEmpty) {
        continueReadingData.assignAll(response.data!);
        print(
            '✅ KnowledgeCenter - Continue reading data loaded: ${continueReadingData['topicName']}');
        print('   - Topic ID: ${continueReadingData['topicId']}');
        print('   - Progress: ${continueReadingData['progressPercentage']}%');
        print(
            '   - Read: ${continueReadingData['readEntries']}/${continueReadingData['totalEntries']}');
      } else {
        print('⚠️ KnowledgeCenter - No continue reading data available');
        continueReadingData.clear();
      }
    } catch (e) {
      print('❌ KnowledgeCenter - Continue reading error: $e');
      continueReadingData.clear();
    }
  }

  // Load traditional knowledge center data
  Future<void> loadKnowledgeCenter() async {
    try {
      isLoading.value = true;
      print('🚀 KnowledgeCenter - Loading traditional knowledge center data');

      final response = await _knowledgeService.getKnowledgeCenter();

      if (response.success && response.data != null) {
        final raw = response.data!['topics'];
        topics.value = raw is List ? raw : [];
        print('✅ KnowledgeCenter - Topics loaded: ${topics.length}');
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load knowledge center: ${e.toString()}');
      print('❌ KnowledgeCenter - Knowledge center error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load Learn API data for the specific category
  Future<void> loadLearnData() async {
    try {
      isLoading.value = true;
      print(
          '🚀 KnowledgeCenter - Loading Learn API data for category: $categoryId');

      if (categoryId == null) {
        print('❌ KnowledgeCenter - No category ID provided');
        return;
      }

      // Load subcategories for the main category
      final response =
          await _learnService.getCompleteMainCategoryData(categoryId!);

      if (response.success && response.data != null) {
        final mainCategory =
            response.data!['mainCategory'] as Map<String, dynamic>?;
        final subCategories =
            response.data!['subCategories'] as List<Map<String, dynamic>>;

        print(
            '🔍 KnowledgeCenter - Raw subcategories: ${subCategories.length}');

        if (subCategories.isNotEmpty) {
          // FIXED: Use controller.subCategories instead of subCategories
          this.subCategories.assignAll(subCategories);
          print(
              '✅ KnowledgeCenter - Subcategories loaded: ${this.subCategories.length}');

          // Store the complete data for easy access
          _storeCompleteData(mainCategory, subCategories);
        } else {
          print('⚠️ KnowledgeCenter - No subcategories found');
          _showNoDataMessage();
        }
      } else {
        print(
            '❌ KnowledgeCenter - Failed to load subcategories: ${response.message}');
        Get.snackbar(
          'Error',
          'Failed to load category data: ${response.message}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
      }
    } catch (e) {
      print('❌ KnowledgeCenter - Learn data error: $e');
      Get.snackbar(
        'Error',
        'Failed to load category data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

// Enhanced loadTopicsForSubCategory method
  Future<void> loadTopicsForSubCategory(String subCategoryId) async {
    try {
      isLoading.value = true;
      selectedSubCategoryId.value = subCategoryId;
      print(
          '🚀 KnowledgeCenter - Loading topics for subcategory: $subCategoryId');

      if (categoryId == null) {
        Get.snackbar('Error', 'No main category selected');
        return;
      }

      // First try to get topics from the already loaded data
      final subCategory = this.subCategories.firstWhereOrNull(
            (sub) => sub['_id']?.toString() == subCategoryId,
          );

      if (subCategory != null && subCategory['topics'] != null) {
        final topics = subCategory['topics'] as List<Map<String, dynamic>>;
        learnTopics.assignAll(topics);
        print(
            '✅ KnowledgeCenter - Topics loaded from cached data: ${learnTopics.length}');

        Get.snackbar(
          'Success',
          'Loaded ${learnTopics.length} topics from cache',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        // Fallback to API call if not in cached data
        final topicsResponse =
            await _learnService.getTopics(categoryId!, subCategoryId);

        if (topicsResponse.success && topicsResponse.data != null) {
          final items =
              (topicsResponse.data!['items'] as List<Map<String, dynamic>>);
          learnTopics.assignAll(items);
          print(
              '✅ KnowledgeCenter - Topics loaded from API: ${learnTopics.length}');

          Get.snackbar(
            'Success',
            'Loaded ${learnTopics.length} topics from API',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
        } else {
          print(
              '❌ KnowledgeCenter - Failed to load topics: ${topicsResponse.message}');
          Get.snackbar(
            'Error',
            'Failed to load topics: ${topicsResponse.message}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
      }
    } catch (e) {
      print('❌ KnowledgeCenter - Topics error: $e');
      Get.snackbar(
        'Error',
        'Failed to load topics: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

// Enhanced loadEntriesForTopic method
  Future<void> loadEntriesForTopic(String subCategoryId, String topicId) async {
    try {
      isLoading.value = true;
      selectedLearnTopicId.value = topicId;
      print('🚀 KnowledgeCenter - Loading entries for topic: $topicId');

      if (categoryId == null) {
        Get.snackbar('Error', 'No main category selected');
        return;
      }

      // First try to get entries from the already loaded data
      final subCategory = this.subCategories.firstWhereOrNull(
            (sub) => sub['_id']?.toString() == subCategoryId,
          );

      if (subCategory != null) {
        final topics =
            subCategory['topics'] as List<Map<String, dynamic>>? ?? [];
        final topic = topics.firstWhereOrNull(
          (topic) => topic['_id']?.toString() == topicId,
        );

        if (topic != null && topic['entries'] != null) {
          final entries = topic['entries'] as List<Map<String, dynamic>>;
          entries.assignAll(entries);
          print(
              '✅ KnowledgeCenter - Entries loaded from cached data: ${entries.length}');

          Get.snackbar(
            'Success',
            'Loaded ${entries.length} entries from cache',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
          return;
        }
      }

      // Fallback to API call if not in cached data
      final entriesResponse =
          await _learnService.getEntries(categoryId!, subCategoryId, topicId);

      if (entriesResponse.success && entriesResponse.data != null) {
        final items =
            (entriesResponse.data!['items'] as List<Map<String, dynamic>>);
        entries.assignAll(items);
        print('✅ KnowledgeCenter - Entries loaded from API: ${entries.length}');

        Get.snackbar(
          'Success',
          'Loaded ${entries.length} entries from API',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        print(
            '❌ KnowledgeCenter - Failed to load entries: ${entriesResponse.message}');
        Get.snackbar(
          'Error',
          'Failed to load entries: ${entriesResponse.message}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ KnowledgeCenter - Entries error: $e');
      Get.snackbar(
        'Error',
        'Failed to load entries: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load detailed content for an entry
  Future<void> loadEntryContent(String entryId) async {
    try {
      isContentLoading.value = true;
      currentContentId.value = entryId;
      print('🚀 KnowledgeCenter - Loading entry content: $entryId');

      final response = await _learnService.getEntryContent(entryId);

      if (response.success && response.data != null) {
        final contentData = response.data!;
        contentDetails.assignAll([contentData]);

        // Also load related content
        await loadRelatedContent(entryId);

        print('✅ KnowledgeCenter - Entry content loaded successfully');

        Get.snackbar(
          'Success',
          'Content loaded successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        print(
            '❌ KnowledgeCenter - Failed to load entry content: ${response.message}');
        Get.snackbar(
          'Error',
          'Failed to load content: ${response.message}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ KnowledgeCenter - Entry content error: $e');
      Get.snackbar(
        'Error',
        'Failed to load content: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isContentLoading.value = false;
    }
  }

  // Load related content for an entry
  Future<void> loadRelatedContent(String entryId) async {
    try {
      print('🚀 KnowledgeCenter - Loading related content for: $entryId');

      final response = await _learnService.getRelatedContent(entryId);

      if (response.success && response.data != null) {
        final items = response.data!['items'] as List<Map<String, dynamic>>;
        relatedContent.assignAll(items);
        print(
            '✅ KnowledgeCenter - Related content loaded: ${relatedContent.length}');
      } else {
        print(
            '❌ KnowledgeCenter - Failed to load related content: ${response.message}');
      }
    } catch (e) {
      print('❌ KnowledgeCenter - Related content error: $e');
    }
  }

  // Search content within current subcategory
  Future<void> searchContent(String query) async {
    try {
      isLoading.value = true;
      searchQuery.value = query;
      print('🚀 KnowledgeCenter - Searching content: $query');

      if (selectedSubCategoryId.value.isEmpty) {
        Get.snackbar('Error', 'No subcategory selected for search');
        return;
      }

      final response = await _learnService.searchContentInSubCategory(
          selectedSubCategoryId.value, query);

      if (response.success && response.data != null) {
        final items = response.data!['items'] as List<Map<String, dynamic>>;
        searchResults.assignAll(items);
        print('✅ KnowledgeCenter - Search results: ${searchResults.length}');

        Get.snackbar(
          'Search Results',
          'Found ${searchResults.length} results for "$query"',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        print('❌ KnowledgeCenter - Search failed: ${response.message}');
        Get.snackbar(
          'Search Failed',
          'No results found for "$query"',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ KnowledgeCenter - Search error: $e');
      Get.snackbar(
        'Error',
        'Search failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Enhanced entry tap with content preloading
  void onEntryTapWithContent(Map<String, dynamic> entry) async {
    final entryId = entry['_id']?.toString();
    if (entryId != null) {
      // Show loading indicator
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFFE93A47)),
                SizedBox(height: 16),
                Text('Loading content...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      try {
        // Load content in background
        await loadEntryContent(entryId);

        // Close loading dialog
        Get.back();

        // Navigate with loaded content
        navigateToContentDetail(entry);
      } catch (e) {
        // Close loading dialog
        Get.back();

        // Show error and navigate anyway
        Get.snackbar(
          'Warning',
          'Content loading failed, showing basic details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        // Navigate with basic data
        onEntryTap(entry);
      }
    }
  }

  // Clear search results
  void clearSearchResults() {
    searchResults.clear();
    currentSearchQuery.value = '';
  }

  // Navigate to content detail with full content loading
  void navigateToContentDetail(Map<String, dynamic> entry) async {
    final entryId = entry['_id']?.toString();
    if (entryId != null) {
      // Load the full content first
      await loadEntryContent(entryId);

      // Navigate to detail screen with loaded content
      Get.toNamed(Routes.NEWS_DETAILS_SCREEN, arguments: {
        'contentId': entryId,
        'entryData': entry,
        'categoryName': categoryName,
        'contentDetails':
            contentDetails.isNotEmpty ? contentDetails.first : null,
        'relatedContent': relatedContent.toList(),
      });
    }
  }

  // Navigate to subcategory detail
  void onSubCategoryTap(Map<String, dynamic> subCategory) {
    final subCategoryId = subCategory['_id']?.toString();
    if (subCategoryId != null) {
      loadTopicsForSubCategory(subCategoryId);
    }
  }

  // Navigate to topic detail
  void onTopicTap(Map<String, dynamic> topic) {
    final topicId = topic['_id']?.toString();
    if (topicId != null && selectedSubCategoryId.value.isNotEmpty) {
      loadEntriesForTopic(selectedSubCategoryId.value, topicId);
    }
  }

  // Navigate to entry detail
  void onEntryTap(Map<String, dynamic> entry) {
    final entryId = entry['_id']?.toString();
    if (entryId != null) {
      Get.toNamed(Routes.NEWS_DETAILS_SCREEN, arguments: {
        'contentId': entryId,
        'entryData': entry,
        'categoryName': categoryName,
      });
    }
  }

  // Navigate to continue reading - last read entry detail
  void onContinueReadingTap() {
    if (continueReadingData.isEmpty) {
      Get.snackbar('Info', 'No previous topic to continue reading');
      return;
    }

    final lastReadEntry = continueReadingData['lastReadEntry'];

    print('🚀 KnowledgeCenter - Navigating to continue reading entry');
    print('   - Last Read Entry: $lastReadEntry');

    // Check if we have the last read entry data
    if (lastReadEntry == null ||
        (lastReadEntry is Map && lastReadEntry.isEmpty)) {
      print(
          '⚠️ KnowledgeCenter - No last read entry found, navigating to topic');
      _navigateToTopic();
      return;
    }

    final entryId = lastReadEntry['_id']?.toString();
    final entryTitle = lastReadEntry['title']?.toString();

    print('   - Entry ID: $entryId');
    print('   - Entry Title: $entryTitle');

    // Validate entry ID
    if (entryId == null || entryId.isEmpty) {
      print('⚠️ KnowledgeCenter - Entry ID is missing, navigating to topic');
      _navigateToTopic();
      return;
    }

    // Navigate directly to news detail screen with the last read entry
    Get.to(
      () => NewsDetailScreen(news: lastReadEntry),
      transition: Transition.rightToLeft,
      duration: Duration(milliseconds: 300),
    );
  }

  // Fallback: Navigate to topic if entry data is not available
  void _navigateToTopic() {
    final topicId = continueReadingData['topicId']?.toString();
    final topicName = continueReadingData['topicName']?.toString();
    final subCategoryId = continueReadingData['subCategoryId']?.toString();
    final mainCategoryId = continueReadingData['mainCategoryId']?.toString();

    print('🚀 KnowledgeCenter - Fallback: Navigating to topic');
    print('   - Topic ID: $topicId');
    print('   - Topic Name: $topicName');

    // Validate required parameters
    if (topicId == null || topicId.isEmpty) {
      Get.snackbar('Error', 'Topic ID is missing');
      return;
    }

    if (subCategoryId == null || subCategoryId.isEmpty) {
      Get.snackbar('Error', 'SubCategory ID is missing');
      return;
    }

    if (mainCategoryId == null || mainCategoryId.isEmpty) {
      Get.snackbar('Error', 'Category ID is missing');
      return;
    }

    // Navigate to news screen with topic data
    Get.toNamed(Routes.NEWS_SCREEN, arguments: {
      'topicId': topicId,
      'topicName': topicName ?? 'Topic',
      'subCategoryId': subCategoryId,
      'categoryId': mainCategoryId,
    });
  }

// Helper method to store complete data structure
  void _storeCompleteData(Map<String, dynamic>? mainCategory,
      List<Map<String, dynamic>> subCategories) {
    // Store main category info
    if (mainCategory != null) {
      print('📋 KnowledgeCenter - Main Category: ${mainCategory['name']}');
    }

    // Store subcategories with their complete data
    for (var subCategory in subCategories) {
      final topics = subCategory['topics'] as List<Map<String, dynamic>>?;
      print(
          '📋 KnowledgeCenter - SubCategory: ${subCategory['name']} with ${topics?.length ?? 0} topics');

      if (topics != null) {
        for (var topic in topics) {
          final entries = topic['entries'] as List<Map<String, dynamic>>?;
          print(
              '📋 KnowledgeCenter - Topic: ${topic['name']} with ${entries?.length ?? 0} entries');
        }
      }
    }
  }

  // Legacy methods for backward compatibility
  Future<void> loadSubtopics(String topicId) async {
    try {
      isLoading.value = true;
      selectedTopicId.value = topicId;

      final response = await _knowledgeService.getSubTopicContents(topicId);

      if (response.success && response.data != null) {
        final raw = response.data!['subtopics'];
        subtopics.value = raw is List ? raw : [];
        print('✅ Loaded ${subtopics.length} subtopics for topic: $topicId');
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load subtopics: ${e.toString()}');
      print('❌ Load subtopics error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadContents(String subtopicId) async {
    try {
      isLoading.value = true;
      selectedSubtopicId.value = subtopicId;

      final response = await _knowledgeService.getSubTopicContents(subtopicId);

      if (response.success && response.data != null) {
        final raw = response.data!['contents'];
        contents.value = raw is List ? raw : [];
        print('✅ Loaded ${contents.length} contents for subtopic: $subtopicId');
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load contents: ${e.toString()}');
      print('❌ Load contents error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToContent(String contentId) {
    Get.toNamed(Routes.NEWS_DETAILS_SCREEN,
        arguments: {'contentId': contentId});
  }

  void navigateToSubtopicCommunity(String subtopicId) {
    Get.toNamed(Routes.WORLD_AND_CULTURE_COMMUNITY_SCREEN,
        arguments: {'subtopicId': subtopicId});
  }

  // Show user-friendly message when no data is available
  void _showNoDataMessage() {
    subCategories.assignAll([
      {
        'name': 'Currently we have not this type of data',
        'isNoData': true,
      }
    ]);

    Get.snackbar(
      'No Content Available',
      'We are working on adding more content for this category. Please check back later.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: Duration(seconds: 4),
    );
  }

  // Search topics by query using subcategory search
  Future<void> searchTopics(String query) async {
    try {
      if (query.trim().isEmpty) {
        // Clear search results if query is empty
        searchResults.clear();
        currentSearchQuery.value = '';
        return;
      }

      isSearching.value = true;
      currentSearchQuery.value = query;
      print('🚀 KnowledgeCenter - Searching topics: $query');

      if (categoryId == null) {
        Get.snackbar('Error', 'No category ID available for search');
        return;
      }

      // First, get all subcategories for the main category
      final subCategoriesResponse =
          await _learnService.getCompleteMainCategoryData(categoryId!);

      if (!subCategoriesResponse.success ||
          subCategoriesResponse.data == null) {
        Get.snackbar('Error', 'Failed to load subcategories');
        return;
      }

      final subCategories = subCategoriesResponse.data!['subCategories']
          as List<Map<String, dynamic>>;
      print(
          '🔍 KnowledgeCenter - Found ${subCategories.length} subcategories to search');

      // Search for topics within subcategories
      List<Map<String, dynamic>> foundTopics = [];

      for (var subCategory in subCategories) {
        if (subCategory['topics'] != null) {
          final topics = subCategory['topics'] as List<Map<String, dynamic>>;

          for (var topic in topics) {
            final topicName = topic['name']?.toString().toLowerCase() ?? '';
            final searchQuery = query.toLowerCase();

            // Check if topic name contains the search query
            if (topicName.contains(searchQuery)) {
              // Add subcategory info to the topic
              topic['subCategory'] = {
                '_id': subCategory['_id'],
                'name': subCategory['name'],
              };
              topic['entriesCount'] = (topic['entries'] as List?)?.length ?? 0;
              foundTopics.add(topic);
            }
          }
        }
      }

      // Sort by relevance (exact matches first, then partial matches)
      foundTopics.sort((a, b) {
        final aName = a['name']?.toString().toLowerCase() ?? '';
        final bName = b['name']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        // Exact match gets highest priority
        if (aName == searchQuery && bName != searchQuery) return -1;
        if (bName == searchQuery && aName != searchQuery) return 1;

        // Starts with query gets second priority
        if (aName.startsWith(searchQuery) && !bName.startsWith(searchQuery))
          return -1;
        if (bName.startsWith(searchQuery) && !aName.startsWith(searchQuery))
          return 1;

        // Alphabetical order for other matches
        return aName.compareTo(bName);
      });

      searchResults.assignAll(foundTopics);
      print(
          '✅ KnowledgeCenter - Found ${searchResults.length} topics matching "$query"');

      if (foundTopics.isEmpty) {
        Get.snackbar('Info', 'No topics found matching "$query"');
      }
    } catch (e) {
      print('❌ KnowledgeCenter - Search error: $e');
      Get.snackbar('Error', 'Search failed: ${e.toString()}');
    } finally {
      isSearching.value = false;
    }
  }

  // Check if currently showing search results
  bool get isShowingSearchResults => searchResults.isNotEmpty;

  void clearSearch() {
    searchResults.clear();
    currentSearchQuery.value = '';
    searchTextController.clear();
  }
}
