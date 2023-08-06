import 'package:chat_app/data/common/methods.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/friend/views/widgetss/view_profile.dart';
import 'package:chat_app/modules/home/controllers/data_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/message_types/call_message.dart';
import 'package:chat_app/utils/helpers/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'message_types/audio_message.dart';
import 'message_types/video_message.dart';
import 'message_types/image_message.dart';
import 'message_types/text_message.dart';
import 'message_types/location_message.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';

class MessageTile extends GetView<MessageController> {
  MessageTile(
      {super.key,
      required this.message,
      required this.currentUser,
      required this.idMessageData});
  Message message;
  String idMessageData; // to identify which MessageData it bolong to
  User currentUser;
  final focusNode = FocusNode();
  Widget messageContain(Message message) {
    if (message.chatMessageType == ChatMessageType.AUDIO) {
      return AudioMessage(
          message: message,
          currentUser: currentUser,
          idMessageData: idMessageData);
    } else if (message.chatMessageType == ChatMessageType.VIDEO) {
      return VideoMessage(
          message: message,
          currentUser: currentUser,
          idMessageData: idMessageData);
    } else if (message.chatMessageType == ChatMessageType.IMAGE) {
      return ImageMessage(
          message: message,
          currentUser: currentUser,
          idMessageData: idMessageData);
    } else if (message.chatMessageType == ChatMessageType.TEXT) {
      return TextMessage(
          message: message,
          currentUser: currentUser,
          idMessageData: idMessageData);
    } else if (message.chatMessageType == ChatMessageType.FILE) {
      return TextMessage(
          message: message,
          currentUser: currentUser,
          idMessageData: idMessageData);
    } else if (message.chatMessageType == ChatMessageType.LOCATION) {
      return LocationMessage(
          message: message,
          currentUser: currentUser,
          idMessageData: idMessageData);
    } else {
      return CallMessage(
          message: message,
          currentUser: currentUser,
          idMessageData: idMessageData);
    }
  }

  Widget getShareIcon(Message message) {
    if (message.chatMessageType == ChatMessageType.AUDIO) {
      return Container(
        height: 40,
        width: 30,
        child: Center(
          child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.share_rounded,
                color: Colors.blue,
              )),
        ),
      );
    } else if (message.chatMessageType == ChatMessageType.VIDEO) {
      return Container(
        height: 130,
        width: 30,
        child: Center(
          child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.share_rounded,
                color: Colors.blue,
              )),
        ),
      );
    } else if (message.chatMessageType == ChatMessageType.IMAGE) {
      return Container(
        height: double.infinity * 0.35,
        width: 30,
        child: Center(
          child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.share_rounded,
                color: Colors.blue,
              )),
        ),
      );
    } else if (message.chatMessageType == ChatMessageType.TEXT) {
      return Container(
        height: 50,
        width: 30,
        child: Center(
          child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.share_rounded,
                color: Colors.blue,
              )),
        ),
      );
    } else {
      return Container(
        height: 70,
        width: 30,
        child: Center(
          child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.share_rounded,
                color: Colors.blue,
              )),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => DataController());
    final controller = Get.find<MessageController>();
    final authController = Get.find<AuthController>();
    final dataController = Get.find<DataController>();
    final listAllUser = dataController.listAllUser.value;
    final currentUser = authController.currentUser.value;

    return SwipeTo(
      onLeftSwipe: () {},
      onRightSwipe: () {
        if (!message.isDeleted) {
          // if (!message.isSender!) {
          //   print('Test 2');
          //   print(
          //       'Id: ${message.idMessage} and text: ${message.text} and type: ${message.chatMessageType} isSender: ${message.isSender}');
          //   controller.changeReplyMessage(message, User());
          //   controller.changeisReply();
          // } else {
          // print('Test 2');
          // print(
          //     'Id: ${message.idMessage} and text: ${message.text} and type: ${message.chatMessageType} sender: ${message.senderID}');
          controller.changeReplyMessage(
              message); //message here is message which need reply(old msg)
          controller.changeisReply();
          //  }
        }
      },
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment:
              message.chatMessageType == ChatMessageType.NOTIFICATION
                  ? MainAxisAlignment.center
                  : message.senderID != currentUser!.id
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
          children: [
            if (message.senderID != currentUser!.id &&
                message.chatMessageType != ChatMessageType.NOTIFICATION) ...[
              InkWell(
                onTap: () {
                  // Get.to(ViewProfile(user: ));
                },
                child: Obx(
                  () {
                    final listUser = controller.relatedUserToCurrentUser.value;
                    User? sender;
                    if (listAllUser != null && listAllUser.isNotEmpty) {
                      sender = CommonMethods.getUserFromID(
                          listAllUser, message.senderID);
                      return CircleAvatar(
                        radius: 15,
                        backgroundImage: NetworkImage(
                          sender!.urlImage!,
                        ),
                      );
                    } else {
                      return const CircleAvatar(
                        radius: 15,
                        backgroundImage: NetworkImage(
                          "https://t4.ftcdn.net/jpg/03/59/58/91/360_F_359589186_JDLl8dIWoBNf1iqEkHxhUeeOulx0wOC5.jpg",
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(
                width: 5,
              ),
            ],
            // if (!message.isSender!) ...{
            //   getShareIcon(message),
            // },
            if (message.chatMessageType != ChatMessageType.NOTIFICATION) ...{
              Container(
                margin: message.senderID != currentUser.id
                    ? const EdgeInsets.only(top: 10, left: 2)
                    : const EdgeInsets.only(top: 10),
                child: FittedBox(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   DateFormat.jm().format(message.dateTime!),
                      //   style: TextStyle(fontSize: 11),
                      // ),
                      message.isDeleted
                          ? (Validators.differenceHours(message) < 3
                              ? DeletedWidget()
                              : const DeletedForYou())
                          : messageContain(message),
                    ],
                  ),
                ),
              ),
            } else ...{
              NotificationMessage(message: message)
            },

            if (message.senderID == currentUser.id &&
                message.chatMessageType != ChatMessageType.NOTIFICATION)
              Center(
                  child:
                      MessageStatusDot(messageStatus: message.messageStatus!)),
            // if (message.isSender!) ...{
            //   getShareIcon(message),
            // }
          ],
        ),
      ),
    );
  }
}

class MessageStatusDot extends StatelessWidget {
  MessageStatusDot({super.key, required this.messageStatus});
  MessageStatus messageStatus;
  Color dotColor(MessageStatus messageStatus) {
    if (messageStatus == MessageStatus.SENT) {
      return Colors.greenAccent;
    } else if (messageStatus == MessageStatus.SENDING) {
      return Colors.grey;
    } else if (messageStatus == MessageStatus.RECEIVED) {
      return Colors.purple;
    } else {
      return Colors.orange;
    }
  }

  Icon dotIcon(MessageStatus messageStatus) {
    if (messageStatus == MessageStatus.SENT) {
      return const Icon(
        Icons.done,
        size: 8,
      );
    } else if (messageStatus == MessageStatus.SENDING) {
      return const Icon(
        Icons.done,
        size: 8,
      );
    } else if (messageStatus == MessageStatus.RECEIVED) {
      return const Icon(
        Icons.done,
        size: 8,
      );
    } else {
      return const Icon(
        Icons.done,
        size: 8,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 12,
        width: 12,
        margin: const EdgeInsets.only(left: 5),
        decoration: BoxDecoration(
            color: dotColor(messageStatus), shape: BoxShape.circle),
        child: dotIcon(messageStatus));
  }
}

class DeletedWidget extends StatelessWidget {
  DeletedWidget({super.key});
  String notice = "You unsent a message";
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: notice.length * 8,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12, width: 2)),
      child: Center(
        child: Text(notice),
      ),
    );
  }
}

class DeletedForYou extends StatelessWidget {
  const DeletedForYou({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 10,
      width: 10,
      child: Center(
        child: Text(""),
      ),
    );
  }
}

class NotificationMessage extends StatelessWidget {
  NotificationMessage({super.key, required this.message});
  Message message;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(color: Colors.brown.shade200),
      height: size.height * 0.02,
      child: Center(
        child: Text(message.text!),
      ),
    );
  }
}
