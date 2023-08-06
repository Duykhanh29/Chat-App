import 'dart:convert';

import 'package:chat_app/data/models/message_data.dart';
import 'package:chat_app/modules/friend/views/friend_view.dart';
import 'package:chat_app/modules/friend/views/widgetss/request_friend.dart';
import 'package:chat_app/modules/home/controllers/home_controller.dart';
import 'package:chat_app/modules/home/views/main_view.dart';
import 'package:chat_app/modules/messeger/controllers/message_controller.dart';
import 'package:chat_app/modules/messeger/views/widgets/chatting_page.dart';
import 'package:chat_app/routes/app_routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static void initialize() async {
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
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        print("It is fine");
        print("Payload: ${details.payload}");
        print("Payload: ${details.actionId}");
        print("Payload: ${details.id}");
        print("Payload: ${details.input}");
        print("Payload: ${details.notificationResponseType}");
        if (details.payload == Paths.CHATTINGPAGE) {
          // final msgController = Get.find<MessageController>();
          // String idChat = message.data['detailed'];
          // MessageData messageData = msgController.listMessageData
          //     .firstWhere((data) => data.idMessageData == idChat);
          // Get.to(() => ChattingPage(messageData: messageData));
        } else if (details.payload == Paths.RECEIVED_FRIEND_REQUEST) {
          // Get.to(() => const RequestFriend());
        } else if (details.payload == Paths.FRIENDS) {
          // Get.to(() => FriendView());
        }
      },
      // onDidReceiveBackgroundNotificationResponse: (details) {
      // print("Payload: ${details.payload}");
      // print("Payload: ${details.actionId}");
      // print("Payload: ${details.id}");
      // print("Payload: ${details.input}");
      // print("Payload: ${details.notificationResponseType}");
      // if (details.payload == Paths.CHATTINGPAGE) {
      //   // final msgController = Get.find<MessageController>();
      //   // String idChat = message.data['detailed'];
      //   // MessageData messageData = msgController.listMessageData
      //   //     .firstWhere((data) => data.idMessageData == idChat);
      //   // Get.to(() => ChattingPage(messageData: messageData));
      // } else if (details.payload == Paths.RECEIVED_FRIEND_REQUEST) {
      //   // Get.to(() => const RequestFriend());
      // } else if (details.payload == Paths.FRIENDS) {
      //   // Get.to(() => FriendView());
      // }
      // },
    );
  }

  static void handleMessage(RemoteMessage message) {
    if (message.data['route'] == Paths.CHATTINGPAGE) {
      final msgController = Get.find<MessageController>();
      String idChat = message.data['detailed'];
      MessageData messageData = msgController.listMessageData
          .firstWhere((data) => data.idMessageData == idChat);
      Get.to(() => ChattingPage(messageData: messageData));
    } else if (message.data['route'] == Paths.RECEIVED_FRIEND_REQUEST) {
      final homeController = Get.find<HomeController>();
      homeController.updatePageIndex(1);
      Get.to(() => const RequestFriend());
    } else if (message.data['route'] == Paths.FRIENDS) {
      final homeController = Get.find<HomeController>();
      homeController.updatePageIndex(1);
      // Get.to(() => FriendView());
    }
  }

  static Future<void> display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails("chat-app-9267d", "ddk",
              importance: Importance.max,
              priority: Priority.max,
              sound: RawResourceAndroidNotificationSound("notification")
              // ledColor: Colors.cyan,
              // enableLights: true,
              // enableVibration: true
              ));
      await notificationsPlugin.show(id, message.notification!.title,
          message.notification!.body, notificationDetails,
          payload: message.data["route"]);
    } on Exception catch (e) {
      print(e);
    }
  }

  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  static void sendPushMessage(List<String> tokens, String body, String title,
      String route, String detailed) async {
    try {
      await http.post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAXUszgbQ:APA91bFAY_ugzeZSJGjbil72Xcr9d8Z2wfcQkcFH0kwXhsxnq3iz6lCZfg1O8gLibfz9ZqQzjs2yBCT_32TegDTwRa_WuYG2ObZMTtmU9EDLhkd4BUDIZKsI1lyY3IkK3XxOHdGNPLFg',
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'route': route,
              'detailed': detailed
            },
            'notification': <String, dynamic>{
              'title': title,
              'body': body,
              'android_channel_id': 'chat-app-9267d'
            },
            'to': {tokens}
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error push notification");
      }
    }
  }
}
