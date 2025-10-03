import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/message_service.dart';
import 'package:vropay_final/app/core/services/interest_service.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';
import 'package:vropay_final/app/core/services/socket_service.dart';

class MessageController extends GetxController {
  // Services
  final MessageService _messageService = Get.find<MessageService>();
  final InterestService _interestService = Get.find<InterestService>();
  final AuthService _authService = Get.find<AuthService>();
  SocketService? _socketService;

  // UI State
  final selectedFilter = ''.obs;
  final totalMessages = 0.obs;
  final messages = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final replyToMessage = Rxn<Map<String, dynamic>>();
  final taggedUsers = <String>[].obs;
  final messageController = TextEditingController();
  final isImportantIconPressed = false.obs;

  // Real-time messaging
  final RxBool isRealTimeEnabled = false.obs;
  final RxString typingUsersText = ''.obs;
  final RxBool isTyping = false.obs;

  // Typing timer
  Timer? _typingTimer;
  Timer? _stopTypingTimer;

  // Dynamic Data
  final RxString interestId = ''.obs;
  final RxString interestName = ''.obs;
  final RxInt memberCount = 0.obs;
  final RxBool canSendMessages = false.obs;
  final RxBool hasUserInterest = false.obs;
  final RxString communityAccess = ''.obs;

  // Report options
  final List<String> reportOptions = [
    'irrelevant',
    'advertising',
    'selling',
    'suspicious',
    'offensive',
    'abusive',
    'false',
    'hate',
  ];

  final selectedReportOption = Rxn<String>();
  final isReportDialogOpen = false.obs;

  // Scroll callback
  VoidCallback? _scrollCallback;

  @override
  void onReady() {
    super.onReady();
    _initializeSocketService();
    _initializeMessageScreen();
  }

  @override
  void onClose() {
    _disposeTimers();
    _messageService.disableRealTimeMessaging();
    _disconnectFromSocket();
    messageController.dispose();
    super.onClose();
  }

  /// Disconnect from socket
  void _disconnectFromSocket() {
    if (_socketService != null) {
      _socketService!.disconnect();
    }
  }

  /// Initialize Socket.IO service
  void _initializeSocketService() {
    try {
      _socketService = Get.find<SocketService>();
      isRealTimeEnabled.value = true;
      print('✅ [MESSAGE CONTROLLER] Socket service initialized');

      // Connect to socket if user is authenticated
      _connectToSocket();
    } catch (e) {
      print('⚠️ [MESSAGE CONTROLLER] Socket service not available: $e');
      isRealTimeEnabled.value = false;
    }
  }

  /// Connect to socket with authentication
  Future<void> _connectToSocket() async {
    if (_socketService == null) return;

    try {
      final currentUser = _authService.currentUser.value;
      if (currentUser != null) {
        final authToken = await _authService.getAuthToken();
        final connected = await _socketService!.connect(
          authToken: authToken,
          userId: currentUser.id,
        );

        if (connected) {
          print('✅ [MESSAGE CONTROLLER] Connected to socket server');
        } else {
          print(
              '⚠️ [MESSAGE CONTROLLER] Socket connection failed, using REST API fallback');
          isRealTimeEnabled.value = false;
        }
      }
    } catch (e) {
      print('❌ [MESSAGE CONTROLLER] Failed to connect to socket: $e');
      isRealTimeEnabled.value = false;
    }
  }

  /// Retry socket connection
  Future<void> retrySocketConnection() async {
    if (_socketService != null && !isRealTimeEnabled.value) {
      print('🔄 [MESSAGE CONTROLLER] Retrying socket connection...');
      await _connectToSocket();

      if (isRealTimeEnabled.value) {
        await _enableRealTimeMessaging();
      }
    }
  }

  /// Dispose timers
  void _disposeTimers() {
    _typingTimer?.cancel();
    _stopTypingTimer?.cancel();
  }

  // Initialize message screen with dynamic data
  Future<void> _initializeMessageScreen() async {
    try {
      print(
          '🚀 [MESSAGE CONTROLLER] Starting message screen initialization...');
      isLoading.value = true;

      // Get interest data from arguments
      print('📥 [MESSAGE CONTROLLER] Getting arguments...');
      if (Get.arguments != null) {
        print('📥 [MESSAGE CONTROLLER] Arguments received: ${Get.arguments}');
        interestId.value = Get.arguments['interestId'] ?? '';
        interestName.value = Get.arguments['interestName'] ?? 'news';

        print('📥 [MESSAGE CONTROLLER] Parsed values:');
        print('   - interestId: "${interestId.value}"');
        print('   - interestName: "${interestName.value}"');
      } else {
        print('❌ [MESSAGE CONTROLLER] No arguments received!');
      }

      if (interestId.value.isEmpty) {
        Get.snackbar('Error', 'Interest ID not provided');
        return;
      }

      // Get current user
      print('👤 [MESSAGE CONTROLLER] Getting current user...');
      final currentUser = _authService.currentUser.value;
      if (currentUser == null) {
        print('❌ [MESSAGE CONTROLLER] User not authenticated!');
        Get.snackbar('Error', 'User not authenticated');
        return;
      }
      print('✅ [MESSAGE CONTROLLER] User authenticated: ${currentUser.id}');

      // Load all dynamic data in parallel
      print('🔄 [MESSAGE CONTROLLER] Loading data in parallel...');
      await Future.wait([
        _loadInterestDetails(),
        _checkUserPermissions(),
        _loadMessages(),
      ]);

      // Enable real-time messaging after loading initial data
      if (isRealTimeEnabled.value) {
        await _enableRealTimeMessaging();
      }

      print(
          '✅ [MESSAGE CONTROLLER] Message screen initialization completed successfully!');
    } catch (e) {
      print('❌ [MESSAGE CONTROLLER] Error initializing message screen: $e');
      print('❌ [MESSAGE CONTROLLER] Stack trace: ${StackTrace.current}');
      Get.snackbar('Error', 'Failed to load message data');
    } finally {
      isLoading.value = false;
      print('🏁 [MESSAGE CONTROLLER] Loading state set to false');
    }
  }

  // Load interest details (name and member count)
  Future<void> _loadInterestDetails() async {
    try {
      print(
          '📊 [INTEREST DETAILS] Starting to load interest details for interestId: "${interestId.value}"');
      final details =
          await _interestService.getInterestDetails(interestId.value);

      // Update interest name from API if available
      if (details['interestName'] != null &&
          details['interestName'].isNotEmpty) {
        interestName.value = details['interestName'];
        print(
            '📊 [INTEREST DETAILS] Interest name updated from API: "${interestName.value}"');
      }

      // Update member count
      memberCount.value = details['userCount'] ?? 0;
      print('✅ [INTEREST DETAILS] Interest details loaded successfully:');
      print('   - interestName: "${interestName.value}"');
      print('   - memberCount: ${memberCount.value}');
    } catch (e) {
      print('❌ [INTEREST DETAILS] Error loading interest details: $e');
      print('❌ [INTEREST DETAILS] Stack trace: ${StackTrace.current}');
      memberCount.value = 0;
    }
  }

  // Check user permissions (interest + community access)
  Future<void> _checkUserPermissions() async {
    try {
      print('🔐 [PERMISSIONS] Starting permission check...');
      final currentUser = _authService.currentUser.value!;
      print(
          '🔐 [PERMISSIONS] Checking permissions for user: ${currentUser.id}');

      // Check if user has this interest
      print(
          '🔐 [PERMISSIONS] Checking if user has interest: ${interestId.value}');
      final hasInterest = await _interestService.checkUserHasInterest(
          currentUser.id, interestId.value);
      hasUserInterest.value = hasInterest;
      print('🔐 [PERMISSIONS] User has interest: $hasInterest');

      // Get community access preference
      print('🔐 [PERMISSIONS] Getting community access preference...');
      final access =
          await _interestService.getUserCommunityAccess(currentUser.id);
      communityAccess.value = access;
      print('🔐 [PERMISSIONS] Community access: $access');

      // Determine if user can send messages
      canSendMessages.value = hasInterest && access == 'IN';
      print('🔐 [PERMISSIONS] Can send messages: ${canSendMessages.value}');
      print('✅ [PERMISSIONS] Permission check completed successfully');
    } catch (e) {
      print('❌ [PERMISSIONS] Error checking user permissions: $e');
      print('❌ [PERMISSIONS] Stack trace: ${StackTrace.current}');
      canSendMessages.value = false;
      hasUserInterest.value = false;
      communityAccess.value = 'OUT';
    }
  }

  // Load messages for the interest
  Future<void> _loadMessages() async {
    try {
      print(
          '💬 [MESSAGES] Starting to load messages for interestId: "${interestId.value}"');
      await _messageService.getInterestMessages(interestId: interestId.value);
      messages.value = _messageService.messages;
      totalMessages.value = _messageService.totalMessages.value;
      print(
          '✅ [MESSAGES] Messages loaded successfully: ${messages.length} messages');
      print('✅ [MESSAGES] Total messages: ${totalMessages.value}');
    } catch (e) {
      print('❌ [MESSAGES] Error loading messages: $e');
      print('❌ [MESSAGES] Stack trace: ${StackTrace.current}');
      Get.snackbar('Error', 'Failed to load messages');
    }
  }

  // Load more messages (pagination)
  Future<void> loadMoreMessages() async {
    try {
      await _messageService.loadMoreMessages(interestId.value);
      messages.value = _messageService.messages;
    } catch (e) {
      print('Error loading more messages: $e');
    }
  }

  // Send a message
  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;
    if (!canSendMessages.value) {
      Get.snackbar('Access Denied', 'You cannot send messages to this group');
      return;
    }

    try {
      isLoading.value = true;

      // Send stop typing indicator
      _sendStopTypingIndicator();

      await _messageService.sendMessage(
        interestId: interestId.value,
        message: messageController.text.trim(),
        replyToMessageId: replyToMessage.value?['id'],
        taggedUsers: taggedUsers.isNotEmpty ? taggedUsers : null,
      );

      // Update local messages
      messages.value = _messageService.messages;
      totalMessages.value = _messageService.totalMessages.value;

      // Clear input and reply
      messageController.clear();
      replyToMessage.value = null;
      taggedUsers.clear();

      // Scroll to bottom
      _scrollToBottom();
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar('Error', 'Failed to send message');
    } finally {
      isLoading.value = false;
    }
  }

  // Send important message
  Future<void> sendImportantMessage(String message) async {
    if (message.trim().isEmpty) return;
    if (!canSendMessages.value) {
      Get.snackbar('Access Denied', 'You cannot send messages to this group');
      return;
    }

    try {
      isLoading.value = true;

      // For now, send as regular message
      // You can extend this to have a special important message API
      await _messageService.sendMessage(
        interestId: interestId.value,
        message: message.trim(),
      );

      messages.value = _messageService.messages;
      totalMessages.value = _messageService.totalMessages.value;
      _scrollToBottom();
    } catch (e) {
      print('Error sending important message: $e');
      Get.snackbar('Error', 'Failed to send important message');
    } finally {
      isLoading.value = false;
    }
  }

  // Send normal message
  Future<void> sendNormalMessage(String message) async {
    await sendImportantMessage(message);
  }

  // Send quick reply message
  Future<void> sendQuickReplyMessage(String message, Color color) async {
    if (!canSendMessages.value) {
      Get.snackbar('Access Denied', 'You cannot send messages to this group');
      return;
    }

    try {
      isLoading.value = true;

      await _messageService.sendMessage(
        interestId: interestId.value,
        message: message,
      );

      messages.value = _messageService.messages;
      totalMessages.value = _messageService.totalMessages.value;
      _scrollToBottom();
    } catch (e) {
      print('Error sending quick reply: $e');
      Get.snackbar('Error', 'Failed to send quick reply');
    } finally {
      isLoading.value = false;
    }
  }

  // Set scroll callback
  void setScrollCallback(VoidCallback callback) {
    _scrollCallback = callback;
  }

  // Scroll to bottom
  void _scrollToBottom() {
    if (_scrollCallback != null) {
      _scrollCallback!();
    }
  }

  // Toggle blur effect
  void toggleBlurEffect() {
    isImportantIconPressed.value = !isImportantIconPressed.value;
  }

  // Disable blur effect
  void disableBlurEffect() {
    isImportantIconPressed.value = false;
  }

  // Cancel reply
  void cancelReply() {
    replyToMessage.value = null;
  }

  // Remove tag
  void removeTag(String username) {
    taggedUsers.remove(username);
  }

  // Refresh data
  Future<void> refreshData() async {
    await _initializeMessageScreen();
  }

  bool get hasNextPage => _messageService.hasNextPage.value;

  /// Enable real-time messaging
  Future<void> _enableRealTimeMessaging() async {
    if (!isRealTimeEnabled.value) return;

    try {
      await _messageService.enableRealTimeMessaging(interestId.value);

      // Listen for typing indicators
      _listenToTypingIndicators();

      // Listen for socket errors
      _listenToSocketErrors();

      print('✅ [MESSAGE CONTROLLER] Real-time messaging enabled');
    } catch (e) {
      print('❌ [MESSAGE CONTROLLER] Failed to enable real-time messaging: $e');
      _handleSocketError(e.toString());
    }
  }

  /// Listen to socket errors
  void _listenToSocketErrors() {
    if (_socketService != null) {
      _socketService!.errorStream.listen((errorData) {
        _handleSocketError(errorData['error']?.toString() ?? 'Unknown error');
      });
    }
  }

  /// Listen to typing indicators
  void _listenToTypingIndicators() {
    // Update typing users text whenever it changes
    ever(_messageService.typingUsers, (List<String> typingUsers) {
      typingUsersText.value = _messageService.getTypingUsersText();
    });
  }

  /// Handle text input changes for typing indicators
  void onTextChanged(String text) {
    if (!isRealTimeEnabled.value) return;

    // Cancel previous timers
    _typingTimer?.cancel();
    _stopTypingTimer?.cancel();

    if (text.isNotEmpty) {
      // Send typing indicator if not already typing
      if (!isTyping.value) {
        _messageService.sendTypingIndicator();
        isTyping.value = true;
      }

      // Set timer to send stop typing after 2 seconds of inactivity
      _stopTypingTimer = Timer(const Duration(seconds: 2), () {
        _sendStopTypingIndicator();
      });
    } else {
      // Send stop typing immediately if text is empty
      _sendStopTypingIndicator();
    }
  }

  /// Send stop typing indicator
  void _sendStopTypingIndicator() {
    if (isTyping.value) {
      _messageService.sendStopTypingIndicator();
      isTyping.value = false;
    }
  }

  /// Get connection status
  String get connectionStatus {
    if (!isRealTimeEnabled.value) return 'REST API';
    if (_socketService == null) return 'Socket Unavailable';
    return _socketService!.statusText;
  }

  /// Check if real-time messaging is active
  bool get isRealTimeActive =>
      isRealTimeEnabled.value && _socketService?.isConnected.value == true;

  /// Handle socket errors
  void _handleSocketError(String error) {
    print('❌ [MESSAGE CONTROLLER] Socket error: $error');

    // Show user-friendly error message
    Get.snackbar(
      'Connection Issue',
      'Real-time messaging temporarily unavailable. Messages will still be sent.',
      backgroundColor: Colors.orange.withOpacity(0.8),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );

    // Disable real-time features but keep messaging functional
    isRealTimeEnabled.value = false;
  }

  /// Get connection status for debugging
  String get connectionStatusDebug {
    if (!isRealTimeEnabled.value) return 'REST API Mode';
    if (_socketService == null) return 'Socket Service Unavailable';
    return _socketService!.statusText;
  }
}
