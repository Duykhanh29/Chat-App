import 'package:chat_app/data/models/message_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                  ),
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
