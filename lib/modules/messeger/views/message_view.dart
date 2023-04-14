import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:get/get.dart';

import './widgets/list_messeger.dart';
import './widgets/user_online.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class MessageView extends GetView<MessageController> {
  MessageView({super.key});
  var searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    var listUser = controller.listUser;
    var listMessageData = controller.listMessageData.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome back"),
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
                    child: ListView.separated(
                        separatorBuilder: (context, index) => const SizedBox(
                              width: 3,
                            ),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          User user = listUser[index];
                          print("Check user: ${user.id}");

                          return UserOnline(
                            user: user,
                            //   messageData: messageData,
                          );
                        },
                        itemCount: listUser.length),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const ListMesseger(),
          ],
        ),
      ),
    );
  }
}
