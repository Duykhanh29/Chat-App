import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/chatting_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AChat extends StatelessWidget {
  MessageData messageData;
  Text displayTime(DateTime dateTime) {
    if (dateTime.day.compareTo(DateTime.now().day) == 0) {
      return Text(DateFormat.jm().format(dateTime));
    } else if (dateTime.day.compareTo(DateTime.now().day - 1) == 0) {
      return const Text("Yesterday");
    }
    return Text(DateFormat.EEEE().format(dateTime));
  }

  Widget showState(MessageData data) {
    if (data.listMessages!.last.isSender!) {
      if (data.listMessages!.last.messageStatus == MessageStatus.SEEN) {
        return const Icon(Icons.done_outline);
      } else if (data.listMessages!.last.messageStatus ==
          MessageStatus.RECEIVED) {
        return const Icon(Icons.done_all);
      } else if (data.listMessages!.last.messageStatus == MessageStatus.SENT) {
        return const Icon(Icons.done);
      }
      return const Icon(Icons.send_rounded);
    } else {
      if (data.listMessages!.last.isSeen!) {
        return const Icon(
          Icons.circle,
          size: 12,
          color: Colors.red,
        );
      }
      return const Text("");
    }
  }

  Text displayMessage(MessageData data) {
    if (data.listMessages!.last.isSender!) {
      if (data.listMessages!.last.isSeen!) {
        return Text(
          data.listMessages!.last.text!,
          overflow: TextOverflow.ellipsis,
        );
      }
    }
    return Text(
      data.listMessages!.last.text!,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
    );
  }

  AChat({super.key, required this.messageData});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    // TODO: implement build
    int length = messageData.listMessages!.length;
    var list = messageData.listMessages;
    return Dismissible(
      key: Key(messageData.user!.id!),
      //onDismissed: ,
      direction: DismissDirection.endToStart,

      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.blue,
        ),
      ),
      child: ListTile(
        onTap: () {
          Get.to(() => ChattingPage(), arguments: messageData);
        },
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(messageData.user!.urlImage!),
          child: GestureDetector(
            onTap: () {
              print("Oke nha");
            },
          ),
        ),
        subtitle: displayMessage(messageData),
        title: Text(messageData.user!.name!),
        trailing: FittedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              displayTime(list!.last.dateTime!),
              showState(messageData)
            ],
          ),
        ),
        //  ),
      ),
    );
  }
}
