import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vropay_final/Components/bottom_navbar.dart';
import 'package:vropay_final/Components/top_navbar.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import 'package:vropay_final/app/modules/Screens/world_and_culture_community/controllers/world_and_culture_community_controller.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class WorldAndCultureCommunityScreen
    extends GetView<WorldAndCultureCommunityController> {
  const WorldAndCultureCommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set the context for ScreenUtils
    ScreenUtils.setContext(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: CustomTopNavBar(selectedIndex: null),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: ScreenUtils.height * 0.03),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("tap for community",
                    style: TextStyle(
                      fontSize: ScreenUtils.x(5),
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF714FC0),
                    )),
                SizedBox(
                  width: ScreenUtils.width * 0.05,
                ),
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Color(0xFF6A3DBE),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/icons/downward_arrow.png',
                      color: Colors.white,
                      height: 18,
                      width: 18,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: ScreenUtils.height * 0.03,
            ),

            // API Topics Grid View
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 43.0),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF18707C),
                    ),
                  );
                }

                if (controller.topics.isEmpty) {
                  return Center(
                    child: Text('No topics available'),
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 29,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: controller.topics.length,
                  itemBuilder: (context, index) {
                    final topic = controller.topics[index];
                    return _buildTopicCard(topic, index);
                  },
                );
              }),
            ),
            SizedBox(height: ScreenUtils.height * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic, int index) {
    final topicName = topic['name']?.toString() ?? 'Topic';
    final topicId = topic['_id']?.toString();
    return GestureDetector(
      onTap: () => _onTopicTap(topicName, topicId),
      child: Container(
        height: ScreenUtils.height * 0.5,
        width: ScreenUtils.width * 0.4,
        decoration: BoxDecoration(
          color: Color(0xFF3E9292).withOpacity(0.1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category Name
              Text(
                topicName,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  color: _getCategoryColor(index),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Handle topic tap with first time visit logic
  void _onTopicTap(String topicName, String? topicId) async {
    print(
        '🚀 WorldAndCultureCommunity - Topic tapped: $topicName (ID: $topicId)');

    // Check if this is the first time visiting this topic
    final isFirstTime = await _isFirstTimeVisit(topicId ?? '');

    if (isFirstTime) {
      // Show consent screen first for first time visitors
      _showConsentScreen(topicName, topicId);
    } else {
      // Navigate directly to message screen for returning visitor
      _navigateToMessageScreen(topicName, topicId);
    }
  }

  // Check if this is the first time visiting a topic
  Future<bool> _isFirstTimeVisit(String topicId) async {
    if (topicId.isEmpty) return true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'topic_visited_$topicId';
      return !(prefs.getBool(key) ?? false);
    } catch (e) {
      print('❌ Error checking first time visit: $e');
      return true; // Default to first time if error
    }
  }

  // Mark topic as visited
  Future<void> _markAsVisited(String topicId) async {
    if (topicId.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'topic_visited_$topicId';
      await prefs.setBool(key, true);
      print('✅ Marked topic $topicId as visited');
    } catch (e) {
      print('❌ Error marking as visited: $e');
    }
  }

  // Show consent screen for first-time visitors
  void _showConsentScreen(String topicName, String? topicId) {
    Get.toNamed(Routes.CONSENT_SCREEN, arguments: {
      'subCategoryName': topicName,
      'subCategoryId': topicId,
      'onConsentAccepted': () {
        // Mark as visited and navigate to message screen
        if (topicId != null) {
          _markAsVisited(topicId);
        }
        _navigateToMessageScreen(topicName, topicId);
      },
    });
  }

  // Navigate to message screen
  void _navigateToMessageScreen(String topicName, String? topicId) {
    print('🚀 [WORLD & CULTURE COMMUNITY] Navigating to message screen...');
    print('🚀 [WORLD & CULTURE COMMUNITY] Topic Name: "$topicName"');
    print('🚀 [WORLD & CULTURE COMMUNITY] Topic ID: "$topicId"');

    if (topicId == null || topicId.isEmpty) {
      print('❌ [WORLD & CULTURE COMMUNITY] Topic ID is null or empty!');
      Get.snackbar('Error', 'Topic ID is missing');
      return;
    }

    Get.toNamed(Routes.MESSAGE_SCREEN, arguments: {
      'interestId': topicId, // ✅ This will be used for the API call
      'interestName': topicName, // ✅ This will be shown in header
      'subCategoryId': topicId, // ✅ Use topicId as subCategoryId for now
      'subCategoryName': topicName,
      'categoryId': controller.categoryId, // ✅ Use categoryId as mainCategoryId
      'categoryName': controller.categoryName,
      'topicId': topicId, // ✅ Explicitly pass topicId
    });

    print('✅ [WORLD & CULTURE COMMUNITY] Navigation initiated with arguments:');
    print('   - interestId: $topicId');
    print('   - interestName: $topicName');
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Color(0xFF4B7C24),
      Color(0xFF32CD32),
      Color(0xFF00A059),
      Color(0xFF01451E),
      Color(0xFF01451E),
      Color(0xFF32CD32),
      Color(0xFF4B7C24),
      Color(0xFF00A059),
      Color(0xFF4B7C24),
      Color(0xFF32CD32),
      Color(0xFF01451E),
    ];
    return colors[index % colors.length];
  }
}
