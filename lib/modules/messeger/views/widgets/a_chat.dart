import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/chatting_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chat_app/data/common/methods.dart';

class AChat extends StatelessWidget {
  MessageData messageData;
  Text displayTime(DateTime dateTime) {
    if (dateTime.day.compareTo(DateTime.now().day) == 0) {
      return Text(DateFormat.jm().format(dateTime));
    } else if (dateTime.day.compareTo(DateTime.now().day - 1) == 0) {
      return const Text("Yesterday");
    }
    return Text(DateFormat.EEEE().format(dateTime));
  }

  Widget showState(MessageData data, User currentUser) {
    if (data.listMessages!.last.sender != currentUser) {
      if (data.listMessages!.last.messageStatus == MessageStatus.SEEN) {
        return const Icon(Icons.done_outline);
      } else if (data.listMessages!.last.messageStatus ==
          MessageStatus.RECEIVED) {
        return const Icon(Icons.done_all);
      } else if (data.listMessages!.last.messageStatus == MessageStatus.SENT) {
        return const Icon(Icons.done);
      }
      return const Icon(Icons.send_rounded);
    } else {
      if (data.listMessages!.last.isSeen!) {
        return const Icon(
          Icons.circle,
          size: 12,
          color: Colors.red,
        );
      }
      return const Text("");
    }
  }

  Text displayMessage(MessageData data, User currentUser) {
    if (data.listMessages!.last.sender != currentUser) {
      if (!data.listMessages!.last.isSeen!) {
        if (data.listMessages!.last.chatMessageType ==
                ChatMessageType.VIDEOCALL ||
            data.listMessages!.last.chatMessageType == ChatMessageType.CALL) {
          return const Text(
            "The call ended",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
          );
        } else if (data.listMessages!.last.chatMessageType ==
            ChatMessageType.EMOJI) {
          return const Text(
            "An EMOJI is sent",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
          );
        } else if (data.listMessages!.last.chatMessageType ==
            ChatMessageType.FILE) {
          return const Text(
            "An attachment is sent",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
          );
        } else if (data.listMessages!.last.chatMessageType ==
            ChatMessageType.IMAGE) {
          return const Text(
            "An image is sent",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
          );
        } else if (data.listMessages!.last.chatMessageType ==
            ChatMessageType.AUDIO) {
          return const Text(
            "An audio is sent",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
          );
        } else if (data.listMessages!.last.chatMessageType ==
            ChatMessageType.VIDEO) {
          return const Text(
            "A video is sent",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
          );
        } else if (data.listMessages!.last.chatMessageType ==
            ChatMessageType.GIF) {
          return const Text(
            "A GIF is sent",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
          );
        } else if (data.listMessages!.last.chatMessageType ==
            ChatMessageType.GIF) {
          return const Text(
            "A Location is sent",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
          );
        }
        return Text(
          data.listMessages!.last.text!,
          // maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style:
              const TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
        );
      }
    }
    if (data.listMessages!.last.chatMessageType == ChatMessageType.VIDEOCALL ||
        data.listMessages!.last.chatMessageType == ChatMessageType.CALL) {
      return const Text(
        "The call ended",
        overflow: TextOverflow.ellipsis,
      );
    } else if (data.listMessages!.last.chatMessageType ==
        ChatMessageType.EMOJI) {
      return const Text(
        "An EMOJI is sent",
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
      );
    } else if (data.listMessages!.last.chatMessageType ==
        ChatMessageType.FILE) {
      return const Text(
        "An attachment is sent",
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
      );
    } else if (data.listMessages!.last.chatMessageType ==
        ChatMessageType.IMAGE) {
      return const Text(
        "An image is sent",
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
      );
    } else if (data.listMessages!.last.chatMessageType ==
        ChatMessageType.AUDIO) {
      return const Text(
        "An audio is sent",
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
      );
    } else if (data.listMessages!.last.chatMessageType ==
        ChatMessageType.VIDEO) {
      return const Text(
        "A video is sent",
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
      );
    } else if (data.listMessages!.last.chatMessageType == ChatMessageType.GIF) {
      return const Text(
        "A GIF is sent",
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
      );
    } else if (data.listMessages!.last.chatMessageType == ChatMessageType.GIF) {
      return const Text(
        "A Location is sent",
        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
      );
    }

    return Text(
      data.listMessages!.last.text!,
      // maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
    // return Text(
    //   data.listMessages!.last.text!,
    //   overflow: TextOverflow.ellipsis,
    //   style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
    // );
  }

  AChat({super.key, required this.messageData});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    final authController = Get.find<AuthController>();
    final currentUser = authController.currentUser.value;
    var list = messageData.listMessages;
    User? receiver;

    List<User>? receivers;
    //   if (CommonMethods.isAGroup(messageData.receivers)) {
    receivers = CommonMethods.getAllUserInChat(
        messageData.receivers!, controller.listAllUser.value, currentUser!);
    if (CommonMethods.isAGroup(messageData.receivers) == false) {
      receiver = CommonMethods.getReceiver(receivers, currentUser);
    }
    print("Chat index ID: ${messageData.idMessageData}");
    return
        // Dismissible(
        //   key: Key(messageData.user!.id!),
        //   onDismissed: (direction) {
        //     // print('Size nha: ${controller.listMessageData.length}');
        //     // var listData = controller.listMessageData;
        //     // print(
        //     //     "ListData size: #${controller.getListMessageData(listData).length}");
        //     // controller.deleteAConversation(messageData.user!.id!);
        //     // print('Size nha1: ${controller.listMessageData.length}');
        //     // var listData1 = controller.listMessageData;
        //     // print(
        //     //     "ListData size1: #${controller.getListMessageData(listData1).length}");
        //     // print("SIze messages: ${controller.sizeOfMessages(messageData)}");
        //   },
        //   direction: DismissDirection.endToStart,
        //   background: Container(
        //     color: Colors.red,
        //     alignment: Alignment.centerRight,
        //     padding: const EdgeInsets.only(right: 20),
        //     child: const Icon(
        //       Icons.delete,
        //       color: Colors.blue,
        //     ),
        //   ),
        //   child:
        Container(
      constraints: const BoxConstraints(maxHeight: 80),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color.fromARGB(255, 135, 177, 254)),
      margin: const EdgeInsets.only(bottom: 3),
      child: ListTile(
        isThreeLine: false,
        onTap: () {
          print("Check id of MSDATA: ${messageData.idMessageData}");
          Get.to(() => ChattingPage(), arguments: messageData);
        },
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: CommonMethods.isAGroup(messageData.receivers)
              ? messageData.groupImage != null
                  ? const NetworkImage(
                      "https://cdn-icons-png.flaticon.com/512/615/615075.png")
                  : NetworkImage(messageData.groupImage!)
              : receiver!.urlImage == null
                  ? const NetworkImage(
                      "https://t4.ftcdn.net/jpg/03/59/58/91/360_F_359589186_JDLl8dIWoBNf1iqEkHxhUeeOulx0wOC5.jpg")
                  : NetworkImage(receiver.urlImage!),
          child: GestureDetector(
            onTap: () {
              print("Oke nha");
            },
          ),
        ),
        subtitle: displayMessage(messageData, currentUser),
        title: CommonMethods.isAGroup(messageData.receivers)
            ? Text(messageData.chatName == null
                ? "No Group name"
                : messageData.chatName!)
            : Text(receiver!.name == null ? "No name" : receiver.name!),
        trailing: FittedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              displayTime(list!.last.dateTime!),
              showState(messageData, currentUser)
            ],
          ),
        ),
        //  ),
        // ),
      ),
    );
  }
}
