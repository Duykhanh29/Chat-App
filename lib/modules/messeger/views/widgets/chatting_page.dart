import 'dart:async';
import 'dart:io';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/components/camera.dart';
import 'package:chat_app/service/storage_service.dart';
import 'package:clipboard/clipboard.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/chatting_details.dart';
import 'package:chat_app/modules/messeger/views/widgets/message_tile.dart';
import 'package:chat_app/modules/messeger/views/widgets/call_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:chat_app/data/common/methods.dart';
import 'package:chat_app/utils/helpers/validators.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import './components/choose_options.dart';
import './components/recorder.dart';
import './components/reply_msg_input.dart';
import './components/cam.dart';

class ChattingPage extends GetView<MessageController> {
  var messageController = TextEditingController();
  ChattingPage({super.key});
  //MessageData? messageData;
  final scrollController = ScrollController();
  Storage storage = Storage();
  String userStatus(UserStatus userStatus) {
    if (userStatus == UserStatus.ONLINE) {
      return "Online";
    } else if (userStatus == UserStatus.OFFLINE) {
      return "Offline";
    }
    return "";
  }

  Future downloadAllImages(
      MessageData messageData, List<User>? receivers, User? currentUser) async {
    List<Reference> listURL = await storage.downloaddAllImages();
    for (var data in listURL) {
      try {
        var url = await data.getDownloadURL();
        MessageStatus messageStatus;
        messageStatus = CommonMethods.getMessageStatus(receivers, currentUser);
        Message message = Message(
            text: url,
            chatMessageType: ChatMessageType.IMAGE,
            isSeen: false,
            messageStatus: messageStatus,
            dateTime: DateTime.now(),
            sender: currentUser);
        message.showALlAttribute();
        controller.sentAMessage(message, messageData);
      } catch (e) {
        print("error is: $e");
      }
    }
  }

  Future downloadAllVideo(
      MessageData messageData, List<User>? receivers, User? currentUser) async {
    List<Reference> listURL = await storage.getVideo();
    for (var element in listURL) {
      var url = await element.getDownloadURL();
      MessageStatus messageStatus;
      messageStatus = CommonMethods.getMessageStatus(receivers, currentUser);
      Message message = Message(
          text: url,
          chatMessageType: ChatMessageType.VIDEO,
          isSeen: false,
          messageStatus: messageStatus,
          dateTime: DateTime.now(),
          sender: currentUser);
      message.showALlAttribute();
      controller.sentAMessage(message, messageData);
    }
  }

  List<Message>? getListMessages(MessageData? messageData) {
    if (messageData == null) {
      return null;
    } else {
      return messageData.listMessages!.reversed.toList();
    }
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
    final authController = Get.find<AuthController>();
    MessageData? messageData = Get.arguments;
    List<Message>? list = getListMessages(messageData);
    print("SHow all attributes: \n");
    messageData!.showALlAttribute();
    User? receiver;
    User? currentUser = authController.currentUser.value!;
    List<User>? receivers = CommonMethods.getAllUserInChat(
        messageData.receivers!, controller.listAllUser.value, currentUser);
    if (CommonMethods.isAGroup(messageData.receivers) == false) {
      receiver = CommonMethods.getReceiver(receivers, currentUser);
    }
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();

              // to find a receiver
              var data = controller.listMessageData.firstWhere((data) =>
                  data.receivers!.last == messageData.receivers!.last);
              final messageList = data.listMessages!.reversed.toList();
              if (messageList.isEmpty) {
                controller.deleteAChat(messageData);
              }
              if (controller.isSearch.value) {
                controller.cancelSearch();
                controller.stopSearch(
                    controller.searchController.text, messageData);
              }
              if (controller.isRecorder.value) {
                controller.changeRecorder();
              }
              if (controller.isMore.value) {
                controller.changeIsMore();
              }
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: Obx(() => controller.isSearch.value
            ? displaySearch(controller, messageData)
            : TitleWidget(
                controller: controller,
                messageData: messageData,
                receiver: receiver,
                userStatus: userStatus(receiver!.userStatus!))),
        actions: [
          FittedBox(
            child: IconButton(
              onPressed: () {
                Get.to(() => CallPage(), arguments: messageData);
              },
              icon: CommonMethods.isOnlineChat(receivers, currentUser) == true
                  ? const Icon(
                      Icons.local_phone_outlined,
                      color: Colors.orange,
                      size: 22,
                    )
                  : const Icon(
                      Icons.local_phone,
                      size: 22,
                    ),
            ),
          ),
          FittedBox(
            child: IconButton(
              onPressed: () async {
                await downloadAllImages(messageData, receivers, currentUser);
              },
              icon: CommonMethods.isOnlineChat(receivers, currentUser) == true
                  ? const Icon(
                      Icons.videocam_outlined,
                      size: 22,
                      color: Colors.orange,
                    )
                  : const Icon(
                      Icons.videocam,
                      size: 22,
                    ),
            ),
          ),
          FittedBox(
            child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  size: 22,
                )),
          )
        ],
      ),
      body: Obx(() {
        var data = controller.listMessageData.firstWhere(
            (data) => data.idMessageData == messageData.idMessageData);
        final messageList = data.listMessages!.reversed.toList();
        return Column(
          mainAxisAlignment: messageList.isEmpty
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: <Widget>[
            messageList.isEmpty
                ? NewConversation(
                    messageData: messageData,
                    currentUser: currentUser,
                    controller: controller,
                    receivers: receivers)
                : OldConversation(
                    messageData: messageData,
                    receiver: receivers.last,
                    currentUser: currentUser,
                    controller: controller),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Obx(() => controller.isChoosen.value
                  ? ChooseOptions(
                      messageData: messageData,
                      message: controller.findMessageFromID(
                          controller.deletedID.value, messageData)!,
                    )
                  : Inputer(
                      authController: authController,
                      controller: controller,
                      currentUser: currentUser,
                      messageController: messageController,
                      messageData: messageData,
                      receiver: receiver,
                      receivers: receivers,
                      storage: storage)),
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

class OldConversation extends StatelessWidget {
  const OldConversation({
    super.key,
    required this.messageData,
    required this.receiver,
    required this.currentUser,
    required this.controller,
  });
  final MessageData? messageData;
  final User? receiver;
  final User? currentUser;
  final MessageController controller;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: const Color.fromARGB(255, 245, 226, 187),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Obx(() {
            var list = controller.listMessageData.value;
            var data = list.firstWhere(
                (data) => data.idMessageData == messageData!.idMessageData);
            final messageList = data.listMessages!.reversed.toList();
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
              itemComparator: (message1, message2) =>
                  message1.dateTime!.compareTo(message2.dateTime!),
              groupHeaderBuilder: (message) => SizedBox(
                height: 30,
                child: Center(
                  child: Card(
                    color: Colors.blueGrey,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Validators.compareDate(message.dateTime!)
                          ? const Text(
                              "Today",
                              style: TextStyle(fontSize: 12),
                            )
                          : Text(
                              DateFormat.EEEE().format(message.dateTime!),
                              style: const TextStyle(fontSize: 12),
                            ),
                    ),
                  ),
                ),
              ),
              itemBuilder: (context, message) {
                return MessageTile(
                  idMessageData: messageData!.idMessageData!,
                  message: message,
                  currentUser: currentUser!,
                  key: ValueKey(message.idMessage),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class NewConversation extends StatelessWidget {
  const NewConversation({
    super.key,
    required this.messageData,
    required this.receivers,
    required this.currentUser,
    required this.controller,
  });

  final MessageData? messageData;
  final List<User>? receivers;
  final User? currentUser;
  final MessageController controller;

  @override
  Widget build(BuildContext context) {
    User? receiver;
    if (CommonMethods.isAGroup(messageData!.receivers) == false) {
      receiver = CommonMethods.getReceiver(receivers, currentUser);
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: CommonMethods.isAGroup(messageData!.receivers)
                ? messageData!.groupImage != null
                    ? const NetworkImage(
                        "https://cdn-icons-png.flaticon.com/512/615/615075.png")
                    : NetworkImage(messageData!.groupImage!)
                : receiver!.urlImage == null
                    ? const NetworkImage(
                        "https://t4.ftcdn.net/jpg/03/59/58/91/360_F_359589186_JDLl8dIWoBNf1iqEkHxhUeeOulx0wOC5.jpg")
                    : NetworkImage(receiver.urlImage!),
          ),
          const SizedBox(
            height: 50,
          ),
          TextButton(
              onPressed: () {
                MessageStatus messageStatus;
                messageStatus =
                    CommonMethods.getMessageStatus(receivers, currentUser);
                Message message = Message(
                    text: "Hello",
                    chatMessageType: ChatMessageType.TEXT,
                    isSeen: false,
                    messageStatus: messageStatus,
                    dateTime: DateTime.now(),
                    sender: currentUser);
                message.showALlAttribute();
                controller.sentAMessage(message, messageData!);
              },
              child: const Icon(
                Icons.waving_hand_rounded,
                color: Colors.blue,
                size: 60,
              )),
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
          )
        ],
      ),
    );
  }
}

class Inputer extends StatelessWidget {
  Inputer(
      {super.key,
      required this.authController,
      required this.controller,
      required this.currentUser,
      required this.messageController,
      required this.messageData,
      required this.receiver,
      required this.receivers,
      required this.storage});
  List<User>? receivers;
  User? currentUser;
  MessageController controller;
  AuthController authController;
  User? receiver;
  Storage storage = Storage();
  MessageData messageData;
  TextEditingController messageController;
  void _showPicker(context, MessageData messageData, List<User>? receivers,
      User? currentUser) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return SafeArea(
              child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () async {
                  final result = await FilePicker.platform.pickFiles(
                      allowMultiple: false,
                      type: FileType.custom,
                      allowedExtensions: ['png', 'jpg', 'mp4', 'mp3']);
                  if (result != null) {
                    final path = result.files.single.path!;
                    final fileName = result.files.single.name;
                    storage
                        .uploadFile(path, fileName, messageData.idMessageData!)
                        .then((value) => print("Done"));

                    String url = await storage.downloadURL(
                        fileName, messageData.idMessageData!);

                    MessageStatus messageStatus;
                    messageStatus =
                        CommonMethods.getMessageStatus(receivers, currentUser);
                    late Message message;
                    if (fileName.contains('.mp4')) {
                      message = Message(
                          text: url,
                          chatMessageType: ChatMessageType.VIDEO,
                          isSeen: false,
                          messageStatus: messageStatus,
                          dateTime: DateTime.now(),
                          sender: currentUser);
                    } else if (fileName.contains('.png') ||
                        fileName.contains('.jpg')) {
                      message = Message(
                          text: url,
                          chatMessageType: ChatMessageType.IMAGE,
                          isSeen: false,
                          messageStatus: messageStatus,
                          dateTime: DateTime.now(),
                          sender: currentUser);
                    } else if (fileName.contains('.mp3')) {
                      message = Message(
                          text: url,
                          chatMessageType: ChatMessageType.AUDIO,
                          isSeen: false,
                          messageStatus: messageStatus,
                          dateTime: DateTime.now(),
                          sender: currentUser);
                    }
                    message.showALlAttribute();
                    controller.sentAMessage(message, messageData);
                  } else {
                    print("Do nothing here");
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text("Camera"),
                onTap: () async {
                  // String imageURL = await storage.downloadURL(
                  //       fileName, messageData.idMessageData!);
                  //  Get.to(() => Camera());
                  MessageStatus messageStatus;
                  messageStatus =
                      CommonMethods.getMessageStatus(receivers, currentUser);
                  await availableCameras()
                      .then((value) => Get.to(() => CameraScreen(
                            cameras: value,
                            messageData: messageData,
                            messageStatus: messageStatus,
                            sender: currentUser,
                          )));
                },
              ),
            ],
          ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
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
                    flex: 3, child: Recorder(messageController: controller))
                : Flexible(
                    flex: 3,
                    child: Column(children: [
                      if (controller.isReply.value) ...{
                        BuildReplyMessageInput(
                          currentUser: authController.currentUser.value,
                          message: controller.replyMessage!,
                          user: receiver,
                        )
                      },
                      TextField(
                        focusNode: FocusNode(),
                        controller: messageController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.blueGrey[50],
                          labelStyle: const TextStyle(fontSize: 12),
                          contentPadding: const EdgeInsets.all(20),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          suffixIcon: IconButton(
                              onPressed: () {
                                // await downloadAllVideo(
                                //     messageData,
                                //     receivers,
                                //     currentUser);
                                controller.changeIsMore();
                              },
                              icon: const Icon(Icons.more_horiz_outlined)),
                          prefixIcon: IconButton(
                            onPressed: () async {
                              _showPicker(
                                  context, messageData, receivers, currentUser);
                            },
                            icon: const Icon(Icons.photo),
                          ),
                          hintText: "Aa",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide:
                                const BorderSide(color: Colors.blueAccent),
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
              messageStatus =
                  CommonMethods.getMessageStatus(receivers, currentUser);
              late Message message;
              bool isSend = true;
              if (controller.isRecorder.value) {
                message = Message(
                    text: "/data/user/0/com.example.chat_app/cache/audio2",
                    chatMessageType: ChatMessageType.AUDIO,
                    isSeen: false,
                    messageStatus: messageStatus,
                    dateTime: DateTime.now(),
                    sender: currentUser);
                controller.changeRecorder();
                print("Recorder");
              } else {
                if (messageController.text != "" &&
                    messageController.text != null) {
                  if (controller.isReply.value) {
                    message = Message(
                        replyToUser: controller.replyToUser,
                        // idMessage: ,
                        text: messageController.text,
                        chatMessageType: ChatMessageType.TEXT,
                        isSeen: false,
                        messageStatus: messageStatus,
                        dateTime: DateTime.now(),
                        sender: authController.currentUser.value,
                        isRepy: true,
                        idReplyText: controller.replyMessage!.idMessage);
                    print("Reply");
                    controller.changeisReply();
                    controller.resetReplyMessage();
                  } else {
                    message = Message(
                        text: messageController.text,
                        chatMessageType: ChatMessageType.TEXT,
                        isSeen: false,
                        messageStatus: messageStatus,
                        dateTime: DateTime.now(),
                        sender: currentUser);
                  }
                } else {
                  // do nothing
                  isSend = false;
                }
              }
              if (isSend) {
                message.showALlAttribute();
                print("ID in ms data: ${messageData.idMessageData}");
                controller.sentAMessage(message, messageData);
                messageController.text = "";
              }
            },
            icon: const Icon(
              Icons.send_sharp,
              color: Colors.blue,
            ),
          ),
        ],
      ),
      Obx(
        () {
          var result = controller.isMore.value;
          if (controller.isMore.value) {
            return Container(
              height: 80,
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 232, 241, 245)),
              width: MediaQuery.of(context).size.width * 0.98,
              padding: const EdgeInsets.only(top: 5),
              margin: const EdgeInsets.only(top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(
                    width: 5,
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.blue.withOpacity(0.1)),
                        child: const Icon(Icons.emoji_emotions,
                            color: Colors.blue, size: 25)),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.blue.withOpacity(0.1)),
                      child: const Icon(
                        Icons.attach_file_outlined,
                        size: 25,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.blue.withOpacity(0.1)),
                        child: const Icon(
                          Icons.location_pin,
                          size: 25,
                          color: Colors.blue,
                        )),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                ],
              ),
            );
          } else {
            return Container(
              height: 1,
            );
          }
        },
      ),
    ]);
  }
}

class TitleWidget extends StatelessWidget {
  TitleWidget(
      {super.key,
      required this.controller,
      required this.messageData,
      required this.receiver,
      required this.userStatus});
  MessageData messageData;
  MessageController controller;
  User? receiver;
  String userStatus;
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.red,
              child: CircleAvatar(
                radius: 27,
                backgroundImage: CommonMethods.isAGroup(messageData.receivers!)
                    ? (messageData.groupImage == null
                        ? const NetworkImage(
                            "https://cdn-icons-png.flaticon.com/512/615/615075.png")
                        : NetworkImage(messageData.groupImage!))
                    : (receiver!.urlImage == null
                        ? const NetworkImage(
                            "https://t4.ftcdn.net/jpg/03/59/58/91/360_F_359589186_JDLl8dIWoBNf1iqEkHxhUeeOulx0wOC5.jpg")
                        : NetworkImage(receiver!.urlImage!)),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (controller.isSearch.value) {
                controller.cancelSearch();
              }
              Get.to(() => ChattingDetails(), arguments: messageData);
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
                      CommonMethods.isAGroup(messageData.receivers)
                          ? (Text(messageData.chatName == null
                              ? "No Group name"
                              : messageData.chatName!))
                          : (Text(receiver!.name == null
                              ? "No name"
                              : receiver!.name!)),
                      Text(
                        userStatus, //
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
    );
  }
}
