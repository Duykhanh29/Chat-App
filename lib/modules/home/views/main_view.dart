import 'package:chat_app/modules/home/controllers/data_controller.dart';
import 'package:chat_app/modules/home/controllers/home_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/message_view.dart';
import 'package:chat_app/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:chat_app/modules/profile/views/widgets/profile_view.dart';
import 'package:get/get.dart';

class MainView extends GetView<HomeController> {
  MainView({super.key});

  // int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => MessageController());
    Get.lazyPut(() => DataController());
    final controller = Get.find<HomeController>();
    final dataController = Get.find<DataController>();
    final msgController = Get.find<MessageController>();
    // Get.put(MessageController());
    // Get.put(ProfileController());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          iconSize: 25,
          backgroundColor: const Color.fromARGB(255, 98, 170, 212),
          selectedFontSize: 8,
          onTap: (value) {
            controller.updatePageIndex(value);
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.messenger,
                  color: Colors.white70,
                ),
                label: "Messeges"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.group_rounded,
                  color: Colors.white70,
                ),
                label: "Friends"),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.person_2,
                  color: Colors.white70,
                ),
                label: "Profile"),
          ],
          currentIndex: controller.currentPageINdex.value,
        ),
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
