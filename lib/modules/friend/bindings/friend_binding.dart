import 'package:chat_app/modules/friend/controllers/friend_controller.dart';
import 'package:get/get.dart';

class FriendBinding extends Bindings {
  @override
  void dependencies() {
    //   Get.put(() => GroupController());
    Get.lazyPut<FriendController>(
      () => FriendController(),
    );
  }
}
