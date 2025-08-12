import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/Components/bottom_navbar.dart';
import 'package:vropay_final/Components/top_navbar.dart';
import 'package:vropay_final/Utilities/constants/KImages.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import 'package:vropay_final/app/modules/Screens/news/controllers/news_controller.dart';
import 'package:vropay_final/app/modules/Screens/news/views/news_detail_screen.dart';

class NewsScreen extends GetView<NewsController> {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey _moreButtonKey = GlobalKey();
    final GlobalKey _moreVertButtonKey = GlobalKey();
    final GlobalKey _filterButtonKey = GlobalKey();

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
                    Text(
                      "NEWS",
                      style: TextStyle(
                        fontSize: ScreenUtils.x(25),
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF01B3B2).withOpacity(0.5),
                      ),
                    ),
                    Positioned(
                      // This will overlay the text exactly in the center of "NEWS"
                      child: Text(
                        "know what is happening",
                        style: TextStyle(
                          fontSize: ScreenUtils.x(5),
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
              padding: const EdgeInsets.only(left: 40.0, right: 20),
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
                            prefixIcon: Image.asset(
                              KImages.searchIcon,
                              color: Color(0xFF172B75),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Color(0xFF172B75),
                              ),
                              onPressed: () => controller.clearSearch(),
                            ),
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
                          margin: EdgeInsets.only(top: 8),
                          constraints: BoxConstraints(
                            maxHeight: ScreenUtils.height * 0.3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: Colors.black.withOpacity(0.1)),
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
                                  ),
                                ),
                                onTap: () {
                                  controller.searchText.value =
                                      news['title'] ?? ''; // Add null check
                                  // You can add navigation or other action here
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(width: ScreenUtils.width * 0.01),
                GestureDetector(
                  key: _filterButtonKey,
                  onTap: () async {
                    final RenderBox button = _filterButtonKey.currentContext!
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
                                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
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
                                  height: ScreenUtils.height * 0.16,
                                  width: ScreenUtils.width * 0.4,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: EdgeInsets.only(left: 30),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildFilterChip(
                                          context,
                                          "All",
                                          controller.selectedFilter.value ==
                                              "All", () {
                                        controller.selectedFilter.value = "All";
                                        Navigator.of(context).pop();
                                      }),
                                      _buildFilterChip(
                                          context,
                                          "today",
                                          controller.selectedFilter.value ==
                                              "today", () {
                                        controller.selectedFilter.value =
                                            "today";
                                        Navigator.of(context).pop();
                                      }),
                                      _buildFilterChip(
                                          context,
                                          "this week",
                                          controller.selectedFilter.value ==
                                              "this week", () {
                                        controller.selectedFilter.value =
                                            "this week";
                                        Navigator.of(context).pop();
                                      }),
                                      _buildFilterChip(
                                          context,
                                          "this month",
                                          controller.selectedFilter.value ==
                                              "this month", () {
                                        controller.selectedFilter.value =
                                            "this month";
                                        Navigator.of(context).pop();
                                      }),
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
                IconButton(
                  key: _moreVertButtonKey,
                  onPressed: () async {
                    final RenderBox button = _moreVertButtonKey.currentContext!
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
                                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
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
                                  height: ScreenUtils.height * 0.13,
                                  width: ScreenUtils.width * 0.3,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: EdgeInsets.only(left: 30),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildFilterChip(
                                          context,
                                          "All",
                                          controller.selectedFilter.value ==
                                              "All", () {
                                        controller.selectedFilter.value = "All";
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

                // View Mode Icon
                Obx(() => AnimatedContainer(
                      duration: Duration(milliseconds: 250),
                      height: ScreenUtils.height * 0.07,
                      width: ScreenUtils.width * 0.33,
                      decoration: BoxDecoration(
                        color: Color(0xFFB5E3FF),
                        borderRadius: BorderRadius.circular(20),
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
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.grid_view,
                                color: controller.isGridView.value
                                    ? Color(0xFFFFFFFF)
                                    : Color(0xFF65778E),
                                size: 30,
                              ),
                            ),
                          ),
                          SizedBox(width: ScreenUtils.width * 0.025),
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
                                height: 25,
                                width: 25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
            SizedBox(height: ScreenUtils.height * 0.01),
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
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF18707C),
                  ),
                );
              }

              final filteredNews = controller.filteredNews;

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
                        'No news found for "${controller.searchText.value}"',
                        style: TextStyle(
                          fontSize: ScreenUtils.x(4),
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
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

              if (controller.isGridView.value) {
                return _buildGridView(filteredNews);
              } else {
                return _buildListView(filteredNews);
              }
            }),
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
        mainAxisSpacing: 12,
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
        // Handle news tap
        Get.to(() => NewsDetailScreen(news: news));
      },
      child: Container(
        height: ScreenUtils.height * 0.15,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Color(0xFFDFDFDF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: ListTile(
            leading: (news['thumbnail'] != null &&
                    news['thumbnail'].toString().isNotEmpty)
                ? Image.asset(
                    news['thumbnail'],
                    height: 50,
                    width: 50,
                    fit: BoxFit.fitWidth,
                  )
                : Container(
                    height: ScreenUtils.height * 0.05,
                    width: ScreenUtils.width * 0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black.withOpacity(0.1)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      news['thumbnail'] != null &&
                              news['thumbnail'].toString().isNotEmpty
                          ? news['thumbnail'].toString()
                          : 'thumbnail',
                      style: TextStyle(
                        color: Color(0xFF616161),
                        fontSize: ScreenUtils.x(1),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
            title: Text(
              news['title'],
              style: TextStyle(
                fontSize: ScreenUtils.x(4),
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              textAlign: TextAlign.start,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridNewsCard(Map<String, dynamic> news, int index) {
    return GestureDetector(
      onTap: () {
        Get.to(() => NewsDetailScreen(news: news));
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(0xFFDFDFDF).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            (news['thumbnail'] != null &&
                    news['thumbnail'].toString().isNotEmpty)
                ? Image.asset(
                    news['thumbnail'],
                    height: ScreenUtils.height * 0.1,
                    width: ScreenUtils.width * 0.5,
                    fit: BoxFit.fitWidth,
                  )
                : Container(
                    height: ScreenUtils.height * 0.05,
                    width: ScreenUtils.width * 0.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black.withOpacity(0.1)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      news['thumbnail'] != null &&
                              news['thumbnail'].toString().isNotEmpty
                          ? news['thumbnail'].toString()
                          : 'thumbnail',
                      style: TextStyle(
                        color: Color(0xFF616161),
                        fontSize: ScreenUtils.x(1),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
            Text(
              news['keyword'],
              style: TextStyle(
                fontSize: ScreenUtils.x(3),
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getNewsColor(int index) {
    switch (index) {
      case 0:
        return Color(0xFFFF692D);
      case 1:
        return Color(0xFFAB272D);
      case 2:
        return Color(0xFFD80031);
      case 3:
        return Color(0xFFA65854);
      case 4:
        return Color(0xFFFF0017);
      case 5:
        return Color(0xFF690005);
      case 6:
        return Color(0xFFE50B5F);
      default:
        return Color(0xFF18707C);
    }
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

  List<TextSpan> _highlightOccurrences(String text, String query) {
    if (query.isEmpty) {
      return [
        TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.black87,
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
            color: Colors.black87,
            fontSize: ScreenUtils.x(3.5),
            fontWeight: FontWeight.w500,
          ),
        ));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: TextStyle(
            color: Colors.black87,
            fontSize: ScreenUtils.x(3.5),
            fontWeight: FontWeight.w500,
          ),
        ));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          color: Color(0xFF1976D2),
          fontSize: ScreenUtils.x(3.5),
          fontWeight: FontWeight.bold,
          backgroundColor: Color(0xFFE3F2FD),
        ),
      ));

      start = index + query.length;
    }

    return spans;
  }
}
