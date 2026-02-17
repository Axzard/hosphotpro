import 'package:get/get.dart';
import '../../../config/routing/app_routes.dart';

class DashboardViewModel extends GetxController {
  // final AuthRepository _authRepository = Get.find<AuthRepository>();

  final subscriptionStatus = 'Active'.obs;
  final routerCount = 0.obs;
  final voucherCount = 0.obs;
  final expiryDate = DateTime.now().add(const Duration(days: 30)).obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Simulate API

    // Mock data
    routerCount.value = 5;
    voucherCount.value = 120;
    subscriptionStatus.value = 'Active';
    expiryDate.value = DateTime.now().add(const Duration(days: 28));
    
    isLoading.value = false;
  }

  void navigateToRouters() {
    // Get.toNamed(Routes.ROUTERS);
    Get.snackbar('Info', 'Router feature coming soon');
  }

  void navigateToVouchers() {
    Get.toNamed(Routes.VOUCHERS);
  }

  void navigateToProfile() {
    Get.toNamed(Routes.PROFILE);
  }

  void navigateToSubscriptionStatus() {
    Get.toNamed(Routes.SUBSCRIPTION_STATUS);
  }

  void navigateToPackageList() {
    Get.toNamed(Routes.PACKAGES);
  }

  void navigateToTransactions() {
    Get.snackbar('Informasi', 'Fitur riwayat transaksi akan segera hadir');
  }
}
