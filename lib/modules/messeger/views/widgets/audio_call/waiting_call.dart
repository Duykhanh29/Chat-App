import 'package:chat_app/data/common/methods.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/messeger/controllers/audio_call_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/audio_call/audio_call_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class WaitingCall extends StatefulWidget {
  WaitingCall({super.key, required this.messageData, this.senderID});
  MessageData messageData;
  String? senderID;

  @override
  State<WaitingCall> createState() => _WaitingCallState();
}

class _WaitingCallState extends State<WaitingCall> {
  Future startWaiting() async {
    await Future.delayed(const Duration(seconds: 30));
    audioController.onCallEnd();
    // Get.back();
  }

  final audioController = Get.put(AudioCallController());
  final msgController = Get.put(MessageController());

  bool isWaiting = true;
  bool isStartCall = false;

  // this Widget just is used for sender
  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(
      Duration.zero,
      () async {
        await getData();
      },
    );
    super.initState();

    // getData();
    // if (widget.senderID != null) {

    // }
  }

  Future getData() async {
    await audioController.addCreatorInfor(
        widget.messageData.idMessageData!, widget.senderID!);
    final callID =
        await audioController.getCallID(widget.messageData.idMessageData!);
    audioController.getNumberOfCurrentAudience(callID!).listen((event) {
      if (event >= 2) {
        setState(() {
          isStartCall = true;
        });
        Get.to(() => AudioCallPage(
              messageData: widget.messageData,
              senderID: widget.senderID,
            ));
      } else {
        if (isStartCall) {
          Get.back();
        }
      }
    });

    // ever(audioController.localUserJoined, (data) {
    //   if (data) {
    //     if (!isStartCall) {
    //       Get.to(() => AudioCallPage(
    //             messageData: widget.messageData,
    //             senderID: widget.senderID,
    //           ));
    //       if (mounted) {
    //         setState(() {
    //           isStartCall = true;
    //         });
    //       }
    //     }
    //   } else {
    //     if (audioController.isEnded.value) {
    //       audioController.onCallEnd();
    //       // Get.back();
    //       audioController.resetSenderID();
    //     }
    //   }
    // });
    Future.delayed(const Duration(seconds: 60)).then((value) async {
      if (audioController.remoteUsers.value.isEmpty) {
        audioController.onCallEnd();
        // audioController.deleteUsersID(widget.senderID!);
        sendMessage(
            controller: msgController,
            senderID: widget.senderID!,
            type: ChatMessageType.MISSEDAUDIOCALL);
        audioController.resetSenderID();
        await audioController.leaveChannel(callID, widget.senderID!);
      }
    });
  }

  void sendMessage({
    required MessageController controller,
    required String senderID,
    required ChatMessageType type,
  }) {
    MessageStatus messageStatus;
    User? user =
        controller.userGetUserFromIDBYGetX(widget.messageData.receivers!.last);
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
      chatMessageType: type,
      isSeen: false,
      messageStatus: messageStatus,
      dateTime: Timestamp.now(),
      senderID: senderID,
      // longTime: timeCounter
    );
    controller.sendAMessage(message, widget.messageData);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // audioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    MessageData messageData = Get.arguments;
    final authController = Get.find<AuthController>();
    User? receiver;
    User? currentUser = authController.currentUser.value!;
    List<User>? receivers = CommonMethods.getAllUserInChat(
        widget.messageData.receivers!, controller.listAllUser.value);
    if (CommonMethods.isAGroup(widget.messageData.receivers) == false) {
      receiver = CommonMethods.getReceiver(receivers, currentUser);
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 136, 179, 253),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.18,
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
                      ? messageData.groupImage == null
                          ? const NetworkImage(
                              "https://cdn-icons-png.flaticon.com/512/615/615075.png")
                          : NetworkImage(messageData.groupImage!)
                      : receiver!.urlImage == null
                          ? const NetworkImage(
                              "https://t4.ftcdn.net/jpg/03/59/58/91/360_F_359589186_JDLl8dIWoBNf1iqEkHxhUeeOulx0wOC5.jpg")
                          : NetworkImage(receiver.urlImage!),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const SizedBox(
                height: 50,
                width: 300,
                child: Center(
                  child: Text("Waiting",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.08,
              ),
              InkWell(
                onTap: () {
                  if (currentUser.id == widget.senderID) {
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
                    Message message = Message(
                      // idMessage: "ID0${size}",
                      chatMessageType: ChatMessageType.MISSEDAUDIOCALL,
                      isSeen: false,
                      messageStatus: messageStatus,
                      dateTime: Timestamp.now(),
                      senderID: widget.senderID,
                    );
                    controller.sendAMessage(message, widget.messageData);
                  }
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
              ),
            ]),
      ),
    );
  }
}
