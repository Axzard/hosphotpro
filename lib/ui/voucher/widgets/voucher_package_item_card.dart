import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/voucher_package_model.dart';
import '../../../core/utils/currency_formatter.dart';

class VoucherPackageItemCard extends StatelessWidget {
  final VoucherPackageModel package;
  final Color cardColor;
  final Color accentColor;
  final Function(VoucherPackageModel) onEdit;
  final Function(VoucherPackageModel) onDelete;
  final bool isDeleting;

  const VoucherPackageItemCard({
    super.key,
    required this.package,
    required this.cardColor,
    required this.accentColor,
    required this.onEdit,
    required this.onDelete,
    this.isDeleting = false,
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
              Expanded(
                child: Text(
                  package.namaPaket,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'Rp${CurrencyFormatter.format(package.harga)}',
                style: GoogleFonts.plusJakartaSans(
                  color: accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Flexible(child: _buildInfoChip(Icons.timer_outlined, package.durasi)),
              const SizedBox(width: 8),
              if (package.rateLimit != null && package.rateLimit!.isNotEmpty) ...[
                Flexible(child: _buildInfoChip(Icons.speed, package.rateLimit!)),
                const SizedBox(width: 8),
              ],
              Flexible(child: _buildInfoChip(Icons.person_outline, package.namaProfileMikrotik)),
            ],
          ),
          const Divider(height: 32, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: isDeleting ? null : () => onEdit(package),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: isDeleting ? null : () => onDelete(package),
                icon: isDeleting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueGrey),
                      )
                    : const Icon(Icons.delete_outline, size: 18),
                label: Text(isDeleting ? '...' : 'Hapus'),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white54),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white70,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
