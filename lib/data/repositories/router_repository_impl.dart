import '../../domain/models/router_model.dart';
import '../../domain/models/hotspot_model.dart';
import '../../domain/repositories/router_repository.dart';
import '../services/router_service.dart';
import '../../core/services/cache_service.dart';
import '../model/router_api_model.dart';
import '../model/hotspot_api_model.dart';

class RouterRepositoryImpl implements RouterRepository {
  final RouterService _routerService;
  final CacheService _cacheService;

  RouterRepositoryImpl(this._routerService, this._cacheService);

  @override
  Future<List<RouterModel>> getRouters() async {
    final response = await _routerService.getRouters();
    if (response.success && response.data != null) {
      await _cacheService.saveRouters(response.data!.map((e) => e.toJson()).toList());
      return response.data!.map((apiModel) => apiModel.toDomain()).toList();
    }
    throw Exception(response.message);
  }

  @override
  Future<RouterModel> createRouter(RouterModel router) async {
    final apiModel = RouterApiModel.fromDomain(router);
    final response = await _routerService.createRouter(apiModel);
    if (response.success && response.data != null) {
      return response.data!.toDomain();
    }
    throw Exception(response.message);
  }

  @override
  Future<RouterModel> updateRouter(RouterModel router) async {
    final apiModel = RouterApiModel.fromDomain(router);
    final routerId = int.tryParse(router.id) ?? 0;
    if (routerId == 0) throw Exception('ID Router tidak valid: ${router.id}');
    final response = await _routerService.updateRouter(routerId, apiModel);
    if (response.success && response.data != null) {
      return response.data!.toDomain();
    }
    throw Exception(response.message);
  }

  @override
  Future<void> deleteRouter(String id) async {
    final routerId = int.tryParse(id) ?? 0;
    if (routerId == 0) throw Exception('ID Router tidak valid: $id');
    final response = await _routerService.deleteRouter(routerId);
    if (!response.success) {
      throw Exception(response.message);
    }
  }

  @override
  Future<List<HotspotModel>> getHotspots(int idRouter) async {
    final response = await _routerService.getHotspots(idRouter);
    if (response.success && response.data != null) {
      await _cacheService.saveHotspots(idRouter, response.data!.map((e) => e.toJson()).toList());
      return response.data!
          .map((apiModel) => apiModel.toDomain(idRouterOverride: idRouter))
          .toList();
    }
    throw Exception(response.message);
  }

  @override
  Future<List<HotspotModel>> getAllHotspots() async {
    final response = await _routerService.getAllHotspots();
    if (response.success && response.data != null) {
      return response.data!.map((apiModel) => apiModel.toDomain()).toList();
    }
    throw Exception(response.message);
  }

  @override
  Future<HotspotModel> getHotspotDetail(int idHotspot) async {
    final response = await _routerService.getHotspotDetail(idHotspot);
    if (response.success && response.data != null) {
      return response.data!.toDomain();
    }
    throw Exception(response.message);
  }

  @override
  Future<void> updateHotspot(int idHotspot, Map<String, dynamic> data) async {
    final response = await _routerService.updateHotspot(idHotspot, data);
    if (!response.success) {
      throw Exception(response.message);
    }
  }

  @override
  Future<void> deleteHotspot(int idHotspot) async {
    final response = await _routerService.deleteHotspot(idHotspot);
    if (!response.success) {
      throw Exception(response.message);
    }
  }

  @override
  Future<List<dynamic>> syncHotspots(int idRouter) async {
    final response = await _routerService.syncHotspots(idRouter);
    if (!response.success) {
      throw Exception(response.message);
    }
    return response.data ?? [];
  }

  @override
  Future<Map<String, dynamic>> pingRouter(int id) async {
    final response = await _routerService.pingRouter(id);
    if (!response.success) {
      throw Exception(response.message);
    }
    return response.data ?? {};
  }

  @override
  Future<List<RouterModel>> getRoutersFromCache() async {
    final cached = _cacheService.getRouters();
    if (cached == null) return [];
    return cached
        .map((json) => RouterApiModel.fromJson(json as Map<String, dynamic>).toDomain())
        .toList();
  }

  @override
  Future<List<HotspotModel>> getHotspotsFromCache(int idRouter) async {
    final cached = _cacheService.getHotspots(idRouter);
    if (cached == null) return [];
    return cached
        .map((json) => HotspotApiModel.fromJson(json as Map<String, dynamic>)
            .toDomain(idRouterOverride: idRouter))
        .toList();
  }

  @override
  Future<void> updateRouterCache(List<RouterModel> routers) async {
    await _cacheService.saveRouters(
      routers.map((e) => RouterApiModel.fromDomain(e).toJson()).toList(),
    );
  }

  @override
  Future<void> updateHotspotCache(int idRouter, List<HotspotModel> hotspots) async {
    await _cacheService.saveHotspots(
      idRouter,
      hotspots.map((e) => HotspotApiModel.fromDomain(e).toJson()).toList(),
    );
  }
}
