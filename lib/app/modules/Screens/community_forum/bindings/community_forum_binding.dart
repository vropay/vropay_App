import 'package:get/get.dart';

import '../controllers/community_forum_controller.dart';

class CommunityForumBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunityForumController>(
      () => CommunityForumController(),
    );
  }
}
