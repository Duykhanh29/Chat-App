import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/user_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'a_chat.dart';
import 'package:chat_app/utils/constants/image_data.dart';

class ListMesseger extends GetView<MessageController> {
  const ListMesseger({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    final authController = Get.find<AuthController>();
    final currentUser = authController.currentUser.value;
    List<MessageData> listMessageData = controller.listMessageData.value;
    final msgDatas = FirebaseFirestore.instance.collection('messageDatas');
    return Flexible(
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 189, 209, 246),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
              scrollbarTheme: ScrollbarThemeData(
                  thumbColor: MaterialStateProperty.all<Color>(Colors.red))),
          child: Scrollbar(
            child: StreamBuilder(
              stream: controller.getAllMsgDataOfCurrentUser(currentUser),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data = snapshot.data;
                  List<MessageData> listMsgData = data!;

                  return Obx(
                    () {
                      // controller.listMessageData.value = listMsgData;
                      // controller.searchListMessageData.value = listMsgData;
                      print("OBX 1");
                      String searchKey = controller.searchKey.value;
                      int size = controller.searchListMessageData.length;
                      List<User> listUser = [];
                      return
                          // controller.listMessageData.value.isEmpty
                          listMsgData.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      const Text("No list chat"),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Center(
                                        child: Image.asset(
                                          ImageData.emptyilst,
                                          width: 100,
                                          height: 100,
                                        ),
                                      )
                                    ])
                              :
                              // searchKey != ""
                              //     ? Center(
                              //         child: Text(searchKey),
                              //       )
                              //     :
                              StreamBuilder<List<MessageData>>(
                                  stream: controller.updateDisplay(
                                      currentUser, searchKey),
                                  builder: (context, snapshot) {
                                    if (snapshot.data == null ||
                                        snapshot.data!.isEmpty) {
                                      return ListView.separated(
                                          itemBuilder: (context, index) {
                                            return UserCard(
                                                receiver: controller
                                                    .searchListUser[index]);
                                          },
                                          separatorBuilder: (context, index) =>
                                              const Divider(
                                                color: Colors.black26,
                                                height: 2,
                                              ),
                                          itemCount:
                                              controller.searchListUser.length);
                                    } else {
                                      List<MessageData> listMsgData =
                                          snapshot.data!;
                                      return ListView.separated(
                                          itemBuilder: (context, index) {
                                            return AChat(
                                              messageData: controller
                                                      .getListMessageData(
                                                          listMsgData)[
                                                  index], // issue at listMsgData
                                            );
                                          },
                                          separatorBuilder: (context, index) =>
                                              const Divider(
                                                color: Colors.black26,
                                                height: 2,
                                              ),
                                          itemCount: controller
                                              .getListMessageData(listMsgData)
                                              .length);
                                    }
                                  },
                                );
                    },
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
