import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:vropay_final/app/modules/Screens/consent_screen/controllers/consent_controller.dart';

class ConsentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConsentController>(
      () => ConsentController(),
    );
  }
}
