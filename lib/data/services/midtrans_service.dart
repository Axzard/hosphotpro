import 'package:get/get.dart';

class MidtransService extends GetxService {
  bool _isInitialized = false;

  void initialize({
    required String clientKey,
    required String merchantBaseUrl,
    bool isProduction = false,
  }) {
    _isInitialized = true;
    print('Midtrans initialized with clientKey: $clientKey');
  }

  Future<Map<String, dynamic>?> startPayment(String snapToken) async {
    if (!_isInitialized) {
      print('Midtrans not initialized');
      return null;
    }

    try {
      return await mockPayment(snapToken);
    } catch (e) {
      print('Midtrans payment error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> mockPayment(String snapToken) async {
    await Future.delayed(const Duration(seconds: 3));

    return {
      'status': 'success',
      'transaction_id': 'mock_trx_${DateTime.now().millisecondsSinceEpoch}',
      'payment_type': 'mock_payment',
    };
  }
}
