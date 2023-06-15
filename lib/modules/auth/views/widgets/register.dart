import 'package:chat_app/modules/auth/controllers/auth_controller.dart';

import '../startPage.dart';
import 'package:chat_app/modules/group/views/group_view.dart';
import 'package:chat_app/modules/messeger/views/message_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/service/auth.dart';

class Register extends StatefulWidget {
  Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  var confirmPasswordController = TextEditingController();

  String? errorMessage = '';

  bool isVisible = true;
  bool isVisibleConfirm = true;

  final formKey = GlobalKey<FormState>();
  Future<void> createUserWithEmail() async {
    try {
      await AuthService().createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      Get.to(() => GroupView());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      errorMessage = e.message;
      print("Error message: $errorMessage");
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   backgroundColor: Colors.white70,
      // ),

      body: Padding(
        padding:
            const EdgeInsets.only(bottom: 10, right: 15, left: 15, top: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 15,
                ),
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6),
                  child: const Text.rich(
                    TextSpan(
                      text: "Create your Account",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
            Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextFormField(
                    autofocus: false,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Input again";
                      } else {
                        // if (errorMessage != '') {
                        //   print(errorMessage);
                        //   return errorMessage;
                        // }
                        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                            .hasMatch(value)) {
                          return ("Please Enter a valid email");
                        }
                        return null;
                      }
                    },
                    controller: emailController,
                    decoration: InputDecoration(
                        hintText: "Email",
                        prefixIcon: const Icon(Icons.email_rounded),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15))),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    validator: (value) {
                      RegExp regex = new RegExp(r'^.{6,}$');
                      if (value!.isEmpty) {
                        return "Input again";
                      } else {
                        // if (errorMessage != '') {
                        //   print(errorMessage);
                        //   return errorMessage;
                        // }
                        if (!regex.hasMatch(value)) {
                          return ("Enter Valid Password(Min. 6 Character)");
                        }
                        return null;
                      }
                    },
                    controller: passwordController,
                    decoration: InputDecoration(
                        //     errorText: errorMessage,
                        hintText: "Password",
                        // errorBorder: const OutlineInputBorder(
                        //     borderSide: BorderSide(color: Colors.red)),
                        prefixIcon: const Icon(Icons.lock_rounded),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isVisible = !isVisible;
                              });
                            },
                            icon: isVisible
                                ? const Icon(Icons.visibility_rounded)
                                : const Icon(Icons.visibility_off_rounded)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15))),
                    obscureText: isVisible,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    validator: (value) {
                      RegExp regex = new RegExp(r'^.{6,}$');
                      if (value!.isEmpty) {
                        return "Input again";
                      } else {
                        // if (errorMessage != '') {
                        //   print(errorMessage);
                        //   return errorMessage;
                        // }
                        if (!regex.hasMatch(value)) {
                          return ("Enter Valid Password(Min. 6 Character)");
                        } else if (value != passwordController.text) {
                          return ("The password doesn't macth");
                        }
                        return null;
                      }
                    },
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                        //     errorText: errorMessage,
                        hintText: "Confirm password",
                        // errorBorder: const OutlineInputBorder(
                        //     borderSide: BorderSide(color: Colors.red)),
                        prefixIcon: const Icon(Icons.lock_rounded),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isVisibleConfirm = !isVisibleConfirm;
                              });
                            },
                            icon: isVisibleConfirm
                                ? const Icon(Icons.visibility_rounded)
                                : const Icon(Icons.visibility_off_rounded)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15))),
                    obscureText: isVisibleConfirm,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black26)),
              clipBehavior: Clip.antiAlias,
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    var isValid = formKey.currentState!.validate();
                    if (isValid) {
                      await controller.createUserWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text);
                    }
                  },
                  child: const Text("Sign up",
                      style: TextStyle(color: Colors.black))),
            ),
            const SizedBox(height: 40),
            Row(
              children: const <Widget>[
                Expanded(
                  child: Divider(
                    color: Colors.black,
                    height: 20,
                    thickness: 0.2,
                    indent: 25,
                    endIndent: 8,
                  ),
                ),
                Text(
                  "Or continue with",
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.black,
                    height: 20,
                    thickness: 0.2,
                    indent: 8,
                    endIndent: 25,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  // splashColor: Colors.red,
                  onTap: () {
                    print("on tap");
                  },
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black26),
                      // color: Colors.blue
                    ),
                    width: 60,
                    height: 45,
                    padding: const EdgeInsets.all(11),
                    child: Image.asset(
                      "assets/images/google-logo.png",
                      width: 10,
                      height: 10,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black26),
                      // color: Colors.blue
                    ),
                    width: 60,
                    height: 45,
                    padding: const EdgeInsets.all(11),
                    child: const Icon(
                      Icons.facebook_rounded,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                InkWell(
                  onTap: () {},
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black26),
                      // color: Colors.blue
                    ),
                    width: 60,
                    height: 45,
                    padding: const EdgeInsets.all(11),
                    child: const Icon(
                      Icons.phone_rounded,
                      color: Colors.blue,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                const SizedBox(
                  width: 2,
                ),
                TextButton(
                    onPressed: () {
                      Get.to(() => const StartPage());
                    },
                    child: const Text("Sign in"))
              ],
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
