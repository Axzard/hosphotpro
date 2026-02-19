import 'package:get/get.dart';
import '../../domain/models/router_model.dart';
import '../../domain/models/hotspot_model.dart';

class SelectionService extends GetxService {
  final Rxn<RouterModel> selectedRouter = Rxn<RouterModel>();
  final Rxn<HotspotModel> selectedHotspot = Rxn<HotspotModel>();

  void updateRouter(RouterModel? router) {
    if (selectedRouter.value?.id == router?.id) return;
    
    // Only clear selectedHotspot if the router is literally different
    if (selectedRouter.value?.id != router?.id) {
      selectedHotspot.value = null;
    }
    
    selectedRouter.value = router;
  }

  void updateHotspot(HotspotModel? hotspot) {
    selectedHotspot.value = hotspot;
  }
}
