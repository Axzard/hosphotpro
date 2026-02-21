import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../../../domain/models/subscription_package_model.dart';
import '../../../domain/models/subscription_repository.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../domain/models/user_subscription_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/routing/app_routes.dart';
import '../midtrans_webview_screen.dart';
import '../../../data/services/payment_persistence_service.dart';
import '../../../core/services/websocket_service.dart';

class SubscriptionViewModel extends GetxController {
  final SubscriptionRepository _subscriptionRepository;
  final PaymentPersistenceService _paymentPersistenceService = Get.find<PaymentPersistenceService>();
  final _webSocketService = Get.find<WebSocketService>();

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

  StreamSubscription? _refreshSub;

  @override
  void onInit() {
    super.onInit();
    // Use parallel fetching to speed up initial load
    Future.wait([
      loadPackages(),
      loadMySubscriptions(),
    ]);
    _initRealtimeListeners();
  }

  void _initRealtimeListeners() {
    _refreshSub = _webSocketService.eventStream.listen((eventData) {
      final event = (eventData['event'] ?? '').toString().toLowerCase();
      
      // Filter: Only refresh on payment/subscription related events
      const relevantEvents = ['payment_success', 'payment_failed', 'subscription_updated'];
      if (!relevantEvents.contains(event)) return;

      loadMySubscriptions();
    });
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

      // Step 2: Create Transaction (Checkout)
      final transaction = await _subscriptionRepository.createTransaction(
        idPaketLangganan: packageId,
        jumlahBulan: 1, // Default to 1 for direct select if not specified
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
        idPaketLangganan: packageId,
        jumlahBulan: selectedDuration.value,
        amount: totalPrice,
      );

      if (transaction.redirectUrl != null &&
          transaction.redirectUrl!.isNotEmpty) {
        Get.to(
          () => const MidtransWebViewScreen(),
          arguments: {
            'url': transaction.redirectUrl,
            'idLangganan': idLangganan,
          },
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
        idPaketLangganan: subscription.idPaketLangganan,
        jumlahBulan: 1, // Renewal usually 1 or based on period
        amount: subscription.totalBayar,
      );

      // Step 3: Open Midtrans payment page
      if (transaction.redirectUrl != null &&
          transaction.redirectUrl!.isNotEmpty) {
        // SAVE LOCALLY
        await _paymentPersistenceService.savePendingPayment(idLangganan, transaction.redirectUrl!);
        
        Get.to(
          () => const MidtransWebViewScreen(),
          arguments: {
            'url': transaction.redirectUrl!,
            'idLangganan': idLangganan,
          },
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

  /// Resume an existing pending payment using its saved payment URL
  /// If forced or URL is missing, it will re-create the transaction
  Future<void> resumePayment(UserSubscriptionModel subscription, {bool forceNew = false}) async {
    String? url;
    
    if (!forceNew) {
      // Priority 1: Persistent Local Storage
      url = _paymentPersistenceService.getPendingUrl(subscription.idLangganan);
      // Priority 2: API Model URL
      url ??= subscription.paymentUrl;
    }

    if (url != null && url.isNotEmpty && !forceNew) {
      Get.to(
        () => const MidtransWebViewScreen(),
        arguments: {
          'url': url,
          'idLangganan': subscription.idLangganan,
        },
      );
    } else {
      // Re-create transaction (Re-checkout) for the SAME idLangganan
      try {
        processingSubscriptionId.value = subscription.idLangganan;
        
        // Use current totalBayar
        final transaction = await _subscriptionRepository.createTransaction(
          idPaketLangganan: subscription.idPaketLangganan,
          jumlahBulan: 1, 
          amount: subscription.totalBayar,
        );

        if (transaction.redirectUrl != null && transaction.redirectUrl!.isNotEmpty) {
          // SAVE LOCALLY
          await _paymentPersistenceService.savePendingPayment(subscription.idLangganan, transaction.redirectUrl!);
          
          Get.to(
            () => const MidtransWebViewScreen(),
            arguments: {
              'url': transaction.redirectUrl!,
              'idLangganan': subscription.idLangganan,
            },
          );
        } else {
          SnackbarUtils.showError('Error', 'Gagal memperbarui tautan pembayaran');
        }
      } catch (e) {
        SnackbarUtils.showError('Error', 'Gagal memproses pembayaran: $e');
      } finally {
        processingSubscriptionId.value = null;
      }
    }
  }

  /// Clear local pending payment
  Future<void> clearPendingPayment(int idLangganan) async {
    await _paymentPersistenceService.clearPendingPayment(idLangganan);
  }

  /// Cancel subscription (Explicitly by user or on expiry detect)
  Future<void> cancelSubscription(int idLangganan) async {
    try {
      isLoading.value = true;
      // Step 1: Tell backend to update status to 'canceled'
      final success = await _subscriptionRepository.updateSubscriptionStatus(idLangganan, 'canceled');
      
      // Step 2: Clear local persistence
      await clearPendingPayment(idLangganan);
      
      if (success) {
        // Step 3: Refresh lists so it disappears from status screen
        await loadMySubscriptions();
      }
    } catch (e) {
      debugPrint('Error canceling subscription: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToPackages() {
    Get.toNamed(Routes.PACKAGES);
  }

  @override
  void onClose() {
    _refreshSub?.cancel();
    super.onClose();
  }
}
