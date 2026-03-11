import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../model/api_response.dart';
import '../../config/api_config.dart';
import '../../core/utils/error_utils.dart';
import '../model/voucher_api_model.dart';
import '../model/voucher_package_api_model.dart';
import 'token_service.dart';

List<VoucherPackageApiModel> _parseVoucherPackages(dynamic data) {
  final list = data as List<dynamic>;
  return list
      .where((e) => e is Map)
      .map(
        (json) => VoucherPackageApiModel.fromJson(json as Map<String, dynamic>),
      )
      .toList();
}

List<VoucherApiModel> _parseVouchers(dynamic data) {
  final list = data as List<dynamic>;
  return list
      .where((e) => e is Map)
      .map((json) => VoucherApiModel.fromJson(json as Map<String, dynamic>))
      .toList();
}

class VoucherService extends GetxService {
  final Dio _dio = ApiConfig.createDio();
  final TokenService _tokenService = Get.find<TokenService>();

  String _getErrorMsg(dynamic data, String fallback) {
    if (data is Map) {
      return (data['pesan'] ?? data['detail'] ?? data['message'] ?? fallback)
          .toString();
    }
    if (data != null && data.toString().isNotEmpty) {
      return data.toString();
    }
    return fallback;
  }

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

        final packages = await compute(_parseVoucherPackages, listData);

        return ApiResponse(
          success: true,
          message: message ?? 'Packages fetched',
          data: packages,
        );
      } else {
        return ApiResponse(
          success: false,
          message: _getErrorMsg(response.data, 'Failed'),
          data: [],
        );
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

        final packages = await compute(_parseVoucherPackages, listData);

        return ApiResponse(
          success: true,
          message: message ?? 'Packages fetched',
          data: packages,
        );
      } else {
        return ApiResponse(
          success: false,
          message: _getErrorMsg(response.data, 'Failed'),
          data: [],
        );
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
        final respData = response.data;
        if (respData is Map) {
          if (respData['id_paket'] != null) {
            createdPackage = VoucherPackageApiModel(
              id: respData['id_paket'],
              idRouter: package.idRouter,
              idHotspot: package.idHotspot,
              namaPaket: package.namaPaket,
              durasi: package.durasi,
              harga: package.harga,
              prefix: package.prefix,
              panjangUsername: package.panjangUsername,
              formatKarakter: package.formatKarakter,
              rateLimit: package.rateLimit,
              gunakanSsl: package.gunakanSsl,
            );
          } else if (respData['data'] != null && respData['data'] is Map) {
            createdPackage = VoucherPackageApiModel.fromJson(
              respData['data'] as Map<String, dynamic>,
            );
          }
        }
        return ApiResponse(
          success: true,
          message: _getErrorMsg(response.data, 'Package created'),
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

      if (response.statusCode == 200 ||
          (response.data is Map && response.data['sukses'] == true)) {
        final respData = response.data;
        final rawData = respData is Map
            ? (respData['data'] ?? respData)
            : respData;
        if (rawData is Map) {
          final package = VoucherPackageApiModel.fromJson(
            rawData as Map<String, dynamic>,
          );
          return ApiResponse(success: true, message: 'OK', data: package);
        }
        return ApiResponse(success: false, message: 'Format data tidak valid');
      } else {
        String errorMsg = 'Package not found';
        final errData = response.data;
        if (errData is Map) {
          errorMsg = (errData['pesan'] ?? errData['detail'] ?? errorMsg)
              .toString();
        }
        return ApiResponse(success: false, message: errorMsg);
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
        String errorMsg = 'Gagal menghapus paket voucher';
        final dynamic respData = response.data;
        if (respData is Map) {
          errorMsg =
              (respData['pesan'] ??
                      respData['message'] ??
                      respData['detail'] ??
                      errorMsg)
                  .toString();
        } else if (respData != null && respData.toString().isNotEmpty) {
          errorMsg = ErrorUtils.sanitizeServerMessage(respData.toString());
        }
        return ApiResponse(success: false, message: errorMsg);
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
        final respData = response.data;
        final List<dynamic> data =
            (respData is Map ? respData['data'] : null) ?? [];
        final vouchers = await compute(_parseVouchers, data);
        return ApiResponse(
          success: true,
          message: _getErrorMsg(respData, 'Vouchers fetched'),
          data: vouchers,
        );
      } else {
        String errorMsg = 'Status code: ${response.statusCode}';
        final errData = response.data;
        if (errData is Map) {
          errorMsg = (errData['pesan'] ?? errData['detail'] ?? errorMsg)
              .toString();
        } else if (errData != null && errData.toString().isNotEmpty) {
          errorMsg = errData.toString();
        }
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

      final url = idHotspot > 0
          ? ApiConfig.vouchersByHotspot(idHotspot)
          : ApiConfig.vouchersAktif;

      final response = await _dio.get(
        url,
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic rawData = response.data;
        List<dynamic> listData = [];

        if (rawData is Map) {
          final dataField = rawData['data'];
          if (dataField is List) {
            listData = dataField;
          } else if (dataField is Map) {
            if (dataField['detail'] is List) {
              listData = dataField['detail'];
            } else {
              listData = [dataField];
            }
          }
        } else if (rawData is List) {
          listData = rawData;
        }

        final vouchers = await compute(_parseVouchers, listData);
        return ApiResponse(
          success: true,
          message: 'Vouchers fetched',
          data: vouchers,
        );
      } else {
        String errorMsg = 'Server Error ${response.statusCode}';
        if (response.data is Map) {
          errorMsg = response.data['pesan']?.toString() ?? errorMsg;
        }
        return ApiResponse(success: false, message: errorMsg, data: []);
      }
    } catch (e) {
      return ApiResponse(success: false, message: e.toString(), data: []);
    }
  }

  Future<ApiResponse<List<VoucherApiModel>>> getAllVouchersByPackages(
    List<int> paketIds,
  ) async {
    try {
      if (paketIds.isEmpty) {
        return ApiResponse(success: true, message: 'No packages', data: []);
      }

      final results = await Future.wait(
        paketIds.map((id) => getVouchersByPackage(id)),
      );

      final allVouchers = <VoucherApiModel>[];
      for (final r in results) {
        if (r.success && r.data != null) {
          allVouchers.addAll(r.data!);
        }
      }
      return ApiResponse(success: true, message: 'OK', data: allVouchers);
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e', data: []);
    }
  }

  Future<ApiResponse<List<VoucherApiModel>>> getAllVouchers() async {
    return getVouchersByHotspot(0);
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

      if (response.statusCode == 200) {
        final respData = response.data;
        final rawData = respData is Map ? respData['data'] : null;
        if (rawData is Map) {
          final voucher = VoucherApiModel.fromJson(
            rawData as Map<String, dynamic>,
          );
          return ApiResponse(success: true, message: 'OK', data: voucher);
        }
        return ApiResponse(
          success: false,
          message: 'Voucher data is not a Map',
        );
      } else {
        return ApiResponse(
          success: false,
          message: _getErrorMsg(response.data, 'Voucher not found'),
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
        final rawData = response.data['data'];
        if (rawData is Map) {
          voucher = VoucherApiModel.fromJson(rawData as Map<String, dynamic>);
        }
        return ApiResponse(
          success: true,
          message: _getErrorMsg(response.data, 'Voucher created'),
          data: voucher,
        );
      } else {
        return ApiResponse(
          success: false,
          message: _getErrorMsg(response.data, 'Failed'),
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
        final rawData = response.data['data'];
        if (rawData is List) {
          vouchers = await compute(_parseVouchers, rawData);
        }
        return ApiResponse(
          success: true,
          message: _getErrorMsg(response.data, 'Bulk vouchers created'),
          data: vouchers,
        );
      } else {
        return ApiResponse(
          success: false,
          message: _getErrorMsg(response.data, 'Failed'),
          data: [],
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e', data: []);
    }
  }

  Future<ApiResponse<void>> deleteVoucherBulkAll({
    List<int>? ids,
    String? status,
  }) async {
    try {
      final token = _tokenService.getToken();
      final Map<String, dynamic> body = {};
      if (ids != null && ids.isNotEmpty) body['ids'] = ids;
      if (status != null && status.isNotEmpty) body['status_voucher'] = status;

      final response = await _dio.delete(
        ApiConfig.deleteVoucherBulk,
        data: body,
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (s) => s! < 600,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          success: true,
          message: _getErrorMsg(response.data, 'Voucher berhasil dihapus'),
        );
      } else {
        return ApiResponse(
          success: false,
          message: _getErrorMsg(response.data, 'Gagal menghapus voucher'),
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
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
          message: _getErrorMsg(response.data, 'Failed to delete voucher'),
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

        if (rawData is Map) {
          listData = rawData['data'] is List ? (rawData['data'] as List) : [];
        } else if (rawData is List) {
          listData = rawData;
        }

        final vouchers = listData
            .where((e) => e is Map)
            .map(
              (json) => VoucherApiModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
        return ApiResponse(
          success: true,
          message: 'Vouchers fetched',
          data: vouchers,
        );
      } else {
        return ApiResponse(
          success: false,
          message: _getErrorMsg(
            response.data,
            'Failed to fetch active vouchers',
          ),
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
          message: _getErrorMsg(response.data, 'Gagal menjual voucher'),
          data: 0,
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e', data: 0);
    }
  }
}
