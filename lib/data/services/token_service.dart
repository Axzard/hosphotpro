import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenService extends GetxService {
  static const String _tokenKey = 'auth_token';
  static const String _loginTimeKey = 'login_time';
  static const String _usernameKey = 'auth_username';
  
  SharedPreferences? _prefs;

  Future<TokenService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Save token
  Future<void> saveToken(String token) async {
    await _prefs?.setString(_tokenKey, token);
    await saveLoginTime();
    print('Token saved: ${token.substring(0, 20)}...');
  }

  // Save username
  Future<void> saveUsername(String username) async {
    await _prefs?.setString(_usernameKey, username);
    print('Username saved: $username');
  }

  // Save login time
  Future<void> saveLoginTime() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _prefs?.setInt(_loginTimeKey, now);
    print('Login time saved: $now');
  }

  // Get login time
  int? getLoginTime() {
    return _prefs?.getInt(_loginTimeKey);
  }

  // Get token
  String? getToken() {
    final token = _prefs?.getString(_tokenKey);
    if (token != null) {
      print('Token retrieved: ${token.substring(0, 20)}...');
    } else {
      print(' No token found');
    }
    return token;
  }

  // Get username
  String? getUsername() {
    return _prefs?.getString(_usernameKey);
  }

  // Clear token
  Future<void> clearToken() async {
    await _prefs?.remove(_tokenKey);
    await _prefs?.remove(_loginTimeKey);
    await _prefs?.remove(_usernameKey);
    print('Token, login time, and username cleared');
  }

  // Check if token exists
  bool hasToken() {
    return _prefs?.getString(_tokenKey) != null;
  }

  // Check if token is expired (1 day = 24 hours)
  bool isTokenExpired() {
    final loginTime = getLoginTime();
    if (loginTime == null) return true;

    final lastLogin = DateTime.fromMillisecondsSinceEpoch(loginTime);
    final now = DateTime.now();
    final difference = now.difference(lastLogin);

    return difference.inDays >= 1;
  }
}
