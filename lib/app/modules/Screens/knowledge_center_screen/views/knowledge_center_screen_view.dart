import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Components%20/top_navbar.dart';
import 'package:vropay_final/app/modules/Screens/knowledge_center_screen/controllers/knowledge_center_screen_controller.dart';

import '../../../../../Components /bottom_navbar.dart';


class KnowledgeCenterScreenView extends GetView<KnowledgeCenterScreenController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const CustomTopNavBar(selectedIndex: 2),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
                            onPressed: () {
                              // Your action
                            },
                            backgroundColor: Color(0xFF6A3DBE),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Image.asset('assets/icons/downward_arrow.png', color: Colors.white, height:40)
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // Info Cards
                _infoCard(
                  "Knowledge Center",
                  "Articles, blogs, explainers & visuals on tech, money, mindset & more.",
                  Color(0xFFE93A47),
                  "learn",
                  'assets/images/cupboard.png',
                  128,
                  80,
                ),
                SizedBox(height: 20),

                _infoCard(
                  "Community Forum",
                  "Talk with the community for real questions, real opinions, zero fluff.",
                  Color(0xFF3E9292),
                  "engage",
                  'assets/images/communityForum.png',
                  122,
                  102,
                ),
                SizedBox(height: 20),

                _infoCard(
                  "StartUp Tuition",
                  "Turn your ideas into action with simplified startup knowledge",
                  Color(0xFFEF9736),
                  "prepare",
                  'assets/images/startUp.png',
                  133,
                  107,
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
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 1,),
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
      ) {
    return Container(
      height: 346,
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Image.asset(
                imagePath,
                height: imageHeight,
                width: imageWidth,
                fit: BoxFit.contain,
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: color,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(actionText),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
