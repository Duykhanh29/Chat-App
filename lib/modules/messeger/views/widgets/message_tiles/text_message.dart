import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/message_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:clipboard/clipboard.dart';

class TextMessage extends GetView<MessageController> {
  TextMessage({super.key, required this.message, required this.user});
  User user;
  final Message message;
  bool isUrl(String text) {
    // Regular expression pattern to match URLs
    // This pattern matches most common URLs, but may not match all possible URLs
    final urlPattern = RegExp(r'^https?:\/\/[\w\-]+(\.[\w\-]+)+[/#?]?.*$',
        caseSensitive: false, multiLine: false);

    return urlPattern.hasMatch(text);
  }

  Color displayColor(bool isSearchGetX, Message message) {
    if (isSearchGetX) {
      if (message.isSearch) {
        return Colors.deepOrange;
      } else {
        if (message.isSender!) {
          return const Color.fromARGB(255, 131, 221, 244);
        } else {
          return Colors.blueAccent;
        }
      }
    } else {
      if (message.isSender!) {
        return const Color.fromARGB(255, 131, 221, 244);
      } else {
        return Colors.blueAccent;
      }
    }
  }

  Color getColor(bool isSearchGetX, Message message) {
    if (isSearchGetX) {
      if (message.isSearch) {
        return Colors.deepOrange;
      } else {
        return Colors.blue;
      }
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    print("Get text: ${message.text!}");
    Message? replyMessage;
    if (message.isRepy) {
      replyMessage = controller.findMessageFromIdAndUser(
          message.idReplyText!, message.replyToUser!);
      print(
          "New Value at ${message.idMessage}: ID: ${replyMessage.idMessage} text: ${replyMessage.text} type: ${replyMessage.chatMessageType}");
    }
    return isUrl(message.text!)
        ? Obx(
            () => Container(
              height: message.isRepy ? 130 : 50,
              width: message.text!.length * 8,
              child: Column(
                  mainAxisAlignment: message.isSender!
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  crossAxisAlignment: message.isSender!
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    if (message.isRepy) ...{
                      BuildReplyMessage(
                          replyMessage: replyMessage!,
                          replyUser: message.replyToUser!)
                    },
                    GestureDetector(
                      onLongPress: () {
                        if (!message.isSender!) {
                          controller.changeIsChoose();
                          controller.toggleDeleteID(message.idMessage!);
                        }
                      },
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        height: 50,
                        width: message.text!.length * 8,
                        child: GestureDetector(
                          onTap: () {
                            launchUrl(Uri.parse(message.text!));
                          },
                          child: Card(
                            color: Colors.grey,
                            child: Center(
                              child: Text(
                                message.text!,
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: getColor(
                                        controller.isSearch.value, message)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),
          )
        : Obx(
            () => Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                mainAxisAlignment: message.isSender!
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                crossAxisAlignment: message.isSender!
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  if (message.isRepy) ...{
                    BuildReplyMessage(
                        replyMessage: replyMessage!,
                        replyUser: message.replyToUser!)
                  },
                  GestureDetector(
                    onLongPress: () {
                      controller.changeIsChoose();
                      controller.toggleDeleteID(message.idMessage!);
                    },
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: displayColor(controller.isSearch.value, message),
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
                        style: TextStyle(
                            color: controller.searchMessageIndex.value != -1
                                ? Colors.orangeAccent
                                : Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
