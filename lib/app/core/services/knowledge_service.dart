import 'package:get/get.dart';
import 'package:vropay_final/app/core/api/api_constant.dart';
import 'package:vropay_final/app/core/models/api_response.dart';
import 'package:vropay_final/app/core/network/api_client.dart';
import 'package:vropay_final/app/core/network/api_exception.dart';

class KnowledgeService extends GetxService {
  final ApiClient _apiClient = ApiClient();
  final RxBool isLoading = false.obs;
  final RxList<dynamic> topics = <dynamic>[].obs;

  // Get knowledge center topics/subtopics
  Future<ApiResponse<Map<String, dynamic>>> getKnowledgeCenter() async {
    try {
      isLoading.value = true;
      print('🚀 Getting knowledge center topics/subtopics');

      final response = await _apiClient.get(ApiConstants.learnMainCategories);

      print('✅ Knowledge center response: ${response.data}');

      // Hydrate observable topics for UI widgets (e.g., InterestSelectionDialog)
      try {
        final dynamic root = response.data;
        final dynamic data = root is Map<String, dynamic> ? root['data'] : null;
        final dynamic t =
            (data is Map<String, dynamic>) ? data['topics'] : null;
        if (t is List) {
          topics.value = t;
        }
      } catch (_) {}

      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Knowledge center error: $e');
      throw _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Convenience: Featured topics list for HomeController
  Future<List<Map<String, dynamic>>> getFeaturedTopics() async {
    final resp = await getKnowledgeCenter();
    if (resp.success && resp.data != null) {
      final data = resp.data!;
      final dynamic featured = data['featured'] ?? data['topics'];
      if (featured is List) {
        return List<Map<String, dynamic>>.from(featured);
      }
    }
    return <Map<String, dynamic>>[];
  }

  // Convenience: Recent topics list for HomeController
  Future<List<Map<String, dynamic>>> getRecentTopics() async {
    final resp = await getKnowledgeCenter();
    if (resp.success && resp.data != null) {
      final data = resp.data!;
      final dynamic recent = data['recent'] ?? data['topics'];
      if (recent is List) {
        return List<Map<String, dynamic>>.from(recent);
      }
    }
    return <Map<String, dynamic>>[];
  }

  // Get content for subtopic
  Future<ApiResponse<Map<String, dynamic>>> getSubTopicContents(
      String subtopicId) async {
    try {
      isLoading.value = true;
      print('🚀 Getting content for subtopic: $subtopicId');

      final response = await _apiClient
          .get('${ApiConstants.subtopicContents}/$subtopicId/contents');

      print('✅ Content for subtopic response: ${response.data}');

      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Content for subtopic error: $e');
      throw _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Get particular content
  Future<ApiResponse<Map<String, dynamic>>> getContentDetails(
      String contentId) async {
    try {
      isLoading.value = true;
      print('🚀 Getting particular content: $contentId');

      final response =
          await _apiClient.get('${ApiConstants.contentDetails}/$contentId');

      print('✅ Particular content response: ${response.data}');

      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Particular content error: $e');
      throw _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    return UnknownException('Knowledge Service error: ${error.toString()}');
  }
}
