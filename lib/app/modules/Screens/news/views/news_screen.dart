import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:vropay_final/Components/bottom_navbar.dart';
import 'package:vropay_final/Components/top_navbar.dart';
import 'package:vropay_final/Utilities/constants/KImages.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import 'package:vropay_final/app/modules/Screens/news/controllers/news_controller.dart';
import 'package:vropay_final/app/core/api/api_constant.dart';

class NewsScreen extends GetView<NewsController> {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Set the context for ScreenUtils
    ScreenUtils.setContext(context);

    final GlobalKey moreVertButtonKey = GlobalKey();
    final GlobalKey filterButtonKey = GlobalKey();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: CustomTopNavBar(selectedIndex: null),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 56, right: 56),
                      child: Text(
                        "NEWS",
                        style: TextStyle(
                          fontSize: 85,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF01B3B2).withOpacity(0.5),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 75,
                      // This will overlay the text exactly in the center of "NEWS"
                      child: Text(
                        "know what is happening",
                        style: TextStyle(
                          fontSize: ScreenUtils.x(4.8),
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6253DB),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: ScreenUtils.height * 0.01),
            // Search Bar and View Mode Icon
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 20),
              child: Column(
                children: [
                  Container(
                    height: ScreenUtils.height * 0.06,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Obx(() => TextField(
                          onChanged: (value) =>
                              controller.updateSearchText(value),
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text: controller.searchText.value,
                              selection: TextSelection.collapsed(
                                  offset: controller.searchText.value.length),
                            ),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Try searching the relevant keyword',
                            hintStyle: TextStyle(
                                color: Color(0xFF172B75),
                                fontSize: ScreenUtils.x(3.5),
                                fontWeight: FontWeight.w300),
                            prefixIcon: controller.isSearching.value
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Color(0xFF172B75),
                                        ),
                                      ),
                                    ),
                                  )
                                : Image.asset(
                                    KImages.searchIcon,
                                    color: Color(0xFF172B75),
                                  ),
                            suffixIcon: controller.searchText.value.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Color(0xFF172B75),
                                    ),
                                    onPressed: () => controller.clearSearch(),
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                          ),
                        )),
                  ),

                  // Show suggested titles below search bar
                  Obx(() {
                    if (controller.searchText.value.isNotEmpty) {
                      final suggestions = controller.newsArticles.where((news) {
                        return news['title'].toString().toLowerCase().contains(
                            controller.searchText.value.toLowerCase());
                      }).toList();

                      if (suggestions.isNotEmpty) {
                        return Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(top: 8, left: 20, right: 20),
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
                              final news = suggestions[index];
                              return ListTile(
                                title: RichText(
                                  text: TextSpan(
                                      children: _highlightOccurrences(
                                        news['title'] ?? '',
                                        controller.searchText.value,
                                      ),
                                      style:
                                          TextStyle(color: Color(0xFF797C7B))),
                                ),
                                onTap: () {
                                  print(
                                      '🔍 SearchSuggestion - Tapped suggestion: ${news['title']}');
                                  print(
                                      '🔍 SearchSuggestion - News data: ${news.toString()}');

                                  // Navigate directly to NewsDetailScreen
                                  controller.navigateToNewsDetail(news);
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
            ),
            SizedBox(height: ScreenUtils.height * 0.046),

            // Filter and More Options Icons
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                children: [
                  SizedBox(width: ScreenUtils.width * 0.15),
                  GestureDetector(
                    key: filterButtonKey,
                    onTap: () async {
                      final RenderBox button = filterButtonKey.currentContext!
                          .findRenderObject() as RenderBox;
                      final RenderBox overlay = Navigator.of(context)
                          .overlay!
                          .context
                          .findRenderObject() as RenderBox;
                      final RelativeRect position = RelativeRect.fromRect(
                        Rect.fromPoints(
                          button.localToGlobal(Offset.zero, ancestor: overlay),
                          button.localToGlobal(
                              button.size.bottomRight(Offset.zero),
                              ancestor: overlay),
                        ),
                        Offset.zero & overlay.size,
                      );

                      await showGeneralDialog(
                        context: context,
                        barrierColor: Colors.transparent,
                        barrierDismissible: true,
                        barrierLabel: "Filter",
                        transitionDuration: Duration.zero,
                        pageBuilder: (context, anim1, anim2) {
                          return Stack(
                            children: [
                              // Blur background
                              Positioned.fromRect(
                                rect: Rect.fromPoints(
                                  Offset(0, 0),
                                  Offset(ScreenUtils.width * 0.05,
                                      ScreenUtils.height * 0.05),
                                ),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                              // The filter menu
                              Positioned(
                                left: 100,
                                top: position.top,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    height: ScreenUtils.height * 0.22,
                                    width: ScreenUtils.width * 0.45,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.transparent.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    padding: EdgeInsets.only(left: 30),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 14,
                                        ),
                                        _buildFilterChip(
                                            context,
                                            "All",
                                            controller.selectedFilter.value ==
                                                "All", () {
                                          controller.onFilterChanged("All");
                                          Navigator.of(context).pop();
                                        }),
                                        _buildFilterChip(
                                            context,
                                            "today",
                                            controller.selectedFilter.value ==
                                                "today", () {
                                          controller.onFilterChanged("today");
                                          Navigator.of(context).pop();
                                        }),
                                        _buildFilterChip(
                                            context,
                                            "this week",
                                            controller.selectedFilter.value ==
                                                "this week", () {
                                          controller
                                              .onFilterChanged("this week");
                                          Navigator.of(context).pop();
                                        }),
                                        _buildFilterChip(
                                            context,
                                            "this month",
                                            controller.selectedFilter.value ==
                                                "this month", () {
                                          controller
                                              .onFilterChanged("this month");
                                          Navigator.of(context).pop();
                                        }),
                                        SizedBox(
                                          height: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Image.asset(KImages.filterIcon),
                  ),

                  SizedBox(width: ScreenUtils.width * 0.1),
                  IconButton(
                    key: moreVertButtonKey,
                    onPressed: () async {
                      final RenderBox button = moreVertButtonKey.currentContext!
                          .findRenderObject() as RenderBox;
                      final RenderBox overlay = Navigator.of(context)
                          .overlay!
                          .context
                          .findRenderObject() as RenderBox;
                      final RelativeRect position = RelativeRect.fromRect(
                        Rect.fromPoints(
                          button.localToGlobal(Offset.zero, ancestor: overlay),
                          button.localToGlobal(
                              button.size.bottomRight(Offset.zero),
                              ancestor: overlay),
                        ),
                        Offset.zero & overlay.size,
                      );

                      // Custom menu with transparent and blur background
                      await showGeneralDialog(
                        context: context,
                        barrierColor: Colors.transparent,
                        barrierDismissible: true,
                        barrierLabel: "More Options",
                        transitionDuration: Duration.zero,
                        pageBuilder: (context, anim1, anim2) {
                          return Stack(
                            children: [
                              // Blur background
                              Positioned.fromRect(
                                rect: Rect.fromPoints(
                                  Offset(0, 0),
                                  Offset(ScreenUtils.width * 0.05,
                                      ScreenUtils.height * 0.05),
                                ),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                              // The more options menu
                              Positioned(
                                right: 100,
                                top: position.top,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Container(
                                    height: ScreenUtils.height * 0.18,
                                    width: ScreenUtils.width * 0.35,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.transparent.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: EdgeInsets.only(left: 30),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 11.5,
                                        ),
                                        _buildFilterChip(
                                            context,
                                            "All",
                                            controller.selectedFilter.value ==
                                                "All", () {
                                          controller.selectedFilter.value =
                                              "All";
                                          Navigator.of(context).pop();
                                        }),
                                        _buildFilterChip(
                                            context,
                                            "read",
                                            controller.selectedFilter.value ==
                                                "read", () {
                                          controller.selectedFilter.value =
                                              "read";
                                          Navigator.of(context).pop();
                                        }),
                                        _buildFilterChip(
                                            context,
                                            "unread",
                                            controller.selectedFilter.value ==
                                                "unread", () {
                                          controller.selectedFilter.value =
                                              "unread";
                                          Navigator.of(context).pop();
                                        }),
                                        SizedBox(
                                          height: 11.5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.more_vert),
                  ),

                  SizedBox(width: ScreenUtils.width * 0.125),
                  // View Mode Icon
                  Obx(() => AnimatedContainer(
                        duration: Duration(milliseconds: 250),
                        height: ScreenUtils.height * 0.056,
                        width: ScreenUtils.width * 0.29,
                        decoration: BoxDecoration(
                          color: Color(0xFFB5E3FF),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (controller.isGridView.value) return;
                                controller.toggleViewMode();
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 250),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: controller.isGridView.value
                                      ? Color(0xFF41B7FF)
                                      : Colors.transparent,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  Iconsax.grid_25,
                                  color: controller.isGridView.value
                                      ? Color(0xFFFFFFFF)
                                      : Color(0xFF65778E),
                                  size: 20,
                                ),
                              ),
                            ),
                            SizedBox(width: ScreenUtils.width * 0.030),
                            GestureDetector(
                              onTap: () {
                                if (!controller.isGridView.value) return;
                                controller.toggleViewMode();
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 250),
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: controller.isGridView.value
                                      ? Colors.transparent
                                      : Color(0xFF41B7FF),
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Image.asset(
                                  KImages.listIcon,
                                  color: !controller.isGridView.value
                                      ? Color(0xFFFFFFFF)
                                      : Color(0xFF65778E),
                                  height: 17,
                                  width: 19,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            SizedBox(height: ScreenUtils.height * 0.025),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Single Tap",
                  style: TextStyle(
                    fontSize: ScreenUtils.x(2.5),
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF00B8F0),
                  ),
                ),
                Text(
                  " will just mark as read",
                  style: TextStyle(
                    fontSize: ScreenUtils.x(2.5),
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            SizedBox(height: ScreenUtils.height * 0.02),

            // News Articles List/Grid
            Obx(() {
              if (controller.isLoading.value &&
                  controller.searchText.value.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF18707C),
                  ),
                );
              }

              // Show search error if there's an error
              if (controller.searchError.value.isNotEmpty &&
                  controller.searchText.value.isNotEmpty) {
                return Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Search Error',
                        style: TextStyle(
                          fontSize: ScreenUtils.x(4),
                          color: Colors.red[600],
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        controller.searchError.value,
                        style: TextStyle(
                          fontSize: ScreenUtils.x(3.5),
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () => controller.clearSearch(),
                        child: Text(
                          'Clear search',
                          style: TextStyle(
                            color: Color(0xFF714FC0),
                            fontSize: ScreenUtils.x(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final filteredNews = controller.filteredNews;

              // Show "no results" message for search
              if (filteredNews.isEmpty &&
                  controller.searchText.value.isNotEmpty) {
                return Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No results found for "${controller.searchText.value}"',
                        style: TextStyle(
                          fontSize: ScreenUtils.x(4),
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        controller.hasSearchResults.value
                            ? 'Try different keywords'
                            : 'Search in this topic for relevant content',
                        style: TextStyle(
                          fontSize: ScreenUtils.x(3.2),
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () => controller.clearSearch(),
                        child: Text(
                          'Clear search',
                          style: TextStyle(
                            color: Color(0xFF714FC0),
                            fontSize: ScreenUtils.x(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Show search results count if searching
              Widget content;
              if (controller.isGridView.value) {
                content = Padding(
                  padding: const EdgeInsets.only(left: 46, right: 46),
                  child: _buildGridView(filteredNews),
                );
              } else {
                content = _buildListView(filteredNews);
              }

              // Add search results header if we have search results
              if (controller.hasSearchResults.value &&
                  controller.searchText.value.isNotEmpty) {
                return Column(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                          Text(
                            '(${filteredNews.length} found)',
                            style: TextStyle(
                              fontSize: ScreenUtils.x(3),
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    content,
                  ],
                );
              }

              return content;
            }),
            SizedBox(height: ScreenUtils.height * 0.04),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> newsList) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 10),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: newsList.length,
      itemBuilder: (context, index) {
        final news = newsList[index];
        return _buildNewsCard(news, index);
      },
    );
  }

  Widget _buildGridView(List<Map<String, dynamic>> newsList) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 3,
        childAspectRatio: 1.2,
      ),
      itemCount: newsList.length,
      itemBuilder: (context, index) {
        final news = newsList[index];
        return _buildGridNewsCard(news, index);
      },
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> news, int index) {
    return GestureDetector(
      onTap: () {
        controller.navigateToNewsDetail(news);
      },
      child: Container(
        height: ScreenUtils.height * 0.12,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8, left: 20, right: 20),
        padding: const EdgeInsets.only(
          left: 0,
          right: 0,
        ),
        decoration: BoxDecoration(
          color: Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              height: ScreenUtils.height * 0.08,
              width: ScreenUtils.width * 0.18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
              ),
              child: (news['thumbnail'] != null &&
                      news['thumbnail'].toString().isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _buildNewsImage(
                        news['thumbnail'].toString(),
                        fit: BoxFit.fitWidth,
                        height: ScreenUtils.height * 0.08,
                        width: ScreenUtils.width * 0.18,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.article,
                        color: Colors.grey[600],
                        size: 24,
                      ),
                    ),
            ),

            // Spacing
            SizedBox(width: 12),

            // Title and content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  _buildNewsTitle(news),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridNewsCard(Map<String, dynamic> news, int index) {
    return GestureDetector(
      onTap: () {
        controller.navigateToNewsDetail(news);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Thumbnail covering the top part of the card
            Container(
              height: ScreenUtils.height * 0.08,
              width: ScreenUtils.width * 0.744,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: (news['thumbnail'] != null &&
                      news['thumbnail'].toString().isNotEmpty)
                  ? _buildNewsImage(
                      news['thumbnail'].toString(),
                      fit: BoxFit.cover,
                      height: ScreenUtils.height * 0.08,
                      width: ScreenUtils.width * 0.744,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          'Image',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: ScreenUtils.x(2.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
            ),
            // Title text below the image
            Container(
              height: ScreenUtils.height * 0.04,
              width: double.infinity,
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Center(
                child: _buildGridNewsTitle(news),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            fontSize: ScreenUtils.x(3.5),
          ),
        ),
      ),
    );
  }

  // Build news image widget that handles both assets and network images
  Widget _buildNewsImage(
    String imagePath, {
    double? height,
    double? width,
    BoxFit? fit,
  }) {
    print('🖼️ News - Building image with path: $imagePath');

    // Use centralized URL builder
    String finalImageUrl = ApiConstant.getImageUrl(imagePath);
    print('🔗 News - Final image URL: $finalImageUrl');

    // Check if it's an asset path
    if (imagePath.startsWith('assets/')) {
      print('📁 News - Loading asset image: $imagePath');
      return Image.asset(
        imagePath,
        height: height,
        width: width,
        fit: fit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey[400],
              size: height != null ? height * 0.4 : 24,
            ),
          );
        },
      );
    }

    // For all other cases (network URLs and backend images), use Image.network
    print('🌐 News - Loading network image: $finalImageUrl');
    return Image.network(
      finalImageUrl,
      height: height,
      width: width,
      fit: fit ?? BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('❌ News - Failed to load image: $finalImageUrl');
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey[400],
            size: height != null ? height * 0.4 : 24,
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              color: Colors.grey[400],
            ),
          ),
        );
      },
    );
  }

  // Format date for display
  String _formatDate(dynamic date) {
    if (date == null) return '';

    try {
      DateTime dateTime;
      if (date is String) {
        dateTime = DateTime.parse(date);
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        return '';
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      print('❌ News - Error formatting date: $e');
      return '';
    }
  }

  // Build grid news title with highlighting support for search results
  Widget _buildGridNewsTitle(Map<String, dynamic> news) {
    final title = news['title'] ?? '';
    final highlightedTitle = news['highlightedTitle'];

    // If we have a highlighted title from search results, use it
    if (highlightedTitle != null && highlightedTitle.toString().isNotEmpty) {
      return RichText(
        text: TextSpan(
          children: _parseHighlightedText(highlightedTitle.toString()),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E2025),
          ),
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Otherwise, use regular title
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1E2025),
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // Build news title with highlighting support for search results
  Widget _buildNewsTitle(Map<String, dynamic> news) {
    final title = news['title'] ?? '';
    final highlightedTitle = news['highlightedTitle'];

    // If we have a highlighted title from search results, use it
    if (highlightedTitle != null && highlightedTitle.toString().isNotEmpty) {
      return RichText(
        text: TextSpan(
          children: _parseHighlightedText(highlightedTitle.toString()),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1E2025),
          ),
        ),
        textAlign: TextAlign.start,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    // Otherwise, use regular title
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1E2025),
      ),
      textAlign: TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // Parse highlighted text from backend (handles <mark> tags)
  List<TextSpan> _parseHighlightedText(String highlightedText) {
    final List<TextSpan> spans = [];
    final RegExp markRegex = RegExp(r'<mark>(.*?)</mark>');

    int lastIndex = 0;
    markRegex.allMatches(highlightedText).forEach((match) {
      // Add text before the mark
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: highlightedText.substring(lastIndex, match.start),
          style: TextStyle(
            color: Color(0xFF1E2025),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ));
      }

      // Add highlighted text
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(
          color: Color(0xFF714FC0),
          fontSize: 15,
          fontWeight: FontWeight.w600,
          backgroundColor: Color(0xFF714FC0).withOpacity(0.1),
        ),
      ));

      lastIndex = match.end;
    });

    // Add remaining text
    if (lastIndex < highlightedText.length) {
      spans.add(TextSpan(
        text: highlightedText.substring(lastIndex),
        style: TextStyle(
          color: Color(0xFF1E2025),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ));
    }

    // If no marks were found, return the whole text as normal
    if (spans.isEmpty) {
      spans.add(TextSpan(
        text: highlightedText,
        style: TextStyle(
          color: Color(0xFF1E2025),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ));
    }

    return spans;
  }

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
          color: Color(0xFF714FC0),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ));

      start = index + query.length;
    }

    return spans;
  }
}
