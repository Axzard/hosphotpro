import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../domain/models/router_model.dart';
import '../../../../domain/models/router_repository.dart';

class RouterViewModel extends GetxController {
  final RouterRepository _routerRepository;

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

  @override
  void onInit() {
    super.onInit();
    loadRouters();
  }

  Future<void> loadRouters() async {
    try {
      isLoading.value = true;
      routers.value = await _routerRepository.getRouters();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat router: $e');
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
        Get.snackbar('Berhasil', 'Router berhasil diperbarui');
      } else {
        await _routerRepository.createRouter(routerData);
        Get.snackbar('Berhasil', 'Router berhasil ditambahkan');
      }

      clearForm();
      loadRouters();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan router: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteRouter(String id) async {
    try {
      isLoading.value = true;
      await _routerRepository.deleteRouter(id);
      Get.snackbar('Berhasil', 'Router berhasil dihapus');
      loadRouters();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus router: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void editRouter(RouterModel router) {
    isEditing.value = true;
    editingId.value = router.id;
    namaController.text = router.namaRouter;
    ipController.text = router.alamatIp;
    portController.text = router.portApi.toString();
    usernameController.text = router.usernameApi;
    passwordController.text = router.passwordApi;
    keteranganController.text = router.keterangan;
    
    // Scroll to top or switch tab if needed, but the form is usually visible
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
      Get.snackbar('Peringatan', 'Harap isi semua kolom wajib');
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    namaController.dispose();
    ipController.dispose();
    portController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    keteranganController.dispose();
    super.onClose();
  }
}
