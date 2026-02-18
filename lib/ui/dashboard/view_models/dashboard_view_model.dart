import 'package:get/get.dart';
import '../../../config/routing/app_routes.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../domain/models/router_repository.dart';
import '../../../domain/models/voucher_repository.dart';
import '../../../domain/models/subscription_repository.dart';
import '../../../domain/models/auth_repository.dart';
import '../../../core/services/websocket_service.dart';

class DashboardViewModel extends GetxController {
  // Repositories
  final RouterRepository _routerRepository = Get.find<RouterRepository>();
  final VoucherRepository _voucherRepository = Get.find<VoucherRepository>();
  final SubscriptionRepository _subscriptionRepository = Get.find<SubscriptionRepository>();
  final WebSocketService _webSocketService = Get.find<WebSocketService>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // Observables
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

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
    _initRealtimeListeners();
  }

  void _initRealtimeListeners() {
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
      // Fetch Router Count (Initial)
      final routers = await _routerRepository.getRouters();
      totalRouterCount.value = routers.length;
      // Assume all are offline initially or wait for WS
      // onlineRouterCount.value = 0; 

      // Fetch Voucher Count (Initial)
      if (routers.isNotEmpty) {
        final idRouter = int.tryParse(routers.first.id) ?? 0;
        final vouchers = await _voucherRepository.getVouchersByRouter(idRouter);
        voucherCount.value = vouchers.length;
      } else {
        voucherCount.value = 0;
      }

      // Fetch Subscription Status
      final subscriptions = await _subscriptionRepository.getMySubscriptions();

      // Find active subscription
      final activeSub = subscriptions.firstWhereOrNull((sub) => sub.isActive);

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

      // Initial active user count can be 0 or fetched via API if available.
      // WebSocket will update it shortly.
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
}
