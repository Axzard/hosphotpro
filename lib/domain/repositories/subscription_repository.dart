import '../models/subscription_package_model.dart';
import '../models/transaction_model.dart';
import '../models/user_subscription_model.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionPackageModel>> getPackages();
  Future<SubscriptionPackageModel?> getPackageDetail(int id);
  Future<Map<String, dynamic>?> createSubscription(
    int packageId,
    int jumlahBulan,
  );
  Future<TransactionModel> createTransaction({
    required int idLangganan,
    required int idPaketLangganan,
    required int jumlahBulan,
    String? metodePembayaran,
  });
  Future<TransactionModel> renewTransaction({
    required int jumlahBulan,
    int? idLangganan,
    int? idPaketLangganan,
    String? metodePembayaran,
  });
  Future<List<UserSubscriptionModel>> getMySubscriptions();
  Future<bool> updateSubscriptionStatus(int id, String status);
}
