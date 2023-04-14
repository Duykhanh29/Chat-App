import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:get/get.dart';

class MessageBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(() => MessageController());
  }
}
