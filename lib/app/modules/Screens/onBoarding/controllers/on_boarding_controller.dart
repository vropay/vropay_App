import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/views/home_view.dart';

class OnBoardingController extends GetxController {
  var currentPage = 0.obs;
  final PageController pageController = PageController();

  void goToNextPage() {
    if (currentPage.value < 3) {
      currentPage.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      goToSignup();
    }
  }

  void goToSignup() {
    Get.offAll(
        () => HomeView()); // Navigate to home screen instead of sign-up
  }

  void goToSignIn() {
    // Navigate to home screen for now since sign-in view doesn't exist yet
    Get.offAll(() => HomeView());
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
