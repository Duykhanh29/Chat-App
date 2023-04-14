part of './app_page.dart';

abstract class Routes {
  Routes._();
  static const INIT = _Paths.MAINVIEW;
}

abstract class _Paths {
  _Paths._();
  static const PROFILE = '/profile';
  static const MAINVIEW = '/mainview';
  static const MESSAGE = '/message';
}
