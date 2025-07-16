import 'package:get/get.dart';

class NotificationItem {
  final String title;
  final String body;
  final String source;
  final DateTime dateTime;
  bool isRead;
  final String iconType; // for different icons (gift, badge, etc.)

  NotificationItem({
    required this.title,
    required this.body,
    required this.source,
    required this.dateTime,
    this.isRead = false,
    required this.iconType,
  });
}

class NotificationController extends GetxController {
  var selectedTab = 'All'.obs;
  var selectedClearOption = 'Clear'.obs;
  var selectedSource = 'Source'.obs;
  var navTabIndex = 0.obs;

  List<String> sources = [
    'ALL',
    'launchpad',
    'library',
    'points & rewards',
    'referrals',
    'chats',
    'startup support',
    'networking',
    'posts',
    'community',
    'Miscellaneous',
  ];

  var notifications = <NotificationItem>[ // Example data
    NotificationItem(
      title: "You've got a new response under 'Collaborate'.",
      body: '',
      source: 'chats',
      dateTime: DateTime.now().subtract(Duration(hours: 4)),
      isRead: false,
      iconType: 'chat',
    ),
    NotificationItem(
      title: 'New service added under Startup Support.',
      body: '',
      source: 'startup support',
      dateTime: DateTime.now().subtract(Duration(hours: 6)),
      isRead: false,
      iconType: 'gift',
    ),
    NotificationItem(
      title: "You've earned over 500 points! Redeem your points now and unlock access to exclusive rewards, premium services, special discounts.",
      body: '',
      source: 'points & rewards',
      dateTime: DateTime.now().subtract(Duration(days: 7)),
      isRead: true,
      iconType: 'points',
    ),
    NotificationItem(
      title: 'A new topic is live in the Community Forum',
      body: '',
      source: 'community',
      dateTime: DateTime.now().subtract(Duration(days: 14)),
      isRead: true,
      iconType: 'post',
    ),
    NotificationItem(
      title: "You've unlocked a new badge: 'Community Contributor' 🎉",
      body: '',
      source: 'community',
      dateTime: DateTime.now().subtract(Duration(days: 28)),
      isRead: true,
      iconType: 'badge',
    ),
    NotificationItem(
      title: 'Your engagement score for this week is up by 15%',
      body: '',
      source: 'points & rewards',
      dateTime: DateTime.now().subtract(Duration(hours: 10)),
      isRead: false,
      iconType: 'score',
    ),
    NotificationItem(
      title: 'Your password was successfully reset.',
      body: '',
      source: 'Miscellaneous',
      dateTime: DateTime.now().subtract(Duration(days: 12)),
      isRead: true,
      iconType: 'settings',
    ),
  ].obs;

  // Filtering logic
  List<NotificationItem> get filteredNotifications {
    final tab = selectedTab.value;
    final source = selectedSource.value;
    final now = DateTime.now();
    return notifications.where((n) {
      if (tab == 'Unread' && n.isRead) return false;
      if (tab == 'Today' && (now.difference(n.dateTime).inDays > 0)) return false;
      if (source != 'Source' && source != 'ALL' && n.source != source) return false;
      return true;
    }).toList();
  }

  void markAsRead(NotificationItem item) {
    item.isRead = true;
    notifications.refresh();
  }

  void changeTab(String tab) {
    selectedTab.value = tab;
  }

  void changeSource(String source) {
    selectedSource.value = source;
  }

  void changeClearOption(String option) {
    selectedClearOption.value = option;
    if (option == 'Clear All') {
      notifications.clear();
    } else if (option == 'Clear Read') {
      notifications.removeWhere((n) => n.isRead);
    } else if (option == 'Clear Today') {
      final now = DateTime.now();
      notifications.removeWhere((n) => now.difference(n.dateTime).inDays == 0);
    }
    notifications.refresh();
  }

  void clearNotifications() {
    notifications.clear();
    notifications.refresh();
  }

  void onNavTap(int index) {
    navTabIndex.value = index;
    // Add page change logic if needed
  }
}
