import 'dart:async';

import 'package:chat_app/data/common/methods.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/messeger/controllers/call_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/audio_call/audio_call_page.dart';
import 'package:chat_app/modules/messeger/views/widgets/audio_call/video_call.dart';
import 'package:chat_app/modules/messeger/views/widgets/audio_call/waiting_call.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chat_app/modules/messeger/controllers/audio_call_controller.dart';

class CallNotification extends StatelessWidget {
  CallNotification({super.key, required this.messageData, required this.type});
  MessageData messageData;
  String type;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    // MessageData messageData = Get.arguments;
    final authController = Get.find<AuthController>();
    User? receiver;
    User? currentUser = authController.currentUser.value!;
    List<User>? receivers = CommonMethods.getAllUserInChat(
        messageData.receivers!, controller.listAllUser.value);
    if (CommonMethods.isAGroup(messageData.receivers) == false) {
      receiver = CommonMethods.getReceiver(receivers, currentUser);
    }
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 136, 179, 253),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            Center(
              child: Text(
                receiver!.name == null ? "User" : receiver.name!,
                style: const TextStyle(
                    fontSize: 30,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 90,
              child: CircleAvatar(
                radius: 80,
                backgroundImage: CommonMethods.isAGroup(messageData.receivers)
                    ? messageData.groupImage == null
                        ? const NetworkImage(
                            "https://cdn-icons-png.flaticon.com/512/615/615075.png")
                        : NetworkImage(messageData.groupImage!)
                    : receiver.urlImage == null
                        ? const NetworkImage(
                            "https://t4.ftcdn.net/jpg/03/59/58/91/360_F_359589186_JDLl8dIWoBNf1iqEkHxhUeeOulx0wOC5.jpg")
                        : NetworkImage(receiver.urlImage!),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            type == "VIDEOCALL"
                ? const Text("Incoming video call")
                : const Text("Incoming audio call"),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () async {
                    final callController = Get.put(AudioCallController());
                    final callID = await callController
                        .getCallID(messageData.idMessageData!);
                    await callController.joinChannel(callID!, currentUser.id!);
                    Get.to(() => AudioCallPage(
                          messageData: messageData,
                          senderID: currentUser.id,
                        ));
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.redAccent),
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final videoCallController = Get.put(CallController());
                    final callID = await videoCallController
                        .getCallID(messageData.idMessageData!);
                    await videoCallController.joinChannel(
                        callID!, currentUser.id!);
                    Get.to(() => VideoCall(
                          messageData: messageData,
                          sender: currentUser,
                        ));
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.green),
                    child: const Icon(
                      Icons.call_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
