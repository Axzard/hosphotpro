import '../models/voucher_model.dart';
import '../models/voucher_package_model.dart';

abstract class VoucherRepository {
  Future<List<VoucherModel>> getVouchersByHotspot(int idHotspot);
  Future<List<VoucherModel>> getAllVouchers();
  Future<List<VoucherModel>> getAllVouchersByPackages(List<int> paketIds);
  Future<VoucherModel?> getVoucherDetail(int id);
  Future<VoucherModel?> createVoucher(int idPaket);
  Future<List<VoucherModel>> createVoucherBulk(int idPaket, int jumlah);
  Future<bool> deleteVoucher(int id);
  Future<bool> deleteVoucherBulkAll({List<int>? ids, String? status});
  Future<List<VoucherModel>> getActiveVouchers();
  Future<double> sellVoucher(int idVoucher, String paymentMethod);

  Future<List<VoucherPackageModel>> getVoucherPackages(int idHotspot);
  Future<List<VoucherPackageModel>> getAllVoucherPackages();
  Future<VoucherPackageModel?> getVoucherPackageDetail(int id);
  Future<VoucherPackageModel?> createVoucherPackage(
    VoucherPackageModel package,
  );
  Future<void> updateVoucherPackage(int id, VoucherPackageModel package);
  Future<void> deleteVoucherPackage(int id);

  // Cache methods
  Future<List<VoucherPackageModel>> getVoucherPackagesFromCache(int idHotspot);
  Future<List<VoucherModel>> getVouchersByHotspotFromCache(int idHotspot);
  Future<void> updateVoucherCache(int idHotspot, List<VoucherModel> vouchers);
  Future<void> updateVoucherPackageCache(int idHotspot, List<VoucherPackageModel> packages);
}
