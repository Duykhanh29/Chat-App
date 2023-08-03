import 'package:chat_app/main.dart';
import 'package:chat_app/modules/auth/bindings/auth_binding.dart';
import 'package:chat_app/modules/auth/views/startPage.dart';
import 'package:chat_app/modules/friend/bindings/friend_binding.dart';
import 'package:chat_app/modules/friend/views/friend_view.dart';
import 'package:chat_app/modules/home/views/main_view.dart';
import 'package:chat_app/modules/messeger/views/message_view.dart';
import 'package:chat_app/modules/messeger/views/widgets/chatting_page.dart';
import 'package:chat_app/modules/profile/bindings/profile_biding.dart';
import 'package:chat_app/modules/profile/views/widgets/profile_view.dart';
import 'package:get/get.dart';
import 'package:chat_app/modules/home/bindings/home_binding.dart';
import 'package:chat_app/modules/messeger/bindings/message_binding.dart';
// part 'app_routes.dart';
import './app_routes.dart';

class AppPages {
  static const INITIAL = Paths.HOME;
  AppPages._();
  static final routes = [
    GetPage(
      name: Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Paths.MESSAGE,
      page: () => MessageView(),
      binding: MessageBinding(),
    ),
    GetPage(
      name: Paths.FRIENDS,
      page: () => FriendView(),
      binding: FriendBinding(),
    ),
    GetPage(
      name: Paths.MAINVIEW,
      page: () => MainView(),
      //   binding: HomeBinding(),
    ),
    GetPage(
      name: Paths.AUTH,
      page: () => const StartPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Paths.HOME,
      page: () => const Home(),
    ),
    GetPage(name: Paths.CHATTINGPAGE, page: () => ChattingPage()),
  ];
}
