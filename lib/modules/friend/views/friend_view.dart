import 'package:chat_app/data/common/methods.dart';
import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/friend/controllers/friend_controller.dart';
import 'package:chat_app/modules/friend/views/widgetss/request_friend.dart';
import 'package:chat_app/modules/home/controllers/data_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/utils/constants/image_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:chat_app/modules/auth/views/startPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './widgetss/view_profile.dart';

class FriendView extends GetView<FriendController> {
  FriendView({super.key});
  final List<String> emoticons = [
    '😊',
    '😂',
    '😍',
    '😢',
    '😡',
    '😱',
    '😴',
    '🤢',
    '🤔',
  ];

  @override
  Widget build(BuildContext context) {
    Get.put(
        FriendController()); // need to consider when it comes to deployment, because of the performnace
    final controller = Get.find<FriendController>();
    final msgController = Get.find<MessageController>();
    final authController = Get.find<AuthController>();

    final msgData = FirebaseFirestore.instance
        .collection('messageDatas')
        .doc('a3364063-7f2a-403e-b4b2-23f41296cc12');

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Friends'),
      ),
      body: Container(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            RequestCard(),
            const Divider(
              height: 3,
              color: Color.fromARGB(255, 157, 161, 163),
            ),
            Obx(
              () {
                User? currentUser = authController.currentUser.value;
                return ListFriend(currentUser: currentUser);
              },
            )
          ],
        ),
      ),
      //  ),
    );
    //  StreamBuilder(
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       final messageData = snapshot.data!;
    //       final listMessages =
    //           messageData.data()!['listMessages'] as List<dynamic>;
    //       final messages =
    //           listMessages.map((e) => Message.fromJson(e)).toList();
    //       return ListView.builder(
    //         itemCount: messages.length,
    //         itemBuilder: (context, index) {
    //           return Text(messages[index].text ?? "FIle");
    //         },
    //       );
    //     } else {
    //       return const Center(
    //         child: CircularProgressIndicator(),
    //       );
    //     }
    //   },
    //   stream: msgData.snapshots(),
    // ),
  }
}

class RequestCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const RequestFriend());
      },
      child: Container(
        margin: const EdgeInsets.only(left: 2, right: 10),
        child: Card(
          elevation: 4,
          // color: Colors.greenAccent.shade100,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10), // Điều chỉnh độ cong của góc
          ),
          child: Container(
            // margin: const EdgeInsets.only(left: 2, right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.greenAccent.shade100,
            ),
            height: MediaQuery.of(context).size.height * 0.07,
            child: const Center(
              child: ListTile(
                leading: Icon(Icons.people_rounded),
                title: Text("Friend request"),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ListFriend extends StatelessWidget {
  ListFriend({super.key, required this.currentUser});
  User? currentUser;
  @override
  Widget build(BuildContext context) {
    final friendController = Get.find<FriendController>();
    final dataController = Get.find<DataController>();

    return StreamBuilder(
      stream: friendController.getFriend(currentUser!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none) {
          return Column(
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
            ],
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.data != null) {
            // return Obx(
            //   () {

            return Expanded(
              // child:
              // Theme(
              //     data: Theme.of(context).copyWith(
              //         scrollbarTheme: ScrollbarThemeData(
              //             thumbColor:
              //                 MaterialStateProperty.all<Color>(Colors.blueAccent))),
              //     child: Scrollbar(

              child: Obx(
                () {
                  final listALlUser = dataController.listAllUser.value;
                  List<User>? listFriend = CommonMethods.getListUserFromFriends(
                      snapshot.data!.listFriend!, listALlUser);
                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: List.generate(
                      listFriend!.length,
                      (index) {
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => ViewProfile(
                                  user: listFriend[index],
                                ));
                          },
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.1,
                            decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(15)),
                            margin: const EdgeInsets.fromLTRB(3, 2, 10, 2),
                            padding: const EdgeInsets.all(5),
                            child: Center(
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 40,
                                  backgroundImage:
                                      NetworkImage(listFriend[index].urlImage!),
                                ),
                                title: Text(listFriend[index].name!),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              // );
              // },
            );
          } else {
            return Text("Null");
          }
        }
      },
    )
        //  ),
        //     ),
        ;
  }
}
