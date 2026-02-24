import 'dart:async';
import 'package:get/get.dart';
import '../../../config/routing/app_routes.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../domain/repositories/router_repository.dart';
import '../../../domain/repositories/voucher_repository.dart';
import '../../../domain/repositories/subscription_repository.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/report_repository.dart';
import '../../../domain/models/report_model.dart';
import '../../../core/services/websocket_service.dart';
import '../../../core/services/selection_service.dart';
import '../../../domain/models/router_model.dart';
import '../../../domain/models/user_subscription_model.dart';
import '../../../domain/models/auth_model.dart';
import '../../../domain/models/voucher_model.dart';
import '../../../domain/models/voucher_package_model.dart';
import '../../../data/services/token_service.dart';

class DashboardViewModel extends GetxController {
  final RouterRepository _routerRepository = Get.find<RouterRepository>();
  final VoucherRepository _voucherRepository = Get.find<VoucherRepository>();
  final SubscriptionRepository _subscriptionRepository = Get.find<SubscriptionRepository>();
  final ReportRepository _reportRepository = Get.find<ReportRepository>();
  final WebSocketService _webSocketService = Get.find<WebSocketService>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final _selectionService = Get.find<SelectionService>();
  final TokenService _tokenService = Get.find<TokenService>();

  Rxn<RouterModel> get selectedRouter => _selectionService.selectedRouter;
  final subscriptionStatus = 'Tidak Ada Langganan'.obs;
  final subscriptionStatusEnum = SubscriptionStatus.none.obs;
  final totalRouterCount = 0.obs;
  final onlineRouterCount = 0.obs;
  final hotspotCount = 0.obs;
  final voucherPackageCount = 0.obs;
  final voucherCount = 0.obs;
  final activeUserCount = 0.obs;
  final username = 'Admin'.obs;
  final expiryDate = Rxn<DateTime>();
  final isActiveSubscription = false.obs;
  final packageName = 'Tidak Ada Langganan'.obs;
  final isLoading = true.obs;

  final reportSummary = Rxn<ReportDashboardModel>();
  final totalIncomeToday = 0.0.obs;
  final totalTransactionsToday = 0.obs;

  final _isInitialLoad = true.obs;
  DateTime? _lastFetchTime;
  Timer? _throttleTimer;

  final cpuLoad = 0.0.obs;
  final memoryUsage = 0.0.obs;

  StreamSubscription? _refreshSub;

  @override
  void onInit() {
    super.onInit();

    final storedUsername = _tokenService.getUsername();
    if (storedUsername != null) {
      username.value = storedUsername;
    }

    fetchDashboardData(isInitial: true);
    _initRealtimeListeners();

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

        final filtered = activeVouchers
            .where((v) => v.statusVoucher == VoucherStatus.aktif)
            .toList();
        activeUserCount.value = filtered.length;
      } catch (e) {}
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

      if (event == 'voucher:sold' ||
          event == 'voucher:activated' ||
          event == 'voucher:updated') {
        final data = eventData['data'];
        if (data is Map) {
          final harga = (data['harga'] is num)
              ? (data['harga'] as num).toDouble()
              : 0.0;

          if (event == 'voucher:sold') {
            totalIncomeToday.value += harga;
            totalTransactionsToday.value += 1;
          } else if (event == 'voucher:activated') {
            if (harga > 0) totalIncomeToday.value += harga;
            totalTransactionsToday.value += 1;
          }

          _throttledActiveUserFetch();
          _throttledFetch();
        }
      }

      if (_lastFetchTime == null ||
          DateTime.now().difference(_lastFetchTime!) >
              const Duration(seconds: 3)) {
        fetchDashboardData(isSilent: true);
      }
    });

    ever(_webSocketService.activeUserStats, (dynamic stats) {
      if (stats is Map) {
        final count =
            stats['count'] ??
            stats['total'] ??
            stats['activeUsers'] ??
            stats['online'] ??
            stats['user_aktif'] ??
            stats['user_online'];
        if (count is num) {
          final val = count.toInt();

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
        // Assume 'router_count' here refers to online ones based on emitting logic
        onlineRouterCount.value = status['router_count'] as int;
      }
      
      // If we have total routers but online count is missing, we might want a fallback or refresh
      if (totalRouterCount.value > 0 && !status.containsKey('online_count')) {
        _throttledFetch();
      }
    });
  }

  List<double> get dailyIncomeData {
    final reports = reportSummary.value;
    if (reports == null || reports.perHari.isEmpty) return [];

    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    final daysInMonth = DateTime(year, month + 1, 0).day;

    return List.generate(daysInMonth, (index) {
      final day = index + 1;
      final report = reports.perHari.firstWhereOrNull(
        (e) => e.tanggal.day == day,
      );
      return report?.totalPendapatan ?? 0.0;
    });
  }

  List<double> get cumulativeIncomeData {
    final reports = reportSummary.value;
    if (reports == null || reports.perHari.isEmpty) return [];

    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;

    double runningTotal = 0;
    return List.generate(daysInMonth, (index) {
      final day = index + 1;
      final report = reports.perHari.firstWhereOrNull(
        (e) => e.tanggal.day == day,
      );
      runningTotal += report?.totalPendapatan ?? 0.0;
      return runningTotal;
    });
  }

  Future<void> fetchDashboardData({
    bool isInitial = false,
    bool isSilent = false,
  }) async {
    final nowTime = DateTime.now();
    final isDataOld =
        _lastFetchTime == null ||
        nowTime.difference(_lastFetchTime!).inMinutes > 5;
    final hasNoData = reportSummary.value == null;

    if (isInitial && (isDataOld || hasNoData)) {
      isLoading.value = true;
    }

    _lastFetchTime = nowTime;

    try {
      final now = DateTime.now();

      final results = await Future.wait([
        _routerRepository.getRouters(),
        _subscriptionRepository.getMySubscriptions(),
        _reportRepository.getDashboardReport(year: now.year, month: now.month),
        _authRepository.getProfile(),
        _reportRepository.getDailyReportHarian(
          tahun: now.year,
          bulan: now.month,
          tgl: now.day,
        ),
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
      
      // Fallback: If dailyReport is missing or zero, try to find today's data in the reportSummary (perHari)
      double income = dailyReport?.totalPendapatan ?? 0;
      int transactions = dailyReport?.totalTransaksi ?? 0;

      if (income == 0 && transactions == 0 && reports != null) {
        final today = DateTime.now();
        final match = reports.perHari.firstWhereOrNull(
          (e) => e.tanggal.year == today.year && 
                 e.tanggal.month == today.month && 
                 e.tanggal.day == today.day
        );
        if (match != null) {
          income = match.totalPendapatan;
          transactions = match.totalTransaksi;
        }
      }

      totalIncomeToday.value = income;
      totalTransactionsToday.value = transactions;

      if (activeVouchers != null && activeVouchers.isNotEmpty) {
        final filteredAktif = activeVouchers
            .where((v) => v.statusVoucher == VoucherStatus.aktif)
            .toList();
        activeUserCount.value = filteredAktif.length;
        print('[DashboardVM] Initialized Active Users: ${activeUserCount.value}');
      }

      totalRouterCount.value = routers.length;
      onlineRouterCount.value = routers.where((r) => r.statusRouter == 'aktif').length;

      UserSubscriptionModel? activeSub;
      try {
        activeSub = subscriptions.firstWhere((sub) => sub.isActive);
        isActiveSubscription.value = true;
      } catch (_) {
        activeSub = subscriptions.isNotEmpty ? subscriptions.first : null;
        isActiveSubscription.value = activeSub?.isActive ?? false;
      }

      if (activeSub != null) {
        subscriptionStatus.value = activeSub.status.displayName;
        subscriptionStatusEnum.value = activeSub.status;
        expiryDate.value = activeSub.tanggalBerakhir;
        packageName.value = activeSub.namaPaket;
      } else {
        subscriptionStatus.value = 'Tidak Ada Langganan';
        subscriptionStatusEnum.value = SubscriptionStatus.none;
        expiryDate.value = null;
        isActiveSubscription.value = false;
        packageName.value = 'Anda Belum Berlangganan';
      }

      final activeRouter =
          selectedRouter.value ?? (routers.isNotEmpty ? routers.first : null);
      if (activeRouter != null) {
        if (selectedRouter.value == null) {
          _selectionService.updateRouter(activeRouter);
        }

        _fetchVoucherCountInBackground(activeRouter);
      }
    } catch (e) {
      Get.toNamed(
        Routes.ERROR,
        arguments: 'Gagal memuat data dashboard, terjadi gangguan pada server.',
      );
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
      hotspotCount.value = hotspotsList.length;

      if (hotspotsList.isNotEmpty) {
        // Fetch vouchers and packages for all hotspots in parallel
        final voucherFutures = hotspotsList
            .map((h) => _voucherRepository.getVouchersByHotspot(h.idHotspot))
            .toList();
        
        final packageFutures = hotspotsList
            .map((h) => _voucherRepository.getVoucherPackages(h.idHotspot))
            .toList();

        final results = await Future.wait([
          Future.wait(voucherFutures),
          Future.wait(packageFutures),
        ]);

        final voucherGroups = results[0] as List<List<VoucherModel>>;
        final packageGroups = results[1] as List<List<VoucherPackageModel>>;

        final allVouchers = voucherGroups.expand((x) => x).toList();
        final allPackages = packageGroups.expand((x) => x).toList();

        voucherCount.value = allVouchers.length;
        voucherPackageCount.value = allPackages.length;

        final filteredAktif = allVouchers
            .where((v) => v.statusVoucher == VoucherStatus.aktif)
            .toList();
        if (activeUserCount.value == 0 && filteredAktif.isNotEmpty) {
          activeUserCount.value = filteredAktif.length;
          print(
            '[DashboardVM] Active Users (Fallback from Hotspots): ${activeUserCount.value}',
          );
        }
      } else {
        voucherCount.value = 0;
        voucherPackageCount.value = 0;
      }
    } catch (e) {
      print('[DashboardVM] Error background fetch: $e');
    }
  }

  void navigateToRouters() => Get.toNamed('/mikrotik-routers');
  void navigateToVouchers() => Get.toNamed(Routes.VOUCHERS);
  void navigateToProfile() => Get.toNamed(Routes.PROFILE);
  void navigateToSubscriptionStatus() => Get.toNamed(Routes.SUBSCRIPTION_STATUS);
  void navigateToPackageList() => Get.toNamed(Routes.PACKAGES);
  void navigateToHotspots() => Get.toNamed(Routes.HOTSPOTS);

  void navigateToVoucherPackages() => Get.toNamed(Routes.VOUCHER_PACKAGES);

  void navigateToReports() {
    Get.toNamed(Routes.TRANSACTIONS);
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
