import 'package:chat_app/modules/friend/controllers/friend_controller.dart';
import 'package:chat_app/modules/friend/views/friend_view.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/message_view.dart';
import 'package:chat_app/modules/profile/controllers/profile_controller.dart';
import 'package:chat_app/modules/profile/views/widgets/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  List<Widget> page = [MessageView(), FriendView(), const ProfileView()];
  RxInt currentPageINdex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    Get.lazyPut(
      () => ProfileController(),
    );
    Get.lazyPut(() => FriendController());
    Get.lazyPut(() => ProfileController());
  }

  void updatePageIndex(int index) {
    currentPageINdex.value = index;
  }
}
