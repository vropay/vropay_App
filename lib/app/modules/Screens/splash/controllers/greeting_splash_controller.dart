import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class GreetingSplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var isAuthenticated = false.obs;
  var userName = 'User'.obs;

  // Regular splash animation variables
  var isLoading = true.obs;
  var progressValue = 0.0.obs;
  var currentStep = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _checkUserStatus();
    _initializeSplash();
  }

  void _checkUserStatus() {
    isAuthenticated.value = _authService.isLoggedIn.value;
    if (isAuthenticated.value) {
      final user = _authService.currentUser.value;
      userName.value = user?.firstName ?? 'User';
    }
  }

  void _initializeSplash() async {
    if (isAuthenticated.value) {
      // User is logged in - show greeting splash
      await _showGreetingSplash();
    } else {
      // User is not logged in - show regular splash
      await _startSplashLogic();
    }
  }

  // Show greeting splash for authenticated users
  Future<void> _showGreetingSplash() async {
    await Future.delayed(Duration(seconds: 2));

    // Navigate to dashboard for authenticated users
    Get.offAllNamed(Routes.LEARN_SCREEN);
  }

  // REgular splash logic for non-authenticated users
  Future<void> _startSplashLogic() async {
    // Step 1: Show logo
    currentStep.value = 1;
    await Future.delayed(Duration(milliseconds: 1000));

    // Step 2: Show app name
    currentStep.value = 2;
    await Future.delayed(Duration(milliseconds: 1000));

    // Step 3: Show loading
    currentStep.value = 3;

    // Simulate loading process
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(Duration(milliseconds: 20));
      progressValue.value = i / 100;
    }

    // Wait a bit more for smooth transition
    await Future.delayed(Duration(milliseconds: 20));

    // Navigate to onboarding for non-authenticated users
    Get.offAllNamed(Routes.ON_BOARDING);
  }

  // Method to skip splash
  void skipSplash() {
    if (isAuthenticated.value) {
      Get.offAllNamed(Routes.LEARN_SCREEN);
    } else {
      Get.offAllNamed(Routes.ON_BOARDING);
    }
  }

  // Method to restart splash
  void restartSplash() {
    progressValue.value = 0.0;
    currentStep.value = 0;
    if (!isAuthenticated.value) {
      _startSplashLogic();
    }
  }
}
