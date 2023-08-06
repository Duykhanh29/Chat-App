import 'package:chat_app/data/common/methods.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/friend/controllers/friend_controller.dart';
import 'package:chat_app/modules/home/controllers/data_controller.dart';
import 'package:chat_app/modules/messeger/controllers/group_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/ingroup/add_new_member.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/service/notification_service.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_app/modules/friend/views/widgetss/view_profile.dart';

class ViewMembers extends StatelessWidget {
  ViewMembers({super.key, required this.messageData});
  MessageData messageData;

  @override
  Widget build(BuildContext context) {
    final messageController = Get.find<MessageController>();
    final authController = Get.find<AuthController>();
    final groupController = Get.find<GroupController>();
    User? currentUser = authController.currentUser.value;
    List<User>? receivers = CommonMethods.getAllUserInChat(
      messageData.receivers!,
      messageController.listAllUser.value,
    );
    groupController.setValueUserInAChat(receivers);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Group members"),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ListMember(
              // listUser: receivers,
              messageData: messageData,
            ),
            // const Spacer(),
            // InkWell(
            //   onTap: (){},
            //   child: Container(
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(15),
            //       color: Colors.greenAccent
            //     ),
            //   ),
            // ),
            ElevatedButton.icon(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all(
                  Colors.greenAccent,
                ),
              ),
              onPressed: () {
                List<String>? allIdUser =
                    CommonMethods.convertListUserToListStringID(
                        groupController.allUserInAChat.value);
                Get.to(() => AddMember(
                      messageData: messageData,
                      existedUser: allIdUser,
                    ));
              },
              icon: const Icon(Icons.add),
              label: const Text("Add member"),
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}

class ListMember extends StatelessWidget {
  ListMember({super.key, required this.messageData});
  // List<User> listUser;
  MessageData messageData;
  @override
  Widget build(BuildContext context) {
    final friendController = Get.find<FriendController>();
    final dataController = Get.find<DataController>();
    final authController = Get.find<AuthController>();
    final groupController = Get.find<GroupController>();
    final currentUser = authController.currentUser.value;
    final listALlUser = dataController.listAllUser.value;
    // List<User>? friends = CommonMethods.getListUserFromFriends(
    //     friendController.listAllFriend.value, listALlUser);
    return Expanded(
      child: Theme(
        data: Theme.of(context).copyWith(
            scrollbarTheme: ScrollbarThemeData(
                thumbColor: MaterialStateProperty.all(Colors.blue))),
        child: Scrollbar(
          child: Obx(
            () {
              final listUser = groupController.allUserInAChat.value;
              return ListView.separated(
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(listUser[index].id!),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.blue,
                        ),
                      ),
                      direction: messageData.idAdmin == currentUser!.id &&
                              messageData.receivers!.length > 3
                          ? DismissDirection.endToStart
                          : DismissDirection.none,
                      onDismissed: (direction) async {
                        // if (messageData.receivers!.length > 3) {
                        if (messageData.idAdmin == currentUser.id) {
                          await groupController.deleteAnUserFromGroup(
                              messageData, listUser[index]);
                          Future.delayed(const Duration(seconds: 15));
                          groupController.deleteUserFromChat(listUser[index]);
                        }
                        // } else {
                        //   Get.dialog(
                        //     AlertDialog(
                        //       title: const Text('Notice'),
                        //       content: const Text(
                        //           'Group should have at least 3 members'),
                        //       actions: <Widget>[
                        //         TextButton(
                        //           onPressed: () {
                        //             Get.back();
                        //           },
                        //           child: const Text('OK'),
                        //         ),
                        //       ],
                        //     ),
                        //   );
                        // }
                      },
                      child: ListTile(
                          dense: true,
                          visualDensity:
                              const VisualDensity(vertical: 3), // to expand
                          onTap: () {
                            Get.to(() => ViewProfile(user: listUser[index]));
                          },
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage:
                                NetworkImage(listUser[index].urlImage!),
                          ),
                          title: Text(
                            listUser[index].id == messageData.idAdmin
                                ? "${listUser[index].name!} (Admin)"
                                : listUser[index].name!,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                          trailing: StreamBuilder(
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.none) {
                                return const SizedBox();
                              } else if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox();
                              } else {
                                if (snapshot.data != null) {
                                  final listFriend =
                                      CommonMethods.getListUserFromFriends(
                                          snapshot.data!.listFriend!,
                                          listALlUser);
                                  final listQueue =
                                      CommonMethods.getListUserFromFriends(
                                          snapshot.data!.queueList!,
                                          listALlUser);
                                  final listSent =
                                      CommonMethods.getListUserFromFriends(
                                          snapshot.data!.requestedList!,
                                          listALlUser);
                                  if (listUser[index].id == currentUser.id) {
                                    return const Text("You");
                                  } else if (CommonMethods.isFriend(
                                      listUser[index].id!, listFriend)) {
                                    return const SizedBox();
                                  } else if (CommonMethods.isSentRequest(
                                      listUser[index].id!, listSent)) {
                                    return InkWell(
                                      onTap: () async {
                                        await friendController.cancelRequest(
                                            currentUser, listUser[index]);
                                      },
                                      child: const Icon(
                                        Icons.cancel,
                                        color: Colors.redAccent,
                                      ),
                                    );
                                  } else if (CommonMethods.isReceivedRequest(
                                      listUser[index].id!, listQueue)) {
                                    return FittedBox(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              await friendController
                                                  .acceptRequest(currentUser,
                                                      listUser[index]);
                                            },
                                            child: const Icon(
                                              Icons.cancel,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              await friendController
                                                  .removeRequest(currentUser,
                                                      listUser[index]);
                                            },
                                            child: const Icon(
                                              Icons.cancel,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return InkWell(
                                      onTap: () async {
                                        await friendController.addFriend(
                                            currentUser, listUser[index]);
                                        String tokens = listUser[index].token!;
                                        NotificationService.sendPushMessage(
                                            [tokens],
                                            "${currentUser.name} sent a friend request",
                                            "Friend request",
                                            Paths.RECEIVED_FRIEND_REQUEST,
                                            "");
                                      },
                                      child: const Icon(
                                        Icons.person_add_alt_1,
                                        color: Colors.blue,
                                      ),
                                    );
                                  }
                                } else {
                                  return const SizedBox();
                                }
                              }
                            },
                            stream: friendController.getFriend(currentUser),
                          )),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        color: Colors.black26,
                      ),
                  itemCount: listUser.length);
            },
          ),
        ),
      ),
    );
  }
}
