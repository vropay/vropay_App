class ApiConstant {
  // Base URLs
  static const String baseUrl = 'http://10.0.2.2:3000';
  static const String apiVersion = '/api';

  // Authentication Endpoints
  static const String signUp = '$apiVersion/signup';
  static const String signIn = '$apiVersion/signin';
  static const String verifyOtp = '$apiVersion/verify-otp';
  static const String verifySignin = '$apiVersion/verify-signin';

  // Phone sign up endpoints
  static const String signUpPhoneVerification =
      '$apiVersion/request-phone-verification';
  static const String signUpVerifyPhoneNumber =
      '$apiVersion/verify-phone-number';

  // Google auth endpoints
  static const String googleAuth = '$apiVersion/google-auth';
  static const String appleAuth = '$apiVersion/apple-auth';

  // Phone sign in endpoints
  static const String phoneSignIn =
      '$apiVersion/signin'; //  Phone sign-in endpoint
  static const String phoneSignInVerify =
      '$apiVersion/verify-signin'; // Phone OTP verification

  // User Endpoints
  static const String userProfile = '$apiVersion/profile';
  static const String userPreferences = '$apiVersion/preferences';
  static const String updateUser = '$apiVersion/profile';
  static const String changeEmail = '$apiVersion/change-email';
  static const String difficulty = '$apiVersion/set-difficulty';
  static const String communityAccess = '$apiVersion/set-community';
  static const String setNotification = '$apiVersion/set-notifications';

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
  static const int successCode = 200;
  static const int createdCode = 201;
  static const int badRequestCode = 400;
  static const int unauthorizedCode = 401;
  static const int forbiddenCode = 403;
  static const int notFoundCode = 404;
  static const int serverErrorCode = 500;

  // Interest screen's
  static const String interest = '$apiVersion/interests';
  static const String updateUserInterests = '$apiVersion/interests/user';

  // Learn Screen endpoints
  static const String learnMainCategories = '$apiVersion/main-categories';

  // knowledge center endpoints
  static String learnMainCategoryById(String mainCategoryId) =>
      '$apiVersion/main-category/$mainCategoryId';

  static String learnSubCategories(String mainCategoryId) =>
      '$apiVersion/main-category/$mainCategoryId/sub-categories';

  static String learnTopics(String mainCategoryId, String subCategoryId) =>
      '$apiVersion/main-category/$mainCategoryId/sub-category/$subCategoryId/topics';

  static String learnEntries(
          String mainCategoryId, String subCategoryId, String topicId) =>
      '$apiVersion/main-category/$mainCategoryId/sub-category/$subCategoryId/topic/$topicId/entries';

// Entry content endpoints
  static String learnEntryContent(String entryId) =>
      '$apiVersion/entries/$entryId/content';

  static String learnContentWithDetails(String mainCategoryId,
          String subCategoryId, String topicId, String entryId) =>
      '$apiVersion/main-category/$mainCategoryId/sub-category/$subCategoryId/topics/$topicId/entries/$entryId/details';

  static String learnSearchContent(String subCategoryId, String searchQuery) =>
      '$apiVersion/sub-categories/$subCategoryId/search?q=${Uri.encodeComponent(searchQuery)}';

  static String learnRelatedContent(String entryId) =>
      '$apiVersion/entries/$entryId/related';

  // Community endpoints
  static String communityMainCategories = '$apiVersion/main-categories';

  static String communityMainCategoryById(String mainCategoryId) =>
      '$apiVersion/main-category/$mainCategoryId';

  // Message Endpoints
  static const String sendMessage = '$apiVersion/messages';
  static String getInterestMessages(String interestId) =>
      '$apiVersion/messages/$interestId'; // GET /api/messages/:interestId
  static String getInterestUserCount(String interestId) =>
      '$apiVersion/user-count/$interestId'; // GET /api/user-count/:interestId

// User Interest Endpoints (for checking user permissions)
  static String getUserInterests(String userId) =>
      '$apiVersion/users/$userId/interests'; // GET /api/users/:userId/interests
  static String getUserCommunityAccess(String userId) =>
      '$apiVersion/users/$userId/community-access'; // GET /api/users/:userId/community-access
}
