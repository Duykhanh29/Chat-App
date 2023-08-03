import 'package:chat_app/modules/auth/bindings/auth_binding.dart';
import 'package:chat_app/modules/auth/controllers/auth_controller.dart';
import 'package:chat_app/modules/auth/views/startPage.dart';
import 'package:chat_app/modules/home/views/main_view.dart';
import 'package:chat_app/modules/messeger/bindings/message_binding.dart';
import 'package:chat_app/modules/widgets/splash.dart';
import 'package:chat_app/routes/app_page.dart';
import 'package:chat_app/utils/constants/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:chat_app/modules/home/bindings/home_binding.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

Future backgroundhandler(RemoteMessage message) async {
  print("This is message from background");
  print(message.notification!.body);
  print(message.notification!.title);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setSystemUIOverlayStyle(style)
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyA0kdqm9qyrOkfl7qcDu9w7-LrVUWBB00U",
            appId: "1:400693625268:web:bfa539631d4e51255e72e1",
            messagingSenderId: "G-V7G0364ZHF",
            projectId: "chat-app-9267d"));
  }
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );

  // if()
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // this is used for IOS devices
  NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      sound: true,
      criticalAlert: false,
      provisional: false);
  print('User granted permission: ${settings.authorizationStatus}');

  final fcmToken = await FirebaseMessaging.instance.getToken();
  print("Token: $fcmToken");
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // AndroidNotificationChannel androidNotificationChannel=AndroidNotificationChannel("high_importance_channel", name)
  //.then((value) => Get.put(AuthController()));
  // Get.put(AuthController());
  FirebaseMessaging.onBackgroundMessage(backgroundhandler);
  Get.lazyPut(
    () => AuthController(),
  );
  await [Permission.microphone, Permission.camera].request();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      initialBinding: AuthBinding(),
      //  darkTheme: ,
      //theme: ,
      //themeMode: ,
      // home:
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // ternimated State
    // FirebaseMessaging.instance.getInitialMessage().then((value) {
    //   if (value!.notification != null) {
    //     print("This message is coming from ternimated");
    //     print(value.notification!.body);
    //     print(value.notification!.title);
    //   }
    // });

    // Foreground State
    FirebaseMessaging.onMessage.listen((event) {
      if (event.notification != null) {
        print("This message is coming from Foreground");
        print(event.notification!.body);
        print(event.notification!.title);
      }
    });

    // background State
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      if (event.notification != null) {
        print("This message is coming from background");
        print(event.notification!.body);
        print(event.notification!.title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        if (controller.currentUser.value != null) {
          return MainView();
        } else {
          return const StartPage();
        }
      },
      init: AuthController(),

      //home: SplashScreen(),
    );
    // Get.put(AuthController());
    // final auController = Get.find<AuthController>();
    // return StreamBuilder(
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.none) {
    //     } else if (snapshot.connectionState == ConnectionState.waiting) {
    //       Center(
    //         child: CircularProgressIndicator(),
    //       );
    //     } else {
    //       if(snapshot.data!=null){

    //       }
    //     }
    //   },
    //   stream: FirebaseAuth.instance.authStateChanges(),
    // );
  }
}
