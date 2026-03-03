import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService extends GetxService {
  late SharedPreferences _prefs;

  Future<CacheService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  static const _keyDashboard = 'cached_dashboard_data';
  static const _keyReports = 'cached_reports_data';

  Future<void> _save(String key, dynamic data) async {
    if (data == null) return;
    await _prefs.setString(key, jsonEncode(data));
  }

  dynamic _get(String key) {
    final str = _prefs.getString(key);
    if (str == null) return null;
    try {
      return jsonDecode(str);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveDashboard(Map<String, dynamic> data) =>
      _save(_keyDashboard, data);
  Map<String, dynamic>? getDashboard() =>
      _get(_keyDashboard) as Map<String, dynamic>?;

  Future<void> saveReports(Map<String, dynamic> data) =>
      _save(_keyReports, data);
  Map<String, dynamic>? getReports() =>
      _get(_keyReports) as Map<String, dynamic>?;

  Future<void> clearAll() => _prefs.clear();
}
