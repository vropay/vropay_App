import 'package:get/get.dart';

import '../controllers/signout_screen_controller.dart';

class SignoutScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignoutScreenController>(
      () => SignoutScreenController(),
    );
  }
}
