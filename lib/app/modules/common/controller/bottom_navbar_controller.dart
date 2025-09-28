// controllers/bottom_nav_controller.dart
import 'package:get/get.dart';

class BottomNavController extends GetxController {
  var currentIndex = 2.obs; // Default to "learn"
  var selectedSubOption = 'learn'.obs;

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
