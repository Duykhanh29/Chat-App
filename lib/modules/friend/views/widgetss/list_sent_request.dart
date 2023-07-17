import 'package:chat_app/data/common/methods.dart';
import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/friend/controllers/friend_controller.dart';
import 'package:chat_app/modules/friend/views/widgetss/sent_request_card.dart';
import 'package:chat_app/modules/home/controllers/data_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class ListSentRequest extends StatelessWidget {
  const ListSentRequest({super.key});

  @override
  Widget build(BuildContext context) {
    final friendController = Get.find<FriendController>();
    final dataController = Get.find<DataController>();
    final authController = Get.find<AuthController>();
    User? currentUser = authController.currentUser.value;
    final listAllUser = dataController.listAllUser.value;
    return StreamBuilder(
      stream: friendController.getFriend(currentUser!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none) {
          return Container();
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          List<User>? listQueueFriends = CommonMethods.getListUserFromFriends(
              snapshot.data!.requestedList!, listAllUser);
          return Padding(
            padding: const EdgeInsets.all(5),
            child: ListView.builder(
              itemBuilder: (context, index) {
                return SentRequestCard(user: listQueueFriends[index]);
              },
              itemCount: listQueueFriends!.length,
            ),
          );
        }
      },
    );
  }
}
