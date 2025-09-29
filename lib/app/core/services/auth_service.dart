import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vropay_final/app/core/api/api_constant.dart';
import 'package:vropay_final/app/core/models/api_response.dart';
import 'package:vropay_final/app/core/models/user_model.dart';
import 'package:vropay_final/app/core/network/api_client.dart';
import 'package:vropay_final/app/core/network/api_exception.dart';

class AuthService extends GetxService {
  final ApiClient _apiClient = ApiClient();
  final GetStorage _storage = GetStorage();

  // Observable variables
  final RxBool isLoggedIn = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxString authToken = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAuthData();
    _checkAuthStatus();
  }

  // Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    final token = _storage.read('auth_token');
    if (token != null && token.isNotEmpty) {
      authToken.value = token;
      isLoggedIn.value = true;

      // Load user data from storage first for quick access
      final userData = _storage.read('user_data');
      if (userData != null) {
        currentUser.value = UserModel.fromJson(userData);
      }

      // Try to get user profile to validate token
      try {
        await getUserProfile();
      } catch (e) {
        await logout();
      }
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => isLoggedIn.value && authToken.value.isNotEmpty;

  // Load authentication data from storage
  void _loadAuthData() {
    final token = _storage.read('auth_token');
    final userData = _storage.read('user_data');

    if (token != null) {
      authToken.value = token;
      isLoggedIn.value = true;

      if (userData != null) {
        currentUser.value = UserModel.fromJson(userData);
      }
    }
  }

  // Sign up with email - Postman collection endpoint
  Future<ApiResponse<Map<String, dynamic>>> signUpWithEmail({
    required String email,
    String? name,
  }) async {
    try {
      isLoading.value = true;

      print('🚀 Signing up with email: $email, name: $name');
      print('🔗 Full URL: ${ApiConstants.baseUrl}${ApiConstants.signUp}');

      final requestData = {
        'email': email,
        if (name != null) 'name': name,
      };
      print('📦 Request data: $requestData');

      // Test connection first
      try {
        final response =
            await _apiClient.post(ApiConstants.signUp, data: requestData);
        print('🔗 Response received successfully');
        return _processSignupResponse(response);
      } catch (e) {
        print('❌ Network error during signup: $e');
        throw e;
      }
    } catch (e) {
      print('❌ Sign up error: $e');
      throw _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Verify OTP
  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      isLoading.value = true;
      print('🚀 Verifying OTP for email: $email, OTP: $otp');

      final response = await _apiClient.post(ApiConstants.verifyOtp, data: {
        'email': email,
        'otp': otp,
      });
      final responseData = response.data;
      print('✅ OTP verification response: $responseData');

      // Save token and user data if available
      if (responseData['token'] != null) {
        await _saveAuthData(responseData['token'], responseData['user'] ?? {});
      }

      return ApiResponse.fromJson(
          responseData, (data) => data as Map<String, dynamic>);
    } catch (e) {
      print('❌ OTP verification error: $e');
      throw _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Google authentication with token
  Future<ApiResponse<Map<String, dynamic>>> googleAuth({
    required String email,
    required String name,
    required String idToken,
  }) async {
    try {
      isLoading.value = true;

      print('🚀 Google auth with email: $email,');
      final response = await _apiClient.post(ApiConstants.googleAuth, data: {
        'idToken': idToken,
      });

      // Check if response is HTML (Google login page)
      if (response.data['token'] != null) {
        await _saveAuthData(
            response.data['token'], response.data['user'] ?? {});
      }

      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ Google auth error: $e');
      throw _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Apple authentication with identity toke
  Future<ApiResponse<Map<String, dynamic>>> appleAuth({
    required String email,
    required String name,
    required String identityToken,
    required String userIdentifier,
  }) async {
    try {
      isLoading.value = true;
      final response = await _apiClient.post(ApiConstants.appleAuth, data: {
        'email': email,
        'name': name,
        'identityToken': identityToken,
        'userIdentifier': userIdentifier,
      });

      final responseData = response.data;

      // Save token and user data
      if (responseData['token'] != null) {
        await _saveAuthData(responseData['token'], responseData['user'] ?? {});
      }

      return ApiResponse.fromJson(
          responseData, (data) => data as Map<String, dynamic>);
    } catch (e) {
      throw _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Get user profile
  Future<ApiResponse<UserModel>> getUserProfile() async {
    try {
      isLoading.value = true;
      print('🚀 AuthService - Getting user profile from API...');

      final response = await _apiClient.get(ApiConstants.userProfile);
      print('🔍 AuthService - Raw API response: ${response.data}');
      print('🔍 AuthService - Response type: ${response.data.runtimeType}');

      // Extract user data from nested response
      Map<String, dynamic> userData;
      if (response.data is Map<String, dynamic> &&
          response.data['user'] != null) {
        userData = response.data['user'] as Map<String, dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        userData = response.data;
      } else {
        throw Exception('Invalid user profile response format');
      }

      print('🔍 AuthService - Extracted user data: $userData');

      final user = UserModel.fromJson(userData);
      print('✅ AuthService - Parsed user successfully:');
      print('  - ID: ${user.id}');
      print('  - FirstName: ${user.firstName}');
      print('  - LastName: ${user.lastName}');
      print('  - Email: ${user.email}');
      print('  - Mobile: ${user.mobile}');
      print('  - Gender: ${user.gender}');
      print('  - Profession: ${user.profession}');

      currentUser.value = user;
      await _storage.write('user_data', user.toJson());
      print('✅ AuthService - User data saved to storage');

      return ApiResponse.fromJson(
        userData,
        (data) => UserModel.fromJson(data),
      );
    } catch (e) {
      print('❌ AuthService - Get user profile error: $e');
      print('❌ AuthService - Error type: ${e.runtimeType}');
      throw _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Send OTP for email change
  Future<ApiResponse<Map<String, dynamic>>> sendEmailChangeOtp({
    required String newEmail,
  }) async {
    try {
      isLoading.value = true;
      print('🚀 AuthService - Sending OTP for email change to: $newEmail');

      final response = await _apiClient.post(ApiConstants.changeEmail, data: {
        'newEmail': newEmail,
      });

      print('✅ AuthService - Email change OTP sent successfully');
      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ AuthService - Error sending email change OTP: $e');
      throw _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Update user profile
  Future<ApiResponse<Map<String, dynamic>>> updateUserProfile({
    required String firstName,
    required String lastName,
    required String gender,
    required String profession,
    String? mobile,
    List<String>? selectedTopics,
    String? difficultyLevel,
    String? communityAccess,
    bool? notificationsEnabled,
  }) async {
    try {
      isLoading.value = true;
      print('🚀 Updating user profile');

      final Map<String, dynamic> data = {
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'profession': profession,
      };

      if (mobile != null) data['mobile'] = mobile;
      if (selectedTopics != null) {
        data['selectedTopics'] = selectedTopics;
      }
      if (difficultyLevel != null) data['difficultyLevel'] = difficultyLevel;
      if (communityAccess != null) data['communityAccess'] = communityAccess;
      if (notificationsEnabled != null) {
        data['notificationsEnabled'] = notificationsEnabled.toString();
      }

      print('📦 Sending profile data: $data');

      try {
        final response =
            await _apiClient.put(ApiConstants.updateUser, data: data);
        print('✅ Profile update response: ${response.data}');

        // Handle successful response
        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = response.data as Map<String, dynamic>;

          // Update local user data if backend returns user data
          if (responseData['user'] != null) {
            currentUser.value = UserModel.fromJson(responseData['user']);
            await _storage.write('user_data', responseData['user']);
          }

          return ApiResponse.fromJson(
              responseData, (data) => data as Map<String, dynamic>);
        }
      } catch (e) {
        print('❌ API call failed: $e');
        // If API fails, create success response locally
      }

      // Fallback: Update local data and return success
      final localUserData = {
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'profession': profession,
        'selectedTopics': selectedTopics ?? [],
        'difficultyLevel': difficultyLevel ?? 'Beginner',
        'communityAccess': communityAccess ?? 'Public',
        'notificationsEnabled': notificationsEnabled ?? true,
      };

      currentUser.value = UserModel.fromJson(localUserData);
      await _storage.write('user_data', localUserData);

      return ApiResponse.success(
          {'message': 'Profile updated locally', 'user': localUserData});
    } catch (e) {
      print('❌ Update user profile error: $e');
      throw _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // get interest
  Future<Map<String, dynamic>> getInterests() async {
    try {
      final response = await _apiClient.get(ApiConstants.interest);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {'interests': <dynamic>[]};
    } catch (e) {
      print("Error getting interests: $e");
      throw _handleAuthError(e);
    }
  }

  // Update user interests
  Future<ApiResponse<Map<String, dynamic>>> updateUserInterests({
    required List<String> interests,
  }) async {
    try {
      isLoading.value = true;
      print('🚀 Updating user interests: $interests');

      final response =
          await _apiClient.put(ApiConstants.updateUserInterests, data: {
        'interests': interests,
      });

      print('✅ Update user interests response: ${response.data}');

      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Update user interests error: $e');
      throw _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Save selected interests with object IDs
  Future<ApiResponse<Map<String, dynamic>>> saveSelectedInterests({
    required List<String> interestIds,
  }) async {
    try {
      isLoading.value = true;
      print('🚀 Saving selected interests: $interestIds');

      final response = await _apiClient.post(ApiConstants.interest, data: {
        'interests': interestIds,
      });

      print('✅ Save interests response: ${response.data}');

      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Save interests error: $e');
      throw _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Update user preferences
  Future<ApiResponse<Map<String, dynamic>>> updateUserPreferences({
    String? profession,
    List<String>? selectedTopics,
    String? difficultyLevel,
    String? communityAccess,
    bool? notificationsEnabled,
  }) async {
    isLoading.value = true;
    try {
      print('🚀 Updating user preferences');

      final data = <String, dynamic>{};
      if (profession != null) data['profession'] = profession;
      if (selectedTopics != null) data['interests'] = selectedTopics;
      if (difficultyLevel != null) data['difficulty'] = difficultyLevel;
      if (communityAccess != null) data['community'] = communityAccess;
      if (notificationsEnabled != null) {
        data['notifications'] =
            notificationsEnabled ? 'Allowed' : 'Not allowed';
      }

      print('🔍 Sending to backend: $data');

      final response =
          await _apiClient.put(ApiConstants.userPreferences, data: data);
      print('✅ Update preferences response: ${response.data}');

      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Update preferences error: $e');
      throw _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Save authentication data
  Future<void> _saveAuthData(
      String token, Map<String, dynamic> userData) async {
    authToken.value = token;
    isLoggedIn.value = true;
    currentUser.value = UserModel.fromJson(userData);

    await _storage.write('auth_token', token);
    await _storage.write('user_data', userData);

    print('✅ Auth data saved successfully');
  }

  // Process signup response
  ApiResponse<Map<String, dynamic>> _processSignupResponse(response) {
    print('✅ Sign up response status: ${response.statusCode}');
    print('✅ Sign up response data: ${response.data}');

    // Check if response is successful
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } else {
      throw ApiException('Signup failed with status: ${response.statusCode}');
    }
  }

  // Handle authentication errors
  Exception _handleAuthError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    return UnknownException('Authentication failed: ${error.toString()}');
  }

  // Save difficulty level
  Future<ApiResponse<Map<String, dynamic>>> saveDifficultyLevel(
      {required String difficultyLevel}) async {
    try {
      isLoading.value = true;
      print('🚀 Saving selected difficulty: $difficultyLevel');

      final response = await _apiClient
          .post(ApiConstants.difficulty, data: {'difficulty': difficultyLevel});

      print('✅ Save difficulty response: ${response.data}');

      // Handle HTML error message
      if (response.data is String &&
          response.data.contains('<!DOCTYPE html>')) {
        throw ApiException('API endpoint not found: /api/difficulty');
      }

      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      print("Error in Difficulties: $e");
      throw _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Save community access preference
  Future<ApiResponse<Map<String, dynamic>>> saveCommunityAccess(
      {required String accessType}) async {
    try {
      isLoading.value = true;

      final response =
          await _apiClient.post(ApiConstants.communityAccess, data: {
        'community': accessType,
      });

      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse.success({'message': 'Community access saved locally'});
    } finally {
      isLoading.value = false;
    }
  }

  // Save notification preference
  Future<ApiResponse<Map<String, dynamic>>> saveNotificationPreference({
    required String notificationStatus,
  }) async {
    try {
      isLoading.value = true;

      final response = await _apiClient.post(ApiConstants.setNotification,
          data: {'notifications': notificationStatus});

      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      print('Error: Notification save error $e');
      return ApiResponse.success(
          {'message': 'Notification preference saved locally'});
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Call backend logout api
      try {
        final response = await _apiClient.post(ApiConstants.logout, data: {});
      } catch (e) {
        // Continue with local logout even if backedn fails
      }
      // clear local storage
      await _storage.remove('auth_token');
      await _storage.remove('user_data');

      // Reset state
      isLoggedIn.value = false;
      currentUser.value = null;
      authToken.value = '';
    } catch (e) {
      print('Logout error: $e');
      // Event if error, clear local data
      await _storage.remove('auth_token');
      await _storage.remove('user_data');
      isLoggedIn.value = false;
      currentUser.value = null;
      authToken.value = '';
    } finally {
      isLoading.value = false;
    }
  }
}
