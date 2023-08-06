import 'dart:io';

import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/chatting_page.dart';
import 'package:chat_app/service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CameraViewPage extends StatelessWidget {
  CameraViewPage(
      {Key? key,
      required this.path,
      required this.fileName,
      required this.messageData,
      required this.messageStatus,
      required this.sender});
  final String path;
  final String fileName;
  MessageData messageData;
  MessageStatus messageStatus;
  User? sender;
  Storage storage = Storage();
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              icon: Icon(
                Icons.crop_rotate,
                size: 27,
              ),
              onPressed: () {}),
          IconButton(
              icon: Icon(
                Icons.emoji_emotions_outlined,
                size: 27,
              ),
              onPressed: () {}),
          IconButton(
              icon: Icon(
                Icons.title,
                size: 27,
              ),
              onPressed: () {}),
          IconButton(
              icon: Icon(
                Icons.edit,
                size: 27,
              ),
              onPressed: () {}),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 150,
              child: Image.file(
                File(path),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                color: Colors.black38,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: TextFormField(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                  maxLines: 6,
                  minLines: 1,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Add Caption....",
                      prefixIcon: Icon(
                        Icons.add_photo_alternate,
                        color: Colors.white,
                        size: 27,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                      suffixIcon: CircleAvatar(
                          radius: 27,
                          backgroundColor: Colors.tealAccent[700],
                          child: IconButton(
                              onPressed: () async {
                                await storage.uploadFile(path, fileName,
                                    messageData.idMessageData!, 'images');
                                String url = await storage.downloadURL(fileName,
                                    messageData.idMessageData!, 'images');
                                Message message = Message(
                                    text: url,
                                    chatMessageType: ChatMessageType.IMAGE,
                                    isSeen: false,
                                    messageStatus: messageStatus,
                                    dateTime: Timestamp.now(),
                                    senderID: sender!.id);
                                message.showALlAttribute();
                                controller.sendAMessage(message, messageData);
                                // Get.offUntil(
                                //   GetPageRoute(
                                //       page: () => ChattingPage(),
                                //       settings: RouteSettings(
                                //           arguments: messageData)),
                                //   (route) =>
                                //       route.settings.name != '/chattingPage',
                                // );
                                Get.back();
                                Get.back();
                              },
                              icon: const Icon(
                                Icons.telegram_outlined,
                                color: Colors.blue,
                              )))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
