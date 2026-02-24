import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../../../domain/models/subscription_package_model.dart';
import '../../../domain/repositories/subscription_repository.dart';
import '../../../domain/models/transaction_model.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../core/utils/error_utils.dart';
import '../../../domain/models/user_subscription_model.dart';

import '../../../config/routing/app_routes.dart';
import '../midtrans_webview_screen.dart';
import '../../../data/services/payment_persistence_service.dart';
import '../../../core/services/websocket_service.dart';

class SubscriptionViewModel extends GetxController {
  final SubscriptionRepository _subscriptionRepository;
  final PaymentPersistenceService _paymentPersistenceService =
      Get.find<PaymentPersistenceService>();
  final _webSocketService = Get.find<WebSocketService>();

  SubscriptionViewModel(this._subscriptionRepository);

  final packages = <SubscriptionPackageModel>[].obs;
  final mySubscriptions = <UserSubscriptionModel>[].obs;
  final currentSubscription = Rx<UserSubscriptionModel?>(null);
  final isLoading = false.obs;
  bool _isLoadingSubscriptions = false;

  final errorMessage = ''.obs;
  final isProcessingPayment = false.obs;

  final processingSubscriptionId = RxnInt(null);

  final selectedDuration = 1.obs;
  final selectedPaymentMethod = ''.obs;

  StreamSubscription? _refreshSub;

  @override
  void onInit() {
    super.onInit();

    Future.wait([loadPackages(), loadMySubscriptions()]);
    _initRealtimeListeners();
  }

  void _initRealtimeListeners() {
    _refreshSub = _webSocketService.eventStream.listen((eventData) {
      final event = (eventData['event'] ?? '').toString().toLowerCase();

      const relevantEvents = [
        'payment_success',
        'payment_failed',
        'subscription_updated',
      ];
      if (!relevantEvents.contains(event)) return;

      loadMySubscriptions();
    });
  }

  Future<void> loadPackages() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final result = await _subscriptionRepository.getPackages();
      packages.assignAll(result);
    } catch (e) {
      errorMessage.value = ErrorUtils.getUserFriendlyMessage(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMySubscriptions() async {
    if (_isLoadingSubscriptions) return;
    _isLoadingSubscriptions = true;
    isLoading.value = true;
    try {
      final result = await _subscriptionRepository.getMySubscriptions();
      mySubscriptions.value = result;

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
      _isLoadingSubscriptions = false;
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

      final int packageId = int.tryParse(package.id) ?? 0;
      final subscriptionData = await _subscriptionRepository.createSubscription(
        packageId,
        selectedDuration.value,
      );

      if (subscriptionData == null) {
        throw Exception('Gagal membuat langganan');
      }

      final dynamic rawId =
          subscriptionData['id_langganan'] ??
          subscriptionData['data']?['id_langganan'] ??
          subscriptionData['id'] ??
          subscriptionData['data']?['id'] ??
          subscriptionData['id_subscription'];
      final int idLangganan = int.tryParse(rawId?.toString() ?? '') ?? 0;

      if (idLangganan == 0) {
        throw Exception('ID Langganan tidak ditemukan dalam respon server');
      }

      final transaction = await _subscriptionRepository.createTransaction(
        idLangganan: idLangganan,
        idPaketLangganan: packageId,
        jumlahBulan: selectedDuration.value,
        metodePembayaran: selectedPaymentMethod.value,
      );

      String? paymentUrl =
          transaction.redirectUrl ??
          (transaction.snapToken != null
              ? 'https://app.midtrans.com/snap/v2/vtweb/${transaction.snapToken}'
              : null);

      final bool hasPaymentLink = paymentUrl != null && paymentUrl.isNotEmpty;
      final bool hasVaInfo =
          transaction.vaNumber != null && transaction.vaNumber!.isNotEmpty;

      if (hasPaymentLink || hasVaInfo) {
        _navigateToPaymentResult(transaction, idLangganan, false);
      } else {
        Get.toNamed(
          Routes.PAYMENT_ERROR,
          arguments: {
            'message':
                'Gagal mendapatkan detail pembayaran dari ${transaction.bankName ?? selectedPaymentMethod.value}.',
            'bankName': transaction.bankName ?? selectedPaymentMethod.value,
          },
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memproses pembayaran: $e');
    } finally {
      isProcessingPayment.value = false;
    }
  }

  Future<void> renewSubscription(UserSubscriptionModel subscription) async {
    try {
      processingSubscriptionId.value = subscription.idLangganan;

      await clearPendingPayment(subscription.idLangganan);

      final transaction = await _subscriptionRepository.renewTransaction(
        jumlahBulan: 1,
        idLangganan: subscription.idLangganan,
        idPaketLangganan: subscription.idPaketLangganan,
        metodePembayaran: selectedPaymentMethod.value.isNotEmpty
            ? selectedPaymentMethod.value
            : 'qris',
      );

      String? paymentUrl =
          transaction.redirectUrl ??
          (transaction.snapToken != null
              ? 'https://app.midtrans.com/snap/v2/vtweb/${transaction.snapToken}'
              : null);

      final bool hasPaymentLink = paymentUrl != null && paymentUrl.isNotEmpty;
      final bool hasVaInfo =
          transaction.vaNumber != null && transaction.vaNumber!.isNotEmpty;

      if (hasPaymentLink || hasVaInfo) {
        if (hasPaymentLink) {
          await _paymentPersistenceService.savePendingPayment(
            subscription.idLangganan,
            paymentUrl,
          );
        }

        mySubscriptions.refresh();

        _navigateToPaymentResult(transaction, subscription.idLangganan, true);
      } else {
        Get.toNamed(
          Routes.PAYMENT_ERROR,
          arguments: {
            'message':
                'Gagal memperbarui info pembayaran dari ${transaction.bankName ?? selectedPaymentMethod.value}.',
            'bankName': transaction.bankName ?? selectedPaymentMethod.value,
          },
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperpanjang langganan: $e');
    } finally {
      processingSubscriptionId.value = null;
    }
  }

  bool hasPendingUrl(int idLangganan) {
    final url = _paymentPersistenceService.getPendingUrl(idLangganan);
    return url != null && url.isNotEmpty;
  }

  Future<void> resumePayment(
    UserSubscriptionModel subscription, {
    bool forceNew = false,
  }) async {
    if (subscription.vaNumber != null && subscription.vaNumber!.isNotEmpty) {
      Get.toNamed(
        Routes.PAYMENT_DETAIL,
        arguments: TransactionModel(
          id: subscription.idLangganan.toString(),
          packageId: subscription.idPaketLangganan.toString(),
          packageName: subscription.namaPaket,
          userId: '0',
          amount: subscription.totalBayar,
          status: TransactionStatus.pending,
          createdAt: subscription.dibuatPada,
          vaNumber: subscription.vaNumber,
          bankName: subscription.bankName,
        ),
      );
      return;
    }

    String? url;

    if (!forceNew) {
      url = _paymentPersistenceService.getPendingUrl(subscription.idLangganan);

      url ??= subscription.paymentUrl;
    }

    if (url != null && url.isNotEmpty) {
      final isRenewal = !subscription.isPending;
      Get.to(
        () => const MidtransWebViewScreen(),
        arguments: {
          'url': url,
          'idLangganan': subscription.idLangganan,
          'isRenewal': isRenewal,
        },
      );
    } else {
      try {
        SnackbarUtils.showInfo(
          'Memuat',
          'Sedang mengambil detail pembayaran terbaru...',
        );

        final transaction = await _subscriptionRepository.renewTransaction(
          idLangganan: subscription.idLangganan,
          idPaketLangganan: subscription.idPaketLangganan,
          jumlahBulan: subscription.jumlahBulan,
          metodePembayaran: selectedPaymentMethod.value,
        );

        _navigateToPaymentResult(
          transaction,
          subscription.idLangganan,
          !subscription.isPending,
        );
      } catch (e) {
        await clearPendingPayment(subscription.idLangganan);
        SnackbarUtils.showError(
          'Gagal Memuat Pembayaran',
          'Silakan klik kembali tombol perpanjang atau pilih paket baru.',
        );
      }
    }
  }

  Future<void> clearPendingPayment(int idLangganan) async {
    await _paymentPersistenceService.clearPendingPayment(idLangganan);
    mySubscriptions.refresh();
  }

  Future<void> cancelRenewal(int idLangganan) async {
    await clearPendingPayment(idLangganan);
    SnackbarUtils.showInfo('Dibatalkan', 'Pembayaran perpanjangan dibatalkan.');
  }

  Future<void> cancelSubscription(int idLangganan) async {
    await changeSubscriptionStatus(idLangganan, 'batal');
  }

  Future<void> changeSubscriptionStatus(
    int idLangganan,
    String newStatus,
  ) async {
    try {
      SnackbarUtils.showInfo('Memperbarui', 'Sedang memperbarui status...');

      final success = await _subscriptionRepository.updateSubscriptionStatus(
        idLangganan,
        newStatus,
      );

      if (success) {
        SnackbarUtils.showSuccess('Berhasil', 'Status berhasil diperbarui');
        if (newStatus == 'canceled' || newStatus == 'batal') {
          await clearPendingPayment(idLangganan);
        }
        await loadMySubscriptions();
      } else {
        SnackbarUtils.showError('Gagal', 'Gagal memperbarui status');
      }
    } catch (e) {
      debugPrint('Error updating subscription status: $e');
      SnackbarUtils.showError('Error', 'Terjadi kesalahan sistem');
      await loadMySubscriptions();
    }
  }

  void navigateToPackages() {
    Get.toNamed(Routes.PACKAGES);
  }

  void _navigateToPaymentResult(
    TransactionModel transaction,
    int idLangganan,
    bool isRenewal,
  ) {
    if (transaction.vaNumber != null && transaction.vaNumber!.isNotEmpty) {
      Get.toNamed(Routes.PAYMENT_DETAIL, arguments: transaction);
      return;
    }

    String? paymentUrl =
        transaction.redirectUrl ??
        (transaction.snapToken != null
            ? 'https://app.midtrans.com/snap/v2/vtweb/${transaction.snapToken}'
            : null);

    if (paymentUrl != null) {
      Get.to(
        () => const MidtransWebViewScreen(),
        arguments: {
          'url': paymentUrl,
          'idLangganan': idLangganan,
          'isRenewal': isRenewal,
        },
      );
    }
  }

  @override
  void onClose() {
    _refreshSub?.cancel();
    super.onClose();
  }
}
