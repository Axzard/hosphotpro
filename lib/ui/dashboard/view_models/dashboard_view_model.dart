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

  void _throttledFetch() {
    if (_throttleTimer?.isActive ?? false) return;
    _throttleTimer = Timer(const Duration(seconds: 2), () {
      fetchDashboardData(isSilent: true);
    });
  }

  void _initRealtimeListeners() {
    print('🚀 [DashboardVM] Realtime listeners initialized');
    _refreshSub = _webSocketService.eventStream.listen((eventData) {
      final event = (eventData['event'] ?? '').toString().toLowerCase();
      
      const highFreqEvents = ['router_stats', 'active_users', 'logs'];
      if (highFreqEvents.contains(event)) return;

      // Surgical updates for Dashboard HUD
      if (event == 'voucher:sold') {
        final data = eventData['data'];
        if (data is Map && data.containsKey('harga')) {
          final harga = (data['harga'] is num) ? (data['harga'] as num).toDouble() : 0.0;
          totalIncomeToday.value += harga;
          totalTransactionsToday.value += 1;
        }
      }

      // Smart refresh: Only refresh if it's been more than 3 seconds
      if (_lastFetchTime == null || 
          DateTime.now().difference(_lastFetchTime!) > const Duration(seconds: 3)) {
        print('🏠 [DashboardVM] Refreshing due to Event: $event');
        fetchDashboardData(isSilent: true);
      }
    });

    // Reactive listeners for HUD stats (Don't trigger full fetch)
    ever(_webSocketService.activeUserStats, (stats) {
      if (stats.containsKey('count')) {
        activeUserCount.value = stats['count'] as int;
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
      ]);

      final routers = results[0] as List<RouterModel>;
      final subscriptions = results[1] as List<UserSubscriptionModel>;
      final reports = results[2] as ReportDashboardModel?;
      
      reportSummary.value = reports;
      if (reports != null && reports.perHari.isNotEmpty) {
        final today = reports.perHari.first;
        totalIncomeToday.value = today.totalPendapatan;
        totalTransactionsToday.value = today.totalTransaksi;
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
      print('Error fetching dashboard data: $e');
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
      print('Error fetching voucher count: $e');
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
