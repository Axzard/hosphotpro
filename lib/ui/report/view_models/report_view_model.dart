import 'dart:async';
import 'package:get/get.dart';
import '../../../domain/repositories/report_repository.dart';
import '../../../domain/models/report_model.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/services/websocket_service.dart';
import '../../../config/routing/app_routes.dart' as app_routes;
import 'package:intl/intl.dart';

class ReportViewModel extends GetxController {
  final ReportRepository _reportRepository = Get.find<ReportRepository>();
  final WebSocketService _webSocketService = Get.find<WebSocketService>();

  final dailyReports = <DailyReportModel>[].obs;
  final monthlyReports = <MonthlyReportModel>[].obs;
  final yearlyReports = <YearlyReportModel>[].obs;
  final isLoading = false.obs;

  final selectedDate = Rxn<DateTime>();
  final selectedYear = DateTime.now().year.obs;

  StreamSubscription? _refreshSub;

  @override
  void onInit() {
    super.onInit();
    fetchAllReports();
    _initRealtimeListeners();
  }

  void _initRealtimeListeners() {
    _refreshSub = _webSocketService.eventStream.listen((eventData) {
      final event = (eventData['event'] ?? '').toString().toLowerCase();

      if (event == 'voucher:sold' ||
          event == 'voucher:updated' ||
          event == 'voucher:created' ||
          event == 'voucher:bulkcreated') {
        fetchAllReports(isSilent: true);
      }
    });
  }

  @override
  void onClose() {
    _refreshSub?.cancel();
    super.onClose();
  }

  List<double> get dailyIncomeData {
    if (dailyReports.isEmpty) return [];

    final now = DateTime.now();
    final year = selectedDate.value?.year ?? now.year;
    final month = selectedDate.value?.month ?? now.month;

    final daysInMonth = DateTime(year, month + 1, 0).day;

    return List.generate(daysInMonth, (index) {
      final day = index + 1;
      final report = dailyReports.firstWhereOrNull((e) => e.tanggal.day == day);
      return report?.totalPendapatan ?? 0.0;
    });
  }

  List<double> get monthlyIncomeData {
    return List.generate(12, (index) {
      final month = index + 1;
      final report = monthlyReports.firstWhereOrNull((e) => e.bulan == month);
      return report?.totalPendapatan ?? 0.0;
    });
  }

  List<double> get yearlyIncomeData {
    final currentYear = DateTime.now().year;
    return List.generate(5, (index) {
      final year = currentYear - 4 + index;
      final report = yearlyReports.firstWhereOrNull((e) => e.tahun == year);
      return report?.totalPendapatan ?? 0.0;
    });
  }

  Future<void> fetchAllReports({bool isSilent = false}) async {
    final hasData =
        dailyReports.isNotEmpty ||
        monthlyReports.isNotEmpty ||
        yearlyReports.isNotEmpty;
    if (!isSilent && !hasData) isLoading.value = true;
    try {
      final now = DateTime.now();
      final year = selectedDate.value?.year ?? now.year;
      final month = selectedDate.value?.month ?? now.month;

      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);

      final startDateStr = DateFormat('yyyy-MM-dd').format(firstDay);
      final endDateStr = DateFormat('yyyy-MM-dd').format(lastDay);

      final results = await Future.wait([
        _reportRepository.getGroupedReport(
          type: 'day',
          start: startDateStr,
          end: endDateStr,
        ),
        _reportRepository.getMonthlyReports(year: selectedYear.value),
        _reportRepository.getYearlyReports(),
      ]);

      dailyReports.assignAll(results[0] as List<DailyReportModel>);
      monthlyReports.assignAll(results[1] as List<MonthlyReportModel>);
      yearlyReports.assignAll(results[2] as List<YearlyReportModel>);
    } catch (e) {
      if (!isSilent) {
        Get.toNamed(
          app_routes.Routes.ERROR,
          arguments: 'Gagal memuat laporan, terjadi gangguan pada server.',
        );
      }
    } finally {
      if (!isSilent) isLoading.value = false;
    }
  }

  void setDate(DateTime? date) {
    selectedDate.value = date;
    if (date != null) {
      selectedYear.value = date.year;
    }
    fetchAllReports();
  }

  void setYear(int year) {
    selectedYear.value = year;

    if (selectedDate.value != null) {
      selectedDate.value = DateTime(year, selectedDate.value!.month, 1);
    } else {
      selectedDate.value = DateTime(year, DateTime.now().month, 1);
    }
    fetchAllReports();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      final success = await _reportRepository.refreshReports();
      if (success) {
        await fetchAllReports();
        SnackbarUtils.showSuccess('Berhasil', 'Laporan berhasil diperbarui');
      } else {
        SnackbarUtils.showError('Error', 'Gagal memperbarui laporan');
      }
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memperbarui laporan: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
