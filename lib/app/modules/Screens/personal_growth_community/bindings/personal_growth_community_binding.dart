import 'package:get/get.dart';
import 'package:vropay_final/app/modules/Screens/personal_growth_community/controllers/personal_growth_community_controllers.dart';

class PersonalGrowthCommunityBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<PersonalGrowthCommunityController>(
      () => PersonalGrowthCommunityController(),
    );
  }
}