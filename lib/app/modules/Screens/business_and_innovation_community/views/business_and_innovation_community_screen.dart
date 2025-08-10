import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Components/top_navbar.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import 'package:vropay_final/app/modules/Screens/business_and_innovation_community/controllers/business_and_innovation_community_controller.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class BusinessAndInnovationCommunityScreen
    extends GetView<BusinessInnovationCommunityController> {
  const BusinessAndInnovationCommunityScreen({super.key});

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

            // Categories Grid View
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Obx(() => GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
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
        Get.toNamed(Routes.CONSENT_SCREEN);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF3E9292).withOpacity(0.3),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category Name
              Text(
                category,
                style: TextStyle(
                  fontSize: ScreenUtils.x(6),
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
