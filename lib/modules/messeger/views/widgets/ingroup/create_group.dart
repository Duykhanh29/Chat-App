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

class CreateGroup extends StatelessWidget {
  CreateGroup({super.key});
  final searchController = TextEditingController();
  final chatNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Get.put(MessageController());
    Get.put(FriendController());
    Get.put(AuthController());
    Get.put(GroupController());
    final messageController = Get.find<MessageController>();
    final authController = Get.find<AuthController>();
    final friendController = Get.find<FriendController>();
    final groupController = Get.find<GroupController>();
    List<User>? listFriend = friendController.listFriends.value;
    List<User>? friends = listFriend;
    User? currentUser = authController.currentUser.value;
    User? targetUser = groupController.targetUser.value;
    if (targetUser != null) {
      friends = CommonMethods.getAllNoExistedUserInChatGroup(
          listFriend, <String>[targetUser.id!]);
    }
    groupController.setValueForSearchFriend(friends);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create group"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
            groupController.setValueForSearchFriend(listFriend);
            groupController.resetInitialMember();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            TextField(
              onChanged: (value) {
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
              height: 10,
            ),
            TextField(
              controller: chatNameController,
              decoration: const InputDecoration(
                hintText: "Group name",
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Obx(() {
              User? user = groupController.targetUser.value;
              if (user != null) {
                return Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: user.urlImage != null
                          ? NetworkImage(user.urlImage!)
                          : const NetworkImage(
                              "https://t4.ftcdn.net/jpg/03/59/58/91/360_F_359589186_JDLl8dIWoBNf1iqEkHxhUeeOulx0wOC5.jpg"),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: InkWell(
                        onTap: () {
                          groupController.setValueFortargetUser(null);
                          groupController.setValueForSearchFriend(listFriend);
                        },
                        child: Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.white60.withOpacity(0.1)),
                          child: const Icon(Icons.cancel,
                              color: Colors.cyanAccent),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const SizedBox(
                  height: 0,
                );
              }
            }),
            InitialMember(),
            Obx(
              () {
                final initialMembers = groupController.initialMember.value;
                User? user = groupController.targetUser.value;
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
                    if (initialMembers != null) {
                      List<String>? receivers =
                          CommonMethods.convertListUserToListStringID(
                              initialMembers);
                      receivers.add(currentUser!.id!);
                      if (user != null) {
                        receivers.add(user.id!);
                      }
                      MessageData messageData = MessageData(
                        createdAt: Timestamp.now(),
                        // groupImage: ,
                        idAdmin: currentUser.id,
                        listMessages: [],
                        receivers: receivers,
                        chatName: chatNameController.text,
                      );
                      await groupController.createGroup(messageData);
                      messageController.addNewChat(messageData);
                      Future.delayed(const Duration(seconds: 10));
                      Get.back();
                      groupController.setValueFortargetUser(null);
                      groupController.setValueForSearchFriend(listFriend);
                      groupController.resetInitialMember();
                      Message msg = Message(
                          chatMessageType: ChatMessageType.NOTIFICATION,
                          dateTime: Timestamp.now(),
                          senderID: currentUser.id,
                          text: "${currentUser.name} created group",
                          messageStatus: MessageStatus.RECEIVED);
                      messageController.sendAMessage(msg, messageData);
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Create group"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class InitialMember extends StatefulWidget {
  InitialMember({super.key});
  // MessageData messageData;
  @override
  State<InitialMember> createState() => _InitialMemberState();
}

class _InitialMemberState extends State<InitialMember> {
  @override
  Widget build(BuildContext context) {
    final messageController = Get.find<MessageController>();
    final groupController = Get.find<GroupController>();
    return Obx(
      () {
        final listUser = groupController.searchFriend.value;
        List<User> selectedUsers = [];
        return Expanded(
          child: Theme(
            data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                    thumbColor: MaterialStateProperty.all<Color>(Colors.blue))),
            child: Scrollbar(
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          value: groupController.initialMember.value
                              .contains(listUser[index]),
                          onChanged: (value) {
                            setState(() {
                              if (value ?? false) {
                                groupController.addNewUser(listUser[index]);
                              } else {
                                groupController.removeUser(listUser[index]);
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
          ),
        );
      },
    );
  }
}
