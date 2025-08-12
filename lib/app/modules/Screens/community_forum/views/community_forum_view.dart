import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Utilities/constants/KImages.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import 'package:vropay_final/app/modules/Screens/community_forum/controllers/community_forum_controller.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

import '../../../../../Components/bottom_navbar.dart';
import '../../../../../Components/top_navbar.dart';

class CommunityForumView extends GetView<CommunityForumController> {
  const CommunityForumView({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtils.setContext(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      bottomNavigationBar: CustomBottomNavBar(),
      body: SafeArea(
        child: Column(
          children: [
            const CustomTopNavBar(selectedIndex: null),
            Padding(
              padding: const EdgeInsets.all(16.0),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                          hintText: 'Try searching the community like “STOCKS”',
                          hintStyle: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF4A4A4A)),
                          filled: true,
                          fillColor: const Color(0xFFDBEFFF).withOpacity(0.5),
                          prefixIcon: Image.asset(KImages.searchIcon),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: Container(
                              height: ScreenUtils.height * 0.02,
                              width: ScreenUtils.width * 0.02,
                              color: Color(0xFFF2F7FB),
                              child: Icon(CupertinoIcons.clear,
                                  color: Color(0xFF4A4A4A)))),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.02),
                    SizedBox(
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 70,
                                    color: Color(0xFF18707C),
                                  ),
                                  children: [
                                    TextSpan(
                                        text: "find\n",
                                        style: TextStyle(
                                            color: Color(0xFF5A9267),
                                            fontWeight: FontWeight.w300)),
                                    TextSpan(
                                      text: "Your\n",
                                      style: TextStyle(
                                        color: Color(0xFF4D6348),
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Tribe",
                                      style: TextStyle(
                                        color: Color(0xFF25525C),
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Image.asset(
                              'assets/images/findYourTribe.png',
                              height: ScreenUtils.height * 0.3,
                              width: ScreenUtils.width * 0.5,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.03),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "jump back into",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3E9292),
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Image.asset(
                              'assets/images/message.png',
                              color: Color(0xFF3E9292),
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.02),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFFDBEFFF).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "AI (name of last community connected)",
                        style: TextStyle(
                            color: Color(0xFF4A4A4A),
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.02),
                    _buildCard('world\n&\nculture', () {
                      Get.toNamed(Routes.WORLD_AND_CULTURE_COMMUNITY_SCREEN);
                    }),
                    SizedBox(height: ScreenUtils.height * 0.02),
                    _buildCard('personal\ngrowth', () {
                      Get.toNamed(Routes.PERSONAL_GROWTH_COMMUNITY_SCREEN);
                    }),
                    SizedBox(height: ScreenUtils.height * 0.02),
                    _buildCard('business\n&\ninnovation', () {
                      Get.toNamed(Routes.BUSINESS_INNOVATION_COMMUNITY_SCREEN);
                    }),
                    SizedBox(height: ScreenUtils.height * 0.02),
                    Container(
                      color: const Color(0xFF01B3B2),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "most active",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 25,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 200, // Adjust as needed
                                    child: Divider(),
                                  ),
                                  const Text(
                                    "communities",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 25,
                                    ),
                                  ),
                                ],
                              ),
                              Image.asset(
                                KImages.profile1Icon,
                                height: 50,
                                width: 50,
                              ),
                              SizedBox(
                                width: 10,
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            children: const [
                              _CommunityBox(
                                label: 'STOCKS',
                                color: Color(0xFF02D7C3),
                                colorText: Color(0xFF4B7C24),
                              ),
                              _CommunityBox(
                                label: 'TECH',
                                color: Color(0xFF01451E),
                                colorText: Color(0xFF32CD32),
                              ),
                              _CommunityBox(
                                label: 'QUANTUM LEAP',
                                color: Color(0xFF7DE7C1),
                                colorText: Color(0xFF4B7C24),
                              ),
                              _CommunityBox(
                                label: 'BOOKS',
                                color: Color(0xFF32CD32),
                                colorText: Color(0xFF01451E),
                              ),
                              _CommunityBox(
                                label: 'FINANCE',
                                color: Color(0xFF22C58D),
                                colorText: Color(0xFF01451E),
                              ),
                              _CommunityBox(
                                label: 'MUSIC',
                                color: Color(0xFF109D58),
                                colorText: Color(0xFF32CD32),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: 304,
          height: 355,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFF3E9292),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: ScreenUtils.height * 0.04),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 40, color: Color(0xFFD9D9D9)),
              ),
              const Spacer(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("know more",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(Icons.arrow_forward, color: Colors.white),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _CommunityBox extends StatelessWidget {
  final String label;
  final Color color;
  final Color colorText;

  const _CommunityBox(
      {required this.label, required this.color, required this.colorText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.w500, color: colorText, fontSize: 25),
        ),
      ),
    );
  }
}
