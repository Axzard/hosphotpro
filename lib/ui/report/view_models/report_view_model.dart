import 'dart:async';
import 'package:get/get.dart';
import '../../../domain/models/report_repository.dart';
import '../../../domain/models/report_model.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/services/websocket_service.dart';
import 'package:intl/intl.dart';

class ReportViewModel extends GetxController {
  final ReportRepository _reportRepository = Get.find<ReportRepository>();
  final WebSocketService _webSocketService = Get.find<WebSocketService>();

  final dailyReports = <DailyReportModel>[].obs;
  final monthlyReports = <MonthlyReportModel>[].obs;
  final yearlyReports = <YearlyReportModel>[].obs;
  final isLoading = false.obs;

  // Selection filters
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
      
      // Match backend events: voucher:sold, voucher:updated, voucher:created
      if (event == 'voucher:sold' || 
          event == 'voucher:updated' || 
          event == 'voucher:created' || 
          event == 'voucher:bulkcreated') {
        print('📊 [ReportVM] Realtime refresh for event: $event');
        fetchAllReports(isSilent: true);
      }
    });
  }

  @override
  void onClose() {
    _refreshSub?.cancel();
    super.onClose();
  }

  // --- Chart Helpers ---
  List<double> get dailyIncomeData => dailyReports.isEmpty 
      ? [] 
      : dailyReports.map((e) => e.totalPendapatan).toList();

  List<double> get monthlyIncomeData => monthlyReports.isEmpty 
      ? List.filled(12, 0.0) 
      : List.generate(12, (index) {
          final month = index + 1;
          final report = monthlyReports.firstWhereOrNull((e) => e.bulan == month);
          return report?.totalPendapatan ?? 0.0;
        });

  Future<void> fetchAllReports({bool isSilent = false}) async {
    if (!isSilent) isLoading.value = true;
    try {
      final now = DateTime.now();
      final dateStr = selectedDate.value != null 
          ? DateFormat('yyyy-MM-dd').format(selectedDate.value!) 
          : null;

      final results = await Future.wait([
        _reportRepository.getDailyReports(
          year: selectedDate.value?.year ?? now.year,
          month: selectedDate.value?.month ?? now.month,
          date: dateStr,
        ),
        _reportRepository.getMonthlyReports(year: selectedYear.value),
        _reportRepository.getYearlyReports(),
      ]);

      dailyReports.assignAll(results[0] as List<DailyReportModel>);
      monthlyReports.assignAll(results[1] as List<MonthlyReportModel>);
      yearlyReports.assignAll(results[2] as List<YearlyReportModel>);
    } catch (e) {
      if (!isSilent) SnackbarUtils.showError('Error', 'Gagal memuat laporan: $e');
    } finally {
      if (!isSilent) isLoading.value = false;
    }
  }

  void setDate(DateTime? date) {
    selectedDate.value = date;
    fetchAllReports();
  }

  void setYear(int year) {
    selectedYear.value = year;
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
