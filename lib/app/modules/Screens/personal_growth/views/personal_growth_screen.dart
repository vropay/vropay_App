import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:collection/collection.dart';
import 'package:vropay_final/Components/bottom_navbar.dart';
import 'package:vropay_final/Components/top_navbar.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import 'package:vropay_final/app/modules/Screens/personal_growth/controllers/personal_growth_controller.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class PersonalGrowthScreen extends GetView<PersonalGrowthController> {
  const PersonalGrowthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set the context for ScreenUtils
    ScreenUtils.setContext(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: CustomTopNavBar(selectedIndex: null),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: ScreenUtils.height * 0.02,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("tap for content",
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
            SizedBox(height: ScreenUtils.height * 0.045),

            // Categories List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 46),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF18707C),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    return _buildCategoryCard(category);
                  },
                );
              }),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }

  // Handle topic tap - navigate to news screen with topic data
  void _onTopicTap(String topicName) {
    // Find the topic data from the loaded topics
    final topicData = controller.topics.firstWhereOrNull(
      (topic) => topic['name']?.toString().toUpperCase() == topicName,
    );

    if (topicData != null) {
      // Navigate to news screen with topic data
      Get.toNamed(Routes.NEWS_SCREEN, arguments: {
        'topicId': topicData['_id']?.toString(),
        'topicName': topicData['name']?.toString(),
        'subCategoryId': controller.subCategoryId,
        'categoryId': controller.categoryId,
        'subCategoryName': controller.subCategoryName,
        'categoryName': controller.categoryName,
      });
    } else {
      // Fallback - navigate without topic data
      Get.toNamed(Routes.NEWS_SCREEN);
    }
  }

  Widget _buildCategoryCard(String category) {
    return GestureDetector(
      onTap: () {
        _onTopicTap(category);
      },
      child: Container(
        height: ScreenUtils.height * 0.2,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 18),
        decoration: BoxDecoration(
          color: _getContainerColor(category),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              fontSize: _getCategoryFontSize(category),
              fontWeight: FontWeight.w400,
              color: _getCategoryColor(category),
            ),
          ),
        ),
      ),
    );
  }

  Color _getContainerColor(String category) {
    switch (category) {
      case 'ENTREPRENEURSHIP':
        return Color(0xFFDFDFDF)
            .withOpacity(0.2); // Deep Green - represents growth and success
      case 'VISIONARIES':
        return Color(0xFFDFDFDF)
            .withOpacity(0.2); // Deep Blue - represents wisdom and vision
      case 'LAW':
        return Color(0xFFDFDFDF)
            .withOpacity(0.2); // Deep Red - represents authority and justice
      case 'BOOKS':
        return Color(0xFFDFDFDF).withOpacity(
            0.25); // Deep Purple - represents knowledge and learning
      case 'VOCAB':
        return Color(0xFFDFDFDF).withOpacity(
            0.25); // Deep Orange - represents energy and communication
      case 'HEALTH':
        return Color(0xFFDFDFDF)
            .withOpacity(0.25); // Green - represents wellness and vitality
      case 'SPIRITUALITY':
        return Color(0xFFDFDFDF)
            .withOpacity(0.25); // Purple - represents spiritual connection
      case 'QUANTUMLEAP':
        return Color(0xFFDFDFDF)
            .withOpacity(0.25); // Blue - represents transformation and progress
      case 'GEETA GYAN':
        return Color(0xFFDFDFDF)
            .withOpacity(0.25); // Amber - represents ancient wisdom
      case 'VEDIC WISE':
        return Color(0xFFDFDFDF).withOpacity(0.25); // Light gray with opacity
      default:
        return Color(0xFFDFDFDF).withOpacity(0.4); // Default teal color
    }
  }

  double _getCategoryFontSize(String category) {
    switch (category) {
      case 'ENTREPRENEURSHIP':
        return 35;
      case 'VISIONARIES':
        return 42;
      case 'LAW':
        return 50;
      case 'BOOKS':
        return 50;
      case 'VOCAB':
        return 50;
      case 'HEALTH':
        return 45;
      case 'SPIRITUALITY':
        return 40;
      case 'QUANTUMLEAP':
        return 50;
      case 'GEETA GYAN':
        return 42;
      case 'VEDIC WISE':
        return 45;
      default:
        return 40;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'ENTREPRENEURSHIP':
        return Color(0xFFFF692D);
      case 'VISIONARIES':
        return Color(0xFFAB272D);
      case 'LAW':
        return Color(0xFFD80031);
      case 'BOOKS':
        return Color(0xFFA65854);
      case 'VOCAB':
        return Color(0xFFFF0017);
      case 'HEALTH':
        return Color(0xFF690005);
      case 'SPIRITUALITY':
        return Color(0xFFE50B5F);
      case 'QUANTUMLEAP':
        return Color(0xFF963B20);
      case 'GEETA GYAN':
        return Color(0xFFC84045);
      case 'VEDIC WISE':
        return Color(0xFFFF692D);
      default:
        return Color(0xFF18707C);
    }
  }
}
