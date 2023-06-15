import 'package:chat_app/main.dart';
import 'package:chat_app/modules/auth/bindings/auth_binding.dart';
import 'package:chat_app/modules/auth/views/startPage.dart';
import 'package:chat_app/modules/group/bindings/group_binding.dart';
import 'package:chat_app/modules/group/views/group_view.dart';
import 'package:chat_app/modules/home/views/main_view.dart';
import 'package:chat_app/modules/messeger/views/message_view.dart';
import 'package:chat_app/modules/profile/bindings/profile_biding.dart';
import 'package:chat_app/modules/profile/views/widgets/profile_view.dart';
import 'package:get/get.dart';
import 'package:chat_app/modules/home/bindings/home_binding.dart';
import 'package:chat_app/modules/messeger/bindings/message_binding.dart';
part 'app_routes.dart';

class AppPages {
  static const INITIAL = _Paths.HOME;
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
      name: _Paths.GROUP,
      page: () => GroupView(),
      binding: GroupBinding(),
    ),
    GetPage(
      name: _Paths.MAINVIEW,
      page: () => MainView(),
      //   binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const StartPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const Home(),
    ),
  ];
}
