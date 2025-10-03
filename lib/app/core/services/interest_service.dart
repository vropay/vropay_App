import 'package:get/get.dart';
import 'package:vropay_final/app/core/api/api_constant.dart';
import 'package:vropay_final/app/core/models/api_response.dart';
import 'package:vropay_final/app/core/network/api_client.dart';
import 'package:vropay_final/app/core/network/api_exception.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';

class InterestService extends GetxService {
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = Get.find<AuthService>();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxInt memberCount = 0.obs;
  final RxBool hasUserInterest = false.obs;
  final RxString communityAccess = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _apiClient.init();
  }

  // Get member count for an interest
  Future<int> getMemberCount(String interestId) async {
    try {
      print(
          '🔢 [INTEREST SERVICE] Getting member count for interestId: "$interestId"');
      isLoading.value = true;

      final apiUrl = ApiConstant.getInterestUserCount(interestId);
      print('🌐 [INTEREST SERVICE] API URL: $apiUrl');

      final response = await _apiClient.get(apiUrl);
      print('🌐 [INTEREST SERVICE] Response status: ${response.statusCode}');
      print('🌐 [INTEREST SERVICE] Response data: ${response.data}');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(response.data, (data) => data);
        if (apiResponse.success) {
          final count = apiResponse.data['userCount'] ?? 0;
          memberCount.value = count;
          print(
              '✅ [INTEREST SERVICE] Member count retrieved successfully: $count');
          return count;
        } else {
          print(
              '❌ [INTEREST SERVICE] API returned success: false, message: ${apiResponse.message}');
          throw ApiException(apiResponse.message);
        }
      } else {
        print('❌ [INTEREST SERVICE] HTTP Error: ${response.statusCode}');
        throw ApiException('Failed to get member count');
      }
    } catch (e) {
      print('❌ [INTEREST SERVICE] Error getting member count: $e');
      print('❌ [INTEREST SERVICE] Stack trace: ${StackTrace.current}');
      throw ApiException('Failed to get member count: ${e.toString()}');
    } finally {
      isLoading.value = false;
      print('🏁 [INTEREST SERVICE] Loading state set to false');
    }
  }

  /// Resolve interest metadata by id using the user-count endpoint
  /// Returns a map: { 'interestId': string, 'interestName': string, 'userCount': int }
  /// or null if not found (404)
  Future<Map<String, dynamic>?> resolveInterestMeta(String interestId) async {
    try {
      final apiUrl = ApiConstant.getInterestUserCount(interestId);
      final response = await _apiClient.get(apiUrl);

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(response.data, (data) => data);
        if (apiResponse.success) {
          final data = apiResponse.data ?? {};
          return {
            'interestId': data['interestId']?.toString(),
            'interestName': data['interestName']?.toString(),
            'userCount': data['userCount'] ?? 0,
          };
        }
        return null;
      }

      // Not found or other error
      return null;
    } catch (_) {
      return null;
    }
  }

  // Get interest details (name and user count) for an interest
  Future<Map<String, dynamic>> getInterestDetails(String interestId) async {
    try {
      print(
          '📊 [INTEREST SERVICE] Getting interest details for interestId: "$interestId"');
      isLoading.value = true;

      // First, try to get the interest name from the loaded interests
      String interestName = 'Unknown Interest';
      try {
        final interestsResponse = await _authService.getInterests();
        if (interestsResponse['interests'] is List) {
          final interestsList = interestsResponse['interests'] as List;
          for (final interest in interestsList) {
            if (interest is Map<String, dynamic> &&
                interest['_id'] == interestId &&
                interest['name'] != null) {
              interestName = interest['name'].toString();
              print(
                  '📊 [INTEREST SERVICE] Found interest name: "$interestName"');
              break;
            }
          }
        }
      } catch (e) {
        print(
            '⚠️ [INTEREST SERVICE] Could not load interests for name lookup: $e');
      }

      // Then get the user count
      final apiUrl = ApiConstant.getInterestUserCount(interestId);
      print('🌐 [INTEREST SERVICE] API URL: $apiUrl');

      final response = await _apiClient.get(apiUrl);
      print('🌐 [INTEREST SERVICE] Response status: ${response.statusCode}');
      print('🌐 [INTEREST SERVICE] Response data: ${response.data}');

      int userCount = 0;
      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(response.data, (data) => data);
        if (apiResponse.success) {
          userCount = apiResponse.data['userCount'] ?? 0;
        }
      } else if (response.statusCode == 404) {
        print('⚠️ [INTEREST SERVICE] User count not found (404), using 0');
        userCount = 0;
      } else {
        print(
            '⚠️ [INTEREST SERVICE] HTTP Error getting user count: ${response.statusCode}');
        userCount = 0;
      }

      memberCount.value = userCount;

      print('✅ [INTEREST SERVICE] Interest details retrieved successfully:');
      print('   - interestName: "$interestName"');
      print('   - userCount: $userCount');

      return {
        'interestName': interestName,
        'userCount': userCount,
      };
    } catch (e) {
      print('❌ [INTEREST SERVICE] Error getting interest details: $e');
      print('❌ [INTEREST SERVICE] Stack trace: ${StackTrace.current}');

      // Return fallback data
      return {
        'interestName': 'Unknown Interest',
        'userCount': 0,
      };
    } finally {
      isLoading.value = false;
      print('🏁 [INTEREST SERVICE] Loading state set to false');
    }
  }

  // Check if user has selected this interest
  Future<bool> checkUserHasInterest(String userId, String interestId) async {
    try {
      print(
          '🔐 [INTEREST SERVICE] Checking if user $userId has interest $interestId');

      // First check local user data
      final currentUser = _authService.currentUser.value;
      if (currentUser != null) {
        print('🔐 [INTEREST SERVICE] Checking local user data...');
        final userInterests = currentUser.selectedTopics ?? [];
        print('🔐 [INTEREST SERVICE] User selected topics: $userInterests');
        final hasInterest = userInterests.contains(interestId);
        print('🔐 [INTEREST SERVICE] Local check result: $hasInterest');

        if (hasInterest) {
          hasUserInterest.value = true;
          print('✅ [INTEREST SERVICE] User has interest (local check)');
          return true;
        }
      }

      // If not found locally, make API call as fallback
      print('🔐 [INTEREST SERVICE] Making API call for verification...');
      isLoading.value = true;

      final apiUrl = '${ApiConstant.getUserInterests}/$userId/interests';
      print('🌐 [INTEREST SERVICE] API URL: $apiUrl');

      final response = await _apiClient.get(apiUrl);
      print('🌐 [INTEREST SERVICE] Response status: ${response.statusCode}');
      print('🌐 [INTEREST SERVICE] Response data: ${response.data}');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(response.data, (data) => data);
        if (apiResponse.success) {
          final interests = List<Map<String, dynamic>>.from(
              apiResponse.data['interests'] ?? []);
          print('🔐 [INTEREST SERVICE] User interests from API: $interests');
          final hasInterest =
              interests.any((interest) => interest['_id'] == interestId);
          hasUserInterest.value = hasInterest;
          print('✅ [INTEREST SERVICE] API check result: $hasInterest');
          return hasInterest;
        } else {
          print(
              '❌ [INTEREST SERVICE] API returned success: false, message: ${apiResponse.message}');
          throw ApiException(apiResponse.message);
        }
      } else if (response.statusCode == 404) {
        print(
            '⚠️ [INTEREST SERVICE] User interests API not found (404), using local data only');
        // API endpoint doesn't exist, rely on local data only
        hasUserInterest.value = false;
        return false;
      } else {
        print('❌ [INTEREST SERVICE] HTTP Error: ${response.statusCode}');
        throw ApiException('Failed to check user interest');
      }
    } catch (e) {
      print('❌ [INTEREST SERVICE] Error checking user interest: $e');
      print('❌ [INTEREST SERVICE] Stack trace: ${StackTrace.current}');
      throw ApiException('Failed to check user interest: ${e.toString()}');
    } finally {
      isLoading.value = false;
      print('🏁 [INTEREST SERVICE] Loading state set to false');
    }
  }

  // Get user's community access preference
  Future<String> getUserCommunityAccess(String userId) async {
    try {
      // First check local user data
      final currentUser = _authService.currentUser.value;
      if (currentUser != null && currentUser.communityAccess != null) {
        final access = currentUser.communityAccess!;
        communityAccess.value = access;
        return access;
      }

      // If not found locally, make API call as fallback
      isLoading.value = true;

      final response = await _apiClient.get(
        ApiConstant.getUserCommunityAccess(userId),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(response.data, (data) => data);
        if (apiResponse.success) {
          final access = apiResponse.data['communityAccess'] ?? 'OUT';
          communityAccess.value = access;
          return access;
        } else {
          throw ApiException(apiResponse.message);
        }
      } else {
        throw ApiException('Failed to get community access');
      }
    } catch (e) {
      print('Error getting community access: $e');
      throw ApiException('Failed to get community access: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Get user's all interests
  Future<List<Map<String, dynamic>>> getUserInterests(
      String userId, String interestId) async {
    try {
      // First check local user data
      final currentUser = _authService.currentUser.value;
      if (currentUser != null && currentUser.selectedTopics != null) {
        // Convert user's selected topic IDs to interest objects
        final interestIds = currentUser.selectedTopics!;
        final interests = interestIds.map((id) => {'_id': id}).toList();
        return interests;
      }

      // If not found locally, make API call as fallback
      isLoading.value = true;

      final response = await _apiClient.get(
        ApiConstant.getInterestUserCount(interestId),
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(response.data, (data) => data);
        if (apiResponse.success) {
          return List<Map<String, dynamic>>.from(
              apiResponse.data['interests'] ?? []);
        } else {
          throw ApiException(apiResponse.message);
        }
      } else {
        throw ApiException('Failed to get user interests');
      }
    } catch (e) {
      print('Error getting user interests: $e');
      throw ApiException('Failed to get user interests: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Check if user can send messages (has interest + community access is IN)
  Future<bool> canUserSendMessages(String userId, String interestId) async {
    try {
      final hasInterest = await checkUserHasInterest(userId, interestId);
      final access = await getUserCommunityAccess(userId);

      return hasInterest && access == 'IN';
    } catch (e) {
      print('Error checking message permissions: $e');
      return false;
    }
  }
}
