import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/message_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:clipboard/clipboard.dart';
import 'package:chat_app/utils/helpers/validators.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:chat_app/modules/messeger/views/widgets/components/share_icon.dart';
import 'package:chat_app/modules/messeger/views/widgets/components/reply_msg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chat_app/utils/utils.dart';

class TextMessage extends GetView<MessageController> {
  TextMessage(
      {super.key,
      required this.message,
      required this.currentUser,
      required this.idMessageData});
  User currentUser;
  final Message message;
  String idMessageData;

  Color displayColor(bool isSearchGetX, Message message) {
    if (isSearchGetX) {
      if (message.isSearch) {
        return Colors.deepOrange;
      } else {
        if (message.senderID != currentUser.id) {
          return const Color.fromARGB(255, 131, 221, 244);
        } else {
          return Colors.blueAccent;
        }
      }
    } else {
      if (message.senderID != currentUser.id) {
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
    print("In text message\n");
    message.showALlAttribute();
    print("And reccent User: \n");
    currentUser.showALlAttribute();
    Message? replyMessage;
    if (message.isReply) {
      replyMessage = controller.findMessageFromIdAndUser(
          message.idReplyText!, message.replyToUserID!, idMessageData);
      print(
          "New Value at ${message.idMessage}: ID: ${replyMessage.idMessage} text: ${replyMessage.text} type: ${replyMessage.chatMessageType}");
    }
    return Validators.isUrl(message.text!)
        ? Obx(() {
            return LinkURL(
              color: getColor(controller.isSearch.value, message),
              controller: controller,
              currentUser: currentUser,
              idMessageData: idMessageData,
              message: message,
              replyMessage: replyMessage,
            );
          })
        : Obx(() => TextMsg(
              color: getColor(controller.isSearch.value, message),
              controller: controller,
              currentUser: currentUser,
              idMessageData: idMessageData,
              message: message,
              replyMessage: replyMessage,
            ));
  }
}

class LinkURL extends StatefulWidget {
  LinkURL(
      {super.key,
      required this.currentUser,
      required this.idMessageData,
      required this.message,
      required this.replyMessage,
      required this.controller,
      required this.color});
  User currentUser;
  final Message message;
  String idMessageData;
  Message? replyMessage;
  MessageController controller;

  Color color;

  @override
  State<LinkURL> createState() => _LinkURLState();
}

class _LinkURLState extends State<LinkURL> {
  String imageURL = '';
  String title = '';
  Future getLinkPreview() async {
    http.Response response = await http.get(Uri.parse(widget.message.text!));
    if (response.statusCode == 200) {
      dom.Document document = parser.parse(response.body);
      dom.Element? ogImage =
          document.querySelector('meta[property="og:image"]');
      dom.Element? ogTitle =
          document.querySelector('meta[property="og:title"]');
      String domain = await getDomain(widget.message.text!);
      if (mounted) {
        setState(() {
          setState(() {
            imageURL = ogImage?.attributes['content'] ?? '';
            title = ogTitle?.attributes['content'] ?? '';
            if (title == '') {
              title = domain;
            }
          });
        });
      }
    }
  }

  Future<String> getDomain(String url) async {
    var uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      var domain = uri.host;
      return domain.startsWith('www.') ? domain.substring(4) : domain;
    }
    return '';
  }

  @override
  void dispose() {
    // setState(() {
    //   imageURL = '';
    //   title = '';
    // });
    // TODO: implement dispose
    super.dispose();
  }

  PreviewData? datas;
  Future test(String url) async {
    final response = await http.get(Uri.parse(url));
    final document = html.parse(response.body);
    final metaElements = document.getElementsByTagName('meta');
    final imageUrl = metaElements
        .where((element) =>
            element.attributes['property'] == 'og:image' ||
            element.attributes['name'] == 'og:image')
        .map((element) => element.attributes['content'])
        .firstWhere((element) => element != null, orElse: () => null);

    print(imageUrl);
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    getLinkPreview();
  }

  double size = 220;
  @override
  Widget build(BuildContext context) {
    if (widget.message.isReply) {
      size = 300;
    } else {
      size = 220;
    }
    return Container(
      // height: widget.message.isRepy ? 300 : 300,
      constraints: BoxConstraints(
        //   maxWidth: MediaQuery.of(context).size.width * 0.85,
        maxHeight: widget.message.isReply ? 300 : 220,
      ),
      width: MediaQuery.of(context).size.width * 0.75,
      // decoration: BoxDecoration(color: Colors.brown),
      child: Column(
        mainAxisAlignment: widget.message.senderID != widget.currentUser.id
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: widget.message.senderID != widget.currentUser.id
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          if (widget.message.isReply) ...{
            BuildReplyMessage(
                currentUser: widget.currentUser,
                replyMessage: widget.replyMessage!,
                replyUserID: widget.message.replyToUserID!)
          },
          Flexible(
            child: Row(
              mainAxisAlignment:
                  widget.message.senderID != widget.currentUser.id
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
              crossAxisAlignment:
                  widget.message.senderID != widget.currentUser.id
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
              children: [
                if (widget.message.senderID == widget.currentUser.id) ...{
                  SharedIcon(size: size),
                  const SizedBox(
                    width: 10,
                  ),
                },
                BodyCard(
                    currentUser: widget.currentUser,
                    imageURL: imageURL,
                    message: widget.message,
                    title: title),
                if (widget.message.senderID != widget.currentUser.id) ...{
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

class BodyCard extends StatelessWidget {
  BodyCard(
      {super.key,
      required this.currentUser,
      required this.imageURL,
      required this.message,
      required this.title});
  User currentUser;
  Message message;
  String imageURL, title;
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    return GestureDetector(
      onLongPress: () {
        if (message.senderID == currentUser.id) {
          controller.toggleDeleteID(message.idMessage!);
          controller.changeIsChoose();
        }
      },
      onTap: () async {
        await launchUrl(Uri.parse(message.text!));
      },
      child: Container(
        constraints: const BoxConstraints(maxHeight: 220),
        width: MediaQuery.of(context).size.width * 0.6,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
            border: Border.all(color: Colors.black54)
            //   color: Colors.yellow,
            ),
        child: imageURL == "" || title == ""
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // if (imageURL == "" || title == "") ...{

                  // } else ...{
                  Container(
                    constraints: const BoxConstraints(maxHeight: 60),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.red, Colors.red],
                          end: Alignment.bottomCenter,
                          begin: Alignment.topCenter),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Center(
                      child: Text(
                        message.text!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: const TextStyle(
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                  imageURL == ""
                      ? Utils.showCacheImage(
                          url:
                              "https://www.pulsecarshalton.co.uk/wp-content/uploads/2016/08/jk-placeholder-image.jpg",
                          height: 110,
                          width: 160)
                      : Validators.isSVG(imageURL)
                          ? Utils.showSVGImage(
                              url: imageURL, height: 110, width: 260)
                          : Utils.showCacheImage(
                              url: imageURL, height: 110, width: 260),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.cyanAccent, Colors.cyanAccent],
                          end: Alignment.bottomCenter,
                          begin: Alignment.topCenter),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    height: 48,
                    // constraints:
                    //     const BoxConstraints(maxHeight: 48),
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ),
                  //  }
                ],
              ),
      ),
    );
  }
}

// ignore: must_be_immutable
class TextMsg extends StatelessWidget {
  TextMsg(
      {super.key,
      required this.currentUser,
      required this.idMessageData,
      required this.message,
      required this.replyMessage,
      required this.controller,
      required this.color});
  User currentUser;
  final Message message;
  String idMessageData;
  Message? replyMessage;
  MessageController controller;

  Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
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
                replyUserID: message.replyToUserID!)
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: color,
                borderRadius: message.senderID != currentUser.id
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
    );
  }
}
