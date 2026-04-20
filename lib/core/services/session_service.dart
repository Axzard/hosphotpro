import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService extends GetxService {
  late SharedPreferences _prefs;
  
  final RxnString selectedRouterId = RxnString('all');
  final RxnInt voucherHotspotId = RxnInt();
  final RxnInt packageHotspotId = RxnInt();

  Future<SessionService> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Load persisted values
    selectedRouterId.value = _prefs.getString('selected_router_id') ?? 'all';
    voucherHotspotId.value = _prefs.getInt('voucher_hotspot_id');
    packageHotspotId.value = _prefs.getInt('package_hotspot_id');
    
    return this;
  }

  void setRouterId(String? id) {
    selectedRouterId.value = id ?? 'all';
    _prefs.setString('selected_router_id', selectedRouterId.value!);
  }

  void setVoucherHotspotId(int? id) {
    voucherHotspotId.value = id;
    if (id != null) {
      _prefs.setInt('voucher_hotspot_id', id);
    } else {
      _prefs.remove('voucher_hotspot_id');
    }
  }

  void setPackageHotspotId(int? id) {
    packageHotspotId.value = id;
    if (id != null) {
      _prefs.setInt('package_hotspot_id', id);
    } else {
      _prefs.remove('package_hotspot_id');
    }
  }
}
