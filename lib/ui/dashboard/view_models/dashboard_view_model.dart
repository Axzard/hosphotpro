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
import '../../../core/services/session_service.dart';
import '../../../domain/models/router_model.dart';
import '../../../domain/models/user_subscription_model.dart';
import '../../../domain/models/auth_model.dart';
import '../../../domain/models/voucher_model.dart';
import '../../../data/services/token_service.dart';
import '../../../core/services/cache_service.dart';
import '../../../data/model/report_api_model.dart';

class DashboardViewModel extends GetxController {
  final RouterRepository _routerRepository = Get.find<RouterRepository>();
  final VoucherRepository _voucherRepository = Get.find<VoucherRepository>();
  final SubscriptionRepository _subscriptionRepository =
      Get.find<SubscriptionRepository>();
  final ReportRepository _reportRepository = Get.find<ReportRepository>();
  final WebSocketService _webSocketService = Get.find<WebSocketService>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final TokenService _tokenService = Get.find<TokenService>();
  final SessionService _sessionService = Get.find<SessionService>();
  final CacheService _cacheService = Get.find<CacheService>();

  final Rxn<RouterModel> selectedRouter = Rxn<RouterModel>();
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

    loadCachedData();
    fetchDashboardData(isInitial: true);
    _initRealtimeListeners();

    ever(selectedRouter, (router) {
      if (_isInitialLoad.value) return;
      if (router != null) {
        _sessionService.setRouterId(router.id);
      }
      _throttledFetch();
    });
  }

  void loadCachedData() {
    final cachedData = _cacheService.getDashboard();
    if (cachedData != null) {
      try {
        if (cachedData['report_summary'] != null) {
          final apiModel = ReportDashboardApiModel.fromJson(
            cachedData['report_summary'],
          );
          reportSummary.value = apiModel.toDomain();
        }
        totalIncomeToday.value =
            (cachedData['total_income_today'] as num?)?.toDouble() ?? 0.0;
        totalTransactionsToday.value =
            cachedData['total_transactions_today'] as int? ?? 0;
        activeUserCount.value = cachedData['active_user_count'] as int? ?? 0;
        voucherCount.value = cachedData['voucher_count'] as int? ?? 0;
        hotspotCount.value = cachedData['hotspot_count'] as int? ?? 0;
        voucherPackageCount.value =
            cachedData['voucher_package_count'] as int? ?? 0;
      } catch (e) {
        print('[DashboardVM] Error loading cache: $e');
      }
    }
  }

  Timer? _activeUserThrottle;

  void _throttledActiveUserFetch() {
    if (_activeUserThrottle?.isActive ?? false) return;
    _activeUserThrottle = Timer(const Duration(seconds: 3), () async {
      try {
        final activeVouchers = await _voucherRepository.getActiveVouchers();

        activeUserCount.value = activeVouchers.length;
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

            if (voucherCount.value > 0) voucherCount.value -= 1;
          } else if (event == 'voucher:activated') {
            if (harga > 0) totalIncomeToday.value += harga;
            totalTransactionsToday.value += 1;
          }

          _throttledActiveUserFetch();
          _throttledFetch();
        }
      }

      if (event == 'voucher:created') {
        voucherCount.value += 1;
      }
      if (event == 'voucher:bulkcreated') {
        final data = eventData['data'];
        if (data is Map) {
          final listData = data['data'] as List?;
          if (listData != null) {
            voucherCount.value += listData.length;
          }
        }
      }
      if (event == 'voucher:deleted') {
        if (voucherCount.value > 0) voucherCount.value -= 1;
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
        onlineRouterCount.value = status['router_count'] as int;
      }

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

      final routersList = results[0] as List<RouterModel>;
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

      double income = dailyReport?.totalPendapatan ?? 0;
      int transactions = dailyReport?.totalTransaksi ?? 0;

      if (income == 0 && transactions == 0 && reports != null) {
        final today = DateTime.now();
        final match = reports.perHari.firstWhereOrNull(
          (e) =>
              e.tanggal.year == today.year &&
              e.tanggal.month == today.month &&
              e.tanggal.day == today.day,
        );
        if (match != null) {
          income = match.totalPendapatan;
          transactions = match.totalTransaksi;
        }
      }

      totalIncomeToday.value = income;
      totalTransactionsToday.value = transactions;

      if (activeVouchers != null) {
        activeUserCount.value = activeVouchers.length;
        print(
          '[DashboardVM] Initialized Active Vouchers: ${activeUserCount.value}',
        );
      }

      totalRouterCount.value = routersList.length;
      onlineRouterCount.value = routersList
          .where((r) => r.statusRouter == 'aktif')
          .length;

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

      if (selectedRouter.value == null) {
        final savedRouterId = _sessionService.selectedRouterId.value;
        if (savedRouterId != null && savedRouterId != 'all') {
          selectedRouter.value =
              routersList.firstWhereOrNull((r) => r.id == savedRouterId) ??
              RouterModel.semua;
        } else {
          selectedRouter.value = RouterModel.semua;
        }
      }

      _fetchVoucherCountInBackground(selectedRouter.value!);

      _cacheService.saveDashboard({
        'report_summary': reports == null
            ? null
            : {
                'data': {
                  'perHari': reports.perHari
                      .map(
                        (e) => {
                          'tanggal': e.tanggal.toIso8601String(),
                          'total_pendapatan': e.totalPendapatan,
                          'total_transaksi': e.totalTransaksi,
                        },
                      )
                      .toList(),
                  'perBulan': reports.perBulan
                      .map(
                        (e) => {
                          'bulan': e.bulan,
                          'total_pendapatan': e.totalPendapatan,
                          'total_transaksi': e.totalTransaksi,
                        },
                      )
                      .toList(),
                  'perTahun': reports.perTahun
                      .map(
                        (e) => {
                          'tahun': e.tahun,
                          'total_pendapatan': e.totalPendapatan,
                          'total_transaksi': e.totalTransaksi,
                        },
                      )
                      .toList(),
                  'summary': {
                    'total_pendapatan': reports.totalIncome,
                    'total_transaksi': reports.totalTransactions,
                  },
                },
              },
        'total_income_today': totalIncomeToday.value,
        'total_transactions_today': totalTransactionsToday.value,
        'active_user_count': activeUserCount.value,
        'voucher_count': voucherCount.value,
        'hotspot_count': hotspotCount.value,
        'voucher_package_count': voucherPackageCount.value,
      });
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
      final allPackages = await _voucherRepository.getAllVoucherPackages();
      voucherPackageCount.value = allPackages.length;

      if (router.id == 'all') {
        final hotspotsList = await _routerRepository.getAllHotspots();
        hotspotCount.value = hotspotsList.length;
      } else {
        final idRouter = int.tryParse(router.id) ?? 0;
        final hotspotsList = await _routerRepository.getHotspots(idRouter);
        hotspotCount.value = hotspotsList.length;
      }

      final paketIds = allPackages
          .map((p) => p.id)
          .whereType<int>()
          .where((id) => id > 0)
          .toList();

      if (paketIds.isNotEmpty) {
        final allVouchers = await _voucherRepository.getAllVouchersByPackages(
          paketIds,
        );

        voucherCount.value = allVouchers
            .where((v) => v.statusVoucher == VoucherStatus.stok)
            .length;

        print(
          '[DashboardVM] Voucher stok: ${voucherCount.value} dari ${allVouchers.length} total',
        );
      } else {
        voucherCount.value = 0;
      }

      final activeVouchersList = await _voucherRepository.getActiveVouchers();
      activeUserCount.value = activeVouchersList.length;
      print('[DashboardVM] Active Vouchers: ${activeUserCount.value}');
    } catch (e) {
      print('[DashboardVM] Error background fetch: $e');
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
