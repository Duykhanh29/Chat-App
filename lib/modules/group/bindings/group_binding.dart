import 'package:chat_app/modules/group/controllers/group_controller.dart';
import 'package:get/get.dart';

class GroupBinding extends Bindings {
  @override
  void dependencies() {
    //   Get.put(() => GroupController());
    Get.lazyPut<GroupController>(
      () => GroupController(),
    );
  }
}
