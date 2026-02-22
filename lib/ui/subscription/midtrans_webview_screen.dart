import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hosphotpro/ui/subscription/view_models/subscription_view_model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../config/routing/app_routes.dart';

class MidtransWebViewScreen extends StatefulWidget {
  const MidtransWebViewScreen({super.key});

  @override
  State<MidtransWebViewScreen> createState() => _MidtransWebViewScreenState();
}

class _MidtransWebViewScreenState extends State<MidtransWebViewScreen> {
  late final String _url;
  late final int _idLangganan;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map) {
      _url = args['url'] ?? '';
      _idLangganan = args['idLangganan'] ?? 0;
    } else {
      _url = args as String;
      _idLangganan = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0A1118);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: _MobileWebView(redirectUrl: _url, idLangganan: _idLangganan),
      ),
    );
  }
}

class _MobileWebView extends StatefulWidget {
  final String redirectUrl;
  final int idLangganan;

  const _MobileWebView({required this.redirectUrl, required this.idLangganan});

  @override
  State<_MobileWebView> createState() => _MobileWebViewState();
}

class _MobileWebViewState extends State<_MobileWebView> {
  late final WebViewController _controller;
  final isLoading = true.obs;
  final isPaymentFinished = false.obs;
  final SubscriptionViewModel subscriptionViewModel = Get.find<SubscriptionViewModel>();

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0A1118))
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
            final url = request.url.toLowerCase();
            debugPrint('🌐 WebView Navigating to: $url');
            
            // Catch any cancel/error/finish redirects from Midtrans Snap
            if (url.contains('status_code=') || 
                url.contains('transaction_status=') ||
                url.contains('transaction_id=') ||
                url.contains('order_id=') ||
                url.contains('/finish') ||
                url.contains('/unfinish') ||
                url.contains('/error') ||
                url.contains('gopay/finish') || 
                url.contains('payment/finish')) {
              
              _handleRedirect(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            final errorCode = error.errorCode;
            final description = error.description.toLowerCase();
            
            debugPrint('⚠️ WebView Resource Error: $errorCode - $description');

            if (errorCode == -2 || errorCode == -202 || description.contains('ssl') || description.contains('handshake')) {
              return;
            }
            
            if (error.isForMainFrame ?? true) {
              if (Get.isSnackbarOpen == false) {
                 SnackbarUtils.showInfo('Koneksi', 'Halaman sedang dimuat, harap tunggu...');
              }
            }
          },
        ),
      );

    // Android specific tweaks (if needed in future, use correct Manager)
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      // setAcceptThirdPartyCookies is set via AndroidCookieManager if needed
    }

    _controller.loadRequest(Uri.parse(widget.redirectUrl));
  }

  Future<bool> _onWillPop() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF131E29),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Batalkan Pembayaran?', 
          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        content: Text(
          'Apakah Anda yakin ingin ke luar? Pembayaran Anda akan dibatalkan.',
          style: GoogleFonts.plusJakartaSans(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Lanjutkan', style: GoogleFonts.plusJakartaSans(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Batal & Keluar', style: GoogleFonts.plusJakartaSans(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop) {
          // Explicitly cancel if user confirms exit
          if (widget.idLangganan != 0) {
            subscriptionViewModel.cancelSubscription(widget.idLangganan);
          }
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A1118),
          appBar: AppBar(
            backgroundColor: const Color(0xFF131E29),
            elevation: 0,
            leading: const Icon(Icons.payment, color: Colors.white70), // Replaced back arrow with informative icon
            title: Text(
              'Pembayaran',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white54),
              onPressed: () async {
                final shouldPop = await _onWillPop();
                if (shouldPop) {
                  // Explicitly cancel on Close button
                  if (widget.idLangganan != 0) {
                    subscriptionViewModel.cancelSubscription(widget.idLangganan);
                  }
                  Get.back();
                }
              },
              tooltip: 'Tutup & Batalkan',
            ),
          ],
        ),
        body: Stack(
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
            Obx(
              () => isPaymentFinished.value
                  ? Positioned(
                      bottom: 32,
                      left: 24,
                      right: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00C2FF).withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Get.offAllNamed(Routes.DASHBOARD);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C2FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'KEMBALI KE DASHBOARD',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRedirect(String url) {
    try {
      final Uri uri = Uri.parse(url);
      final String? statusCode = uri.queryParameters['status_code'];
      final String? transactionStatus = uri.queryParameters['transaction_status'];
      final String? orderId = uri.queryParameters['order_id'];

      debugPrint('🌐 Redirect detected: Status=$statusCode, TransStatus=$transactionStatus');

      if (statusCode == '200' || transactionStatus == 'settlement' || transactionStatus == 'capture') {
        isPaymentFinished.value = true;
        _finishPayment(true, 'Pembayaran berhasil! Langganan Anda akan segera aktif.', orderId, stayOnPage: true);
      } else if (statusCode == '201' || transactionStatus == 'pending') {
        _finishPayment(false, 'Pembayaran sedang diproses. Silakan selesaikan pembayaran.', orderId);
      } else if (statusCode == '202' || transactionStatus == 'cancel' || transactionStatus == 'expire' || transactionStatus == 'expired' || url.contains('/unfinish')) {
        // If expired or explicitly canceled, we return to the method list
        if (transactionStatus == 'expire' || transactionStatus == 'expired') {
          if (widget.idLangganan != 0) {
            subscriptionViewModel.cancelSubscription(widget.idLangganan);
          }
        }
        
        SnackbarUtils.showInfo('Informasi', 'Kembali ke daftar metode pembayaran.');
        _controller.loadRequest(Uri.parse(widget.redirectUrl));
      } else if (url.contains('/error') || statusCode == '407') {
        _finishPayment(false, 'Pembayaran gagal. Silakan coba lagi.', orderId);
      } else {
        _controller.loadRequest(Uri.parse(widget.redirectUrl));
      }
    } catch (e) {
      debugPrint('Error parsing redirect URL: $e');
      _controller.loadRequest(Uri.parse(widget.redirectUrl));
    }
  }


  void _finishPayment(bool isSuccess, String message, String? orderId, {bool stayOnPage = false}) {
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
    
    if (stayOnPage) return; // Wait for user to click button

    // Safely exit
    if (Get.isOverlaysOpen) Get.back(); 
    
    Future.delayed(const Duration(milliseconds: 200), () {
      // Check if we are still on the WebView page before calling back
      if (Get.currentRoute == Routes.MIDTRANS_WEBVIEW || Get.currentRoute.contains('MidtransWebView')) {
        Get.back();
      }
    });
  }

  void _checkPaymentStatus(String url) {
    if (url.contains('status_code=200') || url.contains('transaction_status=settlement')) {
      isPaymentFinished.value = true;
      _finishPayment(true, 'Pembayaran berhasil!', null, stayOnPage: true);
    }
  }
}

