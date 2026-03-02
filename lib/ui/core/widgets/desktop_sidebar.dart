import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/routing/app_routes.dart';

class DesktopSidebar extends StatelessWidget {
  const DesktopSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = Get.currentRoute;

    return Container(
      width: 280,
      color: const Color(0xFF1E293B),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            alignment: Alignment.center,
            child: const Text(
              'hotspotpro',
              style: TextStyle(
                color: Color(0xFF00C2FF),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _SidebarItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  route: Routes.DASHBOARD,
                  isActive: currentRoute == Routes.DASHBOARD,
                ),
                _SidebarItem(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Voucher',
                  route: Routes.VOUCHERS,
                  isActive: currentRoute == Routes.VOUCHERS,
                ),
                _SidebarItem(
                  icon: Icons.router_outlined,
                  label: 'Manajemen Router',
                  route: Routes.MIKROTIK_ROUTERS,
                  isActive: currentRoute == Routes.MIKROTIK_ROUTERS,
                ),
                _SidebarItem(
                  icon: Icons.wifi_off_outlined,
                  label: 'Manajemen Hotspot',
                  route: Routes.HOTSPOTS,
                  isActive: currentRoute == Routes.HOTSPOTS,
                ),
                _SidebarItem(
                  icon: Icons.bar_chart_outlined,
                  label: 'Laporan',
                  route: Routes.TRANSACTIONS,
                  isActive: currentRoute == Routes.TRANSACTIONS,
                ),
                _SidebarItem(
                  icon: Icons.card_membership_outlined,
                  label: 'Status Langganan',
                  route: Routes.SUBSCRIPTION_STATUS,
                  isActive: currentRoute == Routes.SUBSCRIPTION_STATUS,
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
              onTap: () {
                // Assuming there's a logout logic in a controller or global state
                Get.offAllNamed(Routes.LOGIN);
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

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        onTap: () {
          if (!isActive) {
            Get.toNamed(route);
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
