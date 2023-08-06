import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/home/controllers/data_controller.dart';
import 'package:chat_app/modules/home/controllers/home_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/message_view.dart';
import 'package:chat_app/modules/profile/controllers/profile_controller.dart';
import 'package:chat_app/service/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:chat_app/modules/profile/views/widgets/profile_view.dart';
import 'package:get/get.dart';

class MainView extends StatefulWidget {
  MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final controller = Get.put(HomeController());
  // Get.lazyPut(() => HomeController());
  final authController = Get.put(AuthController());
  final msgController = Get.lazyPut(() => MessageController());
  final dataController = Get.lazyPut(() => DataController());

  @override
  void initState() {
    // TODO: implement initState

    User? currentUser = authController.currentUser.value;
    getToken(currentUser);
    getNotifications();
    super.initState();
  }

  Future getToken(User? user) async {
    final fcmToken = await NotificationService.getToken();
    if (user!.token == null) {
      await authController.setToken(fcmToken!, user.id!);
      // await authController.updateUserToFirebase(uid: user.id!, token: fcmToken);
    }
  }

  Future getNotifications() async {
    // Tẻminated state
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (value != null && value.notification != null) {
        print("This message is coming from ternimated");
        print(value.notification!.body);
        print(value.notification!.title);
        NotificationService.handleMessage(value);
      }
    });

    // Foreground State
    NotificationService.initialize();
    FirebaseMessaging.onMessage.listen((event) async {
      if (event.notification != null) {
        print("This message is coming from Foreground ");
        print(event.notification!.body);
        print(event.notification!.title);
        await NotificationService.display(event);
      }
    });

    // background State
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      if (event.notification != null) {
        print("This message is coming from background ");
        print(event.notification!.body);
        print(event.notification!.title);
        NotificationService.handleMessage(event);
      }
    });
  }

  // int currentPage = 0;
  @override
  Widget build(BuildContext context) {
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
            // BottomNavigationBarItem(
            //     icon: Icon(
            //       Icons.person_2,
            //       color: Colors.white70,
            //     ),
            //     label: "Profile"),
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
