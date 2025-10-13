import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

import '../widgets/deactivate_confirmation.dart';

class DeactivateController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  RxBool confirmErase = false.obs;
  RxBool isLoading = false.obs;

  void toggleCheckbox(bool? value) {
    confirmErase.value = value ?? false;
  }

  Future<void> onDeactivate() async {
    if (!confirmErase.value) {
      Get.snackbar("Confirmation Required", "Please check the box to continue",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;

      // Call the deactivate API
      final response = await _authService.deactivateUserAccount();

      if (response.success) {
        // Show success message with details
        final message =
            response.data?['message'] ?? 'Account deactivated successfully';
        final deletedData = response.data?['data'] as Map<String, dynamic>?;

        if (deletedData != null) {
          print('✅ Account deactivation summary:');
          print('  - Messages deleted: ${deletedData['messagesDeleted']}');
          print(
              '  - Interests removed from: ${deletedData['interestsRemovedFrom']}');
          print('  - User deleted: ${deletedData['userDeleted']}');
        }
        // Clear user data and tokens
        await _authService.logout();

        // Show goodbye overlay
        Get.dialog(
          const GoodbyeOverlayWidget(),
          barrierDismissible: false,
        );

        // Navigate to onboarding after delay
        Timer(const Duration(seconds: 3), () {
          Get.offAllNamed(Routes.ON_BOARDING);
        });
      } else {
        Get.snackbar(
          "Error",
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      String errorMessage = "Failed to deactivate account";

      if (e.toString().contains('User not authenticated')) {
        errorMessage = "Your session has expired. Please sign in again.";
      } else if (e.toString().contains('User not found')) {
        errorMessage = "Account may have already been deactivated.";
      } else if (e.toString().contains('Server error')) {
        errorMessage = "Server error occurred. Please try again later.";
      } else if (e.toString().contains('endpoint not found')) {
        errorMessage =
            "Deactivate feature is not available yet. Please contact support.";
      } else {
        errorMessage = "Failed to deactivate account: ${e.toString()}";
      }

      Get.snackbar(
        "Error",
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5), // Show longer for important errors
      );
    } finally {
      isLoading.value = false;
    }
  }
}
