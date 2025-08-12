import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
            const SizedBox(height: 16),

            // Categories List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
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

  Widget _buildCategoryCard(String category) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.NEWS_SCREEN);
      },
      child: Container(
        height: ScreenUtils.height * 0.15,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFFDFDFDF).withOpacity(0.4),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              fontSize: ScreenUtils.x(8),
              fontWeight: FontWeight.w400,
              color: _getCategoryColor(category),
            ),
          ),
        ),
      ),
    );
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
