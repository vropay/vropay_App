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
        child: CustomTopNavBar(selectedIndex: null, isMainScreen: true),
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

                    // Search field with suggestions dropdown (like news screen)
                    Column(
                      children: [
                        Container(
                          height: ScreenUtils.height * 0.05,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFDBEFFF).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Obx(() => TextField(
                                controller: controller.searchTextController,
                                onChanged: (value) {
                                  controller.searchTopicsDebounced(value);
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      'Try searching the topic like "STOCKS"',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF4A4A4A),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w300,
                                  ),
                                  prefixIcon: Image.asset(
                                    KImages.searchIcon,
                                    color: Color(0xFF4a4a4a),
                                  ),
                                  suffixIcon: controller
                                          .currentSearchQuery.value.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            color: Color(0xFF4a4a4a),
                                          ),
                                          onPressed: () =>
                                              controller.clearSearch(),
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                ),
                              )),
                        ),

                        // Show search suggestions below search bar (like news screen)
                        Obx(() {
                          if (controller.currentSearchQuery.value.isNotEmpty) {
                            final suggestions =
                                controller.searchResults.where((topic) {
                              return topic['name']
                                  .toString()
                                  .toLowerCase()
                                  .contains(controller.currentSearchQuery.value
                                      .toLowerCase());
                            }).toList();

                            if (suggestions.isNotEmpty) {
                              return Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(
                                    top: 8, left: 20, right: 20),
                                padding: EdgeInsets.only(left: 10, right: 20),
                                constraints: BoxConstraints(
                                  maxHeight: ScreenUtils.height * 0.3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.black.withOpacity(0.1)),
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(5),
                                      bottomRight: Radius.circular(5)),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: suggestions.length,
                                  itemBuilder: (context, index) {
                                    final topic = suggestions[index];
                                    return ListTile(
                                      leading: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF4A4A4A)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.topic,
                                          color: Color(0xFF4A4A4A),
                                          size: 16,
                                        ),
                                      ),
                                      title: RichText(
                                        text: TextSpan(
                                            children: _highlightOccurrences(
                                              topic['name'] ?? '',
                                              controller
                                                  .currentSearchQuery.value,
                                            ),
                                            style: TextStyle(
                                                color: Color(0xFF797C7B))),
                                      ),
                                      subtitle: topic['subCategory'] != null
                                          ? Text(
                                              'In: ${topic['subCategory']['name']}',
                                              style: TextStyle(
                                                color: Color(0xFF999999),
                                                fontSize: 12,
                                              ),
                                            )
                                          : null,
                                      onTap: () {
                                        print(
                                            '🔍 SearchSuggestion - Tapped suggestion: ${topic['name']}');
                                        _onTopicSearchResultTap(topic);
                                      },
                                    );
                                  },
                                ),
                              );
                            }
                          }
                          return SizedBox.shrink();
                        }),
                      ],
                    ),

                    SizedBox(height: ScreenUtils.height * 0.02),

                    // Your existing header section (unchanged)
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
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
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

                    // Your existing "continue reading" section (unchanged)
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
                          const SizedBox(width: 8),
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

                    // Dynamic content - API integration with your existing UI
                    Obx(() {
                      if (controller.isLoading.value) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: Color(0xFFE93A47),
                            ),
                          ),
                        );
                      }

                      // Show API data if available - SUBCATEGORIES first
                      if (controller.subCategories.isNotEmpty) {
                        return _buildApiContent();
                      }

                      // Fallback to your existing static content
                      return _buildStaticContent();
                    }),

                    SizedBox(height: ScreenUtils.height * 0.050),
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

  // Build API content using your existing UI structure - SUBCATEGORIES
  Widget _buildApiContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Continue reading container - always show
        Obx(() {
          // Get the last read entry title or default message
          final lastReadEntry = controller.continueReadingData['lastReadEntry'];
          final hasData = controller.continueReadingData.isNotEmpty &&
              lastReadEntry != null &&
              lastReadEntry is Map &&
              lastReadEntry['title'] != null;

          final displayTitle =
              hasData ? lastReadEntry['title'].toString() : 'Start Reading';

          final displaySubtitle = 'INVESTING';

          return GestureDetector(
            onTap: hasData ? () => controller.onContinueReadingTap() : null,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(left: 5, right: 6),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Color(0xFFDBEFFF).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasData ? displayTitle : displaySubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Color(0xFF4A4A4A),
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        }),
        SizedBox(height: ScreenUtils.height * 0.042),

        // SUBCATEGORIES using your existing card style
        ...controller.subCategories
            .map((subCategory) => _buildSubCategoryCard(subCategory))
            .toList(),
      ],
    );
  }

  // Build subcategory card using your existing card style
  Widget _buildSubCategoryCard(Map<String, dynamic> subCategory) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: _buildCard(
        subCategory['name']?.toString().toLowerCase() ?? 'SUBCATEGORY',
        () => _onSubCategoryTap(subCategory),
        ScreenUtils.height * 0.036,
        ScreenUtils.height * 0.045,
      ),
    );
  }

  // Handle subcategory tap - Navigate to specific subcategory screen
  void _onSubCategoryTap(Map<String, dynamic> subCategory) {
    final subCategoryName = subCategory['name']?.toString().toLowerCase() ?? '';
    final subCategoryId = subCategory['_id']?.toString();

    // Map subcategory names to route names
    String routeName = _getRouteForSubCategory(subCategoryName);

    if (routeName.isNotEmpty) {
      // Navigate to the specific subcategory screen with API data
      Get.toNamed(routeName, arguments: {
        'subCategoryId': subCategoryId,
        'subCategoryName': subCategory['name']?.toString(),
        'categoryId': controller.categoryId,
        'categoryName': controller.categoryName,
      });
    } else {
      // Fallback - show topics in dialog if route not found
      _showTopicsDialog(subCategory);
    }
  }

  // Map subcategory names to route names
  String _getRouteForSubCategory(String subCategoryName) {
    switch (subCategoryName.toLowerCase()) {
      case 'business & innovation':
      case 'business and innovation':
        return Routes.BUSINESS_INNOVATION_SCREEN;
      case 'world & culture':
      case 'world and culture':
        return Routes.WORLD_AND_CULTURE_SCREEN;
      case 'personal growth':
        return Routes.PERSONAL_GROWTH_SCREEN;
      // Add more mappings as needed
      default:
        return ''; // No specific route found
    }
  }

  // Fallback method - show topics in dialog
  void _showTopicsDialog(Map<String, dynamic> subCategory) async {
    final subCategoryId = subCategory['_id']?.toString();
    if (subCategoryId != null) {
      await controller.loadTopicsForSubCategory(subCategoryId);
      _showTopicsDialogContent(
          subCategory['name']?.toString() ?? 'Subcategory');
    }
  }

  // Show topics in a dialog using your existing UI style
  void _showTopicsDialogContent(String subCategoryName) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Topics in $subCategoryName',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              SizedBox(height: 16),
              Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(color: Color(0xFFE93A47)),
                  );
                }

                if (controller.learnTopics.isEmpty) {
                  return Text(
                    'No topics available',
                    style: TextStyle(color: Color(0xFF666666)),
                  );
                }

                return Column(
                  children: controller.learnTopics
                      .map((topic) => _buildTopicItem(topic))
                      .toList(),
                );
              }),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Close',
                      style: TextStyle(color: Color(0xFFE93A47)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build topic item using your existing UI style
  Widget _buildTopicItem(Map<String, dynamic> topic) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFE93A47).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.article_outlined,
            color: Color(0xFFE93A47),
            size: 20,
          ),
        ),
        title: Text(
          topic['name']?.toString() ?? 'Topic',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A4A4A),
          ),
        ),
        subtitle: Text(
          '${(topic['entries'] as List?)?.length ?? 0} entries available',
          style: TextStyle(
            color: Color(0xFF666666),
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFFE93A47),
          size: 16,
        ),
        onTap: () => _onTopicTap(topic),
      ),
    );
  }

  // Handle topic tap - load entries and show in dialog
  void _onTopicTap(Map<String, dynamic> topic) async {
    final topicId = topic['_id']?.toString();
    final subCategoryId = controller.selectedSubCategoryId.value;

    if (topicId != null && subCategoryId.isNotEmpty) {
      await controller.loadEntriesForTopic(subCategoryId, topicId);
      _showEntriesDialog(topic['name']?.toString() ?? 'Topic');
    }
  }

  // Show entries in a dialog using your existing UI style
  void _showEntriesDialog(String topicName) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Entries in $topicName',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A4A4A),
                ),
              ),
              SizedBox(height: 16),
              Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(color: Color(0xFFE93A47)),
                  );
                }

                if (controller.entries.isEmpty) {
                  return Text(
                    'No entries available',
                    style: TextStyle(color: Color(0xFF666666)),
                  );
                }

                return Column(
                  children: controller.entries
                      .map((entry) => _buildEntryItem(entry))
                      .toList(),
                );
              }),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Close',
                      style: TextStyle(color: Color(0xFFE93A47)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build entry item using your existing UI style
  Widget _buildEntryItem(Map<String, dynamic> entry) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFFE93A47).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.description_outlined,
            color: Color(0xFFE93A47),
            size: 20,
          ),
        ),
        title: Text(
          entry['title']?.toString() ?? 'Untitled',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A4A4A),
          ),
        ),
        subtitle: entry['body'] != null
            ? Text(
                entry['body'].toString(),
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFFE93A47),
          size: 16,
        ),
        onTap: () => _onEntryTap(entry),
      ),
    );
  }

  // Handle entry tap - navigate to detail screen
  void _onEntryTap(Map<String, dynamic> entry) {
    Get.back(); // Close dialog
    controller.onEntryTap(entry);
  }

  // Your existing static content (unchanged)
  Widget _buildStaticContent() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(left: 5, right: 6),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Color(0xFFDBEFFF).withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            "INVESTING (title of last topic read) Static content ",
            style: TextStyle(
              color: Color(0xFF4A4A4A),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(height: ScreenUtils.height * 0.02),
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: _buildCard('world\n&\nculture', () {
            Get.toNamed(Routes.WORLD_AND_CULTURE_SCREEN);
          }, ScreenUtils.height * 0.036, ScreenUtils.height * 0.045),
        ),
        SizedBox(height: ScreenUtils.height * 0.02),
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: _buildCard('personal\ngrowth', () {
            Get.toNamed(Routes.PERSONAL_GROWTH_SCREEN);
          }, ScreenUtils.height * 0.056, ScreenUtils.height * 0.040),
        ),
        SizedBox(height: ScreenUtils.height * 0.02),
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: _buildCard('business\n&\ninnovation', () {
            Get.toNamed(Routes.BUSINESS_INNOVATION_SCREEN);
          }, ScreenUtils.height * 0.027, ScreenUtils.height * 0.045),
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
                    SizedBox(width: ScreenUtils.width * 0.1),
                    Image.asset(
                      'assets/icons/communitybox.png',
                      height: 30,
                    ),
                  ],
                ),
                SizedBox(height: ScreenUtils.height * 0.02),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 29,
                  padding: EdgeInsets.only(bottom: 37),
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
      ],
    );
  }

  // Your existing card builder (unchanged)
  Widget _buildCard(
      String text, VoidCallback onTap, double topHeight, double bottomHeight) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Container(
          width: ScreenUtils.width * 0.73,
          height: ScreenUtils.height * 0.4,
          padding: EdgeInsets.only(
            top: topHeight,
            left: 22,
            right: 22,
            bottom: bottomHeight,
          ),
          decoration: BoxDecoration(
            color: Color(0xFFE93A47),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.5, left: 32, right: 32),
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
                  Text(
                    "know more",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search results header (like news screen)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Text(
                'Search Results',
                style: TextStyle(
                  fontSize: ScreenUtils.x(3.5),
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF172B75),
                ),
              ),
              SizedBox(width: 8),
              Obx(() => Text(
                    '(${controller.searchResults.length} found)',
                    style: TextStyle(
                      fontSize: ScreenUtils.x(3),
                      color: Colors.grey[600],
                    ),
                  )),
            ],
          ),
        ),
        SizedBox(height: ScreenUtils.height * 0.02),

        // Show search results or "No data found" message
        Obx(() {
          if (controller.searchResults.isEmpty) {
            // Show "No data found" message
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Color(0xFF999999),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No topics found',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try searching with different keywords',
                    style: TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Show search results as topic items
            return Column(
              children: controller.searchResults
                  .map((topic) => _buildTopicSearchResult(topic))
                  .toList(),
            );
          }
        }),
      ],
    );
  }

  // Build topic search result item
  Widget _buildTopicSearchResult(Map<String, dynamic> topic) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFE93A47).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.topic,
              color: Color(0xFFE93A47),
              size: 20,
            ),
          ),
          title: Text(
            topic['name']?.toString() ?? 'Topic',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF4A4A4A),
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (topic['subCategory'] != null)
                Text(
                  'In: ${topic['subCategory']['name'] ?? 'Unknown Category'}',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 12,
                  ),
                ),
              if (topic['entriesCount'] != null)
                Text(
                  '${topic['entriesCount']} entries available',
                  style: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFFE93A47),
            size: 16,
          ),
          onTap: () => _onTopicSearchResultTap(topic),
        ),
      ),
    );
  }

  // Handle topic search result tap
  void _onTopicSearchResultTap(Map<String, dynamic> topic) async {
    final topicId = topic['_id']?.toString();
    final topicName = topic['name']?.toString();
    final subCategoryId = topic['subCategory']?['_id']?.toString();
    final subCategoryName = topic['subCategory']?['name']?.toString();
    final mainCategoryId = controller.categoryId;
    final mainCategoryName = controller.categoryName;

    print('🔍 [KNOWLEDGE CENTER] Navigating to news screen...');
    print('🔍 [KNOWLEDGE CENTER] Topic Name: "$topicName"');
    print('🔍 [KNOWLEDGE CENTER] Topic ID: "$topicId"');
    print('🔍 [KNOWLEDGE CENTER] SubCategory ID: "$subCategoryId"');
    print('🔍 [KNOWLEDGE CENTER] MainCategory ID: "$mainCategoryId"');

    if (topicId != null && topicName != null) {
      // Navigate to news screen with topic data (like other screens)
      Get.toNamed(Routes.NEWS_SCREEN, arguments: {
        'topicId': topicId,
        'topicName': topicName,
        'subCategoryId': subCategoryId ?? '',
        'subCategoryName': subCategoryName ?? '',
        'categoryId': mainCategoryId ?? '',
        'categoryName': mainCategoryName ?? '',
      });

      print('✅ [KNOWLEDGE CENTER] Navigation initiated with arguments:');
      print('   - topicId: $topicId');
      print('   - topicName: $topicName');
      print('   - subCategoryId: $subCategoryId');
      print('   - categoryId: $mainCategoryId');
    } else {
      print('❌ [KNOWLEDGE CENTER] Missing required data for navigation');
      Get.snackbar('Error', 'Unable to navigate to topic');
    }
  }

  // Highlight search occurrences in text (from news screen)
  List<TextSpan> _highlightOccurrences(String text, String query) {
    if (query.isEmpty) {
      return [
        TextSpan(
          text: text,
          style: TextStyle(
            color: Color(0xFF797C7B),
            fontSize: ScreenUtils.x(3.5),
            fontWeight: FontWeight.w500,
          ),
        )
      ];
    }

    List<TextSpan> spans = [];
    String lowerText = text.toLowerCase();
    String lowerQuery = query.toLowerCase();
    int start = 0;

    while (true) {
      int index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(
          text: text.substring(start),
          style: TextStyle(
            color: Color(0xFF797C7B),
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: TextStyle(
            color: Color(0xFF797C7B),
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          color: Color(0xFFE93A47),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ));

      start = index + query.length;
    }

    return spans;
  }
}

// Your existing community box widget (unchanged)
class _CommunityBox extends StatelessWidget {
  final String label;
  final Color color;
  final Color colorText;

  const _CommunityBox({
    required this.label,
    required this.color,
    required this.colorText,
  });

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
            fontWeight: FontWeight.w500,
            color: colorText,
            fontSize: 25,
          ),
        ),
      ),
    );
  }
}
