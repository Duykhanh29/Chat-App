import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/profile/controllers/profile_controller.dart';
import 'package:chat_app/service/auth.dart';
import 'package:chat_app/service/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final formKey = GlobalKey<FormState>();
  Storage storage = Storage();
  @override
  Widget build(BuildContext context) {
    // Get.put(AuthController());
    // Get.put(
    //     ProfileController()); // need to consider when it comes to deployment, because of the performnace
    final authController = Get.find<AuthController>();
    final controller = Get.find<ProfileController>();
    User? currentUser = authController.currentUser.value;
    final messageController = Get.find<MessageController>();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
            onPressed: () {
              authController.resetEditUser();
              Get.back();
              if (authController.isUpdateInfor.value) {
                authController.resetIsUpdateInfor();
              }
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          BuildImage(
              currentUser: currentUser,
              storage: storage,
              authController: authController),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // ),
                    const SizedBox(
                      height: 30,
                    ),
                    // const Divider(
                    //   height: 2,
                    // ),
                    // const SizedBox(
                    //   height: 20,
                    // ),
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

                    BuildNameController(authController: authController),
                    const SizedBox(
                      height: 15,
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

                    BuildEmailController(authController: authController),
                    const SizedBox(
                      height: 15,
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
                    BuildPhoneController(authController: authController),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        final isValid = formKey.currentState!.validate();
                        if (isValid) {
                          print(
                              "New phone: ${authController.phoneController.value.text}, new name: ${authController.nameController.value.text} and new email: ${authController.emailController.value.text}");
                          // await authController.editUser(
                          //     phone: authController.phoneController.value.text,
                          //     email: authController.emailController.value.text,
                          //     name: authController.nameController.value.text);
                          await authController.updateUserToFirebase(
                            uid: currentUser!.id!,
                            email: authController.emailController.value.text,
                            name: authController.nameController.value.text,
                            phone: authController.phoneController.value.text,
                          );
                          authController.changeIsUpdateInforToTrue();
                          print("Check now which value: \n");
                          authController.currentUser.value!.showALlAttribute();
                          await messageController.updateListAllUser();
                        } else {
                          print("Invalid form");
                        }
                      },
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.greenAccent),
                        child: const Center(
                          child: Text(
                            "Change",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
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
          ),
        ],
      ),
    );
  }
}

class BuildPhoneController extends StatefulWidget {
  const BuildPhoneController({
    super.key,
    required this.authController,
  });

  final AuthController authController;

  @override
  State<BuildPhoneController> createState() => _BuildPhoneControllerState();
}

class _BuildPhoneControllerState extends State<BuildPhoneController> {
  bool readOnly = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly,
      controller: widget.authController.phoneController.value,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
          suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  readOnly = !readOnly;
                });
              },
              icon: Icon(readOnly == true
                  ? Icons.lock_open_rounded
                  : Icons.lock_rounded)),
          isDense: true, // Kích thước gọn nhẹ
          contentPadding: const EdgeInsets.symmetric(
              vertical: 17), // Điều chỉnh kích thước chiều cao

          hintText: "Phone",
          prefixIcon: const Icon(Icons.phone_android),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
    );
  }
}

class BuildEmailController extends StatefulWidget {
  const BuildEmailController({
    super.key,
    required this.authController,
  });

  final AuthController authController;

  @override
  State<BuildEmailController> createState() => _BuildEmailControllerState();
}

class _BuildEmailControllerState extends State<BuildEmailController> {
  bool readOnly = true;
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextFormField(
        readOnly: readOnly,
        controller: widget.authController.emailController.value,
        decoration: InputDecoration(
            suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    readOnly = !readOnly;
                  });
                },
                icon: Icon(readOnly == true
                    ? Icons.lock_open_rounded
                    : Icons.lock_rounded)),
            isDense: true, // Kích thước gọn nhẹ
            contentPadding: const EdgeInsets.symmetric(
                vertical: 17), // Điều chỉnh kích thước chiều cao

            hintText: "Email",
            prefixIcon: const Icon(Icons.email),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
      ),
    );
  }
}

class BuildNameController extends StatefulWidget {
  const BuildNameController({
    super.key,
    required this.authController,
  });

  final AuthController authController;

  @override
  State<BuildNameController> createState() => _BuildNameControllerState();
}

class _BuildNameControllerState extends State<BuildNameController> {
  bool readOnly = true;
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextField(
        readOnly: readOnly,
        controller: widget.authController.nameController.value,
        decoration: InputDecoration(
            suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    readOnly = !readOnly;
                  });
                },
                icon: Icon(readOnly == true
                    ? Icons.lock_open_rounded
                    : Icons.lock_rounded)),
            isDense: true, // Kích thước gọn nhẹ
            contentPadding: const EdgeInsets.symmetric(
                vertical: 17), // Điều chỉnh kích thước chiều cao

            hintText: "Name",
            prefixIcon: const Icon(Icons.verified_user_rounded),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
      ),
    );
  }
}

class BuildImage extends StatelessWidget {
  const BuildImage({
    super.key,
    required this.currentUser,
    required this.storage,
    required this.authController,
  });

  final User? currentUser;
  final Storage storage;
  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    final messageController = Get.find<MessageController>();
    double coverImageheight = MediaQuery.of(context).size.height * 0.2;
    double profileHeight = MediaQuery.of(context).size.height * 0.2;
    double top = coverImageheight - profileHeight / 2;
    return Container(
      height: top + coverImageheight,
      // decoration:
      //     BoxDecoration(border: Border.all(color: Colors.yellow, width: 2)),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          buildCoverImage(coverImageheight, context, messageController),
          Positioned(
            top: top,
            child: Stack(
              alignment: Alignment.bottomRight,
              clipBehavior: Clip.none,
              children: [
                // SizedBox(
                //     height: 170,
                //     width: 170,
                //     child:
                buildProfileImage(profileHeight),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: GestureDetector(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(
                        allowMultiple: false,
                        allowedExtensions: ['png', 'jpg'],
                        type: FileType.custom,
                      );
                      if (result != null) {
                        final path = result.files.single.path;
                        final fileName = result.files.single.name;
                        String type = 'avatars';
                        bool isSuccess = await storage.uploadFile(
                            path!, fileName, currentUser!.id!, type);
                        if (isSuccess) {
                          String url = await storage.downloadURL(
                              fileName, currentUser!.id!, type);
                          await authController.updateUserToFirebase(
                              uid: currentUser!.id!, urlImage: url);
                          await authController.editUser(urlImage: url);
                          authController.changeIsUpdateInforToTrue();
                          await messageController.updateListAllUser();
                        }
                      } else {
                        print("Nothing happend");
                      }
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
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileImage(double heigh) => GestureDetector(
        onTap: () {
          Get.to(
            () {
              User? user = authController.currentUser.value;
              return Scaffold(
                appBar: AppBar(
                  actions: [
                    IconButton(
                        onPressed: () async {
                          if (user!.urlImage != null) {
                            await storage.downloadFileToLocalDevice(
                                user.urlImage!, "image");
                          } else {
                            print("Cannot download");
                          }
                        },
                        icon: const Icon(Icons.download_outlined))
                  ],
                ),
                body: SizedBox(
                  child: PhotoView(
                    minScale: PhotoViewComputedScale.covered,
                    maxScale: PhotoViewComputedScale
                        .covered, // Đặt giá trị maxScale bằng minScale
                    imageProvider: NetworkImage(user!.urlImage!),
                    backgroundDecoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: Obx(
          () {
            User? user = authController.currentUser.value;
            if (user != null) {
              return CircleAvatar(
                // radius: heigh / 2,
                // backgroundColor: user.story
                //     ? Colors.blue
                //     : const Color.fromARGB(255, 239, 242, 244),
                // child: CircleAvatar(
                radius: heigh / 2,
                backgroundImage: user.urlImage == null
                    ? const NetworkImage(
                        "https://vn.jugomobile.com/wp-content/uploads/2023/02/Phat-truc-tiep-Al-Nassr-vs-Al-Taawoun-kenh-truyen.jpg?w=640")
                    : NetworkImage(user.urlImage!),
                //),
              );
            } else {
              return const Text("");
            }
          },
        ),
      );
  Widget buildCoverImage(double height, BuildContext context,
          MessageController messageController) =>
      GestureDetector(
        onTap: () {
          showModelBottom(context, messageController);
        },
        child: Obx(
          () {
            User? user = authController.currentUser.value;
            if (user != null) {
              return Container(
                width: double.infinity,
                height: height,
                color: Colors.grey,
                child: Image.network(
                  user.urlCoverImage ??
                      "https://images.pexels.com/photos/268533/pexels-photo-268533.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                  fit: BoxFit.cover,
                ),
              );
            } else {
              return const Text("");
            }
          },
        ),
      );
  void showModelBottom(
      BuildContext context, MessageController messageController) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Obx(
          () {
            User? user = authController.currentUser.value;
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.18,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ListTile(
                    onTap: () {
                      Get.to(
                        () => Scaffold(
                          appBar: AppBar(
                            leading: IconButton(
                              onPressed: () {
                                Get.back();
                                Get.back();
                              },
                              icon: const Icon(Icons.arrow_back),
                            ),
                            actions: [
                              IconButton(
                                  onPressed: () async {
                                    await storage.downloadFileToLocalDevice(
                                        user!.urlCoverImage!, "image");
                                  },
                                  icon: const Icon(Icons.download_outlined))
                            ],
                          ),
                          body: SizedBox(
                            child: PhotoView(
                              minScale: PhotoViewComputedScale.covered,
                              maxScale: PhotoViewComputedScale.covered,
                              imageProvider: NetworkImage(user!.urlCoverImage ??
                                  "https://wallpaperaccess.com/full/393735.jpg"),
                              backgroundDecoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    title: const Text("See picture"),
                    leading: const Icon(Icons.picture_in_picture),
                  ),
                  const Divider(),
                  ListTile(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(
                        allowMultiple: false,
                        allowedExtensions: ['png', 'jpg'],
                        type: FileType.custom,
                      );
                      if (result != null) {
                        String? path = result.files.single.path;
                        String fileName = result.files.single.name;
                        String type = 'coverImages';
                        bool isSuccess = await storage.uploadFile(
                            path!, fileName, currentUser!.id!, type);
                        if (isSuccess) {
                          String url = await storage.downloadURL(
                              fileName, currentUser!.id!, type);
                          await authController.updateUserToFirebase(
                              uid: currentUser!.id!, urlCoverImage: url);
                          await authController.editUser(coverImage: url);
                          authController.changeIsUpdateInforToTrue();
                          await messageController.updateListAllUser();
                          Navigator.of(context).pop();
                        } else {
                          print("Failed to choose new cover image");
                        }
                      } else {
                        print("Nothing happend");
                      }
                    },
                    leading: const Icon(Icons.my_library_add),
                    title: const Text("Choose new picture"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
