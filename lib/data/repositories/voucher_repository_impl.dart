import 'package:get/get.dart';
import '../../domain/models/voucher_model.dart';
import '../../domain/models/voucher_package_model.dart';
import '../../domain/models/voucher_repository.dart';
import '../model/voucher_package_api_model.dart';
import '../services/voucher_service.dart';

class VoucherRepositoryImpl implements VoucherRepository {
  final VoucherService _voucherService = Get.find<VoucherService>();

  @override
  Future<List<VoucherModel>> getVouchersByHotspot(int idHotspot) async {
    // Since there's no direct/working getVouchersByHotspot endpoint (404),
    // we fetch vouchers for all packages in this hotspot and combine them.
    final packagesResponse = await _voucherService.getVoucherPackages(idHotspot);
    if (!packagesResponse.success || packagesResponse.data == null) {
      throw Exception(packagesResponse.message);
    }

    final packages = packagesResponse.data!;
    final List<VoucherModel> allVouchers = [];

    // Fetch vouchers for all packages in parallel for better performance
    final voucherFutures = packages.map((pkg) => _voucherService.getVouchersByPackage(pkg.id));
    final voucherResponses = await Future.wait(voucherFutures);

    for (var response in voucherResponses) {
      if (response.success && response.data != null) {
        allVouchers.addAll(response.data!.map((apiModel) => apiModel.toDomain()));
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
  Future<List<VoucherModel>> createVoucherBulk(
    int idPaket,
    int jumlah,
  ) async {
    final response = await _voucherService.createVoucherBulk(
      idPaket,
      jumlah,
    );
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
  Future<void> updateVoucherPackage(
    int id,
    VoucherPackageModel package,
  ) async {
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
}
