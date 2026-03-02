import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../model/api_response.dart';
import '../../config/api_config.dart';
import '../model/voucher_api_model.dart';
import '../model/voucher_package_api_model.dart';
import 'token_service.dart';

class VoucherService extends GetxService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );
  final TokenService _tokenService = Get.find<TokenService>();

  Future<ApiResponse<List<VoucherPackageApiModel>>> getVoucherPackages(
    int idHotspot,
  ) async {
    if (idHotspot <= 0) return getAllVoucherPackages();
    try {
      final token = _tokenService.getToken();
      final response = await _dio.get(
        ApiConfig.packagesByHotspot(idHotspot),
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
            .map((json) => VoucherPackageApiModel.fromJson(json))
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

  Future<ApiResponse<List<VoucherPackageApiModel>>>
  getAllVoucherPackages() async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.get(
        ApiConfig.paketVoucherUser,
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
            .map((json) => VoucherPackageApiModel.fromJson(json))
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

  Future<ApiResponse<VoucherPackageApiModel?>> createVoucherPackage(
    VoucherPackageApiModel package,
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
        VoucherPackageApiModel? createdPackage;
        if (response.data['id_paket'] != null) {
          createdPackage = VoucherPackageApiModel(
            id: response.data['id_paket'],
            idRouter: package.idRouter,
            idHotspot: package.idHotspot,
            namaPaket: package.namaPaket,
            durasi: package.durasi,
            harga: package.harga,
            namaProfileMikrotik: package.namaProfileMikrotik,
            prefix: package.prefix,
            panjangUsername: package.panjangUsername,
            formatKarakter: package.formatKarakter,
            dataLimitMb: package.dataLimitMb,
          );
        } else if (response.data['data'] != null) {
          createdPackage = VoucherPackageApiModel.fromJson(
            response.data['data'],
          );
        }
        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Package created',
          data: createdPackage,
        );
      } else {
        String errorMsg = 'Server Error (${response.statusCode})';
        if (response.data is Map<String, dynamic>) {
          errorMsg =
              response.data['pesan'] ?? response.data['detail'] ?? errorMsg;
        } else if (response.data is String &&
            response.data.toString().isNotEmpty) {
          errorMsg = response.data.toString();
        }
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

  Future<ApiResponse<VoucherPackageApiModel?>> getVoucherPackageDetail(
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
        final package = VoucherPackageApiModel.fromJson(
          response.data['data'] ?? response.data,
        );
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

  Future<ApiResponse<void>> updateVoucherPackage(
    int id,
    VoucherPackageApiModel package,
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

  Future<ApiResponse<List<VoucherApiModel>>> getVouchersByPackage(
    int idPaket,
  ) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.get(
        ApiConfig.vouchersByPackage(idPaket),
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'] ?? [];
        final vouchers = data
            .map((json) => VoucherApiModel.fromJson(json))
            .toList();
        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Vouchers fetched',
          data: vouchers,
        );
      } else {
        final errorMsg =
            response.data?['pesan'] ??
            response.data?['detail'] ??
            'Status code: ${response.statusCode}';
        return ApiResponse(success: false, message: errorMsg, data: []);
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString(), data: []);
    }
  }

  Future<ApiResponse<List<VoucherApiModel>>> getVouchersByHotspot(
    int idHotspot,
  ) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.get(
        ApiConfig.vouchersByHotspot(idHotspot),
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'] ?? [];
        final vouchers = data
            .map((json) => VoucherApiModel.fromJson(json))
            .toList();
        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Vouchers fetched',
          data: vouchers,
        );
      } else {
        final errorMsg =
            response.data?['pesan'] ??
            response.data?['detail'] ??
            'Status code: ${response.statusCode}';
        return ApiResponse(success: false, message: errorMsg, data: []);
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString(), data: []);
    }
  }

  Future<ApiResponse<VoucherApiModel?>> getVoucherDetail(int id) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.get(
        ApiConfig.voucherDetail(id),
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200 && response.data['sukses'] == true) {
        final voucher = VoucherApiModel.fromJson(response.data['data']);
        return ApiResponse(success: true, message: 'OK', data: voucher);
      } else {
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'Voucher not found',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<VoucherApiModel?>> createVoucher(int idPaket) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.post(
        ApiConfig.createVoucher,
        data: {'id_paket': idPaket},
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        VoucherApiModel? voucher;
        if (response.data['data'] != null) {
          voucher = VoucherApiModel.fromJson(response.data['data']);
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
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<List<VoucherApiModel>>> createVoucherBulk(
    int idPaket,
    int jumlah,
  ) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.post(
        ApiConfig.createVoucherBulk,
        data: {'id_paket': idPaket, 'jumlah': jumlah},
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        List<VoucherApiModel> vouchers = [];
        if (response.data['data'] != null && response.data['data'] is List) {
          vouchers = (response.data['data'] as List)
              .map((json) => VoucherApiModel.fromJson(json))
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
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e', data: []);
    }
  }

  Future<ApiResponse<void>> deleteVoucher(int id) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.delete(
        ApiConfig.deleteVoucher(id),
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
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
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<List<VoucherApiModel>>> getActiveVouchers() async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.get(
        ApiConfig.vouchersAktif,
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200) {
        final dynamic rawData = response.data;
        List<dynamic> listData = [];

        if (rawData is Map<String, dynamic>) {
          listData = rawData['data'] is List ? rawData['data'] : [];
        } else if (rawData is List) {
          listData = rawData;
        }

        final vouchers = listData
            .map((json) => VoucherApiModel.fromJson(json))
            .toList();
        return ApiResponse(
          success: true,
          message: 'Vouchers fetched',
          data: vouchers,
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'Failed to fetch active vouchers',
          data: [],
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e', data: []);
    }
  }

  Future<ApiResponse<double>> sellVoucher(int id, String paymentMethod) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.post(
        ApiConfig.sellVoucher(id),
        data: {'metode_pembayaran': paymentMethod},
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200 && response.data['sukses'] == true) {
        return ApiResponse(
          success: true,
          message: response.data['pesan'] ?? 'Voucher berhasil dijual',
          data: double.tryParse(response.data['harga']?.toString() ?? '0') ?? 0,
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['pesan'] ?? 'Gagal menjual voucher',
          data: 0,
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e', data: 0);
    }
  }
}
