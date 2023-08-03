// part of './app_page.dart';

abstract class Routes {
  Routes._();
  static const INIT = Paths.AUTH;
}

class Paths {
  Paths();
  static const PROFILE = '/profile';
  static const MAINVIEW = '/mainview';
  static const MESSAGE = '/message';
  static const FRIENDS = '/friends';
  static const AUTH = '/auth';
  static const HOME = '/home';
  static const CHATTINGPAGE = '/chatting_page';
  // Getter cho tên màn hình CHATTINGPAGE
  static String get chattingPage => CHATTINGPAGE;
}
