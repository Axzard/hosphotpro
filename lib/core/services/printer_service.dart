import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
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
  final devices = <fbp.BluetoothDevice>[].obs;
  final selectedDevice = Rxn<fbp.BluetoothDevice>();
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _scanSubscription;

  @override
  void onInit() {
    super.onInit();
    _initPrinter();
  }

  @override
  void onClose() {
    _connectionSubscription?.cancel();
    _scanSubscription?.cancel();
    super.onClose();
  }

  void _initPrinter() {
    fbp.FlutterBluePlus.adapterState.listen((state) {
      if (state == fbp.BluetoothAdapterState.on) {
        scanDevices();
      }
    });

    fbp.FlutterBluePlus.isScanning.listen((scanning) {
      isScanning.value = scanning;
    });
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
      devices.clear();
      
      // Get bonded/connected devices first
      final List<fbp.BluetoothDevice> bonded = await fbp.FlutterBluePlus.bondedDevices;
      for (var device in bonded) {
        if (!devices.any((d) => d.remoteId == device.remoteId)) {
          devices.add(device);
        }
      }

      // Also get currently connected system devices (very important!)
      // Some printers might be connected but not bonded
      final List<fbp.BluetoothDevice> system = await fbp.FlutterBluePlus.systemDevices([]);
      for (var device in system) {
        if (!devices.any((d) => d.remoteId == device.remoteId)) {
          devices.add(device);
        }
      }

      // Start scan
      await fbp.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
      );

      _scanSubscription?.cancel();
      _scanSubscription = fbp.FlutterBluePlus.scanResults.listen((results) {
        for (fbp.ScanResult r in results) {
          // Filter for likely printers or just show all for now
          // Thermal printers often have 'Printer' in name or specific UUIDs
          if (r.device.platformName.isNotEmpty) {
             if (!devices.any((d) => d.remoteId == r.device.remoteId)) {
              devices.add(r.device);
            }
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
      print("Connecting to ${device.platformName} (${device.remoteId})");
      await device.connect(autoConnect: false, license: fbp.License.free);
      selectedDevice.value = device;
      isConnected.value = true;

      _connectionSubscription?.cancel();
      _connectionSubscription = device.connectionState.listen((state) {
        print("Connection state changed: $state");
        if (state == fbp.BluetoothConnectionState.disconnected) {
          isConnected.value = false;
          selectedDevice.value = null;
        }
      });
      
      // Request larger MTU for faster printing
      if (Platform.isAndroid) {
        try {
          await device.requestMtu(512);
        } catch (e) {
          print("Error requesting MTU: $e");
        }
      }
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
    bytes += generator.feed(1); // Jarak kecil antara HosphotPro dengan nama hotspot
    bytes += generator.text(
      voucher.namaServer,
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr();

    // Body - Grouped Login Info
    bytes += generator.text(
      'DATA LOGIN VOUCHER',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.feed(1); // Jarak sedikit dengan USERNAME / KODE

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

    // Potong tepat setelah "Terima Kasih"
    bytes += generator.feed(1);
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
