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
import 'package:get/get.dart';
import 'package:chat_app/modules/home/bindings/home_binding.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //.then((value) => Get.put(AuthController()));
  // Get.put(AuthController());
  Get.lazyPut(
    () => AuthController(),
  );
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

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) {
        if (firebaseAuth.currentUser != null) {
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
