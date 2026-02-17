import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/models/subscription_package_model.dart';
import '../../../domain/models/subscription_repository.dart';
import '../../../domain/models/transaction_model.dart';
import '../../../domain/models/user_subscription_model.dart';
import '../../../data/services/midtrans_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/routing/app_routes.dart';
import '../midtrans_webview_screen.dart';

class SubscriptionViewModel extends GetxController {
  final SubscriptionRepository _subscriptionRepository;
  final MidtransService _midtransService = Get.find<MidtransService>();

  SubscriptionViewModel(this._subscriptionRepository);

  final packages = <SubscriptionPackageModel>[].obs;
  final transactions = <TransactionModel>[].obs;
  final currentSubscription = Rx<UserSubscriptionModel?>(null);
  final isLoading = false.obs;
  final isProcessingPayment = false.obs;
  final selectedDuration = 1.obs; // Duration in months
  final selectedPaymentMethod = ''.obs;

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

      // Step 1: Create Subscription to get id_langganan
      final int packageId = int.tryParse(package.id) ?? 0;
      final subscriptionData = await _subscriptionRepository.createSubscription(packageId);
      
      if (subscriptionData == null || subscriptionData['id_langganan'] == null) {
        throw Exception('Gagal mendapatkan ID Langganan');
      }

      final int idLangganan = subscriptionData['id_langganan'];

      // Step 2: Create Transaction (Checkout)
      final transaction = await _subscriptionRepository.createTransaction(
        idLangganan: idLangganan,
        amount: package.price,
      );

      if (transaction.redirectUrl != null && transaction.redirectUrl!.isNotEmpty) {
        // Step 3: Redirect to web for payment
        final Uri url = Uri.parse(transaction.redirectUrl!);
        try {
          // Attempt to launch in external browser first
          bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
          if (!launched) {
            // Fallback to platform default
            launched = await launchUrl(url, mode: LaunchMode.platformDefault);
          }
          
          if (launched) {
            Get.snackbar(
              'Lanjutkan Pembayaran',
              'Silakan selesaikan pembayaran di browser Anda',
              backgroundColor: Colors.cyan.withValues(alpha: 0.1),
              colorText: Colors.white,
            );
          } else {
            throw Exception('Gagal membuka browser');
          }
        } catch (e) {
          Get.snackbar('Error', 'Gagal membuka halaman pembayaran: $e');
        }
      } else if (transaction.snapToken != null && transaction.snapToken!.isNotEmpty) {
        // Fallback or specific logic if only snap token is present
        Get.snackbar('Informasi', 'Token pembayaran: ${transaction.snapToken}');
      } else {
        Get.snackbar('Error', 'Gagal mendapatkan tautan pembayaran');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memproses pembelian: $e');
    } finally {
      isProcessingPayment.value = false;
    }
  }

  double calculateTotalPrice(SubscriptionPackageModel package) {
    final basePrice = package.price;
    final duration = selectedDuration.value;
    
    // Apply discount for longer durations
    double discount = 0;
    if (duration == 3) {
      discount = 0.10; // 10% off for 3 months
    } else if (duration == 6) {
      discount = 0.15; // 15% off for 6 months
    } else if (duration == 12) {
      discount = 0.20; // 20% off for 12 months
    }
    
    final totalPrice = basePrice * duration * (1 - discount);
    return totalPrice;
  }

  Future<void> initiatePayment(SubscriptionPackageModel package) async {
    try {
      isProcessingPayment.value = true;
      final totalPrice = calculateTotalPrice(package);

      // Step 1: Create Subscription to get id_langganan
      final int packageId = int.tryParse(package.id) ?? 0;
      final subscriptionData = await _subscriptionRepository.createSubscription(packageId);
      
      if (subscriptionData == null || subscriptionData['id_langganan'] == null) {
        throw Exception('Gagal mendapatkan ID Langganan');
      }

      final int idLangganan = subscriptionData['id_langganan'];

      // Step 2: Create Transaction (Checkout)
      final transaction = await _subscriptionRepository.createTransaction(
        idLangganan: idLangganan,
        amount: totalPrice,
      );

      if (transaction.redirectUrl != null && transaction.redirectUrl!.isNotEmpty) {
        // Step 3: Navigate to WebView screen
        // Use MidtransWebViewScreen for both Mobile and Windows (with fallback in screen)
        Get.to(
          () => const MidtransWebViewScreen(), 
          arguments: transaction.redirectUrl
        );
      } else if (transaction.snapToken != null && transaction.snapToken!.isNotEmpty) {
        Get.snackbar('Informasi', 'Token pembayaran: ${transaction.snapToken}');
      } else {
        Get.snackbar('Error', 'Gagal mendapatkan tautan pembayaran');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memproses pembayaran: $e');
    } finally {
      isProcessingPayment.value = false;
    }
  }


  Future<void> processPaymentOld(TransactionModel transaction) async {
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
