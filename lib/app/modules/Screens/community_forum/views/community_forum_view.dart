import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/modules/Screens/community_forum/controllers/community_forum_controller.dart';

import '../../../../../Components/bottom_navbar.dart';
import '../../../../../Components/top_navbar.dart';

class CommunityForumView extends GetView<CommunityForumController> {
  const CommunityForumView({Key? key}) : super(key: key);

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
                        hintText: 'Try searching the community like “STOCKS”',
                        filled: true,
                        fillColor: const Color(0xFFDBEFFF),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.grey),
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
                          ),
                          Flexible(
                            flex: 2,
                            child: Center(
                              child: Image.asset(
                                'assets/images/findYourTribe.png',
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
                            "jump back into",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF18707C),
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
                              color: Color(0xFF18707C),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFFDBEFFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:
                          const Text("AI (name of last community connected)"),
                    ),
                    const SizedBox(height: 16),
                    _buildCard('world\n&\nculture', Color(0xFF02D7C3)),
                    const SizedBox(height: 12),
                    _buildCard('personal\ngrowth', Color(0xFF7DE7C1)),
                    const SizedBox(height: 12),
                    _buildCard('business\n&\ninnovation', Color(0xFF22C58D)),
                    const SizedBox(height: 24),
                    Container(
                      color: const Color(0xFF01B3B2),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "most active\ncommunities",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 25),
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

  Widget _buildCard(String text, Color color) {
    return Center(
      child: Container(
        width: 304,
        height: 355,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40, color: Color(0xFF4B7C24)),
            ),
            const SizedBox(height: 8),
            const Spacer(),
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
              fontWeight: FontWeight.normal, color: colorText, fontSize: 25),
        ),
      ),
    );
  }
}
