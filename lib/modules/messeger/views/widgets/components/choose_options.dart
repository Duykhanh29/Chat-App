import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chat_app/service/storage_service.dart';
import 'package:clipboard/clipboard.dart';

class ChooseOptions extends GetView<MessageController> {
  ChooseOptions({super.key, required this.messageData, required this.message});
  MessageData messageData;
  //String id;
  Message message;
  Storage storage = Storage();
  Future showSheet(BuildContext context, MessageController messageController) {
    return showModalBottomSheet(
        context: context,
        builder: (_) {
          return Container(
            height: 200,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 6),
                const Text('Do you want to delete this message'),
                const SizedBox(height: 6),
                if (messageController.differenceHours(message) < 3) ...{
                  Container(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        // Thực hiện hành động xóa vĩnh viễn
                        //   Navigator.pop(context);
                        controller.deleteAMessage(
                            message.idMessage!, messageData);
                        controller.changeIsChoose();
                        Navigator.pop(context);
                      },
                      child: const Text('Unsend for everyone'),
                    ),
                  ),
                  const SizedBox(height: 6),
                },
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      // Thực hiện hành động xóa
                      //   Navigator.pop(context);
                      controller.deleteAMessage(message.idMessage!, messageData,
                          justForYou: true);
                      controller.changeIsChoose();
                      Navigator.pop(context);
                    },
                    child: const Text('Unsend for you'),
                  ),
                ),
                const SizedBox(height: 4),
                const Divider(
                  color: Color.fromARGB(255, 101, 118, 121),
                  height: 1,
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      // Hủy thao tác xóa
                      //   Navigator.pop(context);
                      controller.changeIsChoose();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.blueGrey),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
                onPressed: () {
                  controller.changeIsChoose();
                  controller.changeReplyMessage(message);
                  controller.changeisReply();
                },
                child: const Text("Reply")),
            TextButton(
                onPressed: () async {
                  FlutterClipboard.copy(message.text!).then((value) {
                    return ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Text Copied'),
                      ),
                    );
                  });

                  controller.changeIsChoose();
                },
                child: const Text("Copy")),
            TextButton(
                onPressed: () async {
                  await showSheet(context, controller);
                },
                child: const Text("Unsend")),
            if (message.chatMessageType == ChatMessageType.VIDEO) ...{
              TextButton(
                onPressed: () async {
                  await storage.downloadFileToLocalDevice(
                      message.text!, messageData.idMessageData!, "video");
                },
                child: const Text('Download'),
              ),
            },
            TextButton(
                onPressed: () async {
                  controller.changeIsChoose();
                },
                child: const Text("Cancel")),
          ],
        ),
      ),
    );
  }
}
