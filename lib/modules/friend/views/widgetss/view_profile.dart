import 'package:chat_app/data/common/methods.dart';
import 'package:chat_app/data/models/friend.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/friend/controllers/friend_controller.dart';
import 'package:chat_app/modules/home/controllers/data_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/chatting_page.dart';
import 'package:chat_app/service/storage_service.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class ViewProfile extends StatelessWidget {
  ViewProfile({super.key, required this.user});
  User user;
  Storage storage = Storage();
  @override
  Widget build(BuildContext context) {
    final friendController = Get.find<FriendController>();
    final authController = Get.find<AuthController>();
    User? currentUser = authController.currentUser.value;
    double coverHeight = MediaQuery.of(context).size.height * 0.3;
    double profileHeight = MediaQuery.of(context).size.height * 0.25;
    double top = coverHeight - profileHeight / 2;
    String urlprofile =
        "https://kaleidousercontent.com/removebg/designs/4621cf76-fb41-4177-bc33-f12a67816592/thumbnail_image/change-background-thumbnail.png";
    String urlCoverImage =
        "https://t3.ftcdn.net/jpg/05/23/07/10/360_F_523071045_X1O9AKUHikkPSlkWd9BQ7qMLUHXAnqW1.jpg";
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Stack(
                alignment: Alignment.topLeft,
                clipBehavior: Clip.none,
                children: [
                  buildCoverImage(coverHeight, user.urlCoverImage!),
                  Positioned(
                    top: coverHeight / 5,
                    // left: 10,
                    // right: 10,
                    // bottom: 10,
                    child: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(
                        Icons.navigate_before_rounded,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),

              Positioned(
                top: top,
                child: buildProfileImage(profileHeight, user.urlImage!),
              ),
              const SizedBox(
                height: 10,
              ),
              // Text("Toni"),
            ],
          ),
          Container(
            // decoration: BoxDecoration(color: Colors.red),
            height: (profileHeight / 2) + 30,
          ),
          Text(
            user.name!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 30,
            ),
          ),
          // const SizedBox(
          //   height: 40,
          // ),
          BuildStream(
              friendController: friendController,
              user: user,
              currentUser: currentUser)
        ],
      ),
    );
  }

  Widget buildCoverImage(double coverHeight, String urlCoverImage) =>
      GestureDetector(
        onTap: () {
          Get.to(
            () => Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                actions: [
                  IconButton(
                      onPressed: () async {
                        await storage.downloadFileToLocalDevice(
                            urlCoverImage, "image");
                      },
                      icon: const Icon(Icons.download_outlined))
                ],
              ),
              body: Container(
                child: PhotoView(
                  minScale: PhotoViewComputedScale.covered,
                  maxScale: PhotoViewComputedScale.covered,
                  imageProvider: NetworkImage(urlCoverImage),
                  backgroundDecoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          );
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 5),
          width: double.infinity,
          height: coverHeight,
          color: Colors.grey,
          child: Image.network(
            urlCoverImage,
            fit: BoxFit.cover,
          ),
        ),
      );
  Widget buildProfileImage(double profileHeight, String url) => GestureDetector(
        onTap: () {
          Get.to(
            () => Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                actions: [
                  IconButton(
                      onPressed: () async {
                        await storage.downloadFileToLocalDevice(url, "image");
                      },
                      icon: const Icon(Icons.download_outlined))
                ],
              ),
              body: Container(
                child: PhotoView(
                  minScale: PhotoViewComputedScale.covered,
                  maxScale: PhotoViewComputedScale.covered,
                  imageProvider: NetworkImage(url),
                  backgroundDecoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          );
        },
        child: CircleAvatar(
          radius: profileHeight / 2,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: NetworkImage(url),
        ),
      );
}

class BuildStream extends StatelessWidget {
  const BuildStream({
    super.key,
    required this.friendController,
    required this.user,
    required this.currentUser,
  });

  final FriendController friendController;
  final User user;
  final User? currentUser;

  @override
  Widget build(BuildContext context) {
    final dataController = Get.find<DataController>();
    final messageController = Get.find<MessageController>();
    List<User>? listAllUser = dataController.listAllUser.value;

    return StreamBuilder<Friends?>(
      stream: friendController.getFriend(currentUser!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none) {
          return Container();
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.hasData) {
            List<User>? friends = CommonMethods.getListUserFromFriends(
                snapshot.data!.listFriend!, listAllUser);
            List<User>? sentList = CommonMethods.getListUserFromFriends(
                snapshot.data!.requestedList!, listAllUser);
            List<User>? receivedList = CommonMethods.getListUserFromFriends(
                snapshot.data!.queueList!, listAllUser);
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
              child: currentUser!.id == user.id
                  ? Center(
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                          minimumSize:
                              MaterialStateProperty.all(const Size(120, 40)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blueGrey),
                        ),
                        onPressed: () {
                          var messageData = messageController
                              .getMessageDataOneByOne(currentUser!, user);

                          if (messageData == null) {
                            List<String> list = [];
                            CommonMethods.addToReceiverListOneByOne(
                                list: list,
                                receiver: currentUser!.id,
                                sender: currentUser!.id);
                            print("Lrht: ${list.length}");
                            MessageData newMessageData = MessageData(
                                // sender: currentUser,
                                listMessages: [],
                                receivers: list);
                            messageController.addNewChat(
                                newMessageData); // because of this user haven't chatted with me before
                            Get.to(() => ChattingPage(),
                                arguments: newMessageData);
                          } else {
                            //  messageData.showALlAttribute();
                            Get.to(() => ChattingPage(),
                                arguments: messageData);
                          }
                        },
                        icon: const Icon(Icons.message_rounded),
                        label: const Text("Message"),
                      ),
                    )
                  : Options(friends, receivedList, sentList),
            );
          } else {
            return Container();
          }
        }
      },
    );
  }

  Widget Options(
      List<User>? friends, List<User>? receivedList, List<User>? sentList) {
    final messageController = Get.find<MessageController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (CommonMethods.isFriend(user.id!, friends)) ...{
          ElevatedButton.icon(
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(const Size(120, 40)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            ),
            onPressed: () {},
            icon: const Icon(
              Icons.person_2_outlined,
              color: Colors.blueAccent,
            ),
            label: const Text("Friend"),
          ),
        } else if (CommonMethods.isSentRequest(user.id!, sentList)) ...{
          ElevatedButton.icon(
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(const Size(120, 40)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            ),
            onPressed: () async {
              await friendController.cancelRequest(currentUser!, user);
            },
            icon: const Icon(
              Icons.cancel_sharp,
              color: Colors.redAccent,
            ),
            label: const Text("Cancel"),
          ),
        } else if (CommonMethods.isReceivedRequest(user.id!, receivedList)) ...{
          Flexible(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(const Size(120, 40)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  onPressed: () async {
                    await friendController.acceptRequest(currentUser!, user);
                  },
                  icon: const Icon(
                    Icons.check_circle,
                    color: Colors.amber,
                  ),
                  label: const Text("Confirm"),
                ),
                ElevatedButton.icon(
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(const Size(120, 40)),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green),
                  ),
                  onPressed: () async {
                    await friendController.removeRequest(currentUser!, user);
                  },
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.brown,
                  ),
                  label: const Text("Remove"),
                ),
              ],
            ),
          ),
        } else ...{
          ElevatedButton.icon(
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(const Size(120, 40)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
            ),
            onPressed: () async {
              await friendController.addFriend(currentUser, user);
            },
            icon: const Icon(Icons.person_add_alt_1),
            label: const Text("Add friend"),
          ),
        },
        if (CommonMethods.isReceivedRequest(user.id!, receivedList)) ...{
          Flexible(
            flex: 1,
            child: ElevatedButton.icon(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(const Size(120, 40)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.blueGrey),
              ),
              onPressed: () {
                var messageData = messageController.getMessageDataOneByOne(
                    currentUser!, user);

                if (messageData == null) {
                  List<String> list = [];
                  CommonMethods.addToReceiverListOneByOne(
                      list: list, receiver: user.id, sender: currentUser!.id);
                  MessageData newMessageData = MessageData(
                      // sender: currentUser,
                      listMessages: [],
                      receivers: list);
                  messageController.addNewChat(
                      newMessageData); // because of this user haven't chatted with me before
                  Get.to(() => ChattingPage(), arguments: newMessageData);
                } else {
                  //  messageData.showALlAttribute();
                  Get.to(() => ChattingPage(), arguments: messageData);
                }
              },
              icon: const Icon(Icons.message_rounded),
              label: const Text("Message"),
            ),
          ),
        } else ...{
          ElevatedButton.icon(
            style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(const Size(120, 40)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.blueGrey),
            ),
            onPressed: () {
              var messageData =
                  messageController.getMessageDataOneByOne(currentUser!, user);

              if (messageData == null) {
                List<String> list = [];
                CommonMethods.addToReceiverListOneByOne(
                    list: list, receiver: user.id, sender: currentUser!.id);
                MessageData newMessageData = MessageData(
                    // sender: currentUser,
                    listMessages: [],
                    receivers: list);
                messageController.addNewChat(
                    newMessageData); // because of this user haven't chatted with me before
                Get.to(() => ChattingPage(), arguments: newMessageData);
              } else {
                //  messageData.showALlAttribute();
                Get.to(() => ChattingPage(), arguments: messageData);
              }
            },
            icon: const Icon(Icons.message_rounded),
            label: const Text("Message"),
          ),
        }
      ],
    );
  }
}
