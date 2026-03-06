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
  final Rxn<HotspotModel> formSelectedHotspot = Rxn<HotspotModel>(); // Separate state for form
  final RxBool isLoading = false.obs;
  final RxBool _isInitialLoad = true.obs;
  final RxSet<int> deletingPackageIds = <int>{}.obs;

  final namaPaketController = TextEditingController();
  final durasiController = TextEditingController();
  final hargaController = TextEditingController();
  final profileMikrotikController = TextEditingController();
  final prefixController = TextEditingController();
  final panjangUsernameController = TextEditingController();
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
    final dashboardVM = Get.find<DashboardViewModel>();

    // Listen to subscription status changes
    ever(dashboardVM.isActiveSubscription, (bool isActive) {
      if (isActive && (routers.isEmpty || _isInitialLoad.value)) {
        loadRouters();
      }
    });

    loadRouters();
    _initRealtimeListeners();

    ever(selectedRouter, (router) {
      if (_isInitialLoad.value) return;
      if (router != null) {
        print('[VoucherPackageVM] Global Router changed: ${router.namaRouter}');
        final idRouter = int.tryParse(router.id) ?? 0;
        loadHotspots(idRouter).then((_) {
          loadPackages();
        });
      }
    });

    ever(selectedHotspot, (hotspot) {
      if (_isInitialLoad.value) return;
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
      
      // 1. Load Routers from Cache first
      final cachedRouters = await _routerRepository.getRoutersFromCache();
      if (cachedRouters.isNotEmpty) {
        routers.assignAll([RouterModel.semua, ...cachedRouters]);
      }

      // 2. Fetch Routers from Network
      final result = await _routerRepository.getRouters();
      final allRouters = [RouterModel.semua, ...result];
      routers.assignAll(allRouters);

      // Determine selected router
      RouterModel? nextRouter = selectedRouter.value;
      if (nextRouter == null) {
        final savedRouterId = _sessionService.selectedRouterId.value;
        if (savedRouterId != null) {
          nextRouter = allRouters.firstWhereOrNull((r) => r.id == savedRouterId);
        }
      }
      if (nextRouter == null && allRouters.isNotEmpty) {
        nextRouter = RouterModel.semua;
      }
      selectedRouter.value = nextRouter;

      // 2. Fetch Hotspots
      final idRouter = int.tryParse(nextRouter?.id ?? '') ?? 0;
      final hotspotList = await _routerRepository.getHotspots(idRouter);
      final allHotspots = [HotspotModel.semua, ...hotspotList];

      // Determine selected hotspot
      HotspotModel? nextHotspot = selectedHotspot.value;
      bool currentStillValid = allHotspots.any(
        (h) => h.idHotspot == nextHotspot?.idHotspot,
      );

      if (nextHotspot == null || !currentStillValid) {
        final savedHotspotId = _sessionService.packageHotspotId.value;
        if (savedHotspotId != null) {
          nextHotspot = allHotspots.firstWhereOrNull((h) => h.idHotspot == savedHotspotId);
        }
      }
      
      if (nextHotspot == null && allHotspots.isNotEmpty) {
        nextHotspot = HotspotModel.semua;
      }

      // 3. Fetch Packages
      final idHotspot = nextHotspot?.idHotspot ?? 0;
      final pList = await _voucherRepository.getVoucherPackages(idHotspot);

      // 4. Update states
      routers.assignAll(allRouters);
      selectedRouter.value = nextRouter;
      hotspots.assignAll(allHotspots);
      selectedHotspot.value = nextHotspot;
      packages.assignAll(pList);

    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memuat data: $e');
    } finally {
      isLoading.value = false;
      _isInitialLoad.value = false;
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

    final idHotspot = selectedHotspot.value?.idHotspot ?? 0;
    if (idHotspot == 0) return;

    // 1. Load from cache first
    try {
      final cached = await _voucherRepository.getVoucherPackagesFromCache(idHotspot);
      if (cached.isNotEmpty) {
        packages.assignAll(cached);
      }
    } catch (e) {
      print('Cache load error: $e');
    }

    // 2. Load from network
    try {
      if (packages.isEmpty) isLoading.value = true;
      final result = await _voucherRepository.getVoucherPackages(idHotspot);
      packages.assignAll(result);
    } catch (e) {
      if (packages.isEmpty) {
        SnackbarUtils.showError('Error', 'Gagal memuat paket: $e');
      }
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

  void onFormHotspotChanged(HotspotModel? hotspot) {
    formSelectedHotspot.value = hotspot;
  }

  void onFormatKarakterChanged(String? value) {
    if (value != null) {
      selectedFormatKarakter.value = value;
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
      final package = VoucherPackageModel(
        id: 0,
        idRouter: null,
        idHotspot: formSelectedHotspot.value!.idHotspot,
        namaPaket: namaPaketController.text,
        durasi: durasiController.text,
        harga: CurrencyFormatter.parse(hargaController.text),
        namaProfileMikrotik: profileMikrotikController.text,
        prefix: prefixController.text,
        panjangUsername: int.tryParse(panjangUsernameController.text) ?? 4,
        formatKarakter: selectedFormatKarakter.value,
        dataLimitMb: 0,
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
      final package = VoucherPackageModel(
        id: id,
        idRouter: null,
        idHotspot: formSelectedHotspot.value!.idHotspot,
        namaPaket: namaPaketController.text,
        durasi: durasiController.text,
        harga: CurrencyFormatter.parse(hargaController.text),
        namaProfileMikrotik: profileMikrotikController.text,
        prefix: prefixController.text,
        panjangUsername: int.tryParse(panjangUsernameController.text) ?? 4,
        formatKarakter: selectedFormatKarakter.value,
        dataLimitMb: 0,
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


    selectedFormatKarakter.value = package.formatKarakter;

    final existingHotspot = hotspots.firstWhereOrNull(
      (h) => h.idHotspot == package.idHotspot,
    );

    if (existingHotspot != null) {
      formSelectedHotspot.value = existingHotspot;
    } else {
      formSelectedHotspot.value = null;
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
    dnsLoginController.clear();
    gunakanSsl.value = false;
    selectedFormatKarakter.value = 'mix';
    formSelectedHotspot.value = null;
  }

  bool _validateForm() {
    if (formSelectedHotspot.value == null || formSelectedHotspot.value?.idHotspot == -1) {
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
