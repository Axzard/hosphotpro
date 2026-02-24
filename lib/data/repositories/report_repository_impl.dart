import 'package:get/get.dart';
import '../../domain/models/report_model.dart';
import '../../domain/repositories/report_repository.dart';
import '../services/report_service.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportService _reportService = Get.find<ReportService>();

  @override
  Future<ReportDashboardModel?> getDashboardReport({int? year, int? month}) async {
    final response = await _reportService.getDashboardReport(
      year: year,
      month: month,
    );
    if (response.success && response.data != null) {
      return response.data!.toDomain();
    }
    return null;
  }

  @override
  Future<List<DailyReportModel>> getDailyReports({
    int? year,
    int? month,
    String? date,
  }) async {
    final response = await _reportService.getDailyReports(
      year: year,
      month: month,
      date: date,
    );
    if (response.success && response.data != null) {
      return response.data!.map((e) => e.toDomain()).toList();
    }
    return [];
  }

  @override
  Future<List<MonthlyReportModel>> getMonthlyReports({int? year}) async {
    final response = await _reportService.getMonthlyReports(year: year);
    if (response.success && response.data != null) {
      return response.data!.map((e) => e.toDomain()).toList();
    }
    return [];
  }

  @override
  Future<List<YearlyReportModel>> getYearlyReports() async {
    final response = await _reportService.getYearlyReports();
    if (response.success && response.data != null) {
      return response.data!.map((e) => e.toDomain()).toList();
    }
    return [];
  }

  @override
  Future<bool> refreshReports() async {
    final response = await _reportService.refreshReports();
    return response.success;
  }

  @override
  Future<DailyReportModel?> getDailyReportHarian({required int tahun, required int bulan, required int tgl}) async {
    final response = await _reportService.getDailyReportHarian(tahun: tahun, bulan: bulan, tgl: tgl);
    if (response.success && response.data != null) {
      return response.data!.toDomain();
    }
    return null;
  }

  @override
  Future<List<DailyReportModel>> getGroupedReport({required String type, required String start, required String end}) async {
    final response = await _reportService.getGroupedReport(type: type, start: start, end: end);
    if (response.success && response.data != null) {
      return response.data!.map((e) => e.toDomain()).toList();
    }
    return [];
  }

  @override
  Future<List<DailyReportModel>> getRangeReport({required String start, required String end}) async {
    final response = await _reportService.getRangeReport(start: start, end: end);
    if (response.success && response.data != null) {
      return response.data!.map((e) => e.toDomain()).toList();
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> getSummaryReport({required String start, required String end}) async {
    final response = await _reportService.getSummaryReport(start: start, end: end);
    if (response.success && response.data != null) {
      return {
        'total_pendapatan': double.tryParse(response.data!.totalPendapatan) ?? 0.0,
        'total_transaksi': response.data!.totalTransaksi,
      };
    }
    return {
      'total_pendapatan': 0.0,
      'total_transaksi': 0,
    };
  }
}
