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
  }

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
    required String name,
  }) async {
    try {
      isLoading.value = true;

      print('🚀 Signing up with email: $email, name: $name');

      final response = await _apiClient.post(ApiConstants.signIn, data: {
        'email': email,
        'name': name,
      });

      print('✅ Sign up response: ${response.data}');

      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
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

  // Google authentication
  Future<ApiResponse<Map<String, dynamic>>> googleAuth({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      isLoading.value = true;

      print('🚀 Google auth with email: $email, name: $name');
      final response =
          await _apiClient.get(ApiConstants.googleAuth, queryParameters: {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
      });

      final responseData = response.data;
      print('✅ Google auth response: $responseData');

      // Check if response is HTML (Google login page)
      if (responseData is String && responseData.contains('<!doctype html>')) {
        throw ApiException(
            'Google authentication failed: Server returned login page instead of JSON response. Please check your backend Google auth configuration.');
      }

      // Validate response is a Map (JSON)
      if (responseData is! Map<String, dynamic>) {
        throw ApiException(
            'Invalid response format: Expected JSON but got ${responseData.runtimeType}');
      }

      // Save token and user data
      if (responseData['token'] != null) {
        await _saveAuthData(responseData['token'], responseData['user'] ?? {});
      }

      return ApiResponse.fromJson(
        responseData,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ Google auth error: $e');
      throw _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Get user profile
  Future<ApiResponse<UserModel>> getUserProfile() async {
    try {
      isLoading.value = true;
      print('🚀 Getting user profile');
      final response = await _apiClient.get(ApiConstants.userProfile);
      final user = UserModel.fromJson(response.data);

      print('✅ User profile response: ${response.data}');
      currentUser.value = user;
      await _storage.write('user_data', user.toJson());

      return ApiResponse.fromJson(
        response.data,
        (data) => UserModel.fromJson(data),
      );
    } catch (e) {
      print('❌ Get user profile error: $e');
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
      print('�� Updating user profile');

      final data = {
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'profession': profession,
      };

      if (mobile != null) data['mobile'] = mobile;
      if (selectedTopics != null) {
        data['selectedTopics'] = selectedTopics.join(',');
      }
      if (difficultyLevel != null) data['difficultyLevel'] = difficultyLevel;
      if (communityAccess != null) data['communityAccess'] = communityAccess;
      if (notificationsEnabled != null) {
        data['notificationsEnabled'] = notificationsEnabled.toString();
      }

      final response =
          await _apiClient.patch(ApiConstants.updateUser, data: data);

      print('✅ Update user profile response: ${response.data}');

      // Update local user data
      if (response.data['user'] != null) {
        currentUser.value = UserModel.fromJson(response.data['user']);
        await _storage.write('user_data', response.data['user']);
      }

      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Update user profile error: $e');
      throw _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Update user preferences
  Future<ApiResponse<Map<String, dynamic>>> updateUserPreferences({
    List<String>? selectedTopics,
    String? difficultyLevel,
    String? communityAccess,
    bool? notificationsEnalbled,
  }) async {
    isLoading.value = true;
    try {
      print('🚀 Updating user preferences');

      final data = <String, dynamic>{};
      if (selectedTopics != null) data['selectedTopics'] = selectedTopics;
      if (difficultyLevel != null) data['difficultyLevel'] = difficultyLevel;
      if (communityAccess != null) data['communityAccess'] = communityAccess;
      if (notificationsEnalbled != null)
        data['notificationEnabled'] = notificationsEnalbled;

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

  // Logout
  Future<void> logout() async {
    await _storage.remove('auth_token');
    await _storage.remove('user_data');

    isLoggedIn.value = false;
    currentUser.value = null;
    authToken.value = '';

    print('✅ User logged out successfully');
  }

  // Handle authentication errors
  Exception _handleAuthError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    return UnknownException('Authentication failed: ${error.toString()}');
  }
}
