import 'dart:async';
import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/chatting_details.dart';
import 'package:chat_app/modules/messeger/views/widgets/message_tile.dart';
import 'package:chat_app/modules/messeger/views/widgets/call_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:permission_handler/permission_handler.dart';

class ChattingPage extends GetView<MessageController> {
  var messageController = TextEditingController();
  ChattingPage({super.key});
  //MessageData? messageData;
  final scrollController = ScrollController();
  String userStatus(UserStatus userStatus) {
    if (userStatus == UserStatus.ONLINE) {
      return "Online";
    } else if (userStatus == UserStatus.OFFLINE) {
      return "Offline";
    }
    return "";
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return SafeArea(
              child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text("Camera"),
                onTap: () {},
              ),
            ],
          ));
        });
  }

  List<Message>? getListMessages(MessageData? messageData) {
    if (messageData == null) {
      return null;
    } else {
      return messageData.listMessages!.reversed.toList();
    }
  }

  bool compareDate(DateTime dateTime) {
    if (dateTime.day == DateTime.now().day &&
        dateTime.month == DateTime.now().month &&
        dateTime.year == DateTime.now().year) {
      return true;
    }
    return false;
  }

  Widget displaySearch(
      MessageController messageController, MessageData messageData) {
    return Container(
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: TextField(
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            //hanlde the value when user click search in
            messageController.searchMessages(value, messageData);
          },
          controller: messageController.searchController,
          decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search...',
              suffixIcon: IconButton(
                  onPressed: () {
                    messageController.cancelSearch();
                    messageController.stopSearch(
                        messageController.searchController.text, messageData);
                  },
                  icon: const Icon(Icons.cancel_rounded)),
              border: InputBorder.none),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    MessageData? messageData = Get.arguments;
    List<Message>? list = getListMessages(messageData);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
              var data = controller.listMessageData
                  .firstWhere((data) => data.user!.id == messageData!.user!.id);
              final messageList = data.listMessages!.reversed.toList();
              if (messageList.isEmpty) {
                controller.deleteAChat(messageData!);
              }
              if (controller.isSearch.value) {
                controller.cancelSearch();
                controller.stopSearch(
                    controller.searchController.text, messageData!);
              }
              if (controller.isRecorder.value) {
                controller.changeRecorder();
              }
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: Obx(
          () => controller.isSearch.value
              ? displaySearch(controller, messageData!)
              : FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      // BackButton(
                      //   onPressed: () {
                      //     Get.back();
                      //   },
                      // ),
                      InkWell(
                        // child: SizedBox(
                        //   width: 40,
                        //   height: 40,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.red,
                          child: CircleAvatar(
                            radius: 27,
                            backgroundImage:
                                NetworkImage(messageData!.user!.urlImage!),
                          ),
                        ),
                      ),
                      //  ),
                      GestureDetector(
                        onTap: () {
                          if (controller.isSearch.value) {
                            controller.cancelSearch();
                          }
                          Get.to(() => ChattingDetails(),
                              arguments: messageData);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            Container(
                              width: 180,
                              padding: const EdgeInsets.only(left: 15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    messageData.user!.name!,
                                    style: const TextStyle(fontSize: 25),
                                  ),
                                  Text(
                                    userStatus(messageData.user!.userStatus!),
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.clip,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        actions: [
          FittedBox(
            child: IconButton(
              onPressed: () {
                Get.to(() => CallPage(), arguments: messageData);
              },
              icon: messageData!.user!.userStatus! == UserStatus.ONLINE
                  ? const Icon(
                      Icons.local_phone_outlined,
                      color: Colors.orange,
                      size: 24,
                    )
                  : const Icon(
                      Icons.local_phone,
                      size: 24,
                    ),
            ),
          ),
          FittedBox(
            child: IconButton(
              onPressed: () {},
              icon: messageData.user!.userStatus! == UserStatus.ONLINE
                  ? const Icon(
                      Icons.videocam_outlined,
                      size: 24,
                      color: Colors.orange,
                    )
                  : const Icon(
                      Icons.videocam,
                      size: 24,
                    ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        var data = controller.listMessageData
            .firstWhere((data) => data.user!.id == messageData.user!.id);
        final messageList = data.listMessages!.reversed.toList();
        return Column(
          mainAxisAlignment: messageList.isEmpty
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: <Widget>[
            messageList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              NetworkImage(messageData.user!.urlImage!),
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        TextButton(
                            onPressed: () {
                              MessageStatus messageStatus;
                              if (messageData.user!.userStatus ==
                                  UserStatus.ONLINE) {
                                messageStatus = MessageStatus.RECEIVED;
                              } else if (messageData.user!.userStatus ==
                                  UserStatus.OFFLINE) {
                                messageStatus = MessageStatus.SENT;
                              } else if (messageData.user!.userStatus ==
                                  UserStatus.PRIVACY) {
                                messageStatus = MessageStatus.SENDING;
                              } else {
                                messageStatus = MessageStatus.SEEN;
                              }
                              Message message = Message(
                                  text: "Hello",
                                  chatMessageType: ChatMessageType.TEXT,
                                  isSeen: false,
                                  messageStatus: messageStatus,
                                  dateTime: DateTime.now(),
                                  isSender: false);
                              controller.sentAMessage(
                                  message, messageData.user!);
                            },
                            child: const Icon(
                              Icons.waving_hand_rounded,
                              color: Colors.blue,
                              size: 60,
                            )),
                        const SizedBox(
                          height: 30,
                        ),
                        const Text(
                          "Say hello to start conversation",
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                        )
                      ],
                    ),
                  )
                : Expanded(
                    child: Container(
                      color: const Color.fromARGB(255, 245, 226, 187),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Obx(() {
                          var list = controller.listMessageData.value;
                          var data = list.firstWhere(
                              (data) => data.user!.id == messageData.user!.id);
                          final messageList =
                              data.listMessages!.reversed.toList();
                          return GroupedListView<Message, DateTime>(
                            order: GroupedListOrder.DESC,
                            elements: messageList,
                            groupBy: (message) {
                              return DateTime(
                                message.dateTime!.year,
                                message.dateTime!.month,
                                message.dateTime!.day,
                              );
                            },
                            physics: const BouncingScrollPhysics(),
                            reverse: true,
                            floatingHeader: true,
                            shrinkWrap: true,
                            useStickyGroupSeparators: true,
                            itemComparator: (message1, message2) => message1
                                .dateTime!
                                .compareTo(message2.dateTime!),
                            groupHeaderBuilder: (message) => SizedBox(
                              height: 30,
                              child: Center(
                                child: Card(
                                  color: Colors.blueGrey,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: compareDate(message.dateTime!)
                                        ? const Text(
                                            "Today",
                                            style: TextStyle(fontSize: 12),
                                          )
                                        : Text(
                                            DateFormat.EEEE()
                                                .format(message.dateTime!),
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            itemBuilder: (context, message) {
                              return MessageTile(
                                message: message,
                                user: data.user!,
                                key: ValueKey(message.idMessage),
                              );
                            },
                          );
                        }),
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Obx(
                () => controller.isChoosen.value
                    ? ChooseOptions(
                        messageData: messageData,
                        message: controller.findMessageFromID(
                            controller.deletedID.value, messageData)!,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Obx(
                            () => controller.isRecorder.value
                                ? const SizedBox(
                                    height: 25,
                                    width: 25,
                                  )
                                : IconButton(
                                    onPressed: () {
                                      controller.changeRecorder();
                                    },
                                    icon: const Icon(Icons.mic)),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Obx(
                            () => controller.isRecorder.value
                                ? Flexible(
                                    flex: 3,
                                    child:
                                        Recorder(messageController: controller))
                                : Flexible(
                                    flex: 3,
                                    child: Column(children: [
                                      if (controller.isReply.value) ...{
                                        BuildReplyMessageInput(
                                          message: controller.replyMessage!,
                                          user: messageData.user!,
                                        )
                                      },
                                      TextField(
                                        focusNode: FocusNode(),
                                        controller: messageController,
                                        decoration: InputDecoration(
                                          filled: true,
                                          fillColor: Colors.blueGrey[50],
                                          labelStyle:
                                              const TextStyle(fontSize: 12),
                                          contentPadding:
                                              const EdgeInsets.all(20),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          suffixIcon: IconButton(
                                              onPressed: () {
                                                _showPicker(context);
                                              },
                                              icon: const Icon(Icons.photo)),
                                          prefixIcon: IconButton(
                                            onPressed: () {},
                                            icon: const Icon(
                                                Icons.attach_file_outlined),
                                          ),
                                          hintText: "Type messages",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            borderSide: const BorderSide(
                                                color: Colors.blueAccent),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                          ),
                          IconButton(
                            onPressed: () {
                              // notice
                              // before take action, we need to stop everything is running such as stopping listen audio or video
                              MessageStatus messageStatus;
                              if (messageData.user!.userStatus ==
                                  UserStatus.ONLINE) {
                                messageStatus = MessageStatus.RECEIVED;
                              } else if (messageData.user!.userStatus ==
                                  UserStatus.OFFLINE) {
                                messageStatus = MessageStatus.SENT;
                              } else if (messageData.user!.userStatus ==
                                  UserStatus.PRIVACY) {
                                messageStatus = MessageStatus.SENDING;
                              } else {
                                messageStatus = MessageStatus.SEEN;
                              }
                              late Message message;
                              int size = messageData.listMessages!.length + 1;
                              if (controller.isRecorder.value) {
                                message = Message(
                                    idMessage: "ID0${size}",
                                    text:
                                        "/data/user/0/com.example.chat_app/cache/audio2",
                                    chatMessageType: ChatMessageType.AUDIO,
                                    isSeen: false,
                                    messageStatus: messageStatus,
                                    dateTime: DateTime.now(),
                                    isSender: false);
                                controller.changeRecorder();
                                controller.sentAMessage(
                                    message, messageData.user!);
                              } else {
                                if (messageController.text != "") {
                                  if (controller.isReply.value) {
                                    message = Message(
                                        replyToUser: controller.replyToUser,
                                        idMessage: "ID0${size}",
                                        text: messageController.text,
                                        chatMessageType: ChatMessageType.TEXT,
                                        isSeen: false,
                                        messageStatus: messageStatus,
                                        dateTime: DateTime.now(),
                                        isSender: false,
                                        isRepy: true,
                                        idReplyText:
                                            controller.replyMessage!.idMessage);
                                    controller.changeisReply();
                                    controller.resetReplyMessage();
                                  } else {
                                    message = Message(
                                        idMessage: "ID0${size}",
                                        text: messageController.text,
                                        chatMessageType: ChatMessageType.TEXT,
                                        isSeen: false,
                                        messageStatus: messageStatus,
                                        dateTime: DateTime.now(),
                                        isSender: false);
                                  }

                                  controller.sentAMessage(
                                      message, messageData.user!);
                                }
                              }
                              messageController.text = "";
                            },
                            icon: const Icon(
                              Icons.send_sharp,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        );
      }),
    );
  }
}

class Recorder extends StatefulWidget {
  Recorder({super.key, required this.messageController});
  MessageController messageController;

  @override
  State<Recorder> createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  final recorder = FlutterSoundRecorder();
  bool isInitialized = false;
  final StreamController<RecordingDisposition> recorderController =
      StreamController<RecordingDisposition>();
  bool _isRecording = false;
  Future record() async {
    await recorder.startRecorder(toFile: 'audio2');
  }

  Future stop() async {
    final path = await recorder.stopRecorder();
    final audioFile = File(path!);
    print("Audio recorder: $audioFile");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialRecorder();
  }

  Future initialRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
    await recorder.openRecorder();
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
    isInitialized = true;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    recorder.closeRecorder();
    recorderController.close();
    isInitialized = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity * 0.6,
      height: 40,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: Colors.amber),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onLongPressStart: (LongPressStartDetails details) async {
                await record();
                setState(() {});
              },
              onLongPressMoveUpdate:
                  (LongPressMoveUpdateDetails details) async {
                await stop();
                setState(() {});
              },
              onLongPressEnd: (LongPressEndDetails details) async {
                await stop();
                setState(() {});
              },
              child: InkWell(
                splashColor: Colors.blue,
                highlightColor: Colors.red,
                child: Icon(
                  recorder.isRecording ? Icons.stop : Icons.mic,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            StreamBuilder<RecordingDisposition>(
              builder: (context, snapshot) {
                final duration =
                    snapshot.hasData ? snapshot.data!.duration : Duration.zero;
                String twoDigits(int n) => n.toString().padLeft(2, '0');

                final twoDigitMinutes =
                    twoDigits(duration.inMinutes.remainder(60));
                final twoDigitSeconds =
                    twoDigits(duration.inSeconds.remainder(60));

                return Text(
                  '$twoDigitMinutes:$twoDigitSeconds',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                );
              },
              stream: recorder.onProgress,
            ),
            IconButton(
              onPressed: () {
                widget.messageController.changeRecorder();
              },
              icon: const Icon(Icons.cancel),
            ),
          ],
        ),
      ),
    );
  }
}

class ChooseOptions extends GetView<MessageController> {
  ChooseOptions({super.key, required this.messageData, required this.message});
  MessageData messageData;
  //String id;
  Message message;
  Future showSheet(BuildContext context, MessageController messageController) {
    return showModalBottomSheet(
        context: context,
        builder: (_) {
          return Container(
            height: 200,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 6),
                const Text('Do you want to delete this message'),
                const SizedBox(height: 6),
                if (messageController.differenceHours(message) < 3) ...{
                  Container(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        // Thực hiện hành động xóa vĩnh viễn
                        //   Navigator.pop(context);
                        controller.deleteAMessage(
                            message.idMessage!, messageData);
                        controller.changeIsChoose();
                        Navigator.pop(context);
                      },
                      child: const Text('Unsend for everyone'),
                    ),
                  ),
                  const SizedBox(height: 6),
                },
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      // Thực hiện hành động xóa
                      //   Navigator.pop(context);
                      controller.deleteAMessage(message.idMessage!, messageData,
                          justForYou: true);
                      controller.changeIsChoose();
                      Navigator.pop(context);
                    },
                    child: const Text('Unsend for you'),
                  ),
                ),
                const SizedBox(height: 4),
                const Divider(
                  color: Color.fromARGB(255, 101, 118, 121),
                  height: 1,
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      // Hủy thao tác xóa
                      //   Navigator.pop(context);
                      controller.changeIsChoose();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.blueGrey),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
                onPressed: () {
                  controller.changeIsChoose();
                  controller.changeReplyMessage(message, messageData.user!);
                  controller.changeisReply();
                },
                child: const Text("Reply")),
            TextButton(
                onPressed: () async {
                  FlutterClipboard.copy(message.text!).then((value) {
                    return ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Text Copied'),
                      ),
                    );
                  });

                  controller.changeIsChoose();
                },
                child: const Text("Copy")),
            TextButton(
                onPressed: () async {
                  await showSheet(context, controller);
                },
                child: const Text("Unsend")),
            TextButton(
                onPressed: () async {
                  controller.changeIsChoose();
                },
                child: const Text("Cancel")),
          ],
        ),
      ),
    );
  }
}
