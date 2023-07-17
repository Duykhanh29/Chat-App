import 'dart:async';
import 'dart:io';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/friend/controllers/friend_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/components/camera.dart';
import 'package:chat_app/service/storage_service.dart';
import 'package:clipboard/clipboard.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/chatting_details.dart';
import 'package:chat_app/modules/messeger/views/widgets/message_tile.dart';
import 'package:chat_app/modules/messeger/views/widgets/call_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:geolocator/geolocator.dart';

class ChattingPage extends GetView<MessageController> {
  var messageController = TextEditingController();
  ChattingPage({super.key});
  //MessageData? messageData;
  final scrollController = ScrollController();
  Storage storage = Storage();
  String userStatus(UserStatus? userStatus) {
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
            dateTime: Timestamp.now(),
            senderID: currentUser!.id);
        message.showALlAttribute();
        controller.sendAMessage(message, messageData);
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
          dateTime: Timestamp.now(),
          senderID: currentUser!.id);
      message.showALlAttribute();
      controller.sendAMessage(message, messageData);
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

  List<Widget> actions(
          MessageData messageData, List<User>? receivers, User currentUser) =>
      <Widget>[
        if (CommonMethods.isAGroup(messageData.receivers)) ...{
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
        } else ...{
          Obx(
            () {
              final friendController = Get.find<FriendController>();
              List<User> listFriends = friendController.listFriends;

              User? receiver =
                  CommonMethods.getReceiver(receivers, currentUser);
              return CommonMethods.isFriend(receiver!.id!, listFriends) == true
                  ? FittedBox(
                      child: IconButton(
                        onPressed: () {
                          Get.to(() => CallPage(), arguments: messageData);
                        },
                        icon: CommonMethods.isOnlineChat(
                                    receivers, currentUser) ==
                                true
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
                    )
                  :
                  // FittedBox(
                  //     child:
                  Container();
              //);
              // const FittedBox(
              //     child: Visibility(
              //       visible: false,
              //       child: Icon(Icons.local_phone_outlined),
              //     ),
              //   );
            },
          ),
          Obx(() {
            final friendController = Get.find<FriendController>();
            List<User> listFriends = friendController.listFriends;

            User? receiver = CommonMethods.getReceiver(receivers, currentUser);
            return CommonMethods.isFriend(receiver!.id!, listFriends) == true
                ? FittedBox(
                    child: IconButton(
                      onPressed: () async {
                        await downloadAllImages(
                            messageData, receivers, currentUser);
                      },
                      icon:
                          CommonMethods.isOnlineChat(receivers, currentUser) ==
                                  true
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
                  )
                : Container();
            // FittedBox(
            //     child: Container(),
            //   );
          }),
          FittedBox(
            child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  size: 22,
                )),
          )
        },
      ];
  @override
  Widget build(BuildContext context) {
    Get.put(MessageController());
    Get.put(AuthController());
    Get.put(FriendController());
    final controller = Get.find<MessageController>();
    final authController = Get.find<AuthController>();
    final friendController = Get.find<FriendController>();
    MessageData? messageData = Get.arguments;
    // List<Message>? list = getListMessages(messageData);
    print("SHow all attributes: \n");
    messageData!.showALlAttribute();
    User? receiver;
    User? currentUser = authController.currentUser.value!;
    List<User>? receivers = CommonMethods.getAllUserInChat(
        messageData.receivers!, controller.listAllUser.value);
    if (CommonMethods.isAGroup(messageData.receivers) == false) {
      receiver = CommonMethods.getReceiver(receivers, currentUser);
    }
    final msgData = FirebaseFirestore.instance
        .collection('messageDatas')
        .doc(messageData.idMessageData);
    List<User> friends = friendController.listFriends;
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
                friends: friends,
                controller: controller,
                messageData: messageData,
                receiver: receiver,
                userStatus:
                    receiver == null ? null : userStatus(receiver.userStatus))),
        actions: actions(messageData, receivers, currentUser),
      ),
      body: Obx(
        () {
          var data = controller.listMessageData.firstWhere(
              (data) => data.idMessageData == messageData.idMessageData);
          final messageList = data.listMessages!.reversed.toList();
          return Column(
            mainAxisAlignment: messageList.isEmpty
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: <Widget>[
              // Expanded(
              //   child:

              StreamBuilder(
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    //  final messageDt = snapshot.data!;
                    // if (snapshot.data != null) {
                    MessageData currentMsgData = MessageData(
                      idMessageData: snapshot.data!.idMessageData,
                      chatName: snapshot.data!.chatName,
                      groupImage: snapshot.data!.groupImage,
                      listMessages: (snapshot.data!.listMessages),
                      // .toList(),
                      receivers: List<String>.from(snapshot.data!.receivers!),
                    );

                    final messages = currentMsgData.listMessages;
                    if (CommonMethods.isAGroup(currentMsgData.receivers) &&
                        (currentMsgData.listMessages!.isEmpty)) {
                      return NewConversation(
                          messageData: messageData,
                          currentUser: currentUser,
                          controller: controller,
                          receivers: receivers,
                          friends: friends);
                    }
                    return OldConversation(
                        messageData: currentMsgData,
                        //        receivers: receivers,
                        currentUser: currentUser,
                        controller: controller);
                    // }
                  } else {
                    return NewConversation(
                        messageData: messageData,
                        currentUser: currentUser,
                        controller: controller,
                        receivers: receivers,
                        friends: friends);
                    // return const Center(child: CircularProgressIndicator());
                  }
                },
                stream: controller.getMesgData(messageData),
              ),
              // ),
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
        },
      ),
    );
  }
}

class OldConversation extends StatelessWidget {
  const OldConversation({
    super.key,
    required this.messageData,
    // required this.receiver,
    required this.currentUser,
    required this.controller,
  });
  final MessageData? messageData;
  //final User? receiver;
  final User? currentUser;
  final MessageController controller;
  @override
  Widget build(BuildContext context) {
    final messageList = messageData!.listMessages!.reversed.toList();
    print("Show all attributes of all messages in a chat\n");
    for (var element in messageList) {
      element.showALlAttribute();
    }
    return Expanded(
      child: Theme(
        data: Theme.of(context).copyWith(
            scrollbarTheme: ScrollbarThemeData(
                thumbColor:
                    MaterialStateProperty.all<Color>(Colors.blueAccent))),
        child: Scrollbar(
          child: Container(
            color: const Color.fromARGB(255, 245, 226, 187),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child:
                  //Obx(() {
                  // var list = controller.listMessageData.value;
                  // var data = list.firstWhere(
                  //     (data) => data.idMessageData == messageData!.idMessageData);

                  //return
                  GroupedListView<Message, DateTime>(
                order: GroupedListOrder.DESC,
                elements: messageList,
                groupBy: (message) {
                  return DateTime(
                      message.dateTime!.toDate().year,
                      message.dateTime!.toDate().month,
                      message.dateTime!.toDate().day,
                      message.dateTime!.toDate().hour);
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
                        child:
                            Validators.compareDate(message.dateTime!.toDate())
                                ? const Text(
                                    "Today",
                                    style: TextStyle(fontSize: 12),
                                  )
                                : Text(
                                    DateFormat.EEEE()
                                        .format(message.dateTime!.toDate()),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NewConversation extends StatelessWidget {
  const NewConversation(
      {super.key,
      required this.messageData,
      required this.receivers,
      required this.currentUser,
      required this.controller,
      required this.friends});
  final List<User>? friends;
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
    return Scrollbar(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            CircleAvatar(
              radius: 50,
              backgroundImage: CommonMethods.isAGroup(messageData!.receivers)
                  ? messageData!.groupImage == null
                      ? const NetworkImage(
                          "https://cdn-icons-png.flaticon.com/512/615/615075.png")
                      : NetworkImage(messageData!.groupImage!)
                  : receiver!.urlImage == null
                      ? const NetworkImage(
                          "https://t4.ftcdn.net/jpg/03/59/58/91/360_F_359589186_JDLl8dIWoBNf1iqEkHxhUeeOulx0wOC5.jpg")
                      : NetworkImage(receiver.urlImage!),
            ),
            if (CommonMethods.isAGroup(messageData!.receivers)) ...{
              const SizedBox(
                height: 50,
              ),
            } else ...{
              if (!CommonMethods.isFriend(receiver!.id!, friends) &&
                  receiver != null) ...{
                const SizedBox(
                  height: 30,
                ),
                const Text("You are not friends"),
                const SizedBox(
                  height: 10,
                ),
              } else ...{
                const SizedBox(
                  height: 50,
                ),
              },
            },
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
                    dateTime: Timestamp.now(),
                    senderID: currentUser!.id);
                message.showALlAttribute();
                controller.sendAMessage(message, messageData!);
              },
              child: const Icon(
                Icons.waving_hand_rounded,
                color: Colors.blue,
                size: 60,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
            )
          ],
        ),
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
                    String type = '';
                    ChatMessageType chatMessageType;
                    if (fileName.contains('.mp4')) {
                      type = 'videos';
                      chatMessageType = ChatMessageType.VIDEO;
                    } else if (fileName.contains('.png') ||
                        fileName.contains('.jpg')) {
                      type = 'images';
                      chatMessageType = ChatMessageType.IMAGE;
                    } else {
                      type = 'audios';
                      chatMessageType = ChatMessageType.AUDIO;
                    }
                    bool isSuccess = await storage.uploadFile(
                        path, fileName, messageData.idMessageData!, type);
                    if (isSuccess) {
                      String url = await storage.downloadURL(
                          fileName, messageData.idMessageData!, type);
                      MessageStatus messageStatus;
                      messageStatus = CommonMethods.getMessageStatus(
                          receivers, currentUser);
                      late Message message;
                      message = Message(
                          text: url,
                          chatMessageType: ChatMessageType.IMAGE,
                          isSeen: false,
                          messageStatus: messageStatus,
                          dateTime: Timestamp.now(),
                          senderID: currentUser!.id);
                      message.showALlAttribute();
                      controller.sendAMessage(message, messageData);
                    } else {
                      print("Nothing happend");
                    }
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

  var latitude = '';
  var longitude = '';

  late StreamSubscription<Position> streamSubscription;
  Future getCurrentLocation() async {
    bool enabledServices;
    enabledServices = await Geolocator.isLocationServiceEnabled();
    if (!enabledServices) {
      await Geolocator.openLocationSettings();
      return Future.error("Please allow to open position");
    }
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
      } else if (permission == LocationPermission.deniedForever) {
        print("'Location permissions are permanently denied");
      } else {
        print("GPS Location service is granted");
      }
    } else {
      print("GPS Location permission granted.");
    }
    Position position = await Geolocator.getCurrentPosition();
    String latitude = position.latitude.toString();
    String longitude = position.longitude.toString();
    controller.changeLongTitudeVsLattitude(
        newLong: longitude, newLat: latitude);
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
                    dateTime: Timestamp.now(),
                    senderID: currentUser!.id);
                controller.changeRecorder();
                print("Recorder");
              } else {
                if (messageController.text != "" &&
                    messageController.text != null) {
                  if (controller.isReply.value) {
                    message = Message(
                        replyToUserID: controller.replyToUserID,
                        // idMessage: ,
                        text: messageController.text,
                        chatMessageType: ChatMessageType.TEXT,
                        isSeen: false,
                        messageStatus: messageStatus,
                        dateTime: Timestamp.now(),
                        senderID: currentUser!.id,
                        isReply: true,
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
                        dateTime: Timestamp.now(),
                        senderID: currentUser!.id);
                  }
                } else {
                  // do nothing
                  isSend = false;
                }
              }
              if (isSend) {
                message.showALlAttribute();
                print("ID in ms data: ${messageData.idMessageData}");
                controller.sendAMessage(message, messageData);
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
                    onTap: () async {
                      await getCurrentLocation();

                      MessageStatus messageStatus;
                      messageStatus = CommonMethods.getMessageStatus(
                          receivers, currentUser);
                      Message message = Message(
                          text:
                              "${controller.latitude.value},${controller.longtitude.value}",
                          chatMessageType: ChatMessageType.LOCATION,
                          isSeen: false,
                          messageStatus: messageStatus,
                          dateTime: Timestamp.now(),
                          senderID: currentUser!.id);
                      controller.sendAMessage(message, messageData);
                      controller.changeIsMore();
                    },
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
      required this.friends,
      required this.controller,
      required this.messageData,
      required this.receiver,
      required this.userStatus});
  MessageData messageData;
  MessageController controller;
  User? receiver;
  String? userStatus;
  List<User>? friends;
  @override
  Widget build(BuildContext context) {
    double outerRadius = 23;
    double innerRadius = 20;
    if (!CommonMethods.isAGroup(messageData.receivers)) {
      if (CommonMethods.isFriend(receiver!.id!, friends)) {
        innerRadius = 35;
        outerRadius = 40;
      }
    }

    return FittedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
            child: CircleAvatar(
              radius: outerRadius,
              backgroundColor: Colors.red,
              child: CircleAvatar(
                radius: innerRadius,
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
              // Get.to(() => ChattingDetails(), arguments: messageData);
              Get.to(() => ChattingDetails(
                    messageData: messageData,
                  ));
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
                          ? (Text(
                              messageData.chatName == null ||
                                      messageData.chatName == ""
                                  ? "No Group name"
                                  : messageData.chatName!,
                              style: const TextStyle(fontSize: 25),
                            ))
                          : (Text(receiver!.name == null
                              ? "No name"
                              : receiver!.name!)),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        userStatus ?? "", //
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
