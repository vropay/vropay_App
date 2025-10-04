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
}
