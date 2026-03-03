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

      final dashboardReport = await _reportRepository.getDashboardReport(
        year: year,
        month: month,
      );

      if (dashboardReport != null) {
        // Sort newest first
        final sortedDaily = dashboardReport.perHari;
        sortedDaily.sort((a, b) => b.tanggal.compareTo(a.tanggal));
        
        dailyReports.assignAll(sortedDaily);
        monthlyReports.assignAll(dashboardReport.perBulan);
        yearlyReports.assignAll(dashboardReport.perTahun);

        // Save to cache (we need raw data or reconstruct map)
        _cacheService.saveReports({
          'daily': dashboardReport.perHari.map((e) => {
            'tanggal': e.tanggal.toIso8601String(),
            'total_pendapatan': e.totalPendapatan,
            'total_transaksi': e.totalTransaksi,
          }).toList(),
          'monthly': dashboardReport.perBulan.map((e) => {
            'bulan': e.bulan,
            'total_pendapatan': e.totalPendapatan,
            'total_transaksi': e.totalTransaksi,
          }).toList(),
          'yearly': dashboardReport.perTahun.map((e) => {
            'tahun': e.tahun,
            'total_pendapatan': e.totalPendapatan,
            'total_transaksi': e.totalTransaksi,
          }).toList(),
        });
      }
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
