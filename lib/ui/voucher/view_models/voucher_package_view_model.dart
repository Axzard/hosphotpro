import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../../../../domain/models/voucher_package_model.dart';
import '../../../../domain/models/router_model.dart';
import '../../../../domain/models/hotspot_model.dart';
import '../../../domain/repositories/router_repository.dart';
import '../../../domain/repositories/voucher_repository.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../../core/services/session_service.dart';
import '../../dashboard/view_models/dashboard_view_model.dart';

class VoucherPackageViewModel extends GetxController {
  final RouterRepository _routerRepository = Get.find<RouterRepository>();
  final VoucherRepository _voucherRepository = Get.find<VoucherRepository>();
  final WebSocketService _webSocketService = Get.find<WebSocketService>();
  final SessionService _sessionService = Get.find<SessionService>();

  final RxList<VoucherPackageModel> packages = <VoucherPackageModel>[].obs;
  final RxList<RouterModel> routers = <RouterModel>[].obs;
  final RxList<HotspotModel> hotspots = <HotspotModel>[].obs;

  final Rxn<RouterModel> selectedRouter = Rxn<RouterModel>();
  final Rxn<HotspotModel> selectedHotspot = Rxn<HotspotModel>();
  final RxBool isLoading = false.obs;
  final RxSet<int> deletingPackageIds = <int>{}.obs;

  final namaPaketController = TextEditingController();
  final durasiController = TextEditingController();
  final hargaController = TextEditingController();
  final profileMikrotikController = TextEditingController();
  final prefixController = TextEditingController();
  final panjangUsernameController = TextEditingController();
  final dataLimitMbController = TextEditingController();
  final rateLimitController = TextEditingController();
  final dnsLoginController = TextEditingController();

  final RxBool gunakanSsl = false.obs;

  final RxString selectedFormatKarakter = 'mix'.obs;
  final List<String> formatKarakterOptions = [
    'huruf_kecil',
    'huruf_besar',
    'angka',
    'mix',
  ];

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

    ever(selectedRouter, (router) {
      if (router != null) {
        print('[VoucherPackageVM] Global Router changed: ${router.namaRouter}');
        final idRouter = int.tryParse(router.id) ?? 0;
        loadHotspots(idRouter).then((_) {
          if (hotspots.isNotEmpty) {
            final currentHotspot = selectedHotspot.value;

            if (currentHotspot == null || currentHotspot.idRouter != idRouter) {
              print('[VoucherPackageVM] Resetting hotspot to Semua Hotspot');
              selectedHotspot.value = HotspotModel.semua;
              loadPackages();
            } else {
              print(
                '[VoucherPackageVM] Keeping current hotspot selection: ${currentHotspot.namaServer}',
              );
              loadPackages();
            }
          }
        });
      }
    });

    ever(selectedHotspot, (hotspot) {
      if (hotspot != null) {
        loadPackages();
      }
    });
  }

  void _initRealtimeListeners() {
    print('[VoucherPackageVM] Realtime listeners initialized');
    _refreshSub = _webSocketService.eventStream.listen((eventData) {
      final event = eventData['event'] ?? '';
      print('[VoucherPackageVM] Refreshing due to Event: $event');
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
    rateLimitController.dispose();
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
      routers.assignAll([RouterModel.semua, ...result]);

      if (selectedRouter.value == null) {
        final savedRouterId = _sessionService.selectedRouterId.value;
        if (savedRouterId != null) {
          selectedRouter.value = routers.firstWhereOrNull((r) => r.id == savedRouterId);
        }
      }

      // If still null, pick "Semua Router" by default
      if (selectedRouter.value == null && routers.isNotEmpty) {
        selectedRouter.value = RouterModel.semua;
      }

      final idRouter = int.tryParse(selectedRouter.value?.id ?? '') ?? 0;
      await loadHotspots(idRouter);

      if (selectedHotspot.value == null) {
        final savedHotspotId = _sessionService.packageHotspotId.value;
        if (savedHotspotId != null) {
          selectedHotspot.value = hotspots.firstWhereOrNull((h) => h.idHotspot == savedHotspotId);
        }
      }

      // If still null, pick first
      if (selectedHotspot.value == null && hotspots.isNotEmpty) {
        selectedHotspot.value = hotspots.first;
      }

      await loadPackages();
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memuat data: $e');
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> loadHotspots(int idRouter) async {
    try {
      List<HotspotModel> result = await _routerRepository.getHotspots(idRouter);
      
      hotspots.assignAll([HotspotModel.semua, ...result]);

      final currentHotspot = selectedHotspot.value;
      print(
        '[VoucherPackageVM] loadHotspots - Current: ${currentHotspot?.namaServer}, Results: ${result.length}',
      );

      if (result.isNotEmpty) {
        bool currentStillValid = hotspots.any(
          (h) => h.idHotspot == currentHotspot?.idHotspot,
        );

        if (currentHotspot == null || !currentStillValid) {
          print(
            '[VoucherPackageVM] Selection invalid or null, auto-selecting semua hotspot',
          );
          selectedHotspot.value = HotspotModel.semua;
        } else {
          print(
            '[VoucherPackageVM] Selection still valid: ${currentHotspot.namaServer}',
          );
        }
      } else {
        print('[VoucherPackageVM] No hotspots found for router $idRouter');
        selectedHotspot.value = null;
      }
    } catch (e) {
      print('[VoucherPackageVM] Error loading hotspots: $e');
    }
  }

  Future<void> loadPackages() async {
    final dashboardVM = Get.find<DashboardViewModel>();
    if (!dashboardVM.isActiveSubscription.value) return;

    if (selectedHotspot.value == null) return;

    try {
      if (packages.isEmpty) isLoading.value = true;

      final idHotspot = selectedHotspot.value?.idHotspot ?? 0;
      final result = await _voucherRepository.getVoucherPackages(idHotspot);
      packages.assignAll(result);
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memuat paket: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onRouterChanged(RouterModel? router) {
    if (router == null) return;
    selectedRouter.value = router;
    _sessionService.setRouterId(router.id);
  }

  Future<void> onHotspotFilterChanged(HotspotModel? hotspot) async {
    if (hotspot == null) return;
    selectedHotspot.value = hotspot;
    _sessionService.setPackageHotspotId(hotspot.idHotspot);
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
    final dashboardVM = Get.find<DashboardViewModel>();
    if (!dashboardVM.isActiveSubscription.value) {
      SnackbarUtils.showInfo(
        'Premium Only',
        'Fitur ini hanya tersedia untuk pengguna Premium.',
      );
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
        rateLimit: rateLimitController.text.isNotEmpty
            ? rateLimitController.text
            : null,
        dnsLogin: dnsLoginController.text.isNotEmpty
            ? dnsLoginController.text
            : null,
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
        rateLimit: rateLimitController.text.isNotEmpty
            ? rateLimitController.text
            : null,
        dnsLogin: dnsLoginController.text.isNotEmpty
            ? dnsLoginController.text
            : null,
        gunakanSsl: gunakanSsl.value,
      );

      await _voucherRepository.updateVoucherPackage(id, package);
      Get.back();
      SnackbarUtils.showSuccess(
        'Berhasil',
        'Paket voucher berhasil diperbarui',
      );
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
    rateLimitController.text = package.rateLimit ?? '';
    dnsLoginController.text = package.dnsLogin ?? '';
    gunakanSsl.value = package.gunakanSsl;

    if (package.dataLimitMb >= 1024 && package.dataLimitMb % 1024 == 0) {
      dataLimitMbController.text = (package.dataLimitMb / 1024).toStringAsFixed(
        0,
      );
      selectedDataUnit.value = 'GB';
    } else {
      dataLimitMbController.text = package.dataLimitMb.toString();
      selectedDataUnit.value = 'MB';
    }

    selectedFormatKarakter.value = package.formatKarakter;

    final existingHotspot = hotspots.firstWhereOrNull(
      (h) => h.idHotspot == package.idHotspot,
    );

    if (existingHotspot != null) {
      selectedHotspot.value = existingHotspot;
    } else {
      selectedHotspot.value = null;
      print(
        '[VoucherForm] Warning: Package hotspot ID ${package.idHotspot} not found in current hotspots list',
      );
    }
  }

  void _clearForm() {
    namaPaketController.clear();
    durasiController.clear();
    hargaController.clear();
    profileMikrotikController.clear();
    prefixController.clear();
    panjangUsernameController.clear();
    dataLimitMbController.clear();
    rateLimitController.clear();
    dnsLoginController.clear();
    gunakanSsl.value = false;
    selectedFormatKarakter.value = 'mix';
    selectedDataUnit.value = 'MB';
  }

  bool _validateForm() {
    if (selectedHotspot.value == null || selectedHotspot.value?.idHotspot == -1) {
      SnackbarUtils.showError('Error', 'Hotspot harus dipilih secara spesifik untuk membuat paket');
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
