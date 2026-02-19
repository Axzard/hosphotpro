import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/user_subscription_model.dart';
import '../view_models/subscription_view_model.dart';
import 'subscription_status_badge.dart';

class SubscriptionItemCard extends StatelessWidget {
  final UserSubscriptionModel subscription;
  final Color cardColor;
  final SubscriptionViewModel controller;

  const SubscriptionItemCard({
    super.key,
    required this.subscription,
    required this.cardColor,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy');

    return GestureDetector(
      onTap: subscription.isPending ? () => controller.resumePayment(subscription) : null,
      child: Container(
        // margin handled by parent listview
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: subscription.isPending 
              ? Colors.orange.withValues(alpha: 0.3) 
              : Colors.white.withValues(alpha: 0.05)
          ),
          boxShadow: subscription.isPending ? [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.05),
              blurRadius: 10,
              spreadRadius: 0,
            )
          ] : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: subscription.isPending 
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    subscription.isPending
                        ? Icons.payment_rounded
                        : Icons.history,
                    color: subscription.isPending
                        ? Colors.orange
                        : Colors.white54,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.namaPaket,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${dateFormat.format(subscription.tanggalMulai)} - ${dateFormat.format(subscription.tanggalBerakhir)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(subscription.totalBayar),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      SubscriptionStatusBadge(status: subscription.status),
                    ],
                  ),
                ),
              ],
            ),
            if (subscription.isPending) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app_rounded, size: 14, color: Colors.orange.withValues(alpha: 0.7)),
                  const SizedBox(width: 6),
                  Text(
                    'Klik untuk selesaikan pembayaran',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
            // Show perpanjang button for expired subscriptions
            if (subscription.isExpired) ...[
              const SizedBox(height: 14),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed:
                        controller.processingSubscriptionId.value ==
                            subscription.idLangganan
                        ? null
                        : () => controller.renewSubscription(subscription),
                    icon:
                        controller.processingSubscriptionId.value ==
                            subscription.idLangganan
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF00C2FF),
                            ),
                          )
                        : const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(
                      'Perpanjang',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00C2FF),
                      side: const BorderSide(color: Color(0xFF00C2FF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
