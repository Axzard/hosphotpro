import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/subscription_package_model.dart';

class PackageBenefitsGrid extends StatelessWidget {
  final SubscriptionPackageModel package;
  final NumberFormat currencyFormat;
  final Color cardColor;
  final Color accentColor;

  const PackageBenefitsGrid({
    super.key,
    required this.package,
    required this.currencyFormat,
    required this.cardColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
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
            final data = benefits[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: data.isHighlighted ? accentColor.withValues(alpha: 0.12) : cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: data.isHighlighted
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
          },
        ),
      ],
    );
  }
}

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
