import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/chatting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class AUserOnline extends GetView<MessageController> {
  AUserOnline({super.key, required this.receiver});
  User receiver;
  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final controller = Get.find<MessageController>();
    User currentUser = authController.currentUser.value!;
    return ListTile(
      onTap: () {
        MessageData newMessageData = MessageData(
            // sender: currentUser,
            listMessages: [],
            receivers: [currentUser.id!, receiver.id!]);
        controller.addNewChat(
            newMessageData); // because of this user haven't chatted with me before
        Get.to(() => ChattingPage(), arguments: newMessageData);
      },
      leading: CircleAvatar(
        backgroundImage: NetworkImage(receiver.urlImage!),
      ),
      title: Text(
        receiver.name!,
        style: const TextStyle(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w300),
      ),
    );
  }
}
