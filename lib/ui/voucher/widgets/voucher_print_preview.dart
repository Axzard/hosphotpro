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
                        'HosphotPro',
                        style: GoogleFonts.courierPrime(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.routerName,
                        style: GoogleFonts.courierPrime(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const Divider(
                        color: Colors.black,
                        thickness: 1.5,
                        height: 24,
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
                              printerService.selectedDevice.value?.name ??
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
                  max: widget.vouchers.length.toDouble(),
                  divisions: math.max(1, widget.vouchers.length - 1),
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
          Expanded(
            child: SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () => _sharePdf(context),
                icon: const Icon(Icons.download),
                label: Text(
                  'PDF',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
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
                  isPrinting ? 'Mencetak...' : 'Cetak ($selectedQuantity)',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
                        await printerService.connect(device);
                      },
                      tileColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: const Icon(Icons.print, color: Colors.white),
                      title: Text(
                        device.name ?? 'Unknown',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white),
                      ),
                      trailing:
                          printerService.selectedDevice.value?.address ==
                              device.address
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

    setState(() => isPrinting = true);
    try {
      for (var voucher in _vouchersToPrint) {
        await printerService.printVoucher(voucher);
        await Future.delayed(const Duration(milliseconds: 500));
      }
      SnackbarUtils.showSuccess('Berhasil', 'Voucher sedang dicetak');
    } catch (e) {
      SnackbarUtils.showError('Gagal', 'Terjadi kesalahan saat mencetak: $e');
    } finally {
      setState(() => isPrinting = false);
    }
  }

  Widget _buildVoucherItem(VoucherModel voucher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black26, style: BorderStyle.solid),
        ),
      ),
      child: Column(
        children: [
          Text(
            'KODE VOUCHER',
            style: GoogleFonts.courierPrime(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            voucher.kodeVoucher,
            style: GoogleFonts.courierPrime(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: 2,
            ),
          ),
          if (voucher.passwordVoucher.isNotEmpty &&
              voucher.passwordVoucher != voucher.kodeVoucher) ...[
            const SizedBox(height: 8),
            Text(
              'PASSWORD: ${voucher.passwordVoucher}',
              style: GoogleFonts.courierPrime(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                voucher.namaPaket,
                style: GoogleFonts.courierPrime(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                currencyFormat.format(voucher.harga),
                style: GoogleFonts.courierPrime(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          if (voucher.tanggalExpired != null) ...[
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Exp: ${DateFormat('dd/MM/yy').format(voucher.tanggalExpired!)}',
                style: GoogleFonts.courierPrime(
                  fontSize: 10,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _sharePdf(BuildContext context) async {
    final pdfDetails = await _generatePdf(PdfPageFormat.a4);
    await Printing.sharePdf(
      bytes: pdfDetails,
      filename: 'vouchers_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    // Load font to support unicode/fixes Helvetica issue
    final font = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    const vouchersPerPage = 21;
    final listToPrint = _vouchersToPrint; // Respect selected quantity
    final pages = (listToPrint.length / vouchersPerPage).ceil();

    for (var i = 0; i < pages; i++) {
      final start = i * vouchersPerPage;
      final end = (start + vouchersPerPage < listToPrint.length)
          ? start + vouchersPerPage
          : listToPrint.length;
      final pageVouchers = listToPrint.sublist(start, end);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'HosphotPro Vouchers',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Router: ${widget.routerName}',
                        style: pw.TextStyle(font: font, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.GridView(
                  crossAxisCount: 3,
                  childAspectRatio: 2.0,
                  children: pageVouchers
                      .map(
                        (voucher) =>
                            _buildPdfVoucherItem(voucher, font, fontBold),
                      )
                      .toList(),
                ),
                pw.Spacer(),
                pw.Footer(
                  leading: pw.Text(
                    'Generated by HosphotPro',
                    style: pw.TextStyle(font: font),
                  ),
                  trailing: pw.Text(
                    'Page ${i + 1} of $pages',
                    style: pw.TextStyle(font: font),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }
    return pdf.save();
  }

  pw.Widget _buildPdfVoucherItem(
    VoucherModel voucher,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.all(4),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            voucher.kodeVoucher,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          if (voucher.passwordVoucher.isNotEmpty &&
              voucher.passwordVoucher != voucher.kodeVoucher)
            pw.Text(
              'Pass: ${voucher.passwordVoucher}',
              style: pw.TextStyle(font: font, fontSize: 10),
            ),
          pw.Divider(thickness: 0.5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                voucher.namaPaket,
                style: pw.TextStyle(font: font, fontSize: 8),
              ),
              pw.Text(
                NumberFormat('#,###').format(voucher.harga),
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
