import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vropay_final/Components/bottom_navbar.dart';
import 'package:vropay_final/Components/top_navbar.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  String _selectedFilter = 'all';
  bool _showUnreadOnly = false;
  bool _showTodayOnly = false;

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Share your takeaways in the community',
      'time': 'just\nnow',
      'isRead': false,
      'isToday': true,
    },
    {
      'title': 'Your daily quiz is now ready',
      'time': '6 h',
      'isRead': false,
      'isToday': true,
    },
    {
      'title': 'Finance content for today is live',
      'time': '4 d',
      'isRead': false,
      'isToday': false,
    },
    {
      'title': 'New AI TOOLS content just dropped',
      'time': '1 w',
      'isRead': false,
      'isToday': false,
    },
    {
      'title': 'Primary profile updated.. good to go',
      'time': '4 w',
      'isRead': false,
      'isToday': false,
    },
    {
      'title': 'You\'re on the free plan.. early bird upgrade is live',
      'time': '10 w',
      'isRead': false,
      'isToday': false,
    },
    {
      'title': 'You\'re signed in with a free trial.. explore away',
      'time': '12 w',
      'isRead': false,
      'isToday': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'unread') {
      return _notifications
          .where((notification) => !notification['isRead'])
          .toList();
    } else if (_selectedFilter == 'today') {
      return _notifications
          .where((notification) => notification['isToday'])
          .toList();
    }
    return _notifications;
  }

  void _clearAll() {
    setState(() {
      if (_selectedFilter == 'today') {
        // Remove only today's notifications
        _notifications
            .removeWhere((notification) => notification['isToday'] == true);
      } else if (_selectedFilter == 'unread') {
        // Remove only unread notifications
        _notifications
            .removeWhere((notification) => notification['isRead'] == false);
      } else {
        // Remove all notifications (when 'all' is selected)
        _notifications.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtils.setContext(context);
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: CustomTopNavBar(selectedIndex: null),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: ScreenUtils.height * 0.02),
            // Filter tabs
            Container(
              padding: const EdgeInsets.only(left: 50, right: 49),
              child: Row(
                children: [
                  Expanded(
                    child: _buildFilterTab('all', _selectedFilter == 'all'),
                  ),
                  SizedBox(width: ScreenUtils.width * 0.01),
                  Expanded(
                    child:
                        _buildFilterTab('unread', _selectedFilter == 'unread'),
                  ),
                  SizedBox(width: ScreenUtils.width * 0.01),
                  Expanded(
                    child: _buildFilterTab('today', _selectedFilter == 'today'),
                  ),
                  SizedBox(width: ScreenUtils.width * 0.01),
                ],
              ),
            ),

            SizedBox(height: ScreenUtils.height * 0.035),
            Padding(
              padding: const EdgeInsets.only(left: 36, right: 22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Single-tap',
                      style: TextStyle(
                        color: Color(0xFF00B8F0),
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                      ),
                      children: [
                        TextSpan(
                          text: ' will just mark it as read',
                          style: TextStyle(
                            color: Color(0xFF172B75),
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      onTap: _clearAll,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Clear',
                            style: TextStyle(
                              color: Color(0xFFEF2D56),
                              fontSize: 14.28,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Iconsax.close_circle,
                            color: Color(0xFFEF2D56),
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Notifications list
            Expanded(
              child: _filteredNotifications.isEmpty
                  ? SizedBox()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 21),
                      itemCount: _filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = _filteredNotifications[index];
                        return _buildNotificationItem(notification);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildFilterTab(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        height: ScreenUtils.height * 0.04,
        width: ScreenUtils.width * 0.2,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6253DB) : Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            isSelected
                ? label[0].toUpperCase() +
                    label.substring(1) // Capitalize if selected
                : label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF6253DB),
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return GestureDetector(
      onTap: () {
        setState(() {
          notification['isRead'] = true;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              notification['isRead'] ? const Color(0xFFF7F7F7) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                notification['title'],
                style: TextStyle(
                    color: const Color(0xFF616161),
                    fontSize: 15,
                    fontWeight: FontWeight.w400),
              ),
            ),
            SizedBox(width: ScreenUtils.width * 0.012),
            Text(
              notification['time'],
              style: TextStyle(
                color: const Color(0xFF8E8F95).withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavIcon(IconData icon, {bool isSelected = false}) {
    return Icon(
      icon,
      color: isSelected ? const Color(0xFF714FC0) : const Color(0xFF797C7B),
      size: 24,
    );
  }
}
