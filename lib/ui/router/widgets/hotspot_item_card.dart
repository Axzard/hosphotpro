import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/hotspot_model.dart';

class HotspotItemCard extends StatelessWidget {
  final HotspotModel hotspot;
  final Color cardColor;
  final Color accentColor;
  final Function(HotspotModel) onEdit;
  final Function(HotspotModel) onDelete;

  const HotspotItemCard({
    super.key,
    required this.hotspot,
    required this.cardColor,
    required this.accentColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
              Text(
                hotspot.namaServer,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (hotspot.statusHotspot == 'aktif' ? Colors.green : Colors.red).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  hotspot.statusHotspot.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    color: hotspot.statusHotspot == 'aktif' ? Colors.green : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.lan_outlined, size: 14, color: Colors.white.withValues(alpha: 0.5)),
              const SizedBox(width: 8),
              Text(
                'Interface: ${hotspot.interface}',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => onEdit(hotspot),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
                style: TextButton.styleFrom(foregroundColor: accentColor),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => onDelete(hotspot),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Hapus'),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
