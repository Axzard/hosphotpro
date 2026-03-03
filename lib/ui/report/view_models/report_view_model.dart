import 'dart:async';
import 'package:get/get.dart';
import '../../../domain/repositories/report_repository.dart';
import '../../../domain/models/report_model.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/services/websocket_service.dart';
import '../../../config/routing/app_routes.dart' as app_routes;
import '../../../data/model/report_api_model.dart';
import '../../../core/services/cache_service.dart';
import '../../dashboard/view_models/dashboard_view_model.dart';



class ReportViewModel extends GetxController {
  final ReportRepository _reportRepository = Get.find<ReportRepository>();
  final WebSocketService _webSocketService = Get.find<WebSocketService>();
  final CacheService _cacheService = Get.find<CacheService>();


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
    final dashboardVM = Get.find<DashboardViewModel>();

    // Listen to subscription status changes
    ever(dashboardVM.isActiveSubscription, (bool isActive) {
      if (isActive && dailyReports.isEmpty) {
        fetchAllReports();
      }
    });

    loadCachedData();
    fetchAllReports();
    _initRealtimeListeners();
  }

  void loadCachedData() {
    final cachedData = _cacheService.getReports();
    if (cachedData != null) {
      try {
        if (cachedData['daily'] != null) {
          final List list = cachedData['daily'];
          dailyReports.assignAll(list.map((i) => DailyReportApiModel.fromJson(i).toDomain()).toList());
        }
        if (cachedData['monthly'] != null) {
          final List list = cachedData['monthly'];
          monthlyReports.assignAll(list.map((i) => MonthlyReportApiModel.fromJson(i).toDomain()).toList());
        }
        if (cachedData['yearly'] != null) {
          final List list = cachedData['yearly'];
          yearlyReports.assignAll(list.map((i) => YearlyReportApiModel.fromJson(i).toDomain()).toList());
        }
      } catch (e) {
        print('[ReportVM] Error loading cache: $e');
      }
    }
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
    final year = selectedYear.value;
    final month = selectedDate.value?.month ?? DateTime.now().month;

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
    final baseYear = selectedYear.value;
    return List.generate(5, (index) {
      final year = baseYear - 4 + index;
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
      final year = selectedYear.value;
      final month = selectedDate.value?.month ?? now.month;

      // 1. Fetch Daily Reports (for the selected month)
      final firstDayOfMonth = DateTime(year, month, 1);
      final lastDayOfMonth = DateTime(year, month + 1, 0);
      final dailyData = await _reportRepository.getGroupedReport(
        type: 'day',
        start: _formatDate(firstDayOfMonth),
        end: _formatDate(lastDayOfMonth),
      );
      
      // Sort newest first for the list
      final sortedDaily = List<DailyReportModel>.from(dailyData);
      sortedDaily.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      dailyReports.assignAll(sortedDaily);

      // 2. Fetch Monthly Reports (for the selected year)
      final firstDayOfYear = DateTime(year, 1, 1);
      final lastDayOfYear = DateTime(year, 12, 31);
      final monthlyData = await _reportRepository.getGroupedReport(
        type: 'month',
        start: _formatDate(firstDayOfYear),
        end: _formatDate(lastDayOfYear),
      );
      
      // Convert e.tanggal to MonthlyReportModel
      monthlyReports.assignAll(monthlyData.map((e) => MonthlyReportModel(
        bulan: e.tanggal.month,
        totalPendapatan: e.totalPendapatan,
        totalTransaksi: e.totalTransaksi,
      )).toList());

      // 3. Fetch Yearly Reports (last 5 years)
      final firstDayOfFiveYears = DateTime(year - 4, 1, 1);
      final lastDayOfFiveYears = DateTime(year, 12, 31);
      final yearlyData = await _reportRepository.getGroupedReport(
        type: 'year',
        start: _formatDate(firstDayOfFiveYears),
        end: _formatDate(lastDayOfFiveYears),
      );

      yearlyReports.assignAll(yearlyData.map((e) => YearlyReportModel(
        tahun: e.tanggal.year,
        totalPendapatan: e.totalPendapatan,
        totalTransaksi: e.totalTransaksi,
      )).toList());

      // Update cache
      _cacheService.saveReports({
        'daily': dailyReports.map((e) => {
          'tanggal': e.tanggal.toIso8601String(),
          'total_pendapatan': e.totalPendapatan,
          'total_transaksi': e.totalTransaksi,
        }).toList(),
        'monthly': monthlyReports.map((e) => {
          'bulan': e.bulan,
          'total_pendapatan': e.totalPendapatan,
          'total_transaksi': e.totalTransaksi,
        }).toList(),
        'yearly': yearlyReports.map((e) => {
          'tahun': e.tahun,
          'total_pendapatan': e.totalPendapatan,
          'total_transaksi': e.totalTransaksi,
        }).toList(),
      });

    } catch (e) {
      if (!isSilent) {
        Get.toNamed(
          app_routes.Routes.ERROR,
          arguments: 'Gagal memuat laporan: $e',
        );
      }
    } finally {
      if (!isSilent) isLoading.value = false;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void setDate(DateTime? date) {
    if (date != null) {
      selectedDate.value = date;
      selectedYear.value = date.year;
      fetchAllReports();
    }
  }

  void setYear(int year) {
    selectedYear.value = year;
    // Keep the same month if possible, otherwise use January
    final currentMonth = selectedDate.value?.month ?? DateTime.now().month;
    selectedDate.value = DateTime(year, currentMonth, 1);
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
