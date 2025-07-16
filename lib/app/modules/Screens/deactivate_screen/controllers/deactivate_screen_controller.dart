import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      AlertDialog(
        title: const Text("Confirm Deactivation"),
        content: const Text("This action is permanent. Do you want to proceed?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              // Perform deactivation logic here
              Get.offAllNamed('/login'); // Example navigation
            },
            child: const Text("Yes, Deactivate", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}