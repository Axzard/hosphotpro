import 'dart:async';
import 'package:get/get.dart';
import '../../../config/routing/app_routes.dart';
import '../../../domain/models/voucher_model.dart';
import '../../../domain/models/voucher_package_model.dart';
import '../../../domain/models/voucher_repository.dart';
import '../../../domain/models/router_repository.dart';
import '../../../domain/models/router_model.dart';
import '../../../domain/models/hotspot_model.dart';
import '../../../core/utils/snackbar_utils.dart';
// import '../../../domain/models/subscription_package_model.dart'; // No longer used for hotspot vouchers
// import '../../../domain/models/subscription_repository.dart'; // No longer used for hotspot vouchers
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
  final filterPaketId = Rxn<int>(); // Package filter ID

  // Filtered lists for TabView (respecting both status and package filter)
  List<VoucherModel> get stockVouchers => _applyFilters(VoucherStatus.stok);
  List<VoucherModel> get soldVouchers => _applyFilters(VoucherStatus.terjual);
  List<VoucherModel> get activeVouchers => _applyFilters(VoucherStatus.aktif);
  List<VoucherModel> get expiredVouchers => _applyFilters(VoucherStatus.expired);

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
  // State management for optimization
  final _isInitialLoad = true.obs;
  final isGenerating = false.obs;
  final isDeletingAll = false.obs;
  final deletingVoucherIds = <int>{}.obs; // Track IDs being deleted
  final count = 1.obs;

  // Link selection to SelectionService
  Rxn<RouterModel> get selectedRouter => _selectionService.selectedRouter;
  Rxn<HotspotModel> get selectedHotspot => _selectionService.selectedHotspot;
  final selectedPaketId = Rxn<int>();

  StreamSubscription? _refreshSub;

  @override
  void onInit() {
    super.onInit();
    loadRouters();
    _initRealtimeListeners();

    // Listen to global changes to reload data - Skip if initial load to prevent double load
    ever(selectedRouter, (router) {
      if (_isInitialLoad.value) return;
      if (router != null) {
        loadRouters(); // This will refresh hotspots for the new router
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
    print('🚀 [VoucherVM] Realtime listeners initialized');
    _refreshSub = _webSocketService.eventStream.listen((eventData) {
      final event = (eventData['event'] ?? '').toString().toLowerCase();
      final data = eventData['data'];
      
      print('🎟️ [VoucherVM] Event Received: $event');

      // 1. Created (Single)
      if (event == 'voucher:created' && data != null) {
        try {
          final idPaket = int.tryParse(data['id_paket']?.toString() ?? '') ?? 0;
          // Check if this package belongs to our current hotspot packages
          final package = voucherPackages.firstWhereOrNull((p) => p.id == idPaket);

          if (package != null) {
            final newVoucher = VoucherApiModel.fromJson(data).toDomain().copyWith(
              namaPaket: package.namaPaket,
            );
            vouchers.insert(0, newVoucher);
          }
        } catch (e) {
          print('Error parsing voucher:created: $e');
        }
        return;
      }

      // 2. Created (Bulk)
      if (event == 'voucher:bulkcreated' && data != null) {
        try {
          final idPaket = int.tryParse(data['id_paket']?.toString() ?? '') ?? 0;
          final package = voucherPackages.firstWhereOrNull((p) => p.id == idPaket);

          if (package != null) {
            final listData = data['data'] as List?;
            if (listData != null) {
              final newVouchers = listData
                  .map((e) => VoucherApiModel.fromJson(e).toDomain().copyWith(
                        namaPaket: package.namaPaket,
                      ))
                  .toList();
              vouchers.insertAll(0, newVouchers);
            }
          }
        } catch (e) {
          print('Error parsing voucher:bulkcreated: $e');
        }
        return;
      }

      // 3. Deleted
      if (event == 'voucher:deleted' && data != null) {
        final id = data['id_voucher'] as int?;
        if (id != null) {
          vouchers.removeWhere((v) => v.idVoucher == id);
        }
        return;
      }

      // 4. Updated / Sold
      if ((event == 'voucher:updated' || event == 'voucher:sold') && data != null) {
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

      // Fallback for other relevant structural changes
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
      // Only show full loader if we have no routers yet
      if (routers.isEmpty) isLoading.value = true;
      
      final result = await _routerRepository.getRouters();
      routers.assignAll(result);

      // We no longer aggregate all hotspots.
      // Instead, we load hotspots ONLY for the selected router.
      if (selectedRouter.value != null) {
        final idRouter = int.tryParse(selectedRouter.value!.id) ?? 0;
        final hotspotResult = await _routerRepository.getHotspots(idRouter);
        hotspots.assignAll(hotspotResult);

        // PERSISTENCE FIX: Only auto-select first hotspot if none is currently selected
        // OR if the current selected hotspot doesn't belong to the results
        if (hotspots.isNotEmpty) {
          final currentHotspot = selectedHotspot.value;
          bool currentStillValid = hotspots.any((h) => h.idHotspot == currentHotspot?.idHotspot);
          print('🔍 [VoucherVM] loadRouters - Current: ${currentHotspot?.namaServer}, Valid: $currentStillValid');
          
          if (currentHotspot == null || !currentStillValid) {
            print('🔄 [VoucherVM] Selection invalid or null, auto-selecting: ${hotspots.first.namaServer}');
            selectedHotspot.value = hotspots.first;
          }
        }
      } else if (result.isNotEmpty) {
        // Fallback: select first router if none selected
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
      Get.toNamed(Routes.ERROR, arguments: 'Gagal memuat daftar paket, terjadi gangguan pada server.');
      voucherPackages.clear();
    }
  }
  // Hotspots are now loaded during loadRouters (aggregation)

  /// Load vouchers for the selected hotspot
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
      Get.toNamed(Routes.ERROR, arguments: 'Gagal memuat daftar voucher, terjadi gangguan pada server.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a single voucher
  Future<void> createVoucher() async {
    final dashboardVM = Get.find<DashboardViewModel>();
    if (!dashboardVM.isActiveSubscription.value) {
      SnackbarUtils.showInfo('Premium Only', 'Fitur ini hanya tersedia untuk pengguna Premium.');
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
      Get.back(); // Close bottom sheet if open
      SnackbarUtils.showSuccess('Berhasil', 'Voucher berhasil dibuat');
      await loadVouchers();
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal membuat voucher: $e');
    } finally {
      isGenerating.value = false;
    }
  }

  /// Create bulk vouchers
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

      Get.back(); // Close bottom sheet
      SnackbarUtils.showSuccess(
        'Berhasil',
        '${count.value} voucher berhasil dibuat',
      );

      await loadVouchers();

      // Navigate to print preview if we got vouchers back
      if (result.isNotEmpty) {
        // Fix: Ensure price is populated from the selected package if missing in response
        final selectedPackage = voucherPackages.firstWhereOrNull((p) => p.id == idPaket);
        if (selectedPackage != null) {
          final fixedVouchers = result.map((v) {
            if (v.harga == 0) {
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
                namaPaket: v.namaPaket,
                harga: selectedPackage.harga, // Use package price
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
          _openPrintPreview(fixedVouchers);
        } else {
          _openPrintPreview(result);
        }
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
      SnackbarUtils.showInfo('Premium Only', 'Fitur ini hanya tersedia untuk pengguna Premium.');
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

  /// Delete a voucher
  Future<void> deleteVoucher(int idVoucher) async {
    if (deletingVoucherIds.contains(idVoucher)) return;

    try {
      deletingVoucherIds.add(idVoucher);
      final success = await _voucherRepository.deleteVoucher(idVoucher);
      if (success) {
        vouchers.removeWhere((v) => v.idVoucher == idVoucher);
        SnackbarUtils.showSuccess('Berhasil', 'Voucher berhasil dihapus');
      } else {
        SnackbarUtils.showError('Error', 'Gagal menghapus voucher');
      }
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal menghapus voucher: $e');
    } finally {
      deletingVoucherIds.remove(idVoucher);
    }
  }

  /// Delete vouchers in current list, optionally filtered by status
  Future<void> deleteAllVouchers({VoucherStatus? status}) async {
    if (vouchers.isEmpty) return;
    
    isDeletingAll.value = true;
    try {
      int successCount = 0;
      // Filter list based on status if provided, otherwise all in current list
      final listToDelete = status != null 
          ? vouchers.where((v) => v.statusVoucher == status).toList()
          : List<VoucherModel>.from(vouchers);
      
      if (listToDelete.isEmpty) {
        SnackbarUtils.showInfo('Informasi', 'Tidak ada voucher dengan status ${status?.displayName.toUpperCase() ?? "tersebut"} untuk dihapus');
        return;
      }

      for (var voucher in listToDelete) {
        final success = await _voucherRepository.deleteVoucher(voucher.idVoucher);
        if (success) {
          vouchers.removeWhere((v) => v.idVoucher == voucher.idVoucher);
          successCount++;
        }
      }
      
      if (successCount > 0) {
        SnackbarUtils.showSuccess('Berhasil', '$successCount voucher ${status?.displayName.toUpperCase() ?? ""} berhasil dihapus');
      }
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal menghapus beberapa voucher: $e');
    } finally {
      isDeletingAll.value = false;
      await loadVouchers(); // Final sync
    }
  }

  /// Sell a voucher
  Future<void> sellVoucher(VoucherModel voucher, String paymentMethod) async {
    try {
      isLoading.value = true;
      final price = await _voucherRepository.sellVoucher(voucher.idVoucher, paymentMethod);
      
      SnackbarUtils.showSuccess('Berhasil', 'Voucher berhasil dijual dengan harga Rp${price.toStringAsFixed(0)}');
      
      // Update local status to avoid full refresh if possible
      final index = vouchers.indexWhere((v) => v.idVoucher == voucher.idVoucher);
      if (index != -1) {
        vouchers[index] = voucher.copyWith(statusVoucher: VoucherStatus.terjual);
      }
      
      await loadVouchers(); // Refresh list to be sure
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal menjual voucher: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load global active vouchers
  Future<void> loadActiveVouchers() async {
    try {
      isLoading.value = true;
      await _voucherRepository.getActiveVouchers();
      // ...
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memuat voucher aktif: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to detail screen
  void navigateToDetail(VoucherModel voucher) {
    Get.toNamed(Routes.VOUCHER_DETAIL, arguments: voucher);
  }

  /// Switch selected hotspot and reload vouchers
  Future<void> onHotspotChanged(HotspotModel? hotspot) async {
    if (hotspot == null) return;
    _selectionService.updateHotspot(hotspot);
    selectedPaketId.value = null; // Clear selected package when hotspot changes
    await Future.wait([
      loadVouchers(),
      loadVoucherPackages(),
    ]);
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
