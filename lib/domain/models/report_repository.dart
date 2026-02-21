import 'report_model.dart';

abstract class ReportRepository {
  Future<ReportDashboardModel?> getDashboardReport({int? year, int? month});
  Future<List<DailyReportModel>> getDailyReports({int? year, int? month, String? date});
  Future<List<MonthlyReportModel>> getMonthlyReports({int? year});
  Future<List<YearlyReportModel>> getYearlyReports();
  Future<bool> refreshReports();
}
