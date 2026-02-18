import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SnackbarUtils {
  static void showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
      titleText: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF4ADE80),
          fontSize: 16,
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14),
      ),
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      borderWidth: 1,
      borderColor: const Color(0xFF4ADE80).withValues(alpha: 0.3),
      icon: const Icon(Icons.check_circle_outline, color: Color(0xFF4ADE80)),
      duration: const Duration(seconds: 3),
    );
  }

  static void showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
      titleText: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
          color: Colors.redAccent,
          fontSize: 16,
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14),
      ),
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      borderWidth: 1,
      borderColor: Colors.redAccent.withValues(alpha: 0.3),
      icon: const Icon(Icons.error_outline, color: Colors.redAccent),
      duration: const Duration(seconds: 4),
    );
  }

  static void showInfo(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
      titleText: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF00C2FF),
          fontSize: 16,
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 14),
      ),
      snackPosition: SnackPosition.TOP,
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      borderWidth: 1,
      borderColor: const Color(0xFF00C2FF).withValues(alpha: 0.3),
      icon: const Icon(Icons.info_outline, color: Color(0xFF00C2FF)),
    );
  }
}
