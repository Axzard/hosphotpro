import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'view_models/voucher_package_view_model.dart';
import '../../../domain/models/voucher_package_model.dart';
import '../../../domain/models/router_model.dart';
import '../../../domain/models/hotspot_model.dart';
import 'widgets/voucher_package_header.dart';
import 'widgets/voucher_package_item_card.dart';

class VoucherPackageManagementScreen extends GetView<VoucherPackageViewModel> {
  const VoucherPackageManagementScreen({super.key});

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
            const VoucherPackageHeader(accentColor: accentColor),
            // Router Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
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
                if (controller.isLoading.value && controller.packages.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: accentColor));
                }

                if (controller.packages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada paket voucher',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white54),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadPackages,
                  color: accentColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: controller.packages.length,
                    itemBuilder: (context, index) {
                      final package = controller.packages[index];
                      return VoucherPackageItemCard(
                        package: package,
                        cardColor: cardColor,
                        accentColor: accentColor,
                        onEdit: (p) => _showFormSheet(context, package: p),
                        onDelete: (p) => _showDeleteConfirm(context, p),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormSheet(context),
        backgroundColor: accentColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('Tambah Paket', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showFormSheet(BuildContext context, {VoucherPackageModel? package}) {
    final isEdit = package != null;
    if (isEdit) {
      controller.prepareEdit(package);
    } else {
      controller.namaPaketController.clear();
      controller.durasiController.clear();
      controller.hargaController.clear();
      controller.profileMikrotikController.clear();
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF131E29),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                isEdit ? 'Edit Paket Voucher' : 'Tambah Paket Voucher',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildHotspotSelector(),
              const SizedBox(height: 16),
              _buildTextField(controller.namaPaketController, 'Nama Paket', hint: 'Contoh: Paket 1 Jam'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(controller.durasiController, 'Durasi', hint: '1h')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(controller.hargaController, 'Harga', hint: '5000', keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(controller.profileMikrotikController, 'Profile Mikrotik', hint: 'profile-1jam'),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => isEdit ? controller.updatePackage(package.id) : controller.createPackage(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C2FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isEdit ? 'Simpan Perubahan' : 'Buat Paket',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildHotspotSelector() {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<HotspotModel>(
              value: controller.selectedHotspot.value,
              hint: const Text('Pilih Hotspot Server', style: TextStyle(color: Colors.white54)),
              dropdownColor: const Color(0xFF1E293B),
              isExpanded: true,
              icon: const Icon(Icons.wifi_tethering, color: Color(0xFF00C2FF)),
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
              items: controller.hotspots.map((hotspot) {
                return DropdownMenuItem<HotspotModel>(
                  value: hotspot,
                  child: Text(hotspot.namaServer),
                );
              }).toList(),
              onChanged: controller.onHotspotChanged,
            ),
          ),
        ));
  }

  void _showDeleteConfirm(BuildContext context, VoucherPackageModel package) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          'Hapus Paket',
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus paket "${package.namaPaket}"?',
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
              controller.deletePackage(package.id);
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

  Widget _buildTextField(TextEditingController controller, String label, {String? hint, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.plusJakartaSans(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
    );
  }
}
