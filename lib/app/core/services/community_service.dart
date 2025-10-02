import 'package:get/get.dart';
import 'package:vropay_final/app/core/api/api_constant.dart';
import 'package:vropay_final/app/core/models/api_response.dart';
import 'package:vropay_final/app/core/network/api_client.dart';
import 'package:vropay_final/app/core/network/api_exception.dart';

class CommunityService extends GetxService {
  final ApiClient _apiClient = ApiClient();
  final RxBool isLoading = false.obs;

  // Cache for better performance
  final Map<String, Map<String, dynamic>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry =
      Duration(minutes: 5); // Cache for 5 minutes

  // Get main categories for community
  Future<ApiResponse<Map<String, dynamic>>> getMainCategories() async {
    try {
      isLoading.value = true;
      print('🚀 CommunityService - Getting main categories');

      final res = await _apiClient.get(ApiConstants.learnMainCategories);
      print('✅ CommunityService - Main categories response: ${res.data}');

      final data = _unwrap(res.data);
      print('🔍 CommunityService - Unwrapped main categories data: $data');

      final mainCategories = _extractMainCategories(data);
      print(
          '📋 CommunityService - Extracted main categories: ${mainCategories.length}');

      return ApiResponse.success({
        'mainCategories': mainCategories,
      });
    } catch (e) {
      print('❌ CommunityService - Main categories error: $e');
      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Get subcategories for a main category (using your backend endpoint)
  Future<ApiResponse<Map<String, dynamic>>> getSubCategories(
      String mainCategoryId) async {
    try {
      // Check cache first
      if (_isCacheValid(mainCategoryId)) {
        print('🚀 CommunityService - Using cached data for: $mainCategoryId');
        return ApiResponse.success(_cache[mainCategoryId]!);
      }

      isLoading.value = true;
      print(
          '🚀 CommunityService - Getting subcategories for mainCategoryId: $mainCategoryId');

      // Use your backend endpoint - matches your backend: /api/main-category/{mainCategoryId}
      final res =
          await _apiClient.get(ApiConstants.learnSubCategories(mainCategoryId));
      print('✅ CommunityService - Subcategories response: ${res.data}');

      final data = _unwrap(res.data);
      print('🔍 CommunityService - Unwrapped subcategories data: $data');

      // Your backend returns { success: true, data: mainCategory.subCategorys }
      List<Map<String, dynamic>> subCategories = [];

      if (data is List) {
        subCategories = data.whereType<Map<String, dynamic>>().toList();

        // Add parent main category ID to each subcategory for easy reference
        for (var subcategory in subCategories) {
          subcategory['parentMainCategoryId'] = mainCategoryId;
        }
      } else if (data is Map<String, dynamic>) {
        // Handle case where data might be wrapped in an object
        final subCategorys = data['subCategorys'] as List<dynamic>? ?? [];
        subCategories = subCategorys.whereType<Map<String, dynamic>>().toList();

        // Add parent main category ID to each subcategory for easy reference
        for (var subcategory in subCategories) {
          subcategory['parentMainCategoryId'] = mainCategoryId;
        }
      }

      print(
          '📋 CommunityService - Parsed subcategories: ${subCategories.length}');

      final result = {
        'mainCategory': {'_id': mainCategoryId},
        'subCategories': subCategories,
      };

      // Update cache
      _updateCache(mainCategoryId, result);

      return ApiResponse.success(result);
    } catch (e) {
      print('❌ CommunityService - Subcategories error: $e');
      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Get main category by ID
  Future<ApiResponse<Map<String, dynamic>>> getMainCategoryById(
      String id) async {
    try {
      isLoading.value = true;
      print('🚀 CommunityService - Getting main category by ID: $id');

      final res = await _apiClient.get(ApiConstants.learnMainCategoryById(id));
      print('✅ CommunityService - Main category response: ${res.data}');

      final data = _unwrap(res.data);
      print('🔍 CommunityService - Unwrapped main category data: $data');

      if (data is Map<String, dynamic>) {
        return ApiResponse.success(data);
      } else {
        print('⚠️ CommunityService - Main category data is not a map');
        return ApiResponse.error('Invalid main category data format');
      }
    } catch (e) {
      print('❌ CommunityService - Main category by ID error: $e');
      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Get complete community data (main category + subcategories)
  Future<ApiResponse<Map<String, dynamic>>> getCompleteCommunityData(
      String mainCategoryId) async {
    try {
      isLoading.value = true;
      print(
          '🚀 CommunityService - Getting complete community data: $mainCategoryId');

      // Get main category details
      final mainCategoryRes = await getMainCategoryById(mainCategoryId);
      if (!mainCategoryRes.success || mainCategoryRes.data == null) {
        return ApiResponse.error('Failed to load main category data');
      }

      final mainCategoryData = mainCategoryRes.data!;
      print(
          '📋 CommunityService - Main category data loaded: ${mainCategoryData['name']}');

      // Get subcategories for the main category
      final subCategoriesRes = await getSubCategories(mainCategoryId);
      if (!subCategoriesRes.success || subCategoriesRes.data == null) {
        return ApiResponse.error('Failed to load subcategories data');
      }

      final subCategories =
          subCategoriesRes.data!['subCategories'] as List<Map<String, dynamic>>;

      print(
          '📋 CommunityService - Found ${subCategories.length} subcategories');

      final completeData = {
        'mainCategory': mainCategoryData,
        'subCategories': subCategories,
      };

      print(
          '📋 CommunityService - Complete community data loaded with ${subCategories.length} subcategories');

      return ApiResponse.success(completeData);
    } catch (e) {
      print('❌ CommunityService - Complete community data error: $e');
      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch community screen data with comprehensive information
  Future<ApiResponse<Map<String, dynamic>>> fetchCommunityScreenData(
      String mainCategoryId) async {
    try {
      isLoading.value = true;
      print(
          '🚀 CommunityService - Fetching community screen data for: $mainCategoryId');

      // Check cache first
      final cacheKey = 'community_screen_$mainCategoryId';
      if (_isCacheValid(cacheKey)) {
        print('🚀 CommunityService - Using cached community screen data');
        return ApiResponse.success(_cache[cacheKey]!);
      }

      // Fetch main category details
      final mainCategoryResponse = await getMainCategoryById(mainCategoryId);
      if (!mainCategoryResponse.success || mainCategoryResponse.data == null) {
        return ApiResponse.error(
            'Failed to load main category: ${mainCategoryResponse.message}');
      }

      // Fetch subcategories
      final subCategoriesResponse = await getSubCategories(mainCategoryId);
      if (!subCategoriesResponse.success ||
          subCategoriesResponse.data == null) {
        return ApiResponse.error(
            'Failed to load subcategories: ${subCategoriesResponse.message}');
      }

      // Compile comprehensive community screen data
      final communityScreenData = {
        'mainCategory': mainCategoryResponse.data,
        'subCategories': subCategoriesResponse.data!['subCategories'],
        'metadata': {
          'totalSubCategories':
              (subCategoriesResponse.data!['subCategories'] as List).length,
          'lastUpdated': DateTime.now().toIso8601String(),
          'categoryId': mainCategoryId,
        }
      };

      // Update cache
      _updateCache(cacheKey, communityScreenData);

      print('✅ CommunityService - Community screen data fetched successfully');
      return ApiResponse.success(communityScreenData);
    } catch (e) {
      print('❌ CommunityService - Error fetching community screen data: $e');
      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // // Get topics for a specific subcategory
  // Future<ApiResponse<List<Map<String, dynamic>>>> getTopics(
  //     String mainCategoryId, String subCategoryId) async {
  //   try {
  //     isLoading.value = true;
  //     print(
  //         '🚀 CommunityService - Getting topics for mainCategoryId: $mainCategoryId, subCategoryId: $subCategoryId');

  //     final res = await _apiClient.get(
  //         '/api/main-category/$mainCategoryId/sub-category/$subCategoryId/topics');
  //     print('✅ CommunityService - Topics response: ${res.data}');

  //     final data = _unwrap(res.data);
  //     print('🔍 CommunityService - Unwrapped topics data: $data');

  //     List<Map<String, dynamic>> topics = [];
  //     if (data is List) {
  //       topics = data.whereType<Map<String, dynamic>>().toList();
  //     }

  //     print('📋 CommunityService - Parsed topics: ${topics.length}');
  //     return ApiResponse.success(topics);
  //   } catch (e) {
  //     print('❌ CommunityService - Topics error: $e');
  //     throw _handle(e);
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

  // Helper method to unwrap API response data
  dynamic _unwrap(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data')) {
        return data['data'];
      }
      return data;
    }
    return data;
  }

  // Helper method to extract main categories from API response
  List<Map<String, dynamic>> _extractMainCategories(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      if (data.containsKey('mainCategories')) {
        final mainCategories = data['mainCategories'] as List<dynamic>? ?? [];
        return mainCategories.whereType<Map<String, dynamic>>().toList();
      }
      if (data.containsKey('data')) {
        final dataList = data['data'] as List<dynamic>? ?? [];
        return dataList.whereType<Map<String, dynamic>>().toList();
      }
    }
    print('⚠️ CommunityService - Data is not a list, returning empty list');
    return <Map<String, dynamic>>[];
  }

  Exception _handle(dynamic e) {
    if (e is ApiException) {
      // Handle specific HTTP status codes from your backend
      if (e.statusCode == 404) {
        return ApiException('Main category not found', 404);
      } else if (e.statusCode == 500) {
        return ApiException('Internal server error', 500);
      } else if (e.statusCode == 400) {
        return ApiException('Bad request - invalid category ID', 400);
      }
      return e;
    }
    return UnknownException('CommunityService error: ${e.toString()}');
  }

  // Cache helper methods
  bool _isCacheValid(String key) {
    if (!_cache.containsKey(key)) return false;
    if (!_cacheTimestamps.containsKey(key)) return false;

    final timestamp = _cacheTimestamps[key]!;
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  void _updateCache(String key, Map<String, dynamic> data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  // Get topics for a specific subcategory
  Future<ApiResponse<List<Map<String, dynamic>>>> getTopics(
      String mainCategoryId, String subCategoryId) async {
    try {
      isLoading.value = true;
      print(
          '🚀 CommunityService - Getting topics for mainCategoryId: $mainCategoryId, subCategoryId: $subCategoryId');

      final res = await _apiClient.get(
          '/api/main-category/$mainCategoryId/sub-category/$subCategoryId/topics');
      print('✅ CommunityService - Topics response: ${res.data}');

      final data = _unwrap(res.data);
      print('🔍 CommunityService - Unwrapped topics data: $data');

      List<Map<String, dynamic>> topics = [];
      if (data is List) {
        topics = data.whereType<Map<String, dynamic>>().toList();
      }

      print('📋 CommunityService - Parsed topics: ${topics.length}');
      return ApiResponse.success(topics);
    } catch (e) {
      print('❌ CommunityService - Topics error: $e');
      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Clear cache method for memory management
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }
}
