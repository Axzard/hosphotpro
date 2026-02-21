import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../../../../domain/models/router_model.dart';
import '../../../../domain/models/router_repository.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/services/websocket_service.dart';

class RouterViewModel extends GetxController {
  final RouterRepository _routerRepository;
  final _webSocketService = Get.find<WebSocketService>();

  RouterViewModel(this._routerRepository);

  final RxList<RouterModel> routers = <RouterModel>[].obs;
  final RxBool isLoading = false.obs;

  // Form Controllers
  final namaController = TextEditingController();
  final ipController = TextEditingController();
  final portController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final keteranganController = TextEditingController();

  final RxBool isEditing = false.obs;
  final RxString editingId = ''.obs;

  StreamSubscription? _refreshSub;

  @override
  void onInit() {
    super.onInit();
    loadRouters();
    _initRealtimeListeners();
  }

  void _initRealtimeListeners() {
    print('🚀 [RouterVM] Realtime listeners initialized');
    _refreshSub = _webSocketService.eventStream.listen((eventData) {
      final event = eventData['event'] ?? '';
      print('📟 [RouterVM] Refreshing due to Event: $event');
      loadRouters();
    });
  }

  Future<void> loadRouters() async {
    try {
      isLoading.value = true;
      routers.value = await _routerRepository.getRouters();
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memuat router: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveRouter() async {
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
        statusRouter: 'aktif',
      );

      if (isEditing.value) {
        await _routerRepository.updateRouter(routerData);
        SnackbarUtils.showSuccess('Berhasil', 'Router berhasil diperbarui');
      } else {
        await _routerRepository.createRouter(routerData);
        SnackbarUtils.showSuccess('Berhasil', 'Router berhasil ditambahkan');
      }

      clearForm();
      loadRouters();
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal menyimpan router: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRouter(String id) async {
    try {
      isLoading.value = true;
      await _routerRepository.deleteRouter(id);
      SnackbarUtils.showSuccess('Berhasil', 'Router berhasil dihapus');
      loadRouters();
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal menghapus router: $e');
    } finally {
      isLoading.value = false;
    }
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
  }

  void prepareCreate() {
    clearForm();
  }

  void clearForm() {
    isEditing.value = false;
    editingId.value = '';
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

  Future<void> pingRouter(String id) async {
    try {
      isLoading.value = true;
      final int routerId = int.tryParse(id) ?? 0;
      final result = await _routerRepository.pingRouter(routerId);
      
      final isOnline = result['status'] == 'ONLINE';
      final detail = result['detail'] ?? {};
      final output = detail['output'] ?? 'No output';
      final time = detail['time']?.toString() ?? '-';

      Get.dialog(
        AlertDialog(
          backgroundColor: const Color(0xFF131E29),
          title: Row(
            children: [
              Icon(
                isOnline ? Icons.check_circle : Icons.error,
                color: isOnline ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 12),
              const Text('Router Ping Status', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusRow('Status', result['status'] ?? 'UNKNOWN', isOnline ? Colors.green : Colors.red),
                _buildStatusRow('Response Time', '$time ms', Colors.white70),
                const SizedBox(height: 16),
                const Text('Console Output:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    output,
                    style: GoogleFonts.firaCode(color: Colors.greenAccent, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Tutup', style: TextStyle(color: Color(0xFF00C2FF))),
            ),
          ],
        ),
      );
    } catch (e) {
      SnackbarUtils.showError('Ping Gagal', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Widget _buildStatusRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 13)),
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
