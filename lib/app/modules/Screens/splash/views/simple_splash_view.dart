import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SimpleSplashView extends StatelessWidget {
  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF172B75), // Your app's primary color
      body: SafeArea(
        child: Column(
          children: [
            // Top section with logo
            Expanded(
              flex: 3,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with animation based on current step
                    Obx(() => TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 1000),
                          tween: Tween(
                              begin: 0.0,
                              end: controller.currentStep.value >= 1
                                  ? 1.0
                                  : 0.0),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Opacity(
                                opacity: value,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Image.asset(
                                      'assets/images/vropayLogo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )),

                    SizedBox(height: 30),

                    // App name with fade animation based on current step
                    Obx(() => TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 1000),
                          tween: Tween(
                              begin: 0.0,
                              end: controller.currentStep.value >= 2
                                  ? 1.0
                                  : 0.0),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Text(
                                'VRoPay',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            );
                          },
                        )),

                    SizedBox(height: 10),

                    // Tagline with slide animation based on current step
                    Obx(() => TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 1000),
                          tween: Tween(
                              begin: 50.0,
                              end: controller.currentStep.value >= 2
                                  ? 0.0
                                  : 50.0),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, value),
                              child: Opacity(
                                opacity: (50 - value) / 50,
                                child: Text(
                                  'Empowering Your Growth Journey',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w300,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        )),
                  ],
                ),
              ),
            ),

            // Bottom section with progress
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    // Progress bar - only show when step 3 is active
                    Obx(() => controller.currentStep.value >= 3
                        ? LinearProgressIndicator(
                            value: controller.progressValue.value,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 4,
                          )
                        : SizedBox(height: 4)),

                    SizedBox(height: 20),

                    // Loading text - only show when step 3 is active
                    Obx(() => controller.currentStep.value >= 3
                        ? Text(
                            'Loading... ${(controller.progressValue.value * 100).toInt()}%',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          )
                        : SizedBox(height: 20)),

                    SizedBox(height: 30),

                    // Skip button
                    TextButton(
                      onPressed: controller.skipSplash,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
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
}
