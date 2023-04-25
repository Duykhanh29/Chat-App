import 'package:chat_app/modules/home/controllers/home_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/message_view.dart';
import 'package:chat_app/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:chat_app/modules/profile/views/profile_view.dart';
import 'package:get/get.dart';

class MainView extends GetView<HomeController> {
  MainView({super.key});

  // int currentPage = 0;
  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    // Get.put(MessageController());
    // Get.put(ProfileController());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 25,
        backgroundColor: Colors.amber,
        selectedFontSize: 8,
        onTap: (value) {
          controller.updatePageIndex(value);
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(
                Icons.messenger,
                color: Colors.blue,
              ),
              label: "Messeger"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.group_rounded,
                color: Colors.blue,
              ),
              label: "Group"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person_2,
                color: Colors.blue,
              ),
              label: "Profile"),
        ],
        currentIndex: controller.currentPageINdex.value,
      ),
      body: Obx(
        () => IndexedStack(
          index: controller.currentPageINdex.value,
          children: controller.page,
        ),
      ),
    );
  }
}
