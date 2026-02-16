import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/models/subscription_package_model.dart';
import '../../../domain/models/subscription_repository.dart';
import '../../../domain/models/transaction_model.dart';
import '../../../domain/models/user_subscription_model.dart';
import '../../../data/services/midtrans_service.dart';
import '../../../config/routing/app_pages.dart';

class SubscriptionViewModel extends GetxController {
  final SubscriptionRepository _subscriptionRepository;
  final MidtransService _midtransService = Get.find<MidtransService>();

  SubscriptionViewModel(this._subscriptionRepository);

  final packages = <SubscriptionPackageModel>[].obs;
  final transactions = <TransactionModel>[].obs;
  final currentSubscription = Rx<UserSubscriptionModel?>(null);
  final isLoading = false.obs;
  final isProcessingPayment = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPackages();
    loadCurrentSubscription();
  }

  Future<void> loadPackages() async {
    isLoading.value = true;
    try {
      final result = await _subscriptionRepository.getPackages();
      packages.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load packages');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCurrentSubscription() async {
    try {
      final result = await _subscriptionRepository.getCurrentSubscription();
      currentSubscription.value = result;
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> loadTransactionHistory() async {
    isLoading.value = true;
    try {
      final result = await _subscriptionRepository.getTransactionHistory();
      transactions.value = result;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load transactions');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectPackage(SubscriptionPackageModel package) async {
    try {
      isProcessingPayment.value = true;

      // Create transaction
      final transaction = await _subscriptionRepository.createTransaction(package);

      if (transaction.snapToken != null) {
        // Navigate to payment screen
        Get.toNamed(
          Routes.PAYMENT,
          arguments: {
            'transaction': transaction,
            'package': package,
          },
        );
      } else {
        Get.snackbar('Error', 'Failed to create transaction');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to process payment: $e');
    } finally {
      isProcessingPayment.value = false;
    }
  }

  Future<void> processPayment(TransactionModel transaction) async {
    if (transaction.snapToken == null) {
      Get.snackbar('Error', 'Invalid transaction token');
      return;
    }

    try {
      isProcessingPayment.value = true;

      // Use mock payment for development
      final result = await _midtransService.mockPayment(transaction.snapToken!);

      if (result['status'] == 'success') {
        // Activate subscription
        await _subscriptionRepository.activateSubscription(transaction.id);
        
        // Reload subscription
        await loadCurrentSubscription();

        Get.snackbar(
          'Success',
          'Payment successful! Your subscription is now active.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to dashboard
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        Get.snackbar('Error', 'Payment failed');
      }
    } catch (e) {
      Get.snackbar('Error', 'Payment error: $e');
    } finally {
      isProcessingPayment.value = false;
    }
  }

  void navigateToPackages() {
    Get.toNamed(Routes.PACKAGES);
  }

  void navigateToTransactions() {
    Get.snackbar('Informasi', 'Fitur riwayat transaksi akan segera hadir');
  }
}
