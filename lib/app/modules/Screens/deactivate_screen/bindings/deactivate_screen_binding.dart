import 'package:get/get.dart';

import '../controllers/deactivate_screen_controller.dart';

class DeactivateScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeactivateController>(
      () => DeactivateController(),
    );
  }
}
