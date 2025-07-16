import 'package:get/get.dart';

import '../controllers/track_selection_controller.dart';

class TrackSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrackSelectionController>(
      () => TrackSelectionController(),
    );
  }
}
