import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'view_models/subscription_view_model.dart';
import '../auth/widgets/auth_widgets.dart';
import 'package_detail_screen.dart';

class PackageListScreen extends GetView<SubscriptionViewModel> {
  const PackageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: Colors.cyan));
                }

                if (controller.packages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Tidak ada paket tersedia',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadPackages,
                  color: Colors.cyan,
                  backgroundColor: const Color(0xFF1E293B),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    itemCount: controller.packages.length,
                    itemBuilder: (context, index) {
                      final package = controller.packages[index];
                      final isCurrentPackage =
                          controller.currentSubscription.value?.packageId == package.id;

                      // Mapping features from model
                      final features = [
                        PackageFeature(
                          icon: Icons.router_outlined,
                          text: 'Batas Router: ${package.maxRouters}',
                        ),
                        PackageFeature(
                          icon: Icons.confirmation_number_outlined,
                          text: 'Batas Voucher: ${NumberFormat('#,###').format(package.maxVouchers)}',
                        ),
                        PackageFeature(
                          icon: Icons.calendar_today_outlined,
                          text: 'Masa Aktif: ${package.durationDays} Hari',
                        ),
                      ];

                      // Add extra features based on name for visual parity with design
                      if (package.name.toLowerCase().contains('pro') || package.name.toLowerCase().contains('bisnis')) {
                         features.add(PackageFeature(icon: Icons.speed, text: 'Kecepatan: 100 Mbps'));
                         features.add(PackageFeature(icon: Icons.support_agent, text: 'Dukungan Prioritas 24/7'));
                      }

                      return SubscriptionPackageCard(
                        name: 'Paket ${package.name}',
                        price: currencyFormat.format(package.price),
                        duration: package.durationDays == 30 ? 'Bulan' : '${package.durationDays} Hari',
                        features: features,
                        isPopuler: package.name.toLowerCase().contains('pro'),
                        isSelected: isCurrentPackage,
                        isLoading: controller.isProcessingPayment.value,
                        onBuy: () {
                          // Ensure SubscriptionViewModel is available
                          if (!Get.isRegistered<SubscriptionViewModel>()) {
                            Get.put(SubscriptionViewModel(Get.find()));
                          }
                          Get.to(() => const PackageDetailScreen(), arguments: package);
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.cyan,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Paket Langganan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'NIKMATI LAYANAN INTERNET TERBAIK',
                style: TextStyle(
                  color: Colors.cyan.withOpacity(0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
