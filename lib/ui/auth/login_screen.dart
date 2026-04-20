import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'view_models/auth_view_model.dart';
import 'widgets/auth_widgets.dart';
import '../../config/routing/app_pages.dart';

class LoginScreen extends GetView<AuthViewModel> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Obx(() {
        if (controller.isCheckingLogin.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.cyan),
          );
        }
        
        return SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const AuthLogo(title: 'hotspotsio'),
                    const SizedBox(height: 60),
                    
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang Kembali',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Silakan masuk untuk melanjutkan',
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
                      controller: controller.usernameController,
                      label: 'Username',
                      hint: 'Masukkan username',
                      prefixIcon: Icons.person_outline,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    AuthTextField(
                      controller: controller.passwordController,
                      label: 'Kata Sandi',
                      hint: '........',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Get.toNamed(Routes.FORGOT_PASSWORD),
                        child: const Text(
                          'Lupa Kata Sandi?',
                          style: TextStyle(
                            color: Colors.cyan,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 36),
                    
                    Obx(() => AuthButton(
                      text: 'Masuk',
                      isLoading: controller.isLoading.value,
                      onPressed: () => controller.login(),
                    )),
                    
                    const SizedBox(height: 48),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Belum punya akun? ',
                          style: TextStyle(color: Colors.white38, fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(Routes.REGISTER),
                          child: const Text(
                            'Daftar',
                            style: TextStyle(
                              color: Colors.cyan,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Obx(() => Text(
                      'Versi ${controller.appVersion.value}',
                      style: const TextStyle(
                        color: Colors.white24,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    )),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
