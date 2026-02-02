import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Components/top_navbar.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';

import '../../../../../Components/bottom_navbar.dart';
import '../controllers/learn_screen_controller.dart';

class LearnScreenView extends GetView<LearnScreenController> {
  const LearnScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtils.setContext(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: CustomTopNavBar(selectedIndex: null, isMainScreen: true),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ScreenUtils.width * 0.05,
                vertical: ScreenUtils.height * 0.02),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: ScreenUtils.height * 0.04),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtils.width * 0.05,
                            vertical: ScreenUtils.height * 0.03),
                        width: ScreenUtils.width * 0.8,
                        height: ScreenUtils.height * 0.38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(0xFF006DF4).withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 4)),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "stay",
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF616161),
                                  ),
                                ),
                                Text(
                                  "consistent ,",
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF006DF4),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: ScreenUtils.height * 0.02),
                            Column(
                              children: [
                                Text(
                                  "let curiosity",
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF616161),
                                  ),
                                ),
                                Text(
                                  "compound",
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF006DF4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: -25,
                        right: -10,
                        child: Container(
                          height: ScreenUtils.height * 0.07,
                          width: ScreenUtils.width * 0.15,
                          decoration: BoxDecoration(
                            color: Color(0xFF6A3DBE),
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(12),
                          child: Image.asset('assets/icons/downward_arrow.png',
                              color: Colors.white, height: 25, width: 25),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: ScreenUtils.height * 0.042),

                Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF006DF4),
                      ),
                    );
                  }

                  // Show first 2 categories from API
                  return Column(
                    children: [
                      // First category
                      if (controller.mainCategories.isNotEmpty)
                        _buildCategoryCard(controller.mainCategories[0], 0),
                      SizedBox(height: ScreenUtils.height * 0.058),
                      // Second category
                      if (controller.mainCategories.length > 1)
                        _buildCategoryCard(
                          controller.mainCategories[1],
                          1,
                        )
                    ],
                  );
                }),

                // Info Cards

                SizedBox(height: ScreenUtils.height * 0.056),

                // Bottom Image
                Image.asset(
                  'assets/images/targetImage.png',
                  height: ScreenUtils.height * 0.3,
                  width: ScreenUtils.width * 0.45,
                ),

                SizedBox(height: ScreenUtils.height * 0.057),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
    // Note: NoBackScope wraps the Scaffold above and blocks system/back pops.
  }

  Widget _infoCard(
    String title,
    String subtitle,
    Color color,
    String actionText,
    String imagePath,
    double imageHeight,
    double imageWidth,
    double imageSpaceWidth,
    VoidCallback onPressed1,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed1,
      child: Container(
        height: ScreenUtils.height * 0.40,
        width: double.infinity,
        padding: EdgeInsets.only(
            top: ScreenUtils.height * 0.015,
            bottom: ScreenUtils.height * 0.01,
            left: ScreenUtils.width * 0.05,
            right: ScreenUtils.width * 0.02),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Left Text Section
                Flexible(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFFD9D9D9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: ScreenUtils.height * 0.04),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                    ],
                  ),
                ),

                SizedBox(width: ScreenUtils.width * 0.08),
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(right: ScreenUtils.width * 0.04),
                    child: Image.asset(
                      imagePath,
                      height: imageHeight,
                      width: imageWidth,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenUtils.height * 0.055),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: ScreenUtils.width * 0.5,
                height: ScreenUtils.height * 0.045,
                child: ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtils.width * 0.05,
                        vertical: ScreenUtils.height * 0.01),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        actionText,
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(width: ScreenUtils.width * 0.05),
                      const Icon(Icons.arrow_forward, size: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, int index) {
    final colors = [
      Color(0xFFE93A47), // Red
      Color(0xFF3E9292), // Teal
      Color(0xFF6A3DBE), // Purple
    ];

    final images = [
      'assets/images/cupboard.png',
      'assets/images/communityForum.png',
      'assets/images/knowledgeCenter.png',
    ];

    final color = colors[index % colors.length];
    final image = images[index % images.length];

    return _infoCard(
      category['name']?.toString().toLowerCase() ?? "CATEGORY",
      category['description']?.toString() ?? "Explore this category",
      color,
      "explore",
      image,
      ScreenUtils.height * 0.128,
      ScreenUtils.width * 0.2,
      ScreenUtils.width * 0.08,
      () => _onCategoryTap(category),
      () => _onCategoryTap(category),
    );
  }

  void _onCategoryTap(Map<String, dynamic> category) {
    final categoryId = category['_id']?.toString();
    if (categoryId != null) {
      // Load subcategories and navigate to detail view
      controller.onCategoryTap(category);
    }
  }
}
