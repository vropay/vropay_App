import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../signUp/views/sign_up_view.dart';

class OnBoardingController extends GetxController {
  // final PageController pageController = PageController();
  var currentPage = 0.obs;

  void goToNextPage() {
    if (currentPage.value < 3) {
      // pageController.nextPage(
      //   duration: const Duration(milliseconds: 300),
      //   curve: Curves.easeInOut,
      // );
    } else {
      goToSignup();
    }
  }

  void goToSignup() {
    Get.to(() => SignUpView());
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  @override
  void onClose() {
    // pageController.dispose();
    super.onClose();
  }
}
