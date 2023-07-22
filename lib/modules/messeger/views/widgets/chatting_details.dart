import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/friend/views/widgetss/view_profile.dart';
import 'package:chat_app/modules/messeger/controllers/group_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/components/view_media_file_link.dart';
import 'package:chat_app/modules/messeger/views/widgets/ingroup/add_new_member.dart';
import 'package:chat_app/modules/messeger/views/widgets/ingroup/all_member.dart';
import 'package:chat_app/modules/messeger/views/widgets/ingroup/create_group.dart';
import 'package:chat_app/modules/profile/views/widgets/profile_view.dart';
import 'package:chat_app/service/storage_service.dart';
import 'package:chat_app/utils/helpers/dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/data/common/methods.dart';
import 'package:photo_view/photo_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:uuid/uuid.dart';

class ChattingDetails extends GetView<MessageController> {
  ChattingDetails({super.key, required this.messageData});
  MessageData messageData;

  Widget showSearch1(
      MessageController messageController, MessageData messageData) {
    return Container(
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: TextField(
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            //hanlde the value when user click search in
            messageController.searchMessages(value, messageData);
            Get.back();
          },
          controller: messageController.searchController,
          decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search...',
              suffixIcon: IconButton(
                  onPressed: () {
                    messageController.searchController.text = "";
                  },
                  icon: const Icon(Icons.cancel_rounded)),
              border: InputBorder.none
              //  OutlineInputBorder(
              // //  borderRadius: BorderRadius.circular(15),
              // ),
              ),
        ),
      ),
    );
  }

  Storage storage = Storage();
  //var searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MessageController>();
    final groupController = Get.find<GroupController>();
    final authController = Get.find<AuthController>();
    final messageController = Get.find<MessageController>();
    // MessageData messageData = Get.arguments;
    // User sender = messageData.sender!;
    User? receiver;
    User? currentUser = authController.currentUser.value!;
    List<User>? receivers = CommonMethods.getAllUserInChat(
        messageData.receivers!, controller.listAllUser.value);
    if (CommonMethods.isAGroup(messageData.receivers) == false) {
      receiver = CommonMethods.getReceiver(receivers, currentUser);
    }
    List<String> listLink = CommonMethods.getAllLink(messageData);
    List<Map<String, String>> listMedia =
        CommonMethods.getAllMedias(messageData);
    controller.getAllLink(listLink);
    controller.getAllMedia(listMedia);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          leading: Obx(() => controller.isSearch.value
              ? IconButton(
                  onPressed: () {
                    controller.cancelSearch();
                  },
                  icon: const Icon(Icons.arrow_back),
                )
              : IconButton(
                  onPressed: () {
                    controller.resetAllLink();
                    controller.resetAllMedia();
                    Get.back();
                  },
                  icon: const Icon(Icons.arrow_back),
                )),
          title: Obx(() => controller.isSearch.value
              ? showSearch1(controller, messageData)
              : const Text(""))),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    StreamBuilder(
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.none) {
                          return const SizedBox();
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox();
                        } else {
                          if (snapshot.data != null) {
                            MessageData currentMsgData = MessageData(
                              idMessageData: snapshot.data!.idMessageData,
                              chatName: snapshot.data!.chatName,
                              groupImage: snapshot.data!.groupImage,
                              listMessages: (snapshot.data!.listMessages),
                              // .toList(),
                              receivers:
                                  List<String>.from(snapshot.data!.receivers!),
                            );
                            User? anUser;
                            User? currentUser =
                                authController.currentUser.value!;
                            List<User>? listReceiver =
                                CommonMethods.getAllUserInChat(
                                    currentMsgData.receivers!,
                                    controller.listAllUser.value);
                            if (CommonMethods.isAGroup(messageData.receivers) ==
                                false) {
                              anUser = CommonMethods.getReceiver(
                                  listReceiver, currentUser);
                            }
                            return GestureDetector(
                              onTap: () async {
                                Get.to(() => Scaffold(
                                      appBar: AppBar(
                                        leading: IconButton(
                                            onPressed: () {
                                              Get.back();
                                            },
                                            icon: const Icon(Icons.arrow_back)),
                                        actions: [
                                          IconButton(
                                              onPressed: () async {
                                                String? url =
                                                    CommonMethods.isAGroup(
                                                            currentMsgData
                                                                .receivers!)
                                                        ? currentMsgData
                                                            .groupImage
                                                        : anUser!.urlImage!;
                                                if (url != null) {
                                                  await storage
                                                      .downloadAndSaveImage(
                                                          url);
                                                } else {
                                                  print("Cannot download");
                                                }
                                              },
                                              icon: const Icon(
                                                  Icons.download_outlined))
                                        ],
                                      ),
                                      body: Center(
                                        child: PhotoView(
                                          minScale:
                                              PhotoViewComputedScale.covered *
                                                  0.8,
                                          maxScale:
                                              PhotoViewComputedScale.covered *
                                                  4.0,
                                          imageProvider: CommonMethods.isAGroup(
                                                  currentMsgData.receivers!)
                                              ? (currentMsgData.groupImage ==
                                                      null
                                                  ? const NetworkImage(
                                                      "https://cdn-icons-png.flaticon.com/512/615/615075.png")
                                                  : NetworkImage(currentMsgData
                                                      .groupImage!))
                                              : (anUser!.urlImage == null
                                                  ? const NetworkImage(
                                                      "https://t4.ftcdn.net/jpg/03/59/58/91/360_F_359589186_JDLl8dIWoBNf1iqEkHxhUeeOulx0wOC5.jpg")
                                                  : NetworkImage(
                                                      anUser.urlImage!)),
                                          backgroundDecoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ));
                              },
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: CommonMethods.isOnlineChat(
                                            receivers, currentUser) ==
                                        true
                                    ? Colors.blue
                                    : Colors.grey,
                                child: CircleAvatar(
                                  radius: 55,
                                  backgroundImage: CommonMethods.isAGroup(
                                          currentMsgData.receivers!)
                                      ? (currentMsgData.groupImage == null
                                          ? const NetworkImage(
                                              "https://cdn-icons-png.flaticon.com/512/615/615075.png")
                                          : NetworkImage(
                                              currentMsgData.groupImage!))
                                      : (anUser!.urlImage == null
                                          ? const NetworkImage(
                                              "https://t4.ftcdn.net/jpg/03/59/58/91/360_F_359589186_JDLl8dIWoBNf1iqEkHxhUeeOulx0wOC5.jpg")
                                          : NetworkImage(anUser.urlImage!)),
                                ),
                              ),
                            );
                          } else {
                            List<User>? receivers =
                                CommonMethods.getAllUserInChat(
                                    messageData.receivers!,
                                    controller.listAllUser.value);
                            User? targetUser = CommonMethods.getReceiver(
                                receivers, currentUser);
                            return GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => Scaffold(
                                    appBar: AppBar(
                                      leading: IconButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          icon: const Icon(Icons.arrow_back)),
                                      actions: [
                                        IconButton(
                                            onPressed: () async {
                                              String? url =
                                                  targetUser.urlImage!;
                                              if (url != null) {
                                                await storage
                                                    .downloadAndSaveImage(url);
                                              } else {
                                                print("Cannot download");
                                              }
                                            },
                                            icon: const Icon(
                                                Icons.download_outlined))
                                      ],
                                    ),
                                    body: Center(
                                      child: PhotoView(
                                        minScale:
                                            PhotoViewComputedScale.covered *
                                                0.8,
                                        maxScale:
                                            PhotoViewComputedScale.covered *
                                                4.0,
                                        imageProvider: (targetUser.urlImage ==
                                                null
                                            ? const NetworkImage(
                                                "https://t4.ftcdn.net/jpg/03/59/58/91/360_F_359589186_JDLl8dIWoBNf1iqEkHxhUeeOulx0wOC5.jpg")
                                            : NetworkImage(
                                                targetUser.urlImage!)),
                                        backgroundDecoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: CommonMethods.isOnlineChat(
                                            receivers, currentUser) ==
                                        true
                                    ? Colors.blue
                                    : Colors.grey,
                                child: CircleAvatar(
                                    radius: 55,
                                    backgroundImage: targetUser!.urlImage ==
                                            null
                                        ? const NetworkImage(
                                            "https://t4.ftcdn.net/jpg/03/59/58/91/360_F_359589186_JDLl8dIWoBNf1iqEkHxhUeeOulx0wOC5.jpg")
                                        : NetworkImage(targetUser.urlImage!)),
                              ),
                            );
                          }
                        }
                      },
                      stream: controller.getMesgData(messageData),
                    ),
                    if (CommonMethods.isAGroup(messageData.receivers!)) ...{
                      Positioned(
                        right: 5,
                        bottom: 11,
                        child: GestureDetector(
                          onTap: () async {
                            final result = await FilePicker.platform.pickFiles(
                              allowMultiple: false,
                              allowedExtensions: ['png', 'jpg'],
                              type: FileType.custom,
                            );
                            if (result != null) {
                              final path = result.files.single.path;
                              final fileName = result.files.single.name;
                              String type = 'groupAvatars';
                              bool isSuccess = await storage.uploadFile(path!,
                                  fileName, messageData.idMessageData!, type);
                              if (isSuccess) {
                                String url = await storage.downloadURL(
                                    fileName, messageData.idMessageData!, type);
                                await groupController.updateGroupChat(
                                    messageData: messageData,
                                    user: currentUser,
                                    image: url);
                                Message msg = Message(
                                    chatMessageType:
                                        ChatMessageType.NOTIFICATION,
                                    dateTime: Timestamp.now(),
                                    senderID: currentUser.id,
                                    idMessage: Uuid().v4(),
                                    text:
                                        "${currentUser.name} changed group photo",
                                    messageStatus: MessageStatus.RECEIVED);
                                messageController.sendAMessage(
                                    msg, messageData);
                                // await authController.updateUserToFirebase(
                                //     uid: currentUser.id!, urlImage: url);
                                // await authController.editUser(urlImage: url);
                              } else {
                                print("failed to connect");
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange,
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    }
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                StreamBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.none) {
                      return const SizedBox();
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircleAvatar(
                        radius: 60,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else {
                      if (snapshot.data != null) {
                        MessageData currentMsgData = MessageData(
                          idMessageData: snapshot.data!.idMessageData,
                          chatName: snapshot.data!.chatName,
                          groupImage: snapshot.data!.groupImage,
                          listMessages: (snapshot.data!.listMessages),
                          // .toList(),
                          receivers:
                              List<String>.from(snapshot.data!.receivers!),
                        );
                        User? anUser;
                        User? currentUser = authController.currentUser.value!;
                        List<User>? listReceiver =
                            CommonMethods.getAllUserInChat(
                                currentMsgData.receivers!,
                                controller.listAllUser.value);
                        if (CommonMethods.isAGroup(messageData.receivers) ==
                            false) {
                          anUser = CommonMethods.getReceiver(
                              listReceiver, currentUser);
                        }
                        return CommonMethods.isAGroup(currentMsgData.receivers)
                            ? (Text(
                                currentMsgData.chatName == null
                                    ? "No Group name"
                                    : currentMsgData.chatName!,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              ))
                            : (Text(
                                anUser!.name == null ? "No name" : anUser.name!,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              ));
                      } else {
                        return const SizedBox();
                      }
                    }
                  },
                  stream: controller.getMesgData(messageData),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!CommonMethods.isAGroup(messageData.receivers)) ...{
                      ElevatedButton.icon(
                        onPressed: () {
                          Get.to(() => ViewProfile(
                                user: receiver!,
                              ));
                        },
                        label: const Text("Profile"),
                        icon: const Icon(Icons.info_rounded),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                    },
                    ElevatedButton.icon(
                      onPressed: () {},
                      label: const Text("Mute"),
                      icon: const Icon(Icons.notifications),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text("Customization"),
                Container(
                  height: CommonMethods.isAGroup(messageData.receivers)
                      ? MediaQuery.of(context).size.height * 0.15
                      : MediaQuery.of(context).size.height * 0.08,
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Color.fromARGB(255, 194, 232, 247),
                    shadowColor: Color.fromARGB(255, 248, 149, 149),
                    child: ListView(
                      children: [
                        ListTile(
                          title: const Text("Theme"),
                          onTap: () {},
                          leading: const Icon(
                            Icons.color_lens,
                            color: Colors.red,
                          ),
                        ),
                        const Divider(
                          height: 2,
                          color: Color.fromARGB(255, 42, 42, 42),
                        ),
                        if (CommonMethods.isAGroup(messageData.receivers))
                          ...{},
                        if (CommonMethods.isAGroup(messageData.receivers)) ...{
                          ListTile(
                            title: const Text("Change group name"),
                            onTap: () {
                              showDialogChangeGroupName(
                                groupController,
                                currentUser,
                                messageController,
                              );
                            },
                            leading: const Icon(
                              Icons.abc_outlined,
                              color: Colors.black,
                            ),
                          )
                        },
                        const Divider(
                          height: 2,
                          color: Color.fromARGB(255, 42, 42, 42),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                FittedBox(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Actions"),
                      ]),
                ),
                Container(
                  height: CommonMethods.isAGroup(messageData.receivers)
                      ? MediaQuery.of(context).size.height * 0.3
                      : MediaQuery.of(context).size.height * 0.23,
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Color.fromARGB(255, 194, 232, 247),
                    shadowColor: Color.fromARGB(255, 248, 149, 149),
                    child: ListView(
                      children: [
                        ListTile(
                          title: const Text("Search"),
                          onTap: () {
                            controller.searchMode();
                            if (controller.isSearch.value) {
                              print("true");
                            } else {
                              print("false");
                            }
                          },
                          leading: const Icon(
                            Icons.search_outlined,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const Divider(
                          height: 2,
                          color: Color.fromARGB(255, 42, 42, 42),
                        ),
                        ListTile(
                          title: CommonMethods.isAGroup(messageData.receivers)
                              ? const Text("Add new member")
                              : Text("Create Group with ${receiver!.name}"),
                          onTap: () {
                            if (CommonMethods.isAGroup(messageData.receivers)) {
                              // List<User> listAllUser=CommonMethods.getAllUserInChat(messageData., receivers, currentUser)
                              groupController.setValueUserInAChat(receivers);
                              List<String>? allIdUser =
                                  CommonMethods.convertListUserToListStringID(
                                      groupController.allUserInAChat.value);
                              Get.to(() => AddMember(
                                    messageData: messageData,
                                    existedUser: allIdUser,
                                  ));
                            } else {
                              groupController.setValueFortargetUser(receiver);
                              Get.to(() => CreateGroup());
                            }
                          },
                          leading: const Icon(
                            Icons.group_add_outlined,
                            color: Colors.purpleAccent,
                          ),
                        ),
                        const Divider(
                          height: 2,
                          color: Color.fromARGB(255, 42, 42, 42),
                        ),
                        if (CommonMethods.isAGroup(messageData.receivers)) ...{
                          ListTile(
                            title: const Text("Chat members"),
                            onTap: () {
                              Get.to(
                                  () => ViewMembers(messageData: messageData));
                            },
                            leading: const Icon(
                              Icons.people,
                              color: Colors.cyanAccent,
                            ),
                          ),
                          const Divider(
                            height: 2,
                            color: Color.fromARGB(255, 42, 42, 42),
                          ),
                        },
                        ListTile(
                          title: const Text("View media, files and links"),
                          onTap: () {
                            Get.to(() => const ViewMediaLink());
                          },
                          leading: const Icon(
                            Icons.image,
                            color: Colors.greenAccent,
                          ),
                          trailing: const Icon(Icons.navigate_next_sharp),
                        ),
                      ],
                    ),
                  ),
                ),
                if (CommonMethods.isAGroup(messageData.receivers)) ...{
                  if (messageData.idAdmin == currentUser.id) ...{
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color.fromARGB(255, 194, 232, 247)),
                      child: ListTile(
                        title: const Text(
                          "Delete group",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        onTap: () async {
                          Get.defaultDialog(
                            middleText: "Are you sure to delete group chat",
                            title: "Notice",
                            onConfirm: () async {
                              await groupController.deleteGroup(messageData);
                              Future.delayed(const Duration(seconds: 15));
                              Get.back();
                              Get.back();
                              Get.back();
                            },
                            onCancel: () {
                              Get.back();
                            },
                          );
                        },
                        leading: const Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),

                    // ignore: equal_elements_in_set
                    const SizedBox(
                      height: 10,
                    ),
                  } else ...{
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color.fromARGB(255, 194, 232, 247)),
                      child: ListTile(
                        title: const Text(
                          "Leave group",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        onTap: () {
                          Get.defaultDialog(
                            middleText: "Are you sure to leave group chat",
                            title: "Notice",
                            onConfirm: () async {
                              await groupController.leaveGroup(
                                  messageData, currentUser);
                              Future.delayed(const Duration(seconds: 15));
                              Get.back();
                              Get.back();
                              Message msg = Message(
                                  chatMessageType: ChatMessageType.NOTIFICATION,
                                  dateTime: Timestamp.now(),
                                  senderID: currentUser.id,
                                  idMessage: Uuid().v4(),
                                  text: "${currentUser.name} was left",
                                  messageStatus: MessageStatus.RECEIVED);
                              messageController.sendAMessage(msg, messageData);
                            },
                            onCancel: () {
                              Get.back();
                            },
                          );
                        },
                        leading: const Icon(
                          Icons.exit_to_app,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  }
                },
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showDialogChangeGroupName(GroupController groupController,
      User currentUser, MessageController messageController) {
    TextEditingController nameController =
        TextEditingController(text: messageData.chatName!);
    Get.defaultDialog(
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        onConfirm: () async {
          await groupController.updateGroupChat(
              messageData: messageData,
              user: currentUser,
              groupName: nameController.text);
          Future.delayed(const Duration(seconds: 15));
          Get.back();
          Get.back();
          Message msg = Message(
              chatMessageType: ChatMessageType.NOTIFICATION,
              dateTime: Timestamp.now(),
              senderID: currentUser.id,
              idMessage: Uuid().v4(),
              text: "${currentUser.name} changed group name",
              messageStatus: MessageStatus.RECEIVED);
          messageController.sendAMessage(msg, messageData);
        },
        onCancel: () {
          Get.back();
        },
        title: "Group name",
        middleText: "");
  }
}
