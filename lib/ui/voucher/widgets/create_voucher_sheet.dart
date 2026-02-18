import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../view_models/voucher_view_model.dart';
import '../../../domain/models/router_model.dart';
import '../../../domain/models/voucher_package_model.dart';

class CreateVoucherSheet extends StatefulWidget {
  const CreateVoucherSheet({super.key});

  @override
  State<CreateVoucherSheet> createState() => _CreateVoucherSheetState();
}

class _CreateVoucherSheetState extends State<CreateVoucherSheet> {
  final controller = Get.find<VoucherViewModel>();
  bool isAddingPackage = false;

  // Package Form Controllers
  final namaPaketController = TextEditingController();
  final durasiController = TextEditingController();
  final hargaController = TextEditingController();
  final profileController = TextEditingController();
  final hotspotIdController = TextEditingController(text: '2');

  @override
  void initState() {
    super.initState();
    // Refresh packages when sheet is opened
    if (controller.voucherPackages.isEmpty) {
      controller.loadVoucherPackages();
    }
  }

  @override
  void dispose() {
    namaPaketController.dispose();
    durasiController.dispose();
    hargaController.dispose();
    profileController.dispose();
    hotspotIdController.dispose();
    super.dispose();
  }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAddingPackage
                      ? 'Tambah Paket Voucher'
                      : 'Buat Voucher Baru',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      setState(() => isAddingPackage = !isAddingPackage),
                  icon: Icon(
                    isAddingPackage ? Icons.list_alt : Icons.add_circle_outline,
                    size: 18,
                  ),
                  label: Text(isAddingPackage ? 'Pilih Paket' : 'Paket Baru'),
                  style: TextButton.styleFrom(foregroundColor: accentColor),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (!isAddingPackage) ...[
              // Router Selection
              _buildLabel('Router'),
              const SizedBox(height: 8),
              Obx(
                () => _buildDropdown<RouterModel>(
                  value: controller.selectedRouter.value,
                  hint: 'Pilih Router',
                  items: controller.routers.map((router) {
                    return DropdownMenuItem<RouterModel>(
                      value: router,
                      child: Text(router.namaRouter),
                    );
                  }).toList(),
                  onChanged: controller.onRouterChanged,
                ),
              ),

              const SizedBox(height: 16),

              // Package Selection
              _buildLabel('Paket'),
              const SizedBox(height: 8),
              Obx(
                () => _buildDropdown<int>(
                  value: controller.selectedPaketId.value,
                  hint: 'Pilih Paket',
                  items: controller.voucherPackages.map((pkg) {
                    return DropdownMenuItem<int>(
                      value: pkg.id,
                      child: Text('${pkg.namaPaket} - Rp ${pkg.harga}'),
                    );
                  }).toList(),
                  onChanged: (val) => controller.selectedPaketId.value = val,
                ),
              ),

              const SizedBox(height: 16),

              _buildLabel('Jumlah Voucher'),
              const SizedBox(height: 8),
              Obx(
                () => Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (controller.count.value > 1)
                          controller.count.value--;
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
                () => _buildPrimaryButton(
                  onPressed: controller.isGenerating.value
                      ? null
                      : () {
                          if (controller.count.value > 1) {
                            controller.createBulkVoucher();
                          } else {
                            controller.createVoucher();
                          }
                        },
                  isLoading: controller.isGenerating.value,
                  text: controller.count.value > 1
                      ? 'Buat ${controller.count.value} Voucher'
                      : 'Buat Voucher',
                ),
              ),
            ] else ...[
              // Add Package Form
              _buildLabel('Nama Paket'),
              _buildTextField(namaPaketController, 'Contoh: Paket 1 Jam'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Durasi'),
                        _buildTextField(durasiController, 'Contoh: 1h'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Harga (Rp)'),
                        _buildTextField(
                          hargaController,
                          '5000',
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Profile MikroTik'),
              _buildTextField(profileController, 'Contoh: profile-1jam'),
              const SizedBox(height: 16),

              _buildLabel('ID Hotspot'),
              _buildTextField(
                hotspotIdController,
                '2',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 32),

              Obx(
                () => _buildPrimaryButton(
                  onPressed: controller.isGenerating.value
                      ? null
                      : _handleCreatePackage,
                  isLoading: controller.isGenerating.value,
                  text: 'Simpan Paket Baru',
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(fontSize: 14, color: Colors.white70),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.plusJakartaSans(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: const TextStyle(color: Colors.white54)),
          dropdownColor: const Color(0xFF131E29),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00C2FF)),
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback? onPressed,
    required bool isLoading,
    required String text,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C2FF),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _handleCreatePackage() async {
    final router = controller.selectedRouter.value;
    if (router == null) {
      Get.snackbar('Error', 'Pilih router terlebih dahulu');
      return;
    }

    final newPackage = VoucherPackageModel(
      id: 0,
      idRouter: int.tryParse(router.id) ?? 0,
      idHotspot: int.tryParse(hotspotIdController.text) ?? 2,
      namaPaket: namaPaketController.text,
      durasi: durasiController.text,
      harga: double.tryParse(hargaController.text) ?? 0,
      namaProfileMikrotik: profileController.text,
    );

    if (newPackage.namaPaket.isEmpty ||
        newPackage.durasi.isEmpty ||
        newPackage.namaProfileMikrotik.isEmpty) {
      Get.snackbar('Error', 'Lengkapi semua field');
      return;
    }

    await controller.createVoucherPackage(newPackage);
    setState(() => isAddingPackage = false);
  }
}
