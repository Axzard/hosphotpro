import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:get/get.dart';
import '../../domain/models/voucher_model.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

class PrinterService extends GetxService {
  final BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  final isConnected = false.obs;
  final devices = <BluetoothDevice>[].obs;
  final selectedDevice = Rxn<BluetoothDevice>();

  @override
  void onInit() {
    super.onInit();
    _initPrinter();
  }

  void _initPrinter() {
    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          isConnected.value = true;
          break;
        case BlueThermalPrinter.DISCONNECTED:
          isConnected.value = false;
          break;
        default:
          break;
      }
    });

    scanDevices();
  }

  Future<void> scanDevices() async {
    try {
      devices.clear();
      final List<BluetoothDevice> scannedDevices = await bluetooth
          .getBondedDevices();
      devices.assignAll(scannedDevices);
    } catch (e) {
      print("Error scanning devices: $e");
      if (e.toString().contains('MissingPluginException')) {
        Get.snackbar(
          'Restart Diperlukan',
          'Fitur Bluetooth memerlukan restart aplikasi untuk berjalan.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Future<void> connect(BluetoothDevice device) async {
    if (isConnected.value) {
      await disconnect();
    }

    try {
      await bluetooth.connect(device);
      selectedDevice.value = device;
    } catch (e) {
      print("Error connecting to device: $e");
      rethrow;
    }
  }

  Future<void> disconnect() async {
    try {
      await bluetooth.disconnect();
      selectedDevice.value = null;
    } catch (e) {
      print("Error disconnecting: $e");
    }
  }

  Future<void> printVoucher(VoucherModel voucher) async {
    if (!isConnected.value) return;

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // Header
    bytes += generator.text(
      'HosphotPro',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.text(
      voucher.namaServer,
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr();

    // Body
    bytes += generator.text(
      'Kode Voucher:',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      voucher.kodeVoucher,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    if (voucher.passwordVoucher.isNotEmpty &&
        voucher.passwordVoucher != voucher.kodeVoucher) {
      bytes += generator.text(
        'Password:',
        styles: const PosStyles(align: PosAlign.center),
      );
      bytes += generator.text(
        voucher.passwordVoucher,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
    }

    bytes += generator.feed(1);

    // Details
    bytes += generator.row([
      PosColumn(text: 'Paket', width: 6),
      PosColumn(
        text: voucher.namaPaket,
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.row([
      PosColumn(text: 'Harga', width: 6),
      PosColumn(
        text: NumberFormat.currency(
          locale: 'id',
          symbol: 'Rp ',
          decimalDigits: 0,
        ).format(voucher.harga),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    if (voucher.tanggalExpired != null) {
      bytes += generator.row([
        PosColumn(text: 'Expired', width: 6),
        PosColumn(
          text: DateFormat('dd/MM/yy').format(voucher.tanggalExpired!),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();
    bytes += generator.text(
      'Terima Kasih',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(2);
    bytes += generator.cut();

    await bluetooth.writeBytes(Uint8List.fromList(bytes));
  }

  // Future method needed for bulk printing if necessary
}
