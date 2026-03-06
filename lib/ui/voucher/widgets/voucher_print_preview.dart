import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/voucher_model.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/printer_service.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../view_models/voucher_view_model.dart';
import 'dart:math' as math;

class VoucherPrintPreview extends StatefulWidget {
  final List<VoucherModel> vouchers;
  final String routerName;

  const VoucherPrintPreview({
    super.key,
    required this.vouchers,
    required this.routerName,
  });

  @override
  State<VoucherPrintPreview> createState() => _VoucherPrintPreviewState();
}

class _VoucherPrintPreviewState extends State<VoucherPrintPreview> {
  final PrinterService printerService = Get.find<PrinterService>();
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  int selectedQuantity = 0; // 0 means all
  bool isPrinting = false;
  int currentPrintIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedQuantity = widget.vouchers.length;
  }

  List<VoucherModel> get _vouchersToPrint {
    return widget.vouchers.take(selectedQuantity).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          'Cetak Voucher',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _sharePdf(context),
            tooltip: 'Share PDF',
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Printer & Settings Section
          _buildSettingsSection(),

          // 2. Preview Section (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Container(
                  width: 300, // Simulate ~58-80mm width
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Text(
                        'hotspotsio',
                        style: GoogleFonts.courierPrime(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Divider(
                        color: Colors.black,
                        thickness: 1.5,
                        height: 16,
                      ),


                      // Vouchers List
                      ..._vouchersToPrint.map(
                        (voucher) => _buildVoucherItem(voucher),
                      ),

                      const SizedBox(height: 16),
                      Text(
                        'Terima Kasih',
                        style: GoogleFonts.courierPrime(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('dd MMM yyyy HH:mm').format(DateTime.now()),
                        style: GoogleFonts.courierPrime(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Action Button
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1E293B),
      child: Column(
        children: [
          // Printer Info
          InkWell(
            onTap: _showPrinterScanner,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.print, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Printer Bluetooth',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(() {
                          final deviceName =
                              printerService
                                  .selectedDevice
                                  .value
                                  ?.name ??
                              'Pilih Printer';
                          return Text(
                            deviceName,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  Obx(() {
                    if (printerService.isConnected.value) {
                      return const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4ADE80),
                      );
                    }
                    return const Icon(
                      Icons.chevron_right,
                      color: Colors.white54,
                    );
                  }),
                ],
              ),
            ),
          ),
          if (widget.vouchers.length > 1) ...[
            const SizedBox(height: 12),
            // Quantity Slider
            Row(
              children: [
                Text(
                  'Jumlah:',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white70),
                ),
                Expanded(
                  child: Slider(
                    value: selectedQuantity.toDouble(),
                    min: 1,
                    max: math.max(1, widget.vouchers.length.toDouble()),
                    divisions: math.max(1, widget.vouchers.length),
                    activeColor: const Color(0xFF00C2FF),
                    label: selectedQuantity.toString(),

                    onChanged: (val) {
                      setState(() {
                        selectedQuantity = val.toInt();
                      });
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$selectedQuantity / ${widget.vouchers.length}',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          // Download icon-only button
          SizedBox(
            height: 54,
            width: 54,
            child: OutlinedButton(
              onPressed: () => _downloadPdf(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.zero,
              ),
              child: const Icon(Icons.download, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          // Print button
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _handlePrint,
                icon: isPrinting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.print),
                label: Text(
                  isPrinting
                      ? 'Mencetak ($currentPrintIndex/$selectedQuantity)...'
                      : 'Cetak ($selectedQuantity)',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C2FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrinterScanner() {
    printerService.scanDevices();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pilih Printer',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF00C2FF)),
                  onPressed: printerService.scanDevices,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (printerService.devices.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada printer ditemukan.\nPastikan bluetooth aktif.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(color: Colors.white54),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: printerService.devices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final device = printerService.devices[index];
                    return ListTile(
                      onTap: () async {
                        Get.back(); // Close sheet
                        await printerService.connectToDevice(device);
                      },
                      tileColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: const Icon(Icons.print, color: Colors.white),
                      title: Text(
                        device.name.isEmpty
                            ? 'Unknown Device'
                            : device.name,
                        style: GoogleFonts.plusJakartaSans(color: Colors.white),
                      ),
                      trailing:
                          printerService.selectedDevice.value?.macAdress ==
                              device.macAdress
                          ? const Icon(Icons.check, color: Color(0xFF4ADE80))
                          : null,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePrint() async {
    if (!printerService.isConnected.value) {
      SnackbarUtils.showError(
        'Printer Tidak Terhubung',
        'Silakan pilih dan hubungkan printer terlebih dahulu.',
      );
      _showPrinterScanner();
      return;
    }

    setState(() {
      isPrinting = true;
      currentPrintIndex = 0;
    });

    try {
      final toPrint = _vouchersToPrint;

      for (int i = 0; i < toPrint.length; i++) {
        setState(() {
          currentPrintIndex = i + 1;
        });
        await printerService.printVoucher(toPrint[i]);
        // Slight delay between print commands for buffer safety
        await Future.delayed(const Duration(milliseconds: 600));
      }

      // Update status voucher ke terjual hanya SETELAH berhasil cetak
      final hasStokVouchers = toPrint.any(
        (v) => v.statusVoucher == VoucherStatus.stok,
      );
      if (hasStokVouchers) {
        try {
          final voucherVM = Get.find<VoucherViewModel>();
          await voucherVM.sellBulkVouchersForPrint(toPrint);
        } catch (e) {
          print('[PrintPreview] Error updating status after print: $e');
        }
      }

      SnackbarUtils.showSuccess(
        'Berhasil',
        'Semua voucher ($selectedQuantity) berhasil dicetak',
      );

      // Tutup halaman cetak otomatis setelah berhasil
      Get.back();
    } catch (e) {
      SnackbarUtils.showError(
        'Gagal',
        'Terjadi kesalahan saat mencetak di item $currentPrintIndex: $e',
      );
    } finally {
      setState(() {
        isPrinting = false;
        currentPrintIndex = 0;
      });
    }
  }

  Widget _buildVoucherItem(VoucherModel voucher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.only(bottom: 8),

      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black26, style: BorderStyle.solid),
        ),
      ),
      child: Column(
        children: [
          Text(
            'DATA LOGIN VOUCHER',
            style: GoogleFonts.courierPrime(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            'USERNAME / KODE',
            style: GoogleFonts.courierPrime(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
          Text(
            voucher.kodeVoucher,
            style: GoogleFonts.courierPrime(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 2,
            ),
          ),
          if (voucher.passwordVoucher.isNotEmpty &&
              voucher.passwordVoucher != voucher.kodeVoucher) ...[
            const SizedBox(height: 4),

            Text(
              'PASSWORD',
              style: GoogleFonts.courierPrime(
                fontSize: 10,
                color: Colors.black54,
              ),
            ),
            Text(
              voucher.passwordVoucher,
              style: GoogleFonts.courierPrime(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 2,
              ),
            ),

          ],
        ],
      ),
    );
  }

  Future<void> _downloadPdf(BuildContext context) async {
    final pdfDetails = await _generatePdf();
    await Printing.layoutPdf(
      onLayout: (_) => pdfDetails,
      name: 'vouchers_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  Future<void> _sharePdf(BuildContext context) async {
    final pdfDetails = await _generatePdf();
    await Printing.sharePdf(
      bytes: pdfDetails,
      filename: 'vouchers_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    // Thermal receipt style: ~58mm width single column
    final receiptWidth = 58 * PdfPageFormat.mm;
    final listToPrint = _vouchersToPrint;
    final dateStr = DateFormat('dd MMM yyyy HH:mm').format(DateTime.now());

    // Each voucher gets its own receipt page with header + footer
    for (final voucher in listToPrint) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            receiptWidth,
            double.infinity,
            marginAll: 8 * PdfPageFormat.mm,
          ),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header
                pw.Text(
                  'hotspotsio',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Divider(thickness: 1.5),
                pw.SizedBox(height: 2),


                // Body — voucher data
                pw.Text(
                  'DATA LOGIN VOUCHER',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 2),

                pw.Text(
                  'USERNAME / KODE',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: 7,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  voucher.kodeVoucher,
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                if (voucher.passwordVoucher.isNotEmpty &&
                    voucher.passwordVoucher != voucher.kodeVoucher) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'PASSWORD',
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 7,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    voucher.passwordVoucher,
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),

                ],

                // Footer
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 0.5),

                pw.SizedBox(height: 4),
                pw.Text(
                  'Terima Kasih',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(dateStr, style: pw.TextStyle(font: font, fontSize: 8)),
              ],
            );
          },
        ),
      );
    }
    return pdf.save();
  }
}
