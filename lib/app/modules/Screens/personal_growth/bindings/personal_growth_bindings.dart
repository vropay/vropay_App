
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:vropay_final/app/modules/Screens/personal_growth/controllers/personal_growth_controller.dart';

class PersonalGrowthBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PersonalGrowthController>(() => PersonalGrowthController());
  }
}
