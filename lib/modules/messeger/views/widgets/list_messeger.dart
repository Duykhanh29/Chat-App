import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'a_chat.dart';

class ListMesseger extends GetView<MessageController> {
  const ListMesseger({super.key});

  @override
  Widget build(BuildContext context) {
    final accountController = Get.find<MessageController>();
    List<MessageData> listMessageData = accountController.listMessageData.value;
    print("size: ${listMessageData.length}");
    return Flexible(
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 189, 209, 246),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Obx(
          () {
            int size = accountController.searchListMessageData.length;
            return ListView.separated(
                itemBuilder: (context, index) {
                  return AChat(
                    messageData: accountController.getListMessageData(
                        accountController.searchListMessageData)[index],
                  );
                },
                separatorBuilder: (context, index) => const Divider(
                      color: Colors.black26,
                      height: 2,
                    ),
                itemCount: accountController
                    .getListMessageData(accountController.searchListMessageData)
                    .length);
          },
        ),
      ),
    );
  }
}
