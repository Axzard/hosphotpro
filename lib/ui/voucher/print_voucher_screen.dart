import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../core/widgets/desktop_page_wrapper.dart';
import '../core/widgets/responsive_layout.dart';
import 'view_models/voucher_view_model.dart';
import '../../domain/models/voucher_model.dart';
import '../../domain/models/hotspot_model.dart';
import '../../ui/voucher/widgets/create_voucher_sheet.dart';

class PrintVoucherScreen extends GetView<VoucherViewModel> {
  const PrintVoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0A1118);
    const cardColor = Color(0xFF131E29);
    const accentColor = Color(0xFF00C2FF);

    return DesktopPageWrapper(
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: bgColor,
          floatingActionButton: FloatingActionButton(
            heroTag: null,
            onPressed: () {
              Get.bottomSheet(
                const CreateVoucherSheet(),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              );
            },
            backgroundColor: accentColor,
            child: const Icon(Icons.add_rounded),
          ),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context, accentColor),
                _buildTabBar(accentColor),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildVoucherList(
                        controller.stockVouchers,
                        accentColor,
                        cardColor,
                        'Belum ada voucher stok',
                        VoucherStatus.stok,
                      ),
                      _buildVoucherList(
                        controller.soldVouchers,
                        accentColor,
                        cardColor,
                        'Belum ada voucher terjual',
                        VoucherStatus.terjual,
                      ),
                      _buildVoucherList(
                        controller.activeVouchers,
                        accentColor,
                        cardColor,
                        'Belum ada voucher aktif',
                        VoucherStatus.aktif,
                      ),
                      _buildVoucherList(
                        controller.expiredVouchers,
                        accentColor,
                        cardColor,
                        'Belum ada voucher expired',
                        VoucherStatus.expired,
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
        tabs: [
          Tab(
            child: Obx(() => _buildTabLabel('STOK', controller.stockVouchers.length)),
          ),
          Tab(
            child: Obx(() => _buildTabLabel('TERJUAL', controller.soldVouchers.length)),
          ),
          Tab(
            child: Obx(() => _buildTabLabel('AKTIF', controller.activeVouchers.length)),
          ),
          Tab(
            child: Obx(() => _buildTabLabel('EXPIRED', controller.expiredVouchers.length)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabLabel(String label, int count) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVoucherList(
    List<VoucherModel> items,
    Color accentColor,
    Color cardColor,
    String emptyMessage,
    VoucherStatus listStatus,
  ) {
    return Column(
      children: [
        _buildPackageFilter(accentColor),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00C2FF)),
              );
            }

            final filteredItems = _getFilteredItemsByMessage(emptyMessage);

            if (filteredItems.isEmpty) {
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
                            Icons.confirmation_number_outlined,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            emptyMessage,
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
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final voucher = filteredItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildVoucherCard(voucher, cardColor, accentColor),
                  );
                },
              ),
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
                ...controller.voucherPackages.map(
                  (paket) => _buildFilterTab(
                    label: paket.namaPaket,
                    isSelected: controller.filterPaketId.value == paket.id,
                    onTap: () => controller.setFilterPaket(paket.id),
                    accentColor: accentColor,
                  ),
                ),
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
          color: isSelected
              ? accentColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.05),
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

  Widget _buildHeader(BuildContext context, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 24, right: 24, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (ResponsiveLayout.isMobile(context))
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
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
                ),
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
              
              Obx(
                () => controller.vouchers.isNotEmpty
                    ? IconButton(
                        icon: controller.isDeletingAll.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.redAccent,
                                ),
                              )
                            : const Icon(
                                Icons.delete_sweep_outlined,
                                color: Colors.redAccent,
                              ),
                        onPressed: controller.isDeletingAll.value
                            ? null
                            : () => _showBulkDeleteConfirm(context),
                        tooltip: 'Hapus Semua',
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Obx(() {
            if (controller.hotspots.isEmpty) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<HotspotModel>(
                  value: controller.selectedHotspot.value,
                  hint: const Text(
                    'Pilih Hotspot',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  dropdownColor: const Color(0xFF131E29),
                  isExpanded: true,
                  icon: const Icon(
                    Icons.wifi_tethering,
                    color: Color(0xFF00C2FF),
                    size: 20,
                  ),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  items: controller.hotspots.map((h) {
                    return DropdownMenuItem<HotspotModel>(
                      value: h,
                      child: Text(h.namaServer),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      controller.onHotspotChanged(val);
                    }
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
        statusColor = Colors.greenAccent;
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

    return Obx(() {
      final isBulkDeletingThis = controller.isDeletingAll.value &&
          (controller.bulkDeletingCategory.value == null ||
              controller.bulkDeletingCategory.value == voucher.statusVoucher);
      final isInteractionDisabled = isBulkDeletingThis ||
          controller.deletingVoucherIds.contains(voucher.idVoucher);

      return GestureDetector(
        onTap: isInteractionDisabled
            ? null
            : () => controller.navigateToDetail(voucher),
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
                      
                      IconButton(
                        icon: controller.deletingVoucherIds.contains(voucher.idVoucher) ||
                                (controller.isDeletingAll.value && (controller.bulkDeletingCategory.value == null || controller.bulkDeletingCategory.value == voucher.statusVoucher))
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.redAccent,
                                ),
                              )
                            : const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.redAccent,
                              ),
                        onPressed: isInteractionDisabled
                            ? null
                            : () {
                                showDialog(
                                  context: Get.context!,
                                  barrierDismissible: true,
                                  builder: (dialogContext) {
                                    bool isConfirming = false;
                                    return StatefulBuilder(
                                      builder: (ctx, setStateDialog) {
                                        return AlertDialog(
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
                                              onPressed: () => Navigator.of(dialogContext).pop(),
                                              child: const Text(
                                                'Batal',
                                                style: TextStyle(color: Colors.white54),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: isConfirming
                                                  ? null
                                                  : () {
                                                      setStateDialog(() => isConfirming = true);
                                                      Navigator.of(dialogContext).pop();
                                                      controller.deleteVoucher(voucher.idVoucher);
                                                    },
                                              child: Text(
                                                isConfirming ? 'Menghapus...' : 'Hapus',
                                                style: const TextStyle(color: Colors.redAccent),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                      ),

                      
                      if (voucher.statusVoucher == VoucherStatus.stok)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: TextButton.icon(
                            onPressed: isInteractionDisabled
                                ? null
                                : () => controller.printVoucher(voucher),
                            icon: const Icon(
                              Icons.print_outlined,
                              size: 18,
                              color: Colors.white70,
                            ),
                            label: const Text(
                              'Print',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ),
                      if (voucher.statusVoucher == VoucherStatus.terjual ||
                          voucher.statusVoucher == VoucherStatus.aktif)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: TextButton.icon(
                            onPressed: isInteractionDisabled
                                ? null
                                : () => controller.printVoucher(voucher),
                            icon: const Icon(
                              Icons.print_outlined,
                              size: 18,
                              color: Colors.white70,
                            ),
                            label: const Text(
                              'Print',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.1),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showBulkDeleteConfirm(BuildContext context) {
    final Rx<VoucherStatus?> selectedStatus = Rx<VoucherStatus?>(null);

    Get.dialog(
      Obx(
        () => AlertDialog(
          backgroundColor: const Color(0xFF131E29),
          title: Text(
            'Hapus Voucher',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih kategori voucher yang ingin dihapus:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _buildDeleteOption(null, 'Semua Voucher', selectedStatus),
              _buildDeleteOption(
                VoucherStatus.stok,
                'Voucher Stok',
                selectedStatus,
              ),
              _buildDeleteOption(
                VoucherStatus.terjual,
                'Voucher Terjual',
                selectedStatus,
              ),
              _buildDeleteOption(
                VoucherStatus.aktif,
                'Voucher Aktif',
                selectedStatus,
              ),
              _buildDeleteOption(
                VoucherStatus.expired,
                'Voucher Expired',
                selectedStatus,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.deleteAllVouchers(status: selectedStatus.value);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus Sekarang'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteOption(
    VoucherStatus? status,
    String label,
    Rx<VoucherStatus?> selectedStatus,
  ) {
    final isSelected = selectedStatus.value == status;
    return GestureDetector(
      onTap: () => selectedStatus.value = status,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00C2FF).withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00C2FF).withValues(alpha: 0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF00C2FF) : Colors.white24,
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
