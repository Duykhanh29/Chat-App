import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';

class BuildReplyMessageInput extends StatelessWidget {
  const BuildReplyMessageInput(
      {super.key, required this.message, this.user, required this.currentUser});
  final Message message;
  final User? user;
  final User? currentUser;
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9, maxHeight: 80),
      height: 80,
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(24),
        ),
      ),
      child: ReplyMessageWidgetInput(
          message: message, user: user!, currentUser: currentUser),
    );
  }
}

class ReplyMessageWidgetInput extends StatelessWidget {
  const ReplyMessageWidgetInput(
      {super.key, required this.message, this.user, required this.currentUser});
  final Message message;
  final User? user;
  final User? currentUser;
  Widget getReplyMessage(Message message) {
    if (message.chatMessageType == ChatMessageType.AUDIO) {
      return const Text("Audio", style: TextStyle(color: Colors.black54));
    } else if (message.chatMessageType == ChatMessageType.VIDEO) {
      return const Text("Video", style: TextStyle(color: Colors.black54));
    } else if (message.chatMessageType == ChatMessageType.VIDEOCALL ||
        message.chatMessageType == ChatMessageType.CALL) {
      return const Text("Call", style: TextStyle(color: Colors.black54));
    } else if (message.chatMessageType == ChatMessageType.IMAGE) {
      return Container(
        height: 35,
        child: Image.network(
          message.text!,
          fit: BoxFit.fill,
        ),
      );
    } else if (message.chatMessageType == ChatMessageType.EMOJI) {
      return const Text("EMOJI", style: TextStyle(color: Colors.black54));
    } else if (message.chatMessageType == ChatMessageType.GIF) {
      return const Text("GIF", style: TextStyle(color: Colors.black54));
    } else if (message.chatMessageType == ChatMessageType.FILE) {
      return const Text("FILE", style: TextStyle(color: Colors.black54));
    } else if (message.chatMessageType == ChatMessageType.LOCATION) {
      return const Text("LOCATION", style: TextStyle(color: Colors.black54));
    } else {
      return Text(message.text!,
          style: const TextStyle(color: Colors.black54),
          overflow: TextOverflow.ellipsis);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          //  height: MediaQuery.of(context).size.height * 0.8,
          color: Colors.green,
          width: 4,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 8,
              ),
              Container(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        message.senderID != currentUser!.id
                            ? user!.name!
                            : currentUser!.name!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    // if (!message.isRepy) ...{
                    IconButton(
                        onPressed: () {
                          controller.changeisReply();
                          controller.resetReplyMessage();
                        },
                        icon: const Icon(Icons.close, size: 16))
                    // }
                  ],
                ),
              ),
              const SizedBox(height: 2),
              getReplyMessage(message),
            ],
          ),
        ),
      ],
    );
  }
}
