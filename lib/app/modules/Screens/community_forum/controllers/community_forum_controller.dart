import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/community_service.dart';
import 'package:vropay_final/app/core/services/forum_service.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class CommunityForumController extends GetxController {
  final ForumService _forumService = Get.find<ForumService>();
  late final CommunityService _communityService;

  // Observable variables for community data
  final RxList<Map<String, dynamic>> mainCategories =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> subCategories =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedMainCategoryId = ''.obs;
  final RxString selectedSubCategoryId = ''.obs;

  // Observable variables for forum data
  final RxList<dynamic> categories = <dynamic>[].obs;
  final RxList<dynamic> subtopics = <dynamic>[].obs;
  final RxList<dynamic> rooms = <dynamic>[].obs;
  final RxList<dynamic> messages = <dynamic>[].obs;
  final RxString selectedCategoryId = ''.obs;
  final RxString selectedSubtopicId = ''.obs;
  final RxString selectedRoomId = ''.obs;

  // Category data from navigation
  String? categoryId;
  String? categoryName;
  Map<String, dynamic>? categoryData;

  final TextEditingController searchController = TextEditingController();
  final RxList<String> suggestions = <String>[].obs;
  Timer? _debounce;

  // Search results (topic objects) and current search query
  final RxList<Map<String, dynamic>> searchResults =
      <Map<String, dynamic>>[].obs;
  final RxString currentSearchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  Timer? _searchDebounce;
  // Continue-reading topics (recently read topics for the user)
  final RxList<Map<String, dynamic>> continueReadingTopics =
      <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> continueReadingTarget = <String, dynamic>{}.obs;
  // Last visited screen info (used as AI fallback when no recent topic)
  final RxString lastVisitedScreenName = ''.obs;
  final RxString lastVisitedScreenRoute = ''.obs;
  final RxMap<String, dynamic> lastVisitedScreenArgs = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize CommunityService
    try {
      _communityService = Get.find<CommunityService>();
    } catch (e) {
      print('❌ CommunityForum - CommunityService not found, creating it');
      _communityService = Get.put(CommunityService(), permanent: true);
    }

    // Get category data from navigation arguments
    final args = Get.arguments;
    if (args != null) {
      categoryId = args['categoryId']?.toString();
      categoryName = args['categoryName']?.toString();
      categoryData = args['categoryData'] as Map<String, dynamic>?;

      print('🚀 CommunityForum - Category ID: $categoryId');
      print('🚀 CommunityForum - Category Name: $categoryName');
    }

    // Load data based on category
    if (categoryId != null) {
      loadCommunityData();
    } else {
      // Load default community data if no specific category
      loadDefaultCommunityData();
    }

    // Load continue-reading topics for this category (if categoryId present)
    loadContinueReadingTopics();
    // Load last visited screen from local storage (for AI fallback)
    loadLastVisitedScreen();
  }

  // Load last visited screen name & route from SharedPreferences
  Future<void> loadLastVisitedScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('last_visited_screen_name') ?? '';
      final route = prefs.getString('last_visited_screen_route') ?? '';
      final argsJson = prefs.getString('last_visited_screen_args') ?? '';
      if (argsJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(argsJson);
          if (decoded is Map<String, dynamic>) {
            lastVisitedScreenArgs.assignAll(decoded);
          } else if (decoded is Map) {
            // cast map dynamic
            lastVisitedScreenArgs.assignAll(Map<String, dynamic>.from(decoded));
          }
        } catch (e) {
          print('⚠️ CommunityForum - Failed to decode last visited args: $e');
          lastVisitedScreenArgs.clear();
        }
      } else {
        lastVisitedScreenArgs.clear();
      }
      lastVisitedScreenName.value = name;
      lastVisitedScreenRoute.value = route;
      print('📌 CommunityForum - Loaded last visited screen: $name -> $route');
    } catch (e) {
      print('⚠️ CommunityForum - Failed to load last visited screen: $e');
      lastVisitedScreenName.value = '';
      lastVisitedScreenRoute.value = '';
      lastVisitedScreenArgs.clear();
    }
  }

  // Load continue-reading topics and expose for UI
  Future<void> loadContinueReadingTopics({int page = 1, int limit = 1}) async {
    try {
      isLoading.value = true;
      print('🚀 CommunityForum - Loading continue-reading topics');

      final response = await _communityService.getContinueReadingTopics(
        mainCategoryId: categoryId,
        page: page,
        limit: limit,
      );

      if (response.success && response.data != null) {
        // response.data is List<Map>
        final items = response.data as List<Map<String, dynamic>>;
        continueReadingTopics.assignAll(items);
        if (items.isNotEmpty) {
          // Keep first item as target for quick navigation
          continueReadingTarget.assignAll(items.first);
        }
        print(
            '✅ CommunityForum - Continue-reading topics loaded: ${items.length}');
      } else {
        print('⚠️ CommunityForum - No continue-reading topics found');
        continueReadingTopics.clear();
        continueReadingTarget.clear();
      }
    } catch (e) {
      print('❌ CommunityForum - Continue-reading load error: $e');
      continueReadingTopics.clear();
      continueReadingTarget.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Called on each keystroke (debounced)
  void onSearchChanged(String q) {
    // Keep the original quick suggestions behaviour (strings) for backwards compatibility
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 400), () async {
      final query = q.trim();
      if (query.isEmpty) {
        suggestions.clear();
        return;
      }
      // small placeholder suggestions (can be removed if using topic search)
      suggestions.value = await _fakeSearchApi(query);
    });

    // Also run the richer topic search (debounced separately)
    searchTopicsDebounced(q);
  }

  Future<List<String>> _fakeSearchApi(String q) async {
    // Replace with real API call or reuse knowledge center search logic
    await Future.delayed(Duration(milliseconds: 200));
    return List.generate(5, (i) => '$q suggestion ${i + 1}');
  }

  // Debounced topic search (reuses CommunityService data similar to Knowledge Center)
  void searchTopicsDebounced(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(Duration(milliseconds: 500), () {
      searchTopics(query);
    });
  }

  // Search topics across subcategories for the current main category
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
      print('🚀 CommunityForum - Searching topics: $query');

      if (categoryId == null) {
        Get.snackbar('Error', 'No category ID available for search');
        return;
      }

      // Get full community data for this main category
      final response =
          await _communityService.fetchCommunityScreenData(categoryId!);
      if (!response.success || response.data == null) {
        Get.snackbar('Error', 'Failed to load topics for search');
        return;
      }

      final subCategoriesData =
          response.data!['subCategories'] as List<Map<String, dynamic>>;

      List<Map<String, dynamic>> foundTopics = [];
      final searchLower = query.toLowerCase();

      for (var subCat in subCategoriesData) {
        if (subCat['topics'] != null) {
          final topics =
              (subCat['topics'] as List).cast<Map<String, dynamic>>();
          for (var topic in topics) {
            final name = topic['name']?.toString().toLowerCase() ?? '';
            if (name.contains(searchLower)) {
              // attach subcategory info to topic for navigation
              topic['subCategory'] = {
                '_id': subCat['_id'],
                'name': subCat['name']
              };
              topic['entriesCount'] = (topic['entries'] as List?)?.length ?? 0;
              foundTopics.add(topic);
            }
          }
        }
      }

      // Sort similar to Knowledge Center: exact matches first
      foundTopics.sort((a, b) {
        final aName = a['name']?.toString().toLowerCase() ?? '';
        final bName = b['name']?.toString().toLowerCase() ?? '';
        if (aName == searchLower && bName != searchLower) return -1;
        if (bName == searchLower && aName != searchLower) return 1;
        if (aName.startsWith(searchLower) && !bName.startsWith(searchLower))
          return -1;
        if (bName.startsWith(searchLower) && !aName.startsWith(searchLower))
          return 1;
        return aName.compareTo(bName);
      });

      searchResults.assignAll(foundTopics);
      print('✅ CommunityForum - Topic search results: ${searchResults.length}');
    } catch (e) {
      print('❌ CommunityForum - Search error: $e');
      Get.snackbar('Error', 'Search failed: ${e.toString()}');
    } finally {
      isSearching.value = false;
    }
  }

  // Handle tapping a topic search result - navigate to message screen
  void onTopicSearchResultTap(Map<String, dynamic> topic) async {
    final topicId = topic['_id']?.toString();
    final topicName = topic['name']?.toString();
    final subCategoryId = topic['subCategory']?['_id']?.toString();
    final subCategoryName = topic['subCategory']?['name']?.toString();

    print(
        '🔍 CommunityForum - Navigating to message screen from search result...');
    print('   - topicName: $topicName');
    print('   - topicId: $topicId');

    if (topicId == null || topicId.isEmpty) {
      Get.snackbar('Error', 'Topic ID missing');
      return;
    }

    // Follow the same consent/visit logic as other topic navigations if needed
    // For now navigate directly to message screen and pass topic info
    Get.toNamed(Routes.MESSAGE_SCREEN, arguments: {
      'interestId': topicId,
      'interestName': topicName ?? '',
      'subCategoryId': subCategoryId ?? '',
      'subCategoryName': subCategoryName ?? '',
      'categoryId': categoryId ?? '',
      'categoryName': categoryName ?? '',
      'topicId': topicId,
    });
  }

  // Navigate to message screen using continueReadingTarget (first recent topic)
  void onContinueReadingTap() {
    if (continueReadingTarget.isEmpty) {
      // If no continue-reading topic, fall back to last visited screen (if available)
      if (lastVisitedScreenRoute.value.isNotEmpty) {
        print(
            '🔁 CommunityForum - No recent topic, navigating to last visited screen: ${lastVisitedScreenName.value}');
        try {
          if (lastVisitedScreenArgs.isNotEmpty) {
            print(
                '🔁 CommunityForum - Navigating with args: ${lastVisitedScreenArgs}');
            Get.toNamed(lastVisitedScreenRoute.value,
                arguments: lastVisitedScreenArgs);
          } else {
            Get.toNamed(lastVisitedScreenRoute.value);
          }
        } catch (e) {
          print(
              '❌ CommunityForum - Failed to navigate to last visited route: $e');
          Get.snackbar('Info', 'No recent topic to continue');
        }
        return;
      }

      Get.snackbar('Info', 'No recent topic to continue');
      return;
    }

    final topic = continueReadingTarget;
    final topicId = topic['_id']?.toString();
    final topicName = topic['name']?.toString();
    final subCategoryId = topic['subCategory']?['_id']?.toString();
    final subCategoryName = topic['subCategory']?['name']?.toString();

    if (topicId == null || topicId.isEmpty) {
      Get.snackbar('Error', 'Topic data is missing');
      return;
    }

    // Navigate to message screen (open message view for this topic)
    Get.toNamed(Routes.MESSAGE_SCREEN, arguments: {
      'interestId': topicId,
      'interestName': topicName ?? '',
      'subCategoryId': subCategoryId ?? '',
      'subCategoryName': subCategoryName ?? '',
      'categoryId':
          topic['mainCategory']?['_id']?.toString() ?? categoryId ?? '',
      'categoryName':
          topic['mainCategory']?['name']?.toString() ?? categoryName ?? '',
      'topicId': topicId,
    });
  }

  void clearSearchResults() {
    searchResults.clear();
    currentSearchQuery.value = '';
    searchController.clear();
  }

  void onSuggestionTap(String text) {
    // Navigate to Message screen with query or selected interest/topic
    Get.toNamed(Routes.MESSAGE_SCREEN, arguments: {'query': text});
  }

  void submitSearch(String q) {
    final query = q.trim();
    if (query.isEmpty) return;
    Get.toNamed(Routes.MESSAGE_SCREEN, arguments: {'query': query});
  }

  void clearSearch() {
    searchController.clear();
    suggestions.clear();
  }

  // Load community data from API (similar to knowledge center)
  Future<void> loadCommunityData() async {
    try {
      isLoading.value = true;
      print(
          '🚀 CommunityForum - Loading community data for category: $categoryId');

      if (categoryId == null) {
        print('❌ CommunityForum - No category ID provided');
        _showConnectivityError('Invalid category data');
        return;
      }

      // Fetch comprehensive community screen data using the new method
      final response =
          await _communityService.fetchCommunityScreenData(categoryId!);

      if (response.success && response.data != null) {
        final subCategories =
            response.data!['subCategories'] as List<Map<String, dynamic>>;

        print('🔍 CommunityForum - Raw subcategories: ${subCategories.length}');

        if (subCategories.isNotEmpty) {
          this.subCategories.assignAll(subCategories);
          print(
              '✅ CommunityForum - Subcategories loaded: ${this.subCategories.length}');
        } else {
          print('⚠️ CommunityForum - No subcategories found for this category');
          print('📋 CommunityForum - Category Name: $categoryName');
          print('📋 CommunityForum - Category ID: $categoryId');

          // Show helpful message
          Get.snackbar(
            'No Communities',
            'No community subcategories are available for "$categoryName" yet. They will be added soon!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
            icon: Icon(Icons.info_outline, color: Colors.white),
          );
        }
      } else {
        print(
            '❌ CommunityForum - Failed to load subcategories: ${response.message}');
        _showConnectivityError(response.message);
      }
    } catch (e) {
      print('❌ CommunityForum - Community data error: $e');

      // Handle different types of errors
      String errorMessage = e.toString();
      if (errorMessage.contains('SocketException') ||
          errorMessage.contains('NetworkException')) {
        _showConnectivityError('Network connection failed');
      } else if (errorMessage.contains('TimeoutException')) {
        _showConnectivityError('Request timeout - server not responding');
      } else if (errorMessage.contains('FormatException')) {
        _showConnectivityError('Server returned invalid data');
      } else {
        _showConnectivityError('Internal server error');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _showNoDataMessage() {
    Get.snackbar(
      'Info',
      'No community content available for this category',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );
  }

  void _showConnectivityError(String message) {
    // Determine error type based on message
    String errorTitle;
    String errorMessage;
    IconData errorIcon;

    if (message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('connection') ||
        message.toLowerCase().contains('timeout')) {
      errorTitle = 'Network Error';
      errorMessage =
          'Unable to connect to server. Please check your internet connection and try again.';
      errorIcon = Icons.wifi_off;
    } else if (message.toLowerCase().contains('server') ||
        message.toLowerCase().contains('internal server')) {
      errorTitle = 'Server Error';
      errorMessage =
          'Server is temporarily unavailable. Please try again later.';
      errorIcon = Icons.error_outline;
    } else if (message.toLowerCase().contains('not found')) {
      errorTitle = 'Not Found';
      errorMessage =
          'Requested content not found. Please check your connection.';
      errorIcon = Icons.search_off;
    } else {
      errorTitle = 'Connection Error';
      errorMessage =
          'Unable to load content. Please check your internet connection and try again.';
      errorIcon = Icons.wifi_off;
    }

    Get.snackbar(
      errorTitle,
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 5),
      icon: Icon(errorIcon, color: Colors.white),
      shouldIconPulse: true,
    );
  }

  // Load default community data (when no specific category is selected)
  Future<void> loadDefaultCommunityData() async {
    try {
      isLoading.value = true;
      print('🚀 CommunityForum - Loading default community data');

      // Try to get main categories first
      final mainCategoriesResponse =
          await _communityService.getMainCategories();

      if (mainCategoriesResponse.success &&
          mainCategoriesResponse.data != null) {
        final mainCategoriesList = mainCategoriesResponse
            .data!['mainCategories'] as List<Map<String, dynamic>>;

        if (mainCategoriesList.isNotEmpty) {
          // Load subcategories for ALL main categories (not just the first one)
          print(
              '🚀 CommunityForum - Found ${mainCategoriesList.length} main categories');

          // Try each category until we find one with subcategories
          bool foundSubCategories = false;
          for (var mainCategory in mainCategoriesList) {
            final mainCategoryId = mainCategory['_id']?.toString();
            final mainCategoryName =
                mainCategory['name']?.toString() ?? 'Unknown';

            if (mainCategoryId != null) {
              print('🚀 CommunityForum - Trying category: $mainCategoryName');

              try {
                final subCatResponse = await _communityService
                    .fetchCommunityScreenData(mainCategoryId);

                if (subCatResponse.success && subCatResponse.data != null) {
                  final subs = subCatResponse.data!['subCategories']
                      as List<Map<String, dynamic>>?;

                  if (subs != null && subs.isNotEmpty) {
                    this.subCategories.assignAll(subs);
                    categoryId = mainCategoryId;
                    categoryName = mainCategoryName;
                    foundSubCategories = true;
                    print(
                        '✅ CommunityForum - Found ${subs.length} subcategories in $mainCategoryName');
                    break;
                  }
                }
              } catch (e) {
                print(
                    '⚠️ CommunityForum - Error loading $mainCategoryName: $e');
                continue;
              }
            }
          }

          if (!foundSubCategories) {
            print(
                '⚠️ CommunityForum - No subcategories found in any main category');
            _showNoDataMessage();
          }
        } else {
          print('⚠️ CommunityForum - No main categories found');
          _showNoDataMessage();
        }
      } else {
        print(
            '❌ CommunityForum - Failed to load main categories: ${mainCategoriesResponse.message}');
        _showConnectivityError(mainCategoriesResponse.message);
      }
    } catch (e) {
      print('❌ CommunityForum - Error loading default community data: $e');
      _showConnectivityError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Load forum categories (fallback)
  Future<void> loadForumCategories() async {
    try {
      isLoading.value = true;

      final response = await _forumService.getForumCategories();

      if (response.success && response.data != null) {
        final raw = response.data!['categories'];
        categories.value = raw is List ? raw : [];
        print('✅ Loaded ${categories.length} categories');
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load forum categories: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Load subtopics for a category
  Future<void> loadSubtopics(String categoryId) async {
    try {
      isLoading.value = true;
      selectedCategoryId.value = categoryId;

      final response =
          await _forumService.getSubtopicCommunityForum(categoryId);

      if (response.success && response.data != null) {
        final raw = response.data!['subtopics'];
        subtopics.value = raw is List ? raw : [];
        print(
            '✅ Loaded ${subtopics.length} subtopics for category: $categoryId');
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

  // Load rooms for a subtopic
  Future<void> loadRooms(String subtopicId) async {
    try {
      isLoading.value = true;
      selectedSubtopicId.value = subtopicId;

      final response =
          await _forumService.getForumGroupsForSubtopic(subtopicId);

      if (response.success && response.data != null) {
        final raw = response.data!['rooms'];
        rooms.value = raw is List ? raw : [];
        print('✅ Loaded ${rooms.length} rooms for subtopic: $subtopicId');
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load rooms: ${e.toString()}');
      print('❌ Load rooms error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Post message in a room
  Future<void> postMessage(String roomId, String message) async {
    try {
      isLoading.value = true;

      final response = await _forumService.postMessageInCommunity(
          roomId: roomId, text: message);

      if (response.success) {
        Get.snackbar('Success', 'Message posted successfully');

        // Reload messages
        loadMessages(roomId);
      } else {
        Get.snackbar('Error', response.message);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to post message: ${e.toString()}');
      print('❌ Post message error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load messages for a room
  Future<void> loadMessages(String roomId) async {
    try {
      isLoading.value = true;
      selectedRoomId.value = roomId;

      messages.value = [];
      print(" Loading messages for room: $roomId");
    } catch (e) {
      Get.snackbar('Error', 'Failed to load messages: ${e.toString()}');
      print('❌ Load messages error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Navigate to room
  void navigateToRoom(String roomId) {
    Get.toNamed(Routes.MESSAGE_SCREEN, arguments: {'roomId': roomId});
  }

  // Refresh community data
  Future<void> refreshCommunityData() async {
    print('🔄 CommunityForum - Refreshing community data...');

    // Clear cache to force fresh data fetch
    try {
      _communityService.clearCache();
    } catch (e) {
      print('⚠️ CommunityForum - Error clearing cache: $e');
    }

    // Reload data based on current state
    if (categoryId != null) {
      await loadCommunityData();
    } else {
      await loadDefaultCommunityData();
    }
  }

  // Load community data for a specific main category ID
  Future<void> loadCommunityDataForCategory(String mainCategoryId) async {
    try {
      isLoading.value = true;
      print(
          '🚀 CommunityForum - Loading community data for category: $mainCategoryId');

      // Fetch comprehensive community screen data
      final response =
          await _communityService.fetchCommunityScreenData(mainCategoryId);

      if (response.success && response.data != null) {
        final data = response.data!;
        final subCategories =
            data['subCategories'] as List<Map<String, dynamic>>;
        final mainCategory = data['mainCategory'] as Map<String, dynamic>?;
        final metadata = data['metadata'] as Map<String, dynamic>?;

        print('🔍 CommunityForum - Community screen data loaded:');
        print('  - Main Category: ${mainCategory?['name'] ?? 'Unknown'}');
        print('  - Subcategories: ${subCategories.length}');
        print('  - Last Updated: ${metadata?['lastUpdated'] ?? 'Unknown'}');

        if (subCategories.isNotEmpty) {
          this.subCategories.assignAll(subCategories);
          print(
              '✅ CommunityForum - Community data loaded successfully: ${this.subCategories.length} subcategories');
        } else {
          print('⚠️ CommunityForum - No subcategories found in community data');
          Get.snackbar(
            'Info',
            'No community categories available',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        }
      } else {
        print(
            '❌ CommunityForum - Failed to load community screen data: ${response.message}');
        Get.snackbar(
          'Error',
          'Failed to load community data: ${response.message}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ CommunityForum - Community screen data error: $e');

      // Handle different types of errors
      String errorMessage = e.toString();
      if (errorMessage.contains('SocketException') ||
          errorMessage.contains('NetworkException')) {
        Get.snackbar(
          'Network Error',
          'Please check your internet connection',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } else if (errorMessage.contains('TimeoutException')) {
        Get.snackbar(
          'Timeout',
          'Server is taking too long to respond',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to load community data',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
