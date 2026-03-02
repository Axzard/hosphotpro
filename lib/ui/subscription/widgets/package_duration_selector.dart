import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../view_models/subscription_view_model.dart';

class PackageDurationSelector extends StatelessWidget {
  final Color cardColor;
  final Color accentColor;
  final SubscriptionViewModel controller;

  const PackageDurationSelector({
    super.key,
    required this.cardColor,
    required this.accentColor,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final durationOptions = List.generate(12, (index) {
      final months = index + 1;
      return {'months': months, 'label': '$months Bulan'};
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PILIH DURASI',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.5),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: controller.selectedDuration.value,
                dropdownColor: cardColor,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: accentColor,
                  size: 28,
                ),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                items: durationOptions.map((opt) {
                  return DropdownMenuItem<int>(
                    value: opt['months'] as int,
                    child: Text(opt['label'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedDuration.value = value;
                  }
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pilih durasi lebih lama untuk kenyamanan akses tanpa gangguan.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: accentColor.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
