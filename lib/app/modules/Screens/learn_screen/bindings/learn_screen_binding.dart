import 'package:get/get.dart';
import 'package:vropay_final/app/modules/Screens/learn_screen/views/learn_screen.dart';

import '../controllers/learn_screen_controller.dart';

class LearnScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LearnScreenController>(
      () => LearnScreenController(),
    );
  }
}
