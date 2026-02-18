import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/snackbar_utils.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/models/voucher_model.dart';
import 'view_models/voucher_view_model.dart';

class VoucherDetailScreen extends GetView<VoucherViewModel> {
  const VoucherDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final voucher = Get.arguments as VoucherModel;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    const bgColor = Color(0xFF0A1118);
    const accentColor = Color(0xFF00C2FF);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(accentColor),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildCodeCard(voucher, accentColor),
                    const SizedBox(height: 24),
                    _buildInfoSection(
                      voucher,
                      currencyFormat,
                      dateFormat,
                      accentColor,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildActionButtons(voucher, accentColor),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: accentColor,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detail Voucher',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'INFORMASI LENGKAP',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: accentColor.withValues(alpha: 0.6),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Code card (gradient) ────────────────────────────────────────────────
  Widget _buildCodeCard(VoucherModel voucher, Color accentColor) {
    Color statusColor;
    String statusLabel;

    switch (voucher.statusVoucher) {
      case VoucherStatus.stok:
        statusColor = const Color(0xFF4ADE80);
        statusLabel = 'STOK';
        break;
      case VoucherStatus.aktif:
        statusColor = accentColor;
        statusLabel = 'AKTIF';
        break;
      case VoucherStatus.terjual:
        statusColor = Colors.orange;
        statusLabel = 'TERJUAL';
        break;
      case VoucherStatus.expired:
        statusColor = Colors.redAccent;
        statusLabel = 'EXPIRED';
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor, const Color(0xFF0077B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.wifi_tethering,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          // Kode
          Text(
            'KODE VOUCHER',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: voucher.kodeVoucher));
              SnackbarUtils.showSuccess(
                'Disalin',
                'Kode voucher disalin ke clipboard',
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  voucher.kodeVoucher,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.copy, color: Colors.white70, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Password
          Text(
            'PASSWORD',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: voucher.passwordVoucher));
              SnackbarUtils.showSuccess(
                'Disalin',
                'Password disalin ke clipboard',
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  voucher.passwordVoucher,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withValues(alpha: 0.9),
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.copy, color: Colors.white70, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: statusColor, size: 10),
                const SizedBox(width: 8),
                Text(
                  statusLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info section ────────────────────────────────────────────────────────
  Widget _buildInfoSection(
    VoucherModel voucher,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
    Color accentColor,
  ) {
    const cardColor = Color(0xFF131E29);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // Row 1
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'PAKET',
                  voucher.namaPaket,
                  Icons.sell_outlined,
                  accentColor,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'HARGA',
                  currencyFormat.format(voucher.harga),
                  Icons.payments_outlined,
                  accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          // Row 2
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'PROFIL MIKROTIK',
                  voucher.namaProfileMikrotik,
                  Icons.router_outlined,
                  accentColor,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'SERVER',
                  voucher.namaServer,
                  Icons.dns_outlined,
                  accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Divider(color: Colors.white.withValues(alpha: 0.06)),
          const SizedBox(height: 20),
          // Date info
          _buildDateRow(
            Icons.calendar_today_rounded,
            'Dibuat Pada',
            dateFormat.format(voucher.dibuatPada),
            accentColor,
          ),
          if (voucher.tanggalAktif != null) ...[
            const SizedBox(height: 16),
            _buildDateRow(
              Icons.play_circle_outline,
              'Tanggal Aktif',
              dateFormat.format(voucher.tanggalAktif!),
              const Color(0xFF4ADE80),
            ),
          ],
          if (voucher.tanggalExpired != null) ...[
            const SizedBox(height: 16),
            _buildDateRow(
              Icons.timer_off_outlined,
              'Tanggal Expired',
              dateFormat.format(voucher.tanggalExpired!),
              Colors.redAccent,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ── Action buttons ──────────────────────────────────────────────────────
  Widget _buildActionButtons(VoucherModel voucher, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => controller.printVoucher(voucher),
              icon: const Icon(Icons.print_outlined),
              label: Text(
                'Cetak Sekarang',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                shadowColor: accentColor.withValues(alpha: 0.4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () {
                controller.deleteVoucher(voucher.idVoucher);
                Get.back();
              },
              icon: const Icon(Icons.delete_outline),
              label: Text(
                'Hapus Voucher',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
