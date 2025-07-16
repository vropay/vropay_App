import 'package:get/get.dart';

import '../../OtpScreen/controllers/otp_screen_controller.dart';


class OnBoardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OTPController>(() => OTPController());
  }
}
