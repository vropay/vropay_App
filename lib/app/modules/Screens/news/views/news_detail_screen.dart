import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:vropay_final/Components/back_icon.dart';
import 'package:vropay_final/Utilities/constants/KImages.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';

class NewsDetailScreen extends StatefulWidget {
  final Map<String, dynamic> news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showFixedActionButtons = false;
  final selectedFilter = 'All'.obs; // Add filter state
  final GlobalKey _moreButtonKey = GlobalKey(); // Add key for positioning
  bool _showBlur = false; // Add blur state

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show fixed action buttons when scrolled past title area
    if (_scrollController.offset > 300 && !_showFixedActionButtons) {
      setState(() {
        _showFixedActionButtons = true;
      });
    } else if (_scrollController.offset <= 300 && _showFixedActionButtons) {
      setState(() {
        _showFixedActionButtons = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Scrollable Content
            SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.only(
                top: _showFixedActionButtons
                    ? 80
                    : 0, // Add top padding when fixed buttons are shown
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with back button
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: BackIcon(),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail
                      Container(
                        width: double.infinity,
                        height: ScreenUtils.height * 0.25,
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F5F5),
                        ),
                        child: (widget.news['thumbnail'] != null &&
                                widget.news['thumbnail'].toString().isNotEmpty)
                            ? ClipRRect(
                                child: Image.asset(
                                  widget.news['thumbnail'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Color(0xFFE0E0E0),
                                      ),
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 60,
                                        color: Colors.grey[400],
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Color(0xFFE0E0E0),
                                ),
                                child: Icon(
                                  Icons.article,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                              ),
                      ),

                      SizedBox(height: 20),

                      // Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          widget.news['title'] ?? 'No Title',
                          style: TextStyle(
                            fontSize: ScreenUtils.x(6),
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF172B75),
                            height: 1.3,
                          ),
                        ),
                      ),

                      SizedBox(height: ScreenUtils.height * 0.01),

                      // Action Buttons (Initial Position)
                      if (!_showFixedActionButtons)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                          ),
                          child: Container(
                            width: double.infinity,
                            height: ScreenUtils.height * 0.08,
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40),
                                topRight: Radius.circular(40),
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                        onTap: () {},
                                        child:
                                            Image.asset(KImages.contentIcon)),
                                  ),
                                  SizedBox(width: ScreenUtils.width * 0.05),
                                  Expanded(
                                    child: GestureDetector(
                                        onTap: () {},
                                        child: Image.asset(KImages.nextIcon)),
                                  ),
                                  SizedBox(width: ScreenUtils.width * 0.05),
                                  Expanded(
                                    child: GestureDetector(
                                        onTap: () {},
                                        child: Image.asset(KImages.shareIcon)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      SizedBox(height: ScreenUtils.height * 0.01),

                      // Full Description with right-side icon column
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description text (expanded to take available space)
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Text(
                                _getFullDescription(widget.news['title'] ?? ''),
                                style: TextStyle(
                                  fontSize: ScreenUtils.x(4),
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF424242),
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ),
                          // Icon column on the right
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 20.0, top: 8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.favorite_border,
                                      color: Color(0xFFEF2D56)),
                                  onPressed: () {},
                                ),
                                SizedBox(height: 10),
                                IconButton(
                                  icon: Icon(Icons.bookmark_border,
                                      color: Color(0xFF6253DB)),
                                  onPressed: () {},
                                ),
                                SizedBox(height: 10),
                                IconButton(
                                  icon: Image.asset(KImages.colorVertIcon),
                                  onPressed: () {},
                                ),
                                SizedBox(height: 10),
                                IconButton(
                                  icon: Image.asset(KImages.penIcon),
                                  onPressed: () {},
                                ),
                                SizedBox(height: 10),
                                IconButton(
                                  key: _moreButtonKey,
                                  icon: Icon(Icons.more_horiz,
                                      color: Colors.orange),
                                  onPressed: () async {
                                    setState(() {
                                      _showBlur = true;
                                    });

                                    final RenderBox button = _moreButtonKey
                                        .currentContext!
                                        .findRenderObject() as RenderBox;
                                    final RenderBox overlay =
                                        Navigator.of(context)
                                            .overlay!
                                            .context
                                            .findRenderObject() as RenderBox;
                                    final RelativeRect position =
                                        RelativeRect.fromRect(
                                      Rect.fromPoints(
                                        button.localToGlobal(Offset.zero,
                                            ancestor: overlay),
                                        button.localToGlobal(
                                            button.size
                                                .bottomRight(Offset.zero),
                                            ancestor: overlay),
                                      ),
                                      Offset.zero & overlay.size,
                                    );

                                    // Custom menu with transparent and blur background
                                    await showGeneralDialog(
                                      context: context,
                                      barrierColor: Colors.transparent,
                                      barrierDismissible: true,
                                      barrierLabel: "Menu",
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
                                                filter: ImageFilter.blur(
                                                    sigmaX: 6, sigmaY: 6),
                                                child: Container(
                                                  color: Colors.transparent,
                                                ),
                                              ),
                                            ),
                                            // The menu
                                            Positioned(
                                              right: 60,
                                              top: position.top,
                                              child: Material(
                                                color: Colors.transparent,
                                                child: Container(
                                                  height:
                                                      ScreenUtils.height * 0.14,
                                                  width:
                                                      ScreenUtils.width * 0.3,
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      _buildFilterChip(
                                                          context,
                                                          "beginner",
                                                          selectedFilter
                                                                  .value ==
                                                              "beginner", () {
                                                        selectedFilter.value =
                                                            "beginner";
                                                        Navigator.of(context)
                                                            .pop();
                                                      }),
                                                      _buildFilterChip(
                                                          context,
                                                          "moderate",
                                                          selectedFilter
                                                                  .value ==
                                                              "moderate", () {
                                                        selectedFilter.value =
                                                            "moderate";
                                                        Navigator.of(context)
                                                            .pop();
                                                      }),
                                                      _buildFilterChip(
                                                          context,
                                                          "advance",
                                                          selectedFilter
                                                                  .value ==
                                                              "advance", () {
                                                        selectedFilter.value =
                                                            "advance";
                                                        Navigator.of(context)
                                                            .pop();
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

                                    setState(() {
                                      _showBlur = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 30),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      "Congress leaders urge the Prime Minister to  restore J&K statehood, citing constitutional rights and promises  made by the Government.",
                      style: TextStyle(
                          fontSize: ScreenUtils.x(3),
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF6253DB)),
                    ),
                  )
                ],
              ),
            ),

            // Dark Background Overlay
            if (_showBlur)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),

            // Fixed Action Buttons (appears when scrolling)
            if (_showFixedActionButtons)
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: Container(
                  height: ScreenUtils.height * 0.08,
                  margin:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: BackIcon(),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                              onTap: () {},
                              child:
                                  Image.asset(KImages.contentIcon, height: 30)),
                          SizedBox(width: 20),
                          GestureDetector(
                              onTap: () {},
                              child: Image.asset(KImages.nextIcon, height: 30)),
                          SizedBox(width: 20),
                          GestureDetector(
                              onTap: () {},
                              child:
                                  Image.asset(KImages.shareIcon, height: 30)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getFullDescription(String title) {
    // Generate a detailed description based on the title
    switch (title) {
      case 'Trump greenlights "massive" arms deal for Ukraine':
        return 'Former President Donald Trump has approved a significant arms deal for Ukraine, marking a major development in the ongoing conflict. The deal includes advanced military equipment and weapons systems that will bolster Ukraine\'s defense capabilities. This decision comes amid escalating tensions in the region and represents a substantial commitment to supporting Ukraine\'s sovereignty and territorial integrity. The arms package is expected to include missile systems, armored vehicles, and other critical military supplies that will enhance Ukraine\'s ability to defend itself against external threats.';

      case 'Tesla launches first Mumbai showroom (BKC)':
        return 'Tesla has officially opened its first showroom in Mumbai\'s Bandra Kurla Complex (BKC), marking the electric vehicle giant\'s entry into the Indian market. The state-of-the-art showroom showcases Tesla\'s latest models including the Model 3, Model Y, and Model S. This strategic move represents Tesla\'s commitment to expanding its global presence and tapping into India\'s growing electric vehicle market. The showroom features interactive displays, charging stations, and expert staff to help customers understand Tesla\'s innovative technology and sustainable transportation solutions.';

      case 'SBI cuts lending rates':
        return 'The State Bank of India (SBI) has announced a reduction in its lending rates across various loan products, providing relief to borrowers. This move is expected to boost credit growth and stimulate economic activity in the country. The rate cut applies to home loans, personal loans, and business loans, making borrowing more affordable for consumers and businesses alike. This decision reflects the bank\'s commitment to supporting economic recovery and making financial services more accessible to a broader segment of the population.';

      case 'India\'s inflation hits 6-year low':
        return 'India\'s inflation rate has reached its lowest level in six years, indicating positive economic indicators and improved price stability. This development suggests that the Reserve Bank of India\'s monetary policies have been effective in controlling price rises. The lower inflation rate is expected to provide relief to consumers and create a more favorable environment for economic growth. This milestone reflects the country\'s improving economic fundamentals and could lead to more favorable monetary policy decisions in the future.';

      case 'Astronaut splashdown success':
        return 'A team of astronauts has successfully completed their mission with a safe splashdown landing, marking another milestone in space exploration. The crew returned to Earth after completing various scientific experiments and research activities aboard the International Space Station. The successful landing demonstrates the reliability of modern space technology and the expertise of mission control teams. This achievement contributes valuable data to ongoing space research and paves the way for future missions.';

      case 'Congress demands full J&K statehood':
        return 'Senior Congress leaders Mallikarjun Kharge and Rahul Gandhi on Wednesday (July 16, 2025) wrote a joint letter to Prime Minister Narendra Modi pressing for restoration of Statehood to Jammu and Kashmir.\n\n"For the past five years, the people of J&K have consistently called for the restoration of full statehood. This demand is both legitimate and firmly grounded in their constitutional and democratic rights," the joint letter by the Leaders of the Opposition in the Lok Sabha and Rajya Sabha read. The demand came days ahead of the Monsoon Session of the Parliament.\n\nWhile there were instances of Union Territories being granted Statehood in the past, "the case of J&K is without precedent in Independent India", the letter pointed out.\n\nThe letter also referred to Mr. Modi\'s promises made on May 19 and September 19, 2024 on the issue. "You reaffirmed: \'We have said in Parliament that we will restore the region\'s statehood\'," it said.\n\nThe letter also referred to the Supreme Court\'s assertion that Statehood should be restored to J&K "at the earliest and as soon as possible".\n\nMeanwhile, the Group of Concerned Citizens (GCC) Jammu & Kashmir, a civil society group comprising senior retired officials, said many recent developments in J&K "yet again bring forth the imperative of restoring statehood without further delay". It said restoring Statehood was "essential for larger national interest".\n\nThis would be a significant step towards addressing the cultural, developmental, and political aspirations of the people of Ladakh, while safeguarding their rights, land, and identity," the letter added.';

      case 'China & EU move to normalize diplomatic ties':
        return 'China and the European Union have taken significant steps toward normalizing their diplomatic relations, marking a potential shift in international geopolitics. This development could lead to increased trade cooperation, cultural exchanges, and joint initiatives on global challenges. The normalization process involves addressing various bilateral issues and establishing frameworks for future collaboration. This diplomatic breakthrough has implications for global trade, climate change initiatives, and international security cooperation.';

      default:
        return 'This is a comprehensive news article covering important developments and their implications. The story provides detailed analysis and context to help readers understand the significance of these events. Stay informed about the latest developments and their impact on various sectors and communities.';
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
}

class CustomShape extends StatelessWidget {
  final Color color;
  final double width;
  final double height;
  final double cornerRadius;

  const CustomShape({
    super.key,
    this.color = const Color(0xFF00B8F0),
    this.width = 120,
    this.height = 45,
    this.cornerRadius = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: CustomPaint(
        painter: ShapePainter(
          color: color,
          cornerRadius: cornerRadius,
        ),
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final Color color;
  final double cornerRadius;

  ShapePainter({
    required this.color,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    double width = size.width;
    double height = size.height;

    // 1. TOP-LEFT CORNER (Circular)
    path.moveTo(cornerRadius, 0); // Start point

    // 2. TOP EDGE (to top-right)
    path.lineTo(width - 25, 0); // Top edge line

    // 3. TOP-RIGHT CORNER (Sharp - no rounding)
    path.lineTo(width - 20, 0); // Sharp corner
    path.lineTo(width - 20, 5); // Sharp corner

    // 4. RIGHT EDGE (to arrow area)
    path.lineTo(width - 20, height - 15);
    path.quadraticBezierTo(width - 20, height - 10, width - 25, height - 10);

    // 6. BOTTOM EDGE (to bottom-left)
    path.lineTo(cornerRadius, height - 10); // Bottom edge line

    // 7. BOTTOM-LEFT CORNER (Circular)
    path.quadraticBezierTo(0, height - 10, 0, height - cornerRadius - 10);

    // 8. LEFT EDGE (to top-left)
    path.lineTo(0, cornerRadius); // Left edge line

    // 9. TOP-LEFT CORNER (Circular - completes the shape)
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
