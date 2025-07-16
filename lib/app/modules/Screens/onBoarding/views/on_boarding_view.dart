import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../../Components /constant_buttons.dart';
import '../../../../../Utilities /constants /Colors.dart';
import '../../../../../Utilities /constants /KImages.dart';
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Image.asset(
              KImages.onBoardingScreen,
              height: 400,
              width: 400,
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
                      children: [
                        const TextSpan(text: "Smart tools\n", style: TextStyle(
                            fontWeight: FontWeight.bold
                        )),
                        const TextSpan(text: "Real-time insights\n ",style: TextStyle(
                            fontWeight: FontWeight.bold
                        )),
                        TextSpan(
                          text: "&\n",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF0066FF),
                          ),
                        ),
                        const TextSpan(text: " Limitless possibilities", style: TextStyle(
                          fontWeight: FontWeight.bold
                        )),
                      ],
                    ),
                  ),
                  const Text(
                    "—ready to level up your skills?",
                    style: TextStyle(
                      fontSize: 18,
                      color: KConstColors.onBoardingSubHeading,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FaqHelpText(),
                  const SizedBox(height: 40),
                  // Progress Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildProgressDot(true),
                      _buildProgressDot(false),
                      _buildProgressDot(false),
                      _buildProgressDot(false)
                    ],
                  ),
                ],
              ),
            ),
            Obx(
                  () => CommonButton(
                onPressed: _controller.goToSignup,
                child: _controller.currentPage.value == 0
                    ? Row(
                  children: [
                    const Icon(Icons.arrow_forward_ios, color: KConstColors.colorPrimary, size: 20),
                    Transform.translate(
                      offset: const Offset(-6, 0),
                      child: const Icon(Icons.arrow_forward_ios, color: KConstColors.colorPrimary, size: 20),
                    ),
                    Transform.translate(
                      offset: const Offset(-12, 0),
                      child: const Icon(Icons.arrow_forward_ios, color: KConstColors.colorPrimary, size: 20),
                    ),

                    const SizedBox(width: 40),
                    const Text(
                      "Let’s Sign Up",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: KConstColors.colorPrimary,
                      ),
                    ),
                  ],
                )
                    : Text(
                  "Next",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),


            const SizedBox(height: 20),
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
                        // Get.to(() => Sign());
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

  Widget _buildProgressDot(bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      width: isActive ? 9 : 30,
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? Color(0xFF172B75) : Color(0xFFD0D0D0),
        borderRadius: BorderRadius.circular(19),
      ),
    );
  }
}

