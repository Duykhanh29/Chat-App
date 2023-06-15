import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/auth/views/widgets/forget_pass_page.dart';

import '../widgets/register.dart';
import 'package:chat_app/modules/home/views/main_view.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/service/auth.dart';

class LogInWithEmail extends StatefulWidget {
  const LogInWithEmail({super.key});

  @override
  State<LogInWithEmail> createState() => _LogInWithEmailState();
}

class _LogInWithEmailState extends State<LogInWithEmail> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  String? errorMessage = '';
  bool isVisible = true;
  final formKey = GlobalKey<FormState>();
  Future<void> signInWithEmail() async {
    try {
      await AuthService().signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      Get.to(() => MainView());
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmail() async {
    try {
      await AuthService().createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
        print("Error message: $errorMessage");
      });
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
                SizedBox(
                  width: 15,
                ),
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6),
                  child: Text.rich(
                    TextSpan(
                      text: "Login to your Account",
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
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Input again";
                      } else {
                        if (errorMessage != '') {
                          print(errorMessage);
                          return errorMessage;
                        }
                        return null;
                      }
                    },
                    controller: emailController,
                    decoration: InputDecoration(
                        focusedErrorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.pink)),
                        errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red)),
                        hintText: "Email",
                        prefixIcon: const Icon(Icons.email_rounded),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15))),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Input again";
                      } else {
                        if (errorMessage != '') {
                          return errorMessage;
                        }
                        return null;
                      }
                    },
                    controller: passwordController,
                    decoration: InputDecoration(
                        hintText: "Password",
                        focusedErrorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.pink)),
                        errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red)),
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
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.to(() => const ForgetPassPage());
                    },
                    child: const Text(
                      "Forget password",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w600),
                    ),
                  )
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
                    final isValid = formKey.currentState!.validate();
                    if (isValid) {
                      await controller.signInWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text);
                    }
                  },
                  child: const Text("Sign in",
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
                const Text("Don't have an account?"),
                const SizedBox(
                  width: 2,
                ),
                TextButton(
                    onPressed: () {
                      Get.to(() => Register());
                    },
                    child: const Text("Sign up"))
              ],
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
