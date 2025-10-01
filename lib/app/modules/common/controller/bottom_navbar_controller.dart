// controllers/bottom_nav_controller.dart
import 'package:get/get.dart';
import 'package:vropay_final/app/routes/app_pages.dart';

class BottomNavController extends GetxController {
  var currentIndex = 2.obs; // Default to "learn"
  var selectedSubOption = 'learn'.obs;

  @override
  void onInit() {
    super.onInit();
    // Set initial route
    _updateIndexFromRoute(Get.currentRoute);
  }

  void updateRoute(String route) {
    _updateIndexFromRoute(route);
  }

  void _updateIndexFromRoute(String route) {
    print('🔍 BottomNav - Current route: $route');

    // Check for exact route matches first
    if (route == Routes.DASHBOARD || route == '/dashboard') {
      currentIndex.value = 0;
      selectedSubOption.value = 'home';
    } else if (route == Routes.PROFILE || route == '/profile') {
      currentIndex.value = 1;
      selectedSubOption.value = 'primary';
    } else if (route == Routes.LEARN_SCREEN || route == '/learn-screen') {
      currentIndex.value = 2;
      selectedSubOption.value = 'learn';
    } else if (route == '/shop') {
      currentIndex.value = 3;
      selectedSubOption.value = 'shop';
    } else if (route == Routes.NOTIFICATIONS || route == '/notifications') {
      currentIndex.value = 4;
      selectedSubOption.value = 'notifications';
    } else {
      // For nested routes, try to detect parent route
      if (route.contains('/dashboard')) {
        currentIndex.value = 0;
        selectedSubOption.value = 'home';
      } else if (route.contains('/profile')) {
        currentIndex.value = 1;
        selectedSubOption.value = 'primary';
      } else if (route.contains('/learn')) {
        currentIndex.value = 2;
        selectedSubOption.value = 'learn';
      } else if (route.contains('/shop')) {
        currentIndex.value = 3;
        selectedSubOption.value = 'shop';
      } else if (route.contains('/notifications')) {
        currentIndex.value = 4;
        selectedSubOption.value = 'notifications';
      }
    }

    print('🔍 BottomNav - Updated index to: ${currentIndex.value}');
  }

  void updateIndex(int index) {
    currentIndex.value = index;

    // Handle default sub-option for multi-option tabs
    if (index == 1) {
      selectedSubOption.value = 'primary';
    } else if (index == 2) selectedSubOption.value = 'learn';
  }

  void setSubOption(String option) {
    selectedSubOption.value = option;
  }
}
