import 'package:get/get.dart';
import 'package:vropay_final/app/modules/Screens/news/controllers/news_controller.dart';

class NewsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewsController>(
      () => NewsController(),
    );
  }
}
