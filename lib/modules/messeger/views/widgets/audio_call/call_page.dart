import 'dart:async';

import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:agora_uikit/agora_uikit.dart';
// import 'package:agora_rtm/agora_rtm.dart';

class CallPage extends StatefulWidget {
  CallPage({super.key});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  bool isActive = false;
  int timeCounter = 0;
  Timer? timer;

  Duration startTime = Duration.zero;

  Duration time = Duration.zero;
  void startCount() {
    isActive = true;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timeCounter++;
      });
    });
  }

  void stopCount() {
    isActive = false;
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startCount();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    stopCount();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    MessageData messageData = Get.arguments;
    final authController = Get.find<AuthController>();
    User? receiver =
        controller.userGetUserFromIDBYGetX(messageData.receivers!.last);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color.fromARGB(255, 136, 179, 253),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 30,
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
              radius: 100,
              child: CircleAvatar(
                radius: 90,
                backgroundImage: receiver.urlImage == null
                    ? const NetworkImage(
                        "https://t4.ftcdn.net/jpg/03/59/58/91/360_F_359589186_JDLl8dIWoBNf1iqEkHxhUeeOulx0wOC5.jpg")
                    : NetworkImage(receiver.urlImage!),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 50,
              width: 300,
              child: Center(
                child: Text(formatTime(timeCounter),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400)),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.mic_none_outlined,
                              color: Colors.yellowAccent,
                            ),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.volume_up_outlined,
                              color: Colors.indigoAccent,
                            ),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.videocam_outlined,
                              color: Colors.greenAccent,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.message_outlined,
                              color: Colors.amberAccent,
                            ),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.note,
                              color: Colors.deepOrange,
                            ),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.video_call_outlined,
                              color: Colors.deepPurple,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 80,
            ),
            InkWell(
              onTap: () {
                MessageStatus messageStatus;
                User? user = controller
                    .userGetUserFromIDBYGetX(messageData.receivers!.last);
                if (user!.userStatus == UserStatus.ONLINE) {
                  messageStatus = MessageStatus.RECEIVED;
                } else if (user.userStatus == UserStatus.OFFLINE) {
                  messageStatus = MessageStatus.SENT;
                } else if (user.userStatus == UserStatus.PRIVACY) {
                  messageStatus = MessageStatus.SENDING;
                } else {
                  messageStatus = MessageStatus.SEEN;
                }
                // int size = messageData.listMessages!.length + 1;
                Message message = Message(
                    // idMessage: "ID0${size}",
                    chatMessageType: ChatMessageType.CALL,
                    isSeen: false,
                    messageStatus: messageStatus,
                    dateTime: Timestamp.now(),
                    senderID: authController.currentUser.value!.id,
                    longTime: timeCounter);
                controller.sendAMessage(message, messageData);

                Get.back();
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.redAccent),
                  ),
                  const Icon(Icons.call_end_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeCounter extends StatefulWidget {
  TimeCounter({super.key});

  @override
  State<TimeCounter> createState() => _TimeCounterState();
}

class _TimeCounterState extends State<TimeCounter> {
  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  bool isActive = false;
  int timeCounter = 0;
  Timer? timer;

  Duration startTime = Duration.zero;

  Duration time = Duration.zero;
  void startCount() {
    isActive = true;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        timeCounter++;
      });
    });
  }

  void stopCount() {
    isActive = false;
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startCount();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    stopCount();
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return "$minutesStr:$secondsStr";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 300,
      child: Center(
        child: Text(formatTime(timeCounter)),
      ),
    );
  }
}
