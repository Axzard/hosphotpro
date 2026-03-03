import 'package:get/get.dart' hide FormData;
import 'package:dio/dio.dart';
import '../model/router_api_model.dart';
import '../model/hotspot_api_model.dart';
import '../model/api_response.dart';
import '../../config/api_config.dart';
import 'token_service.dart';

class RouterService extends GetxService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
    ),
  );
  final TokenService _tokenService = Get.find<TokenService>();

  Future<ApiResponse<List<RouterApiModel>>> getRouters() async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.get(
        ApiConfig.routers,
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> routersData = response.data['data'] ?? [];
        final routers = routersData
            .map((json) => RouterApiModel.fromJson(json))
            .toList();

        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Routers fetched successfully',
          data: routers,
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'Failed to fetch routers',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<RouterApiModel>> createRouter(
    RouterApiModel router,
  ) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.post(
        ApiConfig.routers,
        data: router.toJson(),
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        RouterApiModel? createdRouter;
        if (response.data['data'] != null) {
          createdRouter = RouterApiModel.fromJson(response.data['data']);
        } else {
          createdRouter = router;
        }

        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Router created successfully',
          data: createdRouter,
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'Failed to create router',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<RouterApiModel>> updateRouter(
    int id,
    RouterApiModel router,
  ) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.put(
        '${ApiConfig.routers}/$id',
        data: router.toJson(),
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        RouterApiModel? updatedRouter;
        if (response.data['data'] != null) {
          updatedRouter = RouterApiModel.fromJson(response.data['data']);
        } else {
          updatedRouter = router;
        }

        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Router updated successfully',
          data: updatedRouter,
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'Failed to update router',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<void>> deleteRouter(int id) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.delete(
        '${ApiConfig.routers}/$id',
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Router deleted successfully',
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'Failed to delete router',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<List<HotspotApiModel>>> getHotspots(int idRouter) async {
    if (idRouter == 0) return getAllHotspots();
    try {
      final token = _tokenService.getToken();
      final response = await _dio.get(
        ApiConfig.hotspots(idRouter),
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> hotspotsData = response.data['data'] ?? [];
        final hotspots = hotspotsData
            .map((json) => HotspotApiModel.fromJson(json))
            .toList();

        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Hotspots fetched successfully',
          data: hotspots,
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'Failed to fetch hotspots',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<List<HotspotApiModel>>> getAllHotspots() async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.get(
        ApiConfig.hotspotAll,
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> hotspotsData = response.data['data'] ?? [];
        final hotspots = hotspotsData
            .map((json) => HotspotApiModel.fromJson(json))
            .toList();

        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Hotspots fetched successfully',
          data: hotspots,
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'Failed to fetch all hotspots',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<HotspotApiModel>> getHotspotDetail(int idHotspot) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.get(
        ApiConfig.hotspotDetail(idHotspot),
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Hotspot fetched successfully',
          data: HotspotApiModel.fromJson(response.data['data']),
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'Failed to fetch hotspot',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<void>> updateHotspot(
    int idHotspot,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.put(
        ApiConfig.updateHotspot(idHotspot),
        data: data,
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200 || response.data['sukses'] == true) {
        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Hotspot updated successfully',
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'Failed to update hotspot',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<void>> deleteHotspot(int idHotspot) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.delete(
        ApiConfig.deleteHotspot(idHotspot),
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.data['sukses'] == true) {
        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Hotspot deleted successfully',
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'Failed to delete hotspot',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<List<dynamic>>> syncHotspots(int idRouter) async {
    try {
      final token = _tokenService.getToken();

      final response = await _dio.post(
        ApiConfig.syncHotspots,
        queryParameters: {'id_router': idRouter},
        data: {'id_router': idRouter},
        options: Options(
          headers: ApiConfig.headers(token: token),
          contentType: 'application/x-www-form-urlencoded',
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.data['sukses'] == true) {
        final rawData = response.data['data'];
        List<dynamic> resultData = [];
        
        if (rawData is List) {
          resultData = rawData;
        } else if (rawData is Map) {
          if (rawData['detail'] is List) {
            resultData = rawData['detail'];
          } else {
            resultData = [rawData];
          }
        }

        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Sinkronisasi hotspot selesai',
          data: resultData,
        );
      } else {
        return ApiResponse(
          success: false,
          message:
              response.data['pesan'] ??
              response.data['message'] ??
              'Gagal sinkronisasi hotspot',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> pingRouter(int id) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.get(
        ApiConfig.routerPing(id),
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
        ),
      );

      final responseData = response.data;
      final pingResult = responseData['data'] ?? responseData;

      return ApiResponse(
        success:
            response.statusCode == 200 && (responseData['sukses'] == true || responseData['success'] == true),
        message:
            responseData['pesan'] ??
            responseData['message'] ??
            'Ping complete',
        data: Map<String, dynamic>.from(pingResult),
      );

    } catch (e) {
      return ApiResponse(success: false, message: 'Ping error: $e');
    }
  }
}
