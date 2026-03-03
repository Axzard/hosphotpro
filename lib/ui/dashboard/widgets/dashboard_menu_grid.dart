import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../view_models/dashboard_view_model.dart';

class DashboardMenuGrid extends StatelessWidget {
  final DashboardViewModel controller;

  const DashboardMenuGrid({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 900;
        int crossAxisCount = isWide ? 3 : 2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isWide ? 1.4 : 1.1,
          children: [
            Obx(() => _buildMenuCard(
              icon: Icons.shopping_bag_outlined,
              title: 'Paket Langganan',
              subtitle: controller.expiryDate.value != null
                  ? 'Aktif s.d ${DateFormat('d MMM').format(controller.expiryDate.value!)}'
                  : 'Beli / Perpanjang',
              color: const Color(0xFFF472B6),
              onTap: controller.navigateToPackageList,
            )),
            Obx(() {
              final isRestricted = !controller.isActiveSubscription.value;
              return _buildMenuCard(
                icon: Icons.router_rounded,
                title: 'Router',
                subtitle: isRestricted ? 'Butuh Langganan' : '${controller.totalRouterCount.value} Unit',
                color: isRestricted ? Colors.grey : const Color(0xFF4ADE80),
                onTap: isRestricted 
                    ? controller.navigateToPackageList
                    : controller.navigateToRouters,
              );
            }),
            Obx(() {
              final isRestricted = !controller.isActiveSubscription.value;
              return _buildMenuCard(
                icon: Icons.wifi_tethering_rounded,
                title: 'Hotspot',
                subtitle: isRestricted 
                    ? 'Butuh Langganan' 
                    : (controller.selectedRouter.value != null ? '${controller.hotspotCount.value} Unit' : 'Manajemen Server'),
                color: isRestricted ? Colors.grey : const Color(0xFF00C2FF),
                onTap: isRestricted 
                    ? controller.navigateToPackageList
                    : controller.navigateToHotspots,
              );
            }),
            Obx(() {
              final isRestricted = !controller.isActiveSubscription.value;
              return _buildMenuCard(
                icon: Icons.inventory_2_outlined,
                title: 'Paket Voucher',
                subtitle: isRestricted 
                    ? 'Butuh Langganan' 
                    : (controller.selectedRouter.value != null ? '${controller.voucherPackageCount.value} Paket' : 'Kelola Paket'),
                color: isRestricted ? Colors.grey : const Color(0xFF94A3B8),
                onTap: isRestricted 
                    ? controller.navigateToPackageList
                    : controller.navigateToVoucherPackages,
              );
            }),
            Obx(() {
              final isRestricted = !controller.isActiveSubscription.value;
              return _buildMenuCard(
                icon: Icons.confirmation_number_outlined,
                title: 'Voucher',
                subtitle: isRestricted
                    ? 'Butuh Langganan'
                    : (controller.selectedRouter.value != null
                        ? '${controller.voucherCount.value} Pcs'
                        : 'Pilih Router Dahulu'),
                color: isRestricted ? Colors.grey : const Color(0xFFFFB547),
                onTap: isRestricted
                    ? controller.navigateToPackageList
                    : controller.navigateToVouchers,
              );
            }),
            Obx(() {
              final isRestricted = !controller.isActiveSubscription.value;
              return _buildMenuCard(
                icon: Icons.receipt_long_rounded,
                title: 'Laporan Penjualan',
                subtitle: isRestricted ? 'Butuh Langganan' : 'Riwayat Penjualan',
                color: isRestricted ? Colors.grey : const Color(0xFFFF6B81),
                onTap: isRestricted
                    ? controller.navigateToPackageList
                    : controller.navigateToTransactions,
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
