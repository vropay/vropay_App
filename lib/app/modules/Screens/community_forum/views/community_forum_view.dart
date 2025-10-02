import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

                      return SizedBox.shrink(
                        child: Text('No Data'),
                      );
                    }),

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

  // Handle subcategory tap - Navigate to appropriate topics screen
  void _onSubCategoryTap(Map<String, dynamic> subCategory) async {
    final subCategoryName = subCategory['name']?.toString() ?? 'Subcategory';
    final subCategoryId = subCategory['_id']?.toString();

    print(
        '🚀 CommunityForum - SubCategory tapped: $subCategoryName (ID: $subCategoryId)');

    // 1) Check API route first
    final apiRoute = _getRouteForSubCategoryFromApi(subCategory);

    if (apiRoute.isNotEmpty) {
      // Use API route with first-time visit logic
      await _handleApiRouteNavigation(subCategoryName, subCategoryId, apiRoute);
    } else {
      // Fallback to static name-based mapping (no first-time logic)
      final staticRoute = _getRouteForSubCategory(subCategoryName);

      if (staticRoute.isNotEmpty) {
        // Navigate directly to the static route
        Get.toNamed(staticRoute, arguments: {
          'subCategoryId': subCategoryId,
          'subCategoryName': subCategoryName,
          'categoryId': subCategoryId,
          'categoryName': subCategoryName,
          'mainCategoryId': controller.categoryId,
        });
      } else {
        // Fallback - show message if route not found
        Get.snackbar(
          'Coming Soon',
          'Topics for $subCategoryName will be available soon',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Color(0xFF01B3B2),
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }
    }
  }

  // Handle API route navigation with first-time visit logic
  Future<void> _handleApiRouteNavigation(
      String subCategoryName, String? subCategoryId, String apiRoute) async {
    // Check if this is the first time visiting this subcategory
    final isFirstTime = await _isFirstTimeVisit(subCategoryId ?? '');

    if (isFirstTime) {
      // Show consent screen first for first-time visitors
      _showConsentScreen(subCategoryName, subCategoryId, apiRoute);
    } else {
      // Navigate directly to message screen for returning visitors
      _navigateToMessageScreen(subCategoryName, subCategoryId);
    }
  }

// Check if this is the first time visiting a subcategory
  Future<bool> _isFirstTimeVisit(String subCategoryId) async {
    if (subCategoryId.isEmpty) return true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'subcategory_visited_$subCategoryId';
      return !(prefs.getBool(key) ?? false);
    } catch (e) {
      print('❌ Error checking first time visit: $e');
      return true; // Default to first time if error
    }
  }

// Mark subcategory as visited
  Future<void> _markAsVisited(String subCategoryId) async {
    if (subCategoryId.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'subcategory_visited_$subCategoryId';
      await prefs.setBool(key, true);
      print('✅ Marked subcategory $subCategoryId as visited');
    } catch (e) {
      print('❌ Error marking as visited: $e');
    }
  }

// Show consent screen for first-time visitors
  void _showConsentScreen(
      String subCategoryName, String? subCategoryId, String apiRoute) {
    Get.toNamed(Routes.CONSENT_SCREEN, arguments: {
      'subCategoryName': subCategoryName,
      'subCategoryId': subCategoryId,
      'onConsentAccepted': () {
        // Mark as visited and navigate to message screen
        if (subCategoryId != null) {
          _markAsVisited(subCategoryId);
        }
        _navigateToMessageScreen(subCategoryName, subCategoryId);
      },
    });
  }

// Navigate to message screen
  void _navigateToMessageScreen(String subCategoryName, String? subCategoryId) {
    Get.toNamed(Routes.MESSAGE_SCREEN, arguments: {
      'subCategoryId': subCategoryId,
      'subCategoryName': subCategoryName,
      'categoryId': subCategoryId,
      'categoryName': subCategoryName,
      'mainCategoryId': controller.categoryId,
    });
  }

  // Prefer server-provided route data on subcategory to avoid static mappings
  String _getRouteForSubCategoryFromApi(Map<String, dynamic> subCategory) {
    // Common potential keys from backend
    final List<String> possibleKeys = [
      'routePath', // preferred: absolute GetX route path, e.g. '/world-and-culture-community-screen'
      'route',
      'screenRoute',
      'screen_path',
      'path',
    ];

    for (final key in possibleKeys) {
      final value = subCategory[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) {
        // If it looks like a path, use directly
        if (value.startsWith('/')) return value;

        // If API returns a known constant alias, map here if needed
        final alias = value.toLowerCase();
        switch (alias) {
          case 'world_and_culture_community':
          case 'world-and-culture-community':
            return Routes.WORLD_AND_CULTURE_COMMUNITY_SCREEN;
          case 'personal_growth_community':
          case 'personal-growth-community':
            return Routes.PERSONAL_GROWTH_COMMUNITY_SCREEN;
          case 'business_innovation_community':
          case 'business-and-innovation-community':
            return Routes.BUSINESS_INNOVATION_COMMUNITY_SCREEN;
          default:
            // Treat as absolute path if prefixed later or leave empty to fallback
            break;
        }
      }
    }

    // Support a slug if provided (e.g., 'world-and-culture-community-screen')
    final slug = subCategory['slug']?.toString().trim() ?? '';
    if (slug.isNotEmpty) {
      // If slug is a full path, return it; otherwise try to map
      if (slug.startsWith('/')) return slug;
      final normalized = slug.toLowerCase();
      switch (normalized) {
        case 'world-and-culture-community-screen':
          return Routes.WORLD_AND_CULTURE_COMMUNITY_SCREEN;
        case 'personal-growth-community-screen':
          return Routes.PERSONAL_GROWTH_COMMUNITY_SCREEN;
        case 'business-and-innovation-community-screen':
          return Routes.BUSINESS_INNOVATION_COMMUNITY_SCREEN;
        default:
          return '';
      }
    }

    return '';
  }

  // Map subcategory names to route names
  String _getRouteForSubCategory(String subCategoryName) {
    final normalized = subCategoryName.toLowerCase().trim();

    // Handle variations in naming (including typos from backend)
    if (normalized.contains('business') && normalized.contains('innovation')) {
      return Routes.BUSINESS_INNOVATION_COMMUNITY_SCREEN;
    } else if (normalized.contains('world') && normalized.contains('culture')) {
      return Routes.WORLD_AND_CULTURE_COMMUNITY_SCREEN;
    } else if (normalized.contains('personal') &&
        normalized.contains('growth')) {
      return Routes.PERSONAL_GROWTH_COMMUNITY_SCREEN;
    }

    // Exact matches as fallback
    switch (normalized) {
      case 'business & innovation':
      case 'business and innovation':
      case 'business innovation':
        return Routes.BUSINESS_INNOVATION_COMMUNITY_SCREEN;
      case 'world & culture':
      case 'world and culture':
        return Routes.WORLD_AND_CULTURE_COMMUNITY_SCREEN;
      case 'personal growth':
        return Routes.PERSONAL_GROWTH_COMMUNITY_SCREEN;
      default:
        return ''; // No specific route found
    }
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
