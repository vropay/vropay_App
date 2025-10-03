import 'dart:async';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vropay_final/app/core/api/api_constant.dart';
import 'package:vropay_final/app/core/models/api_response.dart';
import 'package:vropay_final/app/core/network/api_client.dart';
import 'package:vropay_final/app/core/network/api_exception.dart';
import 'package:vropay_final/app/core/services/socket_service.dart';

class MessageService extends GetxService {
  final ApiClient _apiClient = ApiClient();
  final GetStorage _storage = GetStorage();
  SocketService? _socketService;

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxInt totalMessages = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasNextPage = false.obs;

  // Real-time messaging
  final RxBool isRealTimeEnabled = false.obs;
  final RxString currentInterestId = ''.obs;
  final RxList<String> typingUsers = <String>[].obs;

  // Stream subscriptions
  StreamSubscription<Map<String, dynamic>>? _messageSubscription;
  StreamSubscription<Map<String, dynamic>>? _typingSubscription;
  StreamSubscription<Map<String, dynamic>>? _stopTypingSubscription;

  @override
  void onInit() {
    super.onInit();
    _apiClient.init();
    _initializeSocketService();
  }

  @override
  void onClose() {
    _disposeStreams();
    super.onClose();
  }

  /// Initialize Socket.IO service
  void _initializeSocketService() {
    try {
      _socketService = Get.find<SocketService>();
      isRealTimeEnabled.value = true;
      print('✅ [MESSAGE SERVICE] Socket service initialized');
    } catch (e) {
      print('⚠️ [MESSAGE SERVICE] Socket service not available: $e');
      isRealTimeEnabled.value = false;
    }
  }

  /// Dispose stream subscriptions
  void _disposeStreams() {
    _messageSubscription?.cancel();
    _typingSubscription?.cancel();
    _stopTypingSubscription?.cancel();
  }

  // Send a message to an interest group
  Future<Map<String, dynamic>> sendMessage({
    required String interestId,
    required String message,
    String? replyToMessageId,
    List<String>? taggedUsers,
  }) async {
    try {
      isLoading.value = true;

      // Use Socket.IO for real-time messaging if available
      if (isRealTimeEnabled.value && _socketService != null) {
        print('📤 [MESSAGE SERVICE] Sending message via Socket.IO');

        // Prepare message data for socket
        final messageData = {
          'interestId': interestId,
          'message': message,
          'userId': _storage.read('user_id'),
          'timestamp': DateTime.now().toIso8601String(),
          if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
          if (taggedUsers != null && taggedUsers.isNotEmpty)
            'taggedUsers': taggedUsers,
        };

        _socketService!.sendMessage(messageData);

        // Return optimistic message data
        final optimisticMessage = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'message': message,
          'interestId': interestId,
          'userId': {
            '_id': _storage.read('user_id'),
            'name': _storage.read('user_name') ?? 'You'
          },
          'createdAt': DateTime.now().toIso8601String(),
          'isOptimistic': true,
        };

        // Add optimistic message to UI immediately
        final transformedMessage = _transformMessage(optimisticMessage);
        messages.insert(0, transformedMessage);
        totalMessages.value++;

        return transformedMessage;
      } else {
        // Fallback to REST API
        print('📤 [MESSAGE SERVICE] Sending message via REST API');
        final response = await _apiClient.post(
          ApiConstant.sendMessage,
          data: {
            'interestId': interestId,
            'message': message,
            if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
            if (taggedUsers != null && taggedUsers.isNotEmpty)
              'taggedUsers': taggedUsers,
          },
        );

        if (response.statusCode == 201) {
          final apiResponse =
              ApiResponse.fromJson(response.data, (data) => data);
          if (apiResponse.success) {
            // Add the new message to the list
            final transformedMessage = _transformMessage(apiResponse.data);
            messages.insert(0, transformedMessage);
            totalMessages.value++;
            return transformedMessage;
          } else {
            throw ApiException(apiResponse.message);
          }
        } else {
          throw ApiException('Failed to send message');
        }
      }
    } catch (e) {
      print('Error sending message: $e');
      throw ApiException('Failed to send message: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Get messages for an interest with pagination
  Future<List<Map<String, dynamic>>> getInterestMessages({
    required String interestId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      isLoading.value = true;

      final response = await _apiClient.get(
        '${ApiConstant.getInterestMessages}/$interestId?page=$page&limit=$limit',
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(response.data, (data) => data);
        if (apiResponse.success) {
          final data = apiResponse.data;
          final messagesList =
              List<Map<String, dynamic>>.from(data['messages'] ?? []);
          final pagination = data['pagination'] ?? {};

          // Update pagination info
          currentPage.value = pagination['currentPage'] ?? page;
          hasNextPage.value = pagination['hasNext'] ?? false;
          totalMessages.value = pagination['totalMessages'] ?? 0;

          // Transform messages to match your UI format
          final transformedMessages = messagesList
              .map((message) => _transformMessage(message))
              .toList();

          if (page == 1) {
            messages.value = transformedMessages;
          } else {
            messages.addAll(transformedMessages);
          }

          return transformedMessages;
        } else {
          throw ApiException(apiResponse.message);
        }
      } else if (response.statusCode == 404) {
        print(
            '⚠️ [MESSAGE SERVICE] Messages not found (404), returning empty list');
        // Interest not found, return empty messages list
        if (page == 1) {
          messages.value = [];
        }
        return [];
      } else {
        throw ApiException('Failed to get messages');
      }
    } catch (e) {
      print('Error getting messages: $e');
      throw ApiException('Failed to get messages: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Get user count for an interest
  Future<int> getInterestUserCount(String interestId) async {
    try {
      isLoading.value = true;

      // GET /api/messages/interest/:interestId/user-count
      final response = await _apiClient.get(
        '${ApiConstant.getInterestUserCount}/$interestId/user-count',
      );

      if (response.statusCode == 200) {
        final apiResponse = ApiResponse.fromJson(response.data, (data) => data);
        if (apiResponse.success) {
          return apiResponse.data['userCount'] ?? 0;
        } else {
          throw ApiException(apiResponse.message);
        }
      } else {
        throw ApiException('Failed to get user count');
      }
    } catch (e) {
      print('Error getting user count: $e');
      throw ApiException('Failed to get user count: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Load more messages (pagination)
  Future<void> loadMoreMessages(String interestId) async {
    if (hasNextPage.value && !isLoading.value) {
      await getInterestMessages(
        interestId: interestId,
        page: currentPage.value + 1,
      );
    }
  }

  // Transform message from API to UI format
  Map<String, dynamic> _transformMessage(Map<String, dynamic> apiMessage) {
    final user = apiMessage['userId'] ?? {};
    final interest = apiMessage['interestId'] ?? {};

    return {
      'id': apiMessage['_id'],
      'message': apiMessage['message'],
      'sender': user['name'] ??
          '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim(),
      'timestamp': apiMessage['createdAt'],
      'isOwnMessage': _isOwnMessage(user['_id']),
      'avatarColor': _getAvatarColor(user['_id']),
      'interestName': interest['name'] ?? 'Unknown Interest',
    };
  }

  // Check if message is from current user
  bool _isOwnMessage(String? userId) {
    final currentUserId = _storage.read('user_id');
    return userId == currentUserId;
  }

  // Get avatar color based on user ID
  Color _getAvatarColor(String? userId) {
    if (userId == null) return const Color(0xFF9E9E9E);

    final colors = [
      const Color(0xFF2196F3),
      const Color(0xFF4CAF50),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFF44336),
      const Color(0xFF00BCD4),
      const Color(0xFF8BC34A),
      const Color(0xFFFFC107),
    ];

    final hash = userId.hashCode;
    return colors[hash.abs() % colors.length];
  }

  // Clear messages
  void clearMessages() {
    messages.clear();
    currentPage.value = 1;
    hasNextPage.value = false;
    totalMessages.value = 0;
  }

  /// Enable real-time messaging for an interest
  Future<void> enableRealTimeMessaging(String interestId) async {
    if (!isRealTimeEnabled.value || _socketService == null) {
      print('⚠️ [MESSAGE SERVICE] Real-time messaging not available');
      return;
    }

    try {
      currentInterestId.value = interestId;

      // Join the interest room
      await _socketService!.joinInterest(interestId);

      // Setup real-time listeners
      _setupRealTimeListeners();

      print(
          '✅ [MESSAGE SERVICE] Real-time messaging enabled for interest: $interestId');
    } catch (e) {
      print('❌ [MESSAGE SERVICE] Failed to enable real-time messaging: $e');
    }
  }

  /// Disable real-time messaging
  void disableRealTimeMessaging() {
    if (_socketService != null && currentInterestId.value.isNotEmpty) {
      _socketService!.leaveInterest();
    }

    _disposeStreams();
    currentInterestId.value = '';
    typingUsers.clear();

    print('🔌 [MESSAGE SERVICE] Real-time messaging disabled');
  }

  /// Setup real-time event listeners
  void _setupRealTimeListeners() {
    if (_socketService == null) return;

    // Listen for new messages
    _messageSubscription = _socketService!.messageStream.listen((data) {
      print('📨 [MESSAGE SERVICE] Real-time message received: $data');

      // Check if message is for current interest
      if (data['interestId'] == currentInterestId.value) {
        final transformedMessage = _transformMessage(data);

        // Check if message already exists (avoid duplicates)
        final messageId = transformedMessage['id'];
        final existingIndex =
            messages.indexWhere((msg) => msg['id'] == messageId);

        if (existingIndex == -1) {
          // Add new message
          messages.insert(0, transformedMessage);
          totalMessages.value++;
        } else {
          // Update existing optimistic message
          messages[existingIndex] = transformedMessage;
        }
      }
    });

    // Listen for typing indicators
    _typingSubscription = _socketService!.typingStream.listen((data) {
      if (data['interestId'] == currentInterestId.value) {
        final userId = data['userId'];
        if (userId != _storage.read('user_id') &&
            !typingUsers.contains(userId)) {
          typingUsers.add(userId);
        }
      }
    });
  }

  /// Send typing indicator
  void sendTypingIndicator() {
    if (isRealTimeEnabled.value &&
        _socketService != null &&
        currentInterestId.value.isNotEmpty) {
      _socketService!.sendTypingIndicator(currentInterestId.value);
    }
  }

  /// Send stop typing indicator
  void sendStopTypingIndicator() {
    if (isRealTimeEnabled.value &&
        _socketService != null &&
        currentInterestId.value.isNotEmpty) {
      _socketService!.sendStopTypingIndicator(currentInterestId.value);
    }
  }

  /// Get typing users display text
  String getTypingUsersText() {
    if (typingUsers.isEmpty) return '';

    if (typingUsers.length == 1) {
      return '${typingUsers.first} is typing...';
    } else if (typingUsers.length == 2) {
      return '${typingUsers.join(' and ')} are typing...';
    } else {
      return '${typingUsers.length} people are typing...';
    }
  }
}
