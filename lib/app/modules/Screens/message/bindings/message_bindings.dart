import 'package:get/get.dart';
import 'package:vropay_final/app/core/services/interest_service.dart';
import 'package:vropay_final/app/core/services/message_service.dart';
import 'package:vropay_final/app/modules/Screens/message/controllers/message_controller.dart';

class MessageBindings extends Bindings {
  @override
  void dependencies() {
    // Register services first
    Get.lazyPut<MessageService>(() => MessageService(), fenix: true);
    Get.lazyPut<InterestService>(() => InterestService(), fenix: true);

    Get.lazyPut<MessageController>(() => MessageController(), fenix: true);
  }
}
