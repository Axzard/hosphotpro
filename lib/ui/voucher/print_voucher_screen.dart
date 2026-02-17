import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'view_models/voucher_view_model.dart';
import '../../domain/models/voucher_model.dart';

class PrintVoucherScreen extends GetView<VoucherViewModel> {
  const PrintVoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF0D1416), 
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildInputCard(context),
                    const SizedBox(height: 32),
                    _buildListHeader(context),
                    const SizedBox(height: 16),
                    _buildVoucherList(),
                    const SizedBox(height: 100), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF162529),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.cyan.withOpacity(0.3)),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.cyan, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cetak Voucher',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'MANAJEMEN VOUCHER',
                style: TextStyle(
                  color: Colors.cyan.withOpacity(0.6),
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF162529),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jumlah Voucher',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1416),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24, width: 1.5), 
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '1 - 500',
                      hintStyle: TextStyle(color: Colors.white24),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) => controller.count.value = int.tryParse(val) ?? 0,
                  ),
                ),
                const Text(
                  'PCS',
                  style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Maksimum pencetakan sekaligus adalah 500 voucher.',
            style: TextStyle(color: Colors.white24, fontSize: 11),
          ),
          const SizedBox(height: 24),
          Obx(() => SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.isGenerating.value ? null : () => controller.generateVoucher(),
              icon: controller.isGenerating.value 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.add_circle),
              label: Text(controller.isGenerating.value ? 'Memproses...' : 'Buat Voucher'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B4D8),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildListHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'DAFTAR VOUCHER TERBARU',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.cyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.cyan.withOpacity(0.3)),
          ),
          child: Obx(() => Text(
            '${controller.vouchers.length} Items',
            style: const TextStyle(color: Colors.cyan, fontSize: 10, fontWeight: FontWeight.bold),
          )),
        ),
      ],
    );
  }

  Widget _buildVoucherList() {
    return Obx(() => ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.vouchers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final voucher = controller.vouchers[index];
        return _buildVoucherItem(voucher);
      },
    ));
  }

  Widget _buildVoucherItem(VoucherModel voucher) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF162529),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1416),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.confirmation_num, color: Colors.cyan, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KODE VOUCHER',
                  style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                Text(
                  voucher.code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          _buildActionIcon(Icons.visibility, () {}),
          const SizedBox(width: 8),
          _buildActionIcon(Icons.print, () => controller.printVoucher(voucher)),
          const SizedBox(width: 8),
          _buildActionIcon(Icons.delete, () => controller.deleteVoucher(voucher.id), color: Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap, {Color color = Colors.white54}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color == Colors.redAccent ? color.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      color: Colors.transparent,
      child: OutlinedButton.icon(
        onPressed: () => controller.printAllVouchers(),
        icon: const Icon(Icons.print),
        label: const Text('CETAK SEMUA VOUCHER'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.cyan,
          side: const BorderSide(color: Colors.cyan),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
    );
  }
}
