import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'view_models/subscription_view_model.dart';
import '../../domain/models/user_subscription_model.dart';

class SubscriptionStatusScreen extends GetView<SubscriptionViewModel> {
  const SubscriptionStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.loadMySubscriptions();

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
                  return _buildEmptyState(accentColor);
                }

                return RefreshIndicator(
                  onRefresh: controller.loadMySubscriptions,
                  color: accentColor,
                  backgroundColor: cardColor,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      const SizedBox(height: 8),
                      // Show active subscription card prominently if exists
                      ...controller.mySubscriptions
                          .where((s) => s.isActive)
                          .map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: _buildActiveSubscriptionCard(
                                s,
                                cardColor,
                                accentColor,
                              ),
                            ),
                          ),
                      // Show pending subscriptions
                      if (controller.mySubscriptions.any(
                        (s) => s.isPending,
                      )) ...[
                        const SizedBox(height: 12),
                        _buildSectionTitle(
                          'Menunggu Pembayaran',
                          Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        ...controller.mySubscriptions
                            .where((s) => s.isPending)
                            .map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildSubscriptionCard(s, cardColor),
                              ),
                            ),
                      ],
                      // Show expired subscriptions
                      if (controller.mySubscriptions.any(
                        (s) => s.isExpired,
                      )) ...[
                        const SizedBox(height: 12),
                        _buildSectionTitle('Kadaluarsa', Colors.redAccent),
                        const SizedBox(height: 16),
                        ...controller.mySubscriptions
                            .where((s) => s.isExpired)
                            .map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildSubscriptionCard(s, cardColor),
                              ),
                            ),
                      ],
                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(accentColor),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Status Langganan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'KELOLA LANGGANAN ANDA',
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

  Widget _buildEmptyState(Color accentColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.subscriptions_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Langganan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih paket langganan untuk mulai menggunakan layanan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => controller.navigateToPackages(),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Lihat Paket',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSubscriptionCard(
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
              _buildStatusBadge(subscription.status),
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

  Widget _buildSubscriptionCard(
    UserSubscriptionModel subscription,
    Color cardColor,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy');

    return Container(
      // margin handled by parent listview
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  subscription.isPending
                      ? Icons.pending_actions
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
                  _buildStatusBadge(subscription.status),
                ],
              ),
            ],
          ),
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
    );
  }

  Widget _buildStatusBadge(SubscriptionStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case SubscriptionStatus.active:
        bgColor = const Color(0xFF4ADE80).withValues(alpha: 0.15);
        textColor = const Color(0xFF4ADE80);
        label = 'AKTIF';
        break;
      case SubscriptionStatus.pending:
        bgColor = Colors.orange.withValues(alpha: 0.15);
        textColor = Colors.orange;
        label = 'PENDING';
        break;
      case SubscriptionStatus.expired:
        bgColor = Colors.redAccent.withValues(alpha: 0.15);
        textColor = Colors.redAccent;
        label = 'EXPIRED';
        break;
      case SubscriptionStatus.none:
        bgColor = Colors.grey.withValues(alpha: 0.15);
        textColor = Colors.grey;
        label = 'NONE';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.5,
        ),
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

  Widget _buildBottomButton(Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1118),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => controller.navigateToPackages(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Beli Paket Baru',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
