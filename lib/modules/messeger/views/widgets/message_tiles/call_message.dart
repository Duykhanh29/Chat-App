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
    if (message.chatMessageType == ChatMessageType.CALL) {
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
    return GestureDetector(
      onLongPress: () {
        if (message.senderID == currentUser.id) {
          controller.changeIsChoose();
          controller.toggleDeleteID(message.idMessage!);
        }
      },
      child: Container(
        decoration: BoxDecoration(
            color: Color.fromARGB(255, 102, 113, 114),
            borderRadius: BorderRadius.circular(23)),
        width: MediaQuery.of(context).size.width * 0.4,
        height: 60,
        padding: const EdgeInsets.all(15),
        child: FittedBox(
          child: Row(
            children: [
              const Icon(
                Icons.call_outlined,
                size: 10,
              ),
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
      ),
    );
  }
}
