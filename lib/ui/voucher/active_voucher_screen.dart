import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/widgets/desktop_page_wrapper.dart';
import '../core/widgets/responsive_layout.dart';
import '../core/controllers/navigation_controller.dart';
import '../../config/routing/app_routes.dart';
import 'view_models/voucher_view_model.dart';
import '../../domain/models/voucher_model.dart';

class ActiveVoucherScreen extends GetView<VoucherViewModel> {
  const ActiveVoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0A1118);
    const cardColor = Color(0xFF131E29);
    const accentColor = Color(0xFF00C2FF);

    return DesktopPageWrapper(
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, accentColor),
              _buildSearchBar(accentColor),
              Expanded(
                child: _buildVoucherList(accentColor, cardColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 24, right: 24, bottom: 8),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                if (Get.isRegistered<NavigationController>() && 
                    ResponsiveLayout.isDesktop(context)) {
                  Get.find<NavigationController>().setIndexByRoute(Routes.DASHBOARD);
                } else {
                  Get.back();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voucher Aktif',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'DAFTAR VOUCHER AKTIF',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: accentColor.withValues(alpha: 0.6),
                    letterSpacing: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Obx(() {
        return TextField(
          onChanged: (val) => controller.searchQuery.value = val,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Cari voucher aktif (kode / user profile)...',
            hintStyle: GoogleFonts.plusJakartaSans(
              color: Colors.white38,
              fontSize: 13,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF00C2FF),
              size: 20,
            ),
            suffixIcon: controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white38,
                      size: 18,
                    ),
                    onPressed: () {
                      controller.searchQuery.value = '';
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF00C2FF),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildVoucherList(Color accentColor, Color cardColor) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF00C2FF)),
        );
      }

      final activeList = controller.activeVouchers;

      if (activeList.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => controller.refreshData(),
          color: const Color(0xFF00C2FF),
          backgroundColor: const Color(0xFF131E29),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off_rounded,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada voucher yang aktif',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshData(),
        color: const Color(0xFF00C2FF),
        backgroundColor: const Color(0xFF131E29),
        child: ListView.builder(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 10,
            bottom: 80,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: activeList.length,
          itemBuilder: (context, index) {
            final voucher = activeList[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildVoucherCard(voucher, cardColor, accentColor),
            );
          },
        ),
      );
    });
  }

  Widget _buildVoucherCard(
    VoucherModel voucher,
    Color cardColor,
    Color accentColor,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return GestureDetector(
      onTap: () => controller.navigateToDetail(voucher),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_circle_rounded,
                    color: accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.namaPaket.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'User: ${voucher.kodeVoucher}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: accentColor.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (voucher.dnsLogin != null &&
                          voucher.dnsLogin!.isNotEmpty)
                        Text(
                          'DNS: ${voucher.dnsLogin}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            color: Colors.white54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.greenAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'AKTIF',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.white.withValues(alpha: 0.05)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currencyFormat.format(voucher.harga),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white38,
                  size: 14,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
