import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageTile extends GetView<MessageController> {
  MessageTile({super.key, required this.message, required this.user});
  Message message;
  User user;
  Widget messageContain(Message message) {
    if (message.chatMessageType == ChatMessageType.AUDIO) {
      return AudioMessage(message: message);
    } else if (message.chatMessageType == ChatMessageType.VIDEO) {
      return VideoMessage(message: message);
    } else if (message.chatMessageType == ChatMessageType.IMAGE) {
      return ImageMessage(message: message);
    } else {
      return TextMessage(message: message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: ,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            message.isSender! ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (message.isSender!) ...[
            InkWell(
              onTap: () {
                // see profile
                print("see profile");
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  user.urlImage!,
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
          ],
          Container(
            margin: const EdgeInsets.only(top: 10, left: 6),
            child: messageContain(message),
          ),
          if (!message.isSender!)
            Center(
                child: MessageStatusDot(messageStatus: message.messageStatus!))
        ],
      ),
    );
  }
}

class TextMessage extends StatelessWidget {
  const TextMessage({
    super.key,
    required this.message,
  });

  final Message message;
  bool isUrl(String text) {
    // Regular expression pattern to match URLs
    // This pattern matches most common URLs, but may not match all possible URLs
    final urlPattern = RegExp(r'^https?:\/\/[\w\-]+(\.[\w\-]+)+[/#?]?.*$',
        caseSensitive: false, multiLine: false);

    return urlPattern.hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    return isUrl(message.text!)
        ? SizedBox(
            height: 50,
            child: GestureDetector(
              onTap: () {
                launchUrl(Uri.parse("'https://www.youtube.com/'"));
              },
              child: Text(
                'https://www.example.com',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                ),
              ),
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                //   width: MediaQuery.of(context).size.width * 0.7,
                //margin: const EdgeInsets.only(top: 15, left: 15, right: 15),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: message.isSender!
                      ? const Color.fromARGB(255, 131, 221, 244)
                      : Colors.blueAccent,
                  borderRadius: message.isSender!
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
                child: Text(
                  message.text!,
                ),
              ),
            ],
          );
  }
}

class AudioMessage extends StatelessWidget {
  AudioMessage({super.key, required this.message});
  Message message;
  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.only(top: 15, left: 15, right: 15),
      width: MediaQuery.of(context).size.width * 0.55,
      padding: const EdgeInsets.only(right: 10),
      height: 40,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 192, 253, 168),
        borderRadius: message.isSender!
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
          FittedBox(
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.play_arrow,
                color: message.isSender! ? Colors.amberAccent : Colors.red,
              ),
            ),
          ),

          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 2,
                  color: Colors.cyanAccent,
                ),
                Positioned(
                  left: 0,
                  child: Container(
                    height: 8,
                    width: 8,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.deepOrange),
                  ),
                )
              ],
            ),
          ),
          // ),
          const SizedBox(
            width: 5,
          ),
          const Text(
            "0.40",
            style: TextStyle(fontSize: 12),
          )
        ],
      ),
    );
  }
}

class ImageMessage extends StatelessWidget {
  ImageMessage({super.key, required this.message});
  Message message;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.width * 0.3,
        child: GestureDetector(
          onTap: () {
            Get.to(() => Scaffold(
                  appBar: AppBar(),
                  body: Container(
                    child: PhotoView(
                      imageProvider: NetworkImage(message.text!),
                      backgroundDecoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                ));
          },
          child: Image.network(
            message.text!,
            fit: BoxFit.cover,
          ),
        ));
  }
}

class VideoMessage extends StatefulWidget {
  VideoMessage({super.key, required this.message});
  Message message;

  @override
  State<VideoMessage> createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage> {
  VideoPlayerController? _videoController;
  late YoutubePlayerController _youtubePlayerController;
  @override
  void initState() {
    // TODO: implement initState
    // _videoController = VideoPlayerController.asset("assets/videos/video.mp4")
    //   ..initialize().then((value) {
    //     setState(() {});
    //   });
    const url =
        "https://www.youtube.com/watch?v=Zi9To04PO78&list=RDZi9To04PO78&start_radio=1";
    _youtubePlayerController = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(url)!,
        flags: const YoutubePlayerFlags(
            mute: false, loop: false, autoPlay: true, hideControls: false))
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      height: 120,
      child:
          // AspectRatio(
          //     aspectRatio: 1.6,
          //     child:
          // _videoController!.value.isInitialized
          //     ?
          //VideoPlayer(_videoController!)
          // :
          SizedBox(),
      //     YoutubePlayerBuilder(
      //   player: YoutubePlayer(controller: _youtubePlayerController),
      //   builder: (p0, p1) {
      //     return Stack(alignment: Alignment.center, children: [
      //       FittedBox(
      //         child: Container(
      //           decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(10),
      //             border: const Border(
      //               top: BorderSide(width: 1.0, color: Colors.grey),
      //               bottom: BorderSide(width: 1.0, color: Colors.grey),
      //               left: BorderSide(width: 1.0, color: Colors.grey),
      //               right: BorderSide(width: 1.0, color: Colors.grey),
      //             ),
      //           ),
      //           height: 50,
      //           width: 60,
      //           //  child:
      //         ),
      //       ),
      //       // _videoController!.value.isInitialized
      //       //     ?
      //       Container(
      //         height: 30,
      //         width: 30,
      //         alignment: Alignment.center,
      //         decoration: const BoxDecoration(
      //             shape: BoxShape.circle, color: Colors.blue),
      //         child: GestureDetector(
      //           child: FittedBox(
      //             child: GestureDetector(
      //               onTap: () {
      //                 print("Play video");
      //                 if (_youtubePlayerController.value.isPlaying) {
      //                   _youtubePlayerController.pause();
      //                 } else {
      //                   _youtubePlayerController.play();
      //                 }
      //               },
      //               child: const Icon(
      //                 Icons.play_arrow,
      //                 size: 20,
      //               ),
      //             ),
      //           ),
      //         ),
      //       )
      //     ]);
      //   },
      // )

      // : const Center(
      //     child: CircularProgressIndicator(),
      //   ),
      //    ],
      //    ),
      //   ),
    );
  }
}

class MessageStatusDot extends StatelessWidget {
  MessageStatusDot({super.key, required this.messageStatus});
  MessageStatus messageStatus;
  Color dotColor(MessageStatus messageStatus) {
    if (messageStatus == MessageStatus.SENT) {
      return Colors.greenAccent;
    } else if (messageStatus == MessageStatus.SENDING) {
      return Colors.grey;
    } else if (messageStatus == MessageStatus.RECEIVED) {
      return Colors.purple;
    } else {
      return Colors.orange;
    }
  }

  Icon dotIcon(MessageStatus messageStatus) {
    if (messageStatus == MessageStatus.SENT) {
      return const Icon(
        Icons.done,
        size: 8,
      );
    } else if (messageStatus == MessageStatus.SENDING) {
      return const Icon(
        Icons.done,
        size: 8,
      );
    } else if (messageStatus == MessageStatus.RECEIVED) {
      return const Icon(
        Icons.done,
        size: 8,
      );
    } else {
      return const Icon(
        Icons.done,
        size: 8,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 12,
        width: 12,
        margin: const EdgeInsets.only(left: 5),
        decoration: BoxDecoration(
            color: dotColor(messageStatus), shape: BoxShape.circle),
        child: dotIcon(messageStatus));
  }
}
