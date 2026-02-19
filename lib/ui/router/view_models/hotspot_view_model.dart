import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../../../../domain/models/hotspot_model.dart';
import '../../../../domain/models/router_model.dart';
import '../../../../domain/models/router_repository.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/services/websocket_service.dart';
import '../../../../core/services/selection_service.dart';

class HotspotViewModel extends GetxController {
  final RouterRepository _routerRepository = Get.find<RouterRepository>();
  final _webSocketService = Get.find<WebSocketService>();
  final _selectionService = Get.find<SelectionService>();

  final RxList<HotspotModel> hotspots = <HotspotModel>[].obs;
  final RxList<RouterModel> routers = <RouterModel>[].obs;
  
  Rxn<RouterModel> get selectedRouter => _selectionService.selectedRouter;
  final RxBool isLoading = false.obs;

  // Form Controllers for Editing
  final namaServerController = TextEditingController();
  final interfaceController = TextEditingController();

  StreamSubscription? _refreshSub;

  @override
  void onInit() {
    super.onInit();
    loadRouters();
    _initRealtimeListeners();

    // Listen to global changes
    ever(selectedRouter, (router) {
      if (router != null) {
        loadHotspots(); // Reverted to just loading, no auto-sync
      }
    });
  }

  void _initRealtimeListeners() {
    print('🚀 [HotspotVM] Realtime listeners initialized');
    _refreshSub = _webSocketService.eventStream.listen((eventData) {
      final event = (eventData['event'] ?? '').toString().toLowerCase();
      
      // Filter: Only refresh on relevant events
      const relevantEvents = ['hotspot_updated', 'router_updated', 'hotspot_created', 'hotspot_deleted'];
      if (!relevantEvents.contains(event)) return;

      print('📡 [HotspotVM] Refreshing due to Event: $event');
      loadHotspots();
    });
  }

  Future<void> loadRouters() async {
    try {
      isLoading.value = true;
      final result = await _routerRepository.getRouters();
      routers.assignAll(result);
      
      if (result.isNotEmpty && selectedRouter.value == null) {
        _selectionService.updateRouter(result.first);
        loadHotspots(); // Reverted to just loading
      } else if (selectedRouter.value != null) {
        loadHotspots(); // Reverted to just loading
      }
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memuat router: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadHotspots() async {
    if (selectedRouter.value == null) return;
    
    try {
      isLoading.value = true;
      final idRouter = int.tryParse(selectedRouter.value!.id) ?? 0;
      final result = await _routerRepository.getHotspots(idRouter);
      hotspots.assignAll(result);
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memuat hotspot: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onRouterChanged(RouterModel? router) {
    if (router == null) return;
    _selectionService.updateRouter(router);
    // syncHotspots will be triggered by the 'ever' listener on selectedRouter
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
      Get.back(); // Close dialog/sheet
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memperbarui hotspot: $e');
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
      SnackbarUtils.showError('Error', 'Gagal menghapus hotspot: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncHotspots() async {
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
      
      print('🔄 [HotspotVM] Syncing hotspots for Router ID: $idRouter');
      await _routerRepository.syncHotspots(idRouter);
      SnackbarUtils.showSuccess('Berhasil', 'Sinkronisasi hotspot selesai');
      await loadHotspots();
    } catch (e) {
      print('❌ [HotspotVM] Sync Error: $e');
      SnackbarUtils.showError('Error', 'Gagal sinkronisasi: $e');
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
