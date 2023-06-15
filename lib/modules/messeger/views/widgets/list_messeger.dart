import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/a_user_online.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'a_chat.dart';

class ListMesseger extends GetView<MessageController> {
  const ListMesseger({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    List<MessageData> listMessageData = controller.listMessageData.value;
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
            print("OBX 1");
            int size = controller.searchListMessageData.length;
            List<User> listUser = [];
            return controller
                    .getListMessageData(controller.searchListMessageData)
                    .isEmpty
                ? ListView.separated(
                    itemBuilder: (context, index) {
                      return AUserOnline(
                          receiver: controller.searchListUser[index]);
                    },
                    separatorBuilder: (context, index) => const Divider(
                          color: Colors.black26,
                          height: 2,
                        ),
                    itemCount: controller.searchListUser.length)
                : ListView.separated(
                    itemBuilder: (context, index) {
                      return AChat(
                        messageData: controller.getListMessageData(
                            controller.searchListMessageData)[index],
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(
                          color: Colors.black26,
                          height: 2,
                        ),
                    itemCount: controller
                        .getListMessageData(controller.searchListMessageData)
                        .length);
          },
        ),
      ),
    );
  }
}
