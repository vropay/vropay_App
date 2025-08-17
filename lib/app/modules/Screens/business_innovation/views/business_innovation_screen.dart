import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Components/bottom_navbar.dart';
import 'package:vropay_final/Components/top_navbar.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import 'package:vropay_final/app/modules/Screens/business_innovation/controllers/business_innovation_controller.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class BusinessInnovationScreen extends GetView<BusinessInnovationController> {
  const BusinessInnovationScreen({super.key});

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

            const SizedBox(height: 34),
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
        height: ScreenUtils.height * 0.2,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _getCategoryContainerColor(category),
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

  double _getCategoryFontSize(String category) {
    switch (category) {
      case 'STARTUP':
        return 50;
      case 'INVESTING':
        return 44;
      case 'FINANCE':
        return 50;
      case 'STOCKS':
        return 50;
      case 'TECH':
        return 50;
      case 'AI TOOLS':
        return 50;
      case 'HUSTLE':
        return 50;
      default:
        return ScreenUtils.x(7.0);
    }
  }

  Color _getCategoryContainerColor(String category) {
    switch (category) {
      case 'STARTUP':
        return Color(0xFFDFDFDF).withOpacity(0.2); // Light green background
      case 'INVESTING':
        return Color(0xFFDFDFDF).withOpacity(0.2); // Light blue background
      case 'FINANCE':
        return Color(0xFFDFDFDF).withOpacity(0.2); // Light red background
      case 'STOCKS':
        return Color(0xFFDFDFDF).withOpacity(0.25); // Light purple background
      case 'TECH':
        return Color(0xFFDFDFDF).withOpacity(0.25); // Light orange background
      case 'AI TOOLS':
        return Color(0xFFDFDFDF).withOpacity(0.25); // Light indigo background
      case 'HUSTLE':
        return Color(0xFFDFDFDF).withOpacity(0.25); // Light pink background
      default:
        return Color(0xFFDFDFDF).withOpacity(0.2); // Default light gray
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'STARTUP':
        return Color(0xFFFF692D);
      case 'INVESTING':
        return Color(0xFFAB272D);
      case 'FINANCE':
        return Color(0xFFD80031);
      case 'STOCKS':
        return Color(0xFFA65854);
      case 'TECH':
        return Color(0xFFFF0017);
      case 'AI TOOLS':
        return Color(0xFF690005);
      case 'HUSTLE':
        return Color(0xFFE50B5F);
      default:
        return Color(0xFF18707C);
    }
  }
}
