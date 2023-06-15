import 'package:chat_app/modules/group/controllers/group_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:chat_app/modules/auth/views/startPage.dart';

class GroupView extends GetView<GroupController> {
  GroupView({super.key});
  final List<String> emoticons = [
    '😊',
    '😂',
    '😍',
    '😢',
    '😡',
    '😱',
    '😴',
    '🤢',
    '🤔',
  ];
  @override
  Widget build(BuildContext context) {
    Get.put(
        GroupController()); // need to consider when it comes to deployment, because of the performnace
    final controller = Get.find<GroupController>();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body:
          // Padding(
          //   padding: const EdgeInsets.all(10),
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       const Text("Group chat"),
          ListView.builder(
        itemBuilder: (context, index) {
          return Text(emoticons[index]);
        },
        itemCount: emoticons.length,
        //     )
        //   ],
        // ),
      ),
    );
  }
}
