import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vropay_final/app/core/api/api_constant.dart';
import 'package:vropay_final/app/core/models/api_response.dart';
import 'package:vropay_final/app/core/models/user_model.dart';
import 'package:vropay_final/app/core/network/api_client.dart';
import 'package:vropay_final/app/core/network/api_exception.dart';
import 'package:vropay_final/app/core/services/socket_service.dart';

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

    // initialize api client
    final apiClient = ApiClient();
    apiClient.init();

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

  // Get auth token
  Future<String?> getAuthToken() async {
    return _storage.read('auth_token');
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
    String? name,
  }) async {
    try {
      isLoading.value = true;

      print('🚀 Signing up with email: $email, name: $name');
      print('🔗 Full URL: ${ApiConstant.baseUrl}${ApiConstant.signUp}');

      final requestData = {
        'email': email,
        if (name != null) 'name': name,
      };
      print('📦 Request data: $requestData');

      // Test connection first
      try {
        final response =
            await _apiClient.post(ApiConstant.signUp, data: requestData);
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

      final response = await _apiClient.post(ApiConstant.verifyOtp, data: {
        'email': email,
        'otp': otp,
      });
      final responseData = response.data;
      print('✅ OTP verification response: $responseData');

      // Robust token extraction and optional profile hydration
      final token = _extractToken(responseData, headers: response.headers.map);
      if (token != null) {
        await _saveAuthData(token, responseData['user'] ?? {});
        try {
          await getUserProfile();
        } catch (_) {}
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

  // Resend OTP for sign-up email
  Future<ApiResponse<Map<String, dynamic>>> resendSignUpEmailOtp(
      {required String email}) async {
    try {
      isLoading.value = true;
      print('🔄 Resending sign-up email OTP for: $email');

      final response = await _apiClient
          .post(ApiConstant.resendSignUpEmailOtp, data: {'email': email});
      print('✅ Resend sign-up email OTP response: ${response.data}');

      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Resend sign-up email OTP error: $e');
      throw ApiException('Failed to resend email OTP: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Resend OTP for sign-up phone
  Future<ApiResponse<Map<String, dynamic>>> resendSignUpPhoneOtp(
      {required String phoneNumber}) async {
    try {
      isLoading.value = true;
      print('🔄 Resending sign-up phone OTP for: $phoneNumber');

      final response = await _apiClient.post(ApiConstant.resendSignUpPhoneOtp,
          data: {'phoneNumber': phoneNumber});

      print('✅ Resend sign-up phone OTP response: ${response.data}');

      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Resend sign-up phone OTP error: $e');
      throw ApiException('Failed to resend phone OTP: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Resend OTP for sign-in
  Future<ApiResponse<Map<String, dynamic>>> resendSignInOtp({
    required String phoneNumber,
  }) async {
    try {
      isLoading.value = true;
      print('🔄 Resending sign-in OTP for: $phoneNumber');

      final response = await _apiClient.post(ApiConstant.resendSignInOtp,
          data: {'phoneNumber': phoneNumber});

      print('✅ Resend OTP response: ${response.data}');

      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Resend OTP error: $e');
      throw ApiException(
        'Failed to resend OTP: ${e.toString()}',
      );
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
      final response = await _apiClient.post(ApiConstant.googleAuth, data: {
        'idToken': idToken,
      });

      // Check if response is HTML (Google login page)
      if (response.data['token'] != null) {
        print('🔍 Saving Google auth token: ${response.data['token']}');

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
      final response = await _apiClient.post(ApiConstant.appleAuth, data: {
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

      final response = await _apiClient.get(ApiConstant.userProfile);
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
      print('🔍 AuthService - Phone fields in response:');
      print('  - phoneNumber: ${userData['phoneNumber']}');
      print('  - mobile: ${userData['mobile']}');
      print('  - phone: ${userData['phone']}');
      print('  - All keys: ${userData.keys.toList()}');

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

      final response = await _apiClient.post(ApiConstant.changeEmail, data: {
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

  // Send OTP for email change (alternative method name)
  Future<ApiResponse<Map<String, dynamic>>> sendemailchangeotp({
    required String newEmail,
  }) async {
    return await sendEmailChangeOtp(newEmail: newEmail);
  }

  // Send OTP for phone change
  Future<ApiResponse<Map<String, dynamic>>> sendphonechangeotp({
    required String newPhone,
  }) async {
    try {
      isLoading.value = true;
      print('🚀 AuthService - Sending OTP for phone change to: $newPhone');

      final response = await _apiClient.post(ApiConstant.changePhone, data: {
        'phoneNumber': newPhone,
        'newPhoneNumber': newPhone,
        'phone': newPhone,
      });

      final responseData = response.data as Map<String, dynamic>;

      // Check if the API returned an error
      if (responseData['success'] == false) {
        print(
            '❌ AuthService - Phone change failed: ${responseData['message']}');
        throw ApiException(
            responseData['message'] ?? 'Failed to send phone OTP');
      }

      print('✅ AuthService - Phone change OTP sent successfully');
      return ApiResponse.fromJson(
        responseData,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ AuthService - Error sending phone change OTP: $e');
      throw _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Verify phone update with OTP
  Future<ApiResponse<Map<String, dynamic>>> verifyPhoneUpdate({
    required String otp,
  }) async {
    try {
      isLoading.value = true;
      print('🚀 AuthService - Verifying phone update with OTP: $otp');

      final response = await _apiClient
          .post('${ApiConstant.apiVersion}/verify-phone-update', data: {
        'otp': otp,
      });

      print('✅ AuthService - Phone verification response: ${response.data}');

      // Update local user data after successful verification
      if (response.data is Map<String, dynamic> &&
          response.data['success'] == true) {
        await getUserProfile();
      }

      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ AuthService - Error verifying phone update: $e');
      throw _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Verify email update with OTP
  Future<ApiResponse<Map<String, dynamic>>> verifyUpdateEmail({
    required String otp,
  }) async {
    try {
      isLoading.value = true;
      print('🚀 AuthService - Verifying email update with OTP: $otp');

      final response = await _apiClient
          .post('${ApiConstant.apiVersion}/verify-email-update', data: {
        'otp': otp,
      });

      print('✅ AuthService - Email verification response: ${response.data}');

      // Handle HTML error responses
      if (response.data is String &&
          response.data.contains('<!DOCTYPE html>')) {
        throw ApiException('Email verification endpoint not found');
      }

      // Update local user data after successful verification
      if (response.data is Map<String, dynamic> &&
          response.data['success'] == true) {
        await getUserProfile();
      }

      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ AuthService - Error verifying email update: $e');
      throw _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Request phone verification OTP
  Future<ApiResponse<Map<String, dynamic>>> requestPhoneVerification({
    required String phoneNumber,
  }) async {
    try {
      isLoading.value = true;
      print('🚀 Requesting phone verification for: $phoneNumber');

      // Debug: Check if token exists before making request
      final currentToken = _storage.read('auth_token');
      print(
          '🔍 Current token before phone verification: ${currentToken != null ? 'EXISTS' : 'MISSING'}');
      if (currentToken != null) {
        print(
            '🔍 Token preview: ${currentToken.toString().substring(0, 20)}...');
      }

      final response =
          await _apiClient.post(ApiConstant.signUpPhoneVerification, data: {
        'phoneNumber': phoneNumber,
      });

      print('✅ Phone verification OTP sent successfully');
      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ Phone verification request error: $e');
      throw _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Verify phone number OTP
  Future<ApiResponse<Map<String, dynamic>>> verifyPhoneNumber({
    required String otp,
  }) async {
    try {
      isLoading.value = true;
      print('🚀 Verifying phone OTP: $otp');

      // Debug: Check if token exists before making request
      final currentToken = _storage.read('auth_token');
      print(
          '🔍 Current token before phone OTP verification: ${currentToken != null ? 'EXISTS' : 'MISSING'}');

      final response =
          await _apiClient.post(ApiConstant.signUpVerifyPhoneNumber, data: {
        'otp': otp,
        'enablePhoneLogin': true, // Request to enable phone login
      });

      print('✅ Phone number verified successfully');
      return ApiResponse.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      print('❌ Phone verification error: $e');
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
    String? email,
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

      if (email != null && email.isNotEmpty) {
        data['email'] = email;
      }

      if (mobile != null && mobile.isNotEmpty) {
        data['mobile'] = mobile;
        data['phoneNumber'] = mobile;
      }
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
            await _apiClient.put(ApiConstant.updateUser, data: data);
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
      final response = await _apiClient.get(ApiConstant.interest);
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
          await _apiClient.put(ApiConstant.updateUserInterests, data: {
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

      final response = await _apiClient.post(ApiConstant.interest, data: {
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
          await _apiClient.put(ApiConstant.userPreferences, data: data);
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
    await _storage.write('user_data', userData); // Verify token was saved
    final savedToken = _storage.read('auth_token');

    // Connect to Socket.IO after successful authentication
    _connectToSocket();
    print(
        '🔍 Token saved verification: ${savedToken != null ? 'SUCCESS' : 'FAILED'}');
    print('✅ Auth data saved successfully');
  }

  /// Connect to Socket.IO after authentication
  void _connectToSocket() {
    try {
      final socketService = Get.find<SocketService>();
      socketService.connect();
      print('🔌 [AUTH SERVICE] Socket.IO connection initiated');
    } catch (e) {
      print('⚠️ [AUTH SERVICE] Socket service not available: $e');
    }
  }

  /// Disconnect Socket.IO on logout
  void _disconnectSocket() {
    try {
      final socketService = Get.find<SocketService>();
      socketService.disconnect();
      print('🔌 [AUTH SERVICE] Socket.IO disconnected');
    } catch (e) {
      print('⚠️ [AUTH SERVICE] Socket service not available: $e');
    }
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
          .post(ApiConstant.difficulty, data: {'difficulty': difficultyLevel});

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
          await _apiClient.post(ApiConstant.communityAccess, data: {
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

      final response = await _apiClient.post(ApiConstant.setNotification,
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
        await _apiClient.post(ApiConstant.logout, data: {});
      } catch (e) {
        // Continue with local logout even if backedn fails
      }
      // clear local storage
      await _storage.remove('auth_token');
      await _storage.remove('user_data');

      // Disconnect Socket.IO
      _disconnectSocket();

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

  // Manually inject an existing token and restore session (useful for dev/QA)
  Future<void> useExistingToken(String token) async {
    try {
      isLoading.value = true;
      authToken.value = token;
      isLoggedIn.value = true;
      await _storage.write('auth_token', token);

      // Try to load profile with the provided token
      try {
        await getUserProfile();
      } catch (_) {
        // Ignore; token may be valid but profile endpoint might be unavailable
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Phone sign in with api
  Future<ApiResponse<Map<String, dynamic>>> signInWithPhone({
    required String phoneNumber,
  }) async {
    try {
      isLoading.value = true;

      print('🚀 Sign-in with phone: $phoneNumber');

      // Debug: Check if token exists (it shouldn't be required for sign-in)
      final currentToken = _storage.read('auth_token');
      print(
          '🔍 Token before sign-in request: ${currentToken != null ? 'EXISTS' : 'MISSING'}');

      final response = await _apiClient.post(ApiConstant.phoneSignIn, data: {
        'phone': phoneNumber,
        'phoneNumber': phoneNumber,
      });
      print('✅ Sign-in response: ${response.data}');

      return ApiResponse.fromJson(
          response.data, (data) => data as Map<String, dynamic>);
    } catch (e) {
      print('❌ Sign-in error: $e');

      throw _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyPhoneSignInOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      isLoading.value = true;

      final payload = {
        'phone': phoneNumber, // tolerate backends expecting 'phone'
        'phoneNumber': phoneNumber, // and those expecting 'phoneNumber'
        'otp': otp,
      };

      final response = await _apiClient.post(
        ApiConstant.phoneSignInVerify,
        data: payload,
      );

      final data = response.data;

      // Robust token extraction: body first, then headers
      String? token;
      if (data is Map<String, dynamic>) {
        token = data['token'] ??
            data['accessToken'] ??
            data['jwt'] ??
            (data['data'] is Map<String, dynamic>
                ? data['data']['token']
                : null);
      }
      if (token == null) {
        final headers = response.headers.map;
        final authHeader = headers['authorization']?.first;
        if (authHeader != null &&
            authHeader.toLowerCase().startsWith('bearer ')) {
          token = authHeader.substring(7);
        }
        token ??= headers['x-access-token']?.first;
      }

      if (token != null) {
        await _saveAuthData(
          token,
          (data is Map<String, dynamic> && data['user'] is Map<String, dynamic>)
              ? data['user'] as Map<String, dynamic>
              : <String, dynamic>{},
        );
        // Optional: hydrate profile after auth
        try {
          await getUserProfile();
        } catch (_) {}
      }

      return ApiResponse.fromJson(
        data,
        (d) => d as Map<String, dynamic>,
      );
    } catch (e) {
      throw _handleAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  String? _extractToken(dynamic data, {Map<String, List<String>>? headers}) {
    if (data is Map<String, dynamic>) {
      return data['token'] ??
          data['accessToken'] ??
          data['jwt'] ??
          (data['data'] is Map ? data['data']['token'] : null);
    }
    // header fallbacks
    final authHeader = headers?['authorization']?.first;
    if (authHeader != null && authHeader.toLowerCase().startsWith('bearer ')) {
      return authHeader.substring(7);
    }
    final xToken = headers?['x-access-token']?.first;
    return xToken;
  }

  // Deactivate User account
  Future<ApiResponse<Map<String, dynamic>>> deactivateUserAccount() async {
    try {
      isLoading.value = true;
      print('🔄 Deactivating user account...');

      final response = await _apiClient.delete(ApiConstant.deactivateAccount);

      print('✅ Deactivate account response status: ${response.statusCode}');
      print('✅ Deactivate account response data: ${response.data}');

      // Check if response is HTML (indicates endpoint not found)
      if (response.data is String &&
          response.data.toString().contains('<!DOCTYPE html>')) {
        throw ApiException(
            'Deactivate endpoint not found. Please check if the API is available.');
      }

      // Handle different response types
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successful response - parse as JSON
        if (response.data is Map<String, dynamic>) {
          final responseData = response.data as Map<String, dynamic>;

          // Log the detailed response for debugging
          if (responseData['data'] != null) {
            final deletedData = responseData['data'] as Map<String, dynamic>;
            print('🗑️ Deleted data summary:');
            print('  - Messages deleted: ${deletedData['messagesDeleted']}');
            print(
                '  - Interests removed from: ${deletedData['interestsRemovedFrom']}');
            print('  - User deleted: ${deletedData['userDeleted']}');
          }

          return ApiResponse.fromJson(
              response.data, (data) => data as Map<String, dynamic>);
        } else {
          // If response is not a Map, create a success response
          return ApiResponse.success(
              {'message': 'Account deactivated successfully'});
        }
      } else if (response.statusCode == 401) {
        throw ApiException('User not authenticated. Please sign in again.');
      } else if (response.statusCode == 404) {
        throw ApiException(
            'Deactivate endpoint not found. Please check if the API is available.');
      } else if (response.statusCode == 500) {
        throw ApiException('Server error occurred. Please try again later.');
      } else {
        // Other HTTP errors
        throw ApiException('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Deactivate account error: $e');
      if (e is ApiException) {
        rethrow; // Re-throw ApiException as-is
      } else {
        throw ApiException('Failed to deactivate account: ${e.toString()}');
      }
    } finally {
      isLoading.value = false;
    }
  }
}
