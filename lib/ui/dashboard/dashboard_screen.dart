import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'view_models/dashboard_view_model.dart';
import '../auth/widgets/auth_widgets.dart';

class DashboardScreen extends GetView<DashboardViewModel> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: Colors.cyan));
          }
          return RefreshIndicator(
            onRefresh: controller.fetchDashboardData,
            color: Colors.cyan,
            backgroundColor: const Color(0xFF1E293B),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildMenuGrid(),
                  _buildMenuGridSecondRow(),
                  const SizedBox(height: 40),
                  _buildTransactionSummary(),
                  const SizedBox(height: 30),
                  _buildStatusCards(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Halo, Admin',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'HOSPHOTPRO DASHBOARD',
          style: TextStyle(
            color: Colors.cyan.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DashboardMenuCard(
          icon: Icons.verified_user_outlined,
          label: 'Langganan',
          onTap: controller.navigateToSubscriptionStatus,
        ),
        DashboardMenuCard(
          icon: Icons.router,
          label: 'Router Mikrotik',
          onTap: controller.navigateToRouters,
        ),
        DashboardMenuCard(
          icon: Icons.print_outlined,
          label: 'Cetak Voucher',
          onTap: controller.navigateToVouchers,
        ),
      ],
    );
  }

  Widget _buildMenuGridSecondRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          DashboardMenuCard(
            icon: Icons.receipt_long_outlined,
            label: 'Transaksi',
            onTap: controller.navigateToTransactions,
          ),
          const SizedBox(width: 48),
          DashboardMenuCard(
            icon: Icons.shopping_cart_outlined,
            label: 'Paket Langganan',
            onTap: controller.navigateToPackageList,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ringkasan Transaksi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Data penjualan 7 hari terakhir',
                    style: TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.cyan.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.trending_up, color: Colors.cyan, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(40),
              _buildBar(60),
              _buildBar(50),
              _buildBar(90),
              _buildBar(70),
              _buildBar(110, isHighlighted: true),
              _buildBar(65),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem('TOTAL', 'Rp 2.450.000'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem('VOUCHERS TERJUAL', '142 Pcs'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, {bool isHighlighted = false}) {
    return Container(
      width: 35,
      height: height,
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.cyan : Colors.cyan.withOpacity(0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCards() {
    return Row(
      children: [
        const Expanded(
          child: DashboardStatCard(
            icon: Icons.sensors,
            title: 'Router Status',
            value: 'Online (3/3)',
            iconColor: Colors.greenAccent,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: DashboardStatCard(
            icon: Icons.people_outline,
            title: 'Aktif User',
            value: '${controller.voucherCount.value} Users',
            iconColor: Colors.cyanAccent,
          ),
        ),
      ],
    );
  }
}
