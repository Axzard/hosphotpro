import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/hotspot_model.dart';

class HotspotItemCard extends StatelessWidget {
  final HotspotModel hotspot;
  final Color cardColor;
  final Color accentColor;

  const HotspotItemCard({
    super.key,
    required this.hotspot,
    required this.cardColor,
    required this.accentColor,
  });

  static TextStyle _titleStyle(Color color) => GoogleFonts.plusJakartaSans(
    color: color,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static TextStyle _statusStyle(Color color) => GoogleFonts.plusJakartaSans(
    color: color,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  static TextStyle _interfaceStyle(Color color) => GoogleFonts.plusJakartaSans(
    color: color,
    fontSize: 13,
  );

  @override
  Widget build(BuildContext context) {
    final statusColor = hotspot.statusHotspot == 'aktif' ? Colors.green : Colors.red;
    final secondaryTextColor = Colors.white.withValues(alpha: 0.5);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  hotspot.namaServer,
                  style: _titleStyle(Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hotspot.statusHotspot.toUpperCase(),
                  style: _statusStyle(statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.lan_outlined, size: 14, color: secondaryTextColor),
              const SizedBox(width: 8),
              Text(
                'Interface: ${hotspot.interface}',
                style: _interfaceStyle(secondaryTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
