import '../models/voucher_model.dart';
import '../models/voucher_package_model.dart';

abstract class VoucherRepository {
  Future<List<VoucherModel>> getVouchersByHotspot(int idHotspot);
  Future<List<VoucherModel>> getAllVouchers();
  Future<VoucherModel?> getVoucherDetail(int id);
  Future<VoucherModel?> createVoucher(int idPaket);
  Future<List<VoucherModel>> createVoucherBulk(int idPaket, int jumlah);
  Future<bool> deleteVoucher(int id);
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
}
