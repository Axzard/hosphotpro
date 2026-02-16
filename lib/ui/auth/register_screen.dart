import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'view_models/auth_view_model.dart';
import 'widgets/auth_widgets.dart';

class RegisterScreen extends GetView<AuthViewModel> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const AuthLogo(title: 'Hosphotpro'),
                const SizedBox(height: 50),
                
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buat Akun',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Isi detail Anda untuk memulai.',
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
                  controller: controller.emailController,
                  label: 'Alamat Email',
                  hint: 'nama@gmail.com',
                  prefixIcon: Icons.email_outlined,
                ),
                
                const SizedBox(height: 20),
                
                AuthTextField(
                  controller: controller.passwordController,
                  label: 'Kata Sandi',
                  hint: '........',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                ),
                
                const SizedBox(height: 40),
                
                Obx(() => AuthButton(
                  text: 'Daftar Sekarang',
                  isLoading: controller.isLoading.value,
                  onPressed: () => controller.register(),
                )),
                
                const SizedBox(height: 48),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun? ',
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          color: Colors.cyan,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
