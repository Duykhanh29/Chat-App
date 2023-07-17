import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/friend/controllers/friend_controller.dart';
import 'package:chat_app/modules/friend/views/widgetss/view_profile.dart';
import 'package:chat_app/modules/profile/views/widgets/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class SentRequestCard extends StatelessWidget {
  SentRequestCard({super.key, required this.user});
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
        height: MediaQuery.of(context).size.height * 0.12,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(user.urlImage!),
            ),
            Text(user.name!),
            SizedBox(
              width: 40,
            ),
            ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.red.shade300),
              ),
              onPressed: () async {
                await friendController.cancelRequest(currentUser!, user);
              },
              child: const Text("Revoke"),
            )
          ],
        ),
      ),
    );
  }
}
