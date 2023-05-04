import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/message_tiles/call_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/message_tiles/audio_message.dart';
import '../widgets/message_tiles/video_message.dart';
import '../widgets/message_tiles/image_message.dart';
import '../widgets/message_tiles/text_message.dart';
import 'package:intl/intl.dart';
import 'package:swipe_to/swipe_to.dart';

class MessageTile extends GetView<MessageController> {
  MessageTile({super.key, required this.message, required this.user});
  Message message;
  User user;
  final focusNode = FocusNode();
  Widget messageContain(Message message) {
    if (message.chatMessageType == ChatMessageType.AUDIO) {
      return AudioMessage(message: message, user: user);
    } else if (message.chatMessageType == ChatMessageType.VIDEO) {
      return VideoMessage(message: message, user: user);
    } else if (message.chatMessageType == ChatMessageType.IMAGE) {
      return ImageMessage(message: message, user: user);
    } else if (message.chatMessageType == ChatMessageType.TEXT) {
      return TextMessage(message: message, user: user);
    } else {
      return CallMessage(message: message, user: user);
    }
  }

  Widget getShareIcon(Message message) {
    if (message.chatMessageType == ChatMessageType.AUDIO) {
      return Container(
        height: 40,
        width: 30,
        child: Center(
          child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.share_rounded,
                color: Colors.blue,
              )),
        ),
      );
    } else if (message.chatMessageType == ChatMessageType.VIDEO) {
      return Container(
        height: 130,
        width: 30,
        child: Center(
          child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.share_rounded,
                color: Colors.blue,
              )),
        ),
      );
    } else if (message.chatMessageType == ChatMessageType.IMAGE) {
      return Container(
        height: double.infinity * 0.35,
        width: 30,
        child: Center(
          child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.share_rounded,
                color: Colors.blue,
              )),
        ),
      );
    } else if (message.chatMessageType == ChatMessageType.TEXT) {
      return Container(
        height: 50,
        width: 30,
        child: Center(
          child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.share_rounded,
                color: Colors.blue,
              )),
        ),
      );
    } else {
      return Container(
        height: 70,
        width: 30,
        child: Center(
          child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.share_rounded,
                color: Colors.blue,
              )),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    return SwipeTo(
      onRightSwipe: () {
        if (!message.isDeleted) {
          // if (!message.isSender!) {
          //   print('Test 2');
          //   print(
          //       'Id: ${message.idMessage} and text: ${message.text} and type: ${message.chatMessageType} isSender: ${message.isSender}');
          //   controller.changeReplyMessage(message, User());
          //   controller.changeisReply();
          // } else {
          print('Test 2');
          print(
              'Id: ${message.idMessage} and text: ${message.text} and type: ${message.chatMessageType} isSender: ${message.isSender}');
          controller.changeReplyMessage(message, user);
          controller.changeisReply();
          //  }
        }
      },
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: message.isSender!
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
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
            // if (!message.isSender!) ...{
            //   getShareIcon(message),
            // },
            Container(
              margin: const EdgeInsets.only(top: 10, left: 6),
              child: FittedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   DateFormat.jm().format(message.dateTime!),
                    //   style: TextStyle(fontSize: 11),
                    // ),
                    message.isDeleted
                        ? controller.differenceHours(message) < 3
                            ? DeletedWidget()
                            : const DeletedForYou()
                        : messageContain(message),
                  ],
                ),
              ),
            ),
            if (!message.isSender!)
              Center(
                  child:
                      MessageStatusDot(messageStatus: message.messageStatus!)),
            // if (message.isSender!) ...{
            //   getShareIcon(message),
            // }
          ],
        ),
      ),
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

class DeletedWidget extends StatelessWidget {
  DeletedWidget({super.key});
  String notice = "You unsent a message";
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: notice.length * 8,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12, width: 2)),
      child: Center(
        child: Text(notice),
      ),
    );
  }
}

class DeletedForYou extends StatelessWidget {
  const DeletedForYou({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 10,
      width: 10,
      child: Center(
        child: Text(""),
      ),
    );
  }
}

class SharedIcon extends StatelessWidget {
  SharedIcon({super.key, required this.size});
  double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: size,
      child: Center(
        child: InkWell(
          splashColor: Colors.red,
          highlightColor: Colors.cyan,
          onTap: () {},
          child: Container(
            width: 30,
            height: 30,
            decoration:
                const BoxDecoration(shape: BoxShape.circle, color: Colors.grey),
            child: const Center(
              child: Icon(
                Icons.share_rounded,
                color: Colors.blue,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BuildReplyMessage extends StatelessWidget {
  const BuildReplyMessage(
      {super.key, this.replyUser, required this.replyMessage});
  final User? replyUser;
  final Message replyMessage;
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.55, maxHeight: 90),
      height: 80,
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(24),
        ),
      ),
      child: ReplyMessageWidget(
        replyMessage: replyMessage,
        replyUser: replyUser!,
      ),
    );
  }
}

class ReplyMessageWidget extends StatelessWidget {
  const ReplyMessageWidget(
      {super.key, this.replyUser, required this.replyMessage});
  final User? replyUser;
  final Message replyMessage;
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
    } else {
      //if (message.isRepy) {
      return Text("message.text",
          style: const TextStyle(
              color: Colors.black54, overflow: TextOverflow.ellipsis));
      // }
      // return Text(message.text!,
      //     style: const TextStyle(color: Colors.black54),
      //     overflow: TextOverflow.ellipsis);
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
                    if (replyMessage.isSender!) ...{
                      Expanded(
                        child: Text(
                          replyUser!.name!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    },

                    // IconButton(
                    //     onPressed: () {
                    //       controller.changeisReply();
                    //       controller.resetReplyMessage();
                    //     },
                    //     icon: const Icon(Icons.close, size: 16))
                  ],
                ),
              ),
              const SizedBox(height: 2),
              getReplyMessage(replyMessage),
            ],
          ),
        ),
      ],
    );
  }
}

class BuildReplyMessageInput extends StatelessWidget {
  const BuildReplyMessageInput({super.key, required this.message, this.user});
  final Message message;
  final User? user;
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9, maxHeight: 75),
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
        message: message,
        user: user!,
      ),
    );
  }
}

class ReplyMessageWidgetInput extends StatelessWidget {
  const ReplyMessageWidgetInput({super.key, required this.message, this.user});
  final Message message;
  final User? user;
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
        height: 40,
        child: Image.network(
          message.text!,
          fit: BoxFit.fill,
        ),
      );
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
                    if (message.isSender!) ...{
                      Expanded(
                        child: Text(
                          user!.name!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    },
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
