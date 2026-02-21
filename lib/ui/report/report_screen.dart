import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'view_models/report_view_model.dart';
import '../../../domain/models/report_model.dart';

class ReportScreen extends GetView<ReportViewModel> {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0F172A);
    const cardColor = Color(0xFF1E293B);
    const accentColor = Color(0xFF00C2FF);

    return Scaffold(
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
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.white),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: controller.selectedDate.value ?? DateTime.now(),
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
            },
          ),
          Obx(() => controller.selectedDate.value != null
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => controller.setDate(null),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() => Column(
            children: [
              if (controller.selectedDate.value != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  width: double.infinity,
                  color: accentColor.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_list,
                          color: accentColor, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Filter: ${DateFormat('dd MMM yyyy').format(controller.selectedDate.value!)}',
                        style: GoogleFonts.plusJakartaSans(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: controller.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(color: accentColor))
                    : DefaultTabController(
                        length: 3,
                        child: Column(
                          children: [
                            TabBar(
                              indicatorColor: accentColor,
                              labelColor: accentColor,
                              unselectedLabelColor: Colors.white54,
                              labelStyle: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold),
                              tabs: const [
                                Tab(text: 'Harian'),
                                Tab(text: 'Bulanan'),
                                Tab(text: 'Tahunan'),
                              ],
                            ),
                            Expanded(
                              child: TabBarView(
                                children: [
                                  _buildDailyTab(controller),
                                  _buildMonthlyTab(controller),
                                  _buildYearlyTab(controller),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          )),
    );
  }

  Widget _buildDailyTab(ReportViewModel controller) {
    if (controller.dailyReports.isEmpty) return _buildEmptyState();
    return Column(
      children: [
        _buildChartSection('Tren Penjualan Harian', controller.dailyIncomeData, const Color(0xFF4ADE80)),
        Expanded(child: _buildDailyList(controller.dailyReports)),
      ],
    );
  }

  Widget _buildMonthlyTab(ReportViewModel controller) {
    if (controller.monthlyReports.isEmpty) return _buildEmptyState();
    return Column(
      children: [
        _buildChartSection('Performa Bulanan', controller.monthlyIncomeData, const Color(0xFF00C2FF)),
        Expanded(child: _buildMonthlyList(controller.monthlyReports)),
      ],
    );
  }

  Widget _buildYearlyTab(ReportViewModel controller) {
    if (controller.yearlyReports.isEmpty) return _buildEmptyState();
    return Column(
      children: [
        _buildChartSection('Rekap tahunan', controller.yearlyReports.map((e) => e.totalPendapatan).toList(), const Color(0xFFF472B6)),
        Expanded(child: _buildYearlyList(controller.yearlyReports)),
      ],
    );
  }

  Widget _buildChartSection(String title, List<double> data, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      height: 200,
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
          Expanded(child: _buildIncomeChart(data, color)),
        ],
      ),
    );
  }

  Widget _buildIncomeChart(List<double> data, Color color) {
    if (data.isEmpty) return const Center(child: Text('No data'));

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i])),
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.1),
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
          title: DateFormat('EEEE, dd MMM yyyy').format(report.tanggal),
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
        final monthName = DateFormat('MMMM').format(DateTime(2024, report.bulan));
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
          Icon(Icons.analytics_outlined,
              size: 64, color: Colors.white.withValues(alpha: 0.1)),
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
