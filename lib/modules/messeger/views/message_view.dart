import 'package:chat_app/data/common/menu_items.dart';
import 'package:chat_app/data/common/methods.dart';
import 'package:chat_app/data/models/menu_item.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/friend/controllers/friend_controller.dart';
import 'package:chat_app/modules/messeger/controllers/group_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/chatting_page.dart';
import 'package:chat_app/modules/messeger/views/widgets/ingroup/create_group.dart';
import 'package:chat_app/modules/profile/views/widgets/profile_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import './widgets/list_messeger.dart';
import 'widgets/an_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:chat_app/modules/profile/views/drawer.dart';

class MessageView extends GetView<MessageController> {
  MessageView({super.key});
  var searchController = TextEditingController();
  PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem(
        value: item,
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 18,
              color: Colors.orangeAccent,
            ),
            const SizedBox(
              width: 12,
            ),
            Text(
              item.text!,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      );

  void onSelected(BuildContext context, MenuItem item) {
    switch (item) {
      // case MenuItems.addFriend:
      //   Get.to(() => ProfileView());
      //   break;
      case MenuItems.createGroup:
        Get.to(() => CreateGroup());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("devicePixelRatio ${MediaQuery.of(context).devicePixelRatio}");
    Get.put(MessageController());
    Get.put(GroupController());
    Get.put(FriendController());
    final groupController = Get.find<GroupController>();
    final controller = Get.find<MessageController>();
    final friendController = Get.find<FriendController>();
    var listUser = controller.listAllUser;
    var listMessageData = controller.listMessageData.value;
    final authController = Get.find<AuthController>();
    // User? currentUser;
    // if (authController.isLogin.value) {
    //   currentUser = authController.currentUser.value!;
    // }
    final msgDatas = FirebaseFirestore.instance.collection('messageDatas');
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        title: const Text("Welcome back"),
        actions: [
          PopupMenuButton<MenuItem>(
            onSelected: (value) => onSelected(context, value),
            itemBuilder: (context) => [
              ...MenuItems.menuItems.map((e) => buildItem(e)).toList(),
            ],
          )

          // IconButton(
          //     onPressed: () {
          //       if (currentUser != null) {
          //         currentUser.showALlAttribute();
          //       }
          //     },
          //     icon: const Icon(
          //       Icons.more_horiz,
          //       color: Colors.white,
          //     ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(right: 5, left: 5),
              height: 45,
              child: Obx(
                () {
                  User? currentUser = authController.currentUser.value;
                  return Center(
                      child: currentUser != null
                          ? StreamBuilder(
                              stream: controller
                                  .getListMsgDataOfCurrentUser(currentUser),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final data = snapshot.data;
                                  List<MessageData> listMsgData = data!;

                                  //controller.listMessageData.value = listMsgData;
                                  // Obx(
                                  //   () {
                                  // controller.setListMessageData(listMsgData);
                                  // controller.listMessageData.value = listMsgData;
                                  // controller.searchListMessageData.value =
                                  //     listMsgData;
                                  final list = controller.listMessageData;
                                  return TextField(
                                    onChanged: (value) {
                                      // controller.updateDisplayedMsgData(value);
                                      controller.changeSearchKey(value);
                                    },
                                    // controller.filterMsgData(value),
                                    // controller.filterListMessageData(
                                    //     searchController.text, list),
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10),
                                      prefixIcon: const Icon(Icons.search),
                                      hintText: "Search for friends",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    // );
                                    // },
                                  );
                                }
                                return TextField(
                                  onChanged: (value) {
                                    controller.changeSearchKey(value);
                                  },
                                  // controller.filterListMessageData(
                                  //     searchController.text,
                                  //     controller.listMessageData),
                                  controller: searchController,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    prefixIcon: const Icon(Icons.search),
                                    hintText: "Search for friends",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                );
                              },
                              // child:
                            )
                          : TextField(
                              onChanged: (value) =>
                                  controller.filterListMessageData(
                                      searchController.text,
                                      controller.listMessageData),
                              controller: searchController,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                prefixIcon: const Icon(Icons.search),
                                hintText: "Search for friends",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ));
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.12,
              child: Row(
                children: [
                  Column(
                    children: [
                      Obx(
                        () => GestureDetector(
                          onTap: () {
                            User? currentUser =
                                authController.currentUser.value;
                            var messageData = controller.getMessageDataOneByOne(
                                currentUser!, currentUser);

                            if (messageData == null) {
                              List<String> list = [];
                              CommonMethods.addToReceiverListOneByOne(
                                  list: list,
                                  receiver: currentUser.id,
                                  sender: currentUser.id);
                              MessageData newMessageData = MessageData(
                                  // sender: currentUser,
                                  listMessages: [],
                                  receivers: list);
                              controller.addNewChat(
                                  newMessageData); // because of this user haven't chatted with me before
                              Get.to(
                                () => ChattingPage(messageData: newMessageData),
                              );
                            } else {
                              //  messageData.showALlAttribute();
                              Get.to(
                                () => ChattingPage(messageData: messageData),
                              );
                            }
                          },
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: authController.currentUser.value !=
                                    null
                                ? NetworkImage(
                                    authController.currentUser.value!.urlImage!)
                                : const NetworkImage(
                                    "https://st3.depositphotos.com/6672868/13701/v/450/depositphotos_137014128-stock-illustration-user-profile-icon.jpg"),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      const Text(
                        "Me",
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Obx(() {
                      List<User> list = controller.listAllUser.value;
                      User? currentUser = authController.currentUser.value;
                      // final listUser = CommonMethods.getListUserFromFriends(
                      //     listFriend, list);
                      final listFriend = friendController.listFriends.value;
                      final listUserInChats =
                          controller.relatedUserToCurrentUser.value;
                      final mergedList =
                          CommonMethods.mergeList(listFriend, listUserInChats);
                      final listOnlineFriend = CommonMethods.showAllUserOnline(
                          mergedList, currentUser);
                      if (listOnlineFriend != null) {
                        return ListView.separated(
                            separatorBuilder: (context, index) =>
                                const SizedBox(
                                  width: 3,
                                ),
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              // list.removeWhere(
                              //   (element) => element.id == currentUser!.id,
                              // );
                              User user = listOnlineFriend[index];
                              return user.id != currentUser!.id
                                  ? AnUser(
                                      receiver: user,
                                      //   messageData: messageData,
                                    )
                                  : const SizedBox(
                                      height: 1,
                                      width: 1,
                                    );
                            },
                            itemCount: listOnlineFriend.length);
                      } else {
                        return const SizedBox();
                      }
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const ListMesseger(),
          ],
        ),
      ),
    );
  }
}
