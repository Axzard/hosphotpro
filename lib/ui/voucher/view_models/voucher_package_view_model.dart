import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../../../../domain/models/voucher_package_model.dart';
import '../../../../domain/models/router_model.dart';
import '../../../../domain/models/hotspot_model.dart';
import '../../../../domain/models/router_repository.dart';
import '../../../../domain/models/voucher_repository.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/services/websocket_service.dart';

class VoucherPackageViewModel extends GetxController {
  final RouterRepository _routerRepository = Get.find<RouterRepository>();
  final VoucherRepository _voucherRepository = Get.find<VoucherRepository>();
  final WebSocketService _webSocketService = Get.find<WebSocketService>();

  final RxList<VoucherPackageModel> packages = <VoucherPackageModel>[].obs;
  final RxList<RouterModel> routers = <RouterModel>[].obs;
  final RxList<HotspotModel> hotspots = <HotspotModel>[].obs;
  
  final Rxn<RouterModel> selectedRouter = Rxn<RouterModel>();
  final Rxn<HotspotModel> selectedHotspot = Rxn<HotspotModel>();
  final RxBool isLoading = false.obs;
  final RxSet<int> deletingPackageIds = <int>{}.obs; // Track IDs being deleted

  // Form Controllers
  final namaPaketController = TextEditingController();
  final durasiController = TextEditingController();
  final hargaController = TextEditingController();
  final profileMikrotikController = TextEditingController();
  final prefixController = TextEditingController();
  final panjangUsernameController = TextEditingController();
  final dataLimitMbController = TextEditingController();
  
  final RxString selectedFormatKarakter = 'mix'.obs;
  final List<String> formatKarakterOptions = ['huruf_kecil', 'huruf_besar', 'angka', 'mix'];
  
  final RxString selectedDataUnit = 'MB'.obs;
  final List<String> dataUnitOptions = ['MB', 'GB'];

  final Map<String, String> formatKarakterLabels = {
    'huruf_kecil': 'Random abcd',
    'huruf_besar': 'Random ABCD',
    'angka': 'Random 1234',
    'mix': 'Random aB2c',
  };

  StreamSubscription? _refreshSub;

  @override
  void onInit() {
    super.onInit();
    loadRouters();
    _initRealtimeListeners();
  }

  void _initRealtimeListeners() {
    print('🚀 [VoucherPackageVM] Realtime listeners initialized');
    _refreshSub = _webSocketService.eventStream.listen((eventData) {
      final event = eventData['event'] ?? '';
      print('🏢 [VoucherPackageVM] Refreshing due to Event: $event');
      loadPackages();
    });
  }

  @override
  void onClose() {
    _refreshSub?.cancel();
    namaPaketController.dispose();
    durasiController.dispose();
    hargaController.dispose();
    profileMikrotikController.dispose();
    prefixController.dispose();
    panjangUsernameController.dispose();
    dataLimitMbController.dispose();
    super.onClose();
  }

  Future<void> loadRouters() async {
    try {
      isLoading.value = true;
      final result = await _routerRepository.getRouters();
      routers.assignAll(result);
      
      List<HotspotModel> allHotspots = [];
      for (var router in result) {
        final idRouter = int.tryParse(router.id) ?? 0;
        final hotspotResult = await _routerRepository.getHotspots(idRouter);
        allHotspots.addAll(hotspotResult);
      }
      hotspots.assignAll(allHotspots);

      if (hotspots.isNotEmpty && selectedHotspot.value == null) {
        selectedHotspot.value = hotspots.first;
        await loadPackages();
      }
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memuat data: $e');
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
    if (selectedHotspot.value == null) return;
    
    try {
      isLoading.value = true;
      final idHotspot = selectedHotspot.value!.idHotspot;
      final result = await _voucherRepository.getVoucherPackages(idHotspot);
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
    
    // Auto load packages for the first hotspot if available
    if (hotspots.isNotEmpty) {
      selectedHotspot.value = hotspots.first;
      await loadPackages();
    } else {
      selectedHotspot.value = null;
      packages.clear();
    }
  }

  Future<void> onHotspotFilterChanged(HotspotModel? hotspot) async {
    if (hotspot == null) return;
    selectedHotspot.value = hotspot;
    await loadPackages();
  }

  void onHotspotChanged(HotspotModel? hotspot) {
    selectedHotspot.value = hotspot;
  }

  void onFormatKarakterChanged(String? value) {
    if (value != null) {
      selectedFormatKarakter.value = value;
    }
  }

  void onDataUnitChanged(String? value) {
    if (value != null) {
      selectedDataUnit.value = value;
    }
  }

  Future<void> createPackage() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;
      
      int dataLimit = int.tryParse(dataLimitMbController.text) ?? 0;
      if (selectedDataUnit.value == 'GB') {
        dataLimit *= 1024;
      }

      final package = VoucherPackageModel(
        id: 0,
        idRouter: null, // Let backend handle or use a default if needed
        idHotspot: selectedHotspot.value!.idHotspot,
        namaPaket: namaPaketController.text,
        durasi: durasiController.text,
        harga: CurrencyFormatter.parse(hargaController.text),
        namaProfileMikrotik: profileMikrotikController.text,
        prefix: prefixController.text,
        panjangUsername: int.tryParse(panjangUsernameController.text) ?? 4,
        formatKarakter: selectedFormatKarakter.value,
        dataLimitMb: dataLimit,
      );

      await _voucherRepository.createVoucherPackage(package);
      Get.back();
      SnackbarUtils.showSuccess('Berhasil', 'Paket voucher berhasil dibuat');
      loadPackages();
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
      
      int dataLimit = int.tryParse(dataLimitMbController.text) ?? 0;
      if (selectedDataUnit.value == 'GB') {
        dataLimit *= 1024;
      }

      final package = VoucherPackageModel(
        id: id,
        idRouter: null,
        idHotspot: selectedHotspot.value!.idHotspot,
        namaPaket: namaPaketController.text,
        durasi: durasiController.text,
        harga: CurrencyFormatter.parse(hargaController.text),
        namaProfileMikrotik: profileMikrotikController.text,
        prefix: prefixController.text,
        panjangUsername: int.tryParse(panjangUsernameController.text) ?? 4,
        formatKarakter: selectedFormatKarakter.value,
        dataLimitMb: dataLimit,
      );

      await _voucherRepository.updateVoucherPackage(id, package);
      Get.back();
      SnackbarUtils.showSuccess('Berhasil', 'Paket voucher berhasil diperbarui');
      loadPackages();
      _clearForm();
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memperbarui paket: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePackage(int id) async {
    if (deletingPackageIds.contains(id)) return;

    try {
      deletingPackageIds.add(id);
      isLoading.value = true;
      await _voucherRepository.deleteVoucherPackage(id);
      SnackbarUtils.showSuccess('Berhasil', 'Paket voucher berhasil dihapus');
      loadPackages();
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal menghapus paket: $e');
    } finally {
      isLoading.value = false;
      deletingPackageIds.remove(id);
    }
  }

  void prepareEdit(VoucherPackageModel package) {
    namaPaketController.text = package.namaPaket;
    durasiController.text = package.durasi;
    hargaController.text = CurrencyFormatter.format(package.harga);
    profileMikrotikController.text = package.namaProfileMikrotik;
    prefixController.text = package.prefix;
    panjangUsernameController.text = package.panjangUsername.toString();
    
    // Convert MB to GB if it's perfectly divisible and >= 1024
    if (package.dataLimitMb >= 1024 && package.dataLimitMb % 1024 == 0) {
      dataLimitMbController.text = (package.dataLimitMb / 1024).toStringAsFixed(0);
      selectedDataUnit.value = 'GB';
    } else {
      dataLimitMbController.text = package.dataLimitMb.toString();
      selectedDataUnit.value = 'MB';
    }
    
    selectedFormatKarakter.value = package.formatKarakter;
    selectedHotspot.value = hotspots.firstWhereOrNull((h) => h.idHotspot == package.idHotspot);
  }

  void _clearForm() {
    namaPaketController.clear();
    durasiController.clear();
    hargaController.clear();
    profileMikrotikController.clear();
    prefixController.clear();
    panjangUsernameController.clear();
    dataLimitMbController.clear();
    selectedFormatKarakter.value = 'mix';
    selectedDataUnit.value = 'MB';
  }

  bool _validateForm() {
    if (selectedHotspot.value == null) {
      SnackbarUtils.showError('Error', 'Hotspot harus dipilih');
      return false;
    }
    if (namaPaketController.text.isEmpty || 
        durasiController.text.isEmpty || 
        hargaController.text.isEmpty || 
        profileMikrotikController.text.isEmpty ||
        panjangUsernameController.text.isEmpty) {
      SnackbarUtils.showError('Error', 'Field wajib diisi harus lengkap');
      return false;
    }
    return true;
  }

}
