import 'package:get/get.dart';
import '../../domain/models/report_model.dart';
import '../../domain/models/report_repository.dart';
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
}
