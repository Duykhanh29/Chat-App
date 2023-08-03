import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static void initialize(BuildContext context) {
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings("@mipmap/ic_launcher"),
            iOS: DarwinInitializationSettings(
                requestSoundPermission: true,
                defaultPresentAlert: true,
                defaultPresentBadge: true,
                defaultPresentList: true,
                defaultPresentBanner: true,
                defaultPresentSound: true));
    notificationsPlugin.initialize(initializationSettings);
  }

  static void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final NotificationDetails notificationDatails = NotificationDetails(
          android: AndroidNotificationDetails("ddk", "mth",
              importance: Importance.max, priority: Priority.high));
      await notificationsPlugin.show(id, message.notification!.title,
          message.notification!.body, notificationDatails,
          payload: message.data["route"]);
    } on Exception catch (e) {
      print(e);
    }
  }
}
