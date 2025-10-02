import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:vropay_final/app/core/api/api_constant.dart';
import 'package:vropay_final/app/core/models/api_response.dart';
import 'package:vropay_final/app/core/network/api_client.dart';
import 'package:vropay_final/app/core/network/api_exception.dart';

class MessageService extends GetxService {
  final ApiClient _apiClient = ApiClient();
  final GetStorage _storage = GetStorage();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxInt totalMessages = 0.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasNextPage = false.obs;

  // Socket.IO related observables
  final RxList<String> typingUsers = <String>[].obs;
  final RxMap<String, dynamic> tempMessages = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _apiClient.init();
  }

  // Send a message to an interest group (REST API - backup method)
  Future<Map<String, dynamic>> sendMessage({
    required String interestId,
    required String message,
  }) async {
    try {
      isLoading.value = true;

      final response = await _apiClient.post(
        ApiConstant.sendMessage,
        data: {
          'interestId': interestId,
          'message': message,
        },
      );

      if (response.statusCode == 201) {
        final apiResponse = ApiResponse.fromJson(response.data, (data) => data);
        if (apiResponse.success) {
          // Add the new message to the list
          final transformedMessage = _transformMessage(apiResponse.data);
          messages.insert(0, apiResponse.data);
          totalMessages.value++;
          return transformedMessage;
        } else {
          throw ApiException(apiResponse.message);
        }
      } else {
        throw ApiException('Failed to send message');
      }
    } catch (e) {
      print('Error sending message: $e');
      throw ApiException('Failed to send message: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Send message via Socket.IO (primary method)
  Future<Map<String, dynamic>> sendMessageViaSocket({
    required String interestId,
    required String message,
  }) async {
    try {
      // Create temporary message for immediate UI update
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final tempMessage = {
        'id': tempId,
        'message': message,
        'sender': _storage.read('user_name') ?? 'You',
        'timestamp': DateTime.now().toIso8601String(),
        'isOwnMessage': true,
        'avatarColor': _getAvatarColor(_storage.read('user_id')),
        'interestName': 'Current Interest',
        'isTemporary': true,
        'status': 'sending',
      };

      // Store temporary message
      tempMessages[tempId] = tempMessage;

      // Add to messages list immediately
      messages.insert(0, tempMessage);
      totalMessages.value++;

      return tempMessage;
    } catch (e) {
      print('Error sending message via socket: $e');
      throw ApiException('Failed to send message via socket: ${e.toString()}');
    }
  }

  // Socket.IO event handlers
  void handleNewMessage(dynamic data) {
    try {
      final message = _transformMessage(data);

      // Remove any temporary message with same content
      messages.removeWhere((msg) =>
          msg['isTemporary'] == true && msg['message'] == message['message']);

      // Add the real message from server
      messages.insert(0, message);
      totalMessages.value++;

      print('✅ [MESSAGE SERVICE] New message added to list');
    } catch (e) {
      print('❌ [MESSAGE SERVICE] Error handling new message: $e');
    }
  }

  void handleMessageSent(dynamic data) {
    try {
      final messageId = data['_id'] ?? data['id'];
      final message = _transformMessage(data);

      // Find and replace temporary message
      final tempIndex = messages.indexWhere((msg) =>
          msg['isTemporary'] == true && msg['message'] == message['message']);

      if (tempIndex != -1) {
        messages[tempIndex] = message;
        messages[tempIndex]['status'] = 'sent';
        messages[tempIndex]['isTemporary'] = false;
      }

      print('✅ [MESSAGE SERVICE] Message sent confirmation received');
    } catch (e) {
      print('❌ [MESSAGE SERVICE] Error handling message sent: $e');
    }
  }

  void handleMessageError(dynamic data) {
    try {
      final error = data['error'] ?? 'Unknown error';

      // Find and update temporary message with error status
      final tempIndex = messages.indexWhere(
          (msg) => msg['isTemporary'] == true && msg['status'] == 'sending');

      if (tempIndex != -1) {
        messages[tempIndex]['status'] = 'error';
        messages[tempIndex]['error'] = error;
      }

      print('❌ [MESSAGE SERVICE] Message error: $error');
    } catch (e) {
      print('❌ [MESSAGE SERVICE] Error handling message error: $e');
    }
  }

  void handleMessageDeleted(dynamic data) {
    try {
      final messageId = data['messageId'] ?? data['_id'];
      messages.removeWhere((msg) => msg['id'] == messageId);
      totalMessages.value--;
      print('✅ [MESSAGE SERVICE] Message deleted from list');
    } catch (e) {
      print('❌ [MESSAGE SERVICE] Error handling message deletion: $e');
    }
  }

  void handleUserJoined(dynamic data) {
    try {
      final user = data['user'] ?? data['username'] ?? 'Unknown User';
      print('✅ [MESSAGE SERVICE] User joined: $user');
      // You can add UI notification here if needed
    } catch (e) {
      print('❌ [MESSAGE SERVICE] Error handling user joined: $e');
    }
  }

  void handleUserLeft(dynamic data) {
    try {
      final user = data['user'] ?? data['username'] ?? 'Unknown User';
      print('✅ [MESSAGE SERVICE] User left: $user');
      // You can add UI notification here if needed
    } catch (e) {
      print('❌ [MESSAGE SERVICE] Error handling user left: $e');
    }
  }

  void handleUserTyping(dynamic data) {
    try {
      final userId = data['userId'] ?? data['user'] ?? 'Unknown';
      if (!typingUsers.contains(userId)) {
        typingUsers.add(userId);
      }
      print('⌨️ [MESSAGE SERVICE] User typing: $userId');
    } catch (e) {
      print('❌ [MESSAGE SERVICE] Error handling user typing: $e');
    }
  }

  void handleUserStopTyping(dynamic data) {
    try {
      final userId = data['userId'] ?? data['user'] ?? 'Unknown';
      typingUsers.remove(userId);
      print('⏹️ [MESSAGE SERVICE] User stopped typing: $userId');
    } catch (e) {
      print('❌ [MESSAGE SERVICE] Error handling user stop typing: $e');
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
      'status': 'sent',
      'isTemporary': false,
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
    typingUsers.clear();
    tempMessages.clear();
  }

  // Get auth headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = _storage.read('auth_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
