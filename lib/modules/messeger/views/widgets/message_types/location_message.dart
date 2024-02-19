import 'package:chat_app/data/common/methods.dart';
import 'package:chat_app/modules/home/controllers/data_controller.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/message_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:chat_app/modules/messeger/views/widgets/components/share_icon.dart';
import 'package:chat_app/modules/messeger/views/widgets/components/reply_msg.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationMessage extends StatelessWidget {
  LocationMessage(
      {super.key,
      required this.message,
      required this.currentUser,
      required this.idMessageData});
  User currentUser;
  final Message message;
  String idMessageData;

  Future openGoogleMap(double latitude, double longitude) async {
    // try {
    final String URL =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(URL))) {
      await launchUrl(Uri.parse(URL));
    } else {
      print("Can not open google map");
    }
    // } catch (e) {
    // print("An error occured: $e");
    // }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    final dataController = Get.find<DataController>();
    final listAllUser = dataController.listAllUser.value;
    User? sender = CommonMethods.getUserFromID(listAllUser, message.senderID);
    final listUser = controller.relatedUserToCurrentUser.value;
    final user = CommonMethods.getUserFromID(listUser, message.senderID);
    double size = 65;
    double size2 = 60;
    if (message.isReply != null &&
        message.isReply! &&
        (message.isFoward != null && message.isFoward)) {
      size = 155;
      size2 = 75;
    } else if (message.isReply != null && message.isReply!) {
      size = 145;
      size2 = 65;
    } else if (message.isFoward != null && message.isFoward) {
      size = 80;
      size2 = 80;
    } else {
      size = 70;
      size2 = 65;
    }
    Message? replyMessage;
    if (message.isReply != null && message.isReply!) {
      replyMessage = controller.findMessageFromIdAndUser(
          message.idReplyText!, message.replyToUserID!, idMessageData);
      print(
          "New Value at ${message.idMessage}: ID: ${replyMessage.idMessage} text: ${replyMessage.text} type: ${replyMessage.chatMessageType}");
    }
    return Container(
      height: size,
      width: MediaQuery.of(context).size.width * 0.65,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (message.isReply != null && message.isReply!) ...{
            BuildReplyMessage(
                currentUser: currentUser,
                replyMessage: replyMessage!,
                replyUserID: message.replyToUserID!)
          },
          Flexible(
            child: Row(
              mainAxisAlignment: message.senderID != currentUser.id
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              crossAxisAlignment: message.senderID != currentUser.id
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                if (message.senderID == currentUser.id) ...{
                  SharedIcon(size: size, message: message),
                  const SizedBox(
                    width: 10,
                  ),
                },
                Container(
                  height: size2,
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (message.isFoward != null && message.isFoward) ...{
                        Center(
                          child: Text(
                            "${sender!.name} forwarded a message",
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        const SizedBox(
                          height: 1,
                        )
                      },
                      Container(
                        height: 65,
                        width: MediaQuery.of(context).size.width * 0.45,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color.fromARGB(255, 148, 144, 143)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Center(
                              child: Icon(
                                Icons.telegram,
                                color: Colors.blue,
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text(
                                  "Location",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  user!.name ?? "No name",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                if (message.senderID != currentUser.id) ...{
                  const SizedBox(
                    width: 10,
                  ),
                  SharedIcon(size: size, message: message)
                }
              ],
            ),
          ),
        ],
      ),
    );
  }
}
