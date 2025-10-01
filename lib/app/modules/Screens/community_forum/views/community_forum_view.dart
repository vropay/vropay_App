import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Utilities/constants/KImages.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import 'package:vropay_final/app/modules/Screens/community_forum/controllers/community_forum_controller.dart';

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
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(150),
          child: const CustomTopNavBar(selectedIndex: null)),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: ScreenUtils.height * 0.04),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: TextField(
                        decoration: InputDecoration(
                            hintText:
                                'Try searching the community like “STOCKS”',
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
                                height: ScreenUtils.height * 0.01,
                                width: ScreenUtils.width * 0.01,
                                color: Color(0xFFF2F7FB),
                                child: Icon(CupertinoIcons.clear,
                                    color: Color(0xFF4A4A4A)))),
                      ),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.02),
                    SizedBox(
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 32, right: 20),
                            child: Column(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                        fontSize: 70,
                                        color: Color(0xFF18707C),
                                        height: 1,
                                        fontWeight: FontWeight.w300),
                                    children: [
                                      TextSpan(
                                          text: "find\n",
                                          style: TextStyle(
                                              color: Color(0xFF5A9267),
                                              fontWeight: FontWeight.w300,
                                              fontSize: 70)),
                                      TextSpan(
                                        text: "Your\n",
                                        style: TextStyle(
                                            color: Color(0xFF4D6348),
                                            fontWeight: FontWeight.w300,
                                            fontSize: 70),
                                      ),
                                      TextSpan(
                                        text: "Tribe",
                                        style: TextStyle(
                                            color: Color(0xFF25525C),
                                            fontWeight: FontWeight.w300,
                                            fontSize: 70),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 15,
                            right: 25,
                            child: Image.asset(
                              'assets/images/findYourTribe.png',
                              height: 169,
                              width: 129,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.038),
                    Padding(
                      padding: const EdgeInsets.only(left: 45, right: 20),
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
                      margin: EdgeInsets.only(left: 20, right: 20),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 16),
                      decoration: BoxDecoration(
                        color: Color(0xFFDBEFFF).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "AI",
                        style: TextStyle(
                            color: Color(0xFF4A4A4A),
                            fontSize: 20,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.02),
                    // Dynamic content - API integration with existing UI
                    Obx(() {
                      if (controller.isLoading.value) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: Color(0xFF01B3B2),
                            ),
                          ),
                        );
                      }

                      if (controller.subCategories.isNotEmpty) {
                        return _buildApiContent();
                      }

                      return SizedBox.shrink();
                    }),

                    // Existing static cards (kept as-is)
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: _buildCard('world\n&\nculture', () {
                        _loadCommunityDataFromAPI(
                            'world-culture-main-category-id');
                      }, ScreenUtils.height * 0.058,
                          ScreenUtils.height * 0.039),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: _buildCard('personal\ngrowth', () {
                        _loadCommunityDataFromAPI(
                            'personal-growth-main-category-id');
                      }, ScreenUtils.height * 0.07, ScreenUtils.height * 0.039),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.02),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, right: 40),
                      child: _buildCard('business\n&\ninnovation', () {
                        _loadCommunityDataFromAPI(
                            'business-innovation-main-category-id');
                      }, ScreenUtils.height * 0.04, ScreenUtils.height * 0.04),
                    ),
                    SizedBox(height: ScreenUtils.height * 0.063),
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
                          SizedBox(height: ScreenUtils.height * 0.03),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 29,
                            padding: EdgeInsets.only(
                              bottom: 37,
                            ),
                            children: [
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

  // Build API content using existing card style
  Widget _buildApiContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: controller.subCategories
          .map((subCategory) => _buildSubCategoryCard(subCategory))
          .toList(),
    );
  }

  // Build subcategory card using existing _buildCard UI
  Widget _buildSubCategoryCard(Map<String, dynamic> subCategory) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: _buildCard(
        subCategory['name']?.toString().toLowerCase() ?? 'SUBCATEGORY',
        () => _onSubCategoryTap(subCategory),
        ScreenUtils.height * 0.058,
        ScreenUtils.height * 0.039,
      ),
    );
  }

  // Handle subcategory tap (hook for navigation or further loading)
  void _onSubCategoryTap(Map<String, dynamic> subCategory) {
    final subCategoryName = subCategory['name']?.toString() ?? 'Subcategory';
    final subCategoryId = subCategory['_id']?.toString();

    print(
        '🚀 CommunityForum - SubCategory tapped: $subCategoryName (ID: $subCategoryId)');

    // For now, just acknowledge selection. Hook up navigation if needed.
    Get.snackbar(
      'Selected',
      'Opening $subCategoryName...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF01B3B2),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
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
            color: Color(0xFF3E9292),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 40, color: Color(0xFFD9D9D9)),
              ),
              const Spacer(),
              Row(
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

  // Load community data from API when card is tapped
  void _loadCommunityDataFromAPI(String mainCategoryId) async {
    print(
        '🚀 CommunityForum - Loading API data for main category: $mainCategoryId');

    // Show loading message
    Get.snackbar(
      'Loading...',
      'Fetching community data from API...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF01B3B2),
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );

    try {
      // Load community data using the controller method
      await controller.loadCommunityDataForCategory(mainCategoryId);

      // Show success message
      Get.snackbar(
        'Success',
        'Community data loaded from API!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        icon: Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      print('❌ CommunityForum - Error loading API data: $e');

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to load community data from API',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        icon: Icon(Icons.error, color: Colors.white),
      );
    }
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
