import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../config/routing/app_pages.dart';

class ForgotPasswordViewModel extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  
  final isLoading = false.obs;

  Future<void> sendOtp() async {
    if (emailController.text.isEmpty) {
      SnackbarUtils.showError('Perhatian', 'Email harus diisi');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authRepository.sendOtp(emailController.text);
      if (response.success) {
        SnackbarUtils.showSuccess('Berhasil', response.message);
        Get.toNamed(Routes.RESET_PASSWORD);
      } else {
        SnackbarUtils.showError('Gagal', response.message);
      }
    } catch (e) {
      SnackbarUtils.showError('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    if (otpController.text.isEmpty || newPasswordController.text.isEmpty) {
      SnackbarUtils.showError('Perhatian', 'OTP dan Password Baru harus diisi');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authRepository.resetPassword(
        emailController.text,
        otpController.text,
        newPasswordController.text,
      );
      if (response.success) {
        SnackbarUtils.showSuccess('Berhasil', response.message);
        Get.offAllNamed(Routes.LOGIN);
      } else {
        SnackbarUtils.showError('Gagal', response.message);
      }
    } catch (e) {
      SnackbarUtils.showError('Error', 'Terjadi kesalahan: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }
}
