import 'package:chat_app/modules/messeger/views/message_view.dart';
import 'package:chat_app/modules/profile/views/profile_view.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var index = 0;
  void changeTabindex(int value) {
    index = value;
    update();
    if (value == 1) {
      Get.to(() => const ProfileView());
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }
}
