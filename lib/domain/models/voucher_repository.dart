import 'voucher_model.dart';

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
}
