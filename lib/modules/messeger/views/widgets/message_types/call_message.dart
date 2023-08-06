import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class CallMessage extends StatelessWidget {
  CallMessage(
      {super.key,
      required this.message,
      required this.currentUser,
      required this.idMessageData});
  Message message;
  User currentUser;
  String idMessageData;
  Text getTypeofCall(Message message) {
    if (message.chatMessageType == ChatMessageType.AUDIOCALL ||
        message.chatMessageType == ChatMessageType.MISSEDAUDIOCALL) {
      return const Text(
        "Audio Call",
        style: TextStyle(fontSize: 6),
      );
    }
    return const Text(
      "Video Call",
      style: TextStyle(fontSize: 6),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    double widthSize = MediaQuery.of(context).size.width * 0.4;
    return GestureDetector(
        onLongPress: () {
          if (message.senderID == currentUser.id) {
            controller.toggleDeleteID(message.idMessage!);
            controller.changeIsChoose();
          }
        },
        child: showContent(widthSize));
  }

  Widget showContent(double widthSize) {
    return Container(
      decoration: BoxDecoration(
          color: Color.fromARGB(255, 116, 126, 126),
          borderRadius: BorderRadius.circular(23)),
      width: widthSize,
      height: 60,
      padding: const EdgeInsets.all(15),
      child: FittedBox(
        child: Row(
          children: [
            if (message.chatMessageType == ChatMessageType.AUDIOCALL) ...{
              const Icon(
                Icons.call_outlined,
                size: 10,
              )
            } else if (message.chatMessageType ==
                ChatMessageType.VIDEOCALL) ...{
              const Icon(
                Icons.video_call_outlined,
                size: 10,
              )
            } else if (message.chatMessageType ==
                ChatMessageType.MISSEDAUDIOCALL) ...{
              if (message.senderID == currentUser.id) ...{
                const Icon(
                  Icons.add_ic_call_outlined,
                  size: 10,
                ),
              } else ...{
                const Icon(
                  Icons.add_ic_call_outlined,
                  size: 10,
                  color: Colors.redAccent,
                ),
              }
            } else ...{
              if (message.senderID == currentUser.id) ...{
                const Icon(
                  Icons.missed_video_call_outlined,
                  size: 10,
                ),
              } else ...{
                const Icon(
                  Icons.missed_video_call_outlined,
                  size: 10,
                  color: Colors.redAccent,
                ),
              }
            },
            const SizedBox(
              width: 6,
            ),
            FittedBox(
              child: Column(
                children: [
                  getTypeofCall(message),
                  const SizedBox(
                    height: 1,
                  ),
                  Text(
                    "${message.longTime}s",
                    style: const TextStyle(fontSize: 4),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
