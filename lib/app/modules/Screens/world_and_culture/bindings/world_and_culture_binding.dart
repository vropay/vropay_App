import 'package:get/get.dart';
import 'package:vropay_final/app/modules/Screens/world_and_culture/controllers/world_and_culture_controller.dart';

class WorldAndCultureBinding  extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<WorldAndCultureController>(
      () => WorldAndCultureController(),
    );
  }
}