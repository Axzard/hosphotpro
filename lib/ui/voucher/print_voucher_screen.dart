import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'view_models/voucher_view_model.dart';
import '../../domain/models/voucher_model.dart';
import '../../ui/voucher/widgets/create_voucher_sheet.dart';

class PrintVoucherScreen extends GetView<VoucherViewModel> {
  const PrintVoucherScreen({super.key});
  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0A1118);
    const cardColor = Color(0xFF131E29);
    const accentColor = Color(0xFF00C2FF);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: bgColor,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Get.bottomSheet(
              const CreateVoucherSheet(),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            );
          },
          backgroundColor: accentColor,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            'Buat Voucher',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(accentColor),
              _buildTabBar(accentColor),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildVoucherList(controller.stockVouchers, accentColor, cardColor, 'Belum ada voucher stok'),
                    _buildVoucherList(controller.soldVouchers, accentColor, cardColor, 'Belum ada voucher terjual'),
                    _buildVoucherList(controller.activeVouchers, accentColor, cardColor, 'Belum ada voucher aktif'),
                    _buildVoucherList(controller.expiredVouchers, accentColor, cardColor, 'Belum ada voucher expired'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(Color accentColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        indicator: BoxDecoration(
          color: accentColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'STOK'),
          Tab(text: 'TERJUAL'),
          Tab(text: 'AKTIF'),
          Tab(text: 'EXPIRED'),
        ],
      ),
    );
  }

  Widget _buildVoucherList(List<VoucherModel> items, Color accentColor, Color cardColor, String emptyMessage) {
    return Column(
      children: [
        _buildPackageFilter(accentColor),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF00C2FF)));
            }

            final filteredItems = _getFilteredItemsByMessage(emptyMessage);

            if (filteredItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                    const SizedBox(height: 16),
                    Text(
                      emptyMessage,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 16),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final voucher = filteredItems[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildVoucherCard(voucher, cardColor, accentColor),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPackageFilter(Color accentColor) {
    return Obx(() {
      if (controller.voucherPackages.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'FILTER PAKET',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white38,
                letterSpacing: 1.5,
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildFilterTab(
                  label: 'Semua Paket',
                  isSelected: controller.filterPaketId.value == null,
                  onTap: () => controller.setFilterPaket(null),
                  accentColor: accentColor,
                ),
                ...controller.voucherPackages.map((paket) => _buildFilterTab(
                      label: paket.namaPaket,
                      isSelected: controller.filterPaketId.value == paket.id,
                      onTap: () => controller.setFilterPaket(paket.id),
                      accentColor: accentColor,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    });
  }

  Widget _buildFilterTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color accentColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? accentColor.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? accentColor : Colors.white70,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 12,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<VoucherModel> _getFilteredItemsByMessage(String message) {
    if (message.contains('stok')) return controller.stockVouchers;
    if (message.contains('terjual')) return controller.soldVouchers;
    if (message.contains('aktif')) return controller.activeVouchers;
    if (message.contains('expired')) return controller.expiredVouchers;
    return [];
  }

  Widget _buildHeader(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 24, right: 24, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manajemen Voucher',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'VOUCHER LIST & PRINTING',
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
          const SizedBox(height: 24),
          // Hotspot Selector
          Obx(() {
            if (controller.hotspots.isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: controller.selectedHotspot.value?.idHotspot,
                  dropdownColor: const Color(0xFF131E29),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white70,
                  ),
                  hint: Text(
                    'Pilih Hotspot',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white54),
                  ),
                  style: GoogleFonts.plusJakartaSans(color: Colors.white),
                  items: controller.hotspots.map((hotspot) {
                    return DropdownMenuItem<int>(
                      value: hotspot.idHotspot,
                      child: Text('Hotspot: ${hotspot.namaServer}'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    final hotspot = controller.hotspots.firstWhereOrNull(
                      (h) => h.idHotspot == val,
                    );
                    controller.onHotspotChanged(hotspot);
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
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

    Color statusColor;
    String statusLabel;

    switch (voucher.statusVoucher) {
      case VoucherStatus.stok:
        statusColor = const Color(0xFF4ADE80);
        statusLabel = 'STOK';
        break;
      case VoucherStatus.aktif:
        statusColor = accentColor;
        statusLabel = 'AKTIF';
        break;
      case VoucherStatus.terjual:
        statusColor = Colors.orange;
        statusLabel = 'TERJUAL';
        break;
      case VoucherStatus.expired:
        statusColor = Colors.redAccent;
        statusLabel = 'EXPIRED';
        break;
    }

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
                    Icons.confirmation_number_rounded,
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
                      if (voucher.dnsLogin != null && voucher.dnsLogin!.isNotEmpty)
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
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
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
                Row(
                  children: [
                    if (voucher.statusVoucher == VoucherStatus.stok)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: TextButton.icon(
                          onPressed: () {
                            Get.dialog(
                              AlertDialog(
                                backgroundColor: const Color(0xFF131E29),
                                title: const Text('Jual Voucher', style: TextStyle(color: Colors.white)),
                                content: Text('Pilih metode pembayaran untuk voucher "${voucher.kodeVoucher}"'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                      controller.sellVoucher(voucher, 'cash');
                                    },
                                    child: const Text('CASH', style: TextStyle(color: Color(0xFF4ADE80))),
                                  ),
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('Batal', style: TextStyle(color: Colors.white54)),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.sell_outlined, size: 18, color: Color(0xFF4ADE80)),
                          label: const Text('Jual', style: TextStyle(color: Color(0xFF4ADE80), fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF4ADE80).withValues(alpha: 0.1),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            backgroundColor: const Color(0xFF131E29),
                            title: const Text(
                              'Hapus Voucher',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: Text(
                              'Apakah Anda yakin ingin menghapus voucher "${voucher.kodeVoucher}"?',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('Batal', style: TextStyle(color: Colors.white54)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                  controller.deleteVoucher(voucher.idVoucher);
                                },
                                child: const Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.print_outlined,
                        size: 20,
                        color: Colors.white70,
                      ),
                      onPressed: () => controller.printVoucher(voucher),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
