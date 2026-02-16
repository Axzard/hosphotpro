// part of 'app_pages.dart'; // Removed to fix build errors

abstract class Routes {
  static const INITIAL = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const PROFILE = _Paths.PROFILE;
  static const DASHBOARD = _Paths.DASHBOARD;
  static const PACKAGES = _Paths.PACKAGES;
  static const PAYMENT = _Paths.PAYMENT;
  static const TRANSACTIONS = _Paths.TRANSACTIONS;
  static const SUBSCRIPTION_STATUS = _Paths.SUBSCRIPTION_STATUS;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const PROFILE = '/profile';
  static const DASHBOARD = '/dashboard';
  static const PACKAGES = '/packages';
  static const PAYMENT = '/payment';
  static const TRANSACTIONS = '/transactions';
  static const SUBSCRIPTION_STATUS = '/subscription-status';
}
