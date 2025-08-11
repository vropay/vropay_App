import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import '../../../../../Components/constant_buttons.dart';
import '../../../../../Utilities/constants/Colors.dart';
import '../../../../../Utilities/constants/KImages.dart';
import '../controllers/on_boarding_controller.dart';
import '../widgets/faq_help.dart';

class OnBoardingView extends StatefulWidget {
  @override
  _OnBoardingViewState createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  final OnBoardingController _controller = Get.put(OnBoardingController());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtils.setContext(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _controller.goToSignup, // This now goes to home screen
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: KConstColors.onBoardingSubHeading,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller.pageController,
                onPageChanged: _controller.onPageChanged,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildOnboardingPage(
                    image: KImages.onBoardingScreen,
                    title:
                        "Smart tools\nReal-time insights\n&\nLimitless possibilities",
                    subtitle: "—ready to level up your skills?",
                    showFaq: true,
                  ),
                  _buildOnboardingPage(
                    image: KImages.onBoardingScreen,
                    title: "Connect with\nLike-minded\nProfessionals",
                    subtitle: "—build your network and grow together?",
                    showFaq: false,
                  ),
                  _buildOnboardingPage(
                    image: KImages.onBoardingScreen,
                    title: "Learn from\nIndustry Experts\n& Mentors",
                    subtitle: "—gain insights from the best in the field?",
                    showFaq: false,
                  ),
                  _buildOnboardingPage(
                    image: KImages.onBoardingScreen,
                    title: "Track Your\nProgress & Achievements",
                    subtitle: "—measure your growth and celebrate success?",
                    showFaq: false,
                  ),
                ],
              ),
            ),
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(() {
                    // Get dynamic sizes based on current page
                    double dotHeight =
                        _getDotHeight(_controller.currentPage.value);
                    double dotWidth =
                        _getDotWidth(_controller.currentPage.value);

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        bool isSelected =
                            index == _controller.currentPage.value;
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 4.0),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: isSelected ? 9 : 30.0,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xFF172B75)
                                  : Color(0xFFD0D0D0),
                              borderRadius: BorderRadius.circular(
                                isSelected
                                    ? dotHeight / 2
                                    : 2.0, // Circle for selected, rounded rectangle for unselected
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Obx(
                () => CommonButton(
                  onPressed: _controller.currentPage.value == 3
                      ? _controller.goToSignup
                      : _controller.goToNextPage,
                  child: _controller.currentPage.value == 3
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_forward_ios,
                                color: KConstColors.colorPrimary, size: 20),
                            Transform.translate(
                              offset: const Offset(-6, 0),
                              child: const Icon(Icons.arrow_forward_ios,
                                  color: KConstColors.colorPrimary, size: 20),
                            ),
                            Transform.translate(
                              offset: const Offset(-12, 0),
                              child: const Icon(Icons.arrow_forward_ios,
                                  color: KConstColors.colorPrimary, size: 20),
                            ),
                            SizedBox(width: ScreenUtils.width * 0.08),
                            const Text(
                              "Let's Sign Up",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: KConstColors.colorPrimary,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Next",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.arrow_forward,
                                color: Colors.white, size: 20),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Sign In Link
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "have an account? ",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: KConstColors.onBoardingSubTitle,
                    ),
                  ),
                  TextSpan(
                    text: "SIGN IN",
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      color: KConstColors.onBoardingSubHeading,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        _controller.goToSignIn();
                      },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String image,
    required String title,
    required String subtitle,
    required bool showFaq,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: Image.asset(
            image,
            fit: BoxFit.contain,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: KConstColors.onBoardingText,
                  ),
                  children: title.split('\n').map((line) {
                    if (line == '&') {
                      return TextSpan(
                        text: "$line\n",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF0066FF),
                        ),
                      );
                    }
                    return TextSpan(
                      text: "$line\n",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 18,
                  color: KConstColors.onBoardingSubHeading,
                ),
              ),
              if (showFaq) ...[
                const SizedBox(height: 20),
                FaqHelpText(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Helper methods for dynamic dot sizing
  double _getDotHeight(int currentPage) {
    switch (currentPage) {
      case 0:
        return 8.0; // First page - larger dots
      case 1:
        return 6.0; // Second page - medium dots
      case 2:
        return 5.0; // Third page - smaller dots
      case 3:
        return 7.0; // Fourth page - medium-large dots
      default:
        return 4.0; // Default size
    }
  }

  double _getDotWidth(int currentPage) {
    switch (currentPage) {
      case 0:
        return 40.0; // First page - wider dots
      case 1:
        return 35.0; // Second page - medium width
      case 2:
        return 30.0; // Third page - narrower dots
      case 3:
        return 45.0; // Fourth page - widest dots
      default:
        return 30.0; // Default width
    }
  }
}
