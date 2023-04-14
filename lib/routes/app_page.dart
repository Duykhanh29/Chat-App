import 'package:chat_app/modules/home/views/home_view.dart';
import 'package:chat_app/modules/home/views/main_view.dart';
import 'package:chat_app/modules/messeger/views/message_view.dart';
import 'package:chat_app/modules/profile/bindings/profile_biding.dart';
import 'package:chat_app/modules/profile/views/profile_view.dart';
import 'package:get/get.dart';
import 'package:chat_app/modules/home/bindings/home_binding.dart';
import 'package:chat_app/modules/messeger/bindings/message_binding.dart';
part 'app_routes.dart';

class AppPages {
  static const INITIAL = _Paths.MAINVIEW;
  AppPages._();
  static final routes = [
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.MESSAGE,
      page: () => MessageView(),
      binding: MessageBinding(),
    ),
    GetPage(
      name: _Paths.MAINVIEW,
      page: () => const MainView(),
      //   binding: HomeBinding(),
    ),
  ];
}
