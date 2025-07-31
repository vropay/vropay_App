import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/modules/Screens/community_forum/controllers/community_forum_controller.dart';
import 'package:vropay_final/app/modules/Screens/knowledge_center_Screen/controllers/knowledge_center_screen_controller.dart';

import '../../../../../Components /bottom_navbar.dart';
import '../../../../../Components /top_navbar.dart';


class KnowledgeCenterScreenView extends GetView<KnowledgeCenterScreenController> {
  const KnowledgeCenterScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                        hintText: 'Try searching the topic like “STOCKS”',
                        filled: true,
                        fillColor: const Color(0xFFDBEFFF),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 3,
                            child: Column(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 70,
                                      color: Color(0xFFFA7244),
                                    ),
                                    children: [
                                      TextSpan(text: "push\n", style: TextStyle(
                                          color: Color(0xFFFA7244),
                                          fontWeight: FontWeight.w300
                                      )),
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
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Center(
                              child: Image.asset(
                                'assets/images/knowledgeCenter.png',
                                height: 150,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
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
                          const SizedBox(width: 8,),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Image.asset(
                              'assets/icons/knowledgeicon.png',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFFDBEFFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text("INVESTING (title of last topic read)"),
                    ),
                    const SizedBox(height: 16),
                    _buildCard('world\n&\nculture'),
                    const SizedBox(height: 12),
                    _buildCard('personal\ngrowth'),
                    const SizedBox(height: 12),
                    _buildCard('business\n&\ninnovation'),
                    const SizedBox(height: 24),
                    Container(
                      color: const Color(0xFFF9E4D7),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                "today's\nreadings",
                                style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFFE93A47), fontSize: 25),
                              ),
                              SizedBox(width: 90,),
                              Image.asset('assets/icons/communitybox.png', height: 30,)
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
                              _CommunityBox(label: 'HEALTH', color: Color(0xFFFF4F4E), colorText: Color(0xFF8E2100),),
                              _CommunityBox(label: 'ASTRO', color: Color(0xFF8E2100), colorText: Color(0xFFFF0017),),
                              _CommunityBox(label: 'TRAVEL', color: Color(0xFFFF692D), colorText: Color(0xFFD80031),),
                              _CommunityBox(label: 'BOOKS', color: Color(0xFFFF0017), colorText: Color(0xFF690005),),
                              _CommunityBox(label: 'FINANCE', color: Color(0xFFFE8081), colorText: Color(0xFF8E2100),),
                              _CommunityBox(label: 'MUSIC', color: Color(0xFFA65854), colorText: Color(0xFFFF692D),),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String text) {
    return Center(
      child: Container(
        width: 304,
        height: 355,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Color(0xFFE93A47) ,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 40, color: Color(0xFFD9D9D9)),
              ),
            ),
            const SizedBox(height: 8),
            const Spacer(),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("know more",
                    textAlign: TextAlign.end,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                SizedBox(width: 10,),
                Icon(Icons.arrow_forward, color: Colors.white),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _CommunityBox extends StatelessWidget {
  final String label;
  final Color color;
  final Color colorText;

  const _CommunityBox({required this.label, required this.color, required this.colorText});

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
          style: TextStyle(fontWeight: FontWeight.normal, color: colorText, fontSize: 25),
        ),
      ),
    );
  }
}
