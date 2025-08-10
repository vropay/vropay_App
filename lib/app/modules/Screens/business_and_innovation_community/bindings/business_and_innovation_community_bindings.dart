import 'package:get/get.dart';
import 'package:vropay_final/app/modules/Screens/business_and_innovation_community/controllers/business_and_innovation_community_controller.dart';

class BusinessInnovationCommunityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BusinessInnovationCommunityController>(
      () => BusinessInnovationCommunityController(),
    );
  }
}
