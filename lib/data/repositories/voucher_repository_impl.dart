import '../../domain/models/voucher_model.dart';
import '../../domain/models/voucher_package_model.dart';
import '../../domain/repositories/voucher_repository.dart';
import '../model/voucher_package_api_model.dart';
import '../services/voucher_service.dart';
import '../../core/services/cache_service.dart';
import '../model/voucher_api_model.dart';

class VoucherRepositoryImpl implements VoucherRepository {
  final VoucherService _voucherService;
  final CacheService _cacheService;

  VoucherRepositoryImpl(this._voucherService, this._cacheService);

  @override
  Future<List<VoucherModel>> getVouchersByHotspot(int idHotspot) async {
    // Gunakan endpoint yang dioptimalkan, jangan ambil per paket (lambat)
    final response = await _voucherService.getVouchersByHotspot(idHotspot);
    
    if (!response.success && idHotspot > 0) {
      throw Exception(response.message);
    }

    final vouchers = response.data ?? [];
    final List<VoucherModel> domainVouchers = vouchers.map((apiModel) => apiModel.toDomain()).toList();

    if (idHotspot > 0 && domainVouchers.isNotEmpty) {
      await _cacheService.saveVouchers(
        idHotspot,
        domainVouchers.map((e) => VoucherApiModel.fromDomain(e).toJson()).toList(),
      );
    }
    
    return domainVouchers;
  }

  @override
  Future<List<VoucherModel>> getAllVouchers() async {
    final response = await _voucherService.getActiveVouchers();
    if (response.success && response.data != null) {
      return response.data!.map((apiModel) => apiModel.toDomain()).toList();
    }
    return [];
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
      await _cacheService.saveVoucherPackages(idHotspot, response.data!.map((e) => e.toJson()).toList());
      return response.data!.map((apiModel) => apiModel.toDomain()).toList();
    }
    throw Exception(response.message);
  }

  @override
  Future<List<VoucherPackageModel>> getAllVoucherPackages() async {
    final response = await _voucherService.getAllVoucherPackages();
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
  @override
  Future<List<VoucherPackageModel>> getVoucherPackagesFromCache(int idHotspot) async {
    final cached = _cacheService.getVoucherPackages(idHotspot);
    if (cached == null) return [];
    return cached
        .map((json) => VoucherPackageApiModel.fromJson(json as Map<String, dynamic>).toDomain())
        .toList();
  }

  @override
  Future<List<VoucherModel>> getVouchersByHotspotFromCache(int idHotspot) async {
    final cached = _cacheService.getVouchers(idHotspot);
    if (cached == null) return [];
    return cached
        .map((json) => VoucherApiModel.fromJson(json as Map<String, dynamic>).toDomain())
        .toList();
  }

  @override
  Future<void> updateVoucherCache(int idHotspot, List<VoucherModel> vouchers) async {
    await _cacheService.saveVouchers(
      idHotspot,
      vouchers.map((e) => VoucherApiModel.fromDomain(e).toJson()).toList(),
    );
  }
}
