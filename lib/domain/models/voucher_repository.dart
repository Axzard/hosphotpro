import 'voucher_model.dart';
import 'voucher_package_model.dart';

abstract class VoucherRepository {
  Future<List<VoucherModel>> getVouchersByHotspot(int idHotspot);
  Future<VoucherModel?> getVoucherDetail(int id);
  Future<VoucherModel?> createVoucher(int idPaket);
  Future<List<VoucherModel>> createVoucherBulk(
    int idPaket,
    int jumlah,
  );
  Future<bool> deleteVoucher(int id);

  // Voucher Package methods
  Future<List<VoucherPackageModel>> getVoucherPackages(int idHotspot);
  Future<VoucherPackageModel?> getVoucherPackageDetail(int id);
  Future<VoucherPackageModel?> createVoucherPackage(
    VoucherPackageModel package,
  );
  Future<void> updateVoucherPackage(int id, VoucherPackageModel package);
  Future<void> deleteVoucherPackage(int id);
}
