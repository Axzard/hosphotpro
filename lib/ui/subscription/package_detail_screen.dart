import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/models/subscription_package_model.dart';
import 'view_models/subscription_view_model.dart';

class PackageDetailScreen extends GetView<SubscriptionViewModel> {
  const PackageDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final package = Get.arguments as SubscriptionPackageModel;
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 2,
    );

    const bgColor = Color(0xFF0A1118);
    const cardColor = Color(0xFF131E29);
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildPackageCard(
                      package,
                      currencyFormat,
                      cardColor,
                      accentColor,
                    ),
                    const SizedBox(height: 28),
                    _buildDurationDropdown(package, cardColor, accentColor),
                    const SizedBox(height: 28),
                    _buildBenefitsGrid(
                      package,
                      currencyFormat,
                      cardColor,
                      accentColor,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildBottomBar(package, currencyFormat, accentColor),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
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
                'Detail Paket',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'INFORMASI BERLANGGANAN',
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

  // ── Package Info Card ───────────────────────────────────────────────────
  Widget _buildPackageCard(
    SubscriptionPackageModel package,
    NumberFormat currencyFormat,
    Color cardColor,
    Color accentColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentColor.withValues(alpha: 0.12), cardColor],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          // Left: text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // POPULER badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'POPULER',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  package.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      currencyFormat.format(package.price),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/ 1 Bulan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Right: icon
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.router_outlined, color: accentColor, size: 30),
          ),
        ],
      ),
    );
  }

  // ── Duration Dropdown ───────────────────────────────────────────────────
  Widget _buildDurationDropdown(
    SubscriptionPackageModel package,
    Color cardColor,
    Color accentColor,
  ) {
    final durationOptions = [
      {'months': 1, 'label': '1 Bulan'},
      {'months': 3, 'label': '3 Bulan'},
      {'months': 6, 'label': '6 Bulan'},
      {'months': 12, 'label': '12 Bulan'},
    ];

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

  // ── Benefits 2×3 Grid ──────────────────────────────────────────────────
  Widget _buildBenefitsGrid(
    SubscriptionPackageModel package,
    NumberFormat currencyFormat,
    Color cardColor,
    Color accentColor,
  ) {
    final voucherFormat = NumberFormat('#,###', 'id_ID');

    final benefits = [
      _BenefitData(
        icon: Icons.payments_outlined,
        label: 'HARGA PAKET',
        value: currencyFormat.format(package.price),
        isHighlighted: true,
      ),
      _BenefitData(
        icon: Icons.dns_outlined,
        label: 'BATAS ROUTER',
        value: '${package.maxRouters} Perangkat',
      ),
      _BenefitData(
        icon: Icons.confirmation_number_outlined,
        label: 'BATAS VOUCHER',
        value: '${voucherFormat.format(package.maxVouchers)} Voucher',
      ),
      _BenefitData(
        icon: Icons.speed_outlined,
        label: 'KECEPATAN',
        value: 'Bandwidth Maks',
      ),
      _BenefitData(
        icon: Icons.monitor_heart_outlined,
        label: 'AKSES',
        value: 'Real-time',
      ),
      _BenefitData(
        icon: Icons.support_agent_outlined,
        label: 'LAYANAN',
        value: '24/7 CS',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MANFAAT PAKET',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: 0.5),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        // 2-column grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.55,
          ),
          itemCount: benefits.length,
          itemBuilder: (context, index) {
            return _buildBenefitCard(benefits[index], cardColor, accentColor);
          },
        ),
      ],
    );
  }

  Widget _buildBenefitCard(
    _BenefitData data,
    Color cardColor,
    Color accentColor,
  ) {
    final isHighlighted = data.isHighlighted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted ? accentColor.withValues(alpha: 0.12) : cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHighlighted
              ? accentColor.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.icon, color: accentColor, size: 28),
          const SizedBox(height: 8),
          Text(
            data.label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: accentColor.withValues(alpha: 0.7),
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            data.value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar ─────────────────────────────────────────────────────────
  Widget _buildBottomBar(
    SubscriptionPackageModel package,
    NumberFormat currencyFormat,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF101820),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Price row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Left: label + price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Biaya',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(() {
                      final totalPrice = controller.calculateTotalPrice(
                        package,
                      );
                      return Text(
                        currencyFormat.format(totalPrice),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              // Right: PPN badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  'PPN 0% TERMASUK',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // CTA button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.isProcessingPayment.value
                    ? null
                    : () => controller.initiatePayment(package),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: accentColor.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 10,
                  shadowColor: accentColor.withValues(alpha: 0.4),
                ),
                child: controller.isProcessingPayment.value
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Lanjutkan ke Pembayaran',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 20,
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Security text
          Text(
            'Metode pembayaran aman melalui sistem enkripsi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Helper class ────────────────────────────────────────────────────────
class _BenefitData {
  final IconData icon;
  final String label;
  final String value;
  final bool isHighlighted;

  const _BenefitData({
    required this.icon,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });
}
