import 'subscription_package_model.dart';
import 'transaction_model.dart';
import 'user_subscription_model.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionPackageModel>> getPackages();
  Future<SubscriptionPackageModel?> getPackageDetail(int id);
  Future<Map<String, dynamic>?> createSubscription(int packageId);
  Future<TransactionModel> createTransaction({
    required int idLangganan,
    required double amount,
  });
  Future<List<UserSubscriptionModel>> getMySubscriptions();
  Future<bool> updateSubscriptionStatus(int id, String status);
}
