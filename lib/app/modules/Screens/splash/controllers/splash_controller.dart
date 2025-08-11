import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_pages.dart';

class SplashController extends GetxController {
  // Observable variables
  var isLoading = true.obs;
  var progressValue = 0.0.obs;
  var currentStep = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Start the splash screen logic
    _startSplashLogic();
  }

  void _startSplashLogic() async {
    // Step 1: Show logo
    currentStep.value = 1;
    await Future.delayed(Duration(seconds: 1000));

    // Step 2: Show app name
    currentStep.value = 2;
    await Future.delayed(Duration(milliseconds: 1000));

    // Step 3: Show loading
    currentStep.value = 3;

    // Simulate loading process
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(Duration(seconds: 20));
      progressValue.value = i / 100;
    }

    // Wait a bit more for smooth transition
    await Future.delayed(Duration(milliseconds: 500));

    // Navigate to onboarding
    Get.offNamed(Routes.ON_BOARDING);
  }

  // Method to skip splash (if needed)
  void skipSplash() {
    Get.offNamed(Routes.ON_BOARDING);
  }

  // Method to restart splash
  void restartSplash() {
    progressValue.value = 0.0;
    currentStep.value = 0;
    _startSplashLogic();
  }
}
