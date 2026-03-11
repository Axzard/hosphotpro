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
  static const _keyRouters = 'cached_routers';
  static const _keyHotspots = 'cached_hotspots_';
  static const _keyVoucherPackages = 'cached_voucher_packages_';
  static const _keyVouchers = 'cached_vouchers_';
  static const _keyDailyReports = 'cached_daily_reports_';

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

  Future<void> _saveList(String key, List<dynamic> data) async {
    await _prefs.setString(key, jsonEncode(data));
  }

  List<dynamic>? _getList(String key) {
    final str = _prefs.getString(key);
    if (str == null) return null;
    try {
      return jsonDecode(str) as List<dynamic>?;
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

  Future<void> saveRouters(List<dynamic> data) => _saveList(_keyRouters, data);
  List<dynamic>? getRouters() => _getList(_keyRouters);

  Future<void> saveHotspots(int idRouter, List<dynamic> data) =>
      _saveList('$_keyHotspots$idRouter', data);
  List<dynamic>? getHotspots(int idRouter) =>
      _getList('$_keyHotspots$idRouter');

  Future<void> saveVoucherPackages(int idHotspot, List<dynamic> data) =>
      _saveList('$_keyVoucherPackages$idHotspot', data);
  List<dynamic>? getVoucherPackages(int idHotspot) =>
      _getList('$_keyVoucherPackages$idHotspot');

  Future<void> saveVouchers(int idHotspot, List<dynamic> data) =>
      _saveList('$_keyVouchers$idHotspot', data);
  List<dynamic>? getVouchers(int idHotspot) =>
      _getList('$_keyVouchers$idHotspot');

  Future<void> saveDailyReports(String dateKey, List<dynamic> data) =>
      _saveList('$_keyDailyReports$dateKey', data);
  List<dynamic>? getDailyReports(String dateKey) =>
      _getList('$_keyDailyReports$dateKey');

  Future<void> clearAll() => _prefs.clear();
}
