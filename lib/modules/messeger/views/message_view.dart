import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:get/get.dart';

import './widgets/list_messeger.dart';
import './widgets/user_online.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:chat_app/modules/profile/views/drawer.dart';

class MessageView extends GetView<MessageController> {
  MessageView({super.key});
  var searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Get.put(MessageController());
    final controller = Get.find<MessageController>();
    var listUser = controller.listUser;
    var listMessageData = controller.listMessageData.value;
    final authController = Get.find<AuthController>();
    User currentUser = authController.currentUser.value!;
    return Scaffold(
      drawer: MyDrawer(),
      appBar: AppBar(
        title: const Text("Welcome back"),
        actions: [
          IconButton(
              onPressed: () {
                currentUser.showALlAttribute();
              },
              icon: const Icon(
                Icons.person_add_alt_1_rounded,
                color: Colors.blue,
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(right: 5, left: 5),
              height: 45,
              child: Center(
                child: TextField(
                  onChanged: (value) =>
                      controller.filterListMessageData(searchController.text),
                  controller: searchController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    prefixIcon: const Icon(Icons.search),
                    hintText: "Search for friends",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.12,
              child: Row(
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                          radius: 30,
                          child: IconButton(
                              onPressed: () {
                                print("add story");
                                for (var data in controller.listMessageData) {
                                  // print(
                                  //     "Numbers of chatting with user: ${data.se!.name} and id: ${data.user!.id} and size: ${data.listMessages!.length}");
                                }
                              },
                              icon: const Icon(
                                Icons.add,
                                size: 25,
                              ))),
                      const SizedBox(
                        height: 4,
                      ),
                      const Text(
                        "Add story",
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Obx(() {
                      print("Render");
                      List<User> list = controller.listUser.value;
                      return ListView.separated(
                          separatorBuilder: (context, index) => const SizedBox(
                                width: 3,
                              ),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            User user = list[index];

                            return UserOnline(
                              receiver: user,
                              //   messageData: messageData,
                            );
                          },
                          itemCount: list.length);
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const ListMesseger(),
          ],
        ),
      ),
    );
  }
}
