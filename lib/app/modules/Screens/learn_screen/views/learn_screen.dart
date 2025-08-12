import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Components/top_navbar.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';

import 'package:vropay_final/app/routes/app_pages.dart';

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
        child: CustomTopNavBar(selectedIndex: null),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
                                    fontSize: 40,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF616161),
                                  ),
                                ),
                                Text(
                                  "consistent ,",
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF006DF4),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
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

                SizedBox(height: ScreenUtils.height * 0.03),

                // Info Cards
                _infoCard(
                  "Knowledge\n Center",
                  "Articles, blogs, explainers &\nvisuals on tech, money,\nmindset & more.",
                  Color(0xFFE93A47),
                  "learn",
                  'assets/images/cupboard.png',
                  ScreenUtils.height * 0.12,
                  ScreenUtils.width * 0.2,
                  () => Get.toNamed(Routes.KNOWLEDGE_CENTER_SCREEN),
                ),
                SizedBox(height: ScreenUtils.height * 0.03),

                _infoCard(
                  "Community\n Forum",
                  "Talk with the community\nfor real questions, real\nopinions, zero fluff.",
                  Color(0xFF3E9292),
                  "engage",
                  'assets/images/communityForum.png',
                  ScreenUtils.height * 0.12,
                  ScreenUtils.width * 0.2,
                  () => Get.toNamed(Routes.COMMUNITY_FORUM),
                ),
                SizedBox(height: ScreenUtils.height * 0.03),

                // Bottom Image
                Image.asset(
                  'assets/images/targetImage.png',
                  height: ScreenUtils.height * 0.3,
                  width: ScreenUtils.width * 0.65,
                ),

                SizedBox(height: ScreenUtils.height * 0.03),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }

  Widget _infoCard(
    String title,
    String subtitle,
    Color color,
    String actionText,
    String imagePath,
    double imageHeight,
    double imageWidth,
    VoidCallback onPressed,
  ) {
    return Container(
      height: ScreenUtils.height * 0.35,
      width: double.infinity,
      padding: EdgeInsets.only(top: 20, bottom: 10, left: 20, right: 10),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFFD9D9D9),
                    ),
                  ),
                  SizedBox(height: ScreenUtils.height * 0.02),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),

              SizedBox(width: ScreenUtils.width * 0.05),
              Image.asset(
                imagePath,
                height: imageHeight,
                width: imageWidth,
                fit: BoxFit.contain,
              ),
            ],
          ),
          SizedBox(height: ScreenUtils.height * 0.04),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: ScreenUtils.width * 0.5,
              height: ScreenUtils.height * 0.05,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
    );
  }
}
