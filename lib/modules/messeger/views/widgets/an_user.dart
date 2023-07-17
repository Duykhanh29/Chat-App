import 'package:chat_app/data/common/methods.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/chatting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class AnUser extends GetView<MessageController> {
  //UserOnline({super.key, required this.user, required this.messageData});
  AnUser({super.key, required this.receiver});
  User receiver;
//  MessageData? messageData;
  @override
  Widget build(BuildContext context) {
    Get.put(MessageController());
    Get.put(AuthController());
    final authController = Get.find<AuthController>();
    final controller = Get.find<MessageController>();
    User currentUser = authController.currentUser.value!;
    print("receiver print: \n");
    receiver.showALlAttribute();
    print("Curernt user print: \n");
    currentUser.showALlAttribute();
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.18,
      //   decoration: BoxDecoration(color: Colors.red),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              receiver.showALlAttribute();

              var messageData =
                  controller.getMessageDataOneByOne(currentUser, receiver);

              if (messageData == null) {
                List<String> list = [];
                CommonMethods.addToReceiverListOneByOne(
                    list: list, receiver: receiver.id, sender: currentUser.id);
                print("Lrht: ${list.length}");
                MessageData newMessageData = MessageData(
                    // sender: currentUser,
                    listMessages: [],
                    receivers: list);
                controller.addNewChat(
                    newMessageData); // because of this user haven't chatted with me before
                Get.to(() => ChattingPage(), arguments: newMessageData);
              } else {
                //  messageData.showALlAttribute();
                Get.to(() => ChattingPage(), arguments: messageData);
              }
            },
            child: CircleAvatar(
              radius: 30,
              child: CircleAvatar(
                radius: 25,
                backgroundImage: receiver.urlImage == null
                    ? const NetworkImage(
                        "https://t4.ftcdn.net/jpg/03/59/58/91/360_F_359589186_JDLl8dIWoBNf1iqEkHxhUeeOulx0wOC5.jpg")
                    : NetworkImage(receiver.urlImage!),
              ),
            ),
          ),
          const SizedBox(
            height: 4,
          ),
          receiver.name == null
              ? const Text("user")
              : Text(
                  receiver.name!,
                  overflow: TextOverflow.ellipsis,
                ),
        ],
      ),
    );
  }
}
