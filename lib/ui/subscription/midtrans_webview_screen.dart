import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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
          onPressed: () {
            Get.dialog(
              AlertDialog(
                backgroundColor: const Color(0xFF131E29),
                title: const Text('Batalkan Pembayaran?', style: TextStyle(color: Colors.white)),
                content: const Text(
                  'Apakah Anda yakin ingin membatalkan pembayaran?',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Tidak', style: TextStyle(color: Colors.white54)),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back(); // Close dialog
                      Get.back(); // Close WebView
                    },
                    child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
          },
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
          : _buildWindowsFallback(redirectUrl),
    );
  }

  Widget _buildWindowsFallback(String url) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.monitor, size: 64, color: Colors.cyan),
          const SizedBox(height: 16),
          Text(
            'Pembayaran di Windows',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Silakan lanjutkan pembayaran di browser Anda',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final Uri uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            icon: const Icon(Icons.open_in_browser),
            label: const Text('Buka Halaman Pembayaran'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
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
          onWebResourceError: (WebResourceError error) {
            Get.snackbar(
              'Error',
              'Gagal memuat halaman pembayaran',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  void _checkPaymentStatus(String url) {
    // Check if payment is completed based on URL
    if (url.contains('status_code=200') || url.contains('transaction_status=settlement')) {
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Pembayaran berhasil! Langganan Anda akan segera aktif.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF4ADE80),
        colorText: Colors.white,
      );
    } else if (url.contains('status_code=201') || url.contains('transaction_status=pending')) {
      Get.back();
      Get.snackbar(
        'Menunggu',
        'Pembayaran sedang diproses. Silakan selesaikan pembayaran.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFA500),
        colorText: Colors.white,
      );
    } else if (url.contains('status_code=202') || url.contains('transaction_status=cancel')) {
      Get.back();
      Get.snackbar(
        'Dibatalkan',
        'Pembayaran dibatalkan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        Obx(() => isLoading.value
            ? Container(
                color: const Color(0xFF0A1118),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: const Color(0xFF00C2FF)),
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
            : const SizedBox.shrink()),
      ],
    );
  }
}
