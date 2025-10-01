import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Components/bottom_navbar.dart';
import 'package:vropay_final/Components/top_navbar.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import 'package:vropay_final/app/modules/Screens/personal_growth_community/controllers/personal_growth_community_controllers.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class PersonalGrowthCommunityScreen
    extends GetView<PersonalGrowthCommunityController> {
  const PersonalGrowthCommunityScreen({super.key});

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

            SizedBox(height: ScreenUtils.height * 0.05),

            // Categories Grid View
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 42),
              child: Obx(() => GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    return _buildCategoryCard(category, index);
                  })),
            ),
            SizedBox(height: ScreenUtils.height * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category, int index) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.PERSONAL_GROWTH_SCREEN, arguments: {
          'categoryName': 'personal growth',
          'subCategoryName': category,
        });
      },
      child: Container(
        height: ScreenUtils.height * 0.2,
        width: double.infinity,
        padding: EdgeInsets.only(left: 9, right: 9),
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
                category,
                style: TextStyle(
                  fontSize: _getCategoryFontSize(category),
                  fontWeight: FontWeight.w500,
                  color: _getCategoryColor(index),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getCategoryFontSize(String category) {
    switch (category) {
      case 'entrepreneurship':
        return 18;
      case 'visionaries':
        return 22;
      case 'law':
        return 22;
      case 'books':
        return 22;
      case 'vocab':
        return 22;
      case 'health':
        return 22;
      case 'spirituality':
        return 22;
      case 'quantumleap':
        return 22;
      case 'geeta gyan':
        return 22;
      case 'vedic wise':
        return 22;
      default:
        return 22;
    }
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Color(0xFF4B7C24), // Purple
      Color(0xFF32CD32), // Dark Purple
      Color(0xFF00A059), // Blue
      Color(0xFF01451E), // Green
      Color(0xFF01451E), // Orange
      Color(0xFF32CD32), // Pink
      Color(0xFF4B7C24), // Purple
      Color(0xFF00A059), // Blue Grey
      Color(0xFF4B7C24), // Brown
    ];
    return colors[index % colors.length];
  }
}
