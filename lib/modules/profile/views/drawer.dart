import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/profile/controllers/profile_controller.dart';
import 'package:chat_app/modules/profile/views/widgets/profile_view.dart';
import 'package:chat_app/modules/profile/views/widgets/settings.dart';
import 'package:chat_app/utils/helpers/dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final profileController = Get.find<ProfileController>();
    final User currentUser = authController.currentUser.value!;
    return Drawer(
      width: 280,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Obx(() {

          //   return
          UserAccountsDrawerHeader(
            accountName: Text(currentUser.name!),
            accountEmail: Text(currentUser.email!),
            currentAccountPicture: CircleAvatar(
              radius: 60,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: currentUser.urlImage == null
                    ? NetworkImage(
                        "https://vn.jugomobile.com/wp-content/uploads/2023/02/Phat-truc-tiep-Al-Nassr-vs-Al-Taawoun-kenh-truyen.jpg?w=640")
                    : NetworkImage(authController.currentUser.value!.urlImage!),
              ),
            ),
          ),
          //}),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('My Profile'),
            onTap: () {
              Get.to(() => const ProfileView());
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              Get.to(() => SettingsPage());
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              'LogOut',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: const Text("Log out"),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: const [
                          Text("Are you sure want to log out?"),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('No'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Yes'),
                        onPressed: () async {
                          await authController.signOut();
                        },
                      ),
                    ],
                  );
                },
              );
              // Dialogs.displayDialog(
              //     context,
              //     "Log out",
              //     "Are you sure want to log out?",
              //     );
            },
          ),
        ],
      ),
    );
  }
}
