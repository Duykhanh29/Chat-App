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
    } else if (message.chatMessageType == ChatMessageType.TEXT) {
      return TextMessage(message: message);
    } else {
      return CallMessage(message: message);
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
            child: FittedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   DateFormat.jm().format(message.dateTime!),
                  //   style: TextStyle(fontSize: 11),
                  // ),
                  messageContain(message),
                ],
              ),
            ),
          ),
          if (!message.isSender!)
            Center(
                child: MessageStatusDot(messageStatus: message.messageStatus!))
        ],
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
