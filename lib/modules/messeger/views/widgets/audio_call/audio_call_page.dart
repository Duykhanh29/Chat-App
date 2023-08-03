import 'dart:async';

import 'package:chat_app/data/common/methods.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/chatting_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chat_app/modules/messeger/controllers/audio_call_controller.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:agora_uikit/agora_uikit.dart';
// import 'package:agora_rtm/agora_rtm.dart';

class AudioCallPage extends StatefulWidget {
  AudioCallPage({super.key, required this.messageData, this.senderID});
  MessageData messageData;
  String? senderID;
  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  final audioController = Get.put(AudioCallController());
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
      if (mounted) {
        setState(() {
          timeCounter++;
        });
      }
    });
  }

  void stopCount() {
    isActive = false;
    if (timer != null) {
      timer!.cancel();
      timer = null;
      timeCounter = 0;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
    /*
    if (widget.senderID != null) {
      audioController.setSenderID(widget.senderID!);
      print("Fine");
    }
    if (audioController.localUserJoined.value ||
        audioController.isJoinedSucceed.value) {
      startCount();
    }
    if (widget.senderID != null) {
      ever(audioController.isJoinedSucceed, (value) {
        if (value) {
          // startCount();
        } else {
          if (!audioController.isJoinedSucceed.value) {
            stopCount();
            // audioController.onCallEnd();
            Get.back();
            audioController.resetSenderID();
          }
        }
      });
    } else {
      ever(audioController.localUserJoined, (value) {
        if (value) {
          // startCount();
        } else {
          if (!audioController.isJoinedSucceed.value) {
            stopCount();
            // audioController.onCallEnd();
            Get.back();
            audioController.resetSenderID();
          }
        }
      });
    }
    */
  }

  Future getData() async {
    startCount();
    final callID =
        await audioController.getCallID(widget.messageData.idMessageData!);
    audioController.getNumberOfCurrentAudience(callID!).listen((event) async {
      if (event <= 1) {
        // Get.to(() => ChattingPage(), arguments: widget.messageData);
        stopCount();
        Get.back();
        Get.back();
        await audioController.leaveChannel(callID, widget.senderID!);
      }
    });
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
    // MessageData messageData = Get.arguments;
    final authController = Get.find<AuthController>();
    User? receiver;
    User? currentUser = authController.currentUser.value!;
    List<User>? receivers = CommonMethods.getAllUserInChat(
        widget.messageData.receivers!, controller.listAllUser.value);
    if (CommonMethods.isAGroup(widget.messageData.receivers) == false) {
      receiver = CommonMethods.getReceiver(receivers, currentUser);
    }

    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      // ),
      backgroundColor: const Color.fromARGB(255, 136, 179, 253),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            Center(
              child: Text(
                CommonMethods.isAGroup(widget.messageData.receivers)
                    ? widget.messageData.chatName ?? "Group"
                    : (receiver!.name == null ? "User" : receiver.name!),
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
                backgroundImage: CommonMethods.isAGroup(
                        widget.messageData.receivers)
                    ? widget.messageData.groupImage == null
                        ? const NetworkImage(
                            "https://cdn-icons-png.flaticon.com/512/615/615075.png")
                        : NetworkImage(widget.messageData.groupImage!)
                    : receiver!.urlImage == null
                        ? const NetworkImage(
                            "https://t4.ftcdn.net/jpg/03/59/58/91/360_F_359589186_JDLl8dIWoBNf1iqEkHxhUeeOulx0wOC5.jpg")
                        : NetworkImage(receiver.urlImage!),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // Obx(
            //   () {
            //     if (audioController.localUserJoined.value) {
            // startCount();
            // return
            SizedBox(
              height: 50,
              width: 300,
              child: Center(
                child: Text(formatTime(timeCounter),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400)),
              ),
            ),
            //     } else {
            //       return const SizedBox(
            //         height: 50,
            //         width: 300,
            //         child: Center(
            //           child: Text("Waiting",
            //               style: TextStyle(
            //                   fontSize: 18, fontWeight: FontWeight.w400)),
            //         ),
            //       );
            //     }
            //   },
            // ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        audioController.onToggleMute();
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromARGB(255, 28, 79, 167)),
                        child: Obx(
                          () {
                            return audioController.isMuted.value
                                ? const Icon(
                                    Icons.mic_none_outlined,
                                    color: Colors.white,
                                    size: 25,
                                  )
                                : const Icon(
                                    Icons.mic_off_outlined,
                                    color: Colors.white,
                                    size: 25,
                                  );
                          },
                        ),
                      ),
                    ),

                    // IconButton(
                    //   onPressed: () {},
                    //   icon:
                    // )

                    GestureDetector(
                      onTap: () {},

                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: const Color.fromARGB(255, 28, 79, 167)),
                        child: const Icon(
                          Icons.videocam_outlined,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      // IconButton(
                      //   onPressed: () {},
                      //   icon:
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: const Color.fromARGB(255, 28, 79, 167)),
                            child: const Icon(
                              Icons.note,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                          // IconButton(
                          //   onPressed: () {},
                          //   icon:
                          // )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.09,
            ),
            InkWell(
              onTap: () async {
                // final members = await audioController
                //     .getTotalNumberOfMembers(widget.messageData.idMessageData!);
                // if (members == 2) {
                // final memberLength = audioController.remoteUsers.value.length;
                // if(memberLength)
                final callID = await audioController
                    .getCallID(widget.messageData.idMessageData!);
                final listCurrentMembers =
                    await audioController.getListCurrentAudence(callID!);
                if (listCurrentMembers!.length == 2) {
                  final creatorID = await audioController
                      .getCreatorID(widget.messageData.idMessageData!);
                  if (creatorID != null) {
                    MessageStatus messageStatus;
                    User? user = controller.userGetUserFromIDBYGetX(
                        widget.messageData.receivers!.last);
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
                    // await
                    Message message = Message(
                        // idMessage: "ID0${size}",
                        chatMessageType: ChatMessageType.AUDIOCALL,
                        isSeen: false,
                        messageStatus: messageStatus,
                        dateTime: Timestamp.now(),
                        senderID: creatorID as String,
                        longTime: timeCounter);
                    controller.sendAMessage(message, widget.messageData);
                  }
                }

                // if the number of members in the call just have only 2
                // we send message with senderID
                // await audioController.leaveChannelUpdate(
                //     widget.messageData.idMessageData!, currentUser.id!);
                await audioController.leaveChannel(callID, currentUser.id!);
                audioController.onCallEnd();
                // Get.back();
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
            )
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
