import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/profile/controllers/profile_controller.dart';
import 'package:chat_app/service/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    // Get.put(AuthController());
    // Get.put(
    //     ProfileController()); // need to consider when it comes to deployment, because of the performnace
    final authController = Get.find<AuthController>();
    final controller = Get.find<ProfileController>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
            onPressed: () {
              authController.resetEditUser();
              Get.back();
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    SizedBox(
                      height: 170,
                      width: 170,
                      child: GestureDetector(
                        onTap: () {
                          Get.to(
                            () => Scaffold(
                              appBar: AppBar(
                                actions: [
                                  IconButton(
                                      onPressed: () {
                                        print("Download photo");
                                      },
                                      icon: const Icon(Icons.download_outlined))
                                ],
                              ),
                              body: Container(
                                child: PhotoView(
                                  imageProvider: authController
                                              .currentUser.value!.urlImage ==
                                          null
                                      ? NetworkImage(
                                          "https://vn.jugomobile.com/wp-content/uploads/2023/02/Phat-truc-tiep-Al-Nassr-vs-Al-Taawoun-kenh-truyen.jpg?w=640")
                                      : NetworkImage(authController
                                          .currentUser.value!.urlImage!),
                                  backgroundDecoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 90,
                          backgroundColor:
                              authController.currentUser.value!.story
                                  ? Colors.blue
                                  : const Color.fromARGB(255, 239, 242, 244),
                          child: CircleAvatar(
                            radius: 80,
                            backgroundImage: authController
                                        .currentUser.value!.urlImage ==
                                    null
                                ? NetworkImage(
                                    "https://vn.jugomobile.com/wp-content/uploads/2023/02/Phat-truc-tiep-Al-Nassr-vs-Al-Taawoun-kenh-truyen.jpg?w=640")
                                : NetworkImage(authController
                                    .currentUser.value!.urlImage!),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: GestureDetector(
                        onTap: () {
                          print("Change photo");
                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.orange,
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ),
              const SizedBox(
                height: 20,
              ),
              const Divider(
                height: 2,
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: RichText(
                    text: const TextSpan(children: [
                  TextSpan(
                    text: 'Name',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                    ),
                  ),
                  TextSpan(
                    text: '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ])),
              ),
              const SizedBox(
                height: 5,
              ),

              Obx(
                () => TextField(
                  controller: authController.nameController.value,
                  decoration: InputDecoration(
                      hintText: "Name",
                      prefixIcon: const Icon(Icons.verified_user_rounded),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25))),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "Email",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Obx(
                () => TextFormField(
                  controller: authController.emailController.value,
                  decoration: InputDecoration(
                      hintText: "Email",
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25))),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "Phone",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              TextFormField(
                controller: authController.phoneController.value,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    hintText: "Phone",
                    prefixIcon: const Icon(Icons.phone_android),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25))),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  final isValid = formKey.currentState!.validate();
                  if (isValid) {
                    print(
                        "New phone: ${authController.phoneController.value.text}, new name: ${authController.nameController.value.text} and new email: ${authController.emailController.value.text}");
                    await authController.editUser(
                        phone: authController.phoneController.value.text,
                        email: authController.emailController.value.text,
                        name: authController.nameController.value.text);
                    print("Check now which value: \n");
                    authController.currentUser.value!.showALlAttribute();
                  } else {
                    print("Invalid form");
                  }
                },
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.greenAccent),
                  child: const Center(
                    child: Text(
                      "Change",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
