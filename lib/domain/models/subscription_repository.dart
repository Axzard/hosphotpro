import 'subscription_package_model.dart';
import 'transaction_model.dart';
import 'user_subscription_model.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionPackageModel>> getPackages();
  Future<TransactionModel> createTransaction(SubscriptionPackageModel package);
  Future<TransactionModel?> getTransactionById(String transactionId);
  Future<List<TransactionModel>> getTransactionHistory();
  Future<UserSubscriptionModel?> getCurrentSubscription();
  Future<bool> activateSubscription(String transactionId);
}
