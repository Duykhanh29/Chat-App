import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/modules/messeger/views/widgets/components/forward_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SharedIcon extends StatelessWidget {
  SharedIcon({super.key, required this.size, required this.message});
  Message message;
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
          onTap: () {
            Get.to(() => ForwardScreen(message: message));
          },
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
