import 'package:chat_app/modules/messeger/controllers/group_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_app/data/common/methods.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/friend/controllers/friend_controller.dart';
import 'package:uuid/uuid.dart';

class AddMember extends StatelessWidget {
  AddMember({super.key, required this.messageData, this.existedUser});
  MessageData messageData;
  List<String>? existedUser;
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final friendController = Get.find<FriendController>();
    final messageController = Get.find<MessageController>();
    final groupController = Get.find<GroupController>();
    final authController = Get.find<AuthController>();
    final currentUser = authController.currentUser.value;
    List<User>? listFriend = friendController.listFriends.value;

    List<User>? friends = listFriend;
    User? targetUser = groupController.targetUser.value;
    if (existedUser != null) {
      friends =
          CommonMethods.getAllNoExistedUserInChatGroup(listFriend, existedUser);
    } else if (targetUser != null) {
      friends = CommonMethods.getAllNoExistedUserInChatGroup(
          listFriend, <String>[targetUser.id!]);
    }
    groupController.setValueForSearchFriend(friends);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
            groupController.setValueForSearchFriend(listFriend);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) {
                print("Value is: $value");
                groupController.filterList(value, friends!);
              },
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.orangeAccent.shade200,
                ),
                hintText: "Search",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            // Obx(() {
            //   User? user = groupController.targetUser.value;
            //   if (user != null) {
            //     return Stack(
            //       alignment: AlignmentDirectional.topEnd,
            //       children: [
            //         CircleAvatar(
            //           radius: 30,
            //           backgroundImage: user.urlImage != null
            //               ? NetworkImage(user.urlImage!)
            //               : const NetworkImage(
            //                   "https://t4.ftcdn.net/jpg/03/59/58/91/360_F_359589186_JDLl8dIWoBNf1iqEkHxhUeeOulx0wOC5.jpg"),
            //         ),
            //         Positioned(
            //           right: 0,
            //           top: 0,
            //           child: InkWell(
            //             onTap: () {
            //               groupController.setValueFortargetUser(null);
            //               groupController.setValueForSearchFriend(listFriend);
            //             },
            //             child: Container(
            //               height: 20,
            //               width: 20,
            //               decoration: BoxDecoration(
            //                   borderRadius: BorderRadius.circular(100),
            //                   color: Colors.white60.withOpacity(0.1)),
            //               child: const Icon(Icons.cancel,
            //                   color: Colors.cyanAccent),
            //             ),
            //           ),
            //         ),
            //       ],
            //     );
            //   } else {
            //     return const SizedBox(
            //       height: 0,
            //     );
            //   }
            // }),
            const SizedBox(
              height: 5,
            ),
            ListForInviting(
              messageData: messageData,
            ),
            Obx(
              () {
                final addMemberList = groupController.addNewMembers.value;
                // final anUser = groupController.targetUser.value;
                return ElevatedButton.icon(
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
                  onPressed: () async {
                    if (addMemberList != null) {
                      for (var user in addMemberList) {
                        await groupController.addAnUserToGroup(
                            messageData, user);
                        Message msg = Message(
                            chatMessageType: ChatMessageType.NOTIFICATION,
                            dateTime: Timestamp.now(),
                            senderID: currentUser!.id,
                            idMessage: Uuid().v4(),
                            text:
                                "${user.name} was added by ${currentUser.name}",
                            messageStatus: MessageStatus.RECEIVED);
                        messageController.sendAMessage(msg, messageData);
                      }
                      // if (targetUser != null) {
                      //   await groupController.addAnUserToGroup(
                      //       messageData, anUser!);
                      // }
                      Future.delayed(const Duration(seconds: 10));

                      Get.back();
                      Get.back();
                      groupController.setValueForSearchFriend(listFriend);
                      groupController.resetInitialMember();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add member"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ListForInviting extends StatefulWidget {
  ListForInviting({super.key, required this.messageData});
  MessageData messageData;
  @override
  State<ListForInviting> createState() => _ListForInvitingState();
}

class _ListForInvitingState extends State<ListForInviting> {
  @override
  Widget build(BuildContext context) {
    final messageController = Get.find<MessageController>();
    final groupController = Get.find<GroupController>();
    return Obx(
      () {
        final listUser = groupController.searchFriend.value;
        return Expanded(
          child: Theme(
            data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                    thumbColor: MaterialStateProperty.all<Color>(Colors.blue))),
            child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                      dense: true,
                      visualDensity:
                          const VisualDensity(vertical: 3), // to expand
                      // onTap: () {
                      //   Get.to();
                      // },
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage:
                            NetworkImage(listUser[index].urlImage!),
                      ),
                      title: Text(
                        listUser[index].name!,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      trailing: Checkbox(
                        value: groupController.addNewMembers.value
                            .contains(listUser[index]),
                        onChanged: (value) {
                          setState(() {
                            if (value ?? false) {
                              groupController
                                  .addNewUserInAddMember(listUser[index]);
                            } else {
                              groupController
                                  .removeUserInAddMembers(listUser[index]);
                            }
                          });
                        },
                      ));
                },
                separatorBuilder: (context, index) => const Divider(
                      color: Colors.black26,
                    ),
                itemCount: listUser.length),
          ),
        );
      },
    );
  }
}
