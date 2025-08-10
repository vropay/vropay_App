import 'package:get/get.dart';
import 'package:vropay_final/app/modules/Screens/world_and_culture_community/controllers/world_and_culture_community_controller.dart';

class WorldAndCultureCommunityBinding  extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<WorldAndCultureCommunityController>(
      () => WorldAndCultureCommunityController(),
    );
  }
}