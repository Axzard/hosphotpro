import 'package:get/get.dart';
import '../../domain/models/subscription_package_model.dart';
import '../../domain/models/subscription_repository.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/models/user_subscription_model.dart';
import '../services/subscription_service.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionService _subscriptionService =
      Get.find<SubscriptionService>();

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
  Future<SubscriptionPackageModel?> getPackageDetail(int id) async {
    try {
      final response = await _subscriptionService.getPackageDetail(id);
      if (response.success && response.data != null) {
        return response.data!.toDomain();
      }
      return null;
    } catch (e) {
      return null;
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
  Future<TransactionModel> createTransaction({
    required int idLangganan,
    required double amount,
  }) async {
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
  Future<List<UserSubscriptionModel>> getMySubscriptions() async {
    try {
      final response = await _subscriptionService.getMySubscriptions();
      if (response.success && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> updateSubscriptionStatus(int id, String status) async {
    try {
      final response = await _subscriptionService.updateSubscriptionStatus(
        id,
        status,
      );
      return response.success;
    } catch (e) {
      return false;
    }
  }
}
