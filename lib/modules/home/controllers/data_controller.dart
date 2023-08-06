import 'package:chat_app/data/models/user.dart';
import 'package:chat_app/modules/friend/controllers/friend_controller.dart';
import 'package:chat_app/modules/friend/views/friend_view.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/message_view.dart';
import 'package:chat_app/modules/profile/controllers/profile_controller.dart';
import 'package:chat_app/modules/profile/views/widgets/profile_view.dart';
import 'package:chat_app/utils/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DataController extends GetxController {
  RxList<User> listAllUser = <User>[].obs;
  RxList<User> friends = <User>[].obs;
  // get all user in database
  Future<RxList<User>> getALlUserInDatabase() async {
    RxList<User> list = <User>[].obs;

    final snapsort = await FirebaseFirestore.instance
        .collection('users')
        .get()
        .then((value) => value.docs.forEach((element) {
              User user = User(
                token: element.data()['token'],
                id: element.data()['id'],
                name: element.data()['name'],
                email: element.data()['email'],
                phoneNumber: element.data()['phoneNumber'],
                story: element.data()['story'],
                urlImage: element.data()['urlImage'],
                userStatus: getUserStatus(element.data()['userStatus']),
                urlCoverImage: element.data()['urlCoverImage'],
              );
              list.value.add(user);
            }));

    // print("stop read");
    // print("Leght: ${list.value.length}");
    return list;
  }

  @override
  void onInit() async {
    super.onInit();
    listAllUser.value = await getALlUserInDatabase();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
