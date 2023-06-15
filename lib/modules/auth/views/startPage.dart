import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/auth/views/widgets/login_with_email.dart';
import 'package:chat_app/modules/auth/views/widgets/login_with_phone.dart';
import 'package:chat_app/modules/home/controllers/home_controller.dart';
import 'package:chat_app/modules/home/views/main_view.dart';
import 'package:chat_app/service/auth.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'widgets/register.dart';

class StartPage extends GetView<AuthController> {
  const StartPage({super.key});
  Future signInWithGG() async {
    try {
      var user = await controller.signInWithGoogle();
      if (user != null) {
        Get.to(() => MainView());
      }
    } catch (e) {
      print("Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                controller.signOut();
              },
              icon: const Icon(Icons.logout_rounded))
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(
              "Let's you in",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 80,
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black26)),
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    //    await controller.signInWithFacebook();
                  },
                  icon: const Icon(
                    Icons.facebook_rounded,
                    color: Colors.blue,
                  ),
                  label: const Text("Continue with facebook",
                      style: TextStyle(color: Colors.black))),
            ),
            const SizedBox(
              height: 25,
            ),
            Container(
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black26)),
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    await controller.signInWithGoogle();
                  },
                  icon: Image.asset(
                    "assets/images/google-logo.png",
                    width: 22,
                    height: 22,
                  ),
                  label: const Text("Continue with Google",
                      style: TextStyle(color: Colors.black))),
            ),
            const SizedBox(
              height: 25,
            ),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black26)),
              child: ElevatedButton.icon(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Get.to(() => const LoginWithPhone());
                  },
                  icon: const Icon(
                    Icons.phone_rounded,
                    color: Colors.blue,
                  ),
                  label: const Text("Continue with phone number",
                      style: TextStyle(color: Colors.black))),
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              children: const <Widget>[
                Expanded(
                  child: Divider(
                    color: Colors.black,
                    height: 20,
                    thickness: 0.2,
                    indent: 55,
                    endIndent: 15,
                  ),
                ),
                Text(
                  "Or",
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.black,
                    height: 20,
                    thickness: 0.2,
                    indent: 15,
                    endIndent: 55,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blueAccent),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Get.to(() => const LogInWithEmail());
                  },
                  child: const Text("Sign in with email"),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account"),
                TextButton(
                    onPressed: () {
                      Get.to(() => Register());
                    },
                    child: const Text("Sign up"))
              ],
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
