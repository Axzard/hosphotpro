import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/models/auth_model.dart';
import '../../../domain/models/auth_repository.dart';
import '../../../config/routing/app_pages.dart';

class AuthViewModel extends GetxController {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository);

  final Rx<AuthModel?> user = Rx<AuthModel?>(null);
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Text Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  // Login
  Future<void> login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('Perhatian', 'Semua form harus diisi',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _authRepository.login(
        usernameController.text,
        passwordController.text,
      );

      if (response.success && response.data != null) {
        user.value = response.data;
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        errorMessage.value = _translateErrorMessage(response.message);
        Get.snackbar(
          'Gagal Masuk', 
          errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Terjadi kesalahan koneksi. Silakan coba lagi.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Register
  Future<void> register() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        usernameController.text.isEmpty) {
      Get.snackbar('Perhatian', 'Semua form harus diisi',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authRepository.register(
          usernameController.text, emailController.text, passwordController.text);

      if (response.success) {
        Get.snackbar(
          'Berhasil',
          'Akun berhasil dibuat. Silakan login.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offNamed(Routes.LOGIN);
      } else {
        Get.snackbar(
          'Gagal Daftar',
          _translateErrorMessage(response.message),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan koneksi. Silakan coba lagi.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authRepository.logout();
    user.value = null;
    Get.offAllNamed(Routes.LOGIN);
  }

  String _translateErrorMessage(String message) {
    final lowerMessage = message.toLowerCase();
    if (lowerMessage.contains('invalid credentials') || 
        lowerMessage.contains('wrong password')) {
      return 'Username atau kata sandi salah.';
    } else if (lowerMessage.contains('user not found')) {
      return 'Akun tidak ditemukan.';
    } else if (lowerMessage.contains('already exists') || 
               lowerMessage.contains('email taken')) {
      return 'Username atau email sudah terdaftar.';
    } else if (lowerMessage.contains('connection timeout')) {
      return 'Koneksi terputus. Periksa internet Anda.';
    }
    return 'Terjadi kesalahan: $message';
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.onClose();
  }
}
