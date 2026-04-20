import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'responsive_layout.dart';
import 'desktop_sidebar.dart';
import '../controllers/navigation_controller.dart';
import '../../dashboard/widgets/background_blobs.dart';

class DesktopPageWrapper extends StatelessWidget {
  final Widget child;
  final bool forceSidebar;

  const DesktopPageWrapper({
    super.key, 
    required this.child,
    this.forceSidebar = false,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveLayout.isMobile(context)) {
      return child;
    }

    // If we are on desktop and NavigationController is registered, 
    // it means we are likely using the MainLayoutScreen which already has a sidebar.
    // BUT if forceSidebar is true, we render the sidebar anyway (useful for pushed pages).
    if (Get.isRegistered<NavigationController>() && !forceSidebar) {
      return child;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          const BackgroundBlobs(),
          Row(
            children: [
              const DesktopSidebar(),
              Expanded(
                child: child,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
