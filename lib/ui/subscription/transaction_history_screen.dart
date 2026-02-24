import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/models/user_subscription_model.dart';
import 'view_models/subscription_view_model.dart';

class TransactionHistoryScreen extends GetView<SubscriptionViewModel> {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: accentColor),
                  );
                }

                if (controller.mySubscriptions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada riwayat langganan',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadMySubscriptions,
                  color: accentColor,
                  backgroundColor: cardColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    itemCount: controller.mySubscriptions.length,
                    itemBuilder: (context, index) {
                      final subscription = controller.mySubscriptions[index];
                      return _buildSubscriptionHistoryCard(
                        subscription,
                        cardColor,
                        accentColor,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Riwayat Langganan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionHistoryCard(
    UserSubscriptionModel subscription,
    Color cardColor,
    Color accentColor,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy');

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (subscription.status) {
      case SubscriptionStatus.active:
        statusColor = const Color(0xFF4ADE80);
        statusLabel = 'AKTIF';
        statusIcon = Icons.check_circle_outline;
        break;
      case SubscriptionStatus.pending:
        statusColor = Colors.orange;
        statusLabel = 'PENDING';
        statusIcon = Icons.pending_actions;
        break;
      case SubscriptionStatus.expired:
        statusColor = Colors.redAccent;
        statusLabel = 'EXPIRED';
        statusIcon = Icons.cancel_outlined;
        break;
      case SubscriptionStatus.canceled:
        statusColor = Colors.red;
        statusLabel = 'DIBATALKAN';
        statusIcon = Icons.block;
        break;
      case SubscriptionStatus.none:
        statusColor = Colors.grey;
        statusLabel = 'NONE';
        statusIcon = Icons.help_outline;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.namaPaket,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(subscription.totalBayar),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            onSelected: (value) {
              controller.changeSubscriptionStatus(
                subscription.idLangganan,
                value,
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'active', child: Text('Set Aktif')),
              const PopupMenuItem(value: 'pending', child: Text('Set Pending')),
              const PopupMenuItem(value: 'expired', child: Text('Set Expired')),
              const PopupMenuItem(value: 'canceled', child: Text('Set Batal')),
            ],
            color: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}
