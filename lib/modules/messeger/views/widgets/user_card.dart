import 'package:chat_app/data/common/methods.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/friend/controllers/friend_controller.dart';
import 'package:chat_app/modules/home/controllers/data_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/chatting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class UserCard extends GetView<MessageController> {
  UserCard({super.key, required this.receiver});
  User receiver;
  @override
  Widget build(BuildContext context) {
    final friendController = Get.find<FriendController>();
    List<User> listFriends = friendController.listFriends;
    final authController = Get.find<AuthController>();
    final controller = Get.find<MessageController>();
    final dataController = Get.find<DataController>();
    User currentUser = authController.currentUser.value!;
    return ListTile(
      onTap: () {
        MessageData newMessageData = MessageData(
            // sender: currentUser,
            listMessages: [],
            receivers: [currentUser.id!, receiver.id!]);
        controller.addNewChat(
            newMessageData); // because of this user haven't chatted with me before
        Get.to(() => ChattingPage(), arguments: newMessageData);
      },
      leading: CircleAvatar(
        backgroundImage: NetworkImage(receiver.urlImage!),
      ),
      title: Text(
        receiver.name!,
        style: const TextStyle(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w300),
      ),
      trailing: StreamBuilder(
        stream: friendController.friends,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.none ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox();
          } else {
            if (snapshot.data != null) {
              final listALlUser = dataController.listAllUser.value;
              List<User>? friends = CommonMethods.getListUserFromFriends(
                  snapshot.data!.listFriend!, listALlUser);
              List<User>? sentList = CommonMethods.getListUserFromFriends(
                  snapshot.data!.requestedList!, listALlUser);
              List<User>? receivedList = CommonMethods.getListUserFromFriends(
                  snapshot.data!.queueList!, listALlUser);
              if (CommonMethods.isFriend(receiver.id!, friends)) {
                return const SizedBox();
              } else if (CommonMethods.isSentRequest(receiver.id!, sentList)) {
                return InkWell(
                  onTap: () async {
                    await friendController.cancelRequest(currentUser, receiver);
                  },
                  child: const Icon(
                    Icons.cancel_sharp,
                    color: Colors.redAccent,
                  ),
                );
              } else if (CommonMethods.isReceivedRequest(
                  receiver.id!, receivedList)) {
                return Flexible(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () async {
                          await friendController.acceptRequest(
                              currentUser, receiver);
                        },
                        child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.blue.withOpacity(0.3)),
                            child: const Icon(Icons.done, color: Colors.blue)),
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      InkWell(
                        onTap: () async {
                          await friendController.removeRequest(
                              currentUser, receiver);
                        },
                        child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.blue.withOpacity(0.3)),
                            child: const Icon(Icons.cancel, color: Colors.red)),
                      ),
                    ],
                  ),
                );
              } else {
                return InkWell(
                  onTap: () async {
                    await friendController.addFriend(currentUser, receiver);
                  },
                  child: const Icon(Icons.person_add_alt_1),
                );
              }
            } else {
              return const SizedBox();
            }
          }
        },
      ),
    );
  }
}
