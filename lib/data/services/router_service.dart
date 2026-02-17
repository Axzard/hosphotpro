import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../model/router_api_model.dart';
import '../model/api_response.dart';
import '../../config/api_config.dart';
import 'token_service.dart';

class RouterService extends GetxService {
  final Dio _dio = Dio();
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

  Future<ApiResponse<RouterApiModel>> createRouter(RouterApiModel router) async {
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
        // Handle case where backend returns success but no data
        RouterApiModel? createdRouter;
        if (response.data['data'] != null) {
          createdRouter = RouterApiModel.fromJson(response.data['data']);
        } else {
          // If no data returned, use the router we sent
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

  Future<ApiResponse<RouterApiModel>> updateRouter(int id, RouterApiModel router) async {
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
        // Handle case where backend returns success but no data
        RouterApiModel? updatedRouter;
        if (response.data['data'] != null) {
          updatedRouter = RouterApiModel.fromJson(response.data['data']);
        } else {
          // If no data returned, use the router we sent
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
}
