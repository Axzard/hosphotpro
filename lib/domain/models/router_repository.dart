import '../models/router_model.dart';

abstract class RouterRepository {
  Future<List<RouterModel>> getRouters();
  Future<RouterModel> createRouter(RouterModel router);
  Future<RouterModel> updateRouter(RouterModel router);
  Future<void> deleteRouter(String id);
}
