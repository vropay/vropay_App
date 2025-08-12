import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
      body: SafeArea(
        child: Padding(
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
                      child: Text(
                        "Hey Vikas",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
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
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    TextSpan(
                      text:
                          "we're dropping \nnew features real soon. \nAppreciate the love. Big things loading",
                      style: TextStyle(fontWeight: FontWeight.w300),
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

              SizedBox(height: 20),

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
                  // Logo
                  Image.asset(
                    KImages.vropayLogo,
                    height: ScreenUtils.height * 0.05,
                    width: ScreenUtils.width * 0.3,
                  ),

                  SizedBox(height: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
