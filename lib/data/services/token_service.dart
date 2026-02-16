import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService extends GetxService {
  static const String _tokenKey = 'auth_token';
  
  SharedPreferences? _prefs;

  Future<TokenService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Save token
  Future<void> saveToken(String token) async {
    await _prefs?.setString(_tokenKey, token);
    print('✅ Token saved: ${token.substring(0, 20)}...');
  }

  // Get token
  String? getToken() {
    final token = _prefs?.getString(_tokenKey);
    if (token != null) {
      print('📌 Token retrieved: ${token.substring(0, 20)}...');
    } else {
      print('⚠️ No token found');
    }
    return token;
  }

  // Clear token
  Future<void> clearToken() async {
    await _prefs?.remove(_tokenKey);
    print('🗑️ Token cleared');
  }

  // Check if token exists
  bool hasToken() {
    return _prefs?.getString(_tokenKey) != null;
  }
}
