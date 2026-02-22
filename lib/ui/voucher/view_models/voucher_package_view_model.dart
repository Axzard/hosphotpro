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
import '../../../../core/services/selection_service.dart';
import '../../dashboard/view_models/dashboard_view_model.dart';

class VoucherPackageViewModel extends GetxController {
  final RouterRepository _routerRepository = Get.find<RouterRepository>();
  final VoucherRepository _voucherRepository = Get.find<VoucherRepository>();
  final WebSocketService _webSocketService = Get.find<WebSocketService>();
  final _selectionService = Get.find<SelectionService>();

  final RxList<VoucherPackageModel> packages = <VoucherPackageModel>[].obs;
  final RxList<RouterModel> routers = <RouterModel>[].obs;
  final RxList<HotspotModel> hotspots = <HotspotModel>[].obs;
  
  Rxn<RouterModel> get selectedRouter => _selectionService.selectedRouter;
  Rxn<HotspotModel> get selectedHotspot => _selectionService.selectedHotspot;
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
  final dnsLoginController = TextEditingController();
  
  final RxBool gunakanSsl = false.obs;
  
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
    
    // Listen to global router changes
    ever(selectedRouter, (router) {
      if (router != null) {
        print('📡 [VoucherPackageVM] Global Router changed: ${router.namaRouter}');
        final idRouter = int.tryParse(router.id) ?? 0;
        loadHotspots(idRouter).then((_) {
          // Double check if we still need to auto-select
          if (hotspots.isNotEmpty) {
            final currentHotspot = selectedHotspot.value;
            // Only reset if current hotspot is null OR belongs to a different router
            if (currentHotspot == null || currentHotspot.idRouter != idRouter) {
              print('🔄 [VoucherPackageVM] Resetting hotspot to first in router');
              selectedHotspot.value = hotspots.first;
              loadPackages();
            } else {
              print('✅ [VoucherPackageVM] Keeping current hotspot selection: ${currentHotspot.namaServer}');
              loadPackages();
            }
          }
        });
      }
    });

    // Listen to global hotspot changes to reload packages
    ever(selectedHotspot, (hotspot) {
      if (hotspot != null) {
        loadPackages();
      }
    });
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
    dnsLoginController.dispose();
    super.onClose();
  }

  Future<void> loadRouters() async {
    final dashboardVM = Get.find<DashboardViewModel>();
    if (!dashboardVM.isActiveSubscription.value) {
      routers.clear();
      hotspots.clear();
      packages.clear();
      return;
    }

    try {
      if (routers.isEmpty) isLoading.value = true;
      final result = await _routerRepository.getRouters();
      routers.assignAll(result);

      // We no longer aggregate all hotspots.
      // Instead, we load hotspots ONLY for the selected router.
      if (selectedRouter.value != null) {
        final idRouter = int.tryParse(selectedRouter.value!.id) ?? 0;
        await loadHotspots(idRouter);
        
        // RE-ENTRY FIX: Explicitly load packages if we have a valid selection
        if (selectedHotspot.value != null) {
          await loadPackages();
        }
      } else if (result.isNotEmpty) {
        // Fallback: select first router if none selected
        _selectionService.updateRouter(result.first);
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
      
      final currentHotspot = selectedHotspot.value;
      print('🔍 [VoucherPackageVM] loadHotspots - Current: ${currentHotspot?.namaServer}, Results: ${result.length}');

      if (result.isNotEmpty) {
        bool currentStillValid = hotspots.any((h) => h.idHotspot == currentHotspot?.idHotspot);
        if (currentHotspot == null || !currentStillValid) {
          print('🔄 [VoucherPackageVM] Selection invalid or null, auto-selecting: ${result.first.namaServer}');
          selectedHotspot.value = result.first;
        } else {
          print('✅ [VoucherPackageVM] Selection still valid: ${currentHotspot.namaServer}');
        }
      } else {
        print('⚠️ [VoucherPackageVM] No hotspots found for router $idRouter');
        selectedHotspot.value = null;
      }
    } catch (e) {
      print('❌ [VoucherPackageVM] Error loading hotspots: $e');
    }
  }

  Future<void> loadPackages() async {
    final dashboardVM = Get.find<DashboardViewModel>();
    if (!dashboardVM.isActiveSubscription.value) return;

    if (selectedHotspot.value == null) return;
    
    try {
      if (packages.isEmpty) isLoading.value = true;
      final idHotspot = selectedHotspot.value!.idHotspot;
      final result = await _voucherRepository.getVoucherPackages(idHotspot);
      packages.assignAll(result);
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memuat paket: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onRouterChanged(RouterModel? router) {
    _selectionService.updateRouter(router);
  }

  Future<void> onHotspotFilterChanged(HotspotModel? hotspot) async {
    if (hotspot == null) return;
    selectedHotspot.value = hotspot;
    await loadPackages();
  }

  void onHotspotChanged(HotspotModel? hotspot) {
    _selectionService.updateHotspot(hotspot);
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
    final dashboardVM = Get.find<DashboardViewModel>();
    if (!dashboardVM.isActiveSubscription.value) {
      SnackbarUtils.showInfo('Premium Only', 'Fitur ini hanya tersedia untuk pengguna Premium.');
      return;
    }

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
        dnsLogin: dnsLoginController.text.isNotEmpty ? dnsLoginController.text : null,
        gunakanSsl: gunakanSsl.value,
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
        dnsLogin: dnsLoginController.text.isNotEmpty ? dnsLoginController.text : null,
        gunakanSsl: gunakanSsl.value,
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
    dnsLoginController.text = package.dnsLogin ?? '';
    gunakanSsl.value = package.gunakanSsl;
    
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
    dnsLoginController.clear();
    gunakanSsl.value = false;
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
