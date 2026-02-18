import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../model/api_response.dart';
import '../../config/api_config.dart';
import '../../domain/models/voucher_model.dart';
import '../../domain/models/voucher_package_model.dart';
import 'token_service.dart';

class VoucherService extends GetxService {
  final Dio _dio = Dio();
  final TokenService _tokenService = Get.find<TokenService>();

  /// GET /api/paket-voucher/router/{idRouter}
  Future<ApiResponse<List<VoucherPackageModel>>> getVoucherPackages(
    int idRouter,
  ) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.get(
        ApiConfig.packagesByRouter(idRouter),
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic rawData = response.data;
        List<dynamic> listData = [];
        String? message;

        if (rawData is Map<String, dynamic>) {
          listData = rawData['data'] is List ? rawData['data'] : [];
          message = rawData['pesan'];
        } else if (rawData is List) {
          listData = rawData;
        }

        final packages = listData
            .map((json) => VoucherPackageModel.fromJson(json))
            .toList();
            
        return ApiResponse(
          success: true,
          message: message ?? 'Packages fetched',
          data: packages,
        );
      } else {
        final errorMsg =
            response.data?['pesan'] ??
            response.data?['detail'] ??
            'Server Error (${response.statusCode}): ${response.data}';
        return ApiResponse(success: false, message: errorMsg, data: []);
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.message} ${e.response?.data}',
        data: [],
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e', data: []);
    }
  }

  /// POST /api/paket-voucher
  Future<ApiResponse<VoucherPackageModel?>> createVoucherPackage(
    VoucherPackageModel package,
  ) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.post(
        ApiConfig.voucherPackages,
        data: package.toJson(),
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        VoucherPackageModel? createdPackage;
        if (response.data['id_paket'] != null) {
          createdPackage = VoucherPackageModel(
            id: response.data['id_paket'],
            idRouter: package.idRouter,
            idHotspot: package.idHotspot,
            namaPaket: package.namaPaket,
            durasi: package.durasi,
            harga: package.harga,
            namaProfileMikrotik: package.namaProfileMikrotik,
          );
        } else if (response.data['data'] != null) {
          createdPackage = VoucherPackageModel.fromJson(response.data['data']);
        }
        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Package created',
          data: createdPackage,
        );
      } else {
        final errorMsg =
            response.data?['pesan'] ??
            response.data?['detail'] ??
            'Server Error (${response.statusCode})';
        return ApiResponse(success: false, message: errorMsg);
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.message} ${e.response?.data}',
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  /// GET /api/paket-voucher/{id}
  Future<ApiResponse<VoucherPackageModel?>> getVoucherPackageDetail(
    int id,
  ) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.get(
        ApiConfig.voucherPackageDetail(id),
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200 || response.data['sukses'] == true) {
        final package = VoucherPackageModel.fromJson(response.data['data'] ?? response.data);
        return ApiResponse(success: true, message: 'OK', data: package);
      } else {
        return ApiResponse(
          success: false,
          message: response.data?['pesan'] ?? 'Package not found',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  /// PUT /api/paket-voucher/{id}
  Future<ApiResponse<void>> updateVoucherPackage(
    int id,
    VoucherPackageModel package,
  ) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.put(
        ApiConfig.updateVoucherPackage(id),
        data: package.toJson(),
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200 || response.data?['sukses'] == true) {
        return ApiResponse(
          success: true,
          message: response.data?['pesan'] ?? 'Package updated',
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data?['pesan'] ?? 'Failed to update package',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  /// DELETE /api/paket-voucher/{id}
  Future<ApiResponse<void>> deleteVoucherPackage(int id) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.delete(
        ApiConfig.deleteVoucherPackage(id),
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200 || response.data?['sukses'] == true) {
        return ApiResponse(
          success: true,
          message: response.data?['pesan'] ?? 'Package deleted',
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data?['pesan'] ?? 'Failed to delete package',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  /// GET /api/voucher/router/{idRouter}
  Future<ApiResponse<List<VoucherModel>>> getVouchersByRouter(
    int idRouter,
  ) async {
    try {
      final token = _tokenService.getToken();
      print('ItemsByRouter Token: $token');
      if (token == null) print('WARNING: Token is null');

      final response = await _dio.get(
        ApiConfig.vouchersByRouter(idRouter),
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'] ?? [];
        final vouchers = data
            .map((json) => VoucherModel.fromJson(json))
            .toList();
        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Vouchers fetched',
          data: vouchers,
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'Failed to fetch vouchers',
          data: [],
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.message}',
        data: [],
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e', data: []);
    }
  }

  /// GET /api/voucher/{id}?id_router={idRouter}
  Future<ApiResponse<VoucherModel?>> getVoucherDetail(
    int id,
    int idRouter,
  ) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.get(
        ApiConfig.voucherDetail(id, idRouter),
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 && response.data['sukses'] == true) {
        final voucher = VoucherModel.fromJson(response.data['data']);
        return ApiResponse(success: true, message: 'OK', data: voucher);
      } else {
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'Voucher not found',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  /// POST /api/voucher  (single)
  Future<ApiResponse<VoucherModel?>> createVoucher(
    int idPaket,
    int idRouter,
  ) async {
    try {
      final token = _tokenService.getToken();
      print('CreateVoucher Token: $token');

      final response = await _dio.post(
        ApiConfig.createVoucher,
        data: {'id_paket': idPaket, 'id_router': idRouter},
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        VoucherModel? voucher;
        if (response.data['data'] != null) {
          voucher = VoucherModel.fromJson(response.data['data']);
        }
        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Voucher created',
          data: voucher,
        );
      } else {
        return ApiResponse(
          success: false,
          message:
              response.data['pesan'] ?? response.data['detail'] ?? 'Failed',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  /// POST /api/voucher/bulk
  Future<ApiResponse<List<VoucherModel>>> createVoucherBulk(
    int idPaket,
    int idRouter,
    int jumlah,
  ) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.post(
        ApiConfig.createVoucherBulk,
        data: {'id_paket': idPaket, 'id_router': idRouter, 'jumlah': jumlah},
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<VoucherModel> vouchers = [];
        if (response.data['data'] != null && response.data['data'] is List) {
          vouchers = (response.data['data'] as List)
              .map((json) => VoucherModel.fromJson(json))
              .toList();
        }
        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Bulk vouchers created',
          data: vouchers,
        );
      } else {
        return ApiResponse(
          success: false,
          message:
              response.data['pesan'] ?? response.data['detail'] ?? 'Failed',
          data: [],
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.message}',
        data: [],
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e', data: []);
    }
  }

  /// DELETE /api/voucher/{id}?id_router={idRouter}
  Future<ApiResponse<void>> deleteVoucher(int id, int idRouter) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.delete(
        ApiConfig.deleteVoucher(id, idRouter),
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Voucher deleted',
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'Failed to delete voucher',
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }
}
