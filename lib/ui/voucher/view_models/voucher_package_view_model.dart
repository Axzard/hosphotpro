import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../domain/models/voucher_package_model.dart';
import '../../../../domain/models/router_model.dart';
import '../../../../domain/models/hotspot_model.dart';
import '../../../../domain/models/router_repository.dart';
import '../../../../domain/models/voucher_repository.dart';
import '../../../../core/utils/snackbar_utils.dart';

class VoucherPackageViewModel extends GetxController {
  final RouterRepository _routerRepository = Get.find<RouterRepository>();
  final VoucherRepository _voucherRepository = Get.find<VoucherRepository>();

  final RxList<VoucherPackageModel> packages = <VoucherPackageModel>[].obs;
  final RxList<RouterModel> routers = <RouterModel>[].obs;
  final RxList<HotspotModel> hotspots = <HotspotModel>[].obs;
  
  final Rxn<RouterModel> selectedRouter = Rxn<RouterModel>();
  final Rxn<HotspotModel> selectedHotspot = Rxn<HotspotModel>();
  final RxBool isLoading = false.obs;

  // Form Controllers
  final namaPaketController = TextEditingController();
  final durasiController = TextEditingController();
  final hargaController = TextEditingController();
  final profileMikrotikController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadRouters();
  }

  Future<void> loadRouters() async {
    try {
      isLoading.value = true;
      final result = await _routerRepository.getRouters();
      routers.assignAll(result);
      
      if (result.isNotEmpty && selectedRouter.value == null) {
        selectedRouter.value = result.first;
        await onRouterChanged(result.first);
      }
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memuat router: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadHotspots(int idRouter) async {
    try {
      final result = await _routerRepository.getHotspots(idRouter);
      hotspots.assignAll(result);
      if (result.isNotEmpty) {
        selectedHotspot.value = result.first;
      } else {
        selectedHotspot.value = null;
      }
    } catch (e) {
      print('Error loading hotspots: $e');
    }
  }

  Future<void> loadPackages() async {
    if (selectedRouter.value == null) return;
    
    try {
      isLoading.value = true;
      final idRouter = int.tryParse(selectedRouter.value!.id) ?? 0;
      final result = await _voucherRepository.getVoucherPackages(idRouter);
      packages.assignAll(result);
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memuat paket: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRouterChanged(RouterModel? router) async {
    if (router == null) return;
    selectedRouter.value = router;
    final idRouter = int.tryParse(router.id) ?? 0;
    await loadHotspots(idRouter);
    await loadPackages();
  }

  void onHotspotChanged(HotspotModel? hotspot) {
    selectedHotspot.value = hotspot;
  }

  Future<void> createPackage() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;
      final package = VoucherPackageModel(
        id: 0,
        idRouter: int.tryParse(selectedRouter.value!.id) ?? 0,
        idHotspot: selectedHotspot.value!.idHotspot,
        namaPaket: namaPaketController.text,
        durasi: durasiController.text,
        harga: double.tryParse(hargaController.text) ?? 0.0,
        namaProfileMikrotik: profileMikrotikController.text,
      );

      await _voucherRepository.createVoucherPackage(package);
      SnackbarUtils.showSuccess('Berhasil', 'Paket voucher berhasil dibuat');
      loadPackages();
      Get.back();
      _clearForm();
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal membuat paket: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePackage(int id) async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;
      final package = VoucherPackageModel(
        id: id,
        idRouter: int.tryParse(selectedRouter.value!.id) ?? 0,
        idHotspot: selectedHotspot.value!.idHotspot,
        namaPaket: namaPaketController.text,
        durasi: durasiController.text,
        harga: double.tryParse(hargaController.text) ?? 0.0,
        namaProfileMikrotik: profileMikrotikController.text,
      );

      await _voucherRepository.updateVoucherPackage(id, package);
      SnackbarUtils.showSuccess('Berhasil', 'Paket voucher berhasil diperbarui');
      loadPackages();
      Get.back();
      _clearForm();
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memperbarui paket: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePackage(int id) async {
    try {
      isLoading.value = true;
      await _voucherRepository.deleteVoucherPackage(id);
      SnackbarUtils.showSuccess('Berhasil', 'Paket voucher berhasil dihapus');
      loadPackages();
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal menghapus paket: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void prepareEdit(VoucherPackageModel package) {
    namaPaketController.text = package.namaPaket;
    durasiController.text = package.durasi;
    hargaController.text = package.harga.toString();
    profileMikrotikController.text = package.namaProfileMikrotik;
    
    selectedHotspot.value = hotspots.firstWhereOrNull((h) => h.idHotspot == package.idHotspot);
  }

  void _clearForm() {
    namaPaketController.clear();
    durasiController.clear();
    hargaController.clear();
    profileMikrotikController.clear();
  }

  bool _validateForm() {
    if (selectedRouter.value == null || selectedHotspot.value == null) {
      SnackbarUtils.showError('Error', 'Router dan Hotspot harus dipilih');
      return false;
    }
    if (namaPaketController.text.isEmpty || 
        durasiController.text.isEmpty || 
        hargaController.text.isEmpty || 
        profileMikrotikController.text.isEmpty) {
      SnackbarUtils.showError('Error', 'Semua field wajib diisi');
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    namaPaketController.dispose();
    durasiController.dispose();
    hargaController.dispose();
    profileMikrotikController.dispose();
    super.onClose();
  }
}
