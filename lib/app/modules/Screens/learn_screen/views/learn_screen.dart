import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Components/top_navbar.dart';

import 'package:vropay_final/app/routes/app_pages.dart';

import '../../../../../Components/bottom_navbar.dart';
import '../controllers/learn_screen_controller.dart';

class LearnScreenView extends GetView<LearnScreenController> {
  const LearnScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: CustomTopNavBar(selectedIndex: null),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        width: 304,
                        height: 325,
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
                              offset: Offset(0, 4),
                            ),
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
                                    fontWeight: FontWeight.w500,
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
                                    fontWeight: FontWeight.w400,
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
                        bottom: -35,
                        right: -10,
                        child: SizedBox(
                          height: 60,
                          width: 60,
                          child: FloatingActionButton(
                              onPressed: () {},
                              backgroundColor: Color(0xFF6A3DBE),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Image.asset(
                                  'assets/icons/downward_arrow.png',
                                  color: Colors.white,
                                  height: 40)),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // Info Cards
                _infoCard(
                  "Knowledge\n Center",
                  "Articles, blogs, explainers &\nvisuals on tech, money,\nmindset & more.",
                  Color(0xFFE93A47),
                  "learn",
                  'assets/images/cupboard.png',
                  128,
                  80,
                  () => Get.toNamed(Routes.KNOWLEDGE_CENTER_SCREEN),
                ),
                SizedBox(height: 40),

                _infoCard(
                  "Community\n Forum",
                  "Talk with the community\nfor real questions, real\nopinions, zero fluff.",
                  Color(0xFF3E9292),
                  "engage",
                  'assets/images/communityForum.png',
                  122,
                  102,
                  () => Get.toNamed(Routes.COMMUNITY_FORUM),
                ),
                SizedBox(height: 40),

                _infoCard(
                  "StartUp Tuition",
                  "Turn your ideas into action with simplified startup knowledge",
                  Color(0xFFEF9736),
                  "prepare",
                  'assets/images/startUp.png',
                  133,
                  107,
                  () => Get.toNamed(Routes.TRACK_SELECTION),
                ),
                SizedBox(height: 40),

                // Bottom Image
                Image.asset(
                  'assets/images/targetImage.png',
                  height: 178,
                  width: 207,
                ),
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
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Text Section
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 250,
                    child: ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            actionText,
                            style: TextStyle(fontSize: 15),
                          ),
                          const SizedBox(width: 40),
                          const Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 20),
          Image.asset(
            imagePath,
            height: imageHeight,
            width: imageWidth,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
