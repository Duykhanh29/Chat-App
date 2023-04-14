import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/chatting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class UserOnline extends GetView<MessageController> {
  //UserOnline({super.key, required this.user, required this.messageData});
  UserOnline({super.key, required this.user});
  User user;
//  MessageData? messageData;
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    print("User id check today: ${user.id}");

    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            var messageData = controller.getMessageData(user);
            if (messageData == null) {
              MessageData newMessageData =
                  MessageData(user: user, listMessages: []);
              controller.addNewChat(
                  newMessageData); // because of this user haven't chatted with me before
              Get.to(() => ChattingPage(), arguments: newMessageData);
            } else {
              Get.to(() => ChattingPage(), arguments: messageData);
            }
          },
          child: CircleAvatar(
            radius: 30,
            child: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(user.urlImage!),
            ),
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(user.name!),
      ],
    );
  }
}
