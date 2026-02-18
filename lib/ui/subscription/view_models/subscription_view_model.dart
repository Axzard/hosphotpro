import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../domain/models/subscription_package_model.dart';
import '../../../domain/models/subscription_repository.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../domain/models/user_subscription_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/routing/app_routes.dart';
import '../midtrans_webview_screen.dart';

class SubscriptionViewModel extends GetxController {
  final SubscriptionRepository _subscriptionRepository;

  SubscriptionViewModel(this._subscriptionRepository);

  final packages = <SubscriptionPackageModel>[].obs;
  final mySubscriptions = <UserSubscriptionModel>[].obs;
  final currentSubscription = Rx<UserSubscriptionModel?>(null);
  final isLoading = false.obs;

  // For new package purchases (Package List -> Detail -> Payment)
  final isProcessingPayment = false.obs;

  // For renewals (Subscription Status Screen) - tracks specific subscription ID
  final processingSubscriptionId = RxnInt(null);

  final selectedDuration = 1.obs;
  final selectedPaymentMethod = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadPackages();
    loadMySubscriptions();
  }

  Future<void> loadPackages() async {
    isLoading.value = true;
    try {
      final result = await _subscriptionRepository.getPackages();
      packages.value = result;
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memuat daftar paket');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMySubscriptions() async {
    isLoading.value = true;
    try {
      final result = await _subscriptionRepository.getMySubscriptions();
      mySubscriptions.value = result;

      // Set current subscription to the active one, or the most recent one
      final activeSubscription = result.where((s) => s.isActive).toList();
      if (activeSubscription.isNotEmpty) {
        currentSubscription.value = activeSubscription.first;
      } else if (result.isNotEmpty) {
        currentSubscription.value = result.first;
      } else {
        currentSubscription.value = null;
      }
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memuat data langganan');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> selectPackage(SubscriptionPackageModel package) async {
    try {
      isProcessingPayment.value = true;

      // Step 1: Create Subscription to get id_langganan
      final int packageId = int.tryParse(package.id) ?? 0;
      final subscriptionData = await _subscriptionRepository.createSubscription(
        packageId,
      );

      if (subscriptionData == null ||
          subscriptionData['id_langganan'] == null) {
        throw Exception('Gagal mendapatkan ID Langganan');
      }

      final int idLangganan = subscriptionData['id_langganan'];

      // Step 2: Create Transaction (Checkout)
      final transaction = await _subscriptionRepository.createTransaction(
        idLangganan: idLangganan,
        amount: package.price,
      );

      if (transaction.redirectUrl != null &&
          transaction.redirectUrl!.isNotEmpty) {
        final Uri url = Uri.parse(transaction.redirectUrl!);
        try {
          bool launched = await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
          if (!launched) {
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
          SnackbarUtils.showError(
            'Error',
            'Gagal membuka halaman pembayaran: $e',
          );
        }
      } else if (transaction.snapToken != null &&
          transaction.snapToken!.isNotEmpty) {
        SnackbarUtils.showInfo(
          'Informasi',
          'Token pembayaran: ${transaction.snapToken}',
        );
      } else {
        SnackbarUtils.showError('Error', 'Gagal mendapatkan tautan pembayaran');
      }
    } catch (e) {
      SnackbarUtils.showError('Error', 'Gagal memproses pembelian: $e');
    } finally {
      isProcessingPayment.value = false;
    }
  }

  double calculateTotalPrice(SubscriptionPackageModel package) {
    final basePrice = package.price;
    final duration = selectedDuration.value;

    double discount = 0;
    if (duration == 3) {
      discount = 0.10;
    } else if (duration == 6) {
      discount = 0.15;
    } else if (duration == 12) {
      discount = 0.20;
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
      final subscriptionData = await _subscriptionRepository.createSubscription(
        packageId,
      );

      if (subscriptionData == null ||
          subscriptionData['id_langganan'] == null) {
        throw Exception('Gagal mendapatkan ID Langganan');
      }

      final int idLangganan = subscriptionData['id_langganan'];

      // Step 2: Create Transaction (Checkout)
      final transaction = await _subscriptionRepository.createTransaction(
        idLangganan: idLangganan,
        amount: totalPrice,
      );

      if (transaction.redirectUrl != null &&
          transaction.redirectUrl!.isNotEmpty) {
        Get.to(
          () => const MidtransWebViewScreen(),
          arguments: transaction.redirectUrl,
        );
      } else if (transaction.snapToken != null &&
          transaction.snapToken!.isNotEmpty) {
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

  /// Perpanjang langganan — create new subscription for the same package, then checkout via Midtrans
  Future<void> renewSubscription(UserSubscriptionModel subscription) async {
    try {
      processingSubscriptionId.value = subscription.idLangganan;

      // Step 1: Create new subscription record for the same package
      final subscriptionData = await _subscriptionRepository.createSubscription(
        subscription.idPaketLangganan,
      );

      if (subscriptionData == null ||
          subscriptionData['id_langganan'] == null) {
        throw Exception('Gagal membuat langganan baru');
      }

      final int idLangganan = subscriptionData['id_langganan'];

      // Step 2: Checkout — use the same totalBayar as the previous subscription
      final transaction = await _subscriptionRepository.createTransaction(
        idLangganan: idLangganan,
        amount: subscription.totalBayar,
      );

      // Step 3: Open Midtrans payment page
      if (transaction.redirectUrl != null &&
          transaction.redirectUrl!.isNotEmpty) {
        Get.to(
          () => const MidtransWebViewScreen(),
          arguments: transaction.redirectUrl,
        );
      } else if (transaction.snapToken != null &&
          transaction.snapToken!.isNotEmpty) {
        Get.snackbar('Informasi', 'Token pembayaran: ${transaction.snapToken}');
      } else {
        Get.snackbar('Error', 'Gagal mendapatkan tautan pembayaran');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperpanjang langganan: $e');
    } finally {
      processingSubscriptionId.value = null;
    }
  }

  void navigateToPackages() {
    Get.toNamed(Routes.PACKAGES);
  }

  void navigateToTransactions() {
    Get.snackbar('Informasi', 'Fitur riwayat transaksi akan segera hadir');
  }
}
