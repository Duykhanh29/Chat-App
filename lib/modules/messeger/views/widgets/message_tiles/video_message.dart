import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/message_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:chat_app/utils/helpers/validators.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/modules/messeger/views/widgets/components/share_icon.dart';
import 'package:chat_app/modules/messeger/views/widgets/components/reply_msg.dart';

class VideoMessage extends StatelessWidget {
  VideoMessage(
      {super.key,
      required this.message,
      required this.currentUser,
      required this.idMessageData});
  Message message;
  User currentUser;
  String idMessageData;

  double size = 130;
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
      size = 220;
    } else {
      size = 140;
    }
    print("seiz: l$size");
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      //   decoration: BoxDecoration(color: Colors.red),
      height: size,
      child: Column(
        mainAxisAlignment: message.senderID != currentUser.id
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: message.senderID != currentUser.id
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          if (message.isReply) ...{
            BuildReplyMessage(
                currentUser: currentUser,
                replyMessage: replyMessage!,
                replyUserID: message.replyToUserID)
          },
          Flexible(
            child: Row(
              mainAxisAlignment: message.senderID != currentUser.id
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.end,
              children: [
                if (message.senderID == currentUser.id) ...{
                  SharedIcon(size: size),
                  const SizedBox(
                    width: 10,
                  ),
                },
                GestureDetector(
                  onLongPress: () {
                    // if (!message.isSender!) {
                    controller.changeIsChoose();
                    controller.toggleDeleteID(message.idMessage!);
                    // }
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 140,
                    child: Validators.isYoutubeUrl(message.text!) == true
                        ? YoutubeVideo(message: message)
                        : VideoPlay(
                            message: message,
                          ),
                  ),
                ),
                if (message.senderID != currentUser.id) ...{
                  const SizedBox(
                    width: 10,
                  ),
                  SharedIcon(size: size)
                }
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlay extends StatefulWidget {
  VideoPlay({super.key, required this.message});
  Message message;
  @override
  State<VideoPlay> createState() => _VideoPlayState();
}

class _VideoPlayState extends State<VideoPlay> {
  late VideoPlayerController controller;
  late Future<void> _initializeVideoPlayerFuture;
  final videoAssets = "assets/videos/video.mp4";
  bool isPlayed = false;
  Duration position = Duration.zero;
  @override
  void initState() {
    // TODO: implement initState
    // loadVideoPlayer();
    // _initializeVideoPlayerFuture = controller.initialize();
    // super.initState();
    //  String file = await rootBundle.loadString('assets/videos/video.mp4');
    controller = VideoPlayerController.network(widget.message.text!)
      ..addListener(() => setState(() {
            position = controller.value.position;
          }))
      ..setLooping(false)
      ..initialize().then((value) {
        if (isPlayed) {
          controller.play();
        }
      });
  }

  void loadVideoPlayer() async {
    final file = await rootBundle.loadString('assets/videos/video.mp4');
    controller = VideoPlayerController.asset(file);
  }

  void playVideo() {
    setState(() {
      if (controller.value.isInitialized) {
        controller.seekTo(position);
      }
      controller.play();
      isPlayed = true;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return controller != null && controller.value.isInitialized
        ? Container(
            alignment: Alignment.topCenter,
            //   color: Colors.yellow,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 1.55,
                  child: VideoPlayer(controller),
                ),
                Positioned.fill(
                    child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => controller.value.isPlaying
                      ? controller.pause()
                      : playVideo(),
                  child: Stack(
                    children: <Widget>[
                      controller.value.isPlaying
                          ? Container()
                          : Container(
                              alignment: Alignment.center,
                              color: Colors.black26,
                              child: const Icon(Icons.play_arrow,
                                  color: Colors.white, size: 40),
                            ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: VideoProgressIndicator(
                          controller,
                          allowScrubbing: true,
                        ),
                      ),
                    ],
                  ),
                ))
              ],
            ),
          )
        : Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.indigo, width: 1)),
            width: MediaQuery.of(context).size.width * 0.6,
            height: 160,
            child: const Center(child: CircularProgressIndicator()),
          );
  }

  Widget buildVideo() => Stack(
        alignment: Alignment.center,
        children: <Widget>[
          buildVideoPlayer(),
          Positioned.fill(child: BasicOverlayWidget(controller: controller)),

          // Stack(
          //   alignment: Alignment.center,
          //   children: [
          //     Container(
          //       height: double.infinity,
          //       width: double.infinity,
          //       child: GestureDetector(
          //         onTap: () {
          //           if (controller.value.isPlaying) {
          //             controller.pause();
          //           } else {
          //             controller.play();
          //           }
          //         },
          //       ),
          //     ),
          //     Container(
          //       height: 30,
          //       width: 30,
          //       alignment: Alignment.center,
          //       decoration: BoxDecoration(
          //           shape: BoxShape.circle,
          //           color: controller.value.isPlaying
          //               ? Colors.grey.withOpacity(0.0)
          //               : Colors.blue),
          //       child:
          //           //  GestureDetector(
          //           //   onTap: () {
          //           //     if (controller.value.isPlaying) {
          //           //       controller.pause();
          //           //     } else {
          //           //       controller.play();
          //           //     }
          //           //   },
          //           //   child:
          //           controller.value.isPlaying
          //               ? Icon(
          //                   Icons.pause,
          //                   size: 20,
          //                   color: Colors.grey.withOpacity(0.0),
          //                 )
          //               : const Icon(
          //                   Icons.play_arrow,
          //                   size: 20,
          //                 ),
          //       //      ),
          //     ),
          //   ],
          // ),
        ],
      );

  Widget buildVideoPlayer() => AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      );
}

class BasicOverlayWidget extends StatelessWidget {
  final VideoPlayerController controller;
  void playVideo() {
    controller.setLooping(false);
    controller.initialize().then((_) {
      controller.play();
    });
  }

  const BasicOverlayWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            controller.value.isPlaying ? controller.pause() : playVideo(),
        child: Stack(
          children: <Widget>[
            buildPlay(),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: buildIndicator(),
            ),
          ],
        ),
      );

  Widget buildIndicator() => VideoProgressIndicator(
        controller,
        allowScrubbing: true,
      );

  Widget buildPlay() => controller.value.isPlaying
      ? Container()
      : Container(
          alignment: Alignment.center,
          color: Colors.black26,
          child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
        );
}

class YoutubeVideo extends StatefulWidget {
  YoutubeVideo({super.key, required this.message});
  Message message;
  @override
  State<YoutubeVideo> createState() => _YoutubeVideoState();
}

class _YoutubeVideoState extends State<YoutubeVideo> {
  late YoutubePlayerController _youtubePlayerController;
  @override
  void dispose() {
    // TODO: implement dispose
    _youtubePlayerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState

    String url = widget.message.text!;
    _youtubePlayerController = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(url)!,
        flags: const YoutubePlayerFlags(
            mute: false, loop: false, autoPlay: false, hideControls: false))
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _youtubePlayerController,
        aspectRatio: 1.6,
      ),
      builder: (p0, p1) {
        return Stack(alignment: Alignment.center, children: [
          FittedBox(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: const Border(
                  top: BorderSide(width: 1.0, color: Colors.grey),
                  bottom: BorderSide(width: 1.0, color: Colors.grey),
                  left: BorderSide(width: 1.0, color: Colors.grey),
                  right: BorderSide(width: 1.0, color: Colors.grey),
                ),
              ),
              height: 50,
              width: 60,
            ),
          ),
          Container(
            height: 30,
            width: 30,
            alignment: Alignment.center,
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: Colors.blue),
            child: GestureDetector(
              child: FittedBox(
                child: GestureDetector(
                  onTap: () {
                    print("Play video");
                    if (_youtubePlayerController.value.isPlaying) {
                      _youtubePlayerController.pause();
                    } else {
                      _youtubePlayerController.play();
                    }
                  },
                  child: const Icon(
                    Icons.play_arrow,
                    size: 20,
                  ),
                ),
              ),
            ),
          )
        ]);
      },
    );
  }
}
