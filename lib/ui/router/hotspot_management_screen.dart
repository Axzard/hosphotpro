import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'view_models/hotspot_view_model.dart';
import '../../../domain/models/router_model.dart';
import '../core/widgets/desktop_page_wrapper.dart';
import 'widgets/hotspot_header.dart';
import 'widgets/hotspot_item_card.dart';

class HotspotManagementScreen extends GetView<HotspotViewModel> {
  const HotspotManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F172A);
    const cardColor = Color(0xFF1E293B);
    const accentColor = Color(0xFF00C2FF);

    return DesktopPageWrapper(
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              HotspotHeader(accentColor: accentColor),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: Obx(() {
                            final currentRouter = controller.selectedRouter.value;
                            final dropdownValue = (currentRouter?.id == 'all')
                                ? RouterModel.semua
                                : controller.routers.firstWhereOrNull((r) => r.id == currentRouter?.id);
                            final filteredRouters = controller.routers.where((r) => r.id != 'all').toList();
                            return DropdownButton<RouterModel>(
                              value: dropdownValue,
                              hint: const Text('Pilih Router', style: TextStyle(color: Colors.white54)),
                              dropdownColor: cardColor,
                              isExpanded: true,
                              icon: const Icon(Icons.router, color: accentColor),
                              style: GoogleFonts.plusJakartaSans(color: Colors.white),
                              items: [
                                DropdownMenuItem<RouterModel>(
                                  value: RouterModel.semua,
                                  child: const Text('Semua Router'),
                                ),
                                ...filteredRouters.map((router) {
                                  return DropdownMenuItem<RouterModel>(
                                    value: router,
                                    child: Text(router.namaRouter),
                                  );
                                }),
                              ],
                              onChanged: controller.onRouterChanged,
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Obx(() {
                      final isAllRouter = controller.selectedRouter.value?.id == 'all';
                      if (isAllRouter) return const SizedBox.shrink();
                      return Container(
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                        ),
                        child: IconButton(
                          onPressed: controller.isLoading.value ? null : () => controller.syncHotspots(),
                          icon: controller.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: accentColor,
                                  ),
                                )
                              : const Icon(Icons.sync_rounded, color: accentColor),
                          tooltip: 'Sinkronkan Hotspot',
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.hotspots.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: accentColor));
                  }
                  if (controller.hotspots.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada hotspot server',
                            style: GoogleFonts.plusJakartaSans(color: Colors.white54),
                          ),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: controller.loadHotspots,
                    color: accentColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: controller.hotspots.length,
                      itemBuilder: (context, index) {
                        final hotspot = controller.hotspots[index];
                        return HotspotItemCard(
                          hotspot: hotspot,
                          cardColor: cardColor,
                          accentColor: accentColor,
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
