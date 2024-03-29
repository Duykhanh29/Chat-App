import 'package:chat_app/modules/home/controllers/data_controller.dart';
import 'package:get/get.dart';
import 'package:chat_app/modules/home/controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.put(DataController());
  }
}
