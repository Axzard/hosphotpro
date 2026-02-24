import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../view_models/dashboard_view_model.dart';
import '../../../domain/models/user_subscription_model.dart';

class SubscriptionCard extends StatelessWidget {
  final DashboardViewModel controller;

  const SubscriptionCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF00C2FF), Color(0xFF0066FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C2FF).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(controller.subscriptionStatusEnum.value),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.subscriptionStatus.value.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (controller.isActiveSubscription.value)
                const Icon(Icons.verified, color: Colors.white, size: 24),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            controller.packageName.value,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            controller.expiryDate.value != null
                ? 'Berakhir pada ${DateFormat('d MMM yyyy').format(controller.expiryDate.value!)}'
                : 'lihat paket langganan untuk informasi lebih lanjut',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.navigateToSubscriptionStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0066FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Kelola Langganan',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return Colors.greenAccent; 
      case SubscriptionStatus.pending:
        return Colors.amberAccent; 
      case SubscriptionStatus.expired:
        return Colors.redAccent; 
      case SubscriptionStatus.canceled:
      case SubscriptionStatus.none:
      return Colors.white.withValues(alpha: 0.2); 
    }
  }
}
