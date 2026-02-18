import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PaymentPersistenceService extends GetxService {
  static const String _pendingPaymentsKey = 'pending_subscription_payments';
  
  SharedPreferences? _prefs;

  Future<PaymentPersistenceService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  /// Save a pending payment URL for a specific subscription ID
  Future<void> savePendingPayment(int idLangganan, String paymentUrl) async {
    final Map<String, String> pending = _getPendingMap();
    pending[idLangganan.toString()] = paymentUrl;
    await _prefs?.setString(_pendingPaymentsKey, _encodeMap(pending));
  }

  /// Get a pending payment URL for a specific subscription ID
  String? getPendingUrl(int idLangganan) {
    final Map<String, String> pending = _getPendingMap();
    return pending[idLangganan.toString()];
  }

  /// Remove a pending payment entry
  Future<void> clearPendingPayment(int idLangganan) async {
    final Map<String, String> pending = _getPendingMap();
    if (pending.containsKey(idLangganan.toString())) {
      pending.remove(idLangganan.toString());
      await _prefs?.setString(_pendingPaymentsKey, _encodeMap(pending));
    }
  }

  // Internal helper to get the map from storage
  Map<String, String> _getPendingMap() {
    final String? jsonStr = _prefs?.getString(_pendingPaymentsKey);
    if (jsonStr == null || jsonStr.isEmpty) return {};
    
    try {
      final Map<String, dynamic> decoded = _decodeMap(jsonStr);
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return {};
    }
  }

  String _encodeMap(Map<String, String> map) {
    return json.encode(map);
  }

  Map<String, dynamic> _decodeMap(String jsonStr) {
    return json.decode(jsonStr);
  }
}
