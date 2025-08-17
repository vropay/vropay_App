import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Components/bottom_navbar.dart';
import 'package:vropay_final/Components/top_navbar.dart';
import 'package:vropay_final/Utilities/constants/KImages.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import 'package:vropay_final/app/modules/Screens/knowledge_center_Screen/controllers/knowledge_center_screen_controller.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class KnowledgeCenterScreenView
    extends GetView<KnowledgeCenterScreenController> {
  const KnowledgeCenterScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtils.setContext(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      bottomNavigationBar: CustomBottomNavBar(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: CustomTopNavBar(selectedIndex: null),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                          hintText: 'Try searching the topic like “STOCKS”',
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
                          Padding(
                            padding: const EdgeInsets.only(left: 10, top: 10),
                            child: Column(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 70,
                                      color: Color(0xFFFA7244),
                                    ),
                                    children: [
                                      TextSpan(
                                          text: "push\n",
                                          style: TextStyle(
                                              color: Color(0xFFFA7244),
                                              fontWeight: FontWeight.w300)),
                                      TextSpan(
                                        text: "Your\n",
                                        style: TextStyle(
                                          color: Color(0xFFFF4601),
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "Limits",
                                        style: TextStyle(
                                          color: Color(0xFFBD1C19),
                                          fontSize: 70,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: ScreenUtils.height * 0.06,
                            right: ScreenUtils.width * 0.0,
                            child: Image.asset(
                              'assets/images/knowledgeCenter.png',
                              height: ScreenUtils.height * 0.2,
                              width: ScreenUtils.width * 0.4,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.036),
                    Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "continue reading",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFE93A47),
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Image.asset(
                              'assets/icons/knowledgeicon.png',
                              width: 25,
                              height: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.02),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(left: 5, right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFFDBEFFF).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "INVESTING (title of last topic read)",
                        style: TextStyle(
                            color: Color(0xFF4A4A4A),
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.only(left: 24, right: 24),
                      child: _buildCard('world\n&\nculture', () {
                        Get.toNamed(Routes.WORLD_AND_CULTURE_SCREEN);
                      }, ScreenUtils.height * 0.036,
                          ScreenUtils.height * 0.045),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.only(left: 24, right: 24),
                      child: _buildCard('personal\ngrowth', () {
                        Get.toNamed(Routes.PERSONAL_GROWTH_SCREEN);
                      }, ScreenUtils.height * 0.056,
                          ScreenUtils.height * 0.040),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.only(left: 24, right: 24),
                      child: _buildCard('business\n&\ninnovation', () {
                        Get.toNamed(Routes.BUSINESS_INNOVATION_SCREEN);
                      }, ScreenUtils.height * 0.027,
                          ScreenUtils.height * 0.045),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.02),
                    Card(
                      color: Color(0xFFF9E4D7),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "today's",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFE93A47),
                                        fontSize: 25,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Container(
                                      width: ScreenUtils.width * 0.4,
                                      height: 1,
                                      color: Color(0xFFE93A47),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "readings",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFFE93A47),
                                        fontSize: 25,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: ScreenUtils.width * 0.1,
                                ),
                                Image.asset(
                                  'assets/icons/communitybox.png',
                                  height: 30,
                                )
                              ],
                            ),
                            SizedBox(height: ScreenUtils.height * 0.02),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 29,
                              padding: EdgeInsets.only(
                                bottom: 37,
                              ),
                              children: const [
                                _CommunityBox(
                                  label: 'HEALTH',
                                  color: Color(0xFFFF4F4E),
                                  colorText: Color(0xFF8E2100),
                                ),
                                _CommunityBox(
                                  label: 'ASTRO',
                                  color: Color(0xFF8E2100),
                                  colorText: Color(0xFFFF0017),
                                ),
                                _CommunityBox(
                                  label: 'TRAVEL',
                                  color: Color(0xFFFF692D),
                                  colorText: Color(0xFFD80031),
                                ),
                                _CommunityBox(
                                  label: 'BOOKS',
                                  color: Color(0xFFFF0017),
                                  colorText: Color(0xFF690005),
                                ),
                                _CommunityBox(
                                  label: 'FINANCE',
                                  color: Color(0xFFFE8081),
                                  colorText: Color(0xFF8E2100),
                                ),
                                _CommunityBox(
                                  label: 'MUSIC',
                                  color: Color(0xFFA65854),
                                  colorText: Color(0xFFFF692D),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.050),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      String text, VoidCallback onTap, double topHeight, double bottomHeight) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: ScreenUtils.width * 0.73,
          height: ScreenUtils.height * 0.4,
          padding: EdgeInsets.only(
              top: topHeight, left: 22, right: 22, bottom: bottomHeight),
          decoration: BoxDecoration(
            color: Color(0xFFE93A47),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.5),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 40, color: Color(0xFFD9D9D9)),
                ),
              ),
              Spacer(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
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
        borderRadius: BorderRadius.circular(5),
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
