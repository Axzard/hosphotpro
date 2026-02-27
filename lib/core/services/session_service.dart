import 'package:get/get.dart';

class SessionService extends GetxService {
  final RxnString selectedRouterId = RxnString('all');
  
  // Separate hotspot IDs for different screens to avoid "bleeding" selections
  final RxnInt voucherHotspotId = RxnInt();
  final RxnInt packageHotspotId = RxnInt();

  void setRouterId(String? id) {
    selectedRouterId.value = id ?? 'all';
  }

  void setVoucherHotspotId(int? id) {
    voucherHotspotId.value = id;
  }

  void setPackageHotspotId(int? id) {
    packageHotspotId.value = id;
  }
}
