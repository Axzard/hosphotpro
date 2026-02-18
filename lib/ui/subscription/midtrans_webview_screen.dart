import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hosphotpro/ui/subscription/view_models/subscription_view_model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/utils/snackbar_utils.dart';
import 'dart:io' show Platform;

class MidtransWebViewScreen extends StatefulWidget {
  const MidtransWebViewScreen({super.key});

  @override
  State<MidtransWebViewScreen> createState() => _MidtransWebViewScreenState();
}

class _MidtransWebViewScreenState extends State<MidtransWebViewScreen> {
  final String redirectUrl = Get.arguments as String;
  final bool useWebView = Platform.isAndroid || Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0A1118);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF131E29),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
          tooltip: 'Keluar',
        ),
        title: Text(
          'Pembayaran',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: useWebView
          ? _MobileWebView(redirectUrl: redirectUrl)
          : _MobileWebView(redirectUrl: redirectUrl), // Fallback for testing, but ideally different for desktop
    );
  }
}

class _MobileWebView extends StatefulWidget {
  final String redirectUrl;

  const _MobileWebView({required this.redirectUrl});

  @override
  State<_MobileWebView> createState() => _MobileWebViewState();
}

class _MobileWebViewState extends State<_MobileWebView> {
  late final WebViewController _controller;
  final isLoading = true.obs;
  final SubscriptionViewModel subscriptionViewModel = Get.find<SubscriptionViewModel>();

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            isLoading.value = true;
          },
          onPageFinished: (String url) {
            isLoading.value = false;
            _checkPaymentStatus(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            
            // Intercept placeholder redirect URLs to prevent ERR_CLEARTEXT_NOT_PERMITTED
            if (url.startsWith('http://example.com') || 
                url.contains('status_code=') || 
                url.contains('transaction_status=')) {
              
              _handleRedirect(url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            // Ignore cancel errors if we are already handling it or redirecting
            if (error.description.contains('net::ERR_CLEARTEXT_NOT_PERMITTED')) {
              return;
            }
            SnackbarUtils.showError('Error', 'Gagal memuat halaman pembayaran');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  void _handleRedirect(String url) {
    // Extract status and ID if possible from the URL
    final Uri uri = Uri.parse(url);
    final String? statusCode = uri.queryParameters['status_code'];
    final String? transactionStatus = uri.queryParameters['transaction_status'];
    final String? orderId = uri.queryParameters['order_id'];

    if (statusCode == '200' || transactionStatus == 'settlement' || transactionStatus == 'capture') {
      _finishPayment(true, 'Pembayaran berhasil! Langganan Anda akan segera aktif.', orderId);
    } else if (statusCode == '201' || transactionStatus == 'pending') {
      _finishPayment(false, 'Pembayaran sedang diproses. Silakan selesaikan pembayaran.', orderId);
    } else if (statusCode == '202' || transactionStatus == 'cancel' || transactionStatus == 'expire') {
      _finishPayment(false, 'Pembayaran dibatalkan atau kadaluarsa.', orderId);
    } else {
      // Default fallback for any other redirect
      Get.back();
    }
  }

  void _finishPayment(bool isSuccess, String message, String? orderId) {
    if (isSuccess) {
      if (orderId != null) {
        final id = int.tryParse(orderId.split('-').last);
        if (id != null) {
          subscriptionViewModel.clearPendingPayment(id);
        }
      }
      SnackbarUtils.showSuccess('Berhasil', message);
    } else {
      SnackbarUtils.showInfo('Informasi', message);
    }
    
    if (Get.isOverlaysOpen) Get.back(); // Close any overlays
    Get.back(); // Close WebView screen
  }

  void _checkPaymentStatus(String url) {
    // legacy check, onNavigationRequest should handle most cases now
    if (url.contains('status_code=200') || url.contains('transaction_status=settlement')) {
      _finishPayment(true, 'Pembayaran berhasil!', null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        Obx(
          () => isLoading.value
              ? Container(
                  color: const Color(0xFF0A1118),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF00C2FF),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Memuat halaman pembayaran...',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
