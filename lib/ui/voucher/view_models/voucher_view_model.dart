import 'package:get/get.dart';
import '../../../config/routing/app_routes.dart';
import '../../../domain/models/voucher_model.dart';

class VoucherViewModel extends GetxController {
  final count = 0.obs;
  final vouchers = <VoucherModel>[].obs;
  final isGenerating = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMockVouchers();
  }

  void loadMockVouchers() {
    vouchers.assignAll([
      VoucherModel(id: '1', code: 'HSP-82X9', createdAt: DateTime.now()),
      VoucherModel(id: '2', code: 'HSP-11M2', createdAt: DateTime.now()),
      VoucherModel(id: '3', code: 'HSP-39K0', createdAt: DateTime.now()),
      VoucherModel(id: '4', code: 'HSP-77Q1', createdAt: DateTime.now()),
      VoucherModel(id: '5', code: 'HSP-05Z4', createdAt: DateTime.now()),
    ]);
  }

  void navigateToDetail(VoucherModel voucher) {
    Get.toNamed(Routes.VOUCHER_DETAIL, arguments: voucher);
  }

  void generateVoucher() async {
    if (count.value <= 0) return;
    
    isGenerating.value = true;
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    final List<VoucherModel> newBatch = [];
    final now = DateTime.now();
    
    for (int i = 0; i < count.value; i++) {
      // Use timestamp + index to ensure uniqueness within the batch
      final uniqueId = (now.millisecondsSinceEpoch + i).toString();
      final tag = (int.parse(uniqueId) % 10000).toString().padLeft(4, '0');
      
      newBatch.add(VoucherModel(
        id: uniqueId,
        code: 'HSP-$tag',
        createdAt: now,
      ));
    }
    
    vouchers.insertAll(0, newBatch);
    isGenerating.value = false;
    
    Get.snackbar('Berhasil', '${count.value} Voucher berhasil dibuat');
  }

  void deleteVoucher(String id) {
    vouchers.removeWhere((v) => v.id == id);
    Get.snackbar('Berhasil', 'Voucher berhasil dihapus');
  }

  void printVoucher(VoucherModel voucher) {
    // Logic for printing here
    vouchers.removeWhere((v) => v.id == voucher.id);
    Get.snackbar('Cetak', 'Voucher ${voucher.code} berhasil dicetak dan dihapus dari daftar');
  }

  void printAllVouchers() {
    // Logic for printing all here
    int total = vouchers.length;
    if (total == 0) return;
    
    vouchers.clear();
    Get.snackbar('Cetak Semua', '$total voucher berhasil dicetak dan dikosongkan');
  }
}
