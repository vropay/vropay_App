import 'package:get/get.dart';
import 'package:vropay_final/app/core/api/api_constant.dart';
import 'package:vropay_final/app/core/models/api_response.dart';
import 'package:vropay_final/app/core/models/user_model.dart';
import 'package:vropay_final/app/core/network/api_client.dart';
import 'package:vropay_final/app/core/network/api_exception.dart';

class UserService extends GetxService {
  final ApiClient _apiClient = ApiClient();

  // Update user profile (first onboarding screen)
  Future<ApiResponse<UserModel>> updateUserProfile({
    required String firstName,
    required String lastName,
    required String gender,
    required String profession,
  }) async {
    try {
      final response = await _apiClient.put(ApiConstant.userProfile, data: {
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'profession': profession,
      });

      return ApiResponse.fromJson(
        response.data,
        (data) => UserModel.fromJson(data),
      );
    } catch (e) {
      throw _handleUserError(e);
    }
  }

  // Update user preferences (interests)
  Future<ApiResponse<UserModel>> updateUserInterests({
    required List<String> selectedTopics,
  }) async {
    try {
      final response = await _apiClient.put(ApiConstant.userPreferences, data: {
        'selectedTopics': selectedTopics,
      });

      return ApiResponse.fromJson(
          response.data, (data) => UserModel.fromJson(data));
    } catch (e) {
      throw _handleUserError(e);
    }
  }

  // Update difficulty level
  Future<ApiResponse<UserModel>> updateDifficultyLevel(
      {required String difficultyLevel}) async {
    try {
      final response = await _apiClient.put(ApiConstant.userPreferences,
          data: {'difficultyLevel': difficultyLevel});

      return ApiResponse.fromJson(
          response.data, (data) => UserModel.fromJson(data));
    } catch (e) {
      throw _handleUserError(e);
    }
  }

  // Update community access
  Future<ApiResponse<UserModel>> updateCommunityAccess(
      {required String communityAccess}) async {
    try {
      final response = await _apiClient.put(ApiConstant.userPreferences, data: {
        'communityAccess': communityAccess,
      });

      return ApiResponse.fromJson(
          response.data, (data) => UserModel.fromJson(data));
    } catch (e) {
      throw _handleUserError(e);
    }
  }

  // Update notification preferences
  Future<ApiResponse<UserModel>> updateNotificationPreferences(
      {required bool notificationsEnabled}) async {
    try {
      final response = await _apiClient.put(ApiConstant.userPreferences, data: {
        'notificationsEnabled': notificationsEnabled,
      });

      return ApiResponse.fromJson(
          response.data, (data) => UserModel.fromJson(data));
    } catch (e) {
      throw _handleUserError(e);
    }
  }

  // Complete user update
  Future<ApiResponse<UserModel>> completeUserUpdate({
    required String firstName,
    required String lastName,
    required String gender,
    required String profession,
    required String mobile,
    required List<String> selectedTopics,
    required String difficultyLevel,
    required String communityAccess,
    required bool notificationsEnabled,
  }) async {
    try {
      final response = await _apiClient.patch(ApiConstant.updateUser, data: {
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'profession': profession,
        'mobile': mobile,
        'selectedTopics': selectedTopics,
        'difficultyLevel': difficultyLevel,
        'communityAccess': communityAccess,
        'notificationEnabled': notificationsEnabled,
      });
      return ApiResponse.fromJson(
          response.data, (data) => UserModel.fromJson(data));
    } catch (e) {
      throw _handleUserError(e);
    }
  }

  // Handle user errors
  Exception _handleUserError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    return UnknownException('User operation failed: ${error.toString()}');
  }
}
