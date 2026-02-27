import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../../../../domain/models/hotspot_model.dart';
import '../../../../domain/models/router_model.dart';
import '../../../domain/repositories/router_repository.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../../core/services/session_service.dart';
import '../../dashboard/view_models/dashboard_view_model.dart';


class HotspotViewModel extends GetxController {
  final RouterRepository _routerRepository = Get.find<RouterRepository>();
  final _webSocketService = Get.find<WebSocketService>();
  final _sessionService = Get.find<SessionService>();

  final RxList<HotspotModel> hotspots = <HotspotModel>[].obs;
  final RxList<RouterModel> routers = <RouterModel>[].obs;

  final Rxn<RouterModel> selectedRouter = Rxn<RouterModel>();
  final RxBool isLoading = false.obs;

  final namaServerController = TextEditingController();
  final interfaceController = TextEditingController();

  StreamSubscription? _refreshSub;

  @override
  void onInit() {
    super.onInit();
    loadRouters();
    _initRealtimeListeners();

    ever(selectedRouter, (router) {
      if (router != null) {
        loadHotspots();
      }
    });
  }

  void _initRealtimeListeners() {
    print(' [HotspotVM] Realtime listeners initialized');
    _refreshSub = _webSocketService.eventStream.listen((eventData) {
      final event = (eventData['event'] ?? '').toString().toLowerCase();

      const relevantEvents = [
        'hotspot_updated',
        'router_updated',
        'hotspot_created',
        'hotspot_deleted',
      ];
      if (!relevantEvents.contains(event)) return;

      print('[HotspotVM] Refreshing due to Event: $event');
      loadHotspots();
    });
  }

  Future<void> loadRouters() async {
    try {
      isLoading.value = true;
      final result = await _routerRepository.getRouters();
      
      final routerList = [RouterModel.semua];
      routerList.addAll(result);
      routers.assignAll(routerList);

      if (selectedRouter.value == null) {
        final savedRouterId = _sessionService.selectedRouterId.value;
        if (savedRouterId != null && savedRouterId != 'all') {
          selectedRouter.value = routerList.firstWhereOrNull((r) => r.id == savedRouterId) ?? RouterModel.semua;
        } else {
          selectedRouter.value = RouterModel.semua;
        }
      }
      loadHotspots();
    } catch (e) {
      print('[HotspotVM] Load Routers Error: $e');
      SnackbarUtils.showError(
        'Error',
        'Gagal memuat daftar router. Pastikan koneksi internet stabil atau coba lagi nanti.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadHotspots() async {
    final dashboardVM = Get.find<DashboardViewModel>();
    if (!dashboardVM.isActiveSubscription.value) {
      hotspots.clear();
      return;
    }

    if (selectedRouter.value == null) return;

    try {
      if (hotspots.isEmpty) isLoading.value = true;

      if (selectedRouter.value!.id == 'all') {
        final result = await _routerRepository.getAllHotspots();
        hotspots.assignAll(result);
      } else {
        final idRouter = int.tryParse(selectedRouter.value!.id) ?? 0;
        final result = await _routerRepository.getHotspots(idRouter);
        hotspots.assignAll(result);
      }
    } catch (e) {
      print('[HotspotVM] Load Hotspots Error: $e');
      SnackbarUtils.showError(
        'Error',
        'Gagal memuat daftar hotspot. Silakan cek status router Mikrotik Anda.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onRouterChanged(RouterModel? router) {
    if (router == null) return;
    selectedRouter.value = router;
    _sessionService.setRouterId(router.id);
    loadHotspots();
  }

  Future<void> updateHotspot(int idHotspot) async {
    if (namaServerController.text.isEmpty || interfaceController.text.isEmpty) {
      SnackbarUtils.showError('Error', 'Nama Server dan Interface wajib diisi');
      return;
    }

    try {
      isLoading.value = true;
      final data = {
        'nama_server': namaServerController.text,
        'interface': interfaceController.text,
      };
      await _routerRepository.updateHotspot(idHotspot, data);
      SnackbarUtils.showSuccess('Berhasil', 'Hotspot berhasil diperbarui');
      loadHotspots();
      Get.back();
    } catch (e) {
      print('[HotspotVM] Update Hotspot Error: $e');
      SnackbarUtils.showError(
        'Error',
        'Gagal memperbarui data hotspot. Terjadi gangguan pada server atau router.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteHotspot(int idHotspot) async {
    try {
      isLoading.value = true;
      await _routerRepository.deleteHotspot(idHotspot);
      SnackbarUtils.showSuccess('Berhasil', 'Hotspot berhasil dihapus');
      loadHotspots();
    } catch (e) {
      print('[HotspotVM] Delete Hotspot Error: $e');
      SnackbarUtils.showError(
        'Error',
        'Gagal menghapus hotspot. Silakan coba lagi beberapa saat lagi.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncHotspots() async {
    final dashboardVM = Get.find<DashboardViewModel>();
    if (!dashboardVM.isActiveSubscription.value) {
      SnackbarUtils.showInfo(
        'Premium Only',
        'Fitur ini hanya tersedia untuk pengguna Premium.',
      );
      return;
    }

    final router = selectedRouter.value;
    if (router == null) {
      SnackbarUtils.showError('Error', 'Pilih router terlebih dahulu');
      return;
    }

    try {
      isLoading.value = true;
      final idRouter = int.tryParse(router.id) ?? 0;
      if (idRouter == 0) {
        SnackbarUtils.showError('Error', 'ID Router tidak valid: ${router.id}');
        return;
      }

      print('[HotspotVM] Syncing hotspots for Router ID: $idRouter');

      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: Color(0xFF00C2FF)),
        ),
        barrierDismissible: false,
      );

      final results = await _routerRepository.syncHotspots(idRouter);

      if (Get.isDialogOpen ?? false) Get.back();

      if (results.isEmpty) {
        SnackbarUtils.showSuccess('Berhasil', 'Sinkronisasi hotspot selesai');
      } else {
        final StringBuffer message = StringBuffer();
        for (var i = 0; i < results.length; i++) {
          final res = results[i] is Map ? results[i] : {};
          final nama = res['nama_server'] ?? 'Hotspot';
          final status = res['status'] ?? 'sudah ada';
          message.write('$nama: $status');
          if (i < results.length - 1) message.write('\n');
        }
        SnackbarUtils.showSuccess('Sinkronisasi Selesai', message.toString());
      }

      await loadHotspots();
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();

      print('[HotspotVM] Sync Error: $e');
      
      String friendlyMessage = 'Gagal sinkronisasi. Pastikan router online dan coba lagi.';
      if (e.toString().contains('500')) {
        friendlyMessage = 'Oops! Terjadi gangguan pada server (500). Silakan hubungi admin.';
      } else if (e.toString().contains('timeout')) {
        friendlyMessage = 'Koneksi ke router melampaui batas waktu. Pastikan router stabil.';
      }

      SnackbarUtils.showError(
        'Sinkronisasi Gagal',
        friendlyMessage,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void prepareEdit(HotspotModel hotspot) {
    namaServerController.text = hotspot.namaServer;
    interfaceController.text = hotspot.interface;
  }

  @override
  void onClose() {
    _refreshSub?.cancel();
    namaServerController.dispose();
    interfaceController.dispose();
    super.onClose();
  }
}
