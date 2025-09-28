import 'package:get/get.dart';

import '../controllers/learn_screen_controller.dart';

class LearnScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LearnScreenController>(
      () => LearnScreenController(),
    );
  }
}
