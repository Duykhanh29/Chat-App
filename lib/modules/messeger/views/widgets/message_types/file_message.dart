import 'package:chat_app/service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/message_tile.dart';
import 'package:chat_app/modules/messeger/views/widgets/components/share_icon.dart';

class FileMessage extends StatelessWidget {
  FileMessage(
      {super.key,
      required this.message,
      required this.currentUser,
      required this.idMessageData});

  Message message;
  User currentUser;
  String idMessageData;
  double size = 85;
  Storage storage = Storage();
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    Message?
        replyMessage; // this is a reply message to show in the main message
    if (message.isReply) {
      replyMessage = controller.findMessageFromIdAndUser(
          message.idReplyText!, message.replyToUserID!, idMessageData);
      print(
          "New Value at ${message.idMessage}: ID: ${replyMessage.idMessage} text: ${replyMessage.text} type: ${replyMessage.chatMessageType}");
    }
    if (message.isReply) {
      size = 165;
    } else {
      size = 85;
    }
    return Container(
      constraints: BoxConstraints(
        maxHeight: size,
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      child: Flexible(
        child: Row(
          mainAxisAlignment: message.senderID != currentUser.id
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            if (message.senderID == currentUser.id) ...{
              SharedIcon(size: size, message: message),
              const SizedBox(
                width: 15,
              ),
            },
            GestureDetector(
              onLongPress: () {
                // if (!message.isSender!) {
                controller.toggleDeleteID(message.idMessage!);
                controller.changeIsChoose();

                // }
              },
              onTap: () async {
                //      await storage.loadPDFFromFirebase(fileName);
              },
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
                child: Card(
                  child: FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Center(
                          child: Icon(
                            Icons.file_copy_rounded,
                            color: Colors.redAccent,
                          ),
                        ),
                        const Text(
                          "fdafdf",
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (message.senderID != currentUser.id) ...{
              const SizedBox(
                width: 15,
              ),
              SharedIcon(size: size, message: message)
            }
          ],
        ),
      ),
    );
  }
}
