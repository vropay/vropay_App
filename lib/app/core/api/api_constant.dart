class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://10.0.2.2:3000';
  static const String apiVersion = '/api';

  // Authentication Endpoints
  static const String signUp = '$apiVersion/signup';
  static const String signIn = '$apiVersion/signin';
  static const String verifyOtp = '$apiVersion/verify-otp';
  static const String googleAuth = '$apiVersion/google-auth';
  static const String appleAuth = '$apiVersion/apple-auth';

  // User Endpoints
  static const String userProfile = '$apiVersion/profile';
  static const String userPreferences = '$apiVersion/preferences';
  static const String updateUser = '$apiVersion/profile';
  static const String changeEmail = '$apiVersion/change-email';
  static const String difficulty = '$apiVersion/set-difficulty';
  static const String communityAccess = '$apiVersion/set-community';
  static const String setNotification = '$apiVersion/set-notifications';

  // Knowledge Center Endpoints
  static const String knowledgeCenter = '$apiVersion/knowledge-center';
  static const String subtopicContents =
      '$apiVersion/knowledge-center/subtopics';
  static const String contentDetails = '$apiVersion/knowledge-center/contents';

  // Forum Endpoints
  static const String forumCategories =
      '$apiVersion/community/forum/categories';
  static const String forumSubtopics = '$apiVersion/community/forum/categories';
  static const String forumRooms = '$apiVersion/community/forum/subtopics';
  static const String forumMessages = '$apiVersion/community/forum/rooms';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'content-type': 'application/json',
    'Accept': 'application/json',
  };

  // Log out Endpoint
  static const String logout = '$apiVersion/logout';

  // Timeouts
  static const int connectionTimeout = 120000; // 120 seconds
  static const int receiveTimeout = 120000; // 120 seconds

  // API Response Status Codes
  static const int succesCode = 200;
  static const int createdCode = 201;
  static const int badRequestCode = 400;
  static const int unauthorizedCode = 401;
  static const int forbiddenCode = 403;
  static const int notFoundCode = 404;
  static const int serverErrorCode = 500;

  // GET APIs

  // User details forms GET api

  // Phone verification endpoints
  static const String requestPhoneVerification = '$apiVersion/request-phone-verification';
  static const String verifyPhoneNumber = '$apiVersion/verify-phone-number';

  // Interest screen's
  static const String interest = '$apiVersion/interests';
  static const String updateUserInterests = '$apiVersion/interests/user';
}
