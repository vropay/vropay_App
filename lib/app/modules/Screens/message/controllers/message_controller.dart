import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/message_service.dart';
import 'package:vropay_final/app/core/services/interest_service.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';

class MessageController extends GetxController {
  // Services
  final MessageService _messageService = Get.find<MessageService>();
  final InterestService _interestService = Get.find<InterestService>();
  final AuthService _authService = Get.find<AuthService>();

  // UI State
  final selectedFilter = ''.obs;
  final totalMessages = 0.obs;
  final messages = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final replyToMessage = Rxn<Map<String, dynamic>>();
  final taggedUsers = <String>[].obs;
  final messageController = TextEditingController();
  final isImportantIconPressed = false.obs;

  // Dynamic Data
  final RxString interestId = ''.obs;
  final RxString interestName = ''.obs;
  final RxInt memberCount = 0.obs;
  final RxBool canSendMessages = false.obs;
  final RxBool hasUserInterest = false.obs;
  final RxString communityAccess = ''.obs;

  // Socket.IO related
  final RxBool isSocketConnected = false.obs;
  final RxList<String> typingUsers = <String>[].obs;
  final RxBool isTyping = false.obs;

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

  // Typing timer
  Timer? _typingTimer;

  @override
  void onReady() {
    super.onReady();
    _initializeMessageScreen();
  }

  @override
  void onClose() {
    _typingTimer?.cancel();
    messageController.dispose();
    super.onClose();
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

  // Send a message (updated for Socket.IO)
  Future<void> sendMessage() async {
    if (messageController.text.trim().isEmpty) return;
    if (!canSendMessages.value) {
      Get.snackbar('Access Denied', 'You cannot send messages to this group');
      return;
    }

    try {
      isLoading.value = true;

      // Send via Socket.IO for real-time delivery
      final tempMessage = await _messageService.sendMessageViaSocket(
        interestId: interestId.value,
        message: messageController.text.trim(),
      );

      // Update local messages
      messages.value = _messageService.messages;
      totalMessages.value = _messageService.totalMessages.value;

      // Clear input
      messageController.clear();

      // Scroll to bottom
      _scrollToBottom();

      print('✅ [MESSAGE CONTROLLER] Message sent via Socket.IO');
    } catch (e) {
      print('❌ [MESSAGE CONTROLLER] Error sending message: $e');
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

      // Send via Socket.IO
      await _messageService.sendMessageViaSocket(
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

      await _messageService.sendMessageViaSocket(
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
}
