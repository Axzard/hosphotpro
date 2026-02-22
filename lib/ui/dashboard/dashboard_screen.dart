import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'view_models/dashboard_view_model.dart';
import 'widgets/background_blobs.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/subscription_card.dart';
import 'widgets/dashboard_status_cards.dart';
import 'widgets/sales_chart.dart';
import 'widgets/dashboard_menu_grid.dart';

class DashboardScreen extends GetView<DashboardViewModel> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // Background Gradient Blobs
          const BackgroundBlobs(),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => controller.fetchDashboardData(isSilent: true),
              color: const Color(0xFF00C2FF),
              backgroundColor: const Color(0xFF1E293B),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardHeader(controller: controller),
                    const SizedBox(height: 32),
                    SubscriptionCard(controller: controller),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Ringkasan'),
                    const SizedBox(height: 16),
                    DashboardStatusCards(controller: controller),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Tren Penjualan'),
                    const SizedBox(height: 16),
                    SalesChart(controller: controller),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Menu Utama'),
                    const SizedBox(height: 16),
                    DashboardMenuGrid(controller: controller),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          
          // Only show full screen loader on VERY FIRST load
          Obx(() => controller.isLoading.value 
            ? Container(
                color: const Color(0xFF0F172A).withValues(alpha: 0.8),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00C2FF)),
                ),
              )
            : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
