import 'dart:io';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/message_tile.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:chat_app/utils/helpers/validators.dart';
import 'package:chat_app/modules/messeger/views/widgets/components/share_icon.dart';
import 'package:chat_app/modules/messeger/views/widgets/components/reply_msg.dart';

class AudioMessage extends StatefulWidget {
  AudioMessage(
      {super.key,
      required this.message,
      required this.currentUser,
      required this.idMessageData});
  Message message;
  User currentUser;
  String idMessageData;
  @override
  State<AudioMessage> createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage> {
  String audioAssest() {
    if (widget.message.text != "audios/SonTingMTP.mp3") {
      return "";
    }
    return "audios/SonTingMTP.mp3";
  }

  bool isDisposed = false;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  AudioPlayer audioPlayer = AudioPlayer();
  void doNothing() {}

  @override
  void initState() {
    super.initState();
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          if (state == PlayerState.playing) {
            //  duration = audioPlayer.d;
            isPlaying = true;
          } else if (state == PlayerState.paused) {
            isPlaying = false;
          }
          // else {
          //   isPlaying = false;
          //   position = Duration();
          // }
        });
      }
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          duration = newDuration;
        });
      }
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          position = newPosition;
        });
      }
    });
  }

  @override
  void dispose() {
    print("dispose() is called");
    audioPlayer.stop();
    // stopAudio();
    audioPlayer.release();
    super.dispose();
  }

  Future<void> stopAudio() async {
    await audioPlayer.dispose();
  }

  late double size;
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    Message? replyMessage;
    if (widget.message.isReply) {
      replyMessage = controller.findMessageFromIdAndUser(
          widget.message.idReplyText!,
          widget.message.replyToUserID!,
          widget.idMessageData);
      print(
          "New Value at id ${widget.message.idMessage}: ID: ${replyMessage.idMessage} text: ${replyMessage.text} type: ${replyMessage.chatMessageType}");
    }
    if (widget.message.isReply) {
      size = 120;
    } else {
      size = 40;
    }
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      //  padding: const EdgeInsets.only(right: 10),
      height: size,
      child: Column(
          mainAxisAlignment: widget.message.senderID != widget.currentUser.id
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          crossAxisAlignment: widget.message.senderID != widget.currentUser.id
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            if (widget.message.isReply) ...{
              //if (widget.message.isSender!) ...{
              BuildReplyMessage(
                  currentUser: widget.currentUser,
                  replyMessage: replyMessage!,
                  replyUserID: widget.message.replyToUserID!)
              // } else ...{
              //   BuildReplyMessage(message: widget.message)
              // }
            },
            Flexible(
              child: Row(
                mainAxisAlignment:
                    widget.message.senderID != widget.currentUser.id
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                children: [
                  if (widget.message.senderID == widget.currentUser.id) ...{
                    SharedIcon(size: size),
                    const SizedBox(
                      width: 15,
                    ),
                  },
                  GestureDetector(
                    onLongPress: () {
                      // if (!widget.message.isSender!) {
                      controller.changeIsChoose();
                      controller.toggleDeleteID(widget.message.idMessage!);
                      // }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      padding: const EdgeInsets.only(right: 10),
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 192, 253, 168),
                        borderRadius:
                            widget.message.senderID != widget.currentUser.id
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                    bottomRight: Radius.circular(30),
                                  )
                                : const BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                    bottomLeft: Radius.circular(30),
                                  ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //  FittedBox(
                          // child:
                          Container(
                            width: 30,
                            height: double.infinity,
                            child: IconButton(
                              onPressed: () {
                                if (isPlaying) {
                                  setState(() {
                                    isPlaying = false;
                                  });
                                  audioPlayer.pause();
                                } else {
                                  if (widget.message.text ==
                                      "audios/SonTingMTP.mp3") {
                                    audioPlayer.play(
                                        AssetSource(widget.message.text!));
                                  } else {
                                    final filePath = widget.message.text;
                                    final file = File(filePath!);
                                    print("Get path: ${file.path}");
                                    final fileExtension =
                                        path.extension(filePath);
                                    print("Dinh dang:   $fileExtension");
                                    audioPlayer
                                        .play(DeviceFileSource(file.path));
                                  }
                                  setState(() {
                                    isPlaying = true;
                                  });
                                }
                              },
                              icon: Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: widget.message.senderID !=
                                        widget.currentUser.id
                                    ? Colors.amberAccent
                                    : Colors.red,
                              ),
                            ),
                          ),
                          // ),

                          Flexible(
                            child: SizedBox(
                              width: double.infinity,
                              child: Slider(
                                value: position.inSeconds.toDouble(),
                                onChanged: (value) async {
                                  final position =
                                      Duration(seconds: value.toInt());
                                  await audioPlayer.seek(position);

                                  //if audio was paused
                                  await audioPlayer.resume();
                                },
                                min: 0,
                                max: duration.inSeconds.toDouble(),
                              ),
                            ),
                          ),

                          Text(
                            Validators.formatTime(
                                (duration - position).inSeconds),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.message.senderID != widget.currentUser.id) ...{
                    const SizedBox(
                      width: 15,
                    ),
                    SharedIcon(size: size)
                  }
                ],
              ),
            ),
          ]),
    );
  }
}
