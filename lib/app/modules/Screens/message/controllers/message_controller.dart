import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageController extends GetxController {
  final selectedFilter = ''.obs;
  final totalMessages = 0.obs;
  final messages = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final replyToMessage = Rxn<Map<String, dynamic>>();
  final taggedUsers = <String>[].obs;
  final messageController = TextEditingController();
  final isImportantIconPressed = false.obs; // New variable for blur effect

  // Report options for messages
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

  @override
  void onReady() {
    super.onReady();
    // Get the selected category from the previous screen
    if (Get.arguments != null && Get.arguments['category'] != null) {
      selectedFilter.value = Get.arguments['category'];
    }
    loadMessages();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  void loadMessages() {
    isLoading.value = true;
    // Load messages immediately
    // Mock data with reply and tag information
    messages.value = [
      {
        'id': 0,
        'sender': 'You',
        'message': 'Hello',
        'timestamp': DateTime.now().subtract(Duration(minutes: 10)),
        'isRead': true,
        'replies': [],
        'tags': [],
        'isOwnMessage': true,
        'avatarColor': Color(0xFF2196F3),
      },
      {
        'id': 1,
        'sender': 'Sneha Joshi',
        'message': 'Hello.. how are you?',
        'timestamp': DateTime.now().subtract(Duration(minutes: 5)),
        'isRead': false,
        'replies': [],
        'tags': [],
        'avatarColor': Color(0xFF3E9292).withOpacity(0.5),
      },
      {
        'id': 2,
        'sender': 'You',
        'message': 'you did your job well!',
        'timestamp': DateTime.now().subtract(Duration(minutes: 4)),
        'isRead': true,
        'replies': [],
        'tags': [],
        'isOwnMessage': true,
      },
      {
        'id': 3,
        'sender': 'Vikas Raika',
        'message': 'did you like the today\'s reading ?',
        'timestamp': DateTime.now().subtract(Duration(minutes: 3)),
        'isRead': true,
        'replies': [],
        'tags': [],
        'avatarColor': Color(0xFFEDA0A8),
      },
      {
        'id': 4,
        'sender': 'Vikas Raika',
        'message': 'Hope you like it 👋',
        'timestamp': DateTime.now().subtract(Duration(minutes: 2)),
        'isRead': true,
        'replies': [],
        'tags': [],
        'avatarColor': Color(0xFFE91E63),
      },
      {
        'id': 5,
        'sender': 'Gabbar Gurjar',
        'message': 'hello, i am excited for the next article 📦',
        'timestamp': DateTime.now().subtract(Duration(minutes: 1)),
        'isRead': true,
        'replies': [],
        'tags': [],
        'avatarColor': Color(0xFF007DB9).withOpacity(0.5),
      },
      {
        'id': 5.1,
        'sender': 'Gabbar Gurjar',
        'message': '',
        'timestamp': DateTime.now().subtract(Duration(minutes: 1)),
        'isRead': true,
        'replies': [],
        'tags': [],
        'avatarColor': Color(0xFF3F51B5),
        'isSharedArticle': true,
        'articleTitle': 'Congress demands full J&K statehood',
        'articleUrl': 'https://example.com/article1',
        'articleImage': 'https://example.com/image1.jpg',
        'replied': false,
      },
      {
        'id': 6,
        'sender': 'You',
        'message': ' 👑 yehhh this is cooll',
        'timestamp': DateTime.now(),
        'isRead': true,
        'replied': [],
        'tags': [],
        'isOwnMessage': true,
        'isReplied': true,
        'replyTo': {
          'sender': 'Gabbar Gurjar',
          'articleTitle': 'Congress demands full J&K statehood',
          'isSharedArticle': true,
          'id': 5
        },
      },
      {
        'id': 7,
        'sender': 'Saumya K',
        'message': 'yupp.. this is giving insights',
        'timestamp': DateTime.now().add(Duration(minutes: 1)),
        'isRead': true,
        'replies': [],
        'tags': ['you'],
        'avatarColor': Color(0xFFB1B1EB),
      },
      {
        'id': 8,
        'sender': 'Saumya K',
        'message': 'hey 💙 S hw r u',
        'timestamp': DateTime.now().add(Duration(minutes: 2)),
        'isRead': true,
        'replies': [],
        'tags': ['sneha'],
        'avatarColor': Color(0xFF9C27B0),
      },
      {
        'id': 9,
        'sender': 'Aditi Pewa',
        'message': 'thanks but i already read it',
        'timestamp': DateTime.now().add(Duration(minutes: 3)),
        'isRead': true,
        'replies': [],
        'tags': [],
        'avatarColor': Color(0xFF4B7C24).withOpacity(0.5),
      },
      {
        'id': 9.1,
        'sender': 'Aditi Pewa',
        'message': '',
        'timestamp': DateTime.now().add(Duration(minutes: 3)),
        'isRead': true,
        'replies': [],
        'tags': [],
        'avatarColor': Color(0xFF4CAF50),
        'isSharedArticle': true,
        'articleTitle': 'New AI breakthrough in healthcare',
        'articleUrl': 'https://example.com/article2',
        'articleImage': 'https://example.com/image2.jpg',
      },
      {
        'id': 10,
        'sender': 'Nidhi Agrwal',
        'message':
            'YUPS,, Still I wanted someone to share this article so that I can get my confusions clear',
        'timestamp': DateTime.now().add(Duration(minutes: 3)),
        'isRead': true,
        'replies': [],
        'tags': [],
        'avatarColor': Color(0xFFFFA000).withOpacity(0.5),
      },
      {
        'id': 11,
        'sender': 'Gabbar Gurjar',
        'message': '',
        'timestamp': DateTime.now().subtract(Duration(minutes: 10)),
        'isRead': true,
        'replies': [],
        'tags': [],
        'avatarColor': Color(0xFFFFA000).withOpacity(0.5),
        'isSharedArticle': true,
        'articleTitle': 'Congress demands full J&K statehood',
        'articleUrl': 'https://example.com/article1',
        'articleImage': 'https://example.com/image1.jpg',
      },
      {
        'id': 12,
        'sender': 'You',
        'message': 'This is a great article! Thanks for sharing',
        'timestamp': DateTime.now().add(Duration(minutes: 4)),
        'isRead': true,
        'replies': [],
        'tags': [],
        'isOwnMessage': true,
      },
      {
        'id': 13,
        'sender': 'Kevin',
        'message': '',
        'timestamp': DateTime.now().add(Duration(minutes: 5)),
        'isRead': true,
        'replies': [],
        'tags': [],
        'isHighlightedContent': true,
        'highlightedTitle': 'Trump Vows Revenge in 2024 Run',
        'highlightedSummary':
            'Former President Donald Trump has announced his intention to run for president again in 2024, promising to seek revenge against political opponents and restore what he calls "America First" policies.',
        'highlightedCategory': 'Politics',
        'highlightedColor': Color(0xFF714FC0),
      },
      {
        'id': 14,
        'sender': 'System',
        'message': '',
        'timestamp': DateTime.now().add(Duration(minutes: 6)),
        'isRead': true,
        'replies': [],
        'tags': [],
        'isHighlightedContent': true,
        'highlightedTitle': 'Court Delays Trump Sentencing Again',
        'highlightedSummary':
            'The sentencing hearing for former President Trump has been postponed once more, as the court considers additional legal arguments and evidence in the ongoing case.',
        'highlightedCategory': 'Legal',
        'highlightedColor': Color(0xFF714FC0),
      },
      {
        'id': 15,
        'sender': 'You',
        'message': 'Thanks for the updates!',
        'timestamp': DateTime.now().subtract(Duration(minutes: 8)),
        'isRead': true,
        'replies': [],
        'tags': [],
        'isOwnMessage': true,
        'replyTo': {
          'sender': 'Gabbar Gurjar',
          'articleTitle': 'Congress demands full J&K statehood',
          'isSharedArticle': true,
          'id': 11,
        },
      },

      // Important Message 1 - Tech Partnership News
      {
        'id': 16,
        'sender': 'Rahul',
        'message':
            'India and UAE have signed a major tech-finance partnership to boost AI-led trade infrastructure and digital payments across borders. The pact enables instant UPI-based settlements in dirhams and rupees. Meanwhile, OpenAI announced GPT-5 pre-release access for enterprise clients, offering stronger reasoning and memory. In markets, Sensex jumped 600+ points as global investors bet big on India\'s infra growth. Elon Musk also confirmed Neuralink\'s second successful human brain-chip implant, claiming improved motor control in the patient.',
        'timestamp': DateTime.now().subtract(Duration(minutes: 15)),
        'isRead': true,
        'replies': [],
        'tags': [],
        'avatarColor': Color(0xFFFFC746),
        'isImportantMessage': true,
      },

      // Important Message 2 - RBI & Nvidia News
      {
        'id': 17,
        'sender': 'Rahul',
        'message':
            'RBI greenlights tokenized digital lending for fintechs, aiming to curb fraud and boost transparency. Meanwhile, Nvidia hits 5T valuation, driven by AI chip demand',
        'timestamp': DateTime.now().subtract(Duration(minutes: 12)),
        'isRead': true,
        'replies': [],
        'tags': [],
        'avatarColor': Color(0xFFFFC746),
        'isImportantMessage': true,
      },

      // Regular message after important messages
      {
        'id': 18,
        'sender': 'Rahul Kewlani',
        'message': 'These updates are crucial for our community!',
        'timestamp': DateTime.now().subtract(Duration(minutes: 10)),
        'isRead': true,
        'replies': [],
        'tags': [],
        'avatarColor': Color(0xFF9E9E9E),
      },

      {
        'id': 19,
        'sender': 'Saumya K',
        'message': 'damn',
        'timestamp': DateTime.now().subtract(Duration(minutes: 5)),
        'isRead': true,
        'replies': [],
        'tags': [],
        'avatarColor': Color(0xFFB1B1EB),
      },
    ];
    totalMessages.value = messages.length;
    isLoading.value = false;
  }

  void setReplyToMessage(Map<String, dynamic> message) {
    replyToMessage.value = message;
    messageController.text = '';
    // Scroll to bottom or show reply indicator
  }

  void cancelReply() {
    replyToMessage.value = null;
    messageController.text = '';
  }

  void addTag(String username) {
    if (!taggedUsers.contains(username)) {
      taggedUsers.add(username);
      messageController.text += ' @$username ';
      messageController.selection = TextSelection.fromPosition(
        TextPosition(offset: messageController.text.length),
      );
    }
  }

  void removeTag(String username) {
    taggedUsers.remove(username);
    messageController.text =
        messageController.text.replaceAll(' @$username ', '');
  }

  void sendMessage() {
    try {
      if (messageController.text == null ||
          messageController.text.trim().isEmpty) return;

      final newMessage = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'sender': 'You',
        'message': messageController.text.trim(),
        'timestamp': DateTime.now(),
        'isRead': false,
        'replies': [],
        'tags': taggedUsers.toList(),
        'isOwnMessage': true,
        'replyTo': replyToMessage.value,
        // Add this to track if we're replying to a shared article
        'isReplyToSharedArticle': replyToMessage.value != null &&
            replyToMessage.value!['isSharedArticle'] == true,
      };

      // Add reply to original message if replying
      if (replyToMessage.value != null) {
        final originalMessageIndex = messages.indexWhere(
          (msg) => msg['id'] == replyToMessage.value!['id'],
        );
        if (originalMessageIndex != -1) {
          messages[originalMessageIndex]['replies'].add(newMessage);
        }
      }

      messages.add(newMessage);
      messageController.text = '';
      taggedUsers.clear();
      replyToMessage.value = null;

      // Scroll to bottom
      Get.snackbar(
        'Message Sent',
        'Your message has been sent successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );

      // Auto-scroll to latest message
      onMessageAdded?.call();
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar(
        'Error',
        'Failed to send message. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    }
  }

  void sendQuickReplyMessage(String message, Color color) {
    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'sender': 'You',
      'message': message,
      'timestamp': DateTime.now(),
      'isRead': false,
      'replies': [],
      'tags': taggedUsers.toList(),
      'isOwnMessage': true,
      'replyTo': replyToMessage.value,
      'quickReplyColor': color, // Store the color
    };

    // Add reply to original message if replying
    if (replyToMessage.value != null) {
      final originalMessageIndex = messages.indexWhere(
        (msg) => msg['id'] == replyToMessage.value!['id'],
      );
      if (originalMessageIndex != -1) {
        messages[originalMessageIndex]['replies'].add(newMessage);
      }
    }

    messages.add(newMessage);
    taggedUsers.clear();
    replyToMessage.value = null;

    // Auto-scroll to latest message
    onMessageAdded?.call();
  }

  void goBack() {
    Get.back();
  }

  void shareArticleFromNews(String articleTitle,
      {String? articleUrl, String? articleImage}) {
    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'sender': 'You',
      'message': '',
      'timestamp': DateTime.now(),
      'isRead': false,
      'replies': [],
      'tags': taggedUsers.toList(),
      'isOwnMessage': true,
      'replyTo': replyToMessage.value,
      'isSharedArticle': true,
      'articleTitle': articleTitle,
      'articleUrl': articleUrl,
      'articleImage': articleImage,
    };

    // Add reply to original message if replying
    if (replyToMessage.value != null) {
      final originalMessageIndex = messages.indexWhere(
        (msg) => msg['id'] == replyToMessage.value!['id'],
      );
      if (originalMessageIndex != -1) {
        messages[originalMessageIndex]['replies'].add(newMessage);
      }
    }

    messages.add(newMessage);
    messageController.text = '';
    taggedUsers.clear();
    replyToMessage.value = null;

    // Scroll to bottom
    Get.snackbar(
      'Article Shared',
      'Article has been shared successfully',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  void addNewMessage() {
    Get.snackbar(
        'Add Message', 'Add new message functionality will be implemented here',
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.primaryColorLight,
        duration: Duration(seconds: 2));
  }

  // Callback function to scroll to bottom
  Function? onMessageAdded;

  void scrollToBottom() {
    // This will be called from the UI to scroll to the latest message
    // The actual scrolling will be handled in the UI with ScrollController
  }

  void setScrollCallback(Function callback) {
    onMessageAdded = callback;
  }

  // Methods to control blur effect
  void enableBlurEffect() {
    isImportantIconPressed.value = true;
  }

  void disableBlurEffect() {
    isImportantIconPressed.value = false;
  }

  void toggleBlurEffect() {
    isImportantIconPressed.value = !isImportantIconPressed.value;
  }

  void showAlert() {
    Get.dialog(AlertDialog(
      title: Text("Alert"),
      content: Text("This is an alert message for the community."),
      actions: [TextButton(onPressed: () => Get.back(), child: Text("OK"))],
    ));
  }

  void sendImportantMessage(String message) {
    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'sender': 'You',
      'message': message,
      'timestamp': DateTime.now(),
      'isRead': false,
      'replies': [],
      'tags': [],
      'isOwnMessage': true,
      'isImportantMessage': true, // Mark as important message
    };

    messages.add(newMessage);

    // Auto-scroll to latest message
    onMessageAdded?.call();

    Get.snackbar(
      'Important Message Sent',
      'Your important message has been sent successfully',
      backgroundColor: const Color(0xFFCC415D),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  // Add this new method to send a normal message with custom text
  void sendNormalMessage(String message) {
    if (message.trim().isEmpty) return;

    final newMessage = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'sender': 'You',
      'message': message.trim(),
      'timestamp': DateTime.now(),
      'isRead': false,
      'replies': [],
      'tags': [],
      'isOwnMessage': true,
      'isImportantMessage': false, // Mark as normal message
    };

    messages.add(newMessage);

    // Auto-scroll to latest message
    onMessageAdded?.call();

    Get.snackbar(
      'Message Sent',
      'Your message has been sent successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }

  // Report message functionality
  void openReportDialog() {
    isReportDialogOpen.value = true;
  }

  void closeReportDialog() {
    isReportDialogOpen.value = false;
    selectedReportOption.value = null;
  }

  void selectReportOption(String option) {
    selectedReportOption.value = option;
  }

  void submitReport(int messageId, String reason) {
    // TODO: Implement actual report submission to backend
    Get.snackbar(
      'Report Submitted',
      'Message reported for: $reason',
      backgroundColor: const Color(0xFFCC415D),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    // Close the report dialog
    closeReportDialog();

    // Log the report for debugging
    print('Message $messageId reported for: $reason');
  }

  void cancelReport() {
    closeReportDialog();
  }
}
