import 'package:get/get.dart';
import '../../domain/models/subscription_package_model.dart';
import '../../domain/models/subscription_repository.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/models/user_subscription_model.dart';
import '../services/subscription_service.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionService _subscriptionService = Get.find<SubscriptionService>();

  @override
  Future<List<SubscriptionPackageModel>> getPackages() async {
    try {
      final response = await _subscriptionService.getPackages();
      if (response.success && response.data != null) {
        return response.data!.map((pkg) => pkg.toDomain()).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>?> createSubscription(int packageId) async {
    final response = await _subscriptionService.createSubscription(packageId);
    if (response.success) {
      return response.data;
    }
    throw Exception(response.message);
  }

  @override
  Future<TransactionModel> createTransaction({required int idLangganan, required double amount}) async {
    try {
      final response = await _subscriptionService.createTransaction(
        idLangganan: idLangganan,
        amount: amount,
      );
      
      if (response.success && response.data != null) {
        return response.data!.toDomain();
      }
      
      throw Exception('Failed to create transaction: ${response.message}');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TransactionModel?> getTransactionById(String transactionId) async {
    try {
      final response = await _subscriptionService.getTransactionById(transactionId);
      return response.data?.toDomain();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionHistory() async {
    try {
      const userId = '1';
      final response = await _subscriptionService.getTransactionHistory(userId);
      
      if (response.success && response.data != null) {
        return response.data!.map((trx) => trx.toDomain()).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<UserSubscriptionModel?> getCurrentSubscription() async {
    // Mock current subscription
    await Future.delayed(const Duration(milliseconds: 500));
    
    return UserSubscriptionModel(
      id: 'sub_001',
      userId: '1',
      packageId: 'pkg_basic',
      packageName: 'Basic',
      status: SubscriptionStatus.active,
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 25)),
    );
  }

  @override
  Future<bool> activateSubscription(String transactionId) async {
    // Mock activation
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
