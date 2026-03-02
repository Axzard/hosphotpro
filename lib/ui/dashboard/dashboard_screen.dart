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
import '../core/widgets/responsive_layout.dart';
import '../core/widgets/desktop_sidebar.dart';

class DashboardScreen extends GetView<DashboardViewModel> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: _buildMobileBody(context),
      desktopBody: _buildDesktopBody(context),
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          const BackgroundBlobs(),
          SafeArea(
            child: _buildMainContent(context),
          ),
          _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildDesktopBody(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          const BackgroundBlobs(),
          Row(
            children: [
              const DesktopSidebar(),
              Expanded(
                child: _buildMainContent(context),
              ),
            ],
          ),
          _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return RefreshIndicator(
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
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Obx(
      () => controller.isLoading.value
          ? Container(
              color: const Color(0xFF0F172A).withValues(alpha: 0.8),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00C2FF),
                ),
              ),
            )
          : const SizedBox.shrink(),
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
