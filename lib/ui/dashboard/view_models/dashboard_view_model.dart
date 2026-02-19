import 'dart:async';
import 'package:get/get.dart';
import '../../../config/routing/app_routes.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../domain/models/router_repository.dart';
import '../../../domain/models/voucher_repository.dart';
import '../../../domain/models/subscription_repository.dart';
import '../../../domain/models/auth_repository.dart';
import '../../../core/services/websocket_service.dart';
import '../../../core/services/selection_service.dart';
import '../../../domain/models/router_model.dart';
import '../../../domain/models/user_subscription_model.dart';

class DashboardViewModel extends GetxController {
  // Repositories
  final RouterRepository _routerRepository = Get.find<RouterRepository>();
  final VoucherRepository _voucherRepository = Get.find<VoucherRepository>();
  final SubscriptionRepository _subscriptionRepository = Get.find<SubscriptionRepository>();
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

  // Realtime specific stats (optional, if UI needs them)
  final cpuLoad = 0.0.obs;
  final memoryUsage = 0.0.obs;

  StreamSubscription? _refreshSub;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
    _initRealtimeListeners();

    // Listen to global router selection changes
    ever(selectedRouter, (_) {
      fetchDashboardData();
    });
  }

  void _initRealtimeListeners() {
    print('🚀 [DashboardVM] Realtime listeners initialized');
    // Global data refresh via Event Bus
    _refreshSub = _webSocketService.eventStream.listen((eventData) {
      final event = (eventData['event'] ?? '').toString().toLowerCase();
      
      // Filter out high-frequency events that shouldn't trigger total refresh
      const highFreqEvents = ['router_stats', 'active_users', 'logs'];
      if (highFreqEvents.contains(event)) return;

      print('🏠 [DashboardVM] Refreshing due to Event: $event');
      fetchDashboardData();
    });

    // Keep reactive specific listeners for HUD stats

    // Listen to WebSocket active user stats
    ever(_webSocketService.activeUserStats, (stats) {
      if (stats.containsKey('count')) {
        activeUserCount.value = stats['count'] as int;
      }
    });

    // Listen to Router Status (e.g. CPU, Memory, or Router Count if aggregated)
    ever(_webSocketService.routerStatus, (status) {
      // Example: Update specific router stats if Dashboard shows them
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

      // If backend sends total connected routers
      if (status.containsKey('online_count')) {
        onlineRouterCount.value = status['online_count'] as int;
      } else if (status.containsKey('router_count')) {
        // Fallback for different payload structures
        onlineRouterCount.value = status['router_count'] as int;
      }
    });
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    try {
      // Parallel fetch using Future.wait to reduce loading time
      final results = await Future.wait([
        _routerRepository.getRouters(),
        _subscriptionRepository.getMySubscriptions(),
      ]);

      final routers = results[0] as List<RouterModel>;
      final subscriptions = results[1] as List<UserSubscriptionModel>;
      
      totalRouterCount.value = routers.length;

      // Fetch total Voucher Count for SELECTED router (aggregated from all its hotspots)
      final activeRouter = selectedRouter.value ?? (routers.isNotEmpty ? routers.first : null);
      if (activeRouter != null) {
        if (selectedRouter.value == null) {
          _selectionService.updateRouter(activeRouter);
        }
        
        final idRouter = int.tryParse(activeRouter.id) ?? 0;
        final hotspotsList = await _routerRepository.getHotspots(idRouter);
        
        if (hotspotsList.isNotEmpty) {
          // Parallel fetch vouchers for all hotspots in this router
          final voucherFutures = hotspotsList.map((h) => 
            _voucherRepository.getVouchersByHotspot(h.idHotspot)
          ).toList();
          
          final voucherGroups = await Future.wait(voucherFutures);
          int totalVouchers = 0;
          for (var group in voucherGroups) {
            totalVouchers += group.length;
          }
          voucherCount.value = totalVouchers;
        } else {
          voucherCount.value = 0;
        }
      } else {
        voucherCount.value = 0;
      }

      // Find active subscription
      UserSubscriptionModel? activeSub;
      try {
        activeSub = subscriptions.firstWhere((sub) => sub.isActive);
      } catch (_) {
        activeSub = null;
      }

      if (activeSub != null) {
        subscriptionStatus.value = activeSub.status.displayName;
        expiryDate.value = activeSub.tanggalBerakhir;
      } else if (subscriptions.isNotEmpty) {
        final latest = subscriptions.first;
        subscriptionStatus.value = latest.status.displayName;
        expiryDate.value = latest.tanggalBerakhir;
      } else {
        subscriptionStatus.value = 'Inactive';
        expiryDate.value = null;
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
    } finally {
      isLoading.value = false;
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

  void navigateToTransactions() {
    SnackbarUtils.showInfo(
      'Informasi',
      'Fitur riwayat transaksi akan segera hadir',
    );
  }

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
