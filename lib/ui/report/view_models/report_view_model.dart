import 'dart:async';
import 'package:get/get.dart';
import '../../../domain/repositories/report_repository.dart';
import '../../../domain/models/report_model.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/error_utils.dart';
import '../../../core/services/websocket_service.dart';
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

  List<DailyReportModel> get filteredDailyReports {
    if (selectedDate.value == null) return dailyReports;
    final date = selectedDate.value!;
    return dailyReports
        .where(
          (e) =>
              e.tanggal.year == date.year &&
              e.tanggal.month == date.month &&
              e.tanggal.day == date.day,
        )
        .toList();
  }

  List<MonthlyReportModel> get filteredMonthlyReports {
    if (selectedDate.value == null) return monthlyReports;
    final date = selectedDate.value!;
    return monthlyReports.where((e) => e.bulan == date.month).toList();
  }

  final selectedDate = Rxn<DateTime>();
  final selectedYear = DateTime.now().year.obs;

  StreamSubscription? _refreshSub;

  @override
  void onInit() {
    super.onInit();
    final dashboardVM = Get.find<DashboardViewModel>();

    ever(dashboardVM.isActiveSubscription, (bool isActive) {
      if (isActive && dailyReports.isEmpty) {
        fetchAllReports();
      }
    });

    loadCachedData();
    fetchAllReports();
    _initRealtimeListeners();
  }

  Future<void> loadCachedData() async {
    try {
      final cached = _cacheService.getReports();

      if (cached != null) {
        if (cached['daily'] != null) {
          final list = (cached['daily'] as List)
              .map(
                (e) => DailyReportApiModel.fromJson(
                  e as Map<String, dynamic>,
                ).toDomain(),
              )
              .toList();
          dailyReports.assignAll(list);
        }
      }
    } catch (e) {
      print('[ReportVM] Error loading cache: $e');
    }
  }

  void _initRealtimeListeners() {
    _refreshSub = _webSocketService.eventStream.listen((eventData) {
      final event = (eventData['event'] ?? '').toString().toLowerCase();
      final data = eventData['data'];

      // Refresh laporan saat ada voucher yang menjadi aktif
      if (event == 'voucher:aktif' || event == 'voucher_aktif') {
        fetchAllReports(isSilent: true);
        return;
      }

      // Periksa event voucher:updated apakah statusnya aktif
      if ((event == 'voucher:updated' || event == 'voucher_updated') && data != null) {
        final statusStr = (data['status_voucher'] ?? '').toString().toLowerCase();
        if (statusStr == 'aktif') {
          fetchAllReports(isSilent: true);
        }
        return;
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

      final dashboardData = await _reportRepository.getDashboardReport(
        year: year,
        month: month,
      );

      if (dashboardData != null) {
        final sortedDaily = List<DailyReportModel>.from(dashboardData.perHari);
        sortedDaily.sort((a, b) => b.tanggal.compareTo(a.tanggal));
        dailyReports.assignAll(sortedDaily);

        monthlyReports.assignAll(dashboardData.perBulan);

        yearlyReports.assignAll(dashboardData.perTahun);

        _cacheService.saveReports({
          'daily': dailyReports
              .map(
                (e) => {
                  'tanggal': e.tanggal.toIso8601String(),
                  'total_pendapatan': e.totalPendapatan,
                  'total_transaksi': e.totalTransaksi,
                },
              )
              .toList(),
          'monthly': monthlyReports
              .map(
                (e) => {
                  'bulan': e.bulan,
                  'total_pendapatan': e.totalPendapatan,
                  'total_transaksi': e.totalTransaksi,
                },
              )
              .toList(),
          'yearly': yearlyReports
              .map(
                (e) => {
                  'tahun': e.tahun,
                  'total_pendapatan': e.totalPendapatan,
                  'total_transaksi': e.totalTransaksi,
                },
              )
              .toList(),
        });
      }
    } catch (e) {
      print('[ReportVM] fetchAllReports error: $e');
      final hasCachedData = dailyReports.isNotEmpty ||
          monthlyReports.isNotEmpty ||
          yearlyReports.isNotEmpty;

      if (isSilent) return; // Silent call — tidak tampilkan apapun saat error

      if (ErrorUtils.isNetworkError(e)) {
        if (!hasCachedData) {
          SnackbarUtils.showError(
            'Koneksi Lambat',
            'Gagal memuat laporan. Periksa koneksi internet Anda.',
          );
        }
        // Jika ada cache, biarkan silent — data lama masih ditampilkan
      } else if (ErrorUtils.isServerError(e)) {
        SnackbarUtils.showError(
          'Server Bermasalah',
          'Server sedang mengalami gangguan. Data laporan mungkin belum terbaru.',
        );
      } else if (!hasCachedData) {
        SnackbarUtils.showError(
          'Gagal Memuat',
          'Terjadi kesalahan saat memuat laporan.',
        );
      }
    } finally {
      if (!isSilent) isLoading.value = false;
    }
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
        SnackbarUtils.showError('Gagal', 'Gagal memperbarui laporan');
      }
    } catch (e) {
      SnackbarUtils.showError('Gagal', 'Gagal memperbarui laporan: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
