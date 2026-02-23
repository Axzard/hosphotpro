import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/subscription_package_model.dart';
import '../view_models/subscription_view_model.dart';
import '../../../config/routing/app_routes.dart';

class PackageDetailBottomBar extends StatelessWidget {
  final SubscriptionPackageModel package;
  final NumberFormat currencyFormat;
  final Color accentColor;
  final SubscriptionViewModel controller;

  const PackageDetailBottomBar({
    super.key,
    required this.package,
    required this.currencyFormat,
    required this.accentColor,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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
          Column(
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
                final totalPrice = controller.calculateTotalPrice(package);
                return Text(
                  currencyFormat.format(totalPrice),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              }),
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
                    : () {
                        final totalPrice = controller.calculateTotalPrice(
                          package,
                        );
                        Get.toNamed(
                          Routes.PAYMENT,
                          arguments: {
                            'package': package,
                            'total_bayar': totalPrice,
                          },
                        );
                      },
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
                          Expanded(
                            child: Text(
                              'Lanjutkan ke Pembayaran',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
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
