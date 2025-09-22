class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://vropay-backend-1.onrender.com';
  static const String apiVersion = '/api';

  // Authentication Endpoints
  static const String signIn = '$apiVersion/auth/signin';
  static const String verifyOtp = '$apiVersion/auth/verify-otp';
  static const String googleAuth = '$apiVersion/auth/google';

  // User Endpoints
  static const String userProfile = '$apiVersion/users/profile';
  static const String userPreferences = '$apiVersion/users/preferences';
  static const String updateUser = '$apiVersion/users';

  // Knowledge Center Endpoints
  static const String knowledgeCenter = '/knowledge-center';
  static const String subtopicContents = '$apiVersion/subtopics';
  static const String contentDetails = '$apiVersion/contents';

  // Forum Endpoints
  static const String forumCategories = '$apiVersion/forum/categories';
  static const String forumSubtopics = '$apiVersion/forum/subtopics';
  static const String forumRooms = '$apiVersion/forum/subtopics';
  static const String forumMessages = '$apiVersion/forum/rooms';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'content-type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeouts
  static const int connectionTimeout = 1200000; // 120 seconds
  static const int receiveTimeout = 1200000; // 120 seconds

  // API Response Status Codes
  static const int succesCode = 200;
  static const int createdCode = 201;
  static const int badRequestCode = 400;
  static const int unauthorizedCode = 401;
  static const int forbiddenCode = 403;
  static const int notFoundCode = 404;
  static const int serverErrorCode = 500;
}
