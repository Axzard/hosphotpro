import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'view_models/forgot_password_view_model.dart';
import 'widgets/auth_widgets.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordViewModel> {
  const ForgotPasswordScreen({super.key});

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
                const AuthLogo(title: 'hotspotpro'),
                const SizedBox(height: 60),
                
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lupa Kata Sandi?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Masukkan email Anda untuk menerima kode OTP',
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
                ),
                
                const SizedBox(height: 48),
                
                Obx(() => AuthButton(
                  text: 'Kirim Kode OTP',
                  isLoading: controller.isLoading.value,
                  onPressed: () => controller.sendOtp(),
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
