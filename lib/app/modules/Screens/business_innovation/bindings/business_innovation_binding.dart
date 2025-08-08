import 'package:get/get.dart';
import 'package:vropay_final/app/modules/Screens/business_innovation/controllers/business_innovation_controller.dart';

class BusinessInnovationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BusinessInnovationController>(
      () => BusinessInnovationController(),
    );
  }
}
