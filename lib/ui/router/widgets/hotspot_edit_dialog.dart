import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/hotspot_model.dart';
import '../view_models/hotspot_view_model.dart';

class HotspotEditDialog extends StatelessWidget {
  final HotspotModel hotspot;
  final HotspotViewModel controller;

  const HotspotEditDialog({
    super.key,
    required this.hotspot,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: Text(
        'Edit Hotspot Server',
        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextField(controller.namaServerController, 'Nama Server'),
          const SizedBox(height: 16),
          _buildTextField(controller.interfaceController, 'Interface'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text('Batal', style: GoogleFonts.plusJakartaSans(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: () => controller.updateHotspot(hotspot.idHotspot),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C2FF),
            foregroundColor: Colors.white,
          ),
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: GoogleFonts.plusJakartaSans(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
    );
  }
}
