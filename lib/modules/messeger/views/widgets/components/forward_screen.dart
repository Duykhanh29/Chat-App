import 'package:chat_app/modules/home/controllers/data_controller.dart';
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

class ForwardScreen extends StatelessWidget {
  ForwardScreen({super.key, required this.message});
  Message message;
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final friendController = Get.find<FriendController>();
    final msgController = Get.find<MessageController>();
    final authController = Get.find<AuthController>();
    final listFriend = friendController.listFriends.value;
    final msgDatas = msgController.listMessageData.value;
    final currentUser = authController.currentUser.value;
    msgController.setForForward(msgDatas, listFriend);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forward"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            msgController.resetForForward();
            Get.back();
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
                msgController.filterSendForward(value, msgDatas, listFriend);
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
            const SizedBox(
              height: 5,
            ),
            ListForSending(currentUser: currentUser),
            Obx(
              () {
                final users = msgController.checkBoxUsers.value;
                final msgDatas = msgController.checkBoxMsgDataForForward.value;
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
                    Message newMsg = Message(
                      chatMessageType: message.chatMessageType,
                      dateTime: Timestamp.now(),
                      isDeleted: false,
                      isFoward: true,
                      isReply: false,
                      isSearch: false,
                      messageStatus: message.messageStatus,
                      text: message.text,
                      senderID: currentUser!.id,
                    );

                    // send to msgData
                    for (var msgData in msgDatas) {
                      msgController.sendAMessage(newMsg, msgData);
                      //send notification to others
                      List<User>? receivers = CommonMethods.getAllUserInChat(
                          msgData.receivers!, msgController.listAllUser.value);
                      User? receiver;
                      if (CommonMethods.isAGroup(msgData.receivers) == false) {
                        receiver =
                            CommonMethods.getReceiver(receivers, currentUser);
                      }
                      CommonMethods.sendNotifications(
                          receivers,
                          currentUser,
                          receiver,
                          msgData,
                          "${currentUser.name} forwarded a message");
                    }

                    // send to users
                    for (var user in users) {
                      MessageData newMessageData = MessageData(
                          // sender: currentUser,
                          listMessages: [],
                          receivers: [currentUser.id!, user.id!]);
                      msgController.addNewChat(
                          newMessageData); // because of this user haven't chatted with me before
                      msgController.sendAMessage(message, newMessageData);
                      //send notification to others
                      List<User>? receivers = CommonMethods.getAllUserInChat(
                          newMessageData.receivers!,
                          msgController.listAllUser.value);

                      CommonMethods.sendNotifications(
                          receivers,
                          currentUser,
                          null,
                          newMessageData,
                          "${currentUser.name} forwarded a message");
                    }
                    msgController.resetForForward();
                    Get.back();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Send"),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ListForSending extends StatefulWidget {
  ListForSending({super.key, required this.currentUser});
  User? currentUser;

  @override
  State<ListForSending> createState() => _ListForSendingState();
}

class _ListForSendingState extends State<ListForSending> {
  @override
  Widget build(BuildContext context) {
    final friendController = Get.find<FriendController>();
    final msgController = Get.find<MessageController>();
    final dataController = Get.find<DataController>();
    final listAllUser = dataController.listAllUser.value;
    return Obx(
      () {
        final msgDatas = msgController.listMsgDataForForward.value;
        final listFriend = msgController.searchUsers.value;
        return Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      MessageData msgData = msgDatas[index];
                      User? user;
                      String title;
                      String urlImage;
                      if (!CommonMethods.isAGroup(msgData.receivers)) {
                        List<User>? receivers = CommonMethods.getAllUserInChat(
                            msgData.receivers!, listAllUser);
                        user = CommonMethods.getReceiver(
                            receivers, widget.currentUser!);
                        title = user!.name!;
                        urlImage = user.urlImage ??
                            "https://t4.ftcdn.net/jpg/03/59/58/91/360_F_359589186_JDLl8dIWoBNf1iqEkHxhUeeOulx0wOC5.jpg";
                      } else {
                        title = msgData.chatName!;
                        urlImage = msgData.groupImage ??
                            "https://cdn-icons-png.flaticon.com/512/615/615075.png";
                      }
                      return ListTile(
                          dense: true,
                          visualDensity:
                              const VisualDensity(vertical: 3), // to expand
                          // onTap: () {
                          //   Get.to();
                          // },
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(urlImage),
                          ),
                          title: Text(
                            title,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                          trailing: Checkbox(
                            value: msgController.checkBoxMsgDataForForward
                                .contains(msgData),
                            onChanged: (value) {
                              setState(() {
                                if (value ?? false) {
                                  msgController
                                      .addMsgDataInSendForward(msgData);
                                } else {
                                  msgController
                                      .removeMsgDataInSendForward(msgData);
                                }
                              });
                            },
                          ));
                    },
                    separatorBuilder: (context, index) => const Divider(
                          color: Colors.black38,
                        ),
                    itemCount: msgDatas.length),
                if (listFriend.length > 0) ...{
                  const SizedBox(
                    height: 5,
                  ),
                  const SizedBox(
                    width: 100,
                    child: Center(child: Text("Users")),
                  ),
                  ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
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
                                  NetworkImage(listFriend[index].urlImage!),
                            ),
                            title: Text(
                              listFriend[index].name!,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700),
                            ),
                            trailing: Checkbox(
                              value: msgController.checkBoxUsers
                                  .contains(listFriend[index]),
                              onChanged: (value) {
                                setState(() {
                                  if (value ?? false) {
                                    msgController.addUserInSendForward(
                                        listFriend[index]);
                                  } else {
                                    msgController.removeUserInSendForward(
                                        listFriend[index]);
                                  }
                                });
                              },
                            ));
                      },
                      separatorBuilder: (context, index) => const Divider(
                            color: Colors.black38,
                          ),
                      itemCount: listFriend.length),
                }
              ],
            ),
          ),
        );
      },
    );
  }
}
