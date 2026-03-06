import 'dart:async';
import 'package:get/get.dart';
import '../../../config/routing/app_routes.dart';
import '../../../domain/models/voucher_model.dart';
import '../../../domain/models/voucher_package_model.dart';
import '../../../domain/repositories/voucher_repository.dart';
import '../../../domain/repositories/router_repository.dart';
import '../../../domain/models/router_model.dart';
import '../../../domain/models/hotspot_model.dart';
import '../../../core/utils/snackbar_utils.dart';

import '../../../ui/voucher/widgets/voucher_print_preview.dart';
import '../../../core/services/websocket_service.dart';
import '../../../core/services/session_service.dart';
import '../../../data/model/voucher_api_model.dart';
import '../../dashboard/view_models/dashboard_view_model.dart';

class VoucherViewModel extends GetxController {
  final VoucherRepository _voucherRepository = Get.find<VoucherRepository>();
  final RouterRepository _routerRepository = Get.find<RouterRepository>();
  final SessionService _sessionService = Get.find<SessionService>();
  final WebSocketService _webSocketService = Get.find<WebSocketService>();

  final vouchers = <VoucherModel>[].obs;
  final filterPaketId = Rxn<int>();

  List<VoucherModel> get stockVouchers => _applyFilters(VoucherStatus.stok);
  List<VoucherModel> get soldVouchers => _applyFilters(VoucherStatus.terjual);
  List<VoucherModel> get activeVouchers => _applyFilters(VoucherStatus.aktif);
  List<VoucherModel> get expiredVouchers =>
      _applyFilters(VoucherStatus.expired);

  List<VoucherModel> _applyFilters(VoucherStatus status) {
    return vouchers.where((v) {
      final matchStatus = v.statusVoucher == status;

      bool matchHotspot = true;
      if (selectedHotspot.value != null &&
          selectedHotspot.value!.idHotspot > 0) {
        matchHotspot = v.idHotspot == selectedHotspot.value!.idHotspot;
      }

      if (!matchHotspot) return false;
      if (filterPaketId.value == null) return matchStatus;
      return matchStatus && v.idPaket == filterPaketId.value;
    }).toList();
  }

  void setFilterPaket(int? id) {
    filterPaketId.value = id;
  }

  final routers = <RouterModel>[].obs;
  final _allPackages = <VoucherPackageModel>[];
  final voucherPackages = <VoucherPackageModel>[].obs;
  final hotspots = <HotspotModel>[].obs;

  final isLoading = false.obs;

  final _isInitialLoad = true.obs;
  final isGenerating = false.obs;
  final isDeletingAll = false.obs;
  final bulkDeletingCategory = Rxn<VoucherStatus>();
  final deletingVoucherIds = <int>{}.obs;
  final count = 1.obs;

  final selectedVoucher = Rxn<VoucherModel>();
  final Rxn<RouterModel> selectedRouter = Rxn<RouterModel>();
  final Rxn<HotspotModel> selectedHotspot = Rxn<HotspotModel>();
  final selectedPaketId = Rxn<int>();

  StreamSubscription? _refreshSub;

  @override
  void onInit() {
    super.onInit();
    final dashboardVM = Get.find<DashboardViewModel>();

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
        loadRouters();
      }
    });

    ever(selectedHotspot, (hotspot) {
      if (_isInitialLoad.value) return;
      loadVoucherPackages();
    });
  }

  void _initRealtimeListeners() {
    print('[VoucherVM] Realtime listeners initialized');
    _refreshSub = _webSocketService.eventStream.listen((eventData) {
      final event = (eventData['event'] ?? '').toString().toLowerCase();
      final data = eventData['data'];

      print('[VoucherVM] Event Received: $event');

      if (event == 'voucher:created' && data != null) {
        try {
          final parsed = VoucherApiModel.fromJson(data).toDomain();
          final enriched = _enrichVoucher(parsed);
          vouchers.insert(0, enriched);
        } catch (e) {
          print('Error parsing voucher:created: $e');
        }
        return;
      }

      if (event == 'voucher:bulkcreated' && data != null) {
        try {
          final listData = data['data'] as List?;
          if (listData != null) {
            final newVouchers = listData
                .map(
                  (e) => _enrichVoucher(VoucherApiModel.fromJson(e).toDomain()),
                )
                .toList();
            vouchers.insertAll(0, newVouchers);
          }
        } catch (e) {
          print('Error parsing voucher:bulkcreated: $e');
        }
        return;
      }

      if (event == 'voucher:deleted' && data != null) {
        final id = data['id_voucher'] as int?;
        if (id != null) {
          vouchers.removeWhere((v) => v.idVoucher == id);
        }
        return;
      }

      if ((event == 'voucher:updated' || event == 'voucher:sold') &&
          data != null) {
        final id = data['id_voucher'] as int?;
        final statusStr = data['status_voucher']?.toString();
        if (id != null && statusStr != null) {
          final index = vouchers.indexWhere((v) => v.idVoucher == id);
          if (index != -1) {
            vouchers[index] = vouchers[index].copyWith(
              statusVoucher: VoucherStatus.fromString(statusStr),
            );
          }
        }
        return;
      }

      const relevantEvents = ['hotspot_updated', 'router_updated'];
      if (relevantEvents.contains(event)) {
        loadVoucherPackages();
        loadVouchers();
      }
    });
  }

  VoucherModel _enrichVoucher(VoucherModel v) {
    final pkg = voucherPackages.firstWhereOrNull((p) => p.id == v.idPaket);
    final router = selectedRouter.value;
    final hotspot = selectedHotspot.value;

    return v.copyWith(
      namaPaket: v.namaPaket.isEmpty ? (pkg?.namaPaket ?? '') : v.namaPaket,
      harga: v.harga <= 0 ? (pkg?.harga ?? 0) : v.harga,
      durasi: v.durasi.isEmpty ? (pkg?.durasi ?? '') : v.durasi,
      namaProfileMikrotik: v.namaProfileMikrotik.isEmpty
          ? (pkg?.namaProfileMikrotik ?? '')
          : v.namaProfileMikrotik,
      namaServer: v.namaServer.isEmpty
          ? (hotspot?.namaServer ?? '')
          : v.namaServer,
      namaRouter: v.namaRouter.isEmpty
          ? (router?.namaRouter ?? '')
          : v.namaRouter,
      alamatIp: v.alamatIp ?? (router?.alamatIp),
      portApi: v.portApi ?? (router?.portApi),
      dnsLogin: v.dnsLogin ?? (pkg?.dnsLogin ?? router?.keterangan),
      gunakanSsl: v.gunakanSsl || (pkg?.gunakanSsl ?? false),
    );
  }

  @override
  void onClose() {
    _refreshSub?.cancel();
    super.onClose();
  }

  Future<void> loadRouters() async {
    final dashboardVM = Get.find<DashboardViewModel>();
    if (!dashboardVM.isActiveSubscription.value) {
      routers.clear();
      hotspots.clear();
      vouchers.clear();
      return;
    }

    try {
      if (routers.isEmpty) isLoading.value = true;

      final routerList = await _routerRepository.getRouters();
      final allRouters = [RouterModel.semua, ...routerList];

      RouterModel? nextRouter = selectedRouter.value;
      if (nextRouter == null) {
        final savedRouterId = _sessionService.selectedRouterId.value;
        if (savedRouterId != null) {
          nextRouter = allRouters.firstWhereOrNull(
            (r) => r.id == savedRouterId,
          );
        }
      }
      if (nextRouter == null && allRouters.isNotEmpty) {
        nextRouter = RouterModel.semua;
      }

      final idRouter = int.tryParse(nextRouter?.id ?? '') ?? 0;
      final hotspotList = await _routerRepository.getHotspots(idRouter);
      final allHotspots = [HotspotModel.semua, ...hotspotList];

      HotspotModel? nextHotspot = selectedHotspot.value;
      bool currentStillValid = allHotspots.any(
        (h) => h.idHotspot == nextHotspot?.idHotspot,
      );

      if (nextHotspot == null || !currentStillValid) {
        final savedHotspotId = _sessionService.voucherHotspotId.value;
        if (savedHotspotId != null) {
          nextHotspot = allHotspots.firstWhereOrNull(
            (h) => h.idHotspot == savedHotspotId,
          );
        }
      }

      if (nextHotspot == null && allHotspots.isNotEmpty) {
        nextHotspot = HotspotModel.semua;
      }

      List<VoucherModel> vchList = [];
      List<VoucherPackageModel> pkgList = [];

      try {
        pkgList = await _voucherRepository.getVoucherPackages(0);

        final paketIds = pkgList
            .map((p) => p.id)
            .whereType<int>()
            .where((id) => id > 0)
            .toList();
        vchList = await _voucherRepository.getAllVouchersByPackages(paketIds);
      } catch (e) {
        print('[VoucherVM] Load Data Error: $e');
      }

      routers.assignAll(allRouters);
      selectedRouter.value = nextRouter;
      hotspots.assignAll(allHotspots);
      selectedHotspot.value = nextHotspot;

      _allPackages.clear();
      _allPackages.addAll(pkgList);
      _applyLocalPackageFilter();

      vouchers.assignAll(vchList);
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memuat data voucher: $e');
    } finally {
      isLoading.value = false;
      _isInitialLoad.value = false;
    }
  }

  Future<void> loadVoucherPackages() async {
    _applyLocalPackageFilter();
  }

  void _applyLocalPackageFilter() {
    final idHotspot = selectedHotspot.value?.idHotspot ?? 0;
    if (idHotspot <= 0) {
      voucherPackages.assignAll(_allPackages);
    } else {
      voucherPackages.assignAll(
        _allPackages.where((p) => p.idHotspot == idHotspot).toList(),
      );
    }
  }

  Future<void> loadVouchers() async {
    final dashboardVM = Get.find<DashboardViewModel>();
    if (!dashboardVM.isActiveSubscription.value) return;

    final idHotspot = selectedHotspot.value?.idHotspot ?? -1;

    try {
      final cached = await _voucherRepository.getVouchersByHotspotFromCache(
        idHotspot,
      );
      if (cached.isNotEmpty) {
        vouchers.value = cached;
      }
    } catch (e) {
      print('Cache load error: $e');
    }

    if (vouchers.isEmpty) isLoading.value = true;
    try {
      final paketIds = _allPackages
          .map((p) => p.id)
          .whereType<int>()
          .where((id) => id > 0)
          .toList();
      if (paketIds.isNotEmpty) {
        final result = await _voucherRepository.getAllVouchersByPackages(
          paketIds,
        );
        vouchers.assignAll(result);
      }
    } catch (e) {
      if (vouchers.isEmpty) {
        Get.toNamed(
          Routes.ERROR,
          arguments:
              'Gagal memuat daftar voucher, terjadi gangguan pada server.',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createVoucher() async {
    final dashboardVM = Get.find<DashboardViewModel>();
    if (!dashboardVM.isActiveSubscription.value) {
      SnackbarUtils.showInfo(
        'Premium Only',
        'Fitur ini hanya tersedia untuk pengguna Premium.',
      );
      return;
    }

    final idPaket = selectedPaketId.value;

    if (idPaket == null) {
      Get.snackbar('Error', 'Pilih paket terlebih dahulu');
      return;
    }

    isGenerating.value = true;
    try {
      final result = await _voucherRepository.createVoucher(idPaket);
      Get.back();
      SnackbarUtils.showSuccess('Berhasil', 'Voucher berhasil dibuat');

      if (result != null) {
        final enriched = _enrichVoucher(result);
        vouchers.insert(0, enriched);
      }

      loadVouchers();
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal membuat voucher: $e');
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> createBulkVoucher() async {
    final idPaket = selectedPaketId.value;

    if (idPaket == null) {
      Get.snackbar('Error', 'Pilih paket terlebih dahulu');
      return;
    }

    if (count.value <= 0 || count.value > 500) {
      SnackbarUtils.showError('Error', 'Jumlah harus antara 1 - 500');
      return;
    }

    isGenerating.value = true;
    try {
      final result = await _voucherRepository.createVoucherBulk(
        idPaket,
        count.value,
      );

      Get.back();
      SnackbarUtils.showSuccess(
        'Berhasil',
        '${count.value} voucher berhasil dibuat',
      );

      if (result.isNotEmpty) {
        final fixedVouchers = result.map((v) => _enrichVoucher(v)).toList();
        vouchers.insertAll(0, fixedVouchers);
        _openPrintPreview(fixedVouchers);
      }

      loadVouchers();
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal membuat voucher bulk: $e');
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> createVoucherPackage(VoucherPackageModel package) async {
    final dashboardVM = Get.find<DashboardViewModel>();
    if (!dashboardVM.isActiveSubscription.value) {
      SnackbarUtils.showInfo(
        'Premium Only',
        'Fitur ini hanya tersedia untuk pengguna Premium.',
      );
      return;
    }

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

  Future<void> deleteVoucher(int idVoucher) async {
    if (deletingVoucherIds.contains(idVoucher)) {
      SnackbarUtils.showInfo(
        'Harap Tunggu',
        'Voucher sedang dalam proses penghapusan',
      );
      return;
    }

    deletingVoucherIds.add(idVoucher);

    final index = vouchers.indexWhere((v) => v.idVoucher == idVoucher);
    VoucherModel? removedVoucher;
    if (index != -1) {
      removedVoucher = vouchers[index];
      vouchers.removeAt(index);
    }

    try {
      final success = await _voucherRepository.deleteVoucher(idVoucher);
      if (success) {
        final idHotspot = selectedHotspot.value?.idHotspot ?? 0;
        if (idHotspot != 0) {
          await _voucherRepository.updateVoucherCache(idHotspot, vouchers);
        }
        SnackbarUtils.showSuccess('Berhasil', 'Voucher berhasil dihapus');
      } else {
        if (removedVoucher != null) {
          vouchers.insert(index.clamp(0, vouchers.length), removedVoucher);
        }
        SnackbarUtils.showError('Error', 'Gagal menghapus voucher');
      }
    } catch (e) {
      if (removedVoucher != null) {
        vouchers.insert(index.clamp(0, vouchers.length), removedVoucher);
      }
      SnackbarUtils.showError('Error', 'Gagal menghapus voucher: $e');
    } finally {
      deletingVoucherIds.remove(idVoucher);
    }
  }

  Future<void> deleteAllVouchers({VoucherStatus? status}) async {
    if (vouchers.isEmpty) return;

    isDeletingAll.value = true;
    bulkDeletingCategory.value = status;
    try {
      int successCount = 0;

      final listToDelete = status != null
          ? vouchers.where((v) => v.statusVoucher == status).toList()
          : List<VoucherModel>.from(vouchers);

      if (listToDelete.isEmpty) {
        SnackbarUtils.showInfo(
          'Informasi',
          'Tidak ada voucher dengan status ${status?.displayName.toUpperCase() ?? "tersebut"} untuk dihapus',
        );
        return;
      }

      for (var voucher in listToDelete) {
        final success = await _voucherRepository.deleteVoucher(
          voucher.idVoucher,
        );
        if (success) {
          vouchers.removeWhere((v) => v.idVoucher == voucher.idVoucher);
          successCount++;
        }
      }

      if (successCount > 0) {
        SnackbarUtils.showSuccess(
          'Berhasil',
          '$successCount voucher ${status?.displayName.toUpperCase() ?? ""} berhasil dihapus',
        );
      }
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal menghapus beberapa voucher: $e');
    } finally {
      isDeletingAll.value = false;
      bulkDeletingCategory.value = null;
      await loadVouchers();
    }
  }

  Future<void> sellVoucher(VoucherModel voucher, String paymentMethod) async {
    try {
      isLoading.value = true;
      final price = await _voucherRepository.sellVoucher(
        voucher.idVoucher,
        paymentMethod,
      );

      SnackbarUtils.showSuccess(
        'Berhasil',
        'Voucher berhasil dijual dengan harga Rp${price.toStringAsFixed(0)}',
      );

      final index = vouchers.indexWhere(
        (v) => v.idVoucher == voucher.idVoucher,
      );
      if (index != -1) {
        vouchers[index] = voucher.copyWith(
          statusVoucher: VoucherStatus.terjual,
        );
      }

      await loadVouchers();
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal menjual voucher: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadActiveVouchers() async {
    try {
      isLoading.value = true;
      await _voucherRepository.getActiveVouchers();
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memuat voucher aktif: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToDetail(VoucherModel voucher) {
    selectedVoucher.value = voucher;
    Get.toNamed(Routes.VOUCHER_DETAIL, arguments: voucher);

    if (voucher.namaProfileMikrotik.isEmpty || voucher.namaServer.isEmpty) {
      _fetchFullVoucherDetail(voucher.idVoucher);
    }
  }

  Future<void> _fetchFullVoucherDetail(int idVoucher) async {
    try {
      final detail = await _voucherRepository.getVoucherDetail(idVoucher);
      if (detail != null) {
        if (selectedVoucher.value?.idVoucher == idVoucher) {
          selectedVoucher.value = detail;
        }

        final index = vouchers.indexWhere((v) => v.idVoucher == idVoucher);
        if (index != -1) {
          vouchers[index] = detail;
        }
      }
    } catch (e) {
      print('[VoucherVM] Gagal fetch detail voucher: $e');
    }
  }

  Future<void> onHotspotChanged(HotspotModel? hotspot) async {
    if (hotspot == null) return;
    selectedHotspot.value = hotspot;
    selectedPaketId.value = null;
    _sessionService.setVoucherHotspotId(hotspot.idHotspot);
    await Future.wait([loadVouchers(), loadVoucherPackages()]);
  }

  void printVoucher(VoucherModel voucher) async {
    _openPrintPreview([voucher]);
  }

  void printAllVouchers() {
    if (vouchers.isEmpty) {
      SnackbarUtils.showError('Error', 'Tidak ada voucher untuk dicetak');
      return;
    }
    _openPrintPreview(vouchers);
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      await loadRouters();
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<VoucherModel>> sellBulkVouchersForPrint(
    List<VoucherModel> vouchersToPrint,
  ) async {
    final List<VoucherModel> updatedVouchers = [];
    for (final voucher in vouchersToPrint) {
      if (voucher.statusVoucher == VoucherStatus.stok) {
        try {
          await _voucherRepository.sellVoucher(voucher.idVoucher, 'cash');
          final updated = voucher.copyWith(
            statusVoucher: VoucherStatus.terjual,
          );

          final index = vouchers.indexWhere(
            (v) => v.idVoucher == voucher.idVoucher,
          );
          if (index != -1) {
            vouchers[index] = updated;
          }
          updatedVouchers.add(updated);
        } catch (e) {
          updatedVouchers.add(voucher);
          print('[VoucherVM] Gagal sell voucher ${voucher.idVoucher}: $e');
        }
      } else {
        updatedVouchers.add(voucher);
      }
    }
    return updatedVouchers;
  }

  void _openPrintPreview(List<VoucherModel> vouchersToPrint) {
    if (selectedHotspot.value == null) {
      SnackbarUtils.showError('Error', 'Hotspot belum dipilih');
      return;
    }

    Get.to(
      () => VoucherPrintPreview(
        vouchers: vouchersToPrint,
        routerName: selectedHotspot.value!.namaServer,
      ),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 200),
    );
  }
}
