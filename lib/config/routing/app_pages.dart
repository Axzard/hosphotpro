import 'package:get/get.dart';
import '../../ui/dashboard/dashboard_screen.dart';
import '../../ui/auth/login_screen.dart';
import '../../ui/auth/register_screen.dart';
import '../../ui/dashboard/view_models/dashboard_view_model.dart';
import '../../ui/subscription/package_list_screen.dart';
import '../../ui/subscription/payment_screen.dart';
import '../../ui/subscription/transaction_history_screen.dart';
import '../../ui/subscription/subscription_status_screen.dart';
import '../../ui/subscription/view_models/subscription_view_model.dart';
import '../../ui/voucher/print_voucher_screen.dart';
import '../../ui/voucher/view_models/voucher_view_model.dart';
import 'app_routes.dart';
export 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardScreen(),
      binding: BindingsBuilder(() {
        Get.put(DashboardViewModel());
      }),
    ),
    GetPage(
      name: Routes.PACKAGES,
      page: () => const PackageListScreen(),
      binding: BindingsBuilder(() {
        Get.put(SubscriptionViewModel(Get.find()));
      }),
    ),
    GetPage(
      name: Routes.PAYMENT,
      page: () => const PaymentScreen(),
    ),
    GetPage(
      name: Routes.TRANSACTIONS,
      page: () => const TransactionHistoryScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SubscriptionViewModel(Get.find()));
      }),
    ),
    GetPage(
      name: Routes.SUBSCRIPTION_STATUS,
      page: () => const SubscriptionStatusScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SubscriptionViewModel(Get.find()));
      }),
    ),
    GetPage(
      name: Routes.VOUCHERS,
      page: () => const PrintVoucherScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => VoucherViewModel());
      }),
    ),
  ];
}
