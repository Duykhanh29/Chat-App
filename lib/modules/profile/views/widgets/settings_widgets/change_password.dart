import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final formKey = GlobalKey<FormState>();
  var currentPass = TextEditingController();

  var passwordController = TextEditingController();

  var confirmPasswordController = TextEditingController();
  bool isVisible = true;
  bool isVisibleConfirm = true;
  bool isVisibleCurrent = true;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
              controller.resetIsUpdateInfor();
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: const Text("Change password"),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(bottom: 10, right: 15, left: 15, top: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
                        // ignore: unrelated_type_equality_checks
                        // bool idValid =
                        //     controller.isValidCurrentPassword(value) as bool;
                        // controller.changeIsUpdateInforToTrue();
                        // if (controller.isValidCurrentPassword(value) == true) {
                        return null;
                        // } else {
                        //   return "Wrong password";
                        // }
                      }
                    },
                    controller: currentPass,
                    decoration: InputDecoration(
                      hintText: "Current password",
                      prefixIcon: const Icon(Icons.lock_rounded),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isVisibleCurrent = !isVisibleCurrent;
                            });
                          },
                          icon: isVisibleCurrent
                              ? const Icon(Icons.visibility_rounded)
                              : const Icon(Icons.visibility_off_rounded)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    obscureText: isVisibleCurrent,
                  ),
                  const SizedBox(height: 30),
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
                  const SizedBox(height: 30),
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
            // const SizedBox(height: 30),
            const Spacer(),
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
                      controller.changeIsUpdateInforToTrue();
                      bool isValidCurrentPass = await controller
                          .isValidCurrentPassword(currentPass.text);
                      if (isValidCurrentPass) {
                        await controller
                            .changePassword(
                                newPass: confirmPasswordController.text,
                                oldPass: currentPass.text,
                                email: controller.currentUser.value!.email!)
                            .whenComplete(() {
                          Get.snackbar("Success", "",
                              snackPosition: SnackPosition.TOP,
                              titleText: const Text("Change successfully"),
                              backgroundColor: Colors.greenAccent);
                        });
                      } else {
                        Get.snackbar("Failed", "Failed",
                            snackPosition: SnackPosition.TOP,
                            titleText: const Text("Wrong password"),
                            backgroundColor: Colors.redAccent);
                      }
                    } else {
                      Get.snackbar("Failed", "",
                          snackPosition: SnackPosition.TOP,
                          titleText: const Text("Fail to change password"),
                          backgroundColor: Colors.redAccent);
                    }
                  },
                  child: const Text("Change",
                      style: TextStyle(color: Colors.black))),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
