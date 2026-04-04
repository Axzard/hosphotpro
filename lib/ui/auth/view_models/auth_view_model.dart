import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/models/auth_model.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../config/routing/app_pages.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/services/websocket_service.dart';
import '../../../data/services/token_service.dart';
import '../../voucher/view_models/voucher_view_model.dart';

class AuthViewModel extends GetxController {
  final AuthRepository _authRepository;
  final _tokenService = Get.find<TokenService>();

  AuthViewModel(this._authRepository);

  final Rx<AuthModel?> user = Rx<AuthModel?>(null);
  final isLoading = false.obs;
  final isCheckingLogin = true.obs;
  final errorMessage = ''.obs;
  final RxString appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initAppVersion();
    checkLoginStatus();
  }

  Future<void> _initAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion.value = info.version;
    } catch (_) {
      appVersion.value = 'Unknown';
    }
  }

  Future<void> checkLoginStatus() async {
    isCheckingLogin.value = true;
    try {
      final token = _tokenService.getToken();
      if (token == null || _tokenService.isTokenExpired()) {
        if (token != null) {
          await _authRepository.logout();
        }
        isCheckingLogin.value = false;
        return;
      }

      final profile = await _authRepository.getProfile();
      if (profile != null) {
        user.value = profile;
        Get.find<WebSocketService>().connect();

        Future.delayed(Duration.zero, () {
          Get.offAllNamed(Routes.DASHBOARD);
        });
      } else {
        await _authRepository.logout();
      }
    } catch (e) {
      print('Auto-login error: $e');
    } finally {
      isCheckingLogin.value = false;
    }
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  Future<void> login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Semua form harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

        Get.find<WebSocketService>().connect();
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        errorMessage.value = _translateErrorMessage(response.message);
        SnackbarUtils.showError('Gagal Login', 'Email atau password salah');
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan koneksi. Silakan coba lagi.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        usernameController.text.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Semua form harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authRepository.register(
        usernameController.text,
        emailController.text,
        passwordController.text,
      );

      if (response.success) {
        SnackbarUtils.showSuccess(
          'Berhasil',
          'Registrasi berhasil, silakan login',
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
      SnackbarUtils.showError('Gagal', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    user.value = null;
    Get.delete<VoucherViewModel>(force: true);
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
