import '../models/router_model.dart';
import '../models/hotspot_model.dart';

abstract class RouterRepository {
  Future<List<RouterModel>> getRouters();
  Future<RouterModel> createRouter(RouterModel router);
  Future<RouterModel> updateRouter(RouterModel router);
  Future<void> deleteRouter(String id);
  Future<List<HotspotModel>> getHotspots(int idRouter);
  Future<List<HotspotModel>> getAllHotspots();
  Future<HotspotModel> getHotspotDetail(int idHotspot);
  Future<void> updateHotspot(int idHotspot, Map<String, dynamic> data);
  Future<void> deleteHotspot(int idHotspot);
  Future<List<dynamic>> syncHotspots(int idRouter);
  Future<Map<String, dynamic>> pingRouter(int id);
  
  // Cache methods
  Future<List<RouterModel>> getRoutersFromCache();
  Future<List<HotspotModel>> getHotspotsFromCache(int idRouter);
  Future<void> updateRouterCache(List<RouterModel> routers);
  Future<void> updateHotspotCache(int idRouter, List<HotspotModel> hotspots);
}
