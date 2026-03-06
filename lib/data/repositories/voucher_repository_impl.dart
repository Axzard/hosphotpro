import 'package:get/get.dart';
import '../../domain/models/voucher_model.dart';
import '../../domain/models/voucher_package_model.dart';
import '../../domain/repositories/voucher_repository.dart';
import '../model/voucher_package_api_model.dart';
import '../services/voucher_service.dart';

class VoucherRepositoryImpl implements VoucherRepository {
  final VoucherService _voucherService = Get.find<VoucherService>();

  @override
  Future<List<VoucherModel>> getVouchersByHotspot(int idHotspot) async {
    // 🚀 Langkah 1: Coba endpoint langsung (1 request)
    try {
      final directResponse = await _voucherService.getVouchersByHotspot(
        idHotspot,
      );
      if (directResponse.success &&
          directResponse.data != null &&
          directResponse.data!.isNotEmpty) {
        return directResponse.data!
            .map((apiModel) => apiModel.toDomain())
            .toList();
      }
    } catch (_) {
      // Lanjut ke fallback
    }

    // 🔁 Fallback: Jika endpoint langsung gagal, gunakan per-paket (N+1 paralel)
    final packagesResponse = await _voucherService.getVoucherPackages(
      idHotspot,
    );
    if (!packagesResponse.success ||
        packagesResponse.data == null ||
        packagesResponse.data!.isEmpty) {
      return [];
    }

    final packages = packagesResponse.data!;
    final voucherFutures = packages.map(
      (pkg) => _voucherService.getVouchersByPackage(pkg.id),
    );
    final voucherResponses = await Future.wait(voucherFutures);

    final List<VoucherModel> allVouchers = [];
    for (var response in voucherResponses) {
      if (response.success && response.data != null) {
        allVouchers.addAll(
          response.data!.map((apiModel) => apiModel.toDomain()),
        );
      }
    }
    return allVouchers;
  }

  @override
  Future<VoucherModel?> getVoucherDetail(int id) async {
    final response = await _voucherService.getVoucherDetail(id);
    if (response.success) {
      return response.data?.toDomain();
    }
    throw Exception(response.message);
  }

  @override
  Future<VoucherModel?> createVoucher(int idPaket) async {
    final response = await _voucherService.createVoucher(idPaket);
    if (response.success) {
      return response.data?.toDomain();
    }
    throw Exception(response.message);
  }

  @override
  Future<List<VoucherModel>> createVoucherBulk(int idPaket, int jumlah) async {
    final response = await _voucherService.createVoucherBulk(idPaket, jumlah);
    if (response.success && response.data != null) {
      return response.data!.map((apiModel) => apiModel.toDomain()).toList();
    }
    throw Exception(response.message);
  }

  @override
  Future<bool> deleteVoucher(int id) async {
    final response = await _voucherService.deleteVoucher(id);
    return response.success;
  }

  @override
  Future<List<VoucherPackageModel>> getVoucherPackages(int idHotspot) async {
    final response = await _voucherService.getVoucherPackages(idHotspot);
    if (response.success && response.data != null) {
      return response.data!.map((apiModel) => apiModel.toDomain()).toList();
    }
    throw Exception(response.message);
  }

  @override
  Future<VoucherPackageModel?> createVoucherPackage(
    VoucherPackageModel package,
  ) async {
    final response = await _voucherService.createVoucherPackage(
      VoucherPackageApiModel.fromDomain(package),
    );
    if (response.success) {
      return response.data?.toDomain();
    }
    throw Exception(response.message);
  }

  @override
  Future<VoucherPackageModel?> getVoucherPackageDetail(int id) async {
    final response = await _voucherService.getVoucherPackageDetail(id);
    if (response.success) {
      return response.data!.toDomain();
    }
    throw Exception(response.message);
  }

  @override
  Future<void> updateVoucherPackage(int id, VoucherPackageModel package) async {
    final response = await _voucherService.updateVoucherPackage(
      id,
      VoucherPackageApiModel.fromDomain(package),
    );
    if (!response.success) {
      throw Exception(response.message);
    }
  }

  @override
  Future<void> deleteVoucherPackage(int id) async {
    final response = await _voucherService.deleteVoucherPackage(id);
    if (!response.success) {
      throw Exception(response.message);
    }
  }

  @override
  Future<List<VoucherModel>> getActiveVouchers() async {
    final response = await _voucherService.getActiveVouchers();
    if (response.success && response.data != null) {
      return response.data!.map((apiModel) => apiModel.toDomain()).toList();
    }
    return [];
  }

  @override
  Future<double> sellVoucher(int id, String paymentMethod) async {
    final response = await _voucherService.sellVoucher(id, paymentMethod);
    if (response.success) {
      return response.data ?? 0;
    }
    throw Exception(response.message);
  }
}
