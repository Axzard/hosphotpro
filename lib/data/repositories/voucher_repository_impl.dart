import 'package:get/get.dart';
import '../../domain/models/voucher_model.dart';
import '../../domain/models/voucher_package_model.dart';
import '../../domain/models/voucher_repository.dart';
import '../services/voucher_service.dart';

class VoucherRepositoryImpl implements VoucherRepository {
  final VoucherService _voucherService = Get.find<VoucherService>();

  @override
  Future<List<VoucherModel>> getVouchersByRouter(int idRouter) async {
    final response = await _voucherService.getVouchersByRouter(idRouter);
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  @override
  Future<VoucherModel?> getVoucherDetail(int id, int idRouter) async {
    final response = await _voucherService.getVoucherDetail(id, idRouter);
    if (response.success) {
      return response.data;
    }
    throw Exception(response.message);
  }

  @override
  Future<VoucherModel?> createVoucher(int idPaket, int idRouter) async {
    final response = await _voucherService.createVoucher(idPaket, idRouter);
    if (response.success) {
      return response.data;
    }
    throw Exception(response.message);
  }

  @override
  Future<List<VoucherModel>> createVoucherBulk(
    int idPaket,
    int idRouter,
    int jumlah,
  ) async {
    final response = await _voucherService.createVoucherBulk(
      idPaket,
      idRouter,
      jumlah,
    );
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  @override
  Future<bool> deleteVoucher(int id, int idRouter) async {
    final response = await _voucherService.deleteVoucher(id, idRouter);
    return response.success;
  }

  @override
  Future<List<VoucherPackageModel>> getVoucherPackages(int idRouter) async {
    final response = await _voucherService.getVoucherPackages(idRouter);
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message);
  }

  @override
  Future<VoucherPackageModel?> createVoucherPackage(
    VoucherPackageModel package,
  ) async {
    final response = await _voucherService.createVoucherPackage(package);
    if (response.success) {
      return response.data;
    }
    throw Exception(response.message);
  }
}
