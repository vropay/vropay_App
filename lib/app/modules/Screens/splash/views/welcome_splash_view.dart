import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class WelcomeSplashView extends StatelessWidget {
  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Top section with greeting
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Greeting text with gradient
                    Obx(() => TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 1500),
                          tween: Tween(
                              begin: 0.0,
                              end: controller.currentStep.value >= 1
                                  ? 1.0
                                  : 0.0),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Hey ',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              Color(0xFF0066FF), // Blue color
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Vikas',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w600,
                                          foreground: Paint()
                                            ..shader = LinearGradient(
                                              colors: [
                                                Color(0xFF8B5CF6), // Purple
                                                Color(0xFFEC4899), // Pink
                                              ],
                                            ).createShader(
                                                Rect.fromLTWH(0, 0, 100, 40)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )),

                    SizedBox(height: 40),

                    // Beta message with fade animation
                    Obx(() => TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 2000),
                          tween: Tween(
                              begin: 0.0,
                              end: controller.currentStep.value >= 2
                                  ? 1.0
                                  : 0.0),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 30 * (1 - value)),
                                child: Column(
                                  children: [
                                    Text(
                                      "You're on the beta wave.. we're dropping\nnew features real soon.",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFF83A5FA), // Light blue
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Appreciate the love. Big things loading",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color:
                                                Color(0xFF83A5FA), // Light blue
                                            height: 1.4,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.favorite,
                                          color:
                                              Color(0xFF83A5FA), // Light blue
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
                  ],
                ),
              ),

              // Bottom section with branding
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // "from" text
                    Obx(() => TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 2500),
                          tween: Tween(
                              begin: 0.0,
                              end: controller.currentStep.value >= 3
                                  ? 1.0
                                  : 0.0),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Text(
                                  'from',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF83A5FA), // Light blue
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          },
                        )),

                    SizedBox(height: 16),

                    // vropay logo with scale animation
                    Obx(() => TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 3000),
                          tween: Tween(
                              begin: 0.0,
                              end: controller.currentStep.value >= 3
                                  ? 1.0
                                  : 0.0),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Opacity(
                                opacity: value,
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'vro',
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF172B75), // Dark blue
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'pay',
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color(0xFF83A5FA), // Light blue
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )),

                    SizedBox(height: 40),

                    // Progress indicator
                    Obx(() => controller.currentStep.value >= 3
                        ? LinearProgressIndicator(
                            value: controller.progressValue.value,
                            backgroundColor: Color(0xFFE5E7EB),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF0066FF)),
                            minHeight: 3,
                          )
                        : SizedBox(height: 3)),

                    SizedBox(height: 20),

                    // Skip button
                    TextButton(
                      onPressed: controller.skipSplash,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Color(0xFF83A5FA),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
