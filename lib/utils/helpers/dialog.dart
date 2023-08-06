import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dialogs {
  Dialogs._();
  static showingDialog(String title, String confirmText, String dismissText,
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

  static void displayDialog(
      BuildContext context, String title, String content, Function onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                onConfirm;
              },
            ),
          ],
        );
      },
    );
  }
}
