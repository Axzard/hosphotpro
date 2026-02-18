import 'package:get/get.dart';
import '../../../config/routing/app_routes.dart';
import '../../../domain/models/voucher_model.dart';
import '../../../domain/models/voucher_package_model.dart';
import '../../../domain/models/voucher_repository.dart';
import '../../../domain/models/router_repository.dart';
import '../../../domain/models/router_model.dart';
import '../../../core/utils/snackbar_utils.dart';
// import '../../../domain/models/subscription_package_model.dart'; // No longer used for hotspot vouchers
// import '../../../domain/models/subscription_repository.dart'; // No longer used for hotspot vouchers
import '../widgets/voucher_print_preview.dart';

class VoucherViewModel extends GetxController {
  final VoucherRepository _voucherRepository = Get.find<VoucherRepository>();
  final RouterRepository _routerRepository = Get.find<RouterRepository>();

  final vouchers = <VoucherModel>[].obs;
  final routers = <RouterModel>[].obs;
  final voucherPackages = <VoucherPackageModel>[].obs;

  final isLoading = false.obs;
  final isGenerating = false.obs;
  final count = 1.obs;

  // Selected values for dropdowns
  final selectedRouter = Rxn<RouterModel>();
  final selectedPaketId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    loadRouters();
  }

  /// Load available routers for the dropdown
  Future<void> loadRouters() async {
    try {
      final result = await _routerRepository.getRouters();
      routers.value = result;

      if (result.isNotEmpty && selectedRouter.value == null) {
        selectedRouter.value = result.first;
        await onRouterChanged(result.first);
      }
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memuat daftar router');
    }
  }

  Future<void> loadVoucherPackages() async {
    final router = selectedRouter.value;
    if (router == null) return;

    try {
      final idRouter = int.tryParse(router.id) ?? 0;
      final result = await _voucherRepository.getVoucherPackages(idRouter);
      voucherPackages.value = result;
      print('Loaded ${result.length} voucher packages for router $idRouter');
    } catch (e) {
      print('Error loading voucher packages: $e');
      SnackbarUtils.showError('Error', 'Gagal memuat daftar paket: $e');
      voucherPackages.clear();
    }
  }

  /// Load vouchers for the selected router
  Future<void> loadVouchers() async {
    final router = selectedRouter.value;
    if (router == null) return;

    isLoading.value = true;
    try {
      final idRouter = int.tryParse(router.id) ?? 0;
      final result = await _voucherRepository.getVouchersByRouter(idRouter);
      vouchers.value = result;
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memuat daftar voucher: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a single voucher
  Future<void> createVoucher() async {
    final router = selectedRouter.value;
    final idPaket = selectedPaketId.value;

    if (router == null || idPaket == null) {
      Get.snackbar('Error', 'Pilih router dan paket terlebih dahulu');
      return;
    }

    isGenerating.value = true;
    try {
      final idRouter = int.tryParse(router.id) ?? 0;
      await _voucherRepository.createVoucher(idPaket, idRouter);
      SnackbarUtils.showSuccess('Berhasil', 'Voucher berhasil dibuat');
      Get.back(); // Close bottom sheet if open
      await loadVouchers();
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal membuat voucher: $e');
    } finally {
      isGenerating.value = false;
    }
  }

  /// Create bulk vouchers
  Future<void> createBulkVoucher() async {
    final router = selectedRouter.value;
    final idPaket = selectedPaketId.value;

    if (router == null || idPaket == null) {
      Get.snackbar('Error', 'Pilih router dan paket terlebih dahulu');
      return;
    }

    if (count.value <= 0 || count.value > 500) {
      SnackbarUtils.showError('Error', 'Jumlah harus antara 1 - 500');
      return;
    }

    isGenerating.value = true;
    try {
      final idRouter = int.tryParse(router.id) ?? 0;
      final result = await _voucherRepository.createVoucherBulk(
        idPaket,
        idRouter,
        count.value,
      );

      SnackbarUtils.showSuccess(
        'Berhasil',
        '${count.value} voucher berhasil dibuat',
      );

      Get.back(); // Close bottom sheet
      await loadVouchers();

      // Navigate to print preview if we got vouchers back
      if (result.isNotEmpty) {
        _openPrintPreview(result);
      }
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal membuat voucher bulk: $e');
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> createVoucherPackage(VoucherPackageModel package) async {
    isGenerating.value = true;
    try {
      await _voucherRepository.createVoucherPackage(package);
      SnackbarUtils.showSuccess('Berhasil', 'Paket voucher berhasil dibuat');
      await loadVoucherPackages();
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal membuat paket voucher: $e');
    } finally {
      isGenerating.value = false;
    }
  }

  /// Delete a voucher
  Future<void> deleteVoucher(int idVoucher) async {
    final router = selectedRouter.value;
    if (router == null) return;

    try {
      final idRouter = int.tryParse(router.id) ?? 0;
      final success = await _voucherRepository.deleteVoucher(
        idVoucher,
        idRouter,
      );
      if (success) {
        vouchers.removeWhere((v) => v.idVoucher == idVoucher);
        SnackbarUtils.showSuccess('Berhasil', 'Voucher berhasil dihapus');
      } else {
        SnackbarUtils.showError('Error', 'Gagal menghapus voucher');
      }
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal menghapus voucher: $e');
    }
  }

  /// Navigate to detail screen
  void navigateToDetail(VoucherModel voucher) {
    Get.toNamed(Routes.VOUCHER_DETAIL, arguments: voucher);
  }

  /// Switch selected router and reload vouchers
  Future<void> onRouterChanged(RouterModel? router) async {
    if (router == null) return;
    selectedRouter.value = router;
    selectedPaketId.value = null; // Clear selected package when router changes
    await Future.wait([loadVouchers(), loadVoucherPackages()]);
  }

  /// Print single voucher
  void printVoucher(VoucherModel voucher) {
    _openPrintPreview([voucher]);
  }

  /// Print all vouchers
  void printAllVouchers() {
    if (vouchers.isEmpty) {
      SnackbarUtils.showError('Error', 'Tidak ada voucher untuk dicetak');
      return;
    }
    _openPrintPreview(vouchers);
  }

  void _openPrintPreview(List<VoucherModel> vouchersToPrint) {
    if (selectedRouter.value == null) {
      SnackbarUtils.showError('Error', 'Router belum dipilih');
      return;
    }

    Get.to(
      () => VoucherPrintPreview(
        vouchers: vouchersToPrint,
        routerName: selectedRouter.value!.namaRouter,
      ),
    );
  }
}
