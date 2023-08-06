import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chat_app/data/common/methods.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/messeger/controllers/call_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/chatting_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:wakelock/wakelock.dart';
import 'package:chat_app/utils/settings/settings.dart';

class VideoCall extends StatefulWidget {
  VideoCall({super.key, required this.messageData, this.sender});
  MessageData messageData;
  User? sender;
  @override
  State<VideoCall> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  final callController = Get.put(CallController());
  final msgController = Get.put(MessageController());
  Timer? timer;
  void startWaiting() {
    timer = Timer(Duration(seconds: 60), () {
      if (callController.remoteUsers.value.isEmpty) {
        // Get.back();
      } else {
        startCount();
      }
    });
  }

  bool isActive = false;
  int timeCounter = 0;
  void startCount() {
    setState(() {
      isActive = true;
    });
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          timeCounter++; // Tăng thời gian chạy lên 1 giây
        });
      }
    });
  }

  String formatTime(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }

  void sendMessage(
      {required MessageController controller,
      required String senderID,
      required ChatMessageType type,
      int? timeCounter}) {
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
        longTime: timeCounter);
    controller.sendAMessage(message, widget.messageData);
  }

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
    // Wakelock.enable(); // Turn on wakelock feature till call is running
    // startWaiting();

    // callController.setSenderID(w)
    // if (widget.sender != null) {
    //   print("Fine");
    // }
    // ever(callController.remoteUsers, (value) {
    //   if (value.isNotEmpty) {
    //     startCount();
    //   } else {
    //     if (isActive) {
    //       timer!.cancel();
    //       Get.back();
    //     }
    //   }
    // });
    // Future.delayed(Duration(seconds: 60), () {
    //   if (!isActive) {
    //     callController.onCallEnd();
    //     if (widget.sender != null) {
    //       sendMessage(
    //           controller: msgController,
    //           senderID: widget.sender!.id!,
    //           type: ChatMessageType.MISSEDVIDEOCALL);
    //     }
    //   }
    // });
  }

  void stopCount() {
    isActive = false;
    if (timer != null) {
      timer!.cancel();
      timer = null;
      timeCounter = 0;
    }
  }

  Future getData() async {
    final callID =
        await callController.getCallID(widget.messageData.idMessageData!);
    callController.getNumberOfCurrentAudience(callID!).listen((event) async {
      if (event <= 1) {
        // if number of members in a call is less or equal to 1 ( this means that there is at least 2 members in call before)
        if (isActive) {
          stopCount();
          Get.back();
          await callController.leaveChannel(callID, widget.sender!.id!);
          // Get.to(() => ChattingPage(), arguments: widget.messageData);
          // final senderID = await callController
          //     .getCreatorID(widget.messageData.idMessageData!);
          //              sendMessage(controller: msgController, senderID: senderID!, type: Chat)
        }
      } else {
        if (!isActive) {
          startCount();
        }
      }
    });
    Future.delayed(Duration(seconds: 60), () async {
      if (!isActive) {
        callController.onCallEnd();
        final senderID = await callController
            .getCreatorID(widget.messageData.idMessageData!);
        sendMessage(
            controller: msgController,
            senderID: senderID!,
            type: ChatMessageType.MISSEDVIDEOCALL);
        await callController.leaveChannel(callID, widget.sender!.id!);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // Wakelock.disable(); // Turn off wakelock feature after call end
    if (isActive) {
      timer!.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // callController.changeIsAudioCall(false);
    // if (CommonMethods.isAGroup(widget.messageData.receivers)) {
    //   callController.changeIsGroup();
    // }
    final authController = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              Center(
                child: (callController.localUserJoined.value == true
                    ? (callController.remoteUsers.value.isNotEmpty
                        ?
                        //  AgoraVideoView(
                        //     controller: VideoViewController.remote(
                        //       rtcEngine: callController.rtcEngine,
                        //       canvas: VideoCanvas(
                        //           uid: callController.myremoteUid.value),
                        //       connection:
                        //           const RtcConnection(channelId: channelId),
                        //     ),
                        //   )
                        (CommonMethods.isAGroup(widget.messageData.receivers)
                            ? viewRow(callController)
                            : AgoraVideoView(
                                controller: VideoViewController(
                                  rtcEngine: callController.rtcEngine,
                                  canvas: VideoCanvas(
                                      uid: callController
                                          .remoteUsers.value.last),
                                ),
                              ))
                        : const Center(
                            child: Text(
                              'Waiting',
                              style: TextStyle(color: Colors.white),
                            ),
                          ))
                    : const Center(
                        child: Text(
                          'No Remote',
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
              ),
              Align(
                alignment: Alignment.topRight,
                child: SizedBox(
                  width: 120,
                  height: 160,
                  child: Center(
                    child: Obx(
                      () {
                        return callController.localUserJoined.value
                            ? AgoraVideoView(
                                controller: VideoViewController(
                                  rtcEngine: callController.rtcEngine,
                                  canvas: const VideoCanvas(uid: 0),
                                ),
                              )
                            : const CircularProgressIndicator();
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 10,
                right: 10,
                child: Container(
                  // height: MediaQuery.of(context).size.height * 0.05,
                  child: Column(
                    children: [
                      Obx(
                        () {
                          bool isEmpty =
                              callController.remoteUsers.value.isEmpty;
                          return SizedBox(
                            height: 50,
                            width: 300,
                            child: Center(
                              child: !isEmpty
                                  ? Text(formatTime(timeCounter),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400))
                                  : const Text(""),
                            ),
                          );
                        },
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                callController.onToggleMute();
                              },
                              child: Icon(
                                callController.muted.value
                                    ? Icons.mic
                                    : Icons.mic_off,
                                size: 35,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () async {
                                final callID = await callController.getCallID(
                                    widget.messageData.idMessageData!);
                                if (!isActive) {
                                  final senderID =
                                      await callController.getCreatorID(
                                          widget.messageData.idMessageData!);
                                  sendMessage(
                                      controller: msgController,
                                      senderID: senderID!,
                                      type: ChatMessageType.MISSEDVIDEOCALL);
                                } else {
                                  final listCurrentMembers =
                                      await callController
                                          .getListCurrentAudence(callID!);
                                  if (listCurrentMembers!.length == 2) {
                                    final creatorID =
                                        await callController.getCreatorID(
                                            widget.messageData.idMessageData!);
                                    if (creatorID != null) {
                                      MessageStatus messageStatus;
                                      User? user = msgController
                                          .userGetUserFromIDBYGetX(widget
                                              .messageData.receivers!.last);
                                      if (user!.userStatus ==
                                          UserStatus.ONLINE) {
                                        messageStatus = MessageStatus.RECEIVED;
                                      } else if (user.userStatus ==
                                          UserStatus.OFFLINE) {
                                        messageStatus = MessageStatus.SENT;
                                      } else if (user.userStatus ==
                                          UserStatus.PRIVACY) {
                                        messageStatus = MessageStatus.SENDING;
                                      } else {
                                        messageStatus = MessageStatus.SEEN;
                                      }
                                      // int size = messageData.listMessages!.length + 1;
                                      // await
                                      sendMessage(
                                          controller: msgController,
                                          senderID: creatorID,
                                          type: ChatMessageType.VIDEOCALL);
                                    }
                                  }
                                }
                                await callController.leaveChannel(
                                    callID!, widget.sender!.id!);
                                callController.onCallEnd();
                              },
                              child: const Icon(
                                Icons.call,
                                size: 35,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          // Expanded(
                          //   flex: 1,
                          //   child: InkWell(
                          //     onTap: () {
                          //       callController.onVideoOff();
                          //     },
                          //     child: const CircleAvatar(
                          //       backgroundColor: Colors.white,
                          //       child: Padding(
                          //         padding: EdgeInsets.all(5),
                          //         child: Center(
                          //           child: Icon(
                          //             Icons.photo_camera_front,
                          //             size: 25,
                          //             color: Colors.black,
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                callController.onSwitchCamera();
                              },
                              child: const Icon(
                                Icons.switch_camera_rounded,
                                size: 35,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _getRenderViews(CallController controller) {
    final List<AgoraVideoView> list = [];
    controller.remoteUsers.forEach(
      (element) {
        list.add(
          AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: controller.rtcEngine,
              canvas: VideoCanvas(uid: element),
            ),
          ),
        );
      },
    );
    return list;
  }

  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  Widget viewRow(CallController controller) {
    final views = _getRenderViews(controller);
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }
}
