import 'package:photo_view/photo_view.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ImageMessage extends StatelessWidget {
  ImageMessage({super.key, required this.message});
  Message message;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width * 0.55,
        height: MediaQuery.of(context).size.width * 0.35,
        child: GestureDetector(
          onTap: () {
            Get.to(() => Scaffold(
                  appBar: AppBar(
                    actions: [
                      IconButton(
                          onPressed: () {
                            print("Download photo");
                          },
                          icon: const Icon(Icons.download_outlined))
                    ],
                  ),
                  body: Container(
                      child: PhotoView(
                    imageProvider: NetworkImage(message.text!),
                    backgroundDecoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  )),
                ));
          },
          child: Image.network(
            message.text!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Text("Error");
            },
          ),
        ));
  }
}
