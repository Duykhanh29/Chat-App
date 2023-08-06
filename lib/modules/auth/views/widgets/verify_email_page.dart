import 'dart:async';
import 'package:chat_app/modules/auth/views/widgets/register.dart';
import 'package:flutter/cupertino.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/home/views/main_view.dart';
import 'package:chat_app/utils/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  AuthController authController = AuthController();
  Timer? timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    User? user = firebaseAuth.currentUser;
    authController.sendVerificationEmail(user);
    timer = Timer.periodic(const Duration(seconds: 50), (data) async {
      await checkEmailVerified(user);
    });
  }

  // mặc dù xác minh xong rồi, và có chạy tới hàm dưới nhưng giá trị vẫn là fasle.
  // xong đó lại chạy tới initialScreen và lạ thay giá trị emailVerified lại là true.
  Future checkEmailVerified(User? user) async {
    await user!.reload();
    setState(() {
      authController.isEMailVerified.value = user.emailVerified;
    });
    if (authController.isEMailVerified.value) {
      timer!.cancel();
      authController.changeEmailVerified();
      authController.addUserToFirebase(user);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              timer!.cancel();
              authController.signOut();
              firebaseAuth.currentUser!.delete();
              // Get.to(() => Register());
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Obx(
            () => authController.isLoad.value
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                        Text("Loading"),
                        SizedBox(
                          height: 15,
                        ),
                        SizedBox(
                          width: 200,
                          child: LinearProgressIndicator(),
                        )
                      ])
                : const Text("Verify email"),
          ),
        ),
      ),
    );
  }
}
