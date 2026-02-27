import 'package:get/get.dart';
import '../../ui/dashboard/dashboard_screen.dart';
import '../../ui/auth/login_screen.dart';
import '../../ui/auth/register_screen.dart';
import '../../ui/dashboard/view_models/dashboard_view_model.dart';
import '../../ui/subscription/package_list_screen.dart';
import '../../ui/subscription/payment_screen.dart';
import '../../ui/subscription/subscription_status_screen.dart';
import '../../ui/subscription/view_models/subscription_view_model.dart';
import '../../ui/report/report_screen.dart';
import '../../ui/report/view_models/report_view_model.dart';
import '../../ui/voucher/print_voucher_screen.dart';
import '../../ui/voucher/voucher_detail_screen.dart';
import '../../ui/voucher/view_models/voucher_view_model.dart';
import '../../ui/router/router_management_screen.dart';
import '../../ui/router/view_models/router_view_model.dart';
import '../../ui/subscription/package_detail_screen.dart';
import '../../ui/subscription/midtrans_webview_screen.dart';
import '../../ui/subscription/payment_detail_screen.dart';
import '../../ui/router/hotspot_management_screen.dart';
import '../../ui/router/view_models/hotspot_view_model.dart';
import '../../ui/voucher/voucher_package_management_screen.dart';
import '../../ui/voucher/view_models/voucher_package_view_model.dart';
import '../../ui/core/widgets/error_screen.dart';
import '../../ui/subscription/payment_error_screen.dart';
import '../../ui/auth/forgot_password_screen.dart';
import '../../ui/auth/reset_password_screen.dart';
import '../../ui/auth/view_models/forgot_password_view_model.dart';
import 'app_routes.dart';
export 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(name: Routes.LOGIN, page: () => const LoginScreen()),
    GetPage(name: Routes.REGISTER, page: () => const RegisterScreen()),
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
    GetPage(name: Routes.PAYMENT, page: () => const PaymentScreen()),
    GetPage(
      name: Routes.TRANSACTIONS,
      page: () => const ReportScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ReportViewModel());
      }),
    ),
    GetPage(
      name: Routes.SUBSCRIPTION_STATUS,
      page: () => const SubscriptionStatusScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<SubscriptionViewModel>()) {
          Get.put(SubscriptionViewModel(Get.find()));
        }
      }),
    ),
    GetPage(
      name: Routes.VOUCHERS,
      page: () => const PrintVoucherScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => VoucherViewModel());
      }),
    ),
    GetPage(
      name: Routes.VOUCHER_DETAIL,
      page: () => const VoucherDetailScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => VoucherViewModel());
      }),
    ),
    GetPage(
      name: '/mikrotik-routers',
      page: () => const RouterManagementScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => RouterViewModel(Get.find()));
      }),
    ),
    GetPage(
      name: Routes.PACKAGE_DETAIL,
      page: () => const PackageDetailScreen(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<SubscriptionViewModel>()) {
          Get.put(SubscriptionViewModel(Get.find()));
        }
      }),
    ),
    GetPage(
      name: Routes.MIDTRANS_WEBVIEW,
      page: () => const MidtransWebViewScreen(),
    ),
    GetPage(
      name: Routes.PAYMENT_DETAIL,
      page: () => const PaymentDetailScreen(),
    ),
    GetPage(
      name: Routes.HOTSPOTS,
      page: () => const HotspotManagementScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HotspotViewModel());
      }),
    ),
    GetPage(
      name: Routes.VOUCHER_PACKAGES,
      page: () => const VoucherPackageManagementScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => VoucherPackageViewModel());
      }),
    ),
    GetPage(
      name: Routes.ERROR,
      page: () => ErrorScreen(message: Get.arguments as String?),
    ),
    GetPage(
      name: Routes.PAYMENT_ERROR,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return PaymentErrorScreen(
          message: args['message'],
          bankName: args['bankName'],
        );
      },
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordScreen(),
      binding: BindingsBuilder(() {
        Get.put(ForgotPasswordViewModel());
      }),
    ),
    GetPage(
      name: Routes.RESET_PASSWORD,
      page: () => const ResetPasswordScreen(),
    ),
  ];
}
