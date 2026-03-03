import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'view_models/forgot_password_view_model.dart';
import 'widgets/auth_widgets.dart';

class ResetPasswordScreen extends GetView<ForgotPasswordViewModel> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AuthLogo(title: 'hotspotsio'),
                const SizedBox(height: 60),
                
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reset Kata Sandi',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Masukkan kode OTP yang dikirim ke email dan password baru Anda',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),

                 AuthTextField(
                  controller: controller.emailController,
                  label: 'Email',
                  hint: 'Masukkan alamat email',
                  prefixIcon: Icons.email_outlined,
                  enabled: false,
                ),
                
                const SizedBox(height: 20),
                
                AuthTextField(
                  controller: controller.otpController,
                  label: 'Kode OTP',
                  hint: 'Masukkan 6 digit kode OTP',
                  prefixIcon: Icons.security_outlined,
                ),
                
                const SizedBox(height: 20),
                
                AuthTextField(
                  controller: controller.newPasswordController,
                  label: 'Kata Sandi Baru',
                  hint: '........',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                ),
                
                const SizedBox(height: 48),
                
                Obx(() => AuthButton(
                  text: 'Simpan Password',
                  isLoading: controller.isLoading.value,
                  onPressed: () => controller.resetPassword(),
                )),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
