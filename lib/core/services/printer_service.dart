import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:get/get.dart';
import '../../domain/models/voucher_model.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:async';

class PrinterService extends GetxService {
  final isConnected = false.obs;
  final devices = <fbp.BluetoothDevice>[].obs;
  final selectedDevice = Rxn<fbp.BluetoothDevice>();
  StreamSubscription? _connectionSubscription;

  @override
  void onInit() {
    super.onInit();
    _initPrinter();
  }

  @override
  void onClose() {
    _connectionSubscription?.cancel();
    super.onClose();
  }

  void _initPrinter() {
    fbp.FlutterBluePlus.adapterState.listen((state) {
      if (state == fbp.BluetoothAdapterState.on) {
        scanDevices();
      }
    });
  }

  Future<void> scanDevices() async {
    try {
      devices.clear();
      // Get bonded devices first
      final List<fbp.BluetoothDevice> bonded = await fbp.FlutterBluePlus.bondedDevices;
      devices.assignAll(bonded);

      // Also start a short scan for new devices
      await fbp.FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      fbp.FlutterBluePlus.scanResults.listen((results) {
        for (fbp.ScanResult r in results) {
          if (!devices.any((d) => d.remoteId == r.device.remoteId)) {
            devices.add(r.device);
          }
        }
      });
    } catch (e) {
      print("Error scanning devices: $e");
    }
  }

  Future<void> connectToDevice(fbp.BluetoothDevice device) async {
    if (isConnected.value) {
      await disconnect();
    }

    try {
      await device.connect(license: fbp.License.free);
      selectedDevice.value = device;
      isConnected.value = true;

      _connectionSubscription?.cancel();
      _connectionSubscription = device.connectionState.listen((state) {
        if (state == fbp.BluetoothConnectionState.disconnected) {
          isConnected.value = false;
          selectedDevice.value = null;
        }
      });
    } catch (e) {
      print("Error connecting to device: $e");
      rethrow;
    }
  }

  Future<void> disconnect() async {
    try {
      if (selectedDevice.value != null) {
        await selectedDevice.value!.disconnect();
      }
      isConnected.value = false;
      selectedDevice.value = null;
    } catch (e) {
      print("Error disconnecting: $e");
    }
  }

  Future<void> printVoucher(VoucherModel voucher) async {
    if (!isConnected.value || selectedDevice.value == null) return;

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

    await _writeToPrinter(Uint8List.fromList(bytes));
  }

  Future<void> _writeToPrinter(Uint8List bytes) async {
    final device = selectedDevice.value;
    if (device == null) return;

    List<fbp.BluetoothService> services = await device.discoverServices();
    fbp.BluetoothCharacteristic? writeCharacteristic;

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
          writeCharacteristic = characteristic;
          break;
        }
      }
      if (writeCharacteristic != null) break;
    }

    if (writeCharacteristic != null) {
      // Split into chunks if necessary (typical BLE MTU is 20-512 bytes)
      int actualMtu = 23; 
      try {
        actualMtu = await device.mtu.first;
      } catch(_) {}
      
      int chunkSize = actualMtu - 3;
      if (chunkSize < 20) chunkSize = 20; // Ensure a sane minimum
      
      for (int i = 0; i < bytes.length; i += chunkSize) {
        int end = (i + chunkSize < bytes.length) ? i + chunkSize : bytes.length;
        await writeCharacteristic.write(bytes.sublist(i, end), withoutResponse: writeCharacteristic.properties.writeWithoutResponse);
      }
    } else {
      throw Exception("Could not find a writable characteristic on the device");
    }
  }
}
