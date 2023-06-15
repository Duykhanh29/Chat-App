import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/message_tile.dart';
import 'package:photo_view/photo_view.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chat_app/service/storage_service.dart';
import 'package:chat_app/modules/messeger/views/widgets/components/share_icon.dart';
import 'package:chat_app/modules/messeger/views/widgets/components/reply_msg.dart';

class ImageMessage extends StatelessWidget {
  ImageMessage(
      {super.key,
      required this.message,
      required this.currentUser,
      required this.idMessageData});
  Message message;
  User currentUser;
  String idMessageData;
  Storage storage = Storage();
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    Message? replyMessage;
    if (message.isRepy) {
      replyMessage = controller.findMessageFromIdAndUser(
          message.idReplyText!, message.replyToUser!, idMessageData);
      print(
          "New Value at ${message.idMessage}: ID: ${replyMessage.idMessage} text: ${replyMessage.text} type: ${replyMessage.chatMessageType}");
    }
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      height: message.isRepy
          ? MediaQuery.of(context).size.width * 0.6
          : MediaQuery.of(context).size.width * 0.35,
      child: Column(
        mainAxisAlignment: message.sender!.id != currentUser.id
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: message.sender!.id != currentUser.id
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          if (message.isRepy) ...{
            BuildReplyMessage(
                currentUser: currentUser,
                replyMessage: replyMessage!,
                replyUser: message.replyToUser!)
          },
          Row(
            mainAxisAlignment: message.sender!.id != currentUser.id
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              if (message.sender!.id == currentUser.id) ...{
                SharedIcon(size: MediaQuery.of(context).size.width * 0.35),
                const SizedBox(
                  width: 15,
                ),
              },
              GestureDetector(
                onLongPress: () {
                  if (message.sender!.id == currentUser.id) {
                    controller.changeIsChoose();
                    controller.toggleDeleteID(message.idMessage!);
                  }
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.55,
                  height: MediaQuery.of(context).size.width * 0.35,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(
                        () => Scaffold(
                          appBar: AppBar(
                            actions: [
                              IconButton(
                                  onPressed: () async {
                                    await storage.downloadFileToLocalDevice(
                                        message.text!, idMessageData, "image");
                                  },
                                  icon: const Icon(Icons.download_outlined))
                            ],
                          ),
                          body: Container(
                            child: PhotoView(
                              imageProvider: NetworkImage(message.text!),
                              backgroundDecoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      message.text!,
                      fit: BoxFit.cover,
                      // errorBuilder: (context, error, stackTrace) {
                      //   return const Text("Error");
                      // },
                    ),
                  ),
                ),
              ),
              if (message.sender!.id != currentUser.id) ...{
                const SizedBox(
                  width: 15,
                ),
                SharedIcon(size: MediaQuery.of(context).size.width * 0.35)
              }
            ],
          ),
        ],
      ),
    );
  }
}
