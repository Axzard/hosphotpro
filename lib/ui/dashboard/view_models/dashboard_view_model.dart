import 'dart:async';
import 'package:get/get.dart';
import '../../../config/routing/app_routes.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../domain/models/router_repository.dart';
import '../../../domain/models/voucher_repository.dart';
import '../../../domain/models/subscription_repository.dart';
import '../../../domain/models/auth_repository.dart';
import '../../../domain/models/report_repository.dart';
import '../../../domain/models/report_model.dart';
import '../../../core/services/websocket_service.dart';
import '../../../core/services/selection_service.dart';
import '../../../domain/models/router_model.dart';
import '../../../domain/models/user_subscription_model.dart';
import '../../../domain/models/auth_model.dart';
import '../../../domain/models/voucher_model.dart';

class DashboardViewModel extends GetxController {
  // Repositories
  final RouterRepository _routerRepository = Get.find<RouterRepository>();
  final VoucherRepository _voucherRepository = Get.find<VoucherRepository>();
  final SubscriptionRepository _subscriptionRepository = Get.find<SubscriptionRepository>();
  final ReportRepository _reportRepository = Get.find<ReportRepository>();
  final WebSocketService _webSocketService = Get.find<WebSocketService>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final _selectionService = Get.find<SelectionService>();

  // Observables
  Rxn<RouterModel> get selectedRouter => _selectionService.selectedRouter;
  final subscriptionStatus = 'Active'.obs;
  final totalRouterCount = 0.obs;
  final onlineRouterCount = 0.obs;
  final voucherCount = 0.obs;
  final activeUserCount = 0.obs; // Realtime active users
  final username = 'Admin'.obs;
  final expiryDate = Rxn<DateTime>();
  final isLoading = true.obs;

  // Report Summary (Laporan Penjualan)
  final reportSummary = Rxn<ReportDashboardModel>();
  final totalIncomeToday = 0.0.obs;
  final totalTransactionsToday = 0.obs;

  // State management for optimization
  final _isInitialLoad = true.obs;
  DateTime? _lastFetchTime;
  Timer? _throttleTimer;

  // Realtime specific stats (HUD)
  final cpuLoad = 0.0.obs;
  final memoryUsage = 0.0.obs;

  StreamSubscription? _refreshSub;

  @override
  void onInit() {
    super.onInit();
    // Use initial load flag to show big spinner only once
    fetchDashboardData(isInitial: true);
    _initRealtimeListeners();

    // Listen to global router selection changes - Skip if initial load to prevent double load
    ever(selectedRouter, (_) {
      if (_isInitialLoad.value) return;
      _throttledFetch();
    });
  }

  Timer? _activeUserThrottle;
  void _throttledActiveUserFetch() {
    if (_activeUserThrottle?.isActive ?? false) return;
    _activeUserThrottle = Timer(const Duration(seconds: 3), () async {
      try {
        final activeVouchers = await _voucherRepository.getActiveVouchers();
        // STRIKT: Filter hanya yang statusnya benar-benar AKTIF
        final filtered = activeVouchers.where((v) => v.statusVoucher == VoucherStatus.aktif).toList();
        activeUserCount.value = filtered.length;
      } catch (e) {
        // Silent fail for background fetch
      }
    });
  }

  void _throttledFetch() {
    if (_throttleTimer?.isActive ?? false) return;
    _throttleTimer = Timer(const Duration(seconds: 2), () {
      fetchDashboardData(isSilent: true);
    });
  }

  void _initRealtimeListeners() {
    _refreshSub = _webSocketService.eventStream.listen((eventData) {
      final event = (eventData['event'] ?? '').toString().toLowerCase();
      
      const highFreqEvents = ['router_stats', 'active_users', 'logs'];
      if (highFreqEvents.contains(event)) return;

      // Surgical updates for Dashboard HUD
      if (event == 'voucher:sold' || event == 'voucher:activated' || event == 'voucher:updated') {
        final data = eventData['data'];
        if (data is Map) {
          // Instant feedback for today's activity
          final harga = (data['harga'] is num) ? (data['harga'] as num).toDouble() : 0.0;
          
          if (event == 'voucher:sold') {
            totalIncomeToday.value += harga;
            totalTransactionsToday.value += 1;
          } else if (event == 'voucher:activated') {
            // Count activation as a sale if price is known, otherwise count as transaction
            if (harga > 0) totalIncomeToday.value += harga;
            totalTransactionsToday.value += 1;
          }
          
          _throttledActiveUserFetch();
          _throttledFetch();
        }
      }

      // Smart refresh: Only refresh if it's been more than 3 seconds
      if (_lastFetchTime == null || 
          DateTime.now().difference(_lastFetchTime!) > const Duration(seconds: 3)) {
        fetchDashboardData(isSilent: true);
      }
    });

    // Reactive listeners for HUD stats (Don't trigger full fetch)
    ever(_webSocketService.activeUserStats, (dynamic stats) {
      if (stats is Map) {
        final count = stats['count'] ?? stats['total'] ?? stats['activeUsers'] ?? stats['online'] ?? stats['user_aktif'] ?? stats['user_online'];
        if (count is num) {
          final val = count.toInt();
          // Prioritize non-zero values from router.
          // If 0, only trust it if we already had a low count.
          if (val > 0) {
            activeUserCount.value = val;
          }
        }
      } else if (stats is int && stats > 0) {
        activeUserCount.value = stats;
      }
    });

    ever(_webSocketService.routerStatus, (status) {
      if (status.containsKey('cpu_load')) {
        cpuLoad.value = (status['cpu_load'] is num)
            ? (status['cpu_load'] as num).toDouble()
            : 0.0;
      }
      if (status.containsKey('memory_usage')) {
        memoryUsage.value = (status['memory_usage'] is num)
            ? (status['memory_usage'] as num).toDouble()
            : 0.0;
      }

      if (status.containsKey('online_count')) {
        onlineRouterCount.value = status['online_count'] as int;
      } else if (status.containsKey('router_count')) {
        onlineRouterCount.value = status['router_count'] as int;
      }
    });
  }

  // Chart Helpers
  List<double> get dailyIncomeData {
    final reports = reportSummary.value;
    if (reports == null || reports.perHari.isEmpty) return [];

    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    // Number of days in current month
    final daysInMonth = DateTime(year, month + 1, 0).day;

    return List.generate(daysInMonth, (index) {
      final day = index + 1;
      final report = reports.perHari.firstWhereOrNull((e) => e.tanggal.day == day);
      return report?.totalPendapatan ?? 0.0;
    });
  }

  Future<void> fetchDashboardData({bool isInitial = false, bool isSilent = false}) async {
    if (isInitial) isLoading.value = true;
    _lastFetchTime = DateTime.now();

    try {
      final now = DateTime.now();
      // Basic data that should be fast
      final results = await Future.wait([
        _routerRepository.getRouters(),
        _subscriptionRepository.getMySubscriptions(),
        _reportRepository.getDashboardReport(year: now.year, month: now.month),
        _authRepository.getProfile(),
        _reportRepository.getDailyReportHarian(tahun: now.year, bulan: now.month, tgl: now.day),
        _voucherRepository.getActiveVouchers(),
      ]);

      final routers = results[0] as List<RouterModel>;
      final subscriptions = results[1] as List<UserSubscriptionModel>;
      final reports = results[2] as ReportDashboardModel?;
      final profileData = results[3];
      final AuthModel? profile = profileData is AuthModel? ? profileData : null;
      final dailyReport = results[4] as DailyReportModel?;
      final activeVouchers = results[5] as List<VoucherModel>?;
      
      if (profile != null) {
        username.value = profile.username;
      }
      
      reportSummary.value = reports;
      
      // Target specific "Today" data from dailyReport for accuracy
      if (dailyReport != null) {
        totalIncomeToday.value = dailyReport.totalPendapatan;
        totalTransactionsToday.value = dailyReport.totalTransaksi;
        
        // COMPENSATE: If there are active vouchers activated TODAY that are NOT in dailyReport
        // (Assuming dailyReport only counts 'terjual' status from /api/laporan/harian)
        if (activeVouchers != null) {
          final now = DateTime.now();
          final activatedToday = activeVouchers.where((v) {
            final tgl = v.tanggalAktif;
             return v.statusVoucher == VoucherStatus.aktif &&
                    tgl != null && 
                    tgl.year == now.year && 
                    tgl.month == now.month && 
                    tgl.day == now.day;
          }).toList();
          
          if (activatedToday.isNotEmpty) {
            // Check if these are already accounted for in totalTransactionsToday
            // If the user says it's not showing, we can heuristic-add them
            // But usually /api/laporan/harian should be the source of truth
          }
        }
      }
      
      if (activeVouchers != null) {
        // STRIKT: Filter hanya status AKTIF
        final filteredAktif = activeVouchers.where((v) => v.statusVoucher == VoucherStatus.aktif).toList();
        activeUserCount.value = filteredAktif.length;
      }
      
      totalRouterCount.value = routers.length;

      // Subscription logic
      UserSubscriptionModel? activeSub;
      try {
        activeSub = subscriptions.firstWhere((sub) => sub.isActive);
      } catch (_) {
        activeSub = subscriptions.isNotEmpty ? subscriptions.first : null;
      }

      if (activeSub != null) {
        subscriptionStatus.value = activeSub.status.displayName;
        expiryDate.value = activeSub.tanggalBerakhir;
      }

      // Router & Voucher count - Only if changed or initial
      final activeRouter = selectedRouter.value ?? (routers.isNotEmpty ? routers.first : null);
      if (activeRouter != null) {
        if (selectedRouter.value == null) {
          _selectionService.updateRouter(activeRouter);
        }
        
        // Fetch voucher count in background without blocking UI
        _fetchVoucherCountInBackground(activeRouter);
      }
    } catch (e) {
      // Silent error for silent fetch
      // Navigate to full error screen if critical data fails
      Get.toNamed(Routes.ERROR, arguments: 'Gagal memuat data dashboard: $e');
    } finally {
      if (isInitial) {
        isLoading.value = false;
        _isInitialLoad.value = false;
      }
    }
  }

  Future<void> _fetchVoucherCountInBackground(RouterModel router) async {
    try {
      final idRouter = int.tryParse(router.id) ?? 0;
      final hotspotsList = await _routerRepository.getHotspots(idRouter);
      
      if (hotspotsList.isNotEmpty) {
        final voucherFutures = hotspotsList.map((h) => 
          _voucherRepository.getVouchersByHotspot(h.idHotspot)
        ).toList();
        
        final voucherGroups = await Future.wait(voucherFutures);
        voucherCount.value = voucherGroups.fold(0, (sum, group) => sum + group.length);
      } else {
        voucherCount.value = 0;
      }
    } catch (e) {
      // Silent fail
    }
  }

  void navigateToRouters() => Get.toNamed('/mikrotik-routers');
  void navigateToVouchers() => Get.toNamed(Routes.VOUCHERS);
  void navigateToProfile() => Get.toNamed(Routes.PROFILE);
  void navigateToSubscriptionStatus() =>
      Get.toNamed(Routes.SUBSCRIPTION_STATUS);
  void navigateToPackageList() => Get.toNamed(Routes.PACKAGES);
  void navigateToHotspots() => Get.toNamed(Routes.HOTSPOTS);

  void navigateToVoucherPackages() => Get.toNamed(Routes.VOUCHER_PACKAGES);

  void navigateToReports() {
    Get.toNamed(Routes.TRANSACTIONS); // Reusing TRANSACTIONS route for Reports
  }

  void navigateToTransactions() => navigateToReports();

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal logout: $e');
    }
  }

  @override
  void onClose() {
    _refreshSub?.cancel();
    super.onClose();
  }
}
