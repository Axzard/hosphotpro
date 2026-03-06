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
import '../../../core/services/selection_service.dart';
import '../../../data/model/voucher_api_model.dart';
import '../../dashboard/view_models/dashboard_view_model.dart';

class VoucherViewModel extends GetxController {
  final VoucherRepository _voucherRepository = Get.find<VoucherRepository>();
  final RouterRepository _routerRepository = Get.find<RouterRepository>();
  final WebSocketService _webSocketService = Get.find<WebSocketService>();
  final _selectionService = Get.find<SelectionService>();

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
      if (filterPaketId.value == null) return matchStatus;
      return matchStatus && v.idPaket == filterPaketId.value;
    }).toList();
  }

  void setFilterPaket(int? id) {
    filterPaketId.value = id;
  }

  final routers = <RouterModel>[].obs;
  final voucherPackages = <VoucherPackageModel>[].obs;
  final hotspots = <HotspotModel>[].obs;

  final isLoading = false.obs;

  final _isInitialLoad = true.obs;
  final isGenerating = false.obs;
  final isDeletingAll = false.obs;
  final deletingVoucherIds = <int>{}.obs;
  final count = 1.obs;

  Rxn<RouterModel> get selectedRouter => _selectionService.selectedRouter;
  Rxn<HotspotModel> get selectedHotspot => _selectionService.selectedHotspot;
  final selectedPaketId = Rxn<int>();

  StreamSubscription? _refreshSub;

  @override
  void onInit() {
    super.onInit();
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
      if (hotspot != null) {
        onHotspotChanged(hotspot);
      }
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
          final idPaket = int.tryParse(data['id_paket']?.toString() ?? '') ?? 0;

          final package = voucherPackages.firstWhereOrNull(
            (p) => p.id == idPaket,
          );

          if (package != null) {
            final newVoucher = VoucherApiModel.fromJson(
              data,
            ).toDomain().copyWith(namaPaket: package.namaPaket);
            vouchers.insert(0, newVoucher);
          }
        } catch (e) {
          print('Error parsing voucher:created: $e');
        }
        return;
      }

      if (event == 'voucher:bulkcreated' && data != null) {
        try {
          final idPaket = int.tryParse(data['id_paket']?.toString() ?? '') ?? 0;
          final package = voucherPackages.firstWhereOrNull(
            (p) => p.id == idPaket,
          );

          if (package != null) {
            final listData = data['data'] as List?;
            if (listData != null) {
              final newVouchers = listData
                  .map(
                    (e) => VoucherApiModel.fromJson(
                      e,
                    ).toDomain().copyWith(namaPaket: package.namaPaket),
                  )
                  .toList();
              vouchers.insertAll(0, newVouchers);
            }
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

      final result = await _routerRepository.getRouters();
      routers.assignAll(result);

      if (selectedRouter.value != null) {
        final idRouter = int.tryParse(selectedRouter.value!.id) ?? 0;
        final hotspotResult = await _routerRepository.getHotspots(idRouter);
        hotspots.assignAll(hotspotResult);

        if (hotspots.isNotEmpty) {
          final currentHotspot = selectedHotspot.value;
          bool currentStillValid = hotspots.any(
            (h) => h.idHotspot == currentHotspot?.idHotspot,
          );
          print(
            '[VoucherVM] loadRouters - Current: ${currentHotspot?.namaServer}, Valid: $currentStillValid',
          );

          if (currentHotspot == null || !currentStillValid) {
            print(
              '[VoucherVM] Selection invalid or null, auto-selecting: ${hotspots.first.namaServer}',
            );
            selectedHotspot.value = hotspots.first;
          }
        }
      } else if (result.isNotEmpty) {
        _selectionService.updateRouter(result.first);
      }

      if (selectedHotspot.value != null) {
        await onHotspotChanged(selectedHotspot.value);
      }
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memuat daftar hotspot');
    } finally {
      isLoading.value = false;
      _isInitialLoad.value = false;
    }
  }

  Future<void> loadVoucherPackages() async {
    final hotspot = selectedHotspot.value;
    if (hotspot == null) return;

    try {
      final idHotspot = hotspot.idHotspot;
      final result = await _voucherRepository.getVoucherPackages(idHotspot);
      voucherPackages.value = result;
      print('Loaded ${result.length} voucher packages for hotspot $idHotspot');
    } catch (e) {
      print('Error loading voucher packages: $e');
      Get.toNamed(
        Routes.ERROR,
        arguments: 'Gagal memuat daftar paket, terjadi gangguan pada server.',
      );
      voucherPackages.clear();
    }
  }

  Future<void> loadVouchers() async {
    final dashboardVM = Get.find<DashboardViewModel>();
    if (!dashboardVM.isActiveSubscription.value) return;

    final hotspot = selectedHotspot.value;
    if (hotspot == null) return;

    if (vouchers.isEmpty) isLoading.value = true;
    try {
      final idHotspot = hotspot.idHotspot;
      final result = await _voucherRepository.getVouchersByHotspot(idHotspot);
      vouchers.value = result;
    } catch (e) {
      Get.toNamed(
        Routes.ERROR,
        arguments: 'Gagal memuat daftar voucher, terjadi gangguan pada server.',
      );
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
      await _voucherRepository.createVoucher(idPaket);
      Get.back();
      SnackbarUtils.showSuccess('Berhasil', 'Voucher berhasil dibuat');
      await loadVouchers();
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
        '${result.length} voucher berhasil dibuat',
      );

      if (result.isNotEmpty) {
        final selectedPackage = voucherPackages.firstWhereOrNull(
          (p) => p.id == idPaket,
        );

        // 🚀 Insert langsung ke list tanpa reload API
        final fixedVouchers = result.map((v) {
          if (v.harga == 0 && selectedPackage != null) {
            return VoucherModel(
              idVoucher: v.idVoucher,
              kodeVoucher: v.kodeVoucher,
              passwordVoucher: v.passwordVoucher,
              idPaket: v.idPaket,
              idRouter: v.idRouter,
              statusVoucher: v.statusVoucher,
              tanggalAktif: v.tanggalAktif,
              tanggalExpired: v.tanggalExpired,
              dibuatPada: v.dibuatPada,
              namaPaket: selectedPackage.namaPaket,
              harga: selectedPackage.harga,
              namaProfileMikrotik: v.namaProfileMikrotik,
              idHotspot: v.idHotspot,
              namaServer: v.namaServer,
              durasi: v.durasi,
              namaRouter: v.namaRouter,
              alamatIp: v.alamatIp,
              portApi: v.portApi,
            );
          }
          return v;
        }).toList();

        // Satu batch insert = 1 UI rebuild
        vouchers.insertAll(0, fixedVouchers);
        _openPrintPreview(fixedVouchers);
      }
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
    if (deletingVoucherIds.contains(idVoucher)) return;

    // Simpan voucher untuk rollback jika gagal
    final voucherToDelete = vouchers.firstWhereOrNull(
      (v) => v.idVoucher == idVoucher,
    );

    try {
      deletingVoucherIds.add(idVoucher);

      // 🚀 Optimistic update: hapus dari UI dulu, rollback jika gagal
      if (voucherToDelete != null) {
        vouchers.removeWhere((v) => v.idVoucher == idVoucher);
      }

      final success = await _voucherRepository.deleteVoucher(idVoucher);
      if (success) {
        SnackbarUtils.showSuccess('Berhasil', 'Voucher berhasil dihapus');
      } else {
        // Rollback
        if (voucherToDelete != null) vouchers.add(voucherToDelete);
        SnackbarUtils.showError('Error', 'Gagal menghapus voucher');
      }
    } catch (e) {
      // Rollback
      if (voucherToDelete != null) vouchers.add(voucherToDelete);
      SnackbarUtils.showError('Error', 'Gagal menghapus voucher: $e');
    } finally {
      deletingVoucherIds.remove(idVoucher);
    }
  }

  Future<void> deleteAllVouchers({VoucherStatus? status}) async {
    if (vouchers.isEmpty) return;

    isDeletingAll.value = true;
    try {
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

      final idsToDelete = listToDelete.map((v) => v.idVoucher).toList();
      final successIds = <int>{};

      // ✅ Batch 5 at a time — server tidak kewalahan
      const batchSize = 5;
      for (int i = 0; i < idsToDelete.length; i += batchSize) {
        final end = (i + batchSize) > idsToDelete.length
            ? idsToDelete.length
            : (i + batchSize);
        final batch = idsToDelete.sublist(i, end);

        final batchResults = await Future.wait<bool>(
          batch.map((id) async {
            try {
              return await _voucherRepository.deleteVoucher(id);
            } catch (_) {
              return false;
            }
          }),
        );

        for (int j = 0; j < batch.length; j++) {
          if (batchResults[j]) successIds.add(batch[j]);
        }

        print(
          '[DELETE ALL] Batch ${i ~/ batchSize + 1}: ${batch.length} sent, ${batchResults.where((r) => r).length} ok',
        );
      }

      print(
        '[DELETE ALL] Done: ${idsToDelete.length} total, ${successIds.length} berhasil',
      );

      if (successIds.isNotEmpty) {
        // Single UI rebuild — bukan per item
        vouchers.removeWhere((v) => successIds.contains(v.idVoucher));
        SnackbarUtils.showSuccess(
          'Berhasil',
          '${successIds.length} voucher ${status?.displayName.toUpperCase() ?? ""} berhasil dihapus',
        );
      } else {
        SnackbarUtils.showError(
          'Gagal',
          'Tidak ada voucher yang berhasil dihapus. Periksa koneksi server.',
        );
      }
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal menghapus voucher: $e');
    } finally {
      isDeletingAll.value = false;
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
    Get.toNamed(Routes.VOUCHER_DETAIL, arguments: voucher);
  }

  Future<void> onHotspotChanged(HotspotModel? hotspot) async {
    if (hotspot == null) return;
    _selectionService.updateHotspot(hotspot);
    selectedPaketId.value = null;
    await Future.wait([loadVouchers(), loadVoucherPackages()]);
  }

  void printVoucher(VoucherModel voucher) {
    _openPrintPreview([voucher]);
  }

  void printAllVouchers() {
    if (vouchers.isEmpty) {
      SnackbarUtils.showError('Error', 'Tidak ada voucher untuk dicetak');
      return;
    }
    _openPrintPreview(vouchers);
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
    );
  }
}
