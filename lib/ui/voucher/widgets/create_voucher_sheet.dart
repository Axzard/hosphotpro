import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../view_models/voucher_view_model.dart';
import '../../../domain/models/hotspot_model.dart';
import '../../../domain/models/voucher_package_model.dart';
import '../../../core/utils/currency_formatter.dart';

class CreateVoucherSheet extends StatefulWidget {
  const CreateVoucherSheet({super.key});

  @override
  State<CreateVoucherSheet> createState() => _CreateVoucherSheetState();
}

class _CreateVoucherSheetState extends State<CreateVoucherSheet> {
  final controller = Get.find<VoucherViewModel>();
  bool isAddingPackage = false;
  Worker? _countWorker;

  final namaPaketController = TextEditingController();
  final durasiController = TextEditingController();
  final hargaController = TextEditingController();
  final profileController = TextEditingController();
  final prefixController = TextEditingController();
  final panjangUsernameController = TextEditingController();
  final dataLimitMbController = TextEditingController();
  final voucherCountController = TextEditingController();
  int? selectedHotspotId;
  String selectedFormatKarakter = 'mix';

  @override
  void initState() {
    super.initState();
    voucherCountController.text = controller.count.value.toString();

    if (controller.voucherPackages.isEmpty) {
      controller.loadVoucherPackages();
    }

    _countWorker = ever(controller.count, (int val) {
      if (voucherCountController.text != val.toString()) {
        voucherCountController.text = val.toString();

        if (voucherCountController.text.isNotEmpty) {
          voucherCountController.selection = TextSelection.fromPosition(
            TextPosition(offset: voucherCountController.text.length),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _countWorker?.dispose();
    namaPaketController.dispose();
    durasiController.dispose();
    hargaController.dispose();
    profileController.dispose();
    prefixController.dispose();
    panjangUsernameController.dispose();
    dataLimitMbController.dispose();
    voucherCountController.dispose();
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
                Expanded(
                  child: Text(
                    isAddingPackage
                        ? 'Tambah Paket Voucher'
                        : 'Buat Voucher Baru',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
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
              _buildLabel('Hotspot'),
              const SizedBox(height: 8),
              Obx(
                () => _buildDropdown<HotspotModel>(
                  value: controller.selectedHotspot.value,
                  hint: 'Pilih Hotspot',
                  items: controller.hotspots.map((hotspot) {
                    return DropdownMenuItem<HotspotModel>(
                      value: hotspot,
                      child: Text('Hotspot: ${hotspot.namaServer}'),
                    );
                  }).toList(),
                  onChanged: controller.onHotspotChanged,
                ),
              ),

              const SizedBox(height: 16),

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
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            int current =
                                int.tryParse(voucherCountController.text) ??
                                controller.count.value;
                            if (current > 1) {
                              controller.count.value = current - 1;
                            } else {
                              controller.count.value = 1;
                            }
                          },
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: accentColor,
                            size: 28,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            textAlign: TextAlign.center,
                            onChanged: (val) {
                              if (val.isEmpty) return;
                              final n = int.tryParse(val) ?? 1;
                              controller.count.value = n.clamp(1, 400);
                            },
                            controller: voucherCountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            int current =
                                int.tryParse(voucherCountController.text) ??
                                controller.count.value;
                            if (current < 500) {
                              controller.count.value = current + 1;
                            }
                          },
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: accentColor,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => controller.count.value > 1
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    color: Colors.orange,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'MODE BULK AKTIF',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

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
                          inputFormatters: [CurrencyFormatter()],
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

              _buildLabel('Format Karakter'),
              _buildTextField(prefixController, 'Contoh: WIFI'),
              const SizedBox(height: 16),

              _buildLabel('Panjang Username'),
              _buildTextField(
                panjangUsernameController,
                'Min. 4 karakter',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),

              _buildLabel('Tipe Karakter'),
              const SizedBox(height: 8),
              _buildDropdown<String>(
                value: selectedFormatKarakter,
                hint: 'Pilih Tipe',
                items: ['huruf_kecil', 'huruf_besar', 'angka', 'mix'].map((
                  opt,
                ) {
                  final label =
                      {
                        'huruf_kecil': 'Random abcd',
                        'huruf_besar': 'Random ABCD',
                        'angka': 'Random 1234',
                        'mix': 'Random aB2c',
                      }[opt] ??
                      opt;
                  return DropdownMenuItem<String>(
                    value: opt,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (val) =>
                    setState(() => selectedFormatKarakter = val ?? 'mix'),
              ),
              const SizedBox(height: 16),

              _buildLabel('Limit Data'),
              _buildDataLimitField(),
              const SizedBox(height: 16),

              _buildLabel('Hotspot Mikrotik'),
              const SizedBox(height: 8),
              Obx(
                () => _buildDropdown<int>(
                  value: selectedHotspotId,
                  hint: 'Pilih Hotspot',
                  items: controller.hotspots.map((hs) {
                    return DropdownMenuItem<int>(
                      value: hs.idHotspot,
                      child: Text(hs.namaServer),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => selectedHotspotId = val),
                ),
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
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
    final hotspot = controller.selectedHotspot.value;
    if (hotspot == null) {
      Get.snackbar('Error', 'Pilih hotspot terlebih dahulu');
      return;
    }

    final newPackage = VoucherPackageModel(
      id: 0,
      idRouter: hotspot.idRouter,
      idHotspot: hotspot.idHotspot,
      namaPaket: namaPaketController.text,
      durasi: durasiController.text,
      harga: double.tryParse(hargaController.text) ?? 0,
      namaProfileMikrotik: profileController.text,
      prefix: prefixController.text,
      panjangUsername: int.tryParse(panjangUsernameController.text) ?? 4,
      formatKarakter: selectedFormatKarakter,
      dataLimitMb:
          (int.tryParse(dataLimitMbController.text) ?? 0) *
          (selectedDataUnit == 'GB' ? 1024 : 1),
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

  String selectedDataUnit = 'MB';

  Widget _buildDataLimitField() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 4,
            child: TextField(
              controller: dataLimitMbController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.plusJakartaSans(color: Colors.white),
              decoration: InputDecoration(
                hintText: '0 (Unlimited)',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _buildDropdown<String>(
              value: selectedDataUnit,
              hint: 'MB',
              items: ['MB', 'GB'].map((unit) {
                return DropdownMenuItem<String>(value: unit, child: Text(unit));
              }).toList(),
              onChanged: (val) =>
                  setState(() => selectedDataUnit = val ?? 'MB'),
            ),
          ),
        ],
      ),
    );
  }
}
