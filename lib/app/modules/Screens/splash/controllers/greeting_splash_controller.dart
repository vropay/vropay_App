import 'package:get/get.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class GreetingSplashController extends GetxController {
  // Configurable timing - you can easily change this value
  final int greetingDurationSeconds =
      1000000; // Change this to increase/decrease timing

  @override
  void onInit() {
    super.onInit();
    // Start the timer when the controller initializes
    _startGreetingTimer();
  }

  void _startGreetingTimer() async {
    // Wait for the specified duration
    await Future.delayed(Duration(seconds: greetingDurationSeconds));

    // Navigate to the next screen (you can change this destination)
    Get.offNamed(Routes.ON_BOARDING);
  }

  // Method to manually skip the greeting (if needed)
  void skipGreeting() {
    Get.offNamed(Routes.ON_BOARDING);
  }

  // Method to restart the greeting timer
  void restartGreeting() {
    _startGreetingTimer();
  }
}
