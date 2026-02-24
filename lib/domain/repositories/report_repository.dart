import '../models/report_model.dart';

abstract class ReportRepository {
  Future<ReportDashboardModel?> getDashboardReport({int? year, int? month});
  Future<List<DailyReportModel>> getDailyReports({
    int? year,
    int? month,
    String? date,
  });
  Future<List<MonthlyReportModel>> getMonthlyReports({int? year});
  Future<List<YearlyReportModel>> getYearlyReports();
  Future<bool> refreshReports();

  Future<DailyReportModel?> getDailyReportHarian({
    required int tahun,
    required int bulan,
    required int tgl,
  });
  Future<List<DailyReportModel>> getGroupedReport({
    required String type,
    required String start,
    required String end,
  });
  Future<List<DailyReportModel>> getRangeReport({
    required String start,
    required String end,
  });
  Future<Map<String, dynamic>> getSummaryReport({
    required String start,
    required String end,
  });
}
