import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../domain/models/voucher_model.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:io';

class PrinterService extends GetxService {
  final isConnected = false.obs;
  final isScanning = false.obs;
  final devices = <BluetoothInfo>[].obs;
  final selectedDevice = Rxn<BluetoothInfo>();

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    try {
      final bool result = await PrintBluetoothThermal.connectionStatus;
      isConnected.value = result;
    } catch (_) {}
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      if (statuses[Permission.bluetoothScan] != PermissionStatus.granted ||
          statuses[Permission.bluetoothConnect] != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<void> scanDevices() async {
    if (!await _requestPermissions()) {
      print("Bluetooth permissions not granted");
      return;
    }

    try {
      isScanning.value = true;
      devices.clear();

      final List<BluetoothInfo> listResult =
          await PrintBluetoothThermal.pairedBluetooths;

      if (listResult.isNotEmpty) {
        devices.value = listResult;
      }
    } catch (e) {
      print("Error scanning devices: $e");
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> connectToDevice(BluetoothInfo device) async {
    try {
      if (isConnected.value) {
        await disconnect();
      }

      print("Connecting to ${device.name} (${device.macAdress})");
      final bool result = await PrintBluetoothThermal.connect(
          macPrinterAddress: device.macAdress);

      if (result) {
        selectedDevice.value = device;
        isConnected.value = true;
      } else {
        isConnected.value = false;
        throw Exception("Failed to connect to ${device.name}");
      }
    } catch (e) {
      print("Error connecting to device: $e");
      rethrow;
    }
  }

  Future<void> disconnect() async {
    try {
      await PrintBluetoothThermal.disconnect;
      isConnected.value = false;
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

    bytes += generator.text(
      'hotspotsio',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.feed(1);
    bytes += generator.text(
      voucher.namaServer,
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr();

    bytes += generator.text(
      'DATA LOGIN VOUCHER',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1);

    bytes += generator.text(
      'USERNAME / KODE',
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
      bytes += generator.feed(1);
      bytes += generator.text(
        'PASSWORD',
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

    bytes += generator.hr();
    bytes += generator.text(
      'Terima Kasih',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.feed(1);
    bytes += generator.cut();

    await _writeToPrinter(Uint8List.fromList(bytes));
  }

  Future<void> _writeToPrinter(Uint8List bytes) async {
    try {
      final bool result = await PrintBluetoothThermal.writeBytes(bytes);
      if (!result) {
        throw Exception("Failed to write to printer");
      }
    } catch (e) {
      print("Error writing to printer: $e");
      throw Exception("Could not write print data: $e");
    }
  }
}
