import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vropay_final/Utilities/constants/Colors.dart';
import 'package:vropay_final/Utilities/constants/KImages.dart';
import 'package:vropay_final/Utilities/screen_utils.dart';
import '../controllers/greeting_splash_controller.dart';

class GreetingSplashView extends StatelessWidget {
  const GreetingSplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    final controller = Get.put(GreetingSplashController());
    // Set the context for ScreenUtils
    ScreenUtils.setContext(context);

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(child: Obx(() {
          // Show greeting splash
          if (controller.isAuthenticated.value) {
            return _buildGreetingSplash(controller);
          } else {
            return _buildRegularSplash(controller);
          }
        })));
  }

  Widget _buildGreetingSplash(GreetingSplashController controller) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Greeting text with gradient
          SizedBox(height: ScreenUtils.height * 0.3),
          Column(
            children: [
              Center(
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [Color(0xFF0066FF), Color(0xFFEF2D56)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Obx(
                    () => Text(
                      "Hey ${controller.userName.value}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: ScreenUtils.height * 0.015),

          // Description text
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF0066FF),
                fontWeight: FontWeight.w200,
              ),
              children: [
                TextSpan(
                    text: "You're on the beta wave.. ",
                    style: TextStyle(fontWeight: FontWeight.w300)),
                TextSpan(
                  text:
                      "we're dropping \nnew features real soon. \nAppreciate the love. Big things loading",
                  style: TextStyle(fontWeight: FontWeight.w200),
                ),
                TextSpan(
                  text: "💙",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: ScreenUtils.height * 0.02),

          // "from" text with custom font
          Column(
            children: [
              Text(
                "from",
                style: TextStyle(
                  fontFamily: GoogleFonts.borel().fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF0066FF),
                ),
              ),
              SizedBox(height: ScreenUtils.height * 0.012),
              // Logo
              Image.asset(
                KImages.vropayLogo,
                height: ScreenUtils.height * 0.05,
                width: ScreenUtils.width * 0.3,
              ),

              SizedBox(height: ScreenUtils.height * 0.036),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegularSplash(GreetingSplashController controller) {
    return Scaffold(
      backgroundColor: KConstColors.colorPrimary,
      body: SafeArea(
        child: Center(
          child: Container(
            width: 180,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Image.asset(
                'assets/images/vropayLogo.png',
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
