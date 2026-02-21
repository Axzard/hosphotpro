import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'view_models/dashboard_view_model.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends GetView<DashboardViewModel> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Gradient Blobs - Non-reactive (Optimized)
          const _BackgroundBlobs(),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchDashboardData(isSilent: true),
              color: const Color(0xFF00C2FF),
              backgroundColor: const Color(0xFF1E293B),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildSubscriptionCard(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Ringkasan'),
                    const SizedBox(height: 16),
                    _buildStatusCards(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Tren Penjualan'),
                    const SizedBox(height: 16),
                    _buildSalesChart(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Menu Utama'),
                    const SizedBox(height: 16),
                    _buildMenuGrid(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          
          // Only show full screen loader on VERY FIRST load
          Obx(() => controller.isLoading.value 
            ? Container(
                color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00C2FF)),
                ),
              )
            : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Text(
                'Halo, ${controller.username.value}',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
              const SizedBox(height: 4),
              Text(
                'Selamat datang kembali',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Get.dialog(
              AlertDialog(
                backgroundColor: const Color(0xFF1E293B),
                title: Text(
                  'Keluar',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  'Apakah Anda yakin ingin keluar dari aplikasi?',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white54),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      controller.logout();
                    },
                    child: Text(
                      'Ya, Keluar',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFF4757), Color(0xFFFF6B81)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0F172A),
              ),
              child: const Icon(Icons.logout, color: Colors.white, size: 24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionCard() {
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
                  color: Colors.white.withValues(alpha: 0.2),
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
              const Icon(Icons.verified, color: Colors.white, size: 24),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Paket Premium',
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
                : 'Belum berlangganan',
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMenuGrid() {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Obx(() => _buildMenuCard(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Paket Langganan',
                  subtitle: controller.expiryDate.value != null
                      ? 'Aktif s.d ${DateFormat('d MMM').format(controller.expiryDate.value!)}'
                      : 'Beli / Perpanjang',
                  color: const Color(0xFFF472B6),
                  onTap: controller.navigateToPackageList,
                )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => _buildMenuCard(
                  icon: Icons.router_rounded,
                  title: 'Router',
                  subtitle: '${controller.totalRouterCount.value} Unit',
                  color: const Color(0xFF4ADE80),
                  onTap: controller.navigateToRouters,
                )),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildMenuCard(
                  icon: Icons.wifi_tethering_rounded,
                  title: 'Hotspot',
                  subtitle: 'Manajemen Server',
                  color: const Color(0xFF00C2FF),
                  onTap: controller.navigateToHotspots,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(() => _buildMenuCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Paket Voucher',
                  subtitle: controller.selectedRouter.value != null 
                      ? 'Kelola Paket' 
                      : 'Pilih Router Dahulu',
                  color: const Color(0xFF94A3B8),
                  onTap: controller.navigateToVoucherPackages,
                )),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Obx(() => _buildMenuCard(
                  icon: Icons.confirmation_number_outlined,
                  title: 'Voucher',
                  subtitle: controller.selectedRouter.value != null
                      ? '${controller.voucherCount.value} Pcs'
                      : 'Pilih Router Dahulu',
                  color: const Color(0xFFFFB547),
                  onTap: controller.navigateToVouchers,
                )),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMenuCard(
                  icon: Icons.receipt_long_rounded,
                  title: 'Transaksi',
                  subtitle: 'Riwayat Penjualan',
                  color: const Color(0xFFFF6B81),
                  onTap: controller.navigateToTransactions,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCards() {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildInfoCard(
                title: 'Pendapatan Hari Ini',
                value: currencyFormat.format(controller.totalIncomeToday.value),
                icon: Icons.account_balance_wallet_rounded,
                color: const Color(0xFF4ADE80),
              )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() => _buildInfoCard(
                title: 'Transaksi Hari Ini',
                value: '${controller.totalTransactionsToday.value}',
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFFFFB240),
              )),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildInfoCard(
                title: 'Router Online',
                value:
                    '${controller.onlineRouterCount.value} / ${controller.totalRouterCount.value}',
                icon: Icons.dns_rounded,
                color: const Color(0xFF00C2FF),
              )),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() => _buildInfoCard(
                title: 'User Aktif',
                value: '${controller.activeUserCount.value < 0 ? 0 : controller.activeUserCount.value}',
                icon: Icons.bolt_rounded,
                color: const Color(0xFFF472B6),
              )),
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
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
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
              Icon(
                Icons.trending_up_rounded,
                color: color.withValues(alpha: 0.3),
                size: 16,
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

  Widget _buildSalesChart() {
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pendapatan Hari Ini',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.show_chart_rounded, color: Color(0xFF00C2FF), size: 18),
            ],
          ),
          const SizedBox(height: 4),
          Obx(() {
            final currencyFormat = NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp',
              decimalDigits: 0,
            );
            return Text(
              currencyFormat.format(controller.totalIncomeToday.value),
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            );
          }),
          const SizedBox(height: 24),
          Expanded(
            child: Obx(() => _buildLineChart(controller.dailyIncomeData)),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<double> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available', style: TextStyle(color: Colors.white24)));
    }

    final maxVal = data.isNotEmpty ? data.reduce((a, b) => a > b ? a : b) : 100.0;
    
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxVal > 0 ? maxVal * 1.3 : 1000,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxVal > 0 ? maxVal / 4 : 250,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withValues(alpha: 0.05),
            strokeWidth: 1,
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1E293B),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final currencyFormat = NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp',
                  decimalDigits: 0,
                );
                return LineTooltipItem(
                  'H${spot.x.toInt() + 1}\n${currencyFormat.format(spot.y)}',
                  GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 5,
              getTitlesWidget: (value, meta) {
                if (value % 5 != 0) return const SizedBox.shrink();
                return Text(
                  '${value.toInt() + 1}',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                String text = '';
                if (value >= 1000000) {
                  text = '${(value / 1000000).toStringAsFixed(1)}M';
                } else if (value >= 1000) {
                  text = '${(value / 1000).toStringAsFixed(0)}K';
                } else {
                  text = value.toStringAsFixed(0);
                }
                return Text(
                  text,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
            isCurved: true,
            color: const Color(0xFF00C2FF),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00C2FF).withValues(alpha: 0.2),
                  const Color(0xFF00C2FF).withValues(alpha: 0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// optimized static background to avoid expensive re-renders
class _BackgroundBlobs extends StatelessWidget {
  const _BackgroundBlobs();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00C2FF).withValues(alpha: 0.15),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4ADE80).withValues(alpha: 0.1),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
