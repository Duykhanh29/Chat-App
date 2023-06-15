import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_app/main.dart';

class ProfileController extends GetxController {
  late TextEditingController emailController;
  late TextEditingController nameController;
  late TextEditingController phoneController;
  RxBool isEdit = false.obs;

  @override
  void onInit() {
    emailController = TextEditingController();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    // TODO: implement onInit
    super.onInit();
  }
}
