import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../../../../domain/models/router_model.dart';
import '../../../domain/repositories/router_repository.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/error_utils.dart';
import '../../../../core/services/websocket_service.dart';
import '../../dashboard/view_models/dashboard_view_model.dart';

class RouterViewModel extends GetxController {
  final RouterRepository _routerRepository;
  final _webSocketService = Get.find<WebSocketService>();

  RouterViewModel(this._routerRepository);

  final RxList<RouterModel> routers = <RouterModel>[].obs;
  final RxBool isLoading = false.obs;

  final namaController = TextEditingController();
  final ipController = TextEditingController();
  final portController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final keteranganController = TextEditingController();

  final RxBool isEditing = false.obs;
  final RxString editingId = ''.obs;
  final RxString editingStatus = 'aktif'.obs;

  StreamSubscription? _refreshSub;

  @override
  void onInit() {
    super.onInit();
    final dashboardVM = Get.find<DashboardViewModel>();

    ever(dashboardVM.isActiveSubscription, (bool isActive) {
      if (isActive && routers.isEmpty) {
        loadRouters();
      }
    });

    loadRouters();
    _initRealtimeListeners();
  }

  void _initRealtimeListeners() {
    print('[RouterVM] Realtime listeners initialized');
    _refreshSub = _webSocketService.eventStream.listen((eventData) {
      final event = eventData['event']?.toString() ?? '';
      final data = eventData['data'];
      print('[RouterVM] Refreshing due to Event: $event');

      if (event == 'router_added' && data != null) {
        try {
          final newRouter = RouterModel.fromJson(data);
          routers.add(newRouter);
          _syncWithCache();
        } catch (_) {}
      } else if (event == 'router_updated' && data != null) {
        try {
          final updated = RouterModel.fromJson(data);
          final idx = routers.indexWhere((r) => r.id == updated.id);
          if (idx != -1) {
            routers[idx] = updated;
            _syncWithCache();
          }
        } catch (_) {}
      } else if (event == 'router_deleted' && data != null) {
        final id = data['id_router']?.toString();
        if (id != null) {
          routers.removeWhere((r) => r.id == id);
          _syncWithCache();
        }
      } else if (event.startsWith('router_')) {
        loadRouters();
      }
    });
  }

  Future<void> loadRouters() async {
    try {
      if (routers.isEmpty) isLoading.value = true;
      final dashboardVM = Get.find<DashboardViewModel>();
      if (!dashboardVM.isActiveSubscription.value) {
        routers.clear();
        return;
      }
      routers.value = await _routerRepository.getRouters();
    } catch (e) {
      SnackbarUtils.showError('Gagal', 'Gagal memuat router: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveRouter() async {
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
      final routerData = RouterModel(
        id: isEditing.value ? editingId.value : '0',
        namaRouter: namaController.text,
        alamatIp: ipController.text,
        portApi: int.tryParse(portController.text) ?? 8728,
        usernameApi: usernameController.text,
        passwordApi: passwordController.text,
        keterangan: keteranganController.text,
        statusRouter: isEditing.value ? editingStatus.value : 'aktif',
      );

      final future = isEditing.value
          ? _routerRepository.updateRouter(routerData)
          : _routerRepository.createRouter(routerData);

      Get.back();
      SnackbarUtils.showSuccess('Proses...', 'Menyimpan router');

      await future;

      if (!isEditing.value) {
        routers.add(routerData);
      } else {
        final idx = routers.indexWhere((r) => r.id == routerData.id);
        if (idx != -1) routers[idx] = routerData;
      }
      _syncWithCache();

      clearForm();
    } catch (e) {
      SnackbarUtils.showError('Gagal', 'Gagal menyimpan router: $e');
      loadRouters();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRouter(String id) async {
    try {
      await _routerRepository.deleteRouter(id);

      routers.removeWhere((r) => r.id == id);
      _syncWithCache();

      SnackbarUtils.showSuccess('Berhasil', 'Router berhasil dihapus');
    } catch (e) {
      SnackbarUtils.showError(
        'Gagal Hapus',
        ErrorUtils.sanitizeServerMessage(
          e.toString().replaceAll('Gagal: ', ''),
        ),
      );
      loadRouters();
    }
  }

  void _syncWithCache() {
    _routerRepository
        .updateRouterCache(routers.toList())
        .catchError((e) => print('[RouterVM] Cache sync error: $e'));
  }

  void prepareEdit(RouterModel router) {
    isEditing.value = true;
    editingId.value = router.id;
    namaController.text = router.namaRouter;
    ipController.text = router.alamatIp;
    portController.text = router.portApi.toString();
    usernameController.text = router.usernameApi;
    passwordController.text = router.passwordApi;
    keteranganController.text = router.keterangan;
    editingStatus.value = router.statusRouter;
  }

  void prepareCreate() {
    clearForm();
  }

  void clearForm() {
    isEditing.value = false;
    editingId.value = '';
    editingStatus.value = 'aktif';
    namaController.clear();
    ipController.clear();
    portController.clear();
    usernameController.clear();
    passwordController.clear();
    keteranganController.clear();
  }

  bool _validateForm() {
    if (namaController.text.isEmpty ||
        ipController.text.isEmpty ||
        portController.text.isEmpty ||
        usernameController.text.isEmpty ||
        passwordController.text.isEmpty) {
      SnackbarUtils.showError('Peringatan', 'Harap isi semua kolom wajib');
      return false;
    }
    return true;
  }

  final RxBool isPingLoading = false.obs;
  final RxString pingStatus = 'UNKNOWN'.obs;
  final RxString pingResponseTime = '-'.obs;
  final RxList<String> pingLines = <String>[].obs;

  Future<void> pingRouter(String id) async {
    try {
      isPingLoading.value = true;
      pingStatus.value = 'PENDING';
      pingResponseTime.value = '-';
      pingLines.clear();

      Get.dialog(
        Obx(
          () => AlertDialog(
            backgroundColor: const Color(0xFF131E29),
            title: Row(
              children: [
                if (isPingLoading.value)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF00C2FF),
                    ),
                  )
                else
                  Icon(
                    pingStatus.value == 'ONLINE'
                        ? Icons.check_circle
                        : Icons.error,
                    color: pingStatus.value == 'ONLINE'
                        ? Colors.green
                        : Colors.red,
                  ),
                const SizedBox(width: 12),
                const Text(
                  'Router Ping Status',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusRow(
                      'Status',
                      pingStatus.value,
                      pingStatus.value == 'ONLINE' ? Colors.green : Colors.red,
                    ),
                    _buildStatusRow(
                      'Response Time',
                      '${pingResponseTime.value} ms',
                      Colors.white70,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Console Output:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(minHeight: 150),
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: isPingLoading.value && pingLines.isEmpty
                          ? const Center(
                              child: Text(
                                "Waiting for response...",
                                style: TextStyle(
                                  color: Colors.white24,
                                  fontSize: 10,
                                ),
                              ),
                            )
                          : Text(
                              pingLines.isEmpty
                                  ? "Ping completed with no log data."
                                  : pingLines.join('\n'),
                              style: GoogleFonts.firaCode(
                                color: pingLines.isEmpty
                                    ? Colors.white38
                                    : Colors.greenAccent,
                                fontSize: 10,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Tutup',
                  style: TextStyle(color: Color(0xFF00C2FF)),
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      final int routerId = int.tryParse(id) ?? 0;
      final result = await _routerRepository.pingRouter(routerId);

      final detail = result['detail'] as Map? ?? {};
      final String rawOutput = (detail['raw'] ?? '').toString();
      final String time = (detail['time'] ?? result['time'] ?? '-').toString();
      final String status = (result['status'] ?? detail['status'] ?? 'UNKNOWN')
          .toString();

      isPingLoading.value = false;
      pingStatus.value = status;
      pingResponseTime.value = time;

      final List<String> lines = rawOutput.split('\n');
      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        pingLines.add(line);
        await Future.delayed(const Duration(milliseconds: 150));
      }
    } catch (e) {
      isPingLoading.value = false;
      if (Get.isDialogOpen ?? false) Get.back();
      SnackbarUtils.showError('Ping Gagal', e.toString());
    }
  }

  Widget _buildStatusRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    _refreshSub?.cancel();
    namaController.dispose();
    ipController.dispose();
    portController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    keteranganController.dispose();
    super.onClose();
  }
}
