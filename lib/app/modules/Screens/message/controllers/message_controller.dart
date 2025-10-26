import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/message_service.dart';
import 'package:vropay_final/app/core/services/interest_service.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';
import 'package:vropay_final/app/core/services/socket_service.dart';
import 'package:vropay_final/app/modules/Screens/news/controllers/news_controller.dart';
import 'package:vropay_final/app/core/services/learn_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:vropay_final/app/routes/app_pages.dart';

class MessageController extends GetxController {
  // Services
  final MessageService _messageService = Get.find<MessageService>();
  final InterestService _interestService = Get.find<InterestService>();
  final AuthService _authService = Get.find<AuthService>();
  final LearnService _learnService = Get.find<LearnService>();
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

  // Search-related data from navigation arguments for highlighted content
  final RxString categoryId = ''.obs;
  final RxString subCategoryId = ''.obs;
  final RxString topicId = ''.obs;

  // Search functionality (similar to NewsController)
  final RxString searchText = ''.obs;
  final RxBool isSearching = false.obs;
  final RxList<Map<String, dynamic>> searchResults =
      <Map<String, dynamic>>[].obs;

  // Search debouncing timer
  Timer? _searchTimer;

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

    // Listen for new messages and auto-scroll
    ever(messages, (List<Map<String, dynamic>> newMessages) {
      if (newMessages.isNotEmpty) {
        // Auto-scroll to bottom when new messages arrive
        Future.delayed(const Duration(milliseconds: 200), () {
          _scrollToBottom();
          print(
              '📜 [MESSAGE CONTROLLER] Auto-scrolled due to new messages (total: ${newMessages.length})');
        });
      }
    });

    // Listen for message count changes (more specific for new messages)
    ever(totalMessages, (int count) {
      if (count > 0) {
        // Auto-scroll when message count increases (new message added)
        Future.delayed(const Duration(milliseconds: 150), () {
          _scrollToBottom();
          print(
              '📜 [MESSAGE CONTROLLER] Auto-scrolled due to message count change: $count');
        });
      }
    });
  }

  @override
  void onClose() {
    _disposeTimers();
    _searchTimer?.cancel(); // Cancel search timer
    _messageService.disableRealTimeMessaging();
    _disconnectFromSocket();
    messageController.dispose();
    super.onClose();
  }

  // Validate current interestId via GET /api/user-count/:id.
  // If valid, updates interestId/interestName from server.
  // If invalid, tries to resolve by interestName from /api/interests.
  Future<void> _validateAndResolveInterest() async {
    try {
      final id = interestId.value;
      if (id.isEmpty) return;

      // 1) Try user-count endpoint to validate id quickly
      final meta = await _interestService.resolveInterestMeta(id);
      if (meta != null && (meta['interestId']?.isNotEmpty ?? false)) {
        // Server-confirmed id/name
        interestId.value = meta['interestId'];
        if ((meta['interestName']?.isNotEmpty ?? false)) {
          interestName.value = meta['interestName'];
        }
        print(
            '🔎 [VALIDATION] Interest validated via server: id=${interestId.value}, name=${interestName.value}');
        return;
      }

      // 2) Resolve by name from /api/interests as fallback
      final interestsResp = await _authService.getInterests();
      if (interestsResp['interests'] is List) {
        final list = interestsResp['interests'] as List;
        final match = list.firstWhere(
          (i) =>
              i is Map<String, dynamic> &&
              (i['name']?.toString().toLowerCase() ?? '') ==
                  interestName.value.toLowerCase(),
          orElse: () => <String, dynamic>{},
        );
        if (match.isNotEmpty) {
          final resolvedId = match['_id']?.toString();
          final resolvedName = match['name']?.toString();
          if (resolvedId != null && resolvedId.isNotEmpty) {
            interestId.value = resolvedId;
            if (resolvedName != null && resolvedName.isNotEmpty) {
              interestName.value = resolvedName;
            }
            print(
                '🧭 [VALIDATION] Interest resolved by name: id=${interestId.value}, name=${interestName.value}');
            return;
          }
        }
      }

      // If still unresolved, keep existing values and continue (UI will show 0 members)
      print(
          '⚠️ [VALIDATION] Could not validate/resolve interest. Proceeding with provided id/name.');
    } catch (e) {
      print('❌ [VALIDATION] Error validating interest: $e');
    }
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
    } catch (e) {
      print('❌ [MESSAGE CONTROLLER] Failed to initialize socket service: $e');
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

        // Add timeout for socket connection
        final connected = await _socketService!
            .connect(
          authToken: authToken,
          userId: currentUser.id,
        )
            .timeout(
          Duration(seconds: 10),
          onTimeout: () {
            print('⏰ [MESSAGE CONTROLLER] Socket connection timeout');
            return false;
          },
        );

        if (connected) {
          print('✅ [MESSAGE CONTROLLER] Connected to socket server');
        } else {
          print(
              '⚠️ [MESSAGE CONTROLLER] Socket connection failed, using REST API fallback');
          print(
              '⚠️ [MESSAGE CONTROLLER] Socket status: ${_socketService!.debugStatusText}');
          isRealTimeEnabled.value = false;
        }
      }
    } catch (e) {
      print('❌ [MESSAGE CONTROLLER] Failed to connect to socket: $e');
      print(
          '❌ [MESSAGE CONTROLLER] Socket status: ${_socketService?.debugStatusText ?? "Unknown"}');
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
      // Do not toggle global spinner for send; UI stays responsive

      // Get interest data from arguments
      print('📥 [MESSAGE CONTROLLER] Getting arguments...');
      if (Get.arguments != null) {
        print('📥 [MESSAGE CONTROLLER] Arguments received: ${Get.arguments}');
        interestId.value = Get.arguments['interestId'] ?? '';
        interestName.value =
            Get.arguments['interestName'] ?? 'Unknown Interest';

        // Extract search-related IDs for highlighted content sharing
        // The navigation now correctly passes:
        // - categoryId as mainCategoryId (for search API)
        // - subCategoryId as subCategoryId (for search API)
        // - topicId as topicId (for search API)
        // - interestId for messaging

        categoryId.value = Get.arguments['categoryId'] ??
            Get.arguments['mainCategoryId'] ??
            '';
        subCategoryId.value = Get.arguments['subCategoryId'] ?? '';
        topicId.value = Get.arguments['topicId'] ??
            interestId.value; // Fallback to interestId if topicId not provided

        print('📥 [MESSAGE CONTROLLER] Parsed values:');
        print('   - interestId: "${interestId.value}"');
        print('   - interestName: "${interestName.value}"');
        print('   - categoryId: "${categoryId.value}"');
        print('   - subCategoryId: "${subCategoryId.value}"');
        print('   - topicId: "${topicId.value}"');
        // One-line explicit log for selected interest
        print(
            '🎯 [MESSAGE CONTROLLER] Using interest -> id: ${interestId.value}, name: ${interestName.value}');
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

      // Validate/resolve interest before loading
      await _validateAndResolveInterest();

      // Load critical data first (messages and permissions)
      print('🔄 [MESSAGE CONTROLLER] Loading critical data first...');
      await Future.wait([
        _loadMessages(), // Load messages first
        _checkUserPermissions(), // Check permissions
      ]);

      // Load non-critical data in background
      _loadInterestDetails(); // Don't await - load in background

      // Debug: List all available interests
      listAllInterests(); // Don't await - run in background
      // Note: Do not auto-switch interest. Keep the user-selected interest even
      // if it's not in user's selected topics. Switching caused defaulting to
      // another topic like "Manifestation" unexpectedly.

      // Connect to socket and enable real-time messaging after critical data is loaded
      if (isRealTimeEnabled.value) {
        await _connectToSocketAndEnableRealTime();
      }

      print(
          '✅ [MESSAGE CONTROLLER] Message screen initialization completed successfully!');

      // Persist this screen as last visited (so Community Forum AI fallback can open it later)
      await saveLastVisitedScreen();

      // Final auto-scroll to ensure we're at the bottom after everything is loaded
      if (messages.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _scrollToBottom();
          print('📜 [MESSAGE CONTROLLER] Final auto-scroll to latest message');
        });
      }
    } catch (e) {
      print('❌ [MESSAGE CONTROLLER] Error initializing message screen: $e');
      print('❌ [MESSAGE CONTROLLER] Stack trace: ${StackTrace.current}');
      Get.snackbar('Error', 'Failed to load message data');
    } finally {
      // Keep loading untouched for send operation
      print('🏁 [MESSAGE CONTROLLER] Loading state set to false');
    }
  }

  // Persist this Message screen as last visited so Community Forum AI fallback
  // can restore it after app restarts. We store route + arguments (JSON).
  Future<void> saveLastVisitedScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = interestName.value.isNotEmpty
          ? 'Messages — ${interestName.value}'
          : 'Messages';
      final route = Routes.MESSAGE_SCREEN;
      final args = {
        'interestId': interestId.value,
        'interestName': interestName.value,
        'categoryId': categoryId.value,
        'subCategoryId': subCategoryId.value,
        'topicId': topicId.value,
      };

      await prefs.setString('last_visited_screen_name', name);
      await prefs.setString('last_visited_screen_route', route);
      await prefs.setString('last_visited_screen_args', jsonEncode(args));

      print(
          '💾 [MESSAGE CONTROLLER] Saved last visited screen: $name -> $route with args: $args');
    } catch (e) {
      print('⚠️ [MESSAGE CONTROLLER] Failed to save last visited screen: $e');
    }
  }

  // Load interest details (name and member count)
  Future<void> _loadInterestDetails() async {
    try {
      print(
          '📊 [INTEREST DETAILS] Starting to load interest details for interestId: "${interestId.value}"');
      final details =
          await _interestService.getInterestDetails(interestId.value);

      // Update interest name from API if available and not "Unknown Interest"
      if (details['interestName'] != null &&
          details['interestName'].isNotEmpty &&
          details['interestName'] != 'Unknown Interest') {
        interestName.value = details['interestName'];
        print(
            '📊 [INTEREST DETAILS] Interest name updated from API: "${interestName.value}"');
      } else {
        print(
            '📊 [INTEREST DETAILS] Keeping existing interest name: "${interestName.value}"');
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
      // Keep the existing interest name from arguments
      print(
          '📊 [INTEREST DETAILS] Keeping interest name from arguments: "${interestName.value}"');
    }
  }

  // Check user permissions (allow all users to send messages)
  Future<void> _checkUserPermissions() async {
    try {
      print('🔐 [PERMISSIONS] Starting permission check...');
      final currentUser = _authService.currentUser.value!;
      print(
          '🔐 [PERMISSIONS] Checking permissions for user: ${currentUser.id}');

      // Check if user has this interest (for display purposes only)
      print(
          '🔐 [PERMISSIONS] Checking if user has interest: ${interestId.value}');
      final hasInterest = await _interestService.checkUserHasInterest(
          currentUser.id, interestId.value);
      hasUserInterest.value = hasInterest;
      print('🔐 [PERMISSIONS] User has interest: $hasInterest');

      // Get community access preference (for display purposes only)
      print('🔐 [PERMISSIONS] Getting community access preference...');
      final access =
          await _interestService.getUserCommunityAccess(currentUser.id);
      communityAccess.value = access;
      print('🔐 [PERMISSIONS] Community access: $access');

      // Allow all users to send messages regardless of interest or community access
      canSendMessages.value = true;
      print(
          '🔐 [PERMISSIONS] Can send messages: ${canSendMessages.value} (All users allowed)');
      print('✅ [PERMISSIONS] Permission check completed successfully');
    } catch (e) {
      print('❌ [PERMISSIONS] Error checking user permissions: $e');
      print('❌ [PERMISSIONS] Stack trace: ${StackTrace.current}');
      // Even on error, allow users to send messages
      canSendMessages.value = true;
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

      // Auto-scroll to bottom after initial messages are loaded
      if (messages.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollToBottom();
          print('📜 [MESSAGES] Auto-scrolled to latest message');
        });
      }
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

  // Debug method to list all available interests
  Future<void> listAllInterests() async {
    try {
      print('🔍 [DEBUG] Fetching all available interests...');
      final response = await _authService.getInterests();

      if (response['interests'] is List) {
        final interestsList = response['interests'] as List;
        print('📋 [DEBUG] Available interests:');

        for (int i = 0; i < interestsList.length; i++) {
          final interest = interestsList[i];
          if (interest is Map<String, dynamic>) {
            final id = interest['_id'] ?? 'No ID';
            final name = interest['name'] ?? 'No Name';
            print('   ${i + 1}. ID: $id, Name: $name');
          }
        }

        // Show current interest being used
        print('🎯 [DEBUG] Current interest being used:');
        print('   - ID: ${interestId.value}');
        print('   - Name: ${interestName.value}');

        // Check if current interest exists
        final currentInterestExists = interestsList.any((interest) =>
            interest is Map<String, dynamic> &&
            interest['_id'] == interestId.value);

        if (currentInterestExists) {
          print('✅ [DEBUG] Current interest ID exists in database');
        } else {
          print('❌ [DEBUG] Current interest ID does NOT exist in database!');
          print('💡 [DEBUG] Try using one of the valid IDs above');
        }

        // Show user's selected interests
        final currentUser = _authService.currentUser.value;
        if (currentUser != null && currentUser.selectedTopics != null) {
          print('👤 [DEBUG] User\'s selected interests:');
          final userSelectedIds = currentUser.selectedTopics!;

          for (final selectedId in userSelectedIds) {
            // Find the interest name for this ID
            final matchingInterest = interestsList.firstWhere(
              (interest) =>
                  interest is Map<String, dynamic> &&
                  interest['_id'] == selectedId,
              orElse: () => <String, dynamic>{},
            );

            if (matchingInterest.isNotEmpty) {
              final name = matchingInterest['name'] ?? 'Unknown';
              print('   - ID: $selectedId, Name: $name');
            } else {
              print('   - ID: $selectedId, Name: NOT FOUND IN DATABASE');
            }
          }

          // Check if current interest is in user's selected topics
          if (userSelectedIds.contains(interestId.value)) {
            print('✅ [DEBUG] Current interest is in user\'s selected topics');
          } else {
            print(
                '⚠️ [DEBUG] Current interest is NOT in user\'s selected topics');
            print(
                '💡 [DEBUG] This is OK - user can still view messages in any interest');
            print(
                '💡 [DEBUG] Only switching will happen if interest doesn\'t exist in database');
          }
        } else {
          print('❌ [DEBUG] User has no selected interests');
        }
      } else {
        print('❌ [DEBUG] No interests found or invalid format');
      }
    } catch (e) {
      print('❌ [DEBUG] Error fetching interests: $e');
    }
  }

  // (Removed) Auto-switch helper intentionally not used to avoid overriding
  // user-selected interests.

  // Method to automatically use a valid interest from user's selected topics
  Future<void> useValidInterestFromUserTopics() async {
    try {
      final currentUser = _authService.currentUser.value;
      if (currentUser != null &&
          currentUser.selectedTopics != null &&
          currentUser.selectedTopics!.isNotEmpty) {
        final userSelectedIds = currentUser.selectedTopics!;

        // Get all interests to find names
        final response = await _authService.getInterests();
        if (response['interests'] is List) {
          final interestsList = response['interests'] as List;

          // Find the first valid interest from user's selected topics
          for (final selectedId in userSelectedIds) {
            final matchingInterest = interestsList.firstWhere(
              (interest) =>
                  interest is Map<String, dynamic> &&
                  interest['_id'] == selectedId,
              orElse: () => <String, dynamic>{},
            );

            if (matchingInterest.isNotEmpty) {
              final name = matchingInterest['name'] ?? 'Unknown';
              print(
                  '🔄 [DEBUG] Switching to valid interest: $name ($selectedId)');

              // Update the current interest
              interestId.value = selectedId;
              interestName.value = name;

              // Reload messages for the new interest
              await _loadMessages();

              print('✅ [DEBUG] Successfully switched to valid interest');
              return;
            }
          }
        }
      }

      print('❌ [DEBUG] No valid interests found in user\'s selected topics');
    } catch (e) {
      print('❌ [DEBUG] Error switching to valid interest: $e');
    }
  }

  // Debug method to test REST API directly
  Future<void> sendMessageViaRestApi() async {
    if (messageController.text.trim().isEmpty) return;

    try {
      print('🧪 [MESSAGE CONTROLLER] Testing REST API directly...');
      await _messageService.sendMessageViaRestApi(
        interestId: interestId.value,
        message: messageController.text.trim(),
      );

      // Update local messages
      messages.value = _messageService.messages;
      totalMessages.value = _messageService.totalMessages.value;

      // Clear input
      messageController.clear();

      Get.snackbar('Success', 'Message sent via REST API',
          backgroundColor: Colors.green);
    } catch (e) {
      print('❌ [MESSAGE CONTROLLER] REST API Error: $e');
      Get.snackbar('Error', 'REST API failed: $e', backgroundColor: Colors.red);
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
      // Do not toggle global spinner for send; UI stays responsive

      // Send stop typing indicator
      _sendStopTypingIndicator();

      print(
          '🚀 [MESSAGE CONTROLLER] Sending message: "${messageController.text.trim()}"');
      print('🚀 [MESSAGE CONTROLLER] To interest: ${interestId.value}');

      // Force REST API for now since Socket.IO is not working
      await _messageService.sendMessage(
        interestId: interestId.value,
        message: messageController.text.trim(),
        replyToMessageId: replyToMessage.value?['id'],
        taggedUsers: taggedUsers.isNotEmpty ? taggedUsers : null,
        forceRestApi: true, // Force REST API since Socket.IO is failing
      );

      // Update local messages
      messages.value = _messageService.messages;
      totalMessages.value = _messageService.totalMessages.value;

      // Clear input and reply
      messageController.clear();
      replyToMessage.value = null;
      taggedUsers.clear();

      // Auto-scroll to new message after a brief delay to ensure UI is updated
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
        print('📜 [MESSAGE CONTROLLER] Auto-scrolled after sending message');
      });
    } catch (e) {
      print('❌ [MESSAGE CONTROLLER] Error sending message: $e');
      String errorMessage = 'Failed to send message';

      // Check if it's a specific error type
      if (e.toString().contains('User not authenticated')) {
        errorMessage = 'Please log in again to send messages';
      } else if (e.toString().contains('Database error')) {
        errorMessage = 'Server error occurred. Please try again.';
      } else if (e.toString().contains('Connection timeout')) {
        errorMessage = 'Connection timeout. Please check your internet.';
      }

      Get.snackbar('Error', errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3));
    } finally {
      // Keep loading untouched for send operation
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

      print(
          '🔥 [MESSAGE CONTROLLER] Sending important message: "${message.trim()}"');
      print('🔥 [MESSAGE CONTROLLER] To interest: ${interestId.value}');

      // Send important message via dedicated API
      await _messageService.sendImportantMessage(
        interestId: interestId.value,
        message: message.trim(),
      );

      // Update local messages
      messages.value = _messageService.messages;
      totalMessages.value = _messageService.totalMessages.value;

      print('✅ [MESSAGE CONTROLLER] Important message sent successfully');

      // Auto-scroll to new message
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    } catch (e) {
      print('❌ [MESSAGE CONTROLLER] Error sending important message: $e');
      String errorMessage = 'Failed to send important message';

      // Check if it's a specific error type
      if (e.toString().contains('User not authenticated')) {
        errorMessage = 'Please log in again to send important messages';
      } else if (e.toString().contains('Database error')) {
        errorMessage = 'Server error occurred. Please try again.';
      } else if (e.toString().contains('Connection timeout')) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else if (e.toString().contains('not a member')) {
        errorMessage = 'You are not a member of this interest group';
      } else if (e.toString().contains('Interest not found')) {
        errorMessage = 'This interest group no longer exists';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Send normal message
  Future<void> sendNormalMessage(String message) async {
    if (message.trim().isEmpty) return;
    if (!canSendMessages.value) {
      Get.snackbar('Access Denied', 'You cannot send messages to this group');
      return;
    }

    try {
      isLoading.value = true;

      print(
          '📤 [MESSAGE CONTROLLER] Sending normal message: "${message.trim()}"');
      print('📤 [MESSAGE CONTROLLER] To interest: ${interestId.value}');

      // Send normal message via regular API
      await _messageService.sendMessage(
        interestId: interestId.value,
        message: message.trim(),
        forceRestApi: true, // Force REST API since Socket.IO is failing
      );

      // Update local messages
      messages.value = _messageService.messages;
      totalMessages.value = _messageService.totalMessages.value;

      print('✅ [MESSAGE CONTROLLER] Normal message sent successfully');

      // Auto-scroll to new message
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    } catch (e) {
      print('❌ [MESSAGE CONTROLLER] Error sending normal message: $e');
      String errorMessage = 'Failed to send message';

      // Check if it's a specific error type
      if (e.toString().contains('User not authenticated')) {
        errorMessage = 'Please log in again to send messages';
      } else if (e.toString().contains('Database error')) {
        errorMessage = 'Server error occurred. Please try again.';
      } else if (e.toString().contains('Connection timeout')) {
        errorMessage = 'Connection timeout. Please check your internet.';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Share an entry as a message
  Future<void> shareEntry({
    required String message,
    required String entryId,
  }) async {
    if (message.trim().isEmpty) return;
    if (!canSendMessages.value) {
      Get.snackbar('Access Denied', 'You cannot send messages to this group');
      return;
    }

    try {
      isLoading.value = true;

      print('📚 [MESSAGE CONTROLLER] Sharing entry: $entryId');
      print('📚 [MESSAGE CONTROLLER] Message: "${message.trim()}"');
      print('📚 [MESSAGE CONTROLLER] To interest: ${interestId.value}');
      print('📚 [MESSAGE CONTROLLER] CategoryId: ${categoryId.value}');
      print('📚 [MESSAGE CONTROLLER] SubCategoryId: ${subCategoryId.value}');
      print('📚 [MESSAGE CONTROLLER] TopicId: ${topicId.value}');

      // Validate that we have the required IDs
      if (categoryId.value.isEmpty ||
          subCategoryId.value.isEmpty ||
          topicId.value.isEmpty) {
        throw Exception(
            'Missing required IDs for sharing. Please ensure you navigated from a valid topic screen.');
      }

      // Share entry via dedicated API
      await _messageService.shareEntry(
        interestId: interestId.value,
        message: message.trim(),
        mainCategoryId: categoryId.value,
        subCategoryId: subCategoryId.value,
        topicId: topicId.value,
        entryId: entryId,
      );

      // Update local messages
      messages.value = _messageService.messages;
      totalMessages.value = _messageService.totalMessages.value;

      print('✅ [MESSAGE CONTROLLER] Entry shared successfully');

      // Auto-scroll to new message
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });

      // Show success message
      Get.snackbar(
        'Entry Shared',
        'Your entry has been shared with the community',
        backgroundColor: const Color(0xFF714FC0),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      print('❌ [MESSAGE CONTROLLER] Error sharing entry: $e');
      String errorMessage = 'Failed to share entry';

      // Check if it's a specific error type
      if (e.toString().contains('User not authenticated')) {
        errorMessage = 'Please log in again to share entries';
      } else if (e.toString().contains('Database error')) {
        errorMessage = 'Server error occurred. Please try again.';
      } else if (e.toString().contains('Connection timeout')) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else if (e.toString().contains('not a member')) {
        errorMessage = 'You are not a member of this interest group';
      } else if (e.toString().contains('Interest not found')) {
        errorMessage = 'This interest group no longer exists';
      } else if (e.toString().contains('Entry not found')) {
        errorMessage = 'The selected entry no longer exists';
      } else if (e.toString().contains('Topic not found')) {
        errorMessage = 'The selected topic no longer exists';
      } else if (e.toString().contains('Main category not found')) {
        errorMessage = 'The selected category no longer exists';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Search entries in a topic using Knowledge Center (LearnService) API first,
  // then fallback to NewsController data if needed
  Future<List<Map<String, dynamic>>> searchEntriesInTopic({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('🔍 [MESSAGE CONTROLLER] Searching entries via LearnService');
      print('   - categoryId: ${categoryId.value}');
      print('   - subCategoryId: ${subCategoryId.value}');
      print('   - topicId: ${topicId.value}');
      print('   - query: $query');

      // Ensure required IDs
      if (categoryId.value.isEmpty ||
          subCategoryId.value.isEmpty ||
          topicId.value.isEmpty) {
        print(
            '⚠️ [MESSAGE CONTROLLER] Missing IDs for LearnService search, falling back to NewsController');
        return await _searchUsingNewsController(
            query: query, page: page, limit: limit);
      }

      // Call the same Knowledge Center search API used by News screen
      final response = await _learnService.searchEntriesInTopic(
        categoryId.value,
        subCategoryId.value,
        topicId.value,
        query,
        page: page,
        limit: limit,
      );

      if (response.success && response.data != null) {
        final rawResults = response.data!['results'] as List<dynamic>? ?? [];
        final results = rawResults.map((item) {
          final map = item as Map<String, dynamic>;
          final title = map['title']?.toString() ?? '';
          final highlighted = map['highlightedTitle']?.toString();
          return {
            '_id': map['_id']?.toString() ?? map['entryId']?.toString() ?? '',
            'title': title,
            'highlightedTitle': highlighted?.isNotEmpty == true
                ? highlighted
                : _highlightSearchText(title, query),
            'body':
                map['body']?.toString() ?? map['description']?.toString() ?? '',
            'image': map['thumbnail'] ?? map['image'] ?? '',
            'footer': map['footer'] ?? '',
            'createdAt': map['createdAt'] ?? '',
            'updatedAt': map['updatedAt'] ?? '',
          };
        }).toList();

        print(
            '✅ [MESSAGE CONTROLLER] Found ${results.length} results from LearnService');
        return results;
      }

      print(
          '⚠️ [MESSAGE CONTROLLER] LearnService returned no data, falling back to NewsController');
      return await _searchUsingNewsController(
          query: query, page: page, limit: limit);
    } catch (e) {
      print('❌ [MESSAGE CONTROLLER] Error searching entries: $e');
      // Fallback to NewsController approach on any error
      return await _searchUsingNewsController(
          query: query, page: page, limit: limit);
    }
  }

  // Fallback: use NewsController in-memory articles
  Future<List<Map<String, dynamic>>> _searchUsingNewsController({
    required String query,
    required int page,
    required int limit,
  }) async {
    try {
      NewsController newsController;

      try {
        newsController = Get.find<NewsController>();
        print('📰 [MESSAGE CONTROLLER] Found existing NewsController');
      } catch (_) {
        print(
            '📰 [MESSAGE CONTROLLER] Creating NewsController for fallback search');
        newsController = Get.put(NewsController(), tag: 'search');
        newsController.topicId = topicId.value;
        newsController.topicName = interestName.value;
        newsController.subCategoryId = subCategoryId.value;
        newsController.categoryId = categoryId.value;
      }

      if (newsController.topicId != topicId.value ||
          newsController.newsArticles.isEmpty) {
        await newsController.loadTopicNews();
      }

      final filteredNews = newsController.newsArticles.where((news) {
        final title = news['title']?.toString().toLowerCase() ?? '';
        final body = news['body']?.toString().toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        return title.contains(searchQuery) || body.contains(searchQuery);
      }).toList();

      final results = filteredNews.map((news) {
        final title = news['title']?.toString() ?? '';
        return {
          '_id': news['_id']?.toString() ?? news['entryId']?.toString() ?? '',
          'title': title,
          'highlightedTitle': _highlightSearchText(title, query),
          'body': news['body']?.toString() ?? '',
          'image': news['thumbnail'] ?? news['image'] ?? '',
          'footer': news['footer'] ?? '',
          'createdAt': news['createdAt'] ?? '',
          'updatedAt': news['updatedAt'] ?? '',
        };
      }).toList();

      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;
      final paginatedResults = results.length > endIndex
          ? results.sublist(startIndex, endIndex)
          : results.sublist(startIndex);

      print(
          '✅ [MESSAGE CONTROLLER] Fallback found ${paginatedResults.length} results from NewsController');
      return paginatedResults;
    } catch (e) {
      print('❌ [MESSAGE CONTROLLER] Fallback search failed: $e');
      return <Map<String, dynamic>>[];
    }
  }

  // Helper method to highlight search text
  String _highlightSearchText(String text, String query) {
    if (query.isEmpty) return text;

    final regex = RegExp('(${RegExp.escape(query)})', caseSensitive: false);
    return text.replaceAllMapped(
        regex, (match) => '<mark>${match.group(0)}</mark>');
  }

  // Search methods (similar to NewsController)
  void updateSearchText(String value) {
    print('🔍 [MESSAGE CONTROLLER] updateSearchText called with: "$value"');
    searchText.value = value;

    // Cancel previous timer
    _searchTimer?.cancel();

    if (value.trim().isEmpty) {
      print('🔍 [MESSAGE CONTROLLER] Clearing search results');
      _clearSearchResults();
    } else if (value.trim().length >= 2) {
      print(
          '🔍 [MESSAGE CONTROLLER] Setting up debounced search for: "$value"');
      // Set new timer for debounced search
      _searchTimer = Timer(Duration(milliseconds: 500), () {
        if (value == searchText.value) {
          // Ensure query hasn't changed
          print(
              '🔍 [MESSAGE CONTROLLER] Executing debounced search for: "$value"');
          _performSearch(value.trim());
        }
      });
    } else {
      print(
          '🔍 [MESSAGE CONTROLLER] Search text too short: "${value.length}" characters');
    }
  }

  void _performSearch(String query) async {
    try {
      isSearching.value = true;
      print('🔍 [MESSAGE CONTROLLER] Performing search for: $query');
      print('🔍 [MESSAGE CONTROLLER] Search context:');
      print('   - categoryId: "${categoryId.value}"');
      print('   - subCategoryId: "${subCategoryId.value}"');
      print('   - topicId: "${topicId.value}"');
      print('   - interestId: "${interestId.value}"');
      print('   - interestName: "${interestName.value}"');

      // Use the existing searchEntriesInTopic method
      final results = await searchEntriesInTopic(query: query);

      // Update search results
      searchResults.value = results;
      print(
          '✅ [MESSAGE CONTROLLER] Search completed: ${results.length} results');

      // Debug: Print first few results
      if (results.isNotEmpty) {
        print('🔍 [MESSAGE CONTROLLER] First result: ${results.first}');
      }
    } catch (e) {
      print('❌ [MESSAGE CONTROLLER] Search error: $e');
      print('❌ [MESSAGE CONTROLLER] Stack trace: ${StackTrace.current}');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  void clearSearch() {
    _searchTimer?.cancel();
    searchText.value = '';
    _clearSearchResults();
  }

  void _clearSearchResults() {
    searchResults.clear();
    print('🧹 [MESSAGE CONTROLLER] Clearing search results');
  }

  // Send quick reply message
  Future<void> sendQuickReplyMessage(String message, Color color) async {
    if (!canSendMessages.value) {
      Get.snackbar('Access Denied', 'You cannot send messages to this group');
      return;
    }

    try {
      isLoading.value = true;

      // Create a temporary message with the quick reply color for instant UI feedback
      final tempMessage = {
        'message': message,
        'sender': _authService.currentUser.value?.firstName ?? 'You',
        'timestamp': DateTime.now().toIso8601String(),
        'isOwnMessage': true,
        'quickReplyColor': color,
        'isQuickReply': true,
      };

      // Add the message to the local list immediately for instant UI feedback
      messages.add(tempMessage);
      totalMessages.value = messages.length;

      // Send the message via service (mark as quick reply to prevent duplicates)
      await _messageService.sendMessage(
        interestId: interestId.value,
        message: message,
        isQuickReply: true,
      );

      // Don't update messages from server - just mark the temporary message as permanent
      final tempIndex = messages.indexWhere(
          (msg) => msg['isQuickReply'] == true && msg['message'] == message);

      if (tempIndex != -1) {
        // Mark the temporary message as permanent (no longer temporary)
        messages[tempIndex]['isQuickReply'] = false;
        // Keep the color and all other properties
      }

      // Don't update totalMessages since we're not adding new messages

      // Auto-scroll to new message
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    } catch (e) {
      print('Error sending quick reply: $e');
      Get.snackbar('Error', 'Failed to send quick reply');

      // Remove the temporary message if sending failed
      if (messages.isNotEmpty && messages.last['isQuickReply'] == true) {
        messages.removeLast();
        totalMessages.value = messages.length;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Set scroll callback
  void setScrollCallback(VoidCallback callback) {
    _scrollCallback = callback;
  }

  // Scroll to bottom (private method)
  void _scrollToBottom() {
    if (_scrollCallback != null) {
      _scrollCallback!();
    }
  }

  // Public method to scroll to bottom (for manual triggers)
  void scrollToBottom() {
    _scrollToBottom();
  }

  // Immediate scroll to bottom for new messages from other users
  void scrollToNewMessage() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollToBottom();
      print(
          '📜 [MESSAGE CONTROLLER] Immediate scroll to new message from other user');
    });
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

  /// Connect to socket and enable real-time messaging
  Future<void> _connectToSocketAndEnableRealTime() async {
    if (!isRealTimeEnabled.value) return;

    try {
      print(
          '🔌 [MESSAGE CONTROLLER] Connecting to socket and enabling real-time messaging...');

      // First, ensure socket connection is established
      await _connectToSocket();

      // Wait a bit for connection to be fully ready
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if socket is connected before enabling real-time messaging
      if (_socketService?.isConnected.value == true) {
        await _enableRealTimeMessaging();
        print('✅ [MESSAGE CONTROLLER] Real-time messaging fully enabled');
      } else {
        print(
            '⚠️ [MESSAGE CONTROLLER] Socket not connected, real-time messaging disabled');
        isRealTimeEnabled.value = false;
      }
    } catch (e) {
      print(
          '❌ [MESSAGE CONTROLLER] Failed to connect and enable real-time messaging: $e');
      _handleSocketError(e.toString());
    }
  }

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
        final error = errorData['error']?.toString() ?? 'Unknown error';
        print('🚨 [MESSAGE CONTROLLER] Socket error received: $error');
        _handleSocketError(error);
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
    return _socketService!.debugStatusText;
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
    return _socketService!.debugStatusText;
  }
}
