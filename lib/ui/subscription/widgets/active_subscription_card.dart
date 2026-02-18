import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/user_subscription_model.dart';
import '../view_models/subscription_view_model.dart';
import 'subscription_status_badge.dart';

class ActiveSubscriptionCard extends StatelessWidget {
  final UserSubscriptionModel subscription;
  final Color cardColor;
  final Color accentColor;
  final SubscriptionViewModel controller;

  const ActiveSubscriptionCard({
    super.key,
    required this.subscription,
    required this.cardColor,
    required this.accentColor,
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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accentColor.withValues(alpha: 0.15), cardColor],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.wifi_tethering, color: accentColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription.namaPaket,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: #${subscription.idLangganan}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              SubscriptionStatusBadge(status: subscription.status),
            ],
          ),
          const SizedBox(height: 24),
          // Info rows
          _buildInfoRow(
            Icons.access_time_rounded,
            'Sisa Waktu',
            '${subscription.daysRemaining} Hari, ${subscription.hoursRemaining} Jam',
            accentColor,
          ),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 24),
          _buildInfoRow(
            Icons.calendar_today_rounded,
            'Mulai',
            dateFormat.format(subscription.tanggalMulai),
            accentColor,
          ),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 24),
          _buildInfoRow(
            Icons.event_rounded,
            'Berakhir',
            dateFormat.format(subscription.tanggalBerakhir),
            accentColor,
          ),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 24),
          _buildInfoRow(
            Icons.payments_rounded,
            'Total Bayar',
            currencyFormat.format(subscription.totalBayar),
            accentColor,
          ),
          const SizedBox(height: 20),
          // Perpanjang button
          Obx(
            () => SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed:
                    controller.processingSubscriptionId.value ==
                        subscription.idLangganan
                    ? null
                    : () => controller.renewSubscription(subscription),
                icon:
                    controller.processingSubscriptionId.value ==
                        subscription.idLangganan
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded, size: 20),
                label: Text(
                  controller.processingSubscriptionId.value ==
                          subscription.idLangganan
                      ? 'Memproses...'
                      : 'Perpanjang Langganan',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: accentColor.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color accentColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.4), size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
