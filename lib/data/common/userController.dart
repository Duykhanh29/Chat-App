import 'package:chat_app/data/models/user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserController extends GetxController {
  late Rx<User?> user = Rx<User?>(null);

  User get currentUser => user.value!;
  void clear() {
    user.value = null;
  }
}
