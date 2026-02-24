import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../model/api_response.dart';
import '../../config/api_config.dart';
import '../model/report_api_model.dart';
import 'token_service.dart';

class ReportService extends GetxService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );
  final TokenService _tokenService = Get.find<TokenService>();

  Future<ApiResponse<ReportDashboardApiModel?>> getDashboardReport({
    int? year,
    int? month,
  }) async {
    try {
      final token = _tokenService.getToken();
      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['tahun'] = year;
      if (month != null) queryParams['bulan'] = month;

      final response = await _dio.get(
        ApiConfig.reportDashboard,
        queryParameters: queryParams,
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: response.data['message'] ?? 'Data laporan berhasil diambil',
          data: ReportDashboardApiModel.fromJson(response.data),
        );
      } else {
        return ApiResponse(
          success: false,
          message: response.data['message'] ?? 'Gagal mengambil data laporan',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<DailyReportApiModel?>> getDailyReportHarian({
    required int tahun,
    required int bulan,
    required int tgl,
  }) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.get(
        ApiConfig.reportHarian,
        queryParameters: {'tahun': tahun, 'bulan': bulan, 'tgl': tgl},
        options: Options(headers: ApiConfig.headers(token: token)),
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: 'Success',
          data: DailyReportApiModel.fromJson(response.data['data']),
        );
      }
      return ApiResponse(success: false, message: 'Failed');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<List<DailyReportApiModel>>> getGroupedReport({
    required String type,
    required String start,
    required String end,
  }) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.get(
        ApiConfig.reportGrouped,
        queryParameters: {'type': type, 'start': start, 'end': end},
        options: Options(headers: ApiConfig.headers(token: token)),
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'] as List? ?? [];
        return ApiResponse(
          success: true,
          message: 'Success',
          data: data.map((json) => DailyReportApiModel.fromJson(json)).toList(),
        );
      }
      return ApiResponse(success: false, message: 'Failed');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<List<DailyReportApiModel>>> getRangeReport({
    required String start,
    required String end,
  }) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.get(
        ApiConfig.reportRange,
        queryParameters: {'start': start, 'end': end},
        options: Options(headers: ApiConfig.headers(token: token)),
      );

      if (response.statusCode == 200) {
        final List data = response.data['data'] as List? ?? [];
        return ApiResponse(
          success: true,
          message: 'Success',
          data: data.map((json) => DailyReportApiModel.fromJson(json)).toList(),
        );
      }
      return ApiResponse(success: false, message: 'Failed');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<ReportSummaryApiModel?>> getSummaryReport({
    required String start,
    required String end,
  }) async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.get(
        ApiConfig.reportSummary,
        queryParameters: {'start': start, 'end': end},
        options: Options(headers: ApiConfig.headers(token: token)),
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: 'Success',
          data: ReportSummaryApiModel.fromJson(response.data['data']),
        );
      }
      return ApiResponse(success: false, message: 'Failed');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<List<DailyReportApiModel>>> getDailyReports({
    int? year,
    int? month,
    String? date,
  }) async {
    try {
      final token = _tokenService.getToken();
      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['tahun'] = year;
      if (month != null) queryParams['bulan'] = month;
      if (date != null) queryParams['date'] = date;

      final response = await _dio.get(
        ApiConfig.reportDaily,
        queryParameters: queryParams,
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List? ?? [];
        return ApiResponse(
          success: true,
          message: 'Success',
          data: data.map((json) => DailyReportApiModel.fromJson(json)).toList(),
        );
      } else {
        return ApiResponse(success: false, message: 'Failed');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<List<MonthlyReportApiModel>>> getMonthlyReports({
    int? year,
  }) async {
    try {
      final token = _tokenService.getToken();
      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['tahun'] = year;

      final response = await _dio.get(
        ApiConfig.reportMonthly,
        queryParameters: queryParams,
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List? ?? [];
        return ApiResponse(
          success: true,
          message: 'Success',
          data: data
              .map((json) => MonthlyReportApiModel.fromJson(json))
              .toList(),
        );
      } else {
        return ApiResponse(success: false, message: 'Failed');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<List<YearlyReportApiModel>>> getYearlyReports() async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.get(
        ApiConfig.reportYearly,
        options: Options(
          headers: ApiConfig.headers(token: token),
          validateStatus: (status) => status! < 600,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List? ?? [];
        return ApiResponse(
          success: true,
          message: 'Success',
          data: data
              .map((json) => YearlyReportApiModel.fromJson(json))
              .toList(),
        );
      } else {
        return ApiResponse(success: false, message: 'Failed');
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }

  Future<ApiResponse<bool>> refreshReports() async {
    try {
      final token = _tokenService.getToken();
      final response = await _dio.post(
        ApiConfig.reportRefresh,
        options: Options(headers: ApiConfig.headers(token: token)),
      );

      return ApiResponse(
        success: response.statusCode == 200,
        message: response.data['message'] ?? 'Refresh Success',
        data: response.statusCode == 200,
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Error: $e');
    }
  }
}
