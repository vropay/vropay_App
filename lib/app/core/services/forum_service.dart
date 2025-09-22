import 'package:get/get.dart';
import 'package:vropay_final/app/core/api/api_constant.dart';
import 'package:vropay_final/app/core/models/api_response.dart';
import 'package:vropay_final/app/core/network/api_client.dart';
import 'package:vropay_final/app/core/network/api_exception.dart';

class ForumService extends GetxService {
  final ApiClient _apiClient = ApiClient();
  final RxBool isLoading = false.obs;

  // Get community forum categories
  Future<ApiResponse<Map<String, dynamic>>> getForumCategories() async {
    try {
      isLoading.value = true;
      print('🚀 Getting community forum categories');

      final response = await _apiClient.get(ApiConstants.forumCategories);

      print('✅ Community forum categories response: ${response.data}');

      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Community forum categories error: $e');
      throw _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Get subtopic community forum
  Future<ApiResponse<Map<String, dynamic>>> getSubtopicCommunityForum(
      String categoryId) async {
    try {
      isLoading.value = true;
      print('🚀 Getting subtopic community forum: $categoryId');
      final response = await _apiClient
          .get('${ApiConstants.forumSubtopics}/$categoryId/subtopics');
      print('✅ Subtopic community forum response: ${response.data}');

      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Subtopic community forum error: $e');
      throw _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Get forum groups for subtopic
  Future<ApiResponse<Map<String, dynamic>>> getForumGroupsForSubtopic(
      String subtopicId) async {
    try {
      isLoading.value = true;
      print('🚀 Getting forum groups for subtopic: $subtopicId');

      final response =
          await _apiClient.get('${ApiConstants.forumRooms}/$subtopicId/room');

      print('✅ Forum groups for subtopic response: ${response.data}');

      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Forum groups for subtopic error: $e');
      throw _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Post message in community
  Future<ApiResponse<Map<String, dynamic>>> postMessageInCommunity({
    required String roomId,
    required String text,
  }) async {
    try {
      isLoading.value = true;
      print('🚀 Posting message in community: $roomId');

      final response = await _apiClient
          .post('${ApiConstants.forumMessages}/$roomId/messages', data: {
        'text': text,
      });

      print('✅ post message response: ${response.data}');

      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      print('❌ post message error: $e');
      throw _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    return UnknownException('Forum service error: ${error.toString()}');
  }
}
