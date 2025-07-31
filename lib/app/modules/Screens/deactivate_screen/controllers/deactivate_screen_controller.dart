import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets /deactivate_confirmation.dart';

class DeactivateController extends GetxController {
  RxBool confirmErase = false.obs;

  void toggleCheckbox(bool? value) {
    confirmErase.value = value ?? false;
  }

  void onDeactivate() {
    if (!confirmErase.value) {
      Get.snackbar("Confirmation Required", "Please check the box to continue",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.white);
      return;
    }

    Get.dialog(
      const GoodbyeOverlayWidget(),
      barrierDismissible: false, // Don't allow closing by tapping outside
    );
  }
}