import 'dart:async';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vropay_final/app/core/api/api_constant.dart';

/// SocketService handles all real-time communication with the backend
/// Integrates with Socket.IO server for live messaging, typing indicators, and more
class SocketService extends GetxService {
  static SocketService get instance => Get.find<SocketService>();

  // Socket.IO client
  IO.Socket? _socket;

  // Connection state
  final RxBool isConnected = false.obs;
  final RxString connectionStatus = 'Disconnected'.obs;
  final RxString lastError = ''.obs;

  // Connection configuration
  String? _serverUrl;
  String? _authToken;
  String? _userId;

  // Event streams
  final StreamController<Map<String, dynamic>> _messageStream =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _typingStream =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _userJoinedStream =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _userLeftStream =
      StreamController.broadcast();
  final StreamController<Map<String, dynamic>> _errorStream =
      StreamController.broadcast();

  // Typing indicators
  final RxList<String> typingUsers = <String>[].obs;
  final RxMap<String, DateTime> typingTimestamps = <String, DateTime>{}.obs;

  // Current room
  String? _currentInterestId;

  // Reconnection settings
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;
  Timer? _reconnectTimer;

  @override
  void onInit() {
    super.onInit();
    _initializeConfiguration();
  }

  @override
  void onClose() {
    disconnect();
    _messageStream.close();
    _typingStream.close();
    _userJoinedStream.close();
    _userLeftStream.close();
    _errorStream.close();
    _reconnectTimer?.cancel();
    super.onClose();
  }

  /// Initialize configuration from API constants
  void _initializeConfiguration() {
    _serverUrl = ApiConstant.baseUrl
        .replaceAll('http://', '')
        .replaceAll('https://', '');
    if (!_serverUrl!.startsWith('ws://') && !_serverUrl!.startsWith('wss://')) {
      _serverUrl = 'ws://$_serverUrl';
    }

    print('🔧 [SOCKET SERVICE] Server URL configured: $_serverUrl');
  }

  /// Connect to Socket.IO server
  Future<bool> connect({String? authToken, String? userId}) async {
    try {
      if (_socket != null && _socket!.connected) {
        print('✅ [SOCKET SERVICE] Already connected');
        return true;
      }

      _authToken = authToken;
      _userId = userId;

      print('🚀 [SOCKET SERVICE] Connecting to $_serverUrl...');

      _socket = IO.io(
          _serverUrl,
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .enableAutoConnect()
              .setTimeout(20000)
              .setReconnectionAttempts(maxReconnectAttempts)
              .setReconnectionDelay(1000)
              .setReconnectionDelayMax(5000)
              .enableReconnection()
              .build());

      _setupEventListeners();

      // Wait for connection
      await _waitForConnection();

      return isConnected.value;
    } catch (e) {
      print('❌ [SOCKET SERVICE] Connection failed: $e');
      lastError.value = e.toString();
      connectionStatus.value = 'Connection Failed';
      return false;
    }
  }

  /// Wait for connection to be established
  Future<void> _waitForConnection() async {
    final completer = Completer<void>();
    late StreamSubscription subscription;

    subscription = isConnected.listen((connected) {
      if (connected) {
        subscription.cancel();
        completer.complete();
      }
    });

    // Timeout after 10 seconds
    Timer(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        subscription.cancel();
        completer.completeError('Connection timeout');
      }
    });

    await completer.future;
  }

  /// Setup all event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      print('✅ [SOCKET SERVICE] Connected to server');
      isConnected.value = true;
      connectionStatus.value = 'Connected';
      lastError.value = '';
      _reconnectAttempts = 0;

      // Authenticate if token is available
      if (_authToken != null) {
        _socket!.emit('authenticate', {'token': _authToken});
      }
    });

    _socket!.onDisconnect((_) {
      print('⚠️ [SOCKET SERVICE] Disconnected from server');
      isConnected.value = false;
      connectionStatus.value = 'Disconnected';
      _clearTypingUsers();
    });

    _socket!.onConnectError((error) {
      print('❌ [SOCKET SERVICE] Connection error: $error');
      lastError.value = error.toString();
      connectionStatus.value = 'Connection Error';
      isConnected.value = false;
    });

    _socket!.onError((error) {
      print('❌ [SOCKET SERVICE] Socket error: $error');
      lastError.value = error.toString();
      _errorStream.add({'error': error, 'timestamp': DateTime.now()});
    });

    // Authentication events
    _socket!.on('authenticated', (data) {
      print('✅ [SOCKET SERVICE] Authentication successful');
    });

    _socket!.on('authentication_error', (data) {
      print('❌ [SOCKET SERVICE] Authentication failed: $data');
      lastError.value = 'Authentication failed';
    });

    // Message events
    _socket!.on('newMessage', (data) {
      print('📨 [SOCKET SERVICE] New message received: ${data['id']}');
      _messageStream.add(data);
    });

    _socket!.on('messageUpdated', (data) {
      print('📝 [SOCKET SERVICE] Message updated: ${data['id']}');
      _messageStream.add({...data, 'type': 'update'});
    });

    _socket!.on('messageDeleted', (data) {
      print('🗑️ [SOCKET SERVICE] Message deleted: ${data['id']}');
      _messageStream.add({...data, 'type': 'delete'});
    });

    // Typing events
    _socket!.on('userTyping', (data) {
      _handleTypingEvent(data);
    });

    // User events
    _socket!.on('userJoined', (data) {
      print('👋 [SOCKET SERVICE] User joined: ${data['userId']}');
      _userJoinedStream.add(data);
    });

    _socket!.on('userLeft', (data) {
      print('👋 [SOCKET SERVICE] User left: ${data['userId']}');
      _userLeftStream.add(data);
    });

    // Interest events
    _socket!.on('interestUpdated', (data) {
      print('📊 [SOCKET SERVICE] Interest updated: ${data['interestId']}');
      // Handle interest updates (member count, etc.)
    });
  }

  /// Handle typing indicator events
  void _handleTypingEvent(Map<String, dynamic> data) {
    final userId = data['userId']?.toString();
    final isTyping = data['isTyping'] == true;

    if (userId == null || userId == _userId) return; // Don't show own typing

    if (isTyping) {
      if (!typingUsers.contains(userId)) {
        typingUsers.add(userId);
      }
      typingTimestamps[userId] = DateTime.now();
    } else {
      typingUsers.remove(userId);
      typingTimestamps.remove(userId);
    }

    _typingStream.add(data);

    // Auto-remove typing indicator after 3 seconds
    if (isTyping) {
      Timer(const Duration(seconds: 3), () {
        if (typingUsers.contains(userId)) {
          typingUsers.remove(userId);
          typingTimestamps.remove(userId);
        }
      });
    }
  }

  /// Clear all typing users
  void _clearTypingUsers() {
    typingUsers.clear();
    typingTimestamps.clear();
  }

  /// Disconnect from server
  void disconnect() {
    if (_socket != null) {
      print('🔌 [SOCKET SERVICE] Disconnecting...');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }

    isConnected.value = false;
    connectionStatus.value = 'Disconnected';
    _clearTypingUsers();
    _reconnectTimer?.cancel();
  }

  /// Join an interest room
  Future<void> joinInterest(String interestId) async {
    if (!isConnected.value) {
      print('⚠️ [SOCKET SERVICE] Cannot join interest - not connected');
      return;
    }

    try {
      print('🚪 [SOCKET SERVICE] Joining interest: $interestId');
      _socket!.emit('joinInterest', interestId);
      _currentInterestId = interestId;
    } catch (e) {
      print('❌ [SOCKET SERVICE] Failed to join interest: $e');
    }
  }

  /// Leave current interest room
  Future<void> leaveInterest() async {
    if (!isConnected.value || _currentInterestId == null) return;

    try {
      print('🚪 [SOCKET SERVICE] Leaving interest: $_currentInterestId');
      _socket!.emit('leaveInterest', _currentInterestId);
      _currentInterestId = null;
      _clearTypingUsers();
    } catch (e) {
      print('❌ [SOCKET SERVICE] Failed to leave interest: $e');
    }
  }

  /// Send typing indicator
  void sendTypingIndicator(String interestId) {
    if (!isConnected.value) return;

    try {
      _socket!.emit('typing', {
        'interestId': interestId,
        'userId': _userId,
        'isTyping': true,
      });
    } catch (e) {
      print('❌ [SOCKET SERVICE] Failed to send typing indicator: $e');
    }
  }

  /// Send stop typing indicator
  void sendStopTypingIndicator(String interestId) {
    if (!isConnected.value) return;

    try {
      _socket!.emit('typing', {
        'interestId': interestId,
        'userId': _userId,
        'isTyping': false,
      });
    } catch (e) {
      print('❌ [SOCKET SERVICE] Failed to send stop typing indicator: $e');
    }
  }

  /// Send a message via socket (for real-time delivery)
  void sendMessage(Map<String, dynamic> messageData) {
    if (!isConnected.value) return;

    try {
      _socket!.emit('sendMessage', messageData);
    } catch (e) {
      print('❌ [SOCKET SERVICE] Failed to send message: $e');
    }
  }

  /// Get typing users text for display
  String getTypingUsersText() {
    if (typingUsers.isEmpty) return '';

    if (typingUsers.length == 1) {
      return '${typingUsers.first} is typing...';
    } else if (typingUsers.length == 2) {
      return '${typingUsers.first} and ${typingUsers.last} are typing...';
    } else {
      return '${typingUsers.length} people are typing...';
    }
  }

  /// Get connection status text
  String get statusText {
    if (isConnected.value) {
      return 'Connected';
    } else if (lastError.value.isNotEmpty) {
      return 'Error: ${lastError.value}';
    } else {
      return 'Disconnected';
    }
  }

  /// Check if currently in an interest room
  bool get isInInterestRoom => _currentInterestId != null;

  /// Get current interest ID
  String? get currentInterestId => _currentInterestId;

  // Stream getters for external listeners
  Stream<Map<String, dynamic>> get messageStream => _messageStream.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingStream.stream;
  Stream<Map<String, dynamic>> get userJoinedStream => _userJoinedStream.stream;
  Stream<Map<String, dynamic>> get userLeftStream => _userLeftStream.stream;
  Stream<Map<String, dynamic>> get errorStream => _errorStream.stream;

  /// Reconnect with exponential backoff
  Future<void> reconnect() async {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      print('❌ [SOCKET SERVICE] Max reconnection attempts reached');
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 2);

    print(
        '🔄 [SOCKET SERVICE] Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts/$maxReconnectAttempts)');

    _reconnectTimer = Timer(delay, () async {
      await connect(authToken: _authToken, userId: _userId);
    });
  }

  /// Force reconnection
  Future<void> forceReconnect() async {
    _reconnectAttempts = 0;
    disconnect();
    await Future.delayed(const Duration(seconds: 1));
    await connect(authToken: _authToken, userId: _userId);
  }
}
