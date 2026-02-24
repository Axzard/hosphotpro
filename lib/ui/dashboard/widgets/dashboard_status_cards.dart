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

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _buildInfoCard(
                  title: 'Pendapatan Hari Ini',
                  value: currencyFormat.format(
                    controller.totalIncomeToday.value,
                  ),
                  icon: Icons.account_balance_wallet_rounded,
                  color: const Color(0xFF4ADE80),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(
                () => _buildInfoCard(
                  title: 'Transaksi Hari Ini',
                  value: '${controller.totalTransactionsToday.value}',
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFFFFB240),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _buildInfoCard(
                  title: 'Router Online',
                  value:
                      '${controller.onlineRouterCount.value} / ${controller.totalRouterCount.value}',
                  icon: Icons.dns_rounded,
                  color: const Color(0xFF00C2FF),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(
                () => _buildInfoCard(
                  title: 'User Aktif',
                  value:
                      '${controller.activeUserCount.value < 0 ? 0 : controller.activeUserCount.value}',
                  icon: Icons.bolt_rounded,
                  color: const Color(0xFFF472B6),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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

            ],
          ),
          const SizedBox(height: 20),
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
