import 'package:get/get.dart';
import '../../../config/routing/app_routes.dart';

class NavigationController extends GetxController {
  final selectedIndex = 0.obs;
  final isSidebarOpen = true.obs;

  void toggleSidebar() {
    isSidebarOpen.value = !isSidebarOpen.value;
  }

  // Mapping from index to route for deep linking / syncing
  final List<String> indexRoutes = [
    Routes.DASHBOARD,
    Routes.VOUCHERS,
    Routes.VOUCHER_PACKAGES,
    Routes.MIKROTIK_ROUTERS,
    Routes.HOTSPOTS,
    Routes.TRANSACTIONS,
    Routes.PACKAGES,
    Routes.SUBSCRIPTION_STATUS,
    Routes.PACKAGE_DETAIL,
  ];

  void changeIndex(int index) {
    if (index >= 0 && index < indexRoutes.length) {
      selectedIndex.value = index;
      // We don't necessarily call Get.toNamed here to avoid the whole-page build,
      // but we might want to update the browser URL if supported.
      // For now, let's keep it simple as an index switch.
    }
  }

  void setIndexByRoute(String route) {
    final index = indexRoutes.indexOf(route);
    if (index != -1) {
      selectedIndex.value = index;
    }
  }

  String get currentRoute => indexRoutes[selectedIndex.value];
}
