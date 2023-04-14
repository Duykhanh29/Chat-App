import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class VideoCall extends GetView<MessageController> {
  const VideoCall({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Color.fromARGB(255, 136, 179, 253),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 30,
            ),
            const Center(
              child: Text(
                "User Name",
                style: TextStyle(
                    fontSize: 30,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const CircleAvatar(
              backgroundColor: Colors.blue,
              radius: 100,
              child: CircleAvatar(
                radius: 80,
                backgroundImage: NetworkImage(
                    "https://static-images.vnncdn.net/files/publish/2023/2/21/valverde-real-madrid-osasuna-827.jpg"),
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.mic_none_outlined,
                              color: Colors.yellowAccent,
                            ),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.volume_up_outlined,
                              color: Colors.indigoAccent,
                            ),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.videocam_outlined,
                              color: Colors.greenAccent,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.message_outlined,
                              color: Colors.amberAccent,
                            ),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.note,
                              color: Colors.deepOrange,
                            ),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.video_call_outlined,
                              color: Colors.deepPurple,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            InkWell(
              onTap: () {
                Get.back();
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.redAccent),
                  ),
                  const Icon(Icons.call_end_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
