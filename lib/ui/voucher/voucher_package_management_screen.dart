import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'view_models/voucher_package_view_model.dart';
import '../../../domain/models/voucher_package_model.dart';
import '../../../domain/models/router_model.dart';
import '../../../domain/models/hotspot_model.dart';
import 'widgets/voucher_package_header.dart';
import 'widgets/voucher_package_item_card.dart';
import '../../core/utils/currency_formatter.dart';

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
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
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
                    color: Colors.white.withOpacity(0.1),
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
              _buildTextField(
                controller.prefixController, 
                'Format Karakter', 
                hint: 'WIFI',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller.panjangUsernameController, 
                'Panjang Username', 
                hint: 'Min. 4 karakter', 
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              _buildFormatKarakterSelector(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(controller.durasiController, 'Durasi', hint: '1h', keyboardType: TextInputType.text)),
                ],
              ),
              const SizedBox(height: 16),
              _buildDataLimitField(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller.hargaController, 
                      'Harga', 
                      hint: '5000', 
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyFormatter()],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(controller.profileMikrotikController, 'Profile Mikrotik', hint: 'profile-1jam')),
                ],
              ),
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
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
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

  Widget _buildFormatKarakterSelector() {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedFormatKarakter.value,
              hint: const Text('Tipe Karakter', style: TextStyle(color: Colors.white54)),
              dropdownColor: const Color(0xFF1E293B),
              isExpanded: true,
              icon: const Icon(Icons.password, color: Color(0xFF00C2FF)),
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
              items: controller.formatKarakterOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(controller.formatKarakterLabels[option] ?? option),
                );
              }).toList(),
              onChanged: controller.onFormatKarakterChanged,
            ),
          ),
        ));
  }

  Widget _buildDataLimitField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 4,
          child: _buildTextField(
            controller.dataLimitMbController, 
            'Limit Data', 
            hint: '0 (Unlimited)', 
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Obx(() => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedDataUnit.value,
                dropdownColor: const Color(0xFF1E293B),
                isExpanded: true,
                icon: const Icon(Icons.unfold_more, color: Color(0xFF00C2FF), size: 18),
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                items: controller.dataUnitOptions.map((unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: controller.onDataUnitChanged,
              ),
            )),
          ),
        ),
      ],
    );
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00C2FF)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
