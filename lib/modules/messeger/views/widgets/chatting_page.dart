import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/message_tile.dart';
import 'package:chat_app/modules/messeger/views/widgets/call_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

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
      print("Oke");
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
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: FittedBox(
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
                    backgroundImage: NetworkImage(messageData!.user!.urlImage!),
                  ),
                ),
              ),
              //  ),
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
        actions: [
          FittedBox(
              child: IconButton(
                  onPressed: () {
                    Get.to(() => CallPage(), arguments: messageData);
                  },
                  icon: messageData.user!.userStatus! == UserStatus.ONLINE
                      ? const Icon(
                          Icons.local_phone_outlined,
                          color: Colors.orange,
                          size: 24,
                        )
                      : const Icon(
                          Icons.local_phone,
                          size: 24,
                        ))),
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
                        )))
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
                          var data = controller.listMessageData.firstWhere(
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
                              );
                            },
                          );
                        }),
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.mic,
                        color: Colors.blueAccent,
                      )),
                  const SizedBox(
                    width: 2,
                  ),
                  Flexible(
                    flex: 3,
                    child: TextField(
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
                              _showPicker(context);
                            },
                            icon: const Icon(Icons.photo)),
                        prefixIcon: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.attach_file_outlined),
                        ),
                        hintText: "Type messages",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // notice
                      // before take action, we need to stop everything is running such as stopping listen audio or video
                      MessageStatus messageStatus;
                      if (messageData.user!.userStatus == UserStatus.ONLINE) {
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
                          text: messageController.text,
                          chatMessageType: ChatMessageType.TEXT,
                          isSeen: false,
                          messageStatus: messageStatus,
                          dateTime: DateTime.now(),
                          isSender: false);
                      controller.sentAMessage(message, messageData.user!);
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
            const SizedBox(
              height: 10,
            )
          ],
        );
      }),
    );
  }
}
