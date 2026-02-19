import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'view_models/hotspot_view_model.dart';
import '../../../domain/models/hotspot_model.dart';
import '../../../domain/models/router_model.dart';
import 'widgets/hotspot_header.dart';
import 'widgets/hotspot_item_card.dart';
import 'widgets/hotspot_form_sheet.dart';

class HotspotManagementScreen extends GetView<HotspotViewModel> {
  const HotspotManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F172A);
    const cardColor = Color(0xFF1E293B);
    const accentColor = Color(0xFF00C2FF);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            const HotspotHeader(accentColor: accentColor),
            // Router Selector
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<RouterModel>(
                        value: controller.selectedRouter.value,
                        hint: const Text('Pilih Router', style: TextStyle(color: Colors.white54)),
                        dropdownColor: cardColor,
                        isExpanded: true,
                        icon: const Icon(Icons.router, color: accentColor),
                        style: GoogleFonts.plusJakartaSans(color: Colors.white),
                        items: controller.routers.map((router) {
                          return DropdownMenuItem<RouterModel>(
                            value: router,
                            child: Text(router.namaRouter),
                          );
                        }).toList(),
                        onChanged: controller.onRouterChanged,
                      ),
                    ),
                  )),
            ),

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
                        onEdit: (h) => _showEditSheet(h),
                        onDelete: (h) => _showDeleteConfirm(h),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(HotspotModel hotspot) {
    controller.prepareEdit(hotspot);
    Get.bottomSheet(
      HotspotFormSheet(hotspot: hotspot),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showDeleteConfirm(HotspotModel hotspot) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          'Hapus Hotspot',
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus server "${hotspot.namaServer}"?',
          style: GoogleFonts.plusJakartaSans(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteHotspot(hotspot.idHotspot);
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
