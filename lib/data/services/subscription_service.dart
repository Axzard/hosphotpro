import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../model/subscription_package_api_model.dart';
import '../model/transaction_api_model.dart';
import '../model/api_response.dart';
import '../../config/api_config.dart';
import '../model/user_subscription_api_model.dart';
import 'token_service.dart';

List<SubscriptionPackageApiModel> _parsePackages(dynamic data) {
  final list = data as List<dynamic>;
  return list.map((json) => SubscriptionPackageApiModel.fromJson(json as Map<String, dynamic>)).toList();
}

List<UserSubscriptionApiModel> _parseSubscriptions(dynamic data) {
  final list = data as List<dynamic>;
  return list.map((json) => UserSubscriptionApiModel.fromJson(json as Map<String, dynamic>)).toList();
}

class SubscriptionService extends GetxService {
  final Dio _dio = ApiConfig.createDio();
  final TokenService _tokenService = Get.find<TokenService>();

  Future<ApiResponse<List<SubscriptionPackageApiModel>>> getPackages() async {
    try {
      final token = _tokenService.getToken();
      final url = ApiConfig.packages;

      final response = await _dio.get(
        url,
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> packagesData = response.data['data'] ?? [];
        final packages = await compute(_parsePackages, packagesData);


        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Packages fetched successfully',
          data: packages,
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'Failed to fetch packages',
          data: [],
        );
      }
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Failed to fetch packages: ${e.message}',
        data: [],
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Unexpected error: $e',
        data: [],
      );
    }
  }

  Future<ApiResponse<SubscriptionPackageApiModel?>> getPackageDetail(
    int id,
  ) async {
    try {
      final token = _tokenService.getToken();

      final response = await _dio.get(
        ApiConfig.packageDetail(id),
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final packageData = response.data['data'];
        if (packageData != null) {
          return ApiResponse(
            success: true,
            message: response.data['pesan'] ?? 'Package detail fetched',
            data: SubscriptionPackageApiModel.fromJson(packageData),
          );
        }
      }

      return ApiResponse(
        success: false,
        message: response.data['pesan'] ?? 'Failed to fetch package detail',
        data: null,
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error: ${e.message}',
        data: null,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> createSubscription(
    int packageId,
    int jumlahBulan,
  ) async {
    try {
      final token = _tokenService.getToken();
      final data = {
        'id_paket_langganan': packageId,
        'jumlah_bulan': jumlahBulan,
      };

      final response = await _dio.post(
        ApiConfig.createSubscription,
        data: data,
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message:
              response.data['pesan'] ??
              response.data['message'] ??
              'Subscription created',
          data: response.data['data'] != null
              ? response.data['data']
              : response.data,
        );
      } else {
        return ApiResponse(
          success: false,
          message:
              response.data['pesan'] ??
              response.data['message'] ??
              'Failed to create subscription',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<List<UserSubscriptionApiModel>>>
  getMySubscriptions() async {
    try {
      final token = _tokenService.getToken();

      final response = await _dio.get(
        ApiConfig.mySubscriptions,
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> subscriptionsData = response.data['data'] ?? [];
        final subscriptions = await compute(_parseSubscriptions, subscriptionsData);


        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Subscriptions fetched',
          data: subscriptions,
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'Failed to fetch subscriptions',
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
      return ApiResponse(
        success: false,
        message: 'Unexpected error: $e',
        data: [],
      );
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateSubscriptionStatus(
    int id,
    String status,
  ) async {
    try {
      final token = _tokenService.getToken();
      final data = {'status': status};

      final response = await _dio.put(
        ApiConfig.updateSubscriptionStatus(id),
        data: data,
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message:
              response.data['pesan'] ??
              response.data['message'] ??
              'Status updated',
          data: response.data['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message:
              response.data['pesan'] ??
              response.data['message'] ??
              'Failed to update status',
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

  Future<ApiResponse<TransactionApiModel>> createTransaction({
    required int idLangganan,
    required int idPaketLangganan,
    required int jumlahBulan,
    String? metodePembayaran,
  }) async {
    final Map<String, dynamic> data = {
      'id_langganan': idLangganan.toString(),
      'id_subscription': idLangganan.toString(),
      'id_paket_langganan': idPaketLangganan.toString(),
      'id_paket': idPaketLangganan.toString(),
      'jumlah_bulan': jumlahBulan.toString(),
    };

    if (metodePembayaran != null && metodePembayaran.isNotEmpty) {
      data['metode_pembayaran'] = metodePembayaran;
    }

    return _processTransaction(
      url: ApiConfig.checkout,
      data: data,
      idPaketLangganan: idPaketLangganan,
    );
  }

  Future<ApiResponse<TransactionApiModel>> renewTransaction({
    required int jumlahBulan,
    int? idLangganan,
    int? idPaketLangganan,
    String? metodePembayaran,
  }) async {
    final Map<String, dynamic> data = {
      'jumlah_bulan': jumlahBulan.toString(),
      'id_langganan': idLangganan?.toString(),
      'id_subscription': idLangganan?.toString(),
      'id_paket_langganan': idPaketLangganan?.toString(),
      'id_paket': idPaketLangganan?.toString(),
    };

    if (metodePembayaran != null && metodePembayaran.isNotEmpty) {
      data['metode_pembayaran'] = metodePembayaran;
    }

    return _processTransaction(
      url: ApiConfig.perpanjang,
      data: data,
      idPaketLangganan: idPaketLangganan ?? 0,
    );
  }

  Future<ApiResponse<TransactionApiModel>> _processTransaction({
    required String url,
    required Map<String, dynamic> data,
    required int idPaketLangganan,
  }) async {
    try {
      final token = _tokenService.getToken();

      final response = await _dio.post(
        url,
        data: data,
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        final transaction = TransactionApiModel.fromJson(responseData).copyWith(
          packageId: idPaketLangganan.toString(),
          packageName: 'Subscription Package',
        );

        return ApiResponse(
          success: true,
          message:
              responseData['message'] ?? responseData['pesan'] ?? 'Success',
          data: transaction,
        );
      } else {
        return ApiResponse(
          success: false,
          message:
              response.data['message'] ??
              response.data['pesan'] ??
              'Failed to process transaction',
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
