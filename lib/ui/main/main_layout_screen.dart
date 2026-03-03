import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/widgets/desktop_sidebar.dart';
import '../core/widgets/responsive_layout.dart';
import '../core/controllers/navigation_controller.dart';
import '../dashboard/dashboard_screen.dart';
import '../voucher/print_voucher_screen.dart';
import '../router/router_management_screen.dart';
import '../router/hotspot_management_screen.dart';
import '../report/report_screen.dart';
import '../subscription/subscription_status_screen.dart';
import '../subscription/package_list_screen.dart';
import '../dashboard/widgets/background_blobs.dart';

class MainLayoutScreen extends GetView<NavigationController> {
  const MainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: ResponsiveLayout(
        mobileBody: const DashboardScreen(), 
        desktopBody: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Stack(
      children: [
        const BackgroundBlobs(),
        Row(
          children: [
            const DesktopSidebar(),
            Expanded(
              child: Obx(
                () => IndexedStack(
                  index: controller.selectedIndex.value,
                  children: const [
                    DashboardScreen(),
                    PrintVoucherScreen(),
                    RouterManagementScreen(),
                    HotspotManagementScreen(),
                    ReportScreen(),
                    PackageListScreen(),
                    SubscriptionStatusScreen(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
