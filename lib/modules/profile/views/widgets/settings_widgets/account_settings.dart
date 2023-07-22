import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/profile/views/widgets/settings_widgets/change_password.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class Account extends StatelessWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              height: 60,
              child: ListTile(
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.blue.withOpacity(0.1)),
                  child: const Icon(Icons.privacy_tip, color: Colors.blue),
                ),
                title: const Text("Privacy"),
                trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.navigate_next_sharp)),
              ),
            ),
            const SizedBox(
              height: 3,
            ),
            const Divider(),
            const SizedBox(
              height: 3,
            ),
            if (authController.isGGLogin.value == false &&
                authController.isPhone.value == false) ...{
              InkWell(
                onTap: () {
                  Get.to(() => const ChangePassword());
                },
                child: SizedBox(
                  height: 60,
                  child: ListTile(
                    leading: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.blue.withOpacity(0.1)),
                        child:
                            const Icon(Icons.privacy_tip, color: Colors.blue)),
                    title: const Text("Change password"),
                    trailing: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.navigate_next_sharp)),
                  ),
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              const Divider(),
            },

            const SizedBox(
              height: 3,
            ),
            SizedBox(
              height: 60,
              child: ListTile(
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
                },
                leading: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.redAccent.withOpacity(0.1)),
                  child: const Icon(Icons.logout_outlined,
                      color: Colors.redAccent),
                ),
                title: const Text("Log Out",
                    style: TextStyle(color: Colors.redAccent)),
              ),
            ),
            const SizedBox(
              height: 3,
            ),
            const Divider(),
            const SizedBox(
              height: 3,
            ),
            // SizedBox(
            //   height: 60,
            //   child: ListTile(
            //     onTap: () async {
            //       await authController.deleteAccount();
            //     },
            //     leading: Container(
            //       height: 40,
            //       width: 40,
            //       decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(100),
            //           color: Colors.red.withOpacity(0.1)),
            //       child: const Icon(Icons.delete_outline, color: Colors.red),
            //     ),
            //     title: const Text(
            //       "Delete Account",
            //       style: TextStyle(color: Colors.red),
            //     ),
            //   ),
            // ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }
}
