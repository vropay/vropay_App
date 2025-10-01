import 'package:get/get.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:vropay_final/app/core/api/api_constant.dart';
import 'package:vropay_final/app/core/models/api_response.dart';
import 'package:vropay_final/app/core/network/api_client.dart';
import 'package:vropay_final/app/core/network/api_exception.dart';

class LearnService extends GetxService {
  final ApiClient _api = ApiClient();
  final RxBool isLoading = false.obs;

  Future<ApiResponse<Map<String, dynamic>>> getMainCategories() async {
    try {
      isLoading.value = true;
      print(
          '🚀 LearnService - Getting main categories from: ${ApiConstants.learnMainCategories}');
      print(
          '🔗 Full URL: ${ApiConstants.baseUrl}${ApiConstants.learnMainCategories}');

      final res = await _api.get(ApiConstants.learnMainCategories);
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

      final res = await _api.get(ApiConstants.learnMainCategoryById(id));
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
          await _api.get(ApiConstants.learnSubCategories(mainCategoryId));
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
          .get(ApiConstants.learnTopics(mainCategoryId, subCategoryId));
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
      String mainCategoryId, String subCategoryId, String topicId) async {
    try {
      isLoading.value = true;
      print(
          '🚀 LearnService - Getting entries for mainId: $mainCategoryId, subId: $subCategoryId, topicId: $topicId');

      final url =
          ApiConstants.learnEntries(mainCategoryId, subCategoryId, topicId);
      print('🌐 LearnService - API URL: $url');

      final res = await _api.get(url);
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

      final res = await _api.get(ApiConstants.learnEntryContent(entryId));
      print('✅ LearnService - Entry content response: ${res.data}');

      final data = _unwrap(res.data);
      return ApiResponse.success(data);
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

      final res = await _api.get(ApiConstants.learnContentWithDetails(
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

  // Search content within a subcategory
  Future<ApiResponse<Map<String, dynamic>>> searchContentInSubCategory(
      String subCategoryId, String searchQuery) async {
    try {
      isLoading.value = true;
      print(
          '🚀 LearnService - Searching content in subcategory: $subCategoryId, searchQuery: $searchQuery');

      final res = await _api
          .get(ApiConstants.learnSearchContent(subCategoryId, searchQuery));

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

      final res = await _api.get(ApiConstants.learnRelatedContent(entryId));
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
}
