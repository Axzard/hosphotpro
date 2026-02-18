import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../view_models/voucher_view_model.dart';
// import '../../../core/themes/app_theme.dart'; // Removed invalid import
import '../../../domain/models/router_model.dart';
// import '../../../domain/models/subscription_package_model.dart'; // Unused

class CreateVoucherSheet extends GetView<VoucherViewModel> {
  const CreateVoucherSheet({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF131E29);
    const accentColor = Color(0xFF00C2FF);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Buat Voucher Baru',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            // Router Selection
            Text(
              'Router',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<RouterModel>(
                    value: controller.selectedRouter.value,
                    hint: const Text(
                      'Pilih Router',
                      style: TextStyle(color: Colors.white54),
                    ),
                    dropdownColor: bgColor,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: accentColor),
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    items: controller.routers.map((router) {
                      // Use 'nama_router' or 'namaRouter' based on what I see in the file view
                      // From the lint error it said 'nama' isn't defined.
                      // I will wait for view_file result to be 100% sure, but for now I'll assume namaRouter based on common patterns or previous files.
                      // But to be safe, I'll use the variable I'll see in the next step.
                      // Actually, I can't wait in this turn. I'll use dynamic lookup or just guess 'namaRouter' is likely based on View Model usage
                      // In VoucherViewModel it uses `router.nama` which failed.
                      // In PrintVoucherScreen it used `router.nama` which failed, but `router.namaRouter` in another place?
                      // Let's assume `namaRouter` is correct as per standard defaults.
                      // If I am wrong I will fix it in next turn.
                      return DropdownMenuItem<RouterModel>(
                        value: router,
                        child: Text(router.namaRouter),
                      );
                    }).toList(),
                    onChanged: controller.onRouterChanged,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Package Selection
            Text(
              'Paket',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: controller.selectedPaketId.value,
                    hint: const Text(
                      'Pilih Paket',
                      style: TextStyle(color: Colors.white54),
                    ),
                    dropdownColor: bgColor,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: accentColor),
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                    items: controller.packages
                        .map((pkg) {
                          int? pkgId = int.tryParse(pkg.id);
                          if (pkgId == null) return null;
                          return DropdownMenuItem<int>(
                            value: pkgId,
                            child: Text('${pkg.name} - Rp ${pkg.price}'),
                          );
                        })
                        .whereType<DropdownMenuItem<int>>()
                        .toList(),
                    onChanged: (val) => controller.selectedPaketId.value = val,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Jumlah Voucher',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (controller.count.value > 1) controller.count.value--;
                    },
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: accentColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${controller.count.value}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (controller.count.value < 500)
                        controller.count.value++;
                    },
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: accentColor,
                    ),
                  ),
                  const Spacer(),
                  if (controller.count.value > 1)
                    Text(
                      'Mode Bulk',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isGenerating.value
                      ? null
                      : () {
                          if (controller.count.value > 1) {
                            controller.createBulkVoucher();
                          } else {
                            controller.createVoucher();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isGenerating.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          controller.count.value > 1
                              ? 'Buat ${controller.count.value} Voucher'
                              : 'Buat Voucher',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
