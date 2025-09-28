import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/auth_service.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class GreetingSplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  var isAuthenticated = false.obs;
  var userName = 'User'.obs;

  @override
  void onInit() {
    super.onInit();
    _checkUserStatus();
    _initializedApp();
  }

  void _checkUserStatus() {
    isAuthenticated.value = _authService.isLoggedIn.value;
    if (isAuthenticated.value) {
      final user = _authService.currentUser.value;
      userName.value = user?.firstName ?? 'User';
    }
  }

  Future<void> _initializedApp() async {
    await Future.delayed(Duration(seconds: 2));

    // Check authentication status
    if (isAuthenticated.value) {
      Get.offAllNamed(Routes.DASHBOARD);
    } else {
      // First time user - show first time splash
      Get.offAllNamed(Routes.ON_BOARDING);
    }
  }
}
