import 'dart:io';

import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/modules/messeger/views/widgets/chatting_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoViewPage extends StatefulWidget {
  VideoViewPage(
      {Key? key,
      required this.path,
      required this.fileName,
      required this.messageData,
      required this.messageStatus,
      required this.sender})
      : super(key: key);
  final String path;
  final String fileName;
  MessageData messageData;
  MessageStatus messageStatus;
  User? sender;
  @override
  _VideoViewPageState createState() => _VideoViewPageState();
}

class _VideoViewPageState extends State<VideoViewPage> {
  VideoPlayerController? _controller;
  Storage storage = Storage();
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

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
              child: _controller!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : Container(),
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
                                await storage.uploadFile(
                                    widget.path,
                                    widget.fileName,
                                    widget.messageData.idMessageData!,
                                    'videos');
                                String url = await storage.downloadURL(
                                    widget.fileName,
                                    widget.messageData.idMessageData!,
                                    'videos');
                                Message message = Message(
                                    text: url,
                                    chatMessageType: ChatMessageType.VIDEO,
                                    isSeen: false,
                                    messageStatus: widget.messageStatus,
                                    dateTime: Timestamp.now(),
                                    senderID: widget.sender!.id);
                                message.showALlAttribute();
                                controller.sendAMessage(
                                    message, widget.messageData);
                                Get.back();
                                Get.back();
                              },
                              icon: const Icon(Icons.arrow_back)))),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _controller!.value.isPlaying
                        ? _controller!.pause()
                        : _controller!.play();
                  });
                },
                child: CircleAvatar(
                  radius: 33,
                  backgroundColor: Colors.black38,
                  child: Icon(
                    _controller!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
