import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'view_models/report_view_model.dart';
import '../../../domain/models/report_model.dart';

class ReportScreen extends GetView<ReportViewModel> {
  const ReportScreen({super.key});

  void _showYearPicker(BuildContext context, ReportViewModel controller) {
    showDialog(
      context: context,
      builder: (context) {
        final currentYear = DateTime.now().year;
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text(
            'Pilih Tahun',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                final year = currentYear - index;
                return ListTile(
                  title: Text(
                    '$year',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white),
                  ),
                  onTap: () {
                    controller.setYear(year);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F172A);
    const cardColor = Color(0xFF1E293B);
    const accentColor = Color(0xFF00C2FF);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Laporan Penjualan',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            indicatorColor: accentColor,
            labelColor: accentColor,
            unselectedLabelColor: Colors.white54,
            labelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
            ),
            tabs: const [
              Tab(text: 'Harian'),
              Tab(text: 'Bulanan'),
              Tab(text: 'Tahunan'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Refresh Data',
              onPressed: () => controller.refreshData(),
            ),
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.calendar_month, color: Colors.white),
                onPressed: () async {
                  final tabController = DefaultTabController.of(context);
                  if (tabController.index == 2) {
                    _showYearPicker(context, controller);
                  } else {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate:
                          controller.selectedDate.value ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: accentColor,
                              onPrimary: Colors.white,
                              surface: cardColor,
                              onSurface: Colors.white,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      controller.setDate(picked);
                    }
                  }
                },
              ),
            ),
            Obx(
              () =>
                  (controller.selectedDate.value != null ||
                      controller.selectedYear.value != DateTime.now().year)
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        controller.selectedDate.value = null;
                        controller.selectedYear.value = DateTime.now().year;
                        controller.fetchAllReports();
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Date filter banner
            Obx(
              () => controller.selectedDate.value != null
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      width: double.infinity,
                      color: accentColor.withValues(alpha: 0.1),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.filter_list,
                            color: accentColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Filter: ${DateFormat('dd MMM yyyy', 'id_ID').format(controller.selectedDate.value!)}',
                            style: GoogleFonts.plusJakartaSans(
                              color: accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

            // Tab content
            Expanded(
              child: Obx(
                () => controller.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(color: accentColor),
                      )
                    : TabBarView(
                        children: [
                          _buildDailyTab(controller),
                          _buildMonthlyTab(controller),
                          _buildYearlyTab(controller),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTab(ReportViewModel controller) {
    return Column(
      children: [
        _buildChartSection(
          'Tren Penjualan Harian',
          controller.dailyIncomeData,
          const Color(0xFF4ADE80),
          'daily',
        ),
        Expanded(
          child: controller.dailyReports.isEmpty
              ? _buildEmptyState()
              : _buildDailyList(controller.dailyReports),
        ),
      ],
    );
  }

  Widget _buildMonthlyTab(ReportViewModel controller) {
    return Column(
      children: [
        _buildChartSection(
          'Performa Bulanan',
          controller.monthlyIncomeData,
          const Color(0xFF00C2FF),
          'monthly',
        ),
        Expanded(
          child: controller.monthlyReports.isEmpty
              ? _buildEmptyState()
              : _buildMonthlyList(controller.monthlyReports),
        ),
      ],
    );
  }

  Widget _buildYearlyTab(ReportViewModel controller) {
    return Column(
      children: [
        _buildChartSection(
          'Rekap Tahunan',
          controller.yearlyIncomeData,
          const Color(0xFFF472B6),
          'yearly',
        ),
        Expanded(
          child: controller.yearlyReports.isEmpty
              ? _buildEmptyState()
              : _buildYearlyList(controller.yearlyReports),
        ),
      ],
    );
  }

  Widget _buildChartSection(
    String title,
    List<double> data,
    Color color,
    String type,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.insights, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(child: _buildIncomeChart(data, color, type)),
        ],
      ),
    );
  }

  Widget _buildIncomeChart(List<double> data, Color color, String type) {
    if (data.isEmpty) return const Center(child: Text('No data'));

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final interval = maxVal > 0 ? (maxVal / 5).ceilToDouble() : 500.0;
    final chartMaxY = maxVal > 0 ? maxVal * 1.3 : 1000.0;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: chartMaxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1E293B),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                String label = '';
                if (type == 'daily') {
                  label = 'H${spot.x.toInt() + 1}';
                } else if (type == 'monthly') {
                  label = DateFormat(
                    'MMM', 'id_ID',
                  ).format(DateTime(2024, spot.x.toInt() + 1));
                } else {
                  label = '${DateTime.now().year - 4 + spot.x.toInt()}';
                }

                final currencyFormat = NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                );
                return LineTooltipItem(
                  '$label\n${currencyFormat.format(spot.y)}',
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
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withValues(alpha: 0.05),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval > 0 ? interval : 500,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                // Defensive label logic to prevent overlapping white blob
                if (value == 0) return const SizedBox.shrink();

                // Show a label every 2 intervals or at least at the top
                final isTop = (value - chartMaxY).abs() < (interval / 2);
                final isInterval = (value % (interval * 2)) < 0.1;

                if (!isTop && !isInterval) return const SizedBox.shrink();

                String formatted = '';
                if (value >= 1000000) {
                  formatted = '${(value / 1000000).toStringAsFixed(1)}M';
                } else if (value >= 1000) {
                  formatted = '${(value / 1000).toStringAsFixed(0)}K';
                } else {
                  formatted = value.toStringAsFixed(0);
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    formatted,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white38,
                      fontSize: 9,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: type == 'daily' ? 5 : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length)
                  return const SizedBox.shrink();

                String text = '';
                if (type == 'daily') {
                  if (index % 5 != 0) return const SizedBox.shrink();
                  text = '${index + 1}';
                } else if (type == 'monthly') {
                  if (index % 2 != 0) return const SizedBox.shrink();
                  text = DateFormat('MMM', 'id_ID').format(DateTime(2024, index + 1));
                } else {
                  text = '${DateTime.now().year - 4 + index}'.substring(2);
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    text,
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              data.length,
              (i) => FlSpot(i.toDouble(), data[i]),
            ),
            isCurved: type != 'yearly', // Less curved for fewer points
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 3,
                    color: color,
                    strokeWidth: 1,
                    strokeColor: Colors.white,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0),
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

  Widget _buildDailyList(List<DailyReportModel> reports) {
    if (reports.isEmpty) return _buildEmptyState();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildReportCard(
          title: DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(report.tanggal),
          income: report.totalPendapatan,
          transactions: report.totalTransaksi,
          icon: Icons.calendar_today,
          iconColor: const Color(0xFF4ADE80),
        );
      },
    );
  }

  Widget _buildMonthlyList(List<MonthlyReportModel> reports) {
    if (reports.isEmpty) return _buildEmptyState();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        final monthName = DateFormat(
          'MMMM', 'id_ID',
        ).format(DateTime(2024, report.bulan));
        return _buildReportCard(
          title: monthName,
          income: report.totalPendapatan,
          transactions: report.totalTransaksi,
          icon: Icons.calendar_month,
          iconColor: const Color(0xFF00C2FF),
        );
      },
    );
  }

  Widget _buildYearlyList(List<YearlyReportModel> reports) {
    if (reports.isEmpty) return _buildEmptyState();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildReportCard(
          title: '${report.tahun}',
          income: report.totalPendapatan,
          transactions: report.totalTransaksi,
          icon: Icons.event,
          iconColor: const Color(0xFFF472B6),
        );
      },
    );
  }

  Widget _buildReportCard({
    required String title,
    required double income,
    required int transactions,
    required IconData icon,
    required Color iconColor,
  }) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$transactions Transaksi',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            currencyFormat.format(income),
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data laporan',
            style: GoogleFonts.plusJakartaSans(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}
