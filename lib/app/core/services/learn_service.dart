import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:vropay_final/app/core/api/api_constant.dart';
import 'package:vropay_final/app/core/models/api_response.dart';
import 'package:vropay_final/app/core/network/api_client.dart';
import 'package:vropay_final/app/core/network/api_exception.dart';

class LearnService extends GetxService {
  final ApiClient _api = ApiClient();
  final GetStorage _storage = GetStorage();
  final RxBool isLoading = false.obs;

  Future<ApiResponse<Map<String, dynamic>>> getMainCategories() async {
    try {
      isLoading.value = true;
      print(
          '🚀 LearnService - Getting main categories from: ${ApiConstant.learnMainCategories}');
      print(
          '🔗 Full URL: ${ApiConstant.baseUrl}${ApiConstant.learnMainCategories}');

      final res = await _api.get(ApiConstant.learnMainCategories);
      print('✅ LearnService - Raw response: ${res.data}');
      print('✅ LearnService - Response status: ${res.statusCode}');

      final data = _unwrap(res.data);
      print('🔍 LearnService - Unwrapped data: $data');

      final list = _asListOfMap(data);
      print('📋 LearnService - Parsed list length: ${list.length}');

      return ApiResponse.success({'items': list});
    } catch (e) {
      print('❌ LearnService - Error: $e');
      print('❌ LearnService - Error type: ${e.runtimeType}');

      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getMainCategoryById(
      String id) async {
    try {
      isLoading.value = true;
      print('🚀 LearnService - Getting main category by ID: $id');

      final res = await _api.get(ApiConstant.learnMainCategoryById(id));
      print('✅ LearnService - Category response: ${res.data}');

      final data = _unwrap(res.data);
      return ApiResponse.success(data);
    } catch (e) {
      print('❌ LearnService - Category error: $e');

      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getSubCategories(
      String mainCategoryId) async {
    try {
      isLoading.value = true;
      print(
          '🚀 LearnService - Getting subcategories for mainCategoryId: $mainCategoryId');

      final res =
          await _api.get(ApiConstant.learnSubCategories(mainCategoryId));
      print('✅ LearnService - Subcategories response: ${res.data}');

      final data = _unwrap(res.data);
      final list = _asListOfMap(data);
      print('📋 LearnService - Parsed subcategories: ${list.length}');

      // Add parent main category ID to each subcategory for easy reference
      for (var subcategory in list) {
        subcategory['parentMainCategoryId'] = mainCategoryId;
      }

      return ApiResponse.success({'items': list});
    } catch (e) {
      print('❌ LearnService - Subcategories error: $e');
      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Get topics for a subcategory
  Future<ApiResponse<Map<String, dynamic>>> getTopics(
      String mainCategoryId, String subCategoryId) async {
    try {
      isLoading.value = true;
      print(
          '🚀 LearnService - Getting topics for mainId: $mainCategoryId, subId: $subCategoryId');

      final res = await _api
          .get(ApiConstant.learnTopics(mainCategoryId, subCategoryId));
      print('✅ LearnService - Topics response: ${res.data}');

      final data = _unwrap(res.data);
      final list = _asListOfMap(data);
      print('📋 LearnService - Parsed topics: ${list.length}');

      // Add parent IDs to each topic for easy reference
      for (var topic in list) {
        topic['parentMainCategoryId'] = mainCategoryId;
        topic['parentSubCategoryId'] = subCategoryId;
      }

      return ApiResponse.success({'items': list});
    } catch (e) {
      print('❌ LearnService - Topics error: $e');
      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Get entries for a topic
  Future<ApiResponse<Map<String, dynamic>>> getEntries(
      String mainCategoryId, String subCategoryId, String topicId,
      {String? dateFilter}) async {
    try {
      isLoading.value = true;
      print(
          '🚀 LearnService - Getting entries for mainId: $mainCategoryId, subId: $subCategoryId, topicId: $topicId');

      final url =
          ApiConstant.learnEntries(mainCategoryId, subCategoryId, topicId);
      print('🌐 LearnService - API URL: $url');

      // Prepare query parameters for date filtering
      Map<String, String> queryParams = {};
      print('📅 LearnService - Received dateFilter: $dateFilter');

      if (dateFilter != null && dateFilter != 'All') {
        final dateRange = _getDateRange(dateFilter);
        print('📅 LearnService - Calculated dateRange: $dateRange');

        if (dateRange != null) {
          queryParams['startDate'] = dateRange['start']!;
          queryParams['endDate'] = dateRange['end']!;
          print('📅 LearnService - Query params: $queryParams');
          print(
              '📅 LearnService - Date range: ${dateRange['start']} to ${dateRange['end']}');
        } else {
          print('❌ LearnService - Date range calculation returned null');
        }
      } else {
        print(
            '📅 LearnService - No date filtering applied (filter: $dateFilter)');
      }

      print('📅 LearnService - Final query params: $queryParams');
      final res = await _api.get(url, queryParameters: queryParams);
      print('✅ LearnService - Entries response: ${res.data}');

      final data = _unwrap(res.data);
      print(
          '🔍 LearnService - Unwrapped entries data: $data (type: ${data.runtimeType})');

      // Backend returns entries directly as array
      List<Map<String, dynamic>> list = [];
      if (data is List) {
        list = data.cast<Map<String, dynamic>>();
        print(
            '✅ LearnService - Successfully cast entries to list: ${list.length}');
      } else {
        print('❌ LearnService - Data is not a list: $data');
      }

      print('📋 LearnService - Final parsed entries: ${list.length}');

      // Add parent IDs to each entry for easy reference and convert HTML to text
      for (var entry in list) {
        entry['parentMainCategoryId'] = mainCategoryId;
        entry['parentSubCategoryId'] = subCategoryId;
        entry['parentTopicId'] = topicId;

        // Convert HTML body to plain text if it exists
        if (entry['body'] != null && entry['body'].toString().isNotEmpty) {
          final originalBody = entry['body'].toString();
          print(
              '🔍 LearnService - Original body content: ${originalBody.substring(0, originalBody.length > 200 ? 200 : originalBody.length)}...');

          entry['body'] = _convertHtmlToText(originalBody);

          if (originalBody != entry['body']) {
            print(
                '🔄 LearnService - Converted HTML body to text for entry: ${entry['title']}');
            print(
                '🔍 LearnService - Converted body: ${entry['body'].toString().substring(0, entry['body'].toString().length > 200 ? 200 : entry['body'].toString().length)}...');
          } else {
            print(
                'ℹ️ LearnService - Body content was already plain text for entry: ${entry['title']}');
          }
        }

        // Also convert title if it contains HTML
        if (entry['title'] != null && entry['title'].toString().isNotEmpty) {
          final originalTitle = entry['title'].toString();
          entry['title'] = _convertHtmlToText(originalTitle);
          if (originalTitle != entry['title']) {
            print(
                '🔄 LearnService - Converted HTML title to text for entry: ${entry['title']}');
          }
        }

        // Ensure all required fields for NewsDetailScreen are present
        // Add fallback values if missing
        entry['thumbnail'] = entry['thumbnail'] ?? entry['image'] ?? '';
        entry['title'] = entry['title'] ?? 'No Title';
        entry['body'] = entry['body'] ?? entry['description'] ?? '';

        // Debug: Log image fields
        if (entry['thumbnail'] != null &&
            entry['thumbnail'].toString().isNotEmpty) {
          print('🖼️ LearnService - Entry thumbnail: ${entry['thumbnail']}');
        }
        if (entry['image'] != null && entry['image'].toString().isNotEmpty) {
          print('🖼️ LearnService - Entry image: ${entry['image']}');
        }

        // Add entry ID for reference if it exists
        if (entry['_id'] != null) {
          entry['entryId'] = entry['_id'];
        }

        // Initialize read status - check if user has read this entry
        // The backend should include readBy array with user IDs
        final readBy = entry['readBy'] as List? ?? [];
        final currentUserId = getCurrentUserId();
        final entryId =
            entry['_id']?.toString() ?? entry['entryId']?.toString();

        bool isRead = false;

        // First check backend readBy data
        if (currentUserId != null && readBy.isNotEmpty) {
          // Check different possible formats for readBy data
          for (var readItem in readBy) {
            if (readItem is Map<String, dynamic>) {
              // Format: {userId: "user_id"}
              final readUserId = readItem['userId']?.toString();
              if (readUserId == currentUserId.toString()) {
                isRead = true;
                break;
              }

              // Format: {user: "user_id"} (alternative format)
              final readUser = readItem['user']?.toString();
              if (readUser == currentUserId.toString()) {
                isRead = true;
                break;
              }
            } else if (readItem is String) {
              // Format: ["user_id", "user_id2"] (direct array of user IDs)
              if (readItem.toString() == currentUserId.toString()) {
                isRead = true;
                break;
              }
            }
          }
        }

        // FALLBACK: Check local storage if backend doesn't have readBy data
        if (!isRead && currentUserId != null && entryId != null) {
          isRead = _isEntryReadLocally(entryId, currentUserId);
          if (isRead) {
            print('💾 LearnService - Entry read status found in LOCAL storage');
          }
        }

        entry['isRead'] = isRead;

        // Debug logging
        print('🔍 LearnService - Entry "${entry['title']}" read status check:');
        print('   - Current User ID: $currentUserId');
        print('   - Entry ID: $entryId');
        print('   - ReadBy data: $readBy');
        print('   - Is Read: $isRead');

        if (isRead) {
          print(
              '📖 LearnService - Entry "${entry['title']}" is already read by user');
        } else {
          print('📰 LearnService - Entry "${entry['title']}" is unread');
        }
      }

      return ApiResponse.success({'items': list});
    } catch (e) {
      print('❌ LearnService - Entries error: $e');
      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Get complete data structure for a main category using the data
  Future<ApiResponse<Map<String, dynamic>>> getCompleteMainCategoryData(
      String mainCategoryId) async {
    try {
      isLoading.value = true;
      print(
          '🚀 LearnService - Getting complete main category data: $mainCategoryId');

      // Get main category details
      final mainCategoryRes = await getMainCategoryById(mainCategoryId);
      if (!mainCategoryRes.success || mainCategoryRes.data == null) {
        return ApiResponse.error('Failed to load main category data');
      }

      final mainCategoryData = mainCategoryRes.data!;
      print(
          '📋 LearnService - Main category data loaded: ${mainCategoryData['name']}');

      // Extract subcategories from the main category data
      final subCategories =
          mainCategoryData['subCategorys'] as List<dynamic>? ?? [];
      print(
          '📋 LearnService - Found ${subCategories.length} subcategories in main category data');

// Process subcategories and add parent IDs
      List<Map<String, dynamic>> processedSubCategories = [];
      for (var subCategory in subCategories) {
        if (subCategory is Map<String, dynamic>) {
          // Add parent main category ID
          subCategory['parentMainCategoryId'] = mainCategoryId;

          // Process topics within this subcategory
          final topics = subCategory['topics'] as List<dynamic>? ?? [];
          List<Map<String, dynamic>> processedTopics = [];

          for (var topic in topics) {
            if (topic is Map<String, dynamic>) {
              // Add parent IDs to topic
              topic['parentMainCategoryId'] = mainCategoryId;
              topic['parentSubCategoryId'] = subCategory['_id'];

              // Process entries within this topic
              final entries = topic['entries'] as List<dynamic>? ?? [];
              List<Map<String, dynamic>> processedEntries = [];

              for (var entry in entries) {
                if (entry is Map<String, dynamic>) {
                  // Add parent IDs to entry
                  entry['parentMainCategoryId'] = mainCategoryId;
                  entry['parentSubCategoryId'] = subCategory['_id'];
                  entry['parentTopicId'] = topic['_id'];
                  processedEntries.add(entry);
                }
              }

              topic['entries'] = processedEntries;
              processedTopics.add(topic);
            }
          }

          subCategory['topics'] = processedTopics;
          processedSubCategories.add(subCategory);
        }
      }

      final completeData = {
        'mainCategory': mainCategoryData,
        'subCategories': processedSubCategories,
      };

      print(
          '📋 LearnService - Complete data loaded with ${subCategories.length} subcategories');

      return ApiResponse.success(completeData);
    } catch (e) {
      print('❌ LearnService - Complete main category data error: $e');
      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Get specific entry content by ID
  Future<ApiResponse<Map<String, dynamic>>> getEntryContent(
      String entryId) async {
    try {
      isLoading.value = true;
      print('🚀 LearnService - Getting entry content by ID: $entryId');

      final res = await _api.get(ApiConstant.learnEntryContent(entryId));
      print('✅ LearnService - Entry content response: ${res.data}');

      final unwrapped = _unwrap(res.data);

      // If backend returned a non-JSON response (e.g., HTML 404 page), _unwrap
      // will return a String. Guard against that and return a clean error so
      // callers don't try to treat a String as a Map and crash.
      if (unwrapped == null) {
        print(
            '⚠️ LearnService - Entry content unwrapped to null for entryId=$entryId');
        return ApiResponse.error('Empty entry content',
            statusCode: res.statusCode);
      }

      if (unwrapped is String) {
        // Log raw body for debugging and return an error result preserving
        // the raw response in the message so callers can log it if needed.
        final raw = unwrapped;
        print(
            '⚠️ LearnService - Entry content is plain text/HTML instead of JSON for entryId=$entryId. Raw body:\n$raw');
        return ApiResponse.error(
            'Non-JSON response from server: ${res.statusCode}',
            statusCode: res.statusCode);
      }

      if (unwrapped is Map<String, dynamic>) {
        return ApiResponse.success(unwrapped);
      }

      // Unexpected type - be defensive
      print(
          '⚠️ LearnService - Entry content returned unexpected type (${unwrapped.runtimeType}) for entryId=$entryId');
      return ApiResponse.error('Invalid entry content format',
          statusCode: res.statusCode);
    } catch (e) {
      print('❌ LearnService - Entry content error: $e');
      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Get content with full details including media, attachments, etc
  Future<ApiResponse<Map<String, dynamic>>> getContentWithDetails(
      String mainCategoryId,
      String subCategoryId,
      String topicId,
      String entryId) async {
    try {
      isLoading.value = true;
      print(
          '🚀 LearnService - Getting content with details for: $mainCategoryId/$subCategoryId/$topicId/$entryId');

      final res = await _api.get(ApiConstant.learnContentWithDetails(
          mainCategoryId, subCategoryId, topicId, entryId));
      print('✅ LearnService - Content with details response: ${res.data}');

      final data = _unwrap(res.data);
      return ApiResponse.success(data);
    } catch (e) {
      print('❌ LearnService - Content with details error: $e');
      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Search subcategories by query
  Future<ApiResponse<Map<String, dynamic>>> searchSubCategories(
      String mainCategoryId, String query) async {
    try {
      isLoading.value = true;
      print(
          '🚀 LearnService - Searching subcategories for mainId: $mainCategoryId, query: $query');

      final res = await _api
          .get(ApiConstant.searchSubCategories(mainCategoryId, query));
      print('✅ LearnService - Subcategory search response: ${res.data}');

      final data = _unwrap(res.data);

      // Backend returns results in 'results' key with pagination
      List<Map<String, dynamic>> list = [];
      if (data is Map<String, dynamic> && data['results'] != null) {
        list = (data['results'] as List).cast<Map<String, dynamic>>();
        print('🔍 LearnService - Found ${list.length} search results');
      }

      return ApiResponse.success({
        'items': list,
        'pagination': data['pagination'],
        'searchQuery': data['searchQuery'],
        'targetMainCategory': data['targetMainCategory']
      });
    } catch (e) {
      print('❌ LearnService - Search subcategories error: $e');
      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Search topics by query
  Future<ApiResponse<Map<String, dynamic>>> searchTopics(
      String mainCategoryId, String query) async {
    try {
      isLoading.value = true;
      print(
          '🚀 LearnService - Searching topics for mainId: $mainCategoryId, query: $query');

      final res =
          await _api.get(ApiConstant.searchTopics(mainCategoryId, query));
      print('✅ LearnService - Topic search response: ${res.data}');

      final data = _unwrap(res.data);

      // Backend returns results in 'results' key with pagination
      List<Map<String, dynamic>> list = [];
      if (data is Map<String, dynamic> && data['results'] != null) {
        list = (data['results'] as List).cast<Map<String, dynamic>>();
        print('🔍 LearnService - Found ${list.length} topic search results');
      }

      return ApiResponse.success({
        'items': list,
        'pagination': data['pagination'],
        'searchQuery': data['searchQuery'],
        'targetMainCategory': data['targetMainCategory']
      });
    } catch (e) {
      print('❌ LearnService - Search topics error: $e');
      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Search content within a subcategory
  Future<ApiResponse<Map<String, dynamic>>> searchContentInSubCategory(
      String subCategoryId, String searchQuery) async {
    try {
      isLoading.value = true;
      print(
          '🚀 LearnService - Searching content in subcategory: $subCategoryId, searchQuery: $searchQuery');

      final res = await _api
          .get(ApiConstant.learnSearchContent(subCategoryId, searchQuery));

      final data = _unwrap(res.data);
      final list = _asListOfMap(data);

      return ApiResponse.success({'items': list});
    } catch (e) {
      print('❌ LearnService - Search content in subcategory error: $e');
      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Get releated content for an entry
  Future<ApiResponse<Map<String, dynamic>>> getRelatedContent(
      String entryId) async {
    try {
      isLoading.value = true;
      print('🚀 LearnService - Getting related content for entry: $entryId');

      final res = await _api.get(ApiConstant.learnRelatedContent(entryId));
      print('✅ LearnService - Related content response: ${res.data}');

      final data = _unwrap(res.data);
      final list = _asListOfMap(data);

      return ApiResponse.success({'items': list});
    } catch (e) {
      print('❌ LearnService - Related content error: $e');
      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Search entries within a specific topic
  Future<ApiResponse<Map<String, dynamic>>> searchEntriesInTopic(
      String mainCategoryId, String subCategoryId, String topicId, String query,
      {int page = 1, int limit = 10}) async {
    try {
      isLoading.value = true;
      print(
          '🚀 LearnService - Searching entries in topic: $topicId, query: $query');

      final url = ApiConstant.learnSearchInTopic(
          mainCategoryId, subCategoryId, topicId);
      print('🌐 LearnService - Search API URL: $url');

      final res = await _api.get(url, queryParameters: {
        'query': query,
        'page': page.toString(),
        'limit': limit.toString(),
      });

      // Extra debug information to help diagnose missing results
      try {
        print('✅ LearnService - Search response status: ${res.statusCode}');
        print('🔗 LearnService - Full request URI: ${res.requestOptions.uri}');
        print(
            '📦 LearnService - Raw response data (type: ${res.data.runtimeType}): ${res.data}');
      } catch (e) {
        print('⚠️ LearnService - Failed to print detailed response info: $e');
      }

      final data = _unwrap(res.data);

      // If server reports the main category is not found, try a subcategory-level search
      try {
        final status = res.statusCode ?? 0;
        final raw = res.data;
        final serverMessage =
            raw is Map ? (raw['message']?.toString() ?? '') : '';

        if (status == 404 ||
            serverMessage.toLowerCase().contains('main category not found')) {
          print(
              '🔁 LearnService - Topic search returned 404/Main category not found. Falling back to subcategory search for subCategoryId=$subCategoryId');
          try {
            final subResp =
                await searchContentInSubCategory(subCategoryId, query);
            if (subResp.success && subResp.data != null) {
              final items =
                  subResp.data!['items'] as List<Map<String, dynamic>>? ?? [];
              // Build a response-shaped map similar to topic search
              final shaped = {
                'results': items,
                'pagination': {},
                'searchQuery': query,
                'targetMainCategory': null,
              };
              print(
                  '✅ LearnService - Subcategory fallback returned ${items.length} items');
              return ApiResponse.success(shaped);
            } else {
              print('⚠️ LearnService - Subcategory fallback returned no data');
            }
          } catch (e) {
            print('⚠️ LearnService - Subcategory fallback failed: $e');
          }
        }
      } catch (e) {
        print(
            '⚠️ LearnService - Error while evaluating fallback condition: $e');
      }

      // The backend returns the search results with pagination info
      if (data is Map<String, dynamic>) {
        // Process search results to convert HTML to text
        if (data['results'] is List) {
          final results = data['results'] as List;
          for (var entry in results) {
            if (entry is Map<String, dynamic>) {
              // Convert HTML content to plain text
              if (entry['body'] != null &&
                  entry['body'].toString().isNotEmpty) {
                entry['body'] = _convertHtmlToText(entry['body'].toString());
              }
              if (entry['title'] != null &&
                  entry['title'].toString().isNotEmpty) {
                entry['title'] = _convertHtmlToText(entry['title'].toString());
              }
              // Also convert highlighted title if it exists
              if (entry['highlightedTitle'] != null &&
                  entry['highlightedTitle'].toString().isNotEmpty) {
                entry['highlightedTitle'] =
                    _convertHtmlToText(entry['highlightedTitle'].toString());
              }
            }
          }
        }

        // If results exist, return immediately
        if (data['results'] is List && (data['results'] as List).isNotEmpty) {
          return ApiResponse.success(data);
        }

        // Debug: no results found with 'query' parameter. Retry with 'q' to
        // handle backends that expect that parameter name.
        try {
          print(
              '🔁 LearnService - No results with "query" param; retrying using "q" param');
          final res2 = await _api.get(url, queryParameters: {
            'q': query,
            'page': page.toString(),
            'limit': limit.toString(),
          });
          print('✅ LearnService - Retry response status: ${res2.statusCode}');
          print(
              '🔗 LearnService - Retry request URI: ${res2.requestOptions.uri}');
          print(
              '📦 LearnService - Retry raw data (type: ${res2.data.runtimeType}): ${res2.data}');

          final data2 = _unwrap(res2.data);
          if (data2 is Map<String, dynamic> && data2['results'] is List) {
            // Convert any HTML-marked highlights to plain text
            for (var entry in data2['results']) {
              if (entry is Map<String, dynamic>) {
                if (entry['body'] != null &&
                    entry['body'].toString().isNotEmpty) {
                  entry['body'] = _convertHtmlToText(entry['body'].toString());
                }
                if (entry['title'] != null &&
                    entry['title'].toString().isNotEmpty) {
                  entry['title'] =
                      _convertHtmlToText(entry['title'].toString());
                }
                if (entry['highlightedTitle'] != null &&
                    entry['highlightedTitle'].toString().isNotEmpty) {
                  entry['highlightedTitle'] =
                      _convertHtmlToText(entry['highlightedTitle'].toString());
                }
              }
            }

            if ((data2['results'] as List).isNotEmpty) {
              print(
                  '✅ LearnService - Retry with "q" returned ${(data2['results'] as List).length} results');
              return ApiResponse.success(data2);
            } else {
              print(
                  '⚠️ LearnService - Retry with "q" also returned zero results');
            }
          }
        } catch (e) {
          print('⚠️ LearnService - Retry with "q" failed: $e');
        }

        // If still here, return original (empty) data to caller
        return ApiResponse.success(data);
      } else {
        return ApiResponse.error('Invalid search response format');
      }
    } catch (e) {
      print('❌ LearnService - Search entries in topic error: $e');
      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Cross-category search across main categories
  Future<ApiResponse<Map<String, dynamic>>> searchCrossCategory(String query,
      {String? targetMainCategoryId, int page = 1, int limit = 10}) async {
    try {
      isLoading.value = true;
      print('🚀 LearnService - Cross-category search for: $query');

      final url = ApiConstant.crossCategorySearch(query,
          targetMainCategoryId: targetMainCategoryId, page: page, limit: limit);
      print('🌐 LearnService - Cross-category API URL: $url');

      final res = await _api.get(url);

      // Extra debug logging for cross-category
      try {
        print(
            '✅ LearnService - Cross-category response status: ${res.statusCode}');
        print(
            '🔗 LearnService - Cross-category full request URI: ${res.requestOptions.uri}');
        print(
            '📦 LearnService - Cross-category raw data (type: ${res.data.runtimeType}): ${res.data}');
      } catch (e) {
        print(
            '⚠️ LearnService - Failed to print cross-category response info: $e');
      }

      final data = _unwrap(res.data);

      if (data is Map<String, dynamic>) {
        // Convert any HTML-marked highlights to plain text
        if (data['results'] is List) {
          for (var item in data['results']) {
            if (item is Map<String, dynamic>) {
              if (item['title'] != null &&
                  item['title'].toString().isNotEmpty) {
                item['title'] = _convertHtmlToText(item['title'].toString());
              }
              if (item['highlightedTitle'] != null &&
                  item['highlightedTitle'].toString().isNotEmpty) {
                item['highlightedTitle'] =
                    _convertHtmlToText(item['highlightedTitle'].toString());
              }
              if (item['body'] != null && item['body'].toString().isNotEmpty) {
                item['body'] = _convertHtmlToText(item['body'].toString());
              }
            }
          }
        }

        return ApiResponse.success(data);
      }

      return ApiResponse.error('Invalid cross-category response');
    } catch (e) {
      print('❌ LearnService - Cross-category search error: $e');
      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Helpers to tolerate {success, data} and raw arrays
  dynamic _unwrap(dynamic raw) {
    print(
        '🔍 LearnService - Unwrapping raw data: $raw (type: ${raw.runtimeType})');

    if (raw is Map<String, dynamic>) {
      final data = raw['data'] ?? raw;
      print('🔍 LearnService - Extracted data: $data');
      return data;
    }
    return raw;
  }

  List<Map<String, dynamic>> _asListOfMap(dynamic data) {
    print(
        '🔍 LearnService - Converting to list: $data (type: ${data.runtimeType})');

    if (data is List) {
      final list = List<Map<String, dynamic>>.from(
        data.where((e) => e is Map<String, dynamic>),
      );
      print('📋 LearnService - Converted list: $list');
      return list;
    }
    print('⚠️ LearnService - Data is not a list, returning empty list');

    return <Map<String, dynamic>>[];
  }

  Exception _handle(dynamic e) {
    if (e is ApiException) {
      return e;
    }
    return UnknownException('LearnService error: ${e.toString()}');
  }

  // Get date range based on filter
  Map<String, String>? _getDateRange(String filter) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    switch (filter.toLowerCase()) {
      case 'today':
        // Only today's news (from start of today to end of today)
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'this week':
        // Last 7 days including today (current day + previous 6 days)
        startDate = now.subtract(Duration(days: 6));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'this month':
        // Last 30 days including today (current day + previous 29 days)
        startDate = now.subtract(Duration(days: 29));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      default:
        return null; // No filtering for 'All' or unknown filters
    }

    // Format dates as ISO 8601 strings (UTC)
    return {
      'start': startDate.toUtc().toIso8601String(),
      'end': endDate.toUtc().toIso8601String(),
    };
  }

  // Helper method to convert HTML to plain text
  String _convertHtmlToText(String htmlContent) {
    try {
      // Parse HTML content
      final document = html_parser.parse(htmlContent);

      // Extract text content, preserving line breaks
      final text = document.body?.text ?? '';

      // Clean up extra whitespace and normalize line breaks
      return text
          .replaceAll(
              RegExp(r'\s+'), ' ') // Replace multiple spaces with single space
          .replaceAll(RegExp(r'\n\s*\n'), '\n\n') // Preserve paragraph breaks
          .trim(); // Remove leading/trailing whitespace
    } catch (e) {
      print('⚠️ LearnService - HTML parsing error: $e');
      // Return original content if parsing fails
      return htmlContent;
    }
  }

  // Mark entry as read
  Future<ApiResponse<Map<String, dynamic>>> markEntryAsRead(
      String mainCategoryId,
      String subCategoryId,
      String topicId,
      String entryId) async {
    try {
      isLoading.value = true;
      print('🚀 LearnService - Marking entry as read: $entryId');
      print(
          '🔍 LearnService - Parameters: mainCategoryId=$mainCategoryId, subCategoryId=$subCategoryId, topicId=$topicId, entryId=$entryId');
      print('🔍 LearnService - Current User ID: ${getCurrentUserId()}');

      final url = ApiConstant.markEntryAsRead(
          mainCategoryId, subCategoryId, topicId, entryId);
      print('🌐 LearnService - Mark as read API URL: $url');

      final res = await _api.post(url);
      print('✅ LearnService - Mark as read response status: ${res.statusCode}');
      print('✅ LearnService - Mark as read response data: ${res.data}');

      final data = _unwrap(res.data);

      // Additional validation
      if (res.statusCode == 200 || res.statusCode == 201) {
        print('✅ LearnService - Entry marked as read successfully in backend');

        // Store read status locally as backup
        markEntryReadLocally(entryId, getCurrentUserId()!);
        print(
            '💾 LearnService - Entry marked as read in LOCAL storage as backup');
      } else {
        print('⚠️ LearnService - Unexpected status code: ${res.statusCode}');
      }

      return ApiResponse.success(data);
    } catch (e) {
      print('❌ LearnService - Mark entry as read error: $e');
      throw _handle(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Get current user ID from storage
  String? getCurrentUserId() {
    try {
      final userData = _storage.read('user_data');
      if (userData != null && userData is Map<String, dynamic>) {
        return userData['_id'] ?? userData['id'];
      }
      return null;
    } catch (e) {
      print('❌ LearnService - Error getting current user ID: $e');
      return null;
    }
  }

  // Get continue reading data - last read topic
  Future<ApiResponse<Map<String, dynamic>>> getContinueReading() async {
    try {
      isLoading.value = true;
      print('🚀 LearnService - Getting continue reading data');

      final res = await _api.get(ApiConstant.continueReading);
      print('✅ LearnService - Continue reading response: ${res.data}');

      final data = _unwrap(res.data);

      // Extract topics list from paginated response
      if (data != null && data is Map) {
        final topicsList = data['topics'];

        if (topicsList != null && topicsList is List && topicsList.isNotEmpty) {
          // Get the first (most recent) topic
          final firstTopic = topicsList[0] as Map<String, dynamic>;

          // Prepare last read entry with all required fields
          Map<String, dynamic>? lastReadEntry;
          if (firstTopic['lastReadEntry'] != null) {
            final entry = firstTopic['lastReadEntry'] as Map<String, dynamic>;
            lastReadEntry = {
              '_id': entry['_id']?.toString(),
              'title': entry['title']?.toString() ?? 'No Title',
              'image': entry['image']?.toString() ?? '',
              'thumbnail': entry['image']?.toString() ?? '',
              'body': entry['body']?.toString() ?? '',
              'description': entry['description']?.toString() ?? '',
              'readAt': entry['readAt'],
            };
          }

          // Transform to match expected format
          final transformedData = {
            'topicId': firstTopic['_id']?.toString(),
            'topicName': firstTopic['name']?.toString(),
            'subCategoryId': firstTopic['subCategory']?['_id']?.toString(),
            'mainCategoryId': firstTopic['mainCategory']?['_id']?.toString(),
            'totalEntries': firstTopic['totalEntries'],
            'readEntries': firstTopic['readEntries'],
            'progressPercentage': firstTopic['progressPercentage'],
            'lastReadEntry': lastReadEntry,
            'lastReadAt': firstTopic['lastReadAt'],
          };

          print('📖 LearnService - Continue reading data: $transformedData');
          return ApiResponse.success(transformedData);
        }
      }

      print('⚠️ LearnService - No continue reading data available');
      return ApiResponse.success({});
    } catch (e) {
      print('❌ LearnService - Continue reading error: $e');
      // Return success with empty map instead of throwing, so UI can handle gracefully
      return ApiResponse.success({});
    } finally {
      isLoading.value = false;
    }
  }

  // LOCAL STORAGE METHODS FOR READ STATUS PERSISTENCE
  // These methods ensure read status persists even if backend fails

  /// Store that an entry has been read by a user locally
  void markEntryReadLocally(String entryId, String userId) {
    try {
      final key = 'read_entries_$userId';
      Set<String> readEntries = Set<String>.from(_storage.read(key) ?? []);
      readEntries.add(entryId);
      _storage.write(key, readEntries.toList());

      print('💾 LearnService - Stored read status locally for entry: $entryId');
      print(
          '💾 LearnService - Total local read entries: ${readEntries.length}');
    } catch (e) {
      print('❌ LearnService - Error storing read status locally: $e');
    }
  }

  /// Check if an entry has been read by a user locally
  bool _isEntryReadLocally(String entryId, String userId) {
    try {
      final key = 'read_entries_$userId';
      final readEntries = _storage.read(key);

      if (readEntries != null && readEntries is List) {
        final isRead = readEntries.contains(entryId);
        print('💾 LearnService - Local read check for entry $entryId: $isRead');
        return isRead;
      }

      return false;
    } catch (e) {
      print('❌ LearnService - Error checking local read status: $e');
      return false;
    }
  }

  /// Clear all local read status for a user (useful for logout)
  void clearLocalReadStatus(String userId) {
    try {
      final key = 'read_entries_$userId';
      _storage.remove(key);
      print('🗑️ LearnService - Cleared local read status for user: $userId');
    } catch (e) {
      print('❌ LearnService - Error clearing local read status: $e');
    }
  }
}
