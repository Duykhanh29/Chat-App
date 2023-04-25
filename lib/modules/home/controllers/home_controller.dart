import 'package:chat_app/modules/group/controllers/group_controller.dart';
import 'package:chat_app/modules/group/views/group_view.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/message_view.dart';
import 'package:chat_app/modules/profile/controllers/profile_controller.dart';
import 'package:chat_app/modules/profile/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  List<Widget> page = [MessageView(), const GroupView(), const ProfileView()];
  RxInt currentPageINdex = 0.obs;

  @override
  void onInit() {
    Get.put(MessageController());
    super.onInit();
  }

  void updatePageIndex(int index) {
    currentPageINdex.value = index;
    if (index == 2) {
      Get.put(ProfileController());
    } else if (index == 1) {
      Get.put(GroupController());
    }
  }
}
