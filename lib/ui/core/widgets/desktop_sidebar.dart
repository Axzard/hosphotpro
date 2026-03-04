import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/routing/app_routes.dart';
import '../controllers/navigation_controller.dart';
import 'responsive_layout.dart';

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    // We try to find the NavigationController. If it's not there, we're likely in a 
    // standalone page or mobile view where indexing isn't used.
    final NavigationController? navCtrl = Get.isRegistered<NavigationController>() 
        ? Get.find<NavigationController>() 
        : null;

    final currentRoute = Get.currentRoute;

    return Container(
      width: 280,
      color: const Color(0xFF1E293B),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 40, 16, 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'hotspotsio',
                  style: TextStyle(
                    color: Color(0xFF00C2FF),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                if (navCtrl != null)
                  IconButton(
                    icon: const Icon(Icons.menu_open, color: Colors.white70),
                    onPressed: navCtrl.toggleSidebar,
                    tooltip: 'Tutup Menu',
                  ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final selectedIndex = navCtrl?.selectedIndex.value ?? -1;

              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _SidebarItem(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    route: Routes.DASHBOARD,
                    isActive: navCtrl != null 
                        ? selectedIndex == 0 
                        : currentRoute == Routes.DASHBOARD,
                    index: 0,
                    navCtrl: navCtrl,
                  ),
                  _SidebarItem(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Voucher',
                    route: Routes.VOUCHERS,
                    isActive: navCtrl != null 
                        ? selectedIndex == 1 
                        : currentRoute == Routes.VOUCHERS,
                    index: 1,
                    navCtrl: navCtrl,
                  ),
                  _SidebarItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'Paket Voucher',
                    route: Routes.VOUCHER_PACKAGES,
                    isActive: navCtrl != null 
                        ? selectedIndex == 2 
                        : currentRoute == Routes.VOUCHER_PACKAGES,
                    index: 2,
                    navCtrl: navCtrl,
                  ),
                  _SidebarItem(
                    icon: Icons.router_outlined,
                    label: 'Manajemen Router',
                    route: Routes.MIKROTIK_ROUTERS,
                    isActive: navCtrl != null 
                        ? selectedIndex == 3 
                        : currentRoute == Routes.MIKROTIK_ROUTERS,
                    index: 3,
                    navCtrl: navCtrl,
                  ),
                  _SidebarItem(
                    icon: Icons.wifi_off_outlined,
                    label: 'Manajemen Hotspot',
                    route: Routes.HOTSPOTS,
                    isActive: navCtrl != null 
                        ? selectedIndex == 4 
                        : currentRoute == Routes.HOTSPOTS,
                    index: 4,
                    navCtrl: navCtrl,
                  ),
                  _SidebarItem(
                    icon: Icons.bar_chart_outlined,
                    label: 'Laporan',
                    route: Routes.TRANSACTIONS,
                    isActive: navCtrl != null 
                        ? selectedIndex == 5 
                        : currentRoute == Routes.TRANSACTIONS,
                    index: 5,
                    navCtrl: navCtrl,
                  ),
                  _SidebarItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'Paket Langganan',
                    route: Routes.PACKAGES,
                    isActive: navCtrl != null 
                        ? (selectedIndex == 6 || selectedIndex == 8) 
                        : (currentRoute == Routes.PACKAGES || currentRoute == Routes.PACKAGE_DETAIL),
                    index: 6,
                    navCtrl: navCtrl,
                  ),
                  _SidebarItem(
                    icon: Icons.card_membership_outlined,
                    label: 'Status Langganan',
                    route: Routes.SUBSCRIPTION_STATUS,
                    isActive: navCtrl != null 
                        ? selectedIndex == 7 
                        : currentRoute == Routes.SUBSCRIPTION_STATUS,
                    index: 7,
                    navCtrl: navCtrl,
                  ),
                ],
              );
            }),
          ),
          const Divider(color: Colors.white10),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    backgroundColor: const Color(0xFF131E29),
                    title: const Text(
                      'Konfirmasi Keluar',
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      'Apakah Anda yakin ingin keluar dari aplikasi?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text(
                          'Batal',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          Get.offAllNamed(Routes.LOGIN);
                        },
                        child: const Text(
                          'Keluar',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );
              },
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Keluar',
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final int index;
  final NavigationController? navCtrl;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
    required this.index,
    this.navCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        onTap: () {
          if (!isActive) {
            if (navCtrl != null && ResponsiveLayout.isDesktop(context)) {
              navCtrl!.changeIndex(index);
            } else {
              Get.toNamed(route);
            }
          }
        },
        leading: Icon(
          icon,
          color: isActive ? const Color(0xFF00C2FF) : Colors.white60,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white60,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isActive,
        selectedTileColor: const Color(0xFF00C2FF).withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
