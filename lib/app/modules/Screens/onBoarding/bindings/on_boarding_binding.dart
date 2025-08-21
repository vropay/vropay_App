import 'package:get/get.dart';
import '../controllers/on_boarding_controller.dart';
import '../../OtpScreen/controllers/otp_screen_controller.dart';

class OnBoardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnBoardingController>(() => OnBoardingController());
    Get.lazyPut<OTPController>(() => OTPController());
  }
}
