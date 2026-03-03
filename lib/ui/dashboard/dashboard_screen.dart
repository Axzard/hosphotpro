import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'view_models/dashboard_view_model.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/subscription_card.dart';
import 'widgets/dashboard_status_cards.dart';
import 'widgets/sales_chart.dart';
import 'widgets/dashboard_menu_grid.dart';
import '../core/widgets/desktop_page_wrapper.dart';
import '../core/widgets/responsive_layout.dart';
import '../core/widgets/responsive_max_width.dart';

class DashboardScreen extends GetView<DashboardViewModel> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DesktopPageWrapper(
      child: Stack(
        children: [
          SafeArea(
            child: _buildMainContent(context),
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
      child: ResponsiveMaxWidth(
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
              if (!ResponsiveLayout.isDesktop(context)) ...[
                _buildSectionTitle('Menu Utama'),
                const SizedBox(height: 16),
                DashboardMenuGrid(controller: controller),
                const SizedBox(height: 48),
              ],
            ],
          ),
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
