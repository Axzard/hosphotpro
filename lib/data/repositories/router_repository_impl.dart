import '../../domain/models/router_model.dart';
import '../../domain/models/router_repository.dart';
import '../services/router_service.dart';
import '../model/router_api_model.dart';

class RouterRepositoryImpl implements RouterRepository {
  final RouterService _routerService;

  RouterRepositoryImpl(this._routerService);

  @override
  Future<List<RouterModel>> getRouters() async {
    final response = await _routerService.getRouters();
    if (response.success && response.data != null) {
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
}
