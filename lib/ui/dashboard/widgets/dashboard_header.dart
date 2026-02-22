import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../view_models/dashboard_view_model.dart';

class DashboardHeader extends StatelessWidget {
  final DashboardViewModel controller;

  const DashboardHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                'Halo, ${controller.username.value}',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
              const SizedBox(height: 4),
              Text(
                'Selamat datang kembali',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Get.dialog(
              AlertDialog(
                backgroundColor: const Color(0xFF1E293B),
                title: Text(
                  'Keluar',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  'Apakah Anda yakin ingin keluar dari aplikasi?',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white54),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      controller.logout();
                    },
                    child: Text(
                      'Ya, Keluar',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFF4757), Color(0xFFFF6B81)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0F172A),
              ),
              child: const Icon(Icons.logout, color: Colors.white, size: 24),
            ),
          ),
        ),
      ],
    );
  }
}
