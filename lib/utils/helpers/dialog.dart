import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dialogs {
  Dialogs._();
  static showDialog(String title, String confirmText, String dismissText,
      Function confirmFunction) {
    return Get.defaultDialog(
      title: title,
      middleText: 'This is the content of the dialog.',
      confirm: ElevatedButton(
        onPressed: () {
          confirmFunction;
        },
        child: Text(confirmText),
      ),
      onCancel: () {
        ElevatedButton(
          onPressed: () {
            Get.back();
          },
          child: Text(dismissText),
        );
      },
    );
  }
}
