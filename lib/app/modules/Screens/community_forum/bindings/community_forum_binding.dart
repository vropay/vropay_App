import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/community_service.dart';

import '../controllers/community_forum_controller.dart';

class CommunityForumBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure CommunityService is available
    if (!Get.isRegistered<CommunityService>()) {
      Get.put(CommunityService(), permanent: true);
    }
    
    Get.lazyPut<CommunityForumController>(
      () => CommunityForumController(),
    );
  }
}
