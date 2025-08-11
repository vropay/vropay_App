import 'package:get/get.dart';
import '../controllers/greeting_splash_controller.dart';

class GreetingSplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GreetingSplashController>(() => GreetingSplashController());
  }
}
