import 'package:chat_app/data/common/methods.dart';
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
  double size = 60;

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
    final listUser = controller.relatedUserToCurrentUser.value;
    final user = CommonMethods.getUserFromID(listUser, message.senderID);
    if (message.isReply) {
      size = 145;
    } else {
      size = 65;
    }
    Message? replyMessage;
    if (message.isReply) {
      replyMessage = controller.findMessageFromIdAndUser(
          message.idReplyText!, message.replyToUserID!, idMessageData);
      print(
          "New Value at ${message.idMessage}: ID: ${replyMessage.idMessage} text: ${replyMessage.text} type: ${replyMessage.chatMessageType}");
    }

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(255, 148, 144, 143)),
      height: size,
      width: MediaQuery.of(context).size.width * 0.45,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (message.isReply) ...{
            BuildReplyMessage(
                currentUser: currentUser,
                replyMessage: replyMessage!,
                replyUserID: message.replyToUserID!)
          },
          GestureDetector(
            onTap: () async {
              final List<String> list = message.text!.split(",");
              print("Print llist\n");
              for (var element in list) {
                print(element);
              }
              var latitude = double.parse(list.first);
              var longitude = double.parse(list.last);
              await openGoogleMap(latitude, longitude);
            },
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
    );
  }
}
