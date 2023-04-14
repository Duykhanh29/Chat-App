import 'package:chat_app/modules/home/controllers/home_controller.dart';
import 'package:chat_app/modules/home/views/home_view.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/message_view.dart';
import 'package:chat_app/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:chat_app/modules/profile/views/profile_view.dart';
import 'package:get/get.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int currentPage = 0;
  List<Widget> pages = [
    MessageView(),
    const ProfileView(),
  ];
  void changePage(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Get.put(MessageController());
    Get.put(ProfileController());
  }

  final controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 25,
        backgroundColor: Colors.amber,
        selectedFontSize: 8,
        onTap: (value) {
          changePage(value);
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
                Icons.person_2,
                color: Colors.blue,
              ),
              label: "Profile"),
        ],
        currentIndex: currentPage,
      ),
      body: IndexedStack(
        index: currentPage,
        children: pages,
      ),
    );
  }
}
