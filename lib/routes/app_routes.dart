part of './app_page.dart';

abstract class Routes {
  Routes._();
  static const INIT = _Paths.AUTH;
}

abstract class _Paths {
  _Paths._();
  static const PROFILE = '/profile';
  static const MAINVIEW = '/mainview';
  static const MESSAGE = '/message';
  static const GROUP = '/group';
  static const AUTH = '/auth';
  static const HOME = '/home';
}
