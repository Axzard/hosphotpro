import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../view_models/dashboard_view_model.dart';

class DashboardStatusCards extends StatelessWidget {
  final DashboardViewModel controller;

  const DashboardStatusCards({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 900;
        int crossAxisCount = isWide ? 4 : 2;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isWide 
              ? 1.4 
              : (constraints.maxWidth < 380 ? 0.95 : 1.1),
          children: [
            Obx(
              () => _buildInfoCard(
                title: 'Pendapatan Hari Ini',
                value: currencyFormat.format(
                  controller.totalIncomeToday.value,
                ),
                icon: Icons.account_balance_wallet_rounded,
                color: const Color(0xFF4ADE80),
              ),
            ),
            Obx(
              () => _buildInfoCard(
                title: 'Transaksi Hari Ini',
                value: '${controller.totalTransactionsToday.value}',
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFFFFB240),
              ),
            ),
            Obx(
              () => _buildInfoCard(
                title: 'Router Online',
                value:
                    '${controller.totalRouterCount.value} / ${controller.onlineRouterCount.value}',
                icon: Icons.dns_rounded,
                color: const Color(0xFF00C2FF),
              ),
            ),
            GestureDetector(
              onTap: () => controller.navigateToActiveVouchers(),
              child: Obx(
                () => _buildInfoCard(
                  title: 'Voucher Aktif',
                  value:
                      '${controller.activeUserCount.value < 0 ? 0 : controller.activeUserCount.value}',
                  icon: Icons.people_alt_rounded,
                  color: const Color(0xFFF472B6),
                  isClickable: true,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isClickable = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              if (isClickable)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tap',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.touch_app_rounded,
                        color: color,
                        size: 14,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
