import 'package:get/get.dart';
import 'package:vropay_final/app/modules/Screens/message/controllers/message_controller.dart';

class MessageBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessageController>(() => MessageController(), fenix: true);
  }
}
