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
    
    final newVoucher = VoucherModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      code: 'HSP-${(DateTime.now().millisecondsSinceEpoch % 10000).toString().padLeft(4, '0')}',
      createdAt: DateTime.now(),
    );
    
    vouchers.insert(0, newVoucher);
    isGenerating.value = false;
    
    Get.snackbar('Berhasil', '${count.value} Voucher berhasil dibuat');
  }

  void deleteVoucher(String id) {
    vouchers.removeWhere((v) => v.id == id);
    Get.snackbar('Berhasil', 'Voucher berhasil dihapus');
  }

  void printVoucher(VoucherModel voucher) {
    Get.snackbar('Cetak', 'Mencetak voucher ${voucher.code}');
  }

  void printAllVouchers() {
    Get.snackbar('Cetak Semua', 'Mencetak ${vouchers.length} voucher');
  }
}
