import 'voucher_model.dart';
import 'voucher_package_model.dart';

abstract class VoucherRepository {
  Future<List<VoucherModel>> getVouchersByRouter(int idRouter);
  Future<VoucherModel?> getVoucherDetail(int id, int idRouter);
  Future<VoucherModel?> createVoucher(int idPaket, int idRouter);
  Future<List<VoucherModel>> createVoucherBulk(
    int idPaket,
    int idRouter,
    int jumlah,
  );
  Future<bool> deleteVoucher(int id, int idRouter);

  // Voucher Package methods
  Future<List<VoucherPackageModel>> getVoucherPackages(int idRouter);
  Future<VoucherPackageModel?> getVoucherPackageDetail(int id);
  Future<VoucherPackageModel?> createVoucherPackage(
    VoucherPackageModel package,
  );
  Future<void> updateVoucherPackage(int id, VoucherPackageModel package);
  Future<void> deleteVoucherPackage(int id);
}
