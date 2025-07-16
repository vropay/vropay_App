import 'package:get/get.dart';

import '../controllers/knowledge_center_screen_controller.dart';

class KnowledgeCenterScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KnowledgeCenterScreenController>(
      () => KnowledgeCenterScreenController(),
    );
  }
}
