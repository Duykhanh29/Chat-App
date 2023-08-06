import 'package:chat_app/data/common/methods.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/friend/controllers/friend_controller.dart';
import 'package:chat_app/modules/friend/views/widgetss/view_profile.dart';
import 'package:chat_app/modules/profile/views/widgets/profile_view.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:chat_app/service/notification_service.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_app/data/models/user.dart';

class ReceivedRequestCard extends StatelessWidget {
  ReceivedRequestCard({super.key, required this.user});
  User user;
  @override
  Widget build(BuildContext context) {
    final friendController = Get.find<FriendController>();
    final authController = Get.find<AuthController>();
    User? currentUser = authController.currentUser.value;
    return InkWell(
      onTap: () {
        Get.to(() => ViewProfile(
              user: user,
            ));
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        height: MediaQuery.of(context).size.height * 0.12,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.grey,
            //     blurRadius: 10,
            //   )
            // ],
            color: Colors.blueGrey.shade100),
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.23,
              child: Center(
                child: Text("Time"),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(user.urlImage!),
              ),
              title: Text(user.name!),
              trailing: FittedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: () async {
                        await friendController.acceptRequest(
                            currentUser!, user);
                        String tokens = user.token!;
                        NotificationService.sendPushMessage(
                            [tokens],
                            "${currentUser.name} accepted friend request",
                            "Friend request",
                            Paths.FRIENDS,
                            "");
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
                            currentUser!, user);
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
